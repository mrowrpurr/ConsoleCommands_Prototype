scriptName ConsoleCommandTest_InvokeViaModEvent extends ConsoleCommandsTest
{Tests for invoking console commands via custom provided SKSE mod event names}

function Tests()
    Test("can invoke one command via event").Fn(OneCommand_Test())
    Test("can invoke one subcommand via event").Fn(OneSubcommand_Test())
endFunction

string _onDragonCommand

function BeforeEach()
    parent.BeforeEach()
    _onDragonCommand = ""
endFunction

function AfterEach()
    parent.AFterEach()
    UnregisterForModEvent("DragonCommandEvent")
endFunction

event OnDragonCommand(string eventName, string command, float parseResult, Form sender)
    _onDragonCommand = "Called OnDragonCommand with: " + command
endEvent

function OneCommand_Test()
    ConsoleCommands.Add("dragon")
    ConsoleCommands.RegisterEvent(command = "dragon", eventName = "DragonCommandEvent")
    RegisterForModEvent("DragonCommandEvent", "OnDragonCommand")
    ExpectString(_onDragonCommand).To(BeEmpty())

    ConsoleCommands.ExecuteCommand("dragon tail")
    Utility.WaitMenuMode(0.1)

    ExpectString(_onDragonCommand).To(EqualString("Called OnDragonCommand with: dragon tail"))
endFunction

function OneSubcommand_Test()
    ConsoleCommands.Add("dragon")
    ConsoleCommands.AddSubcommand("dragon", "fire")
    ConsoleCommands.RegisterEvent(command = "dragon fire", eventName = "DragonCommandEvent")
    RegisterForModEvent("DragonCommandEvent", "OnDragonCommand")
    ExpectString(_onDragonCommand).To(BeEmpty())

    ConsoleCommands.ExecuteCommand("dragon")
    Utility.WaitMenuMode(0.1)
    ExpectString(_onDragonCommand).To(BeEmpty())

    ConsoleCommands.ExecuteCommand("dragon tail")
    Utility.WaitMenuMode(0.1)
    ExpectString(_onDragonCommand).To(BeEmpty())

    ConsoleCommands.ExecuteCommand("dragon fire")
    Utility.WaitMenuMode(1.0)
    ExpectString(_onDragonCommand).To(EqualString("Called OnDragonCommand with: dragon fire"))
endFunction
