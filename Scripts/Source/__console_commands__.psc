scriptName __console_commands__ extends Quest hidden 
{Private Quest script for persisting global data for Custom Console Commands}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Logging configuration
bool   property DebugToPapyrus                         auto
bool   property DebugToConsole                         auto ; <--- TODO: turn this off for mod release!
bool   property DebugToNotifications                   auto
bool   property LogToPapyrus                           auto
bool   property LogToConsole                           auto
bool   property LogToNotifications                     auto
string property LOG_PREFIX = "[ConsoleCommands] " autoReadonly

; Logging function for debugging
function Debug(string text)
    if DebugToPapyrus
        Debug.Trace(LOG_PREFIX + text)
    endIf
    if DebugToConsole
        ConsoleHelper.Print(LOG_PREFIX + text + "\n")
    endIf
    if DebugToNotifications
        Debug.Notification(LOG_PREFIX + text)
    endIf
endFunction

; Logging function for providing information to users
function Log(string text)
    if LogToPapyrus
        Debug.Trace(LOG_PREFIX + text)
    endIf
    if LogToConsole
        ConsoleHelper.Print(LOG_PREFIX + text + "\n")
    endIf
    if LogToNotifications
        Debug.Notification(LOG_PREFIX + text)
    endIf
endFunction

; Requires PapyrusUtil:
function InspectObject(int obj)
    string filePath = "Data/ConsoleCommands/Log/Object-" + obj + ".json"
    JValue.writeToFile(obj, filePath)
    ConsoleHelper.Print(MiscUtil.ReadFromFile(filePath))
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; [INTERNAL]
; Returns an instance of __console_commands__ (used for persisting all Custom Console Commands data)
; Please do not use the interface provided by this script.
; Instead, use either the ConsoleCommands global interface
; or, preferably, create commands by making Quest scripts which extend ConsoleCommand.
__console_commands__ function GetInstance() global
    return Game.GetFormFromFile(0x800, "ConsoleCommands.esp") as __console_commands__
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fields and Properties
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Whether the mod has been initialized yet
bool _initialized

; Whether we're currently listening for any console commands
bool _listeningForCommands

; References to data for storing commands and their data
int _data
int _commandNameToObjectMap
int _commandIdToObjectMap
int _enabledCommandAndSubcommandIdsArray

; Keys used in maps
string property NAME_KEY             = "name"            autoReadonly
string property COMMAND_KEY          = "command"         autoReadonly
string property COMMANDS_KEY         = "commands"        autoReadonly
string property COMMAND_NAMES_KEY    = "commandNames"    autoReadonly
string property ENABLED_COMMANDS_KEY = "enabledCommands" autoReadonly
string property COMMAND_MAP_KEY      = "commandMap"      autoReadonly
string property COMMAND_TEXT_KEY     = "text"            autoReadonly
string property SUBCOMMAND_KEY       = "subcommand"      autoReadonly
string property SUBCOMMANDS_KEY      = "subcommands"     autoReadonly
string property FLAGS_KEY            = "flags"           autoReadonly
string property OPTIONS_KEY          = "options"         autoReadonly
string property ARGUMENTS_KEY        = "arguments"       autoReadonly
string property CALLBACK_EVENT_KEY   = "callback"        autoReadonly
string property SCRIPT_INSTANCE_KEY  = "script"          autoReadonly
string property DESCRIPTION_KEY      = "description"     autoReadonly
string property SHORT_NAME_KEY       = "short"           autoReadonly
string property FLAG_OPTION_TYPE_KEY = "type"            autoReadonly
string property ENABLED_KEY          = "enabled"         autoReadonly
string property FLAG_TYPE            = "flag"            autoReadonly
string property OPTION_TYPE          = "option"          autoReadonly
string property OPTION_TYPE_KEY      = "optionType"      autoReadonly
string property FLOAT_TYPE           = "float"           autoReadonly
string property INT_TYPE             = "int"             autoReadonly
string property STRING_TYPE          = "string"          autoReadonly

; Console Helper integration
string CONSOLE_HELPER_EVENT_NAME  = "ConsoleCommandsEvent_INTERNAL"
string CONSOLE_HELPER_CALLBACK_FN = "OnConsoleCommand" 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mod Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Called from a variety of places to make sure that the data is setup
; and ready to store, e.g. for cases when other mods' OnInit
; loads before ours :)
function Setup()
    if ! _initialized
        _initialized = true
        SetupCommandsDataRepository()
        ConfigureLogging()
    endIf
