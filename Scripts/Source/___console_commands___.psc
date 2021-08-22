scriptName ___console_commands___ extends ReferenceAlias hidden 
{Private Player Script for Custom Console Commands to capture load game events and perform mod upgrades}

; The currently installed version of Custom Console Commands
float property CurrentlyInstalledVersion auto

; On Mod Installation
event OnInit()
    CurrentlyInstalledVersion = ConsoleCommands.GetCurrentVersion()
    __console_commands__.GetInstance().Setup()
endEvent

; On Load Game when mod was previously installed
event OnPlayerLoadGame()
endEvent

event OnDeath(Actor akKiller)
    ConsoleHelper.EnableNativeEnterReturnKeyHandling()
endEvent