Scriptname CustomConsoleCommands

; Register callback for provided ~ console command
;
; e.g. RegisterForModEvent(CustomConsoleCommands.RegisterCommand("Gold"), "OnGoldCommand")
;      and in the ~ console run: `gold 42` to trigger the OnGoldCommand ModEvent callback.
string Function RegisterCommand(string command) global
    StorageUtil.StringListAdd(None, "CustomConsoleCommands_RegisteredCommands", command)
    CCC_UtilityScript.Log("Command registered: " + command)
    return "OnConsole" + command
EndFunction