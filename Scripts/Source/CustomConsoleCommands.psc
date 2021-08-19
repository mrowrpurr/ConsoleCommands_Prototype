scriptName CustomConsoleCommands hidden
{Global interface for Custom Console Commands (for advanced usage)

It is recommended to extend ConsoleCommand to implement individual commands,
but everything ConsoleCommand provides can also be impemented via CustomConsoleCommands.}

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
;; Register Commands + Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function RegisterCommand(string command, string description = "", string defaultSubcommand = "", float version = 1.0, bool helpSubcommand = true, bool versionSubcommand = true, ConsoleCommand commandInstance = None, string callbackEvent = "") global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int commandMap = ccc.GetNewCommandMapID(command) 
    JMap.setStr(commandMap, ccc.CALLBACK_EVENT_KEY, callbackEvent)
endFunction

function RegisterSubcommand(string command, string subcommand, string description = "", string defaultSubcommand = "", ConsoleCommand commandInstance = None, string callbackEvent = "") global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int commandMap = ccc.GetExistingCommandMapID(command)
    int subcommandsMap = JMap.getObj(commandMap, ccc.SUBCOMMANDS_KEY)
    int subcommandMap = JMap.object()
    JMap.setStr(subcommandMap, ccc.NAME_KEY, subcommand)
    JMap.setStr(subcommandMap, ccc.CALLBACK_EVENT_KEY, callbackEvent)
    JMap.setObj(subcommandMap, ccc.FLAGS_KEY, JMap.object())
    JMap.setObj(subcommandMap, ccc.OPTIONS_KEY, JMap.object())
    JMap.setObj(subcommandsMap, subcommand, subcommandMap)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO Don't let conflicting flags be added, e.g. same with Command and a Subcommand (diff subcommands can have ones with the same name tho)
function AddFlag(string name, string command = "", string subcommand = "", string short = "") global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int commandOrSubcommandMap = ccc.GetCommandOrSubcommandMapID(command, subcommand)
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

function AddFloatOption(string name, string command = "", string subcommand = "", string short = "", float default = 0.0) global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int commandOrSubcommandMap = ccc.GetCommandOrSubcommandMapID(command, subcommand)
    int optionsMap = JMap.getObj(commandOrSubcommandMap, ccc.OPTIONS_KEY)
    int optionMap = JMap.object()
    JMap.setStr(optionMap, ccc.FLAG_OPTION_TYPE_KEY, ccc.OPTION_TYPE)
    JMap.setStr(optionMap, ccc.NAME_KEY, name)
    JMap.setStr(optionMap, ccc.SHORT_NAME_KEY, short)
    JMap.setStr(optionMap, ccc.OPTION_TYPE_KEY, ccc.FLOAT_TYPE)
    JMap.setObj(optionsMap, name, optionMap)
endFunction

float function GetFloatOption(string option, string commandText, float default = 0.0) global
    return ParseResult_GetFloatOption(Parse(commandText), option, default)
endFunction

; string function GetStringOption(string flag, string commandText) global
;     ; return ParseResult_HasFlag(Parse(commandText), flag)
; endFunction

; int function GetIntOption(string flag, string commandText) global
;     ; return ParseResult_HasFlag(Parse(commandText), flag)
; endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Parsing Helper Functions (return strings etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function ParseResult_Command(int parseResult) global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    return JMap.getStr(parseResult, ccc.COMMAND_KEY)
endFunction

string function ParseResult_Subcommand(int parseResult) global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    return JMap.getStr(parseResult, ccc.SUBCOMMAND_KEY)
endFunction

bool function ParseResult_HasFlag(int parseResult, string flag) global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int flagsArray = JMap.getObj(parseResult, ccc.FLAGS_KEY)
    return JArray.findStr(flagsArray, flag) > -1
endFunction

float function ParseResult_GetFloatOption(int parseResult, string option, float default = 0.0) global
    __customConsoleCommands__ ccc = __customConsoleCommands__.GetInstance()
    int optionsMap = JMap.getObj(parseResult, ccc.OPTIONS_KEY)
    return JMap.getFlt(optionsMap, option, default)
endFunction

int function Parse(string commandText) global
    return __customConsoleCommands__.GetInstance().Parse(commandText)
endFunction













;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;
;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;
;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;
;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;

;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;
;;; TODO
;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;

bool function IsListeningForCommands() global
endFunction

function ListenForCommands() global
endFunction