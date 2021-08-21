scriptName ConsoleCommands hidden
{Global interface for Custom Console Commands (for advanced usage)

It is recommended to extend ConsoleCommand to implement individual commands,
but everything ConsoleCommand provides can also be impemented via ConsoleCommands.}

; REMINDER - CUSTOM Subcommands have have their own FLAGS!!!
; WHEN ADDING A **GLOBAL** Option or Flag, add it to the lists of all Subcommand Options/Flags? Maybe? Hmm.....

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get Custom Console Commands Current Version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Returns the current version of Custom Console Commands
float function GetCurrentVersion() global
    return 2.0
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start or Stop Listening for Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartListeningForCommands() global
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.ListenForCommands()
endFunction

function StopListeningForCommands() global
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.StopListeningForCommands()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Register Commands + Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Register a command
function RegisterCommand(string command, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "", bool enabled = true) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    if ccc.CommandExists(command)
        ccc.Log("Command already registered: " + command)
    else
        int commandMap = ccc.CreateAndRegisterNewCommandMapForCommandName(command) 
        JMap.setInt(commandMap, ccc.ENABLED_KEY, enabled as int)
        JMap.setStr(commandMap, ccc.DESCRIPTION_KEY, description)
        if callbackEvent
            JMap.setStr(commandMap, ccc.CALLBACK_EVENT_KEY, callbackEvent)
        endIf
        if scriptInstance
            JMap.setForm(commandMap, ccc.SCRIPT_INSTANCE_KEY, scriptInstance)
        endIf
        if enabled
            ccc.EnableCommandOrSubcommand(commandMap)
        endIf
    endIf
endFunction

; Register a subcommand for an existing command
function RegisterSubcommand(string command, string subcommand, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "", bool enabled = true) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int commandMap = ccc.GetCommandMapForCommandName(command)
    if commandMap
        int subcommandsMap = JMap.getObj(commandMap, ccc.SUBCOMMANDS_KEY)
        int existingSubcommandMap = JMap.getObj(subcommandsMap, subcommand)
        if existingSubcommandMap
            ccc.Log("Subcommand already registered: " + command + " " + subcommand)
        else
            int subcommandMap = ccc.CreateAndRegisterNewSubcommand(commandMap, subcommand)
            JMap.setInt(subcommandMap, ccc.ENABLED_KEY, enabled as int)
            JMap.setStr(subcommandMap, ccc.DESCRIPTION_KEY, description)
            if callbackEvent
                JMap.setStr(subcommandMap, ccc.CALLBACK_EVENT_KEY, callbackEvent)
            endIf
            if scriptInstance
                JMap.setForm(subcommandMap, ccc.SCRIPT_INSTANCE_KEY, scriptInstance)
            endIf
            if enabled
                ccc.EnableCommandOrSubcommand(subcommandMap)
            endIf
        endIf
    else
        ccc.Log("Cannot register subcommand '" + subcommand + "' for non-existent command: " + command)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Update Commands + Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; function UpdateCommand(string command, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "")
; function UpdateSubcommand(string command, string subcommand, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Arguments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string[] function GetArguments(string commandText) global
    return ParseResult_Arguments(Parse(commandText))
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function AddFlag(string name, string command = "", string subcommand = "", string short = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int commandOrSubcommandMap = ccc.GetCommandOrSubcommandMapForName(command, subcommand)
    int flagsMap = JMap.getObj(commandOrSubcommandMap, "flags")

    int flagMap = JMap.object()
    JMap.setStr(flagMap, ccc.FLAG_OPTION_TYPE_KEY, ccc.FLAG_TYPE)
    JMap.setStr(flagMap, ccc.NAME_KEY, name)
    JMap.setStr(flagMap, ccc.SHORT_NAME_KEY, short)
    JMap.setObj(flagsMap, name, flagMap)
endFunction

bool function HasFlag(string flag, string commandText) global
    return ParseResult_HasFlag(Parse(commandText), flag)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function AddOption(string type, string name, string command = "", string subcommand = "", string short = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int commandOrSubcommandMap = ccc.GetCommandOrSubcommandMapForName(command, subcommand)
    int optionsMap = JMap.getObj(commandOrSubcommandMap, ccc.OPTIONS_KEY)
    int optionMap = JMap.object()
    JMap.setStr(optionMap, ccc.FLAG_OPTION_TYPE_KEY, ccc.OPTION_TYPE)
    JMap.setStr(optionMap, ccc.NAME_KEY, name)
    JMap.setStr(optionMap, ccc.SHORT_NAME_KEY, short)
    JMap.setStr(optionMap, ccc.OPTION_TYPE_KEY, type)
    JMap.setObj(optionsMap, name, optionMap)
endFunction

function AddFloatOption(string name, string command = "", string subcommand = "", string short = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    AddOption(ccc.FLOAT_TYPE, name, command, subcommand, short)
endFunction

function AddIntOption(string name, string command = "", string subcommand = "", string short = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    AddOption(ccc.INT_TYPE, name, command, subcommand, short)
endFunction

function AddStringOption(string name, string command = "", string subcommand = "", string short = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    AddOption(ccc.STRING_TYPE, name, command, subcommand, short)
endFunction

float function GetFloatOption(string option, string commandText, float default = 0.0) global
    return ParseResult_GetFloatOption(Parse(commandText), option, default)
endFunction

int function GetIntOption(string option, string commandText, int default = 0) global
    return ParseResult_GetIntOption(Parse(commandText), option, default)
endFunction

string function GetStringOption(string option, string commandText, string default = "") global
    return ParseResult_GetStringOption(Parse(commandText), option, default)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Parsing Helper Functions (return strings etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Parse(string commandText) global
    return __console_commands__.GetInstance().Parse(commandText)
endFunction

string function ParseResult_Command(int parseResult) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    return JMap.getStr(parseResult, ccc.COMMAND_KEY)
endFunction

string function ParseResult_Subcommand(int parseResult) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    return JMap.getStr(parseResult, ccc.SUBCOMMAND_KEY)
endFunction

string[] function ParseResult_Arguments(int parseResult) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int argsArray = JMap.getObj(parseResult, ccc.ARGUMENTS_KEY)
    return JArray.asStringArray(argsArray)
endFunction

string function ParseResult_CommandText(int parseResult) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    return JMap.getStr(parseResult, ccc.COMMAND_TEXT_KEY)
endFunction

bool function ParseResult_HasFlag(int parseResult, string flag) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int flagsArray = JMap.getObj(parseResult, ccc.FLAGS_KEY)
    return JArray.findStr(flagsArray, flag) > -1
endFunction

float function ParseResult_GetFloatOption(int parseResult, string option, float default = 0.0) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int optionsMap = JMap.getObj(parseResult, ccc.OPTIONS_KEY)
    return JMap.getFlt(optionsMap, option, default)
endFunction

int function ParseResult_GetIntOption(int parseResult, string option, int default = 0) global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int optionsMap = JMap.getObj(parseResult, ccc.OPTIONS_KEY)
    return JMap.getInt(optionsMap, option, default)
endFunction

string function ParseResult_GetStringOption(int parseResult, string option, string default = "") global
    __console_commands__ ccc = __console_commands__.GetInstance()
    int optionsMap = JMap.getObj(parseResult, ccc.OPTIONS_KEY)
    return JMap.getStr(optionsMap, option, default)
endFunction