endFunction

; Runs the first time the mod is installed.
; See ___console_commands___.OnPlayerLoadGame() for load event handling
; after the mod has already been installed.
event OnInit()
    Setup()
endEvent

; Configure logging to Console/Notifications/Papyrus Log
function ConfigureLogging()
    DebugToConsole = true ; TODO ** Turn this OFF for public release **
    DebugToPapyrus = true
    DebugToNotifications = false
    LogToConsole = true
    LogToPapyrus = true
    LogToNotifications = false
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Setup the JContainer JMap which stores *all* information about commands.
function SetupCommandsDataRepository()
    if _data != 0
        return
    endIf

    _data = JMap.object()
    JValue.retain(_data)

    _commandNameToObjectMap = JMap.object()
    _commandIdToObjectMap = JIntMap.object()
    _enabledCommandAndSubcommandIdsArray = JArray.object()

    JMap.setObj(_data, COMMANDS_KEY, _commandIdToObjectMap)
    JMap.setObj(_data, COMMAND_NAMES_KEY, _commandNameToObjectMap)
    JMap.setObj(_data, ENABLED_COMMANDS_KEY, _enabledCommandAndSubcommandIdsArray)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Use this to get the map of command names ==> id of command
int function GetMap_CommandNamesToMaps()
    if _commandNameToObjectMap == 0
        SetupCommandsDataRepository()
    endIf
    return _commandNameToObjectMap
endFunction

; Use this to get the map of ids ==> command objects
; This is just so that there is a retained data structure
; which stores references to these objects :)
int function GetMap_CommandIdsToMaps()
    if _commandIdToObjectMap
        SetupCommandsDataRepository()
    endIf
    return _commandIdToObjectMap
endFunction

;; TODO helpers which only return ENABLED commands / subcommands :)

; Helper to get command map object for command with provided name (or returns 0)
int function GetCommandMapForCommandName(string command)
    Debug("Looking for command " + command)
    return JMap.getObj(GetMap_CommandNamesToMaps(), command)
endFunction

; Helper to get subcommand map object for subcommand with provided name (or returns 0)
int function GetSubcommandMapForName(string command, string subcommand)
    int commandMap = GetCommandMapForCommandName(command)
    if commandMap
        int subcommandsMap = JMap.getObj(commandMap, SUBCOMMANDS_KEY)
        return JMap.getObj(subcommandsMap, subcommand)
    endIf
endFunction

; Helper to get command OR subcommand map object for the provided name(s) (or returns 0)
int function GetCommandOrSubcommandMapForName(string command, string subcommand)
    int commandMap = GetCommandMapForCommandName(command)
    if commandMap
        if subcommand
            int subcommandsMap = JMap.getObj(commandMap, SUBCOMMANDS_KEY)
            int subcommandMap = JMap.getObj(subcommandsMap, subcommand)
            if subcommandMap
                return subcommandMap
            endIf
        endIf
    endIf
    return commandMap
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns whether a command is registered with the given name
bool function CommandExists(string command)
    return JMap.hasKey(GetMap_CommandNamesToMaps(), command)
endFunction

; Create a new JMap to represent this command and its information
; The command is added to the list of registered command
; This does not check to see if a command with the same name already exists
int function CreateAndRegisterNewCommandMapForCommandName(string command)
    int commandMap = CreateAndRegisterNewCommandMap()
    JMap.setStr(commandMap, NAME_KEY, command)
    JMap.setObj(GetMap_CommandNamesToMaps(), command, commandMap) ; Add it to the map of names => objects
    return commandMap
endFunction

; Creates and returns a new, registered command map (without a name)
int function CreateAndRegisterNewCommandMap()
    int commandMap = JMap.object()
    JMap.setObj(commandMap, SUBCOMMANDS_KEY, JMap.object())
    JMap.setObj(commandMap, FLAGS_KEY, JMap.object())
    JMap.setObj(commandMap, OPTIONS_KEY, JMap.object())
    JMap.setInt(commandMap, ENABLED_KEY, 1) ; Enabled by default unless disabled
    JIntMap.setObj(GetMap_CommandIdsToMaps(), commandMap, commandMap) ; Add it to the ID map which retains everything
    return commandMap
