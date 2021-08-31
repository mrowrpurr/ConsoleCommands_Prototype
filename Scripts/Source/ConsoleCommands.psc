scriptName ConsoleCommands hidden
{Primary interface for working with console commands.

To create your own console command, see the ConsoleCommand script}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clearing all data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function Clear() global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    api.ResetStorage()
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Helpful Command Getters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Count() global ; TODO : Count(enabledOnly = false)
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    return JMap.count(api.Data_CommandNames)
endFunction

string[] function Names() global ; TODO : Names(enabledOnly = false)
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    return JMap.allKeysPArray(api.Data_CommandNames)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function Add(string name) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    return api.AddCommand(name)
endFunction

function Remove(string name) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    api.RemoveCommand(name)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subcommands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function AddSubcommand(string command, string subcommand, string short = "") global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    int commandId = api.GetCommand(command)
    if commandId
        int subcommandId = api.AddSubcommand(commandId, subcommand)
        if short
            api.AddSubcommandAlias(subcommandId, short)
        endIf
        return subcommandId
    endIf
endFunction

function RemoveSubcommand(string command, string subcommand) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    int commandId = api.GetCommand(command)
    if commandId
        int subcommandId = api.GetSubcommand(commandId, subcommand)
        if subcommandId
            api.RemoveSubcommand(commandId, subcommandId)
        endIf
    endIf
endFunction

string[] function SubcommandNames(string command) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    int id = api.GetCommandOrSubcommandByFullName(command)
    if id
        int subcommandsByName = JMap.getObj(id, "subcommandsByName")
        return JMap.allKeysPArray(subcommandsByName)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int function AddFlag(string name, string short = "", string command = "", string subcommand = "") global
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Options 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Execute Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string function ExecuteCommand(string command) global ; Add options for whether to add the command to the command history and print it etc
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    return api.ExecuteCommand(command)
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SKSE Mod Event Command Handlers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function RegisterEvent(string command, string eventName) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    int id = api.GetCommandOrSubcommandByFullName(command)
    api.Log("global RegisterEvent " + command + " " + eventName + " : " + id)
    if id
        api.RegisterEvent(id, eventName)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ConsoleCommand script registration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function RegisterScript(string command, ConsoleCommand script) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    int id = api.GetCommandOrSubcommandByFullName(command)
    api.Log("global RegisterScript " + command + " " + script + " : " + id)
    if id
        api.RegisterScript(id, script)
    endIf
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
