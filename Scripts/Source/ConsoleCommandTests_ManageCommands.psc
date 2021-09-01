scriptName ConsoleCommandTests_ManageCommands extends ConsoleCommandsTest
{Tests for adding, removing, and editing commands}

function Tests()
    Test("can add a command").Fn(AddSimpleCommandTest())
    Test("can remove a command").Fn(RemoveSimpleCommandTest())
    Test("can clear all commands").Fn(ClearAllCommandsTest())
    ; it("can add aliases for commands")
endFunction

function AddSimpleCommandTest()
    ExpectInt(ConsoleCommands.Count()).To(EqualInt(0))

    ConsoleCommands.Add("mycommand")

    ExpectInt(ConsoleCommands.Count()).To(EqualInt(1))
    string firstCommandName = ConsoleCommands.Names()[0]
    ExpectString(firstCommandName).To(EqualString("mycommand"))
endFunction

function RemoveSimpleCommandTest()
    ConsoleCommands.Add("mycommand")
    ExpectInt(ConsoleCommands.Count()).To(EqualInt(1))

    ConsoleCommands.Remove("mycommand")

    ExpectInt(ConsoleCommands.Count()).To(EqualInt(0))
endFunction

function ClearAllCommandsTest()
    ConsoleCommands.Add("hello")
    ConsoleCommands.Add("world")
    ConsoleCommands.Add("hi")
    ExpectInt(ConsoleCommands.Count()).To(EqualInt(3))

    string[] commandNames = ConsoleCommands.Names()
    ExpectStringArray(commandNames).To(ContainString("hello"))
    ExpectStringArray(commandNames).To(ContainString("world"))
    ExpectStringArray(commandNames).To(ContainString("hi"))

    ConsoleCommands.Clear()

    ExpectInt(ConsoleCommands.Count()).To(EqualInt(0))
endFunction