scriptName ___customConsoleCommands___ extends ReferenceAlias hidden 
{Private Player Script for Custom Console Commands to capture load game events and perform mod upgrades}

; The currently installed version of Custom Console Commands
float property CurrentlyInstalledVersion auto

; On Mod Installation
event OnInit()
    CurrentlyInstalledVersion = CustomConsoleCommands.GetCurrentVersion()
    __customConsoleCommands__.GetInstance().ListenForCommands()
endEvent

; On Load Game when mod was previously installed
event OnPlayerLoadGame()
    __customConsoleCommands__.GetInstance().ListenForCommands()
endEvent
