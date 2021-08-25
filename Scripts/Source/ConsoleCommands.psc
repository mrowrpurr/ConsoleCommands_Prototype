scriptName ConsoleCommands hidden
{Primary interface for working with console commands.

To create your own console command, see the ConsoleCommand script}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Simple Command Getters
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
;; Adding Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool function Add(string name) global
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    return api.AddCommand(name)
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