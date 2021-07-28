Scriptname CCC_PlayerScript extends ReferenceAlias hidden

string MENU_NAME = "Console"
string COMMAND_HISTORY_TARGET = "_global.Console.ConsoleInstance.CommandHistory.text"
string COMMANDS_LENGTH_TARGET = "_global.Console.ConsoleInstance.Commands.length"
string COMMAND_REGISTRY_KEY = "CustomConsoleCommands_RegisteredCommands"

int ENTER_KEYCODE = 28
int RETURN_KEYCODE = 156

Event OnInit()
    StartListeningToConsole()
EndEvent

Event OnPlayerLoadGame()
    StartListeningToConsole()
EndEvent

Function StartListeningToConsole()
    UnregisterForAllMenus()
    RegisterForMenu(MENU_NAME)
    CCC_UtilityScript.Log("Listening for console commands...")
EndFunction

Event OnMenuOpen(string menuName)
    RegisterForKey(ENTER_KEYCODE)
    RegisterForKey(RETURN_KEYCODE)
EndEvent

Event OnMenuClose(string menuName)
    UnregisterForKey(ENTER_KEYCODE)
    UnregisterForKey(RETURN_KEYCODE)
EndEvent

Event OnKeyDown(int keyCode)
    if keyCode != ENTER_KEYCODE && keyCode != RETURN_KEYCODE
        return
    endIf
    
    int commandLenth = UI.GetInt(MENU_NAME, COMMANDS_LENGTH_TARGET)
    string mostRecentCommand = UI.GetString(MENU_NAME, "_global.Console.ConsoleInstance.Commands." + (commandLenth - 1))
    string[] commandParts = StringUtil.Split(mostRecentCommand, " ")
    string commandName = commandParts[0]

    if StorageUtil.StringListHas(None, COMMAND_REGISTRY_KEY, commandName)
        CCC_UtilityScript.Log("Run OnConsole" + commandName + " for command: " + mostRecentCommand)
        RemoveCommandNotFoundEntryFromHistory(commandName)
        SendModEvent("OnConsole" + commandName, mostRecentCommand)
    endIf
EndEvent

Function RemoveCommandNotFoundEntryFromHistory(string commandName)
    string historyText = UI.GetString(MENU_NAME, COMMAND_HISTORY_TARGET)
    string errorString = "Script command \"" + commandName + "\" not found"
    int errorIndex = StringUtil.Find(historyText, errorString)
    string historyBeforeError = StringUtil.Substring(historyText, 0, errorIndex)
    UI.SetString(MENU_NAME, COMMAND_HISTORY_TARGET, historyBeforeError)
EndFunction
