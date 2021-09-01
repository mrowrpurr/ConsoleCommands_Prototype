scriptName ConsoleCommandTests_ConsoleCommand extends ConsoleCommandsTest  
{Tests for using the ConsoleCommand script to craft console commands}

function Tests()
    Test("Command name is automatically detected from script name").Fn(DetectCommandNameFromScriptName())
    Test("Is automatically registered and can be invoked").Fn(InvokeCommand_Basic())
    Test("Can customize the script name").Fn(CustomizeScriptName())
    Test("Can easily setup and check for flags").Fn(CommandFlags())
endFunction

function BeforeEach()
    parent.BeforeEach()
    GetExampleCommand().Reset()
endFunction

function DetectCommandNameFromScriptName()
    ExpectString(GetExampleCommand().GetCommandName()).To(EqualString("Example"))
endFunction

function InvokeCommand_Basic()
    ConsoleCommandsPrivateAPI.GetInstance().DisableCommandAutoRegistration = false
    GetExampleCommand().OnInit()

    string output = ConsoleCommands.ExecuteCommand("example hello world")

    ExpectString(output).To(EqualString("You called example with arguments: [\"hello\", \"world\"]"))
endFunction

function CustomizeScriptName()
    ExpectString(GetExampleCommand().GetCommandName()).To(EqualString("Example"))
    ExpectBool(GetExampleCommand().IsRegistered).To(EqualBool(false))

    GetExampleCommand().Name("foo")

    ExpectString(GetExampleCommand().GetCommandName()).To(EqualString("foo"))
    ExpectBool(GetExampleCommand().IsRegistered).To(EqualBool(false))
endFunction

function CommandFlags()
    ExampleCommand example = GetExampleCommand()

    example.Register()
    example.Flag("silent", "s") ; Flag *after* registration

    ExpectBool(example.HasFlag("silent")).To(BeFalse())

    int result = ConsoleCommandParser.Parse("example -s")
    JValue.writeToFile(result, "TheResult.json")
    example.InvokeCommand(result)
    ExpectBool(example.HasFlag("silent")).To(BeTrue())

    result = ConsoleCommandParser.Parse("example foo")
    example.InvokeCommand(result)
    ExpectBool(example.HasFlag("silent")).To(BeFalse())
endFunction
