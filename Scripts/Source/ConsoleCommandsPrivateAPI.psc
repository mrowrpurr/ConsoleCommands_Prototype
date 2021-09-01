Scriptname ConsoleCommandsPrivateAPI extends Quest  
{Private API for Console Commands.

Please do not use.

The interfaces here may change at any time!

To use "Console Commands", please use one of the following:

- ConsoleCommand script to make your own command
- ConsoleCommands for the global interface for working with commands
- ConsoleCommandParser for parsing commands and getting command options
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Singleton ~ GetInstance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Singleton
ConsoleCommandsPrivateAPI function GetInstance() global
    return Game.GetFormFromFile(0x800, "ConsoleCommands.esp") as ConsoleCommandsPrivateAPI
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Primary data storage object
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int _data
int _commandScriptRegistrationTemplateArray

int property MAX_COMMAND_COUNT = 5120 autoReadonly

; Primary data structure for all command storage
int property Data
    int function get()
        if _data == 0
            InitializeStorage()
        endIf
        return _data
    endFunction
endProperty

; Setup data structures for storing commands and metadata
function InitializeStorage()
    if _data == 0
        _data = JMap.object() ; Setup Data as a fresh new Map (string map)
        JValue.retain(_data)  ; Hold onto this! Don't garbage collect it!
        JMap.setObj(Data, "commands", JIntMap.object())
        JMap.setObj(Data, "commandsByName", JMap.object())
        ResetCommandScriptArrays()
    endIf
endFunction

function ResetStorage()
    JValue.release(_data)
    _data = 0
    InitializeStorage()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Storage Objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Data Commands is a Map<int,int> which maps commands
; to themselves by their ID.
; This exists to make sure commands are *retained*.
int property Data_Commands
    int function get()
        return JMap.getObj(Data, "commands")
    endFunction
endProperty

; Data CommandNames is a Map<string,int> which maps command names
; to the object ID of that command.
; There may be multiple names which all point to the same command.
int property Data_CommandNames
    int function get()
        return JMap.getObj(Data, "commandsByName")
    endFunction
endProperty

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Log(string text)
    Debug.Trace("[ConsoleCommands] " + text)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool property DisableCommandAutoRegistration auto

int function GetCommand(string name)
    return JMap.getObj(Data_CommandNames, name)
endFunction

int function AddCommand(string name)
    int command = JMap.object()
    JMap.setObj(Data_CommandNames, name, command)               ; Add to command name ==> command ID map
    JMap.setStr(command, "name", name)                          ; Let the command know its name
    JMap.setInt(command, "commandId", command)                  ; Reference to command for use in subcommands (every parent (command/subcommand) should have a reference back to the command)
    JMap.setStr(command, "fullName", name)                      ; fullName for use in subcommands (every parent (command/subcommand) should have a fullName)
    JMap.setObj(command, "allSubcommands", JMap.object())       ; Add subcommand full name ==> subcommand ID map (this is only on the command, not subcommands)
    JMap.setObj(command, "subcommands", JIntMap.object())       ; Add subcommand ==> subcommand ID map
    JMap.setObj(command, "subcommandsByName", JMap.object())    ; Add subcommand name ==> subcommand ID map
    JMap.setObj(command, "flags", JIntMap.object())             ; Add flag ==> flag ID map
    JMap.setObj(command, "flagsByName", JMap.object())          ; Add flag name ==> flag ID map
    JMap.setObj(command, "options", JIntMap.object())           ; Add option ==> option ID map
    JMap.setObj(command, "optionsByName", JMap.object())        ; Add option name ==> option ID map
    JMap.setObj(command, "flagAndOptionsByText", JMap.object()) ; Add joint lookup for flags/options by console text, e.g. "--silent" "-s" (does not store options for any subcommands)
    ; Add aliases so commands know their aliases
    JIntMap.setObj(Data_Commands, command, command)             ; Add to command ==> command map
    return command
endFunction

; TODO AddCommandAlias()

function RemoveCommand(string name)
    int command = GetCommand(name)
    if command
        JMap.removeKey(Data_CommandNames, name)   ; Remove from names map
        JIntMap.removeKey(Data_Commands, command) ; Remove command object
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;s

int function GetSubcommand(int parentCommand, string subcommandText)
    string[] parts = StringUtil.Split(subcommandText, " ") ; extra spaces or quotations etc are _not allowed_, this does _not_ use the parser, just a fast simple loop
    int subcommand = 0
    int partIndex = 0
    while partIndex < parts.Length
        string part = parts[partIndex]
        int parentCommandSubcommandsByName = JMap.getObj(parentCommand, "subcommandsByName")
        subcommand = JMap.getObj(parentCommandSubcommandsByName, part)
        if subcommand
            if partIndex == parts.Length - 1 ; If this is the final part, return it, else keep going thru to find it!
                return subcommand
            endIf
        else
            return 0 ; we didn't find any subcommand matching this name
        endIf
        partIndex += 1
    endWhile
    return 0
endFunction

int function AddSubcommand(int parentCommand, string subcommandName)
    string parentFullCommand = JMap.getStr(parentCommand, "fullName")
    int commandId = JMap.getInt(parentCommand, "commandId")
    string fullName = parentFullCommand + " " + subcommandName
    int subcommands = JMap.getObj(parentCommand, "subcommands")
    int subcommandsByName = JMap.getObj(parentCommand, "subcommandsByName")
    int subcommand = JMap.object()
    JIntMap.setObj(subcommands, subcommand, subcommand)            ; Add to parents' subcommands
    JMap.setObj(subcommandsByName, subcommandName, subcommand)     ; Add to parents' subcommands
    JMap.setStr(subcommand, "name", subcommandName)                ; Let the subcommand know its name
    JMap.setInt(subcommand, "commandId", commandId)                ; Reference to command for use in subcommands (every parent (command/subcommand) should have a reference back to the command)
    JMap.setStr(subcommand, "fullName", fullName)                  ; Let the subcommand know its full name (including parent command/subcommands)
    JMap.setObj(subcommand, "parent", parentCommand)               ; Let the subcommand know its parent (another subcommand or top-level command)
    JMap.setObj(subcommand, "subcommands", JIntMap.object())       ; Add subcommand ==> subcommand ID map
    JMap.setObj(subcommand, "subcommandsByName", JMap.object())    ; Add subcommand name ==> subcommand ID map
    JMap.setObj(subcommand, "flags", JIntMap.object())             ; Add flag ==> flag ID map
    JMap.setObj(subcommand, "flagsByName", JMap.object())          ; Add flag name ==> flag ID map
    JMap.setObj(subcommand, "options", JIntMap.object())           ; Add option ==> option ID map
    JMap.setObj(subcommand, "optionsByName", JMap.object())        ; Add option name ==> option ID map
    JMap.setObj(subcommand, "flagAndOptionsByText", JMap.object()) ; Add joint lookup for flags/options by console text, e.g. "--silent" "-s" (does not store options for any subcommands)
    ; Add aliases so commands know their aliases
    Log("Add Subcommand " + subcommandName + " Full: " + fullName + " ID: " + subcommand)
    int allSubcommands = JMap.getObj(commandId, "allSubcommands")
    Log("Adding " + fullName + " to allSubcommands " + allSubcommands + " for command " + commandId)
    JMap.setObj(allSubcommands, fullName, subcommand)
    return subcommand
endFunction

function AddSubcommandAlias(int subcommand, string aliasName)
    int parentCommand = JMap.getObj(subcommand, "parent") ; this could be the top-level command or a subcommand
    string parentCommandFullName = JMap.getStr(parentCommand, "fullname")
    int subcommandsByName = JMap.getObj(parentCommand, "subcommandsByName")
    JMap.setObj(subcommandsByName, aliasName, subcommand) ; Adds a key mapping the alias to this subcommand
    int command = JMap.getObj(parentCommand, "parent")
    int allSubcommands = JMap.getObj(command, "allSubcommands")
    JMap.setObj(allSubcommands, parentCommandFullName + " " + aliasName, subcommand) ; Add the alias to the map of ALL subcommands available for this command
endFunction

function RemoveSubcommand(int parentCommand, int subcommand)
    int immediateParent = JMap.getObj(subcommand, "parent")

    string name = JMap.getStr(subcommand, "name")
    int subcommandsByName = JMap.getObj(immediateParent, "subcommandsByName")
    JMap.removeKey(subcommandsByName, name)

    int command = JMap.getObj(subcommand, "parent")
    int allSubcommands = JMap.getObj(command, "allSubcommands")
    string fullName = JMap.getStr(subcommand, "fullName")
    JMap.removeKey(allSubcommands, fullName)

    int subcommands = JMap.getObj(immediateParent, "subcommands")
    JIntMap.removeKey(subcommands, subcommand) ; Removes last reference, it can now be released automatically
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Commands and Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;s

int function GetCommandOrSubcommandByFullName(string fullCommand)
    string[] parts = StringUtil.Split(fullCommand, " ")
    if parts.Length == 1
        return GetCommand(fullCommand) ; <--- update this to work with aliases too :) use a lookup table on the main _data OR move the MAIN TABLE up to _data? nah, actually this table can't work due to alias changes! Remove the table...
    elseIf parts.Length > 1
        int command = GetCommand(parts[0])
        if command
            int allSubcommands = JMap.getObj(command, "allSubcommands")
            Log("Looking for " + fullCommand + " in " + JMap.allKeysPArray(allSubcommands))
            return JMap.getObj(allSubcommands, fullCommand)
        endIf
    endIf
    Log("Command or Subcommand not found by full command: '" + fullCommand + "'")
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function GetFlag(int parentCommand, string name)
    int flagsByName = JMap.getObj(parentCommand, "flagsByName")
    return JMap.getObj(flagsByName, name)
