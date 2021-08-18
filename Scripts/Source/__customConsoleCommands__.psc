scriptName __customConsoleCommands__ extends Quest hidden 
{Private Quest script for persisting global data for Custom Console Commands}

; Returns an instance of __customConsoleCommands__ (used for persisting all Custom Console Commands data)
__customConsoleCommands__ function GetInstance() global
    return Game.GetFormFromFile(0x800, "CustomConsoleCommands.esp") as __customConsoleCommands__
endFunction

function Debug(string text) global
    ConsoleHelper.Print("[CustomConsoleCommands] " + text)
endFunction

int property CommandsMapID auto

event OnInit()
    CommandsMapID = JMap.object()
    JValue.retain(CommandsMapID)
    ListenForCommands()
endEvent

int function GetNewCommandMapID(string command) global
    int commandMap = JMap.object()
    ; TODO deal with if command is already registered
    JMap.setObj(GetInstance().CommandsMapID, command, commandMap)
    return commandMap
endFunction

int function GetExistingCommandMapID(string command) global
    return JMap.getObj(GetInstance().CommandsMapID, command)
endFunction

int function GetExistingSubcommandMapID(string command, string subcommand) global
    int subcommandsMap = JMap.getObj(GetExistingCommandMapID(command), "subcommands")
    return JMap.getObj(subcommandsMap, subcommand)
endFunction

int function GetCommandOrSubcommandMapID(string command, string subcommand = "") global
    if subcommand
        return GetExistingSubcommandMapID(command, subcommand)
    else
        return GetExistingCommandMapID(command)
    endIf
endFunction

function ListenForCommands()
    ConsoleHelper.RegisterForCustomCommands("CustomConsoleCommand_INTERNAL")
    RegisterForModEvent("CustomConsoleCommand_INTERNAL", "OnCustomConsoleCommand")
endFunction

event OnCustomConsoleCommand(string eventName, string commandText, float _, Form sender)
    string[] commandParts = StringUtil.Split(commandText, " ")
    string commandName = commandParts[0]
    string subcommandName = commandParts[1]

    int commandMap = JMap.getObj(CommandsMapID, commandName)
    if commandMap
        int subcommandsMap = JMap.getObj(commandMap, "subcommands")
        int subcommandMap = JMap.getObj(subcommandsMap, subcommandName)
        if subcommandMap
            string callbackEvent = JMap.getStr(subcommandMap, "callbackEvent")
            SendModEvent(callbackEvent, commandText, 0.0)
        else
            string callbackEvent = JMap.getStr(commandMap, "callbackEvent")
            SendModEvent(callbackEvent, commandText, 0.0)
        endIf
    else
        ConsoleHelper.ExecuteCommand(commandText)
    endIf
endEvent










; ; This is what determines which command should be run
; string[] RegisteredCommandPrefixes

; ; This gets the full display name of the command being run
; string[] RegisteredCommandNames

; ; List of the ConsoleCommand instances which should be invoked when a command is run
; Form[] RegisteredConsoleCommands




; event OnCustomConsoleCommand(string eventName, string commandText, float _, Form sender)
;     int commandIndex = FindCommandIndex(commandText)
;     if commandIndex > -1
;         string commandName = RegisteredCommandNames[commandIndex]
;         ConsoleCommand command = RegisteredConsoleCommands[commandIndex] as ConsoleCommand
;         command.OnCommand(commandName, "", None) ; arguments and subcommand later
;     else
;         ConsoleHelper.ExecuteCommand(commandText)
;     endIf
; endEvent

; int function FindCommandIndex(string commandText)
;     int commandLength = StringUtil.GetLength(commandText)
;     int index = 0
;     while index < RegisteredCommandPrefixes.Length
;         string prefix = RegisteredCommandPrefixes[index]
;         int prefixIndex = StringUtil.Find(commandText, prefix)
;         if prefixIndex > -1
;             if StringUtil.GetLength(prefix) == commandLength || StringUtil.Find(commandText, prefix + " ") == 0
;                 return index
;             endIf
;         endIf
;         index += 1
;     endWhile
;     return -1
; endFunction

; function RegisterCommandPrefix(ConsoleCommand command, string commandName, string prefix)
;     if RegisteredCommandPrefixes
;         RegisteredCommandPrefixes = Utility.ResizeStringArray(RegisteredCommandPrefixes, RegisteredCommandPrefixes.Length + 1)
;         RegisteredCommandNames = Utility.ResizeStringArray(RegisteredCommandNames, RegisteredCommandNames.Length + 1)
;         RegisteredConsoleCommands = Utility.ResizeFormArray(RegisteredConsoleCommands, RegisteredConsoleCommands.Length + 1)
;     else
;         ; Initialize arrays
;         RegisteredCommandPrefixes = new string[1]
;         RegisteredCommandNames = new string[1]
;         RegisteredConsoleCommands = new Form[1]
;     endIf

;     RegisteredCommandPrefixes[RegisteredCommandPrefixes.Length - 1] = prefix
;     RegisteredCommandNames[RegisteredCommandNames.Length - 1] = commandName
;     RegisteredConsoleCommands[RegisteredConsoleCommands.Length - 1] = command

;     ; Start listening if there were previously no commands!
; endFunction
