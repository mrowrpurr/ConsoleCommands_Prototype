scriptName ConsoleCommandParser hidden
{Parse console command text and get the result.

Integrations with commands, subcommands, options, and flags for ConsoleCommands commands.

When you get a result, it is provided as an integer identifier which points to
a data structure containing the result information.

To get the parsed command, subcommand, options, and flags, use the provided
functions for reading data from parse results
e.g. string commandName = ConsoleCommandParser.GetCommandName([parse result int identifier]) 

Note: this further integrates into the data storage used in ConsoleCommands and allows
you to get the numeric identifiers of commands, subcommands, options, and flags
e.g. int command = ConsoleCommandParser.IdForCommand([parse result int identifier])
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Parser
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Log(string text) global
    MiscUtil.WriteToFile("Data\\TESTING.txt", text + "\n")
endFunction

; ...
int function Parse(string commandText) global
    ; Setup result
    int result = JMap.object()
    JMap.setStr(result, "TEXT", commandText) ; Raw provided command text
    int argumentList = JArray.object()
    JMap.setObj(result, "LIST", argumentList) ; Raw provided command as list of raw arguments
    int arguments = JArray.object()
    JMap.setObj(result, "ARGUMENTS", arguments) ; Argument list for this specific command
    int flags = JMap.object()
    JMap.setObj(result, "FLAGS", flags) ; Map of flag names to flag integer identifiers

    ; Turn single string 'commandText' into an array of individual 'parts'.
    ;
    ; This is expensive for longer commands
    ;
    ; XXX TODO ~ Try moving this over to a Lua function for performance
    ;            because we *really* shouldn't use Papyrus for this type
    ;            of parsing (where we support double quotes in commands "")
    ;            *However* Papyrus is more accessible to mod authors
    ;            and commands are usually not run at a high rate of frequency.
    string doubleQuote = "\"" ; "\"" <--- hack to make my text editor's Papyrus parser not freak out
    string space = " "
    string slash = "\\"
    string currentArgument = ""
    string lastCharacter = ""
    int characterIndex = 0
    int commandTextLength = StringUtil.GetLength(commandText)
    bool insideStringDefinition = false
    while characterIndex < commandTextLength
        string character = StringUtil.Substring(commandText, characterIndex, 1)
        if character == doubleQuote && lastCharacter != slash
            if insideStringDefinition ; Close the string
                JArray.addStr(argumentList, currentArgument)
                currentArgument = ""
                insideStringDefinition = false
            else ; Open a new string
                if currentArgument
                    JArray.addStr(argumentList, currentArgument)
                    currentArgument = ""
                endIf
                insideStringDefinition = true
            endIf
        elseIf character == space && ! insideStringDefinition ; Save this argument and start a new one
            if currentArgument
                JArray.addStr(argumentList, currentArgument)
            endIf
            currentArgument = ""
        else ; Add the character to the current argument
            currentArgument += character
        endIf

        lastCharacter = character
        characterIndex += 1
    endWhile
    if currentArgument
        JArray.addStr(argumentList, currentArgument)
    endIf
    if JArray.count(argumentList) == 0
        return result
    endIf

    ; Get the API for working with commands, subcommands, flags, and options
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()

    ; Lookup command
    string commandName = JArray.getStr(argumentList, 0)
    int command = api.GetCommand(commandName)
    if command
        JArray.eraseIndex(argumentList, 0)
        JMap.setObj(result, "COMMAND_ID", command)
        JMap.setStr(result, "COMMAND_NAME", JMap.getStr(command, "name"))
    else
        JArray.addFromArray(arguments, argumentList)
        return result
    endIf

    ; This represents the *current* command or subcommand being parsed
    int parentCommand = command
    int subcommand
    string subcommandName

    ; Arguments to loop thru!
    string[] argumentArray = JArray.asStringArray(argumentList)
    int argumentIndex = 0
    while argumentIndex < argumentArray.Length
        string thisArgument = argumentArray[argumentIndex]
        MiscUtil.PrintConsole("Looking at argument: " + thisArgument + " - " + commandText)
        ;

        ; Check this argument to see if it is any of the following:
        ; - subcommand name
        ; - flag associated with the current parent command
        ; - option associated with the current parent command
        subcommand = api.GetSubcommand(parentCommand, thisArgument) ; TODO support aliases :)
        if subcommand
            MiscUtil.PrintConsole("This argument is a subcommand: " + thisArgument + " - " + commandText)
            parentCommand = subcommand
        else
            int flagAndOptionsByText = JMap.getObj(parentCommand, "flagAndOptionsByText")
            int flag = JMap.getObj(flagAndOptionsByText, thisArgument)
            if flag
                JMap.setObj(flags, JMap.getStr(flag, "name"), flag)
            else
                MiscUtil.PrintConsole("This is a regular ol' argument: " + thisArgument + " - " + commandText)
                JArray.addStr(arguments, thisArgument)
            endIf
        endIf

        ; TODO Option

        ;
        argumentIndex += 1
    endWhile

    if parentCommand != command
        JMap.setObj(result, "SUBCOMMAND_ID", parentCommand)
        JMap.setStr(result, "SUBCOMMAND_NAME", JMap.getStr(parentCommand, "name"))
    endIf

    ; Return the identifier for the parsed results
    return result
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Predicate methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool function IsEmpty(int result) global
    return JMap.getStr(result, "TEXT") == ""
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions for getting data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function GetText(int result) global
    return JMap.getStr(result, "TEXT")
endFunction

string[] function GetArguments(int result) global
    return JArray.asStringArray(JMap.getObj(result, "ARGUMENTS"))
endFunction

string function GetArgument(int result, int index) global
    return JArray.getStr(JMap.getObj(result, "ARGUMENTS"), index)
endFunction

string function GetCommand(int result) global
    return JMap.getStr(result, "COMMAND_NAME")
endFunction

bool function HasFlag(int result, string flag) global
    int flags = JMap.getObj(result, "FLAGS")
    return JMap.hasKey(flags, flag)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions for getting IDs
;;
;; These are provided for other parts of
;; ConsoleCommands but are not used here
;; in the parser to provide improved
;; performance.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function IdForCommand(int result) global
    return JMap.getObj(result, "COMMAND_ID")
endFunction

int function IdForSubcommand(int result) global
    return JMap.getObj(result, "SUBCOMMAND_ID")
endFunction

int function IdForCommandOrSubcommand(int result) global
    int subcommandId = IdForSubcommand(result)
    if subcommandId
        return subcommandId
    else
        return IdForCommand(result)
    endIf
endFunction