endFunction

int function AddFlag(int parentCommand, string name, string short = "")
    int flagsIntMap = JMap.getObj(parentCommand, "flags")
    int flagsByName = JMap.getObj(parentCommand, "flagsByName")
    int flagAndOptionsByText = JMap.getObj(parentCommand, "flagAndOptionsByText")
    int flagMap = JMap.object()
    JIntMap.setObj(flagsIntMap, flagMap, flagMap)
    JMap.setStr(flagMap, "name", name)
    JMap.setStr(flagMap, "short", short)
    JMap.setObj(flagsByName, name, flagMap)
    string textArgument = "--" + name
    JMap.setObj(flagAndOptionsByText, textArgument, flagMap)
    if short
        textArgument = "-" + short
        JMap.setObj(flagAndOptionsByText, textArgument, flagMap)
    endIf
    return flagMap
endFunction

function RemoveFlag(int parentCommand, int flag)
    int flagsIntMap = JMap.getObj(parentCommand, "flags")
    int flagsByName = JMap.getObj(parentCommand, "flagsByName")
    int flagAndOptionsByText = JMap.getObj(parentCommand, "flagAndOptionsByText")
    string name = JMap.getStr(flag, "name")
    string textArgument = "--" + name
    JMap.removeKey(flagAndOptionsByText, textArgument)
    string short = JMap.getStr(flag, "short")
    if short
        textArgument = "-" + short
        JMap.removeKey(flagAndOptionsByText, textArgument)
    endIf
    JMap.removeKey(flagsByName, name)
    JIntMap.removeKey(flagsIntMap, flag)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Execute and Invoke Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO ; int parentCommand = ConsoleCommandParser. TODO - have this give us the SPECIFIC discovered subcommand (or top level command)

