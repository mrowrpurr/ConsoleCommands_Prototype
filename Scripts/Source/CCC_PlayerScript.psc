Scriptname CCC_PlayerScript extends ReferenceAlias hidden

int[] AllKeyCodes

Event OnInit()
    SetupAllKeyCodesArray()
    RegisterForMenu("Console")
EndEvent

Event OnMenuOpen(string menuName)
    Debug.Notification("OPEN: " + menuName)
    ListenForAnyKey()
EndEvent

Event OnMenuClose(string menuName)
    Debug.Notification("CLOSE: " + menuName)
    UnregisterForAllKeys()
EndEvent

event OnKeyDown(int keyCode)
    if keyCode == 32 ; D
        bool customCommandsEnabled = UI.GetBool("Console", "_global.Console.ConsoleInstance.CustomCommandsEnabled")
        if customCommandsEnabled
            UI.SetBool("Console", "_global.Console.ConsoleInstance.CustomCommandsEnabled", false)
            Debug.Notification("Disabled custom commands")
        else
            UI.SetBool("Console", "_global.Console.ConsoleInstance.CustomCommandsEnabled", true)
            Debug.Notification("Enabled custom commands")
        endIf
    elseIf keyCode == 45 ; x
        UI.InvokeString("Console", "_global.Console.ConsoleInstance.ExecuteCommand", "player.additem f 1000")
    endIf
endEvent








; string COMMANDS_LENGTH_TARGET = "_global.Console.ConsoleInstance.Commands.length"
; string COMMAND_REGISTRY_KEY = "CustomConsoleCommands_RegisteredCommands"

; int ENTER_KEYCODE = 28
; int RETURN_KEYCODE = 156

; Event OnMenuClose(string menuName)
;     UnregisterForKey(ENTER_KEYCODE)
;     UnregisterForKey(RETURN_KEYCODE)
; EndEvent

; Event OnPlayerLoadGame()
;     ; StartListeningToConsole()
; EndEvent

; Function StartListeningToConsole()
;     UnregisterForAllMenus()
;     RegisterForMenu(MENU_NAME)
;     CCC_UtilityScript.Log("Listening for console commands...")
; EndFunction

; Event OnMenuOpen(string menuName)
;     RegisterForKey(ENTER_KEYCODE)
;     RegisterForKey(RETURN_KEYCODE)
; EndEvent

; Event OnMenuClose(string menuName)
;     UnregisterForKey(ENTER_KEYCODE)
;     UnregisterForKey(RETURN_KEYCODE)
; EndEvent

; Event OnKeyDown(int keyCode)
;     if keyCode != ENTER_KEYCODE && keyCode != RETURN_KEYCODE
;         return
;     endIf
    
;     int commandLenth = UI.GetInt(MENU_NAME, COMMANDS_LENGTH_TARGET)
;     string mostRecentCommand = UI.GetString(MENU_NAME, "_global.Console.ConsoleInstance.Commands." + (commandLenth - 1))
;     string[] commandParts = StringUtil.Split(mostRecentCommand, " ")
;     string commandName = commandParts[0]

;     if StorageUtil.StringListHas(None, COMMAND_REGISTRY_KEY, commandName)
;         CCC_UtilityScript.Log("Run OnConsole" + commandName + " for command: " + mostRecentCommand)
;         RemoveCommandNotFoundEntryFromHistory(commandName)
;         SendModEvent("OnConsole" + commandName, mostRecentCommand)
;     endIf
; EndEvent

; Function RemoveCommandNotFoundEntryFromHistory(string commandName)
;     string historyText = UI.GetString(MENU_NAME, COMMAND_HISTORY_TARGET)
;     string errorString = "Script command \"" + commandName + "\" not found"
;     int errorIndex = StringUtil.Find(historyText, errorString)
;     string historyBeforeError = StringUtil.Substring(historyText, 0, errorIndex)
;     UI.SetString(MENU_NAME, COMMAND_HISTORY_TARGET, historyBeforeError)
; EndFunction

function ListenForAnyKey()
    int index = 0
    while index < AllKeyCodes.Length
        RegisterForKey(AllKeyCodes[index])
        index += 1
    endWhile
    Debug.Notification("Registered!")
endFunction

