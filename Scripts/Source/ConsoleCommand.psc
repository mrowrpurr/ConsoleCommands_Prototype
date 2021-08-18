scriptName ConsoleCommand extends Quest hidden
{Extend this to create your own console command.

; Brief Instructions: ...}

; ; PERSIST THINGS FOR THIS COMMAND ONLY:
; ; ....

; event OnInit()
;     Config()
; endEvent

; function Config()
;     ; Intended to be overriden
; endFunction

; function Command(string command, string description = "", string short = "", string defaultSubcommand = "", float version = 1.0, bool helpSubcommand = true, bool versionSubcommand = true)
;     __customConsoleCommands__.GetInstance().RegisterCommandPrefix(self, command, prefix = command)
;     if short
;         __customConsoleCommands__.GetInstance().RegisterCommandPrefix(self, command, prefix = short)
;     endIf
; endFunction

; function Subcommand(string subcommand, string description = "", string short = "")
; endFunction

; function Print(string text)
;     ConsoleHelper.Print(text)
; endFunction

; function Flag(string name, string description = "", string short = "", string subcommand = "")
; endFunction

; bool function GetFlag(string flag)
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

; event OnCommand(string command, string subcommand, string[] arguments)
;     ; Should be overriden.
; endEvent
