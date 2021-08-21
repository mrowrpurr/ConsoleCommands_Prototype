scriptName ConsoleCommand extends Quest hidden
{Extend this to create your own console command.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private Fields
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Internal ID for the command information
int _commandId

; Whether or not the script and its subcommands have been explicitly disabled
bool _enabled = true

; Fields for the mostly recently run console command
int      _parseResult
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
;; DSL for setting information about the console command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Miscellaneous function if you want to use it
; Runs before any other functions including before Info()
function Setup()
endFunction

; Use this function to set the name of your command, version, etc.
;
; Example:
;
;   function Info()
;     Name("mycommand")
;     Version(1.0)
;     Author("me")
;   endFunction
;
function Info()
endFunction

; Recommended function to add your Options and Flags configuration to
function Options()
endFunction

; Recommended function to add your Subcommand configuration to
function Subcommands()
endFunction

; Set the console command name, e.g. "hello"
;
; This is optional if you name your ConsoleCommand "HelloCommand"
function Name(string name)
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.Debug("Setting name of command to " + name + " for " + self + "( in map " + ccc.GetMap_CommandNamesToMaps() + ")")
    JMap.setStr(_commandId, ccc.NAME_KEY, name)
    JMap.setObj(ccc.GetMap_CommandNamesToMaps(), name, _commandId)
endFunction

string function GetName()
    __console_commands__ ccc = __console_commands__.GetInstance()
    return JMap.getStr(_commandId, ccc.NAME_KEY)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; If you override this, you must call parent.OnInit()
event OnInit()
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.Debug("OnInit " + self)
    _commandId = ccc.CreateAndRegisterNewCommandMap()
    ccc.Debug("Adding script " + self + " to " + _commandId)
    ccc.AddScriptInstanceForCommandOrSubcommand(_commandId, self)

    Setup()
    Info()
    Options()
    Subcommands()

    string commandName = GetName()
    if ! commandName
        commandName = ccc.GetCommandNameForScript(self)
        if commandName
            Name(commandName)
        endIf
    endIf

    if commandName
        ; If there's a name configured, we enable the main command and any default-enabled subcommands and start listening!
        ; Unless they explicitly called Disable() in one of the setup functions
        if _enabled
            ccc.SetupNewCommandAndItsSubcommands(_commandId)
            ccc.Debug("New command setup: " + commandName)
        endIf
    else
        ccc.Log("Command name could not be deterined for script: " + self)
    endIf
endEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable / Disable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Enable()
    _enabled = true
    ; TODO ccc.EnableCommandAndItsSubcommands()
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.Log("Enable() not yet fully supported")
endFunction

function Disable()
    _enabled = false
    ; TODO ccc.DisableCommandAndItsSubcommands()
    __console_commands__ ccc = __console_commands__.GetInstance()
    ccc.Log("Disable() not yet fully supported")
endFunction

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

    ccc.Debug("Invoking OnCommand()")
    self.OnCommand()

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

; function Info()
; endFunction


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

