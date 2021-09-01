Scriptname ConsoleCommandTests_CommandFlags extends Quest
{Tests for command flags, e.g. -s --silent}

function TestSuites()
    ; describe("Command Flags", CommandFlagTests())
endFunction

function CommandFlagTests()
    ; it("does not add any flags if command with name does not exist", CommandDoesNotExistTest())
    ; it("can add a flag to a command (by name)", AddFlagTest())
    ; it("can add a flag with an alias (by name)", AddFlagWithAliasTest())
endFunction

; function CommandDoesNotExistTest()
;     int flag = ConsoleCommands.AddFlag("silent", command = "hello")

;     expectInt(flag, to, beEqualTo, 0)
; endFunction

; function AddFlagTest()
;     ConsoleCommands.Add("hello")

;     int flag = ConsoleCommands.AddFlag("silent", command = "hello")

;     expectInt(flag, notTo, beEqualTo, 0)
; endFunction

; function AddFlagWithAliasTest()
; endFunction