endFunction

int function CreateAndRegisterNewSubcommand(int commandMap, string subcommand)
    int subcommandMap = JMap.object()
    JMap.setStr(subcommandMap, NAME_KEY, subcommand)
    JMap.setObj(subcommandMap, FLAGS_KEY, JMap.object())
    JMap.setObj(subcommandMap, OPTIONS_KEY, JMap.object())
    int subcommandsMap = JMap.getObj(commandMap, SUBCOMMANDS_KEY)
    JMap.setObj(subcommandsMap, subcommand, subcommandMap)
    return subcommandMap
endfunction

function EnableCommandOrSubcommand(int id)
    Debug("Enable command or subcommand " + JMap.getStr(id, NAME_KEY))
    JArray.addObj(_enabledCommandAndSubcommandIdsArray, id)
    StartOrStopListeningForCommandsBasedOnEnabledCommands()
endFunction

function DisableCommandOrSubcommand(int id)
    JArray.eraseObject(_enabledCommandAndSubcommandIdsArray, id)
    StartOrStopListeningForCommandsBasedOnEnabledCommands()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start/Stop Listening for Custom Console Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Register handler with ConsoleHelper to begin listening to Console Commands
function ListenForCommands()
    _listeningForCommands = true
    ConsoleHelper.RegisterForCustomCommands(CONSOLE_HELPER_EVENT_NAME)
    RegisterForModEvent(CONSOLE_HELPER_EVENT_NAME, CONSOLE_HELPER_CALLBACK_FN)
endFunction

; Unregister handler with ConsoleHelper to stop listening to Console Commands
function StopListeningForCommands()
    _listeningForCommands = false
    ConsoleHelper.UnregisterForCustomCommands(CONSOLE_HELPER_EVENT_NAME)
    UnregisterForModEvent(CONSOLE_HELPER_EVENT_NAME)
endFunction

; Called automatically when you Enable or Disable a command or subcommand.
; If any commands are enabled, we'll make sure we're listening.
; If no commands are enabled, we'll stop listening.
function StartOrStopListeningForCommandsBasedOnEnabledCommands()
    bool anyEnabledCommands = JArray.count(_enabledCommandAndSubcommandIdsArray)
    if _listeningForCommands && ! anyEnabledCommands
        StopListeningForCommands()
        Debug("Stopped listening for commands (no more enabled commands)")
    elseIf ! _listeningForCommands && anyEnabledCommands
        ListenForCommands()
        Debug("Started listening for commands")
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function GetCommandNameForScript(ConsoleCommand scriptInstance)
    string fullScriptName = scriptInstance
    int space = StringUtil.Find(fullScriptName, " ")
    string nameOfScript = StringUtil.Substring(fullScriptName, 1, space - 1)
    int commandWord = StringUtil.Find(nameOfScript, "Command")
    if commandWord > -1 && commandWord != 0
        string commandName = StringUtil.Substring(nameOfScript, 0, commandWord)
        return commandName
    endIf
    return ""
endFunction

function SetupNewCommandAndItsSubcommands(int commandMap)
    bool commandIsEnabled = JMap.getInt(commandMap, ENABLED_KEY)
    if commandIsEnabled
        int subcommandsMap = JMap.getObj(commandMap, SUBCOMMANDS_KEY)
        string[] subcommandNames = JMap.allKeysPArray(subcommandsMap)
        int index = 0
        while index < subcommandNames.Length
            ; int subcommand ....
            EnableCommandOrSubcommand(JMap.getObj(subcommandsMap, subcommandNames[index]))
            index += 1
        endWhile
        EnableCommandOrSubcommand(commandMap)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; When Custom Console Commands are enabled and listening for commands,
