scriptName ConsoleCommandsVersionManager Hidden 
{Handles mod installation and load game events including upgrading mod to new versions.}

float property CurrentlyInstalledVersion auto

event OnInit()
    CurrentlyInstalledVersion = 1.0
endEvent

; We'll listen to this when we need to for versioning :)
; event OnPlayerLoadGame()
; endEvent
