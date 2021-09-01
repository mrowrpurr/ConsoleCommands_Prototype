Scriptname ConsoleCommandTests_CommandOptions extends ConsoleCommandsTest
{Tests for command options, e.g. -n 5 or --num 5}

import ArrayAssertions

function Tests()
    Test("can add an option to a command")
    Test("can remove an option from a command")
endFunction