string function ExecuteCommand(string command) ; Add options for whether to add the command to the command history and print it etc
    Log("ExecuteCommand '" + command + "'")
    int parseResult = ConsoleCommandParser.Parse(command)
    int parentCommand = ConsoleCommandParser.IdForCommandOrSubcommand(parseResult)
    if parentCommand
        JValue.retain(parseResult)
        string response = InvokeCommand(parentCommand, parseResult)
        JValue.release(parseResult)
        return response
    else
        Log("Command not custom, invoking natively: " + command)
        return ConsoleMenu.ExecuteCommand(command) ; TODO pass options...
    endIf
endFunction

string function InvokeCommand(int parentCommand, int parseResult)
    Log("InvokeCommand " + parentCommand)
    ; TODO walk up the tree
    
    string skseEventName = JMap.getStr(parentCommand, "skseEventName")
    if skseEventName
        Log("SendModEvent " + skseEventName)
        string fullCommandText = ConsoleCommandParser.GetText(parseResult)
        SendModEvent(skseEventName, fullCommandText, parseResult)
    endIf

    int registeredScriptSlot = JMap.getInt(parentCommand, "scriptRegistrationSlot")
    if registeredScriptSlot
        ConsoleCommand script = GetScript(registeredScriptSlot)
        if script
            Log("Invoking OnCommand for script: " + script)
            return script.InvokeCommand(parseResult)
        endIf
    endIf

    return "" ; TODO return result, even from SKSE Mod Events (by reading from the console)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SKSE Mod Event Command Handlers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function RegisterEvent(int parentCommand, string eventName)
    Log("Register for mod event " + parentCommand + " " + eventName)
    JMap.setStr(parentCommand, "skseEventName", eventName)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ConsoleCommand script registration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float _scriptRegistrationLock

