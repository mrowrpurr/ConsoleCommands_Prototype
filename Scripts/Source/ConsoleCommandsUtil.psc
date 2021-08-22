scriptName ConsoleCommandsUtil hidden
{Utility functions for working *directly* with registered console commands.

You are probably looking for:
- ConsoleCommand (script which you extend to create a custom command)
- ConsoleCommands (global functions for working with custom commnads)

ConsoleCommandsUtil has utility functions for working with commands using
each command's unique integer identifier.

This script does not support working with commands or subcommands via string name,
use the ConsoleCommands script for that instead.

This *is* considered part of the public interface of ConsoleCommands and may be used.
We will aim to provide backwards compatibility to changes made to this interface.}