; this handles *all* of the commands which are sent to the console.
event OnConsoleCommand(string skseEventName, string commandText, float _, Form sender)
    Debug("OnConsoleCommand " + commandText)
    int result = Parse(commandText)
    int command = ParseResult_CommandMap(result)
    if command
        Debug("OnConsoleCommand command: " + ConsoleCommands.ParseResult_Command(result))
        string eventName = JMap.getStr(command, CALLBACK_EVENT_KEY)
        int subcommand = ParseResult_SubcommandMap(result)
        if subcommand
            Debug("OnConsoleCommand subcommand: " + ConsoleCommands.ParseResult_Subcommand(result))
            string subcommandEventName = JMap.getStr(subcommand, CALLBACK_EVENT_KEY)
            if subcommandEventName
                eventName = subcommandEventName
            endIf
        endIf
        if eventName
            SendModEvent(eventName, commandText, 0.0)
            ; Pending Commands array support in ConsoleHelper
            UI.InvokeString(ConsoleHelper.GetMenuName(), ConsoleHelper.GetInstanceTarget("AddHistory"), commandText)
            UI.InvokeString(ConsoleHelper.GetMenuName(), ConsoleHelper.GetInstanceTarget("Commands.push"), commandText)
        else
            ; Check for a script to invoke instead?
            Debug("No event name for command: " + commandText)
            ExecuteCommand(commandText)
        endIf
    else
        ExecuteCommand(commandText)
    endIf
endEvent

; Invokes command given a parse result
function InvokeCommand(int parseResult)
    Debug("Invoke command: " + JMap.getStr(parseResult, COMMAND_TEXT_KEY))
    int command = ParseResult_CommandMap(parseResult)
    int subcommand = ParseResult_SubcommandMap(parseResult)
    string commandSkseEvent = JMap.getStr(command, CALLBACK_EVENT_KEY)    
    string subcommandSkseEvent = JMap.getStr(subcommand, CALLBACK_EVENT_KEY)    
    ConsoleCommand commandScriptInstance = JMap.getForm(command, SCRIPT_INSTANCE_KEY) as ConsoleCommand
    ConsoleCommand subcommandScriptInstance = JMap.getForm(subcommand, SCRIPT_INSTANCE_KEY) as ConsoleCommand
    if commandSkseEvent
        SendCommandModEvent(commandSkseEvent, parseResult)
    endIf
    if subcommandSkseEvent
        SendCommandModEvent(subcommandSkseEvent, parseResult)
    endIf
    if commandScriptInstance
        InvokeCommandOnScriptInstance(commandScriptInstance, parseResult)
    endIf
    if subcommandScriptInstance
        InvokeCommandOnScriptInstance(subcommandScriptInstance, parseResult)
    endIf
endFunction

function SendCommandModEvent(string modEventName, int parseResult)
    SendModEvent( \
        eventName = modEventName, \
        strArg = JMap.getStr(parseResult, COMMAND_TEXT_KEY), \
        numArg = parseResult)
endFunction

function InvokeCommandOnScriptInstance(ConsoleCommand scriptInstance, int parseResult)
    scriptInstance.OnCommandResult(parseResult)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Execution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Run the provided command.
