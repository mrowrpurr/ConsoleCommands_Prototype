scriptName __console_commands__ extends Quest hidden 
{Private Quest script for persisting global data for Custom Console Commands}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Logging configuration
bool   property LogToPapyrus                           auto
bool   property LogToConsole                           auto ; <--- TODO: turn this off for mod release!
bool   property LogToNotifications                     auto
string property LOG_PREFIX = "[ConsoleCommands] " autoReadonly

; Logging function for debugging and providing information to users
function Debug(string text)
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

; Top-Level Primary Map which holds command information
int property CommandsMapID auto

; Keys used in maps
string property NAME_KEY             = "name"        autoReadonly
string property COMMAND_KEY          = "command"     autoReadonly
string property COMMAND_TEXT_KEY     = "text"        autoReadonly
string property SUBCOMMAND_KEY       = "subcommand"  autoReadonly
string property SUBCOMMANDS_KEY      = "subcommands" autoReadonly
string property FLAGS_KEY            = "flags"       autoReadonly
string property OPTIONS_KEY          = "options"     autoReadonly
string property ARGUMENTS_KEY        = "arguments"   autoReadonly
string property CALLBACK_EVENT_KEY   = "callback"    autoReadonly
string property SCRIPT_INSTANCE_KEY  = "script"      autoReadonly
string property DESCRIPTION_KEY      = "description" autoReadonly
string property SHORT_NAME_KEY       = "short"       autoReadonly
string property FLAG_OPTION_TYPE_KEY = "type"        autoReadonly
string property FLAG_TYPE            = "flag"        autoReadonly
string property OPTION_TYPE          = "option"      autoReadonly
string property OPTION_TYPE_KEY      = "optionType"  autoReadonly
string property FLOAT_TYPE           = "float"       autoReadonly
string property INT_TYPE             = "int"         autoReadonly
string property STRING_TYPE          = "string"      autoReadonly

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
    if CommandsMapID == 0
        SetupCommandsDataRepository()
        ConfigureLogging()
        ListenForCommands()
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
    LogToConsole = false ; TODO ** Turn this OFF for public release **
    LogToPapyrus = true
    LogToNotifications = false
endFunction

; Setup the JContainer JMap which stores *all* information about commands.
function SetupCommandsDataRepository()
    CommandsMapID = JMap.object()
    JValue.retain(CommandsMapID)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JContainers Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Create a new JMap to represent this command and its information
int function GetNewCommandMapID(string command)
    int commandMap = JMap.object()
    JMap.setStr(commandMap, NAME_KEY, command)
    JMap.setObj(commandMap, SUBCOMMANDS_KEY, JMap.object())
    JMap.setObj(commandMap, FLAGS_KEY, JMap.object())
    JMap.setObj(commandMap, OPTIONS_KEY, JMap.object())
    JMap.setObj(CommandsMapID, command, commandMap)
    return commandMap
endFunction

; Get the JMap of an existing command (else returns 0)
int function GetExistingCommandMapID(string command)
    return JMap.getObj(CommandsMapID, command)
endFunction

; Get the JMap of an existing subcommand (else returns 0)
int function GetExistingSubcommandMapID(string command, string subcommand)
    int subcommandsMap = JMap.getObj(GetExistingCommandMapID(command), SUBCOMMANDS_KEY)
    return JMap.getObj(subcommandsMap, subcommand)
endFunction

; Get the JMap of an existing command or, if it is provided, subcommand (else returns 0)
int function GetCommandOrSubcommandMapID(string command, string subcommand = "")
    if subcommand
        return GetExistingSubcommandMapID(command, subcommand)
    else
        return GetExistingCommandMapID(command)
    endIf
endFunction

; Get the JMap of the subcommand for the provided command JMap (else returns 0)
int function GetSubcommand(int commandMap, string subcommand)
    ;;;
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start/Stop Listening for Custom Console Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Register handler with ConsoleHelper to begin listening to ConsoleCommands
function ListenForCommands()
    ConsoleHelper.RegisterForCustomCommands(CONSOLE_HELPER_EVENT_NAME)
    RegisterForModEvent(CONSOLE_HELPER_EVENT_NAME, CONSOLE_HELPER_CALLBACK_FN)
endFunction

; TODO
function StopListeningForCommands()
    ; TODO
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
    string command = ConsoleCommands.ParseResult_Command(parseResult)
    if command
        return JMap.getObj(CommandsMapID, command)
    else
        return 0
    endIf
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
    int result = JMap.object()  
    int flagsArray = JArray.object()
    int optionsMap = JMap.object()  
    int argumentsArray = JArray.object()

    JMap.setStr(result, COMMAND_KEY, "")
    JMap.setStr(result, SUBCOMMAND_KEY, "")
    JMap.setStr(result, COMMAND_TEXT_KEY, commandText)
    JMap.setObj(result, FLAGS_KEY, flagsArray)
    JMap.setObj(result, OPTIONS_KEY, optionsMap)
    JMap.setObj(result, ARGUMENTS_KEY, argumentsArray)

    string[] commandTextParts = StringUtil.Split(commandText, " ")

    string command = commandTextParts[0]
    int commandMap = GetExistingCommandMapID(command)
    if ! commandMap
        return result
    else
        Debug("Parse: found command " + command)
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
