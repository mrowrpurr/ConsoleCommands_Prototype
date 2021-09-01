scriptName ExampleCommand extends ConsoleCommand
{Example command used by the ConsoleCommand test}

event OnCommand()
   Print("You called example with arguments: " + GetArguments()) 
endEvent
