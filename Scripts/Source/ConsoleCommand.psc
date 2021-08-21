scriptName ConsoleCommand extends Quest hidden
{Extend this to create your own console command.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private Fields
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int      _parseResult
string   _commandName
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
;; Command Name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Command(string name)
    ; If this has already been configured, gotta reconfigure it!
    ; ...
    ; ...
    _commandName = name
endFunction

string function GetCommandName()
    return _commandName
endFunction

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

    _parseResult = parseResult
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
;; Add Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; function Flag(string flag, string command = "", string subcommand = "")
; endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flag Getter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool function HasFlag(string flag)
    return ConsoleCommands.ParseResult_HasFlag(_parseResult, flag)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add Options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Option Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function GetOptionString(string option, string default = "")
    return ConsoleCommands.ParseResult_GetStringOption(_parseResult, option, default)
endFunction

int function GetOptionInt(string option, int default = 0)
    return ConsoleCommands.ParseResult_GetIntOption(_parseResult, option, default)
endFunction

float function GetOptionFloat(string option, float default = 0.0)
    return ConsoleCommands.ParseResult_GetFloatOption(_parseResult, option, default)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Console Print Helper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prints out the provided text to the console
function Print(string text)
    ConsoleHelper.Print(text)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; function Info()
; endFunction

event OnInit()
    ; SCRIPT NAME ==> COMMAND NAME PARSING LOGIC:
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

