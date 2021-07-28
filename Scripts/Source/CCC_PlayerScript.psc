Scriptname CCC_PlayerScript extends ReferenceAlias  

string MENU_NAME = "Console"
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
    Debug.Trace("Menu open: " + menuName)
    UnregisterForKey(ENTER_KEYCODE)
    UnregisterForKey(RETURN_KEYCODE)
EndEvent

Event OnKeyDown(int keyCode)
    if keyCode != ENTER_KEYCODE && keyCode != RETURN_KEYCODE
        return
    endIf

    int commandLenth = UI.GetInt(MENU_NAME, "_global.Console.ConsoleInstance.Commands.length")
    Debug.Trace("Total number of commands run: " + commandLenth)

    string mostRecentCommand = UI.GetString(MENU_NAME, "_global.Console.ConsoleInstance.Commands." + (commandLenth - 1))
    Debug.Trace("Most recent command: " + mostRecentCommand)

    string fullCommandHistory = UI.GetString(MENU_NAME, "_global.Console.ConsoleInstance.CommandHistory.text")
    Debug.Trace("FULL HISTORY: " + fullCommandHistory)

    ; UI.SetString(MENU_NAME, "_global.Console.ConsoleInstance.CommandHistory.text", "")
    ; UI.Invoke(MENU_NAME, "_global.Console.ClearHistory")
    UI.Invoke(MENU_NAME, "_global.Console.ClearHistory")
    UI.InvokeInt(MENU_NAME, "_global.Console.SetTextSize", 10)
EndEvent