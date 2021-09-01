scriptName ConsoleCommandTests_ConsoleCommand extends ConsoleCommandsTest  
{Tests for using the ConsoleCommand script to craft console commands}

function Tests()
    Test("Command name is automatically detected from script name").Fn(DetectCommandNameFromScriptName())
    Test("Command can be invoked").Fn(InvokeCommand_Basic())
endFunction

function DetectCommandNameFromScriptName()
    ExpectString(GetExampleCommand().GetCommandName()).To(EqualString("Example"))
endFunction

function InvokeCommand_Basic()
    GetExampleCommand().OnInit()

    string output = ConsoleCommands.ExecuteCommand("example hello world")

    ExpectString(output).To(EqualString("You called example with arguments: [\"hello\", \"world\"]"))
endFunction