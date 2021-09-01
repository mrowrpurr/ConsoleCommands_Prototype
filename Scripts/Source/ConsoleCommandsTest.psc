scriptName ConsoleCommandsTest extends SkyUnitTest hidden
{Base script for Lilac tests for Console Commands

Clears all command data before every test runs.}

function BeforeEach()
    ConsoleCommands.Clear()
endFunction

Form function GetModForm(int formID)
    return Game.GetFormFromFile(formID, "ConsoleCommandsTests.esp")
endFunction

ExampleCommand function GetExampleCommand()
    return GetModForm(0x808) as ExampleCommand
endFunction

HelloCommand function GetHelloCommand()
    return GetModForm(0x806) as HelloCommand
endFunction

FooCommand function GetFooCommand()
    return GetModForm(0x807) as FooCommand
endFunction

BarCommand function GetBarCommand()
    return GetModForm(0x807) as BarCommand
endFunction