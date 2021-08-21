scriptName ConsoleCommand extends Quest hidden
{Extend this to create your own console command.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private Fields
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int      _mostRecentParseResult
string   _mostRecentCommandName
string   _mostRecentSubcommandName
string[] _mostRecentArguments
string   _mostRecentCommandText

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public Properties
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This provides the name of the command run
; when used within your OnCommand() event
string property Command
    string function get()
        return _mostRecentCommandName
    endfunction
endProperty

; This provides the name of the subcommand run
; when used within your OnCommand() event
string property Subcommand
    string function get()
        return _mostRecentSubcommandName
    endfunction
endProperty

; This provides the list of arguments provided
; when used within your OnCommand() event
string[] property Arguments
    string[] function get()
        return _mostRecentArguments
    endfunction
endProperty

; This provides the full text of the command run
; when used within your OnCommand() event
string property FullCommandText
    string function get()
        return _mostRecentCommandText
    endfunction
endProperty

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Invocation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Use OnCommand() to implement your console command!
;
; You can use these properties to get information about the command being executed:
; - Command, Subcommand, Arguments, and get the full command text via FullCommandText
;
; Notes:
; - You can get flag values via HasFlag("[name]")
; - You can get option values via GetOptionString("[name]") etc
event OnCommand()
endEvent

; Initial event fired when this command is run.
;
; This is responsible for populating these properties:
; - Command, Subcommand, Arguments, FullCommandText
;
; This is also responsible for calling OnCommand()
;
; Override this is you'd like to get the internal "parseResult"
; but don't forget to call parent.OnCommandResult(parseResult)
; or OnCommand() will never fire.
;
; Finally, this is responsible for *persisting* the "parseResult"
; until OnCommand has completed running.
event OnCommandResult(int parseResult)
    __console_commands__ ccc = __console_commands__.GetInstance()
    JValue.retain(parseResult)

    _mostRecentParseResult = parseResult
    _mostRecentCommandName = ConsoleCommands.ParseResult_Command(parseResult)
    _mostRecentSubcommandName = ConsoleCommands.ParseResult_Subcommand(parseResult)
    _mostRecentArguments = ConsoleCommands.ParseResult_Arguments(parseResult)
    _mostRecentCommandText = ConsoleCommands.ParseResult_CommandText(parseResult)

    OnCommand()

    JValue.release(parseResult)
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; function Info()
; endFunction

event OnInit()
    ; string fullScriptName = self
    ; int space = StringUtil.Find(fullScriptName, " ")
    ; string nameOfScript = StringUtil.Substring(fullScriptName, 1, space - 1)
    ; int commandWord = StringUtil.Find(nameOfScript, "Command")
    ; if commandWord > -1 && commandWord != 0
    ;     string commandName = StringUtil.Substring(nameOfScript, 0, commandWord - 1)
    ;     ConsoleCommands.RegisterCommand(commandName, callbackEvent = "TempCallCommand")
    ;     RegisterForModEvent("TempCallCommand", "OnTempCommandHandler")
    ; endIf
endEvent

; event OnTempCommandHandler(string eventName, string command, float parseResult, Form sender)
;     _mostRecentParseResult = parseResult
; endEvent

; function Version(float version)
; endFunction

; function Author(string author)
; endFunction

; function Config()
;     ; Intended to be overridden
; endFunction

; function Command(string command, string description = "", string defaultSubcommand = "", float version = 1.0, bool helpSubcommand = true, bool versionSubcommand = true)
;     ; ConsoleCommands.RegisterCommand(...)
; endFunction

; function Subcommand(string subcommand, string description = "", string short = "")
; endFunction

; Prints out the provided text to the console
function Print(string text)
    ConsoleHelper.Print(text)
endFunction

; function Flag(string name, string description = "", string short = "", string subcommand = "")
; endFunction

; bool function HasFlag(string flag)
;     return false
; endFunction

; function OptionString(string name, string description = "", string short = "", string subcommand = "", string default = "")
; endFunction

; function OptionInt(string name, string description = "", string short = "", string subcommand = "", int default = 0)
; endFunction

; function OptionFloat(string name, string description = "", string short = "", string subcommand = "", float default = 0.0)
; endFunction

; string function GetOptionString(string name)
;     return ""
; endFunction

; int function GetOptionInt(string name)
;     return 0
; endFunction

; float function GetOptionFloat(string name)
;     return 0.0
; endFunction