function SetupAllKeyCodesArray()
    AllKeyCodes = new int[101]
    AllKeyCodes[0] = 1 ; 0x01 Escape
    AllKeyCodes[1] = 2 ; 0x02 1
    AllKeyCodes[2] = 3 ; 0x03 2
    AllKeyCodes[3] = 4 ; 0x04 3
    AllKeyCodes[4] = 5 ; 0x05 4
    AllKeyCodes[5] = 6 ; 0x06 5
    AllKeyCodes[6] = 7 ; 0x07 6
    AllKeyCodes[7] = 8 ; 0x08 7
    AllKeyCodes[8] = 9 ; 0x09 8
    AllKeyCodes[9] = 10 ; 0x0A 9
    AllKeyCodes[10] = 11 ; 0x0B 0
    AllKeyCodes[11] = 12 ; 0x0C Minus
    AllKeyCodes[12] = 13 ; 0x0D Equals
    AllKeyCodes[13] = 14 ; 0x0E Backspace
    AllKeyCodes[14] = 15 ; 0x0F Tab
    AllKeyCodes[15] = 16 ; 0x10 Q
    AllKeyCodes[16] = 17 ; 0x11 W
    AllKeyCodes[17] = 18 ; 0x12 E
    AllKeyCodes[18] = 19 ; 0x13 R
    AllKeyCodes[19] = 20 ; 0x14 T
    AllKeyCodes[20] = 21 ; 0x15 Y
    AllKeyCodes[21] = 22 ; 0x16 U
    AllKeyCodes[22] = 23 ; 0x17 I
    AllKeyCodes[23] = 24 ; 0x18 O
    AllKeyCodes[24] = 25 ; 0x19 P
    AllKeyCodes[25] = 26 ; 0x1A Left
    AllKeyCodes[26] = 27 ; 0x1B Right
    AllKeyCodes[27] = 28 ; 0x1C Enter
    AllKeyCodes[28] = 29 ; 0x1D Left
    AllKeyCodes[29] = 30 ; 0x1E A
    AllKeyCodes[30] = 31 ; 0x1F S
    AllKeyCodes[31] = 32 ; 0x20 D
    AllKeyCodes[32] = 33 ; 0x21 F
    AllKeyCodes[33] = 34 ; 0x22 G
    AllKeyCodes[34] = 35 ; 0x23 H
    AllKeyCodes[35] = 36 ; 0x24 J
    AllKeyCodes[36] = 37 ; 0x25 K
    AllKeyCodes[37] = 38 ; 0x26 L
    AllKeyCodes[38] = 39 ; 0x27 Semicolon
    AllKeyCodes[39] = 40 ; 0x28 Apostrophe
    AllKeyCodes[40] = 41 ; 0x29 ~
    AllKeyCodes[41] = 42 ; 0x2A Left
    AllKeyCodes[42] = 43 ; 0x2B Back
    AllKeyCodes[43] = 44 ; 0x2C Z
    AllKeyCodes[44] = 45 ; 0x2D X
    AllKeyCodes[45] = 46 ; 0x2E C
    AllKeyCodes[46] = 47 ; 0x2F V
    AllKeyCodes[47] = 48 ; 0x30 B
    AllKeyCodes[48] = 49 ; 0x31 N
    AllKeyCodes[49] = 50 ; 0x32 M
    AllKeyCodes[50] = 51 ; 0x33 Comma
    AllKeyCodes[51] = 52 ; 0x34 Period
    AllKeyCodes[52] = 53 ; 0x35 Forward
    AllKeyCodes[53] = 54 ; 0x36 Right
    AllKeyCodes[54] = 55 ; 0x37 NUM*
    AllKeyCodes[55] = 56 ; 0x38 Left
    AllKeyCodes[56] = 57 ; 0x39 Spacebar
    AllKeyCodes[57] = 58 ; 0x3A Caps
    AllKeyCodes[58] = 59 ; 0x3B F1
    AllKeyCodes[59] = 60 ; 0x3C F2
    AllKeyCodes[60] = 61 ; 0x3D F3
    AllKeyCodes[61] = 62 ; 0x3E F4
    AllKeyCodes[62] = 63 ; 0x3F F5
    AllKeyCodes[63] = 64 ; 0x40 F6
    AllKeyCodes[64] = 65 ; 0x41 F7
    AllKeyCodes[65] = 66 ; 0x42 F8
    AllKeyCodes[66] = 67 ; 0x43 F9
    AllKeyCodes[67] = 68 ; 0x44 F10
    AllKeyCodes[68] = 69 ; 0x45 Num
    AllKeyCodes[69] = 70 ; 0x46 Scroll
    AllKeyCodes[70] = 71 ; 0x47 NUM7
    AllKeyCodes[71] = 72 ; 0x48 NUM8
    AllKeyCodes[72] = 73 ; 0x49 NUM9
    AllKeyCodes[73] = 74 ; 0x4A NUM-
    AllKeyCodes[74] = 75 ; 0x4B NUM4
    AllKeyCodes[75] = 76 ; 0x4C NUM5
    AllKeyCodes[76] = 77 ; 0x4D NUM6
    AllKeyCodes[77] = 78 ; 0x4E NUM+
    AllKeyCodes[78] = 79 ; 0x4F NUM1
    AllKeyCodes[79] = 80 ; 0x50 NUM2
    AllKeyCodes[80] = 81 ; 0x51 NUM3
    AllKeyCodes[81] = 82 ; 0x52 NUM0
    AllKeyCodes[82] = 83 ; 0x53 NUM.
    AllKeyCodes[83] = 87 ; 0x57 F11
    AllKeyCodes[84] = 88 ; 0x58 F12
    AllKeyCodes[85] = 156 ; 0x9C NUM
    AllKeyCodes[86] = 157 ; 0x9D Right
    AllKeyCodes[87] = 181 ; 0xB5 NUM/
    AllKeyCodes[88] = 183 ; 0xB7 SysRq
    AllKeyCodes[89] = 184 ; 0xB8 Right
    AllKeyCodes[90] = 197 ; 0xC5 Pause
    AllKeyCodes[91] = 199 ; 0xC7 Home
    AllKeyCodes[92] = 200 ; 0xC8 Up
    AllKeyCodes[93] = 201 ; 0xC9 PgUp
    AllKeyCodes[94] = 203 ; 0xCB Left
    AllKeyCodes[95] = 205 ; 0xCD Right
    AllKeyCodes[96] = 207 ; 0xCF End
    AllKeyCodes[97] = 208 ; 0xD0 Down
    AllKeyCodes[98] = 209 ; 0xD1 PgDown
    AllKeyCodes[99] = 210 ; 0xD2 Insert
    AllKeyCodes[100] = 211 ; 0xD3 Delete
endFunction