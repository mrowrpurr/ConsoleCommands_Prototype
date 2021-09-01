scriptName ConsoleCommandsVersionManager extends ReferenceAlias hidden 
{Handles mod installation and load game events including upgrading mod to new versions.}

float property CurrentlyInstalledVersion auto

event OnInit()
    CurrentlyInstalledVersion = 1.0
endEvent

event OnPlayerLoadGame()
    ConsoleCommandsPrivateAPI api = ConsoleCommandsPrivateAPI.GetInstance()
    api.ListenForConsoleCommands() ; Start listening again after load game event!
endEvent
