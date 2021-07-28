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
    string mostRecentCommand = UI.GetString(MENU_NAME, "_global.Console.ConsoleInstance.Commands." + (commandLenth - 1))
    
    string commandPrefix = "gold "
    if StringUtil.Find(mostRecentCommand, commandPrefix) == 0
        string argumentText = StringUtil.Substring(mostRecentCommand, StringUtil.GetLength(commandPrefix))
        string[] arguments = StringUtil.Split(argumentText, " ")
        GimmeGold(arguments)
        UI.Invoke(MENU_NAME, "_global.Console.ClearHistory")
    endIf
EndEvent

Function GimmeGold(string[] arguments)
    Actor player = Game.GetPlayer()
    Form gold = Game.GetForm(0x0000000f)
    int index = 0
    while index < arguments.Length
        int amount = arguments[index] as int
        if amount
            player.AddItem(gold, amount)
        endIf
        index += 1
    endWhile
EndFunction