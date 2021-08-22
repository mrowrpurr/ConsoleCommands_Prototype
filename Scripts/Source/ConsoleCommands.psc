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
;; Execute Command Helper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Executes a console command.
; Is the target command is a ConsoleCommand, it will be run.
; Otherwise, a native Skyrim console command will be executed.
function ExecuteCommand(string command) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    cc.ExecuteCommand(command)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start or Stop Listening for Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function StartListeningForCommands() global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    cc.ListenForCommands()
endFunction

function StopListeningForCommands() global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    cc.StopListeningForCommands()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Register Commands + Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Register a command
function RegisterCommand(string command, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "", bool enabled = true) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    if cc.CommandExists(command)
        cc.Log("Command already registered: " + command)
    else
        int commandMap = cc.CreateAndRegisterNewCommandMapForCommandName(command) 
        JMap.setInt(commandMap, cc.ENABLED_KEY, enabled as int)
        JMap.setStr(commandMap, cc.DESCRIPTION_KEY, description)
        if callbackEvent
            JMap.setStr(commandMap, cc.CALLBACK_EVENT_KEY, callbackEvent)
        endIf
        if scriptInstance
            JMap.setForm(commandMap, cc.SCRIPT_INSTANCE_KEY, scriptInstance)
        endIf
        if enabled
            cc.EnableCommandOrSubcommand(commandMap)
        endIf
    endIf
endFunction

; Register a subcommand for an existing command
function RegisterSubcommand(string command, string subcommand, string description = "", ConsoleCommand scriptInstance = None, string callbackEvent = "", bool enabled = true) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int commandMap = cc.GetCommandMapForCommandName(command)
    if commandMap
        int subcommandsMap = JMap.getObj(commandMap, cc.SUBCOMMANDS_KEY)
        int existingSubcommandMap = JMap.getObj(subcommandsMap, subcommand)
        if existingSubcommandMap
            cc.Log("Subcommand already registered: " + command + " " + subcommand)
        else
            int subcommandMap = cc.CreateAndRegisterNewSubcommand(commandMap, subcommand)
            JMap.setInt(subcommandMap, cc.ENABLED_KEY, enabled as int)
            JMap.setStr(subcommandMap, cc.DESCRIPTION_KEY, description)
            if callbackEvent
                JMap.setStr(subcommandMap, cc.CALLBACK_EVENT_KEY, callbackEvent)
            endIf
            if scriptInstance
                JMap.setForm(subcommandMap, cc.SCRIPT_INSTANCE_KEY, scriptInstance)
            endIf
            if enabled
                cc.EnableCommandOrSubcommand(subcommandMap)
            endIf
        endIf
    else
        cc.Log("Cannot register subcommand '" + subcommand + "' for non-existent command: " + command)
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

