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
    _data = JMap.object() ; Setup Data as a fresh new Map (string map)
    JValue.retain(_data)  ; Hold onto this! Don't garbage collect it!
    JMap.setObj(Data, "commands", JIntMap.object())
    JMap.setObj(Data, "commandsByName", JMap.object())
endFunction

function ResetStorage()
    JValue.release(_data)
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
;; Execute and Invoke Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO ; int parentCommand = ConsoleCommandParser. TODO - have this give us the SPECIFIC discovered subcommand (or top level command)

string function ExecuteCommand(string command) ; Add options for whether to add the command to the command history and print it etc
    Log("ExecuteCommand '" + command + "'")
    int parseResult = ConsoleCommandParser.Parse(command)
    int parentCommand = ConsoleCommandParser.IdForCommandOrSubcommand(parseResult)
    if parentCommand
        return InvokeCommand(parentCommand, parseResult)
    else
        ; Do nothing...
    endIf
endFunction

string function InvokeCommand(int parentCommand, int parseResult)
    Log("InvokeCommand " + parentCommand)
    ; TODO walk up the tree
    
    string skseEventName = JMap.getStr(parentCommand, "skseEventName")
    ; TODO script!

    if skseEventName
        Log("SendModEvent " + skseEventName)
        string fullCommandText = ConsoleCommandParser.GetText(parseResult)
        SendModEvent(skseEventName, fullCommandText, parseResult)
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