; Console Commands currently supports a maximum of 5,120 console command scripts
ConsoleCommand[] _commandScripts0
ConsoleCommand[] _commandScripts1
ConsoleCommand[] _commandScripts2
ConsoleCommand[] _commandScripts3
ConsoleCommand[] _commandScripts4
ConsoleCommand[] _commandScripts5
ConsoleCommand[] _commandScripts6
ConsoleCommand[] _commandScripts7
ConsoleCommand[] _commandScripts8
ConsoleCommand[] _commandScripts9
ConsoleCommand[] _commandScripts10
ConsoleCommand[] _commandScripts11
ConsoleCommand[] _commandScripts12
ConsoleCommand[] _commandScripts13
ConsoleCommand[] _commandScripts14
ConsoleCommand[] _commandScripts15
ConsoleCommand[] _commandScripts16
ConsoleCommand[] _commandScripts17
ConsoleCommand[] _commandScripts18
ConsoleCommand[] _commandScripts19
ConsoleCommand[] _commandScripts20
ConsoleCommand[] _commandScripts21
ConsoleCommand[] _commandScripts22
ConsoleCommand[] _commandScripts23
ConsoleCommand[] _commandScripts24
ConsoleCommand[] _commandScripts25
ConsoleCommand[] _commandScripts26
ConsoleCommand[] _commandScripts27
ConsoleCommand[] _commandScripts28
ConsoleCommand[] _commandScripts29
ConsoleCommand[] _commandScripts30
ConsoleCommand[] _commandScripts31
ConsoleCommand[] _commandScripts32
ConsoleCommand[] _commandScripts33
ConsoleCommand[] _commandScripts34
ConsoleCommand[] _commandScripts35
ConsoleCommand[] _commandScripts36
ConsoleCommand[] _commandScripts37
ConsoleCommand[] _commandScripts38
ConsoleCommand[] _commandScripts39

