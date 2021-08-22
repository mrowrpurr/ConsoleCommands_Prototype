scriptName ConsoleCommandParser hidden
{Utility functions for parsing command text directly taken from the ~ console
and extracting information such as:
- What command was run?
- What subcommand was run, if any?
- What options or flags were set?

The primary function is Parse() which takes command text and returns
and integer identifier representing the parse results.

To access data about the parsed commands, pass the parse result integer
identifier to the other functions in this script, e.g.
- GetCommandName(parseResult)
- GetSubcommandName(parseResult)
- GetArguments(parseResult)

Please note that a "parse result" is a temporary object and the
identifier may no longer be valid after only a couple of seconds.

To hold onto your parse result information temporarily or indefinitely,
use ConsoleCommandParser.SaveResult(parseResult).

If/when you are done using the parse result information, you can
call ConsoleCommandParser.UnsaveResult(parseResult).

Saved results are stored in the SKSE Save Game file.}