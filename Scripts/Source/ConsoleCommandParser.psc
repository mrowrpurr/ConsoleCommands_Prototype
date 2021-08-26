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
;; Anatomy of a parse result object:
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Parser
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Log(string text) global
    MiscUtil.WriteToFile("Data\\TESTING.txt", text + "\n")
endFunction

; ...
int function Parse(string commandText) global
    Log("Parse(\"" + commandText + "\")")
    ; Setup result
    int result = JMap.object()
    JMap.setStr(result, "TEXT", commandText)
    int arguments = JArray.object()
    JMap.setObj(result, "ARGUMENTS", arguments)

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
                JArray.addStr(arguments, currentArgument)
                currentArgument = ""
                insideStringDefinition = false
            else ; Open a new string
                if currentArgument
                    JArray.addStr(arguments, currentArgument)
                    currentArgument = ""
                endIf
                insideStringDefinition = true
            endIf
        elseIf character == space && ! insideStringDefinition ; Save this argument and start a new one
            if currentArgument
                JArray.addStr(arguments, currentArgument)
            endIf
            currentArgument = ""
        else ; Add the character to the current argument
            currentArgument += character
        endIf

        lastCharacter = character
        characterIndex += 1
    endWhile
    if currentArgument
        JArray.addStr(arguments, currentArgument)
    endIf

    ; Return the identifier for the parsed results
    return result
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helpers for getting keys
;;
;; These are provided for other parts of
;; ConsoleCommands but are not used here
;; in the parser to provide improved
;; performance.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function KeyForText() global
    return "TEXT"
endFunction

string function KeyForArguments() global
    return "ARGUMENTS"
endFunction

string function KeyForCommand() global
    return "COMMAND"
endFunction

string function KeyForCommandName() global
    return "COMMAND_NAME"
endFunction

string function KeyForSubcommand() global
    return "SUBCOMMAND"
endFunction

string function KeyForSubcommandName() global
    return "SUBCOMMAND_NAME"
endFunction

string function KeyForFlags() global
    return "FLAGS"
endFunction

string function KeyForFlagNames() global
    return "FLAG_NAMES"
endFunction

string function KeyForOptions() global
    return "OPTIONS"
endFunction

string function KeyForOptionNames() global
    return "OPTION_NAMES"
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions for getting IDs
;;
;; These are provided for other parts of
;; ConsoleCommands but are not used here
;; in the parser to provide improved
;; performance.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options to Persist / Unpersist result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function SaveResult(int result) global
    JValue.retain(result)
endFunction

function UnsaveResult(int result) global
    JValue.release(result)
endFunction