function ResetCommandScriptArrays()
    Log("Resetting Command Script Arrays...")
    _commandScripts0 = new ConsoleCommand[128]
    _commandScripts1 = new ConsoleCommand[128]
    _commandScripts2 = new ConsoleCommand[128]
    _commandScripts3 = new ConsoleCommand[128]
    _commandScripts4 = new ConsoleCommand[128]
    _commandScripts5 = new ConsoleCommand[128]
    _commandScripts6 = new ConsoleCommand[128]
    _commandScripts7 = new ConsoleCommand[128]
    _commandScripts8 = new ConsoleCommand[128]
    _commandScripts9 = new ConsoleCommand[128]
    _commandScripts10 = new ConsoleCommand[128]
    _commandScripts11 = new ConsoleCommand[128]
    _commandScripts12 = new ConsoleCommand[128]
    _commandScripts13 = new ConsoleCommand[128]
    _commandScripts14 = new ConsoleCommand[128]
    _commandScripts15 = new ConsoleCommand[128]
    _commandScripts16 = new ConsoleCommand[128]
    _commandScripts17 = new ConsoleCommand[128]
    _commandScripts18 = new ConsoleCommand[128]
    _commandScripts19 = new ConsoleCommand[128]
    _commandScripts20 = new ConsoleCommand[128]
    _commandScripts21 = new ConsoleCommand[128]
    _commandScripts22 = new ConsoleCommand[128]
    _commandScripts23 = new ConsoleCommand[128]
    _commandScripts24 = new ConsoleCommand[128]
    _commandScripts25 = new ConsoleCommand[128]
    _commandScripts26 = new ConsoleCommand[128]
    _commandScripts27 = new ConsoleCommand[128]
    _commandScripts28 = new ConsoleCommand[128]
    _commandScripts29 = new ConsoleCommand[128]
    _commandScripts30 = new ConsoleCommand[128]
    _commandScripts31 = new ConsoleCommand[128]
    _commandScripts32 = new ConsoleCommand[128]
    _commandScripts33 = new ConsoleCommand[128]
    _commandScripts34 = new ConsoleCommand[128]
    _commandScripts35 = new ConsoleCommand[128]
    _commandScripts36 = new ConsoleCommand[128]
    _commandScripts37 = new ConsoleCommand[128]
    _commandScripts38 = new ConsoleCommand[128]
    _commandScripts39 = new ConsoleCommand[128]

    if ! _commandScriptRegistrationTemplateArray
        Log("Setting up Command Script Arrays template...")
        _commandScriptRegistrationTemplateArray = JArray.object()
        JValue.retain(_commandScriptRegistrationTemplateArray)
        int index = 0
        while index < MAX_COMMAND_COUNT
            JArray.addInt(_commandScriptRegistrationTemplateArray, index)
            index += 1
        endWhile
        Log("Command Script Arrays template complete.")
    endIf

    int availableScriptIndices = JArray.object()
    JArray.addFromArray(availableScriptIndices, _commandScriptRegistrationTemplateArray)
    JMap.setObj(Data, "availableScriptIndices", availableScriptIndices)
    
    Log("Command Script Arrays Reset.")
endFunction

