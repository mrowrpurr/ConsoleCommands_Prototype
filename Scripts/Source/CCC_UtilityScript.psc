Scriptname CCC_UtilityScript hidden

; Log function for Custom Console Commands
Function Log(string text) global
    Debug.Trace("[CustomConsoleCommands] " + text)
EndFunction