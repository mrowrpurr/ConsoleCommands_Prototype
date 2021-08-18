scriptName CustomConsoleCommands hidden
{Global interface for Custom Console Commands

It is recommended to extend ConsoleCommand to implement individual commands,
but everything ConsoleCommand provides can also be impemented via CustomConsoleCommands.}

; Returns the current version of Custom Console Commands
float function GetCurrentVersion() global
    return 2.0
endFunction

;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;
;;; TODO
;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;; ;;;;;

bool function IsListeningForCommands() global
endFunction

function ListenForCommands() global
endFunction

function RegisterCommand(string command, string description = "", string defaultSubcommand = "", \
    float version = 1.0, bool helpSubcommand = true, bool versionSubcommand = true, \
    ConsoleCommand commandInstance = None, string callbackEvent = "") global

    ; TODO deal with if it already exists

    int commandMap = __customConsoleCommands__.GetNewCommandMapID(command) 
    JMap.setStr(commandMap, "name", command)
    JMap.setStr(commandMap, "callbackEvent", callbackEvent)

    ; TODO  ALWAYS add the Options and Flags map etc etc etc etc for each lookup
endFunction

function RegisterSubcommand(string command, string subcommand, string description = "", string defaultSubcommand = "", \
    ConsoleCommand commandInstance = None, string callbackEvent = "") global

    ; TODO deal with if it already exists
    int commandMap = __customConsoleCommands__.GetExistingCommandMapID(command)
    int subcommandsMap = JMap.getObj(commandMap, "subcommands")
    if ! subcommandsMap
        subcommandsMap = JMap.object()
        JMap.setObj(commandMap, "subcommands", subcommandsMap)
    endIf

    int subcommandMap = JMap.object()
    JMap.setStr(subcommandMap, "name", subcommand)
    JMap.setStr(subcommandMap, "callbackEvent", callbackEvent)
    JMap.setObj(subcommandsMap, subcommand, subcommandMap)

    ; TODO  ALWAYS add the Options and Flags map etc etc etc etc for each lookup
endFunction

; TODO Don't let conflicting flags be added, e.g. same with Command and a Subcommand (diff subcommands can have ones with the same name tho)
function AddFlag(string name, string command = "", string subcommand = "", string short = "") global
    int commandOrSubcommandMap = __customConsoleCommands__.GetCommandOrSubcommandMapID(command, subcommand)
    ; TODO handle if flag already there!

    int flagsMap = JMap.getObj(commandOrSubcommandMap, "flags")
    if ! flagsMap
        flagsMap = JMap.object()
        JMap.setObj(commandOrSubcommandMap, "flags", flagsMap)
    endIf

    int flagMap = JMap.object()
    JMap.setInt(flagMap, "isFlag", 1)
    JMap.setInt(flagMap, "isOption", 0)
    JMap.setStr(flagMap, "name", name)
    JMap.setStr(flagMap, "short", short)
    JMap.setObj(flagsMap, name, flagMap)

    ; Map of flag arguments to the flag IDs
    int commandMap = __customConsoleCommands__.GetExistingCommandMapID(command)
    int flagAndOptionsArgumentsMap = JMap.getObj(commandOrSubcommandMap, "flagsAndOptions")
    if ! flagAndOptionsArgumentsMap
        flagAndOptionsArgumentsMap = JMap.object()
        JMap.setObj(commandMap, "flagsAndOptions", flagAndOptionsArgumentsMap)
    endIf
    JMap.setObj(flagAndOptionsArgumentsMap, "--" + name, flagMap)
    if short
        JMap.setObj(flagAndOptionsArgumentsMap, "-" + short, flagMap)
    endIf
endFunction

bool function HasFlag(string flag, string commandText) global
    return ParseResult_HasFlag(Parse(commandText), flag)
endFunction

string function GetStringOption(string flag, string commandText) global
    ; return ParseResult_HasFlag(Parse(commandText), flag)
endFunction

int function GetIntOption(string flag, string commandText) global
    ; return ParseResult_HasFlag(Parse(commandText), flag)
endFunction

bool function ParseResult_HasFlag(int parseResult, string flag) global
    int flagsArray = JMap.getObj(parseResult, "flags")
    return JArray.findStr(flagsArray, flag) > -1
endFunction

int function Parse(string commandText) global
    __customConsoleCommands__.Debug("Parse: " + commandText)
    int result = JMap.object()  
    int flagsArray = JArray.object()
    int optionsMap = JMap.object()  
    int argumentsArray = JArray.object()

    JMap.setStr(result, "command", "")
    JMap.setStr(result, "subcommand", "")
    JMap.setStr(result, "text", commandText)
    JMap.setObj(result, "flags", flagsArray)
    JMap.setObj(result, "options", optionsMap)
    JMap.setObj(result, "arguments", argumentsArray)

    string[] commandTextParts = StringUtil.Split(commandText, " ")

    string command = commandTextParts[0]
    int commandMap = __customConsoleCommands__.GetExistingCommandMapID(command)
    if ! commandMap
        return result
    else
        JMap.setStr(result, "command", command)
    endIf

    string subcommand
    int flagAndOptionArgumentsMap = JMap.getObj(commandMap, "flagsAndOptions")
    int subcommandsMap = JMap.getObj(commandMap, "subcommands")

    ; TODO loop over the command's flags/options looking for them OR else a subcommand
    int index = 1
    while index < commandTextParts.Length

        string arg = commandTextParts[index]
        __customConsoleCommands__.Debug("Parse Arg: " + arg)
        int flagOrOptionId = JMap.getObj(flagAndOptionArgumentsMap, arg)
        if flagOrOptionId
            if JMap.getInt(flagOrOptionId, "isFlag") == 1
                JArray.addStr(flagsArray, JMap.getStr(flagOrOptionId, "name"))
            else
                ; TODO options
            endIf
        else
            int subcommandMap = JMap.getObj(subcommandsMap, arg)
            if subcommandMap
                JMap.setStr(result, "subcommand", arg)
            else
                JArray.addStr(argumentsArray, arg)
            endIf
        endIf

        index += 1
    endWhile

    return result
endFunction