function StoreScript(int slot, ConsoleCommand script)
    int arrayNumber = slot / 128
    int arrayIndex = slot % 128
    if arrayNumber == 0
        _commandScripts0[arrayIndex] = script
    elseIf arrayNumber == 1
        _commandScripts1[arrayIndex] = script
    elseIf arrayNumber == 2
        _commandScripts2[arrayIndex] = script
    elseIf arrayNumber == 3
        _commandScripts3[arrayIndex] = script
    elseIf arrayNumber == 4
        _commandScripts4[arrayIndex] = script
    elseIf arrayNumber == 5
        _commandScripts5[arrayIndex] = script
    elseIf arrayNumber == 6
        _commandScripts6[arrayIndex] = script
    elseIf arrayNumber == 7
        _commandScripts7[arrayIndex] = script
    elseIf arrayNumber == 8
        _commandScripts8[arrayIndex] = script
    elseIf arrayNumber == 9
        _commandScripts9[arrayIndex] = script
    elseIf arrayNumber == 10
        _commandScripts10[arrayIndex] = script
    elseIf arrayNumber == 11
        _commandScripts11[arrayIndex] = script
    elseIf arrayNumber == 12
        _commandScripts12[arrayIndex] = script
    elseIf arrayNumber == 13
        _commandScripts13[arrayIndex] = script
    elseIf arrayNumber == 14
        _commandScripts14[arrayIndex] = script
    elseIf arrayNumber == 15
        _commandScripts15[arrayIndex] = script
    elseIf arrayNumber == 16
        _commandScripts16[arrayIndex] = script
    elseIf arrayNumber == 17
        _commandScripts17[arrayIndex] = script
    elseIf arrayNumber == 18
        _commandScripts18[arrayIndex] = script
    elseIf arrayNumber == 19
        _commandScripts19[arrayIndex] = script
    elseIf arrayNumber == 20
        _commandScripts20[arrayIndex] = script
    elseIf arrayNumber == 21
        _commandScripts21[arrayIndex] = script
    elseIf arrayNumber == 22
        _commandScripts22[arrayIndex] = script
    elseIf arrayNumber == 23
        _commandScripts23[arrayIndex] = script
    elseIf arrayNumber == 24
        _commandScripts24[arrayIndex] = script
    elseIf arrayNumber == 25
        _commandScripts25[arrayIndex] = script
    elseIf arrayNumber == 26
        _commandScripts26[arrayIndex] = script
    elseIf arrayNumber == 27
        _commandScripts27[arrayIndex] = script
    elseIf arrayNumber == 28
        _commandScripts28[arrayIndex] = script
    elseIf arrayNumber == 29
        _commandScripts29[arrayIndex] = script
    elseIf arrayNumber == 30
        _commandScripts30[arrayIndex] = script
    elseIf arrayNumber == 31
        _commandScripts31[arrayIndex] = script
    elseIf arrayNumber == 32
        _commandScripts32[arrayIndex] = script
    elseIf arrayNumber == 33
        _commandScripts33[arrayIndex] = script
    elseIf arrayNumber == 34
        _commandScripts34[arrayIndex] = script
    elseIf arrayNumber == 35
        _commandScripts35[arrayIndex] = script
    elseIf arrayNumber == 36
        _commandScripts36[arrayIndex] = script
    elseIf arrayNumber == 37
        _commandScripts37[arrayIndex] = script
    elseIf arrayNumber == 38
        _commandScripts38[arrayIndex] = script
    elseIf arrayNumber == 39
        _commandScripts39[arrayIndex] = script
    endIf
endFunction

