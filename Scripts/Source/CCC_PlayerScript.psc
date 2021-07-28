Scriptname CCC_PlayerScript extends ReferenceAlias  

string MENU_NAME = "Console"
string COMMAND_HISTORY_TARGET = "_global.Console.ConsoleInstance.CommandHistory.text"
string COMMANDS_LENGTH_TARGET = "_global.Console.ConsoleInstance.Commands.length"

int ENTER_KEYCODE = 28
int RETURN_KEYCODE = 156

Event OnInit()
    StartListeningToConsole()
EndEvent

Function StartListeningToConsole()
    UnregisterForAllMenus()
    RegisterForMenu(MENU_NAME)
    Debug.Trace("Registered to listen for console open...")
EndFunction

Event OnMenuOpen(string menuName)
    Debug.Trace("Menu open: " + menuName)
    RegisterForKey(ENTER_KEYCODE)
    RegisterForKey(RETURN_KEYCODE)
EndEvent

Event OnMenuClose(string menuName)
    Debug.Trace("Menu close: " + menuName)
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
    string commandArguments = ""
    if commandParts.Length > 1
        commandArguments = StringUtil.Substring(mostRecentCommand, StringUtil.GetLength(commandName) + 1)
    endIf

    Debug.Trace("Command: " + commandName)

    if StorageUtil.StringListHas(None, "CCC_RegisteredCommands", commandName)
        Debug.Trace("Send Mod Event: OnConsole" + commandName)
        RemoveCommandNotFoundEntryFromHistory(commandName)
        SendModEvent("OnConsole" + commandName, commandArguments)
    endIf
EndEvent

Function RemoveCommandNotFoundEntryFromHistory(string commandName)
    string historyText = UI.GetString(MENU_NAME, COMMAND_HISTORY_TARGET)
    string errorString = "Script command \"" + commandName + "\" not found"
    int errorIndex = StringUtil.Find(historyText, errorString)
    string historyBeforeError = StringUtil.Substring(historyText, 0, errorIndex)
    UI.SetString(MENU_NAME, COMMAND_HISTORY_TARGET, historyBeforeError)
EndFunction
