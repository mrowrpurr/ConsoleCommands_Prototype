Scriptname CCC_PlayerScript extends ReferenceAlias  

string MENU_NAME = "Console"

Event OnInit()
    StartListeningToConsole()
EndEvent

Function StartListeningToConsole()
    Debug.Trace("START LISTENING")
    UnregisterForAllMenus()
    ;UnregisterForMenu(MENU_NAME)
    RegisterForMenu(MENU_NAME)
    RegisterForMenu(MENU_NAME)
    Debug.MessageBox("Registered to listen for console open'")
EndFunction

Event OnMenuOpen(string menuName)
    Debug.Trace("What do you want me to put in here? oN MENU OPEN: " + menuName)
EndEvent

Event OnMenuClose(string menuName)
    Debug.Trace("What do you want me to put in here? Foooo oN MENU CLOSE: " + menuName)
EndEvent