ConsoleCommand function GetScript(int slot)
    int arrayNumber = slot / 128
    int arrayIndex = slot % 128
    if arrayNumber == 0
        return _commandScripts0[arrayIndex]
    elseIf arrayNumber == 1
        return _commandScripts1[arrayIndex]
    elseIf arrayNumber == 2
        return _commandScripts2[arrayIndex]
    elseIf arrayNumber == 3
        return _commandScripts3[arrayIndex]
    elseIf arrayNumber == 4
        return _commandScripts4[arrayIndex]
    elseIf arrayNumber == 5
        return _commandScripts5[arrayIndex]
    elseIf arrayNumber == 6
        return _commandScripts6[arrayIndex]
    elseIf arrayNumber == 7
        return _commandScripts7[arrayIndex]
    elseIf arrayNumber == 8
        return _commandScripts8[arrayIndex]
    elseIf arrayNumber == 9
        return _commandScripts9[arrayIndex]
    elseIf arrayNumber == 10
        return _commandScripts10[arrayIndex]
    elseIf arrayNumber == 11
        return _commandScripts11[arrayIndex]
    elseIf arrayNumber == 12
        return _commandScripts12[arrayIndex]
    elseIf arrayNumber == 13
        return _commandScripts13[arrayIndex]
    elseIf arrayNumber == 14
        return _commandScripts14[arrayIndex]
    elseIf arrayNumber == 15
        return _commandScripts15[arrayIndex]
    elseIf arrayNumber == 16
        return _commandScripts16[arrayIndex]
    elseIf arrayNumber == 17
        return _commandScripts17[arrayIndex]
    elseIf arrayNumber == 18
        return _commandScripts18[arrayIndex]
    elseIf arrayNumber == 19
        return _commandScripts19[arrayIndex]
    elseIf arrayNumber == 20
        return _commandScripts20[arrayIndex]
    elseIf arrayNumber == 21
        return _commandScripts21[arrayIndex]
    elseIf arrayNumber == 22
        return _commandScripts22[arrayIndex]
    elseIf arrayNumber == 23
        return _commandScripts23[arrayIndex]
    elseIf arrayNumber == 24
        return _commandScripts24[arrayIndex]
    elseIf arrayNumber == 25
        return _commandScripts25[arrayIndex]
    elseIf arrayNumber == 26
        return _commandScripts26[arrayIndex]
    elseIf arrayNumber == 27
        return _commandScripts27[arrayIndex]
    elseIf arrayNumber == 28
        return _commandScripts28[arrayIndex]
    elseIf arrayNumber == 29
        return _commandScripts29[arrayIndex]
    elseIf arrayNumber == 30
        return _commandScripts30[arrayIndex]
    elseIf arrayNumber == 31
        return _commandScripts31[arrayIndex]
    elseIf arrayNumber == 32
        return _commandScripts32[arrayIndex]
    elseIf arrayNumber == 33
        return _commandScripts33[arrayIndex]
    elseIf arrayNumber == 34
        return _commandScripts34[arrayIndex]
    elseIf arrayNumber == 35
        return _commandScripts35[arrayIndex]
    elseIf arrayNumber == 36
        return _commandScripts36[arrayIndex]
    elseIf arrayNumber == 37
        return _commandScripts37[arrayIndex]
    elseIf arrayNumber == 38
        return _commandScripts38[arrayIndex]
    elseIf arrayNumber == 39
        return _commandScripts39[arrayIndex]
    endIf
endFunction

function RegisterScript(int parentCommand, ConsoleCommand script, float lock = 0.0, int availableScriptIndices = 0)
    if availableScriptIndices == 0
        availableScriptIndices = JMap.getObj(Data, "availableScriptIndices")
    endIf

    if lock == 0.0
        lock = Utility.RandomFloat(1.0, 10000.0)
    endIf

    while _scriptRegistrationLock != 0.0
        Utility.WaitMenuMode(0.01)
    endWhile

    _scriptRegistrationLock = lock

    if _scriptRegistrationLock == lock
        if _scriptRegistrationLock == lock
            int availableIndicesCount = JArray.count(availableScriptIndices)
            if availableScriptIndices == 0
                Log("No available script slots to register command " + script + " (are there 5,120 command registered? that is the maximum.)")
                return
            endIf
            int registrationSlot = JArray.getInt(availableScriptIndices, availableIndicesCount - 1)
            if registrationSlot == 0
                registrationSlot = JArray.getInt(availableScriptIndices, availableIndicesCount - 1)
            endIf
            if registrationSlot == 0
                Log("Could not get available script slot for command " + script + " (are there 5,120 command registered? that is the maximum.)")
            endIf
            JArray.eraseIndex(availableScriptIndices, 0)
            _scriptRegistrationLock = 0.0
            StoreScript(registrationSlot, script)
            JMap.setInt(parentCommand, "scriptRegistrationSlot", registrationSlot)
            Log("Registered Script " + script + " in slot #" + registrationSlot)
        else
            RegisterScript(parentCommand, script, lock, availableScriptIndices)
        endIf
    else
        RegisterScript(parentCommand, script, lock, availableScriptIndices)
    endIf
endFunction