function AddFlag(string name, string command = "", string subcommand = "", string short = "", string description = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int commandOrSubcommandMap = cc.GetCommandOrSubcommandMapForName(command, subcommand)
    Command_AddFlag(commandOrSubcommandMap, name, short, description)
endFunction

function Command_AddFlag(int commandOrSubcommand, string name, string short = "", string description = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int flagsMap = JMap.getObj(commandOrSubcommand, "flags")

    int flagMap = JMap.object()
    JMap.setStr(flagMap, cc.FLAG_OPTION_TYPE_KEY, cc.FLAG_TYPE)
    JMap.setStr(flagMap, cc.NAME_KEY, name)
    JMap.setStr(flagMap, cc.SHORT_NAME_KEY, short)
    JMap.setObj(flagsMap, name, flagMap)
endFunction

bool function HasFlag(string flag, string commandText) global
    return ParseResult_HasFlag(Parse(commandText), flag)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function AddOption(string type, string name, string command = "", string subcommand = "", string short = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int commandOrSubcommandMap = cc.GetCommandOrSubcommandMapForName(command, subcommand)
    int optionsMap = JMap.getObj(commandOrSubcommandMap, cc.OPTIONS_KEY)
    int optionMap = JMap.object()
    JMap.setStr(optionMap, cc.FLAG_OPTION_TYPE_KEY, cc.OPTION_TYPE)
    JMap.setStr(optionMap, cc.NAME_KEY, name)
    JMap.setStr(optionMap, cc.SHORT_NAME_KEY, short)
    JMap.setStr(optionMap, cc.OPTION_TYPE_KEY, type)
    JMap.setObj(optionsMap, name, optionMap)
endFunction

function AddFloatOption(string name, string command = "", string subcommand = "", string short = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    AddOption(cc.FLOAT_TYPE, name, command, subcommand, short)
endFunction

function AddIntOption(string name, string command = "", string subcommand = "", string short = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    AddOption(cc.INT_TYPE, name, command, subcommand, short)
endFunction

function AddStringOption(string name, string command = "", string subcommand = "", string short = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    AddOption(cc.STRING_TYPE, name, command, subcommand, short)
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
;; Storage Setters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Command_StoreFloat(int commandId, string storageKey, float value) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    cc.StoreFloat(commandId, storageKey, value)
endFunction

function Command_StoreForm(int commandId, string storageKey, Form value) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    cc.StoreForm(commandId, storageKey, value)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Storage Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

float function GetFloat(string command, string storageKey, float default = 0.0) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int commandMap = cc.GetCommandMapForCommandName(command)
    if commandMap
        return Command_GetFloat(commandMap, storageKey, default)
    else
        cc.Debug("GetFloat() command not found: " + command)
        return default
    endIf
endFunction

float function Command_GetFloat(int commandId, string storageKey, float default = 0.0) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    return cc.GetFloat(commandId, storageKey, default)
endFunction

Form function GetForm(string command, string storageKey, Form default = None) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int commandMap = cc.GetCommandMapForCommandName(command)
    if commandMap
        return Command_GetForm(commandMap, storageKey, default)
    else
        cc.Debug("GetForm() command not found: " + command)
        return default
    endIf
endFunction

Form function Command_GetForm(int commandId, string storageKey, Form default = None) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    return cc.GetForm(commandId, storageKey, default)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Parsing Helper Functions (return strings etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Parse(string commandText) global
    return ConsoleCommandsPrivateAPI.GetInstance().Parse(commandText)
endFunction

string function ParseResult_Command(int parseResult) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    return JMap.getStr(parseResult, cc.COMMAND_KEY)
endFunction

string function ParseResult_Subcommand(int parseResult) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    return JMap.getStr(parseResult, cc.SUBCOMMAND_KEY)
endFunction

string[] function ParseResult_Arguments(int parseResult) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int argsArray = JMap.getObj(parseResult, cc.ARGUMENTS_KEY)
    return JArray.asStringArray(argsArray)
endFunction

string function ParseResult_CommandText(int parseResult) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    return JMap.getStr(parseResult, cc.COMMAND_TEXT_KEY)
endFunction

bool function ParseResult_HasFlag(int parseResult, string flag) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int flagsArray = JMap.getObj(parseResult, cc.FLAGS_KEY)
    return JArray.findStr(flagsArray, flag) > -1
endFunction

float function ParseResult_GetFloatOption(int parseResult, string option, float default = 0.0) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int optionsMap = JMap.getObj(parseResult, cc.OPTIONS_KEY)
    return JMap.getFlt(optionsMap, option, default)
endFunction

int function ParseResult_GetIntOption(int parseResult, string option, int default = 0) global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int optionsMap = JMap.getObj(parseResult, cc.OPTIONS_KEY)
    return JMap.getInt(optionsMap, option, default)
endFunction

string function ParseResult_GetStringOption(int parseResult, string option, string default = "") global
    ConsoleCommandsPrivateAPI cc = ConsoleCommandsPrivateAPI.GetInstance()
    int optionsMap = JMap.getObj(parseResult, cc.OPTIONS_KEY)
    return JMap.getStr(optionsMap, option, default)
endFunction
