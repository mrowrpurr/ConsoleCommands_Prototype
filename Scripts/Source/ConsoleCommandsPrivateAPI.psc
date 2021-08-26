Scriptname ConsoleCommandsPrivateAPI extends Quest  
{Private API for Console Commands.

Please do not use.

The interfaces here may change at any time!

To use "Console Commands", please use one of the following:

- ConsoleCommand script to make your own command
- ConsoleCommands for the global interface for working with commands
- ConsoleCommandParser for parsing commands and getting command options
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Singleton ~ GetInstance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Singleton
ConsoleCommandsPrivateAPI function GetInstance() global
    return Game.GetFormFromFile(0x800, "ConsoleCommands.esp") as ConsoleCommandsPrivateAPI
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Primary data storage object
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

int _data

; Primary data structure for all command storage
int property Data
    int function get()
        if _data == 0
            _data = JMap.object() ; Setup Data as a fresh new Map (string map)
            JValue.retain(_data)  ; Hold onto this! Don't garbage collect it!
            InitializeStorage()
        endIf
        return _data
    endFunction
endProperty

; Setup data structures for storing commands and metadata
function InitializeStorage()
    JMap.setObj(Data, KEY_Data_Commands, JIntMap.object())
    JMap.setObj(Data, KEY_Data_CommandNames, JMap.object())
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Storage Objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Data Commands is a Map<int,int> which maps commands
; to themselves by their ID.
; This exists to make sure commands are *retained*.
int property Data_Commands
    int function get()
        return JMap.getObj(Data, KEY_Data_Commands)
    endFunction
endProperty

; Data CommandNames is a Map<string,int> which maps command names
; to the object ID of that command.
; There may be multiple names which all point to the same command.
int property Data_CommandNames
    int function get()
        return JMap.getObj(Data, KEY_Data_CommandNames)
    endFunction
endProperty

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool function AddCommand(string name)
    int command = JMap.object()
    JMap.setStr(command, KEY_Data_Commands_Name, name)
    JIntMap.setObj(Data_Commands, command, command) ; Add command object
    JMap.setObj(Data_CommandNames, name, command)   ; Add to command names
    return true ; TODO
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remove Command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bool function RemoveCommand(string name)
    int command = GetCommand(name)
    if command
        JMap.removeKey(Data_CommandNames, name)   ; Remove from names (O(n))
        JIntMap.removeKey(Data_Commands, command) ; JMap.removeKey(Data_Commands) ; Remove command object
    endIf
    return true ; TODO
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get ID for Command (from name)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;s

int function GetCommand(string name)
    return JMap.getObj(Data_CommandNames, name)
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants (light properties, not saved)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property KEY_Data_CommandNames
    string function get()
        return "commandNames"
    endFunction
endProperty

string property KEY_Data_Commands
    string function get()
        return "commands"
    endFunction
endProperty

string property KEY_Data_Commands_Name
    string function get()
        return "name"
    endFunction
endProperty