; If it is a registered command, it is invoked.
; If no command is found, the native console command is executed (via ConsoleHelper.ExecuteCommand)
function ExecuteCommand(string commandText)
    Debug("ExecuteCommand " + commandText)
    int parseResult = Parse(commandText)
    int commandMap = ParseResult_CommandMap(parseResult)
    if commandMap > 0
        InvokeCommand(parseResult)
    else
        Debug("No command found, running natively: " + commandText)
        ConsoleHelper.ExecuteCommand(commandText)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JContainer Parsing Helper Functions (return objects etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function ParseResult_CommandMap(int parseResult)
    return JMap.getObj(parseResult, COMMAND_MAP_KEY)
endFunction

int function ParseResult_SubcommandMap(int parseResult)
    string subcommand = ConsoleCommands.ParseResult_Subcommand(parseResult)
    if subcommand
        int commandSubcommands = JMap.getObj(ParseResult_CommandMap(parseResult), SUBCOMMANDS_KEY)
        return JMap.getObj(commandSubcommands, subcommand)
    else
        return 0
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Parse() Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Parse(string commandText, bool commandOnly = false)
    Debug("Parse: " + commandText)

    Debug("All Names: " + JMap.allKeysPArray(GetMap_CommandNamesToMaps()))

    int result = JMap.object()  
    int flagsArray = JArray.object()
    int optionsMap = JMap.object()  
    int argumentsArray = JArray.object()

    JMap.setStr(result, COMMAND_TEXT_KEY, commandText)
    JMap.setObj(result, FLAGS_KEY, flagsArray)
    JMap.setObj(result, OPTIONS_KEY, optionsMap)
    JMap.setObj(result, ARGUMENTS_KEY, argumentsArray)

    string[] commandTextParts = StringUtil.Split(commandText, " ")

    string command = commandTextParts[0]
    int commandMap = GetCommandMapForCommandName(command)
    if ! commandMap
        return result
    else
        Debug("Parse: found command " + command)
        JMap.setObj(result, COMMAND_MAP_KEY, commandMap)
        JMap.setStr(result, "command", command)
        if commandOnly
            return result
        endIf
    endIf
    int subcommandsMap = JMap.getObj(commandMap, SUBCOMMANDS_KEY)

    ; Build a Map of Option/Flags ==> Object ... FOR Command + Subcommand
    int flagsAndOptions = JMap.object()
    AddCommandOrSubcommandFlagsAndOptionsToMap(flagsAndOptions, commandMap)

    int index = 1
    while index < commandTextParts.Length
        string arg = commandTextParts[index]

        ; Is it a Flag or an Option?
        int flagOrOption = JMap.getObj(flagsAndOptions, arg)
        if flagOrOption
            string type = JMap.getStr(flagOrOption, FLAG_OPTION_TYPE_KEY)
            ; Flag
            if type == FLAG_TYPE
                string flagName = JMap.getStr(flagOrOption, NAME_KEY)
                JArray.addStr(flagsArray, flagName)
            else
                ; Option
                string nextArgument = commandTextParts[index + 1]
                if nextArgument
                    SetOptionMapValue(optionsMap, flagOrOption, nextArgument)
                    index += 1
                else
                    Debug("No value found for option: " + arg)
                    JArray.addStr(argumentsArray, arg)
                endIf
            endIf
        else
            ; Is it a Subcommand?
            int subcommand = JMap.getObj(subcommandsMap, arg)
            if subcommand
                Debug("Subcommand found: " + arg)
                JMap.setStr(result, SUBCOMMAND_KEY, arg)
                AddCommandOrSubcommandFlagsAndOptionsToMap(flagsAndOptions, subcommand)
            else
                ; Add to Argument List
                JArray.addStr(argumentsArray, arg)
            endIf
        endIf

        index += 1
    endWhile

    return result
endFunction

function SetOptionMapValue(int optionMap, int option, string value)
    string optionName = JMap.getStr(option, NAME_KEY)
    string optionType = JMap.getStr(option, OPTION_TYPE_KEY)
    if optionType == FLOAT_TYPE
        JMap.setFlt(optionMap, optionName, value as float)
    elseIf optionType == INT_TYPE
        JMap.setInt(optionMap, optionName, value as int)
    elseIf optionType == STRING_TYPE
        JMap.setStr(optionMap, optionName, value)
    endIf
endFunction

function AddCommandOrSubcommandFlagsAndOptionsToMap(int flagsAndOptions, int commandOrSubcommandMap)
    int flagsMap = JMap.getObj(commandOrSubcommandMap, FLAGS_KEY)
    int optionsMap = JMap.getObj(commandOrSubcommandMap, OPTIONS_KEY)

    ; Add Flags
    string[] flagNames = JMap.allKeysPArray(flagsMap)
    int index = 0
    while index < flagNames.Length
        string flagName = flagNames[index]
        int flagMap = JMap.getObj(flagsMap, flagName)
        JMap.setObj(flagsAndOptions, "--" + flagName, flagMap)
        string short = JMap.getStr(flagMap, SHORT_NAME_KEY)
        if short
            JMap.setObj(flagsAndOptions, "-" + short, flagMap)
        endIf
        index += 1
    endWhile

    ; Add Options
    string[] optionNames = JMap.allKeysPArray(optionsMap)
    index = 0
    while index < optionNames.Length
        string optionName = optionNames[index]
        int optionMap = JMap.getObj(optionsMap, optionName)
        JMap.setObj(flagsAndOptions, "--" + optionName, optionMap)
        string short = JMap.getStr(optionMap, SHORT_NAME_KEY)
        if short
            JMap.setObj(flagsAndOptions, "-" + short, optionMap)
        endIf
        index += 1
    endWhile
endFunction
