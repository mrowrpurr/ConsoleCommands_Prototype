Scriptname CustomConsoleCommands

; Usage: RegisterCommand("<name of console command>")
string Function RegisterCommand(string commandPrefix) global
    StorageUtil.StringListAdd(None, "CCC_RegisteredCommands", commandPrefix)
    return "OnConsole" + commandPrefix
EndFunction