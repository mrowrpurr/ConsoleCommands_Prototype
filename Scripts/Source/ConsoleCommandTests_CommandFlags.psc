Scriptname ConsoleCommandTests_CommandFlags extends ConsoleCommandsTest
{Tests for command flags, e.g. -s --silent}

import ArrayAssertions

function Tests()
    Test("can add a flag to a command").Fn(AddFlagTest())
    Test("can remove a flag from a command").Fn(RemoveFlagTest())
endFunction

function AddFlagTest()
    ConsoleCommands.Add("hello")

    int flag = ConsoleCommands.AddFlag("silent", command = "hello")

    ExpectInt(flag).Not().To(EqualInt(0))
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(EqualStringArray1("silent"))
endFunction

function RemoveFlagTest()
    ConsoleCommands.Add("hello")
    ConsoleCommands.AddFlag("silent", command = "hello")
    ConsoleCommands.AddFlag("verbose", command = "hello")
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(HaveLength(2))
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(ContainString("silent"))
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(ContainString("verbose"))

    ConsoleCommands.RemoveFlag("silent", command = "hello")

    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(HaveLength(1))
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(ContainString("verbose"))
    ExpectStringArray(ConsoleCommands.FlagNames("hello")).Not().To(ContainString("silent"))

    ConsoleCommands.RemoveFlag("verbose", command = "hello")

    ExpectStringArray(ConsoleCommands.FlagNames("hello")).To(BeEmpty())
endFunction
