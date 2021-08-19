scriptName ConsoleCommand extends Quest hidden
{Extend this to create your own console command.

; Brief Instructions: ...}

; PERSIST THINGS FOR THIS COMMAND ONLY:
; ....



event OnInit()
    ; Config()

    string characters = "0123456789abcdef"
    int[] characterValues = new int[16]
    ; 0 - 9
    characterValues[0] = 48 ; 0
    characterValues[1] = 49 ; 1
    characterValues[2] = 50 ; 2
    characterValues[3] = 51 ; 3
    characterValues[4] = 52 ; 4
    characterValues[5] = 53 ; 5
    characterValues[6] = 54 ; 6
    characterValues[7] = 55 ; 7
    characterValues[8] = 56 ; 8
    characterValues[9] = 57 ; 9
    ; A - F
    characterValues[10] = 65 ; A
    characterValues[11] = 66 ; B
    characterValues[12] = 67 ; C
    characterValues[13] = 68 ; D
    characterValues[14] = 69 ; E
    characterValues[15] = 70 ; F

    string hex = "000800"

    int decimal
    int base = 1

    int index = 5
    while index >= 0
        string character = StringUtil.Substring(hex, index, 1)
        int characterIndex = StringUtil.Find(characters, character)
        int characterValue = characterValues[characterIndex]

        if characterValue >= 48 && characterValue <= 57 ; 0 - 9
            decimal = decimal + (characterValue - 48) * base
            base = base * 16
        elseIf characterValue >= 65 && characterValue <= 70 ; A - F
            decimal = decimal + (characterValue - 55) * base
            base = base * 16
        endIf

        index -= 1
    endWhile

    Debug.MessageBox("hex: " + hex + "  is " + decimal)

    Debug.MessageBox(Game.GetFormFromFile(decimal, "GimmeCommand.esp"))
endEvent

function Version(float version)
endFunction

function Author(string author)
endFunction

function Info()
    ;
endFunction

function Config()
    ; Intended to be overridden
endFunction

function Command(string command, string description = "", string defaultSubcommand = "", float version = 1.0, bool helpSubcommand = true, bool versionSubcommand = true)
    ; CustomConsoleCommands.RegisterCommand(...)
endFunction

function Subcommand(string subcommand, string description = "", string short = "")
endFunction

function Print(string text)
    ConsoleHelper.Print(text)
endFunction

function Flag(string name, string description = "", string short = "", string subcommand = "")
endFunction

bool function HasFlag(string flag)
    return false
endFunction

function OptionString(string name, string description = "", string short = "", string subcommand = "", string default = "")
endFunction

function OptionInt(string name, string description = "", string short = "", string subcommand = "", int default = 0)
endFunction

function OptionFloat(string name, string description = "", string short = "", string subcommand = "", float default = 0.0)
endFunction

string function GetOptionString(string name)
    return ""
endFunction

int function GetOptionInt(string name)
    return 0
endFunction

float function GetOptionFloat(string name)
    return 0.0
endFunction

event OnCommand(string command, string subcommand, string[] arguments)
    ; Should be overriden.
endEvent
