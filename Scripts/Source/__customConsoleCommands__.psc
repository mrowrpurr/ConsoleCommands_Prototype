scriptName __customConsoleCommands__ extends Quest hidden 
{Private Quest script for persisting global data for Custom Console Commands}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Logging configuration
bool   property LogToPapyrus                           auto
bool   property LogToConsole                           auto ; <--- TODO: turn this off for mod release!
bool   property LogToNotifications                     auto
string property LOG_PREFIX = "[CustomConsoleCommands] " autoReadonly

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
    string filePath = "Data/CustomConsoleCommands/Log/Object-" + obj + ".json"
    JValue.writeToFile(obj, filePath)
    ConsoleHelper.Print(MiscUtil.ReadFromFile(filePath))
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; [INTERNAL]
; Returns an instance of __customConsoleCommands__ (used for persisting all Custom Console Commands data)
; Please do not use the interface provided by this script.
; Instead, use either the CustomConsoleCommands global interface
; or, preferably, create commands by making Quest scripts which extend ConsoleCommand.
__customConsoleCommands__ function GetInstance() global
    return Game.GetFormFromFile(0x800, "CustomConsoleCommands.esp") as __customConsoleCommands__
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
string property DESCRIPTION_KEY      = "description" autoReadonly
string property SHORT_NAME_KEY       = "short"       autoReadonly
string property FLAG_OPTION_TYPE_KEY = "type"        autoReadonly
string property FLAG_TYPE            = "flag"        autoReadonly
string property OPTION_TYPE          = "option"      autoReadonly
string property OPTION_TYPE_KEY      = "optionType"  autoReadonly
string property FLOAT_TYPE           = "float"       autoReadonly
string property INT_TYPE             = "int"         autoReadonly
string property STRING_TYPE          = "string"      autoReadonly
string property FORM_TYPE            = "form"        autoReadonly

; Console Helper integration
string CONSOLE_HELPER_EVENT_NAME  = "CustomConsoleCommand_INTERNAL"
string CONSOLE_HELPER_CALLBACK_FN = "OnCustomConsoleCommand" 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mod Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Runs the first time the mod is installed.
; See ___customConsoleCommands___.OnPlayerLoadGame() for load event handling
; after the mod has already been installed.
event OnInit()
    ConfigureLogging()
    SetupCommandsDataRepository()
    ListenForCommands()
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

; Register handler with ConsoleHelper to begin listening to CustomConsoleCommands
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
event OnCustomConsoleCommand(string skseEventName, string commandText, float _, Form sender)
    Debug("OnCustomConsoleCommand " + commandText)
    int result = Parse(commandText)
    int command = ParseResult_CommandMap(result)
    if command
        Debug("OnCustomConsoleCommand command: " + CustomConsoleCommands.ParseResult_Command(result))
        string eventName = JMap.getStr(command, CALLBACK_EVENT_KEY)
        int subcommand = ParseResult_SubcommandMap(result)
        if subcommand
            Debug("OnCustomConsoleCommand subcommand: " + CustomConsoleCommands.ParseResult_Subcommand(result))
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
            ConsoleHelper.ExecuteCommand(commandText)
        endIf
    else
        ConsoleHelper.ExecuteCommand(commandText)
    endIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JContainer Parsing Helper Functions (return objects etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function ParseResult_CommandMap(int parseResult)
    string command = CustomConsoleCommands.ParseResult_Command(parseResult)
    if command
        return JMap.getObj(CommandsMapID, command)
    endIf
endFunction

int function ParseResult_SubcommandMap(int parseResult)
    string subcommand = CustomConsoleCommands.ParseResult_Subcommand(parseResult)
    if subcommand
        int commandSubcommands = JMap.getObj(ParseResult_CommandMap(parseResult), SUBCOMMANDS_KEY)
        return JMap.getObj(commandSubcommands, subcommand)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Parse() Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Parse(string commandText)
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
    else
        ;
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

; ; This is what determines which command should be run
; string[] RegisteredCommandPrefixes

; ; This gets the full display name of the command being run
; string[] RegisteredCommandNames

; ; List of the ConsoleCommand instances which should be invoked when a command is run
; Form[] RegisteredConsoleCommands




; event OnCustomConsoleCommand(string eventName, string commandText, float _, Form sender)
;     int commandIndex = FindCommandIndex(commandText)
;     if commandIndex > -1
;         string commandName = RegisteredCommandNames[commandIndex]
;         ConsoleCommand command = RegisteredConsoleCommands[commandIndex] as ConsoleCommand
;         command.OnCommand(commandName, "", None) ; arguments and subcommand later
;     else
;         ConsoleHelper.ExecuteCommand(commandText)
;     endIf
; endEvent

; int function FindCommandIndex(string commandText)
;     int commandLength = StringUtil.GetLength(commandText)
;     int index = 0
;     while index < RegisteredCommandPrefixes.Length
;         string prefix = RegisteredCommandPrefixes[index]
;         int prefixIndex = StringUtil.Find(commandText, prefix)
;         if prefixIndex > -1
;             if StringUtil.GetLength(prefix) == commandLength || StringUtil.Find(commandText, prefix + " ") == 0
;                 return index
;             endIf
;         endIf
;         index += 1
;     endWhile
;     return -1
; endFunction

; function RegisterCommandPrefix(ConsoleCommand command, string commandName, string prefix)
;     if RegisteredCommandPrefixes
;         RegisteredCommandPrefixes = Utility.ResizeStringArray(RegisteredCommandPrefixes, RegisteredCommandPrefixes.Length + 1)
;         RegisteredCommandNames = Utility.ResizeStringArray(RegisteredCommandNames, RegisteredCommandNames.Length + 1)
;         RegisteredConsoleCommands = Utility.ResizeFormArray(RegisteredConsoleCommands, RegisteredConsoleCommands.Length + 1)
;     else
;         ; Initialize arrays
;         RegisteredCommandPrefixes = new string[1]
;         RegisteredCommandNames = new string[1]
;         RegisteredConsoleCommands = new Form[1]
;     endIf

;     RegisteredCommandPrefixes[RegisteredCommandPrefixes.Length - 1] = prefix
;     RegisteredCommandNames[RegisteredCommandNames.Length - 1] = commandName
;     RegisteredConsoleCommands[RegisteredConsoleCommands.Length - 1] = command

;     ; Start listening if there were previously no commands!
; endFunction
