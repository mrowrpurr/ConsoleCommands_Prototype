scriptName ConsoleCommand extends Quest hidden
{TODO add lots of documentation here :)}

int _commandId
int _parseResult
string _printedText

event OnInit()
    _commandId = ConsoleCommands.Add(GetCommandName()) ; TODO deal with if GetCommandName is ""
    ConsoleCommands.RegisterScript(GetCommandName(), self)
endEvent

event OnCommand()
endEvent

string function InvokeCommand(int parseResult)
    _parseResult = parseResult
    _printedText = ""
    OnCommand()
    return _printedText
endFunction

int function GetCommandID()
    return _commandId
endFunction

string[] function GetArguments()
    return ConsoleCommandParser.GetArguments(_parseResult)
endFunction

string function GetCommandName()
    string fullScriptNameText = self
    int spaceIndex = StringUtil.Find(fullScriptNameText, " ")
    string scriptNameText = StringUtil.Substring(fullScriptNameText, 1, spaceIndex - 1)
    int commandIndex = StringUtil.Find(scriptNameText, "Command")
    if commandIndex == (StringUtil.GetLength(scriptNameText) - 7) ; Length of "Command"
        return StringUtil.Substring(scriptNameText, 0, commandIndex)
    endIf
endFunction

function Print(string text, bool appendOutput = true)
    ConsoleMenu.Print(text)
    if appendOutput
        AppendOutput(text)
    endIf
endFunction

function AppendOutput(string text)
    if _printedText
        _printedText += "\n" + text
    else
        _printedText = text
    endIf
endFunction
