scriptName ConsoleCommand extends Quest hidden
{TODO add lots of documentation here :)}

; Identifier for registered command
int _commandId

; Identifier of the most recent parse result
int _parseResult

; Stores the text this command Print()'s for returning
; when other commands use ExecuteCommand() to get
; the results of this command
string _printedText

; Saves name before command registration
string _unregisteredName

; Get the command arguments
; Must be called from OnCommand() event
string[] property Arguments
    string[] function get()
        return ConsoleCommandParser.GetArguments(_parseResult)
    endFunction
endProperty

event OnInit()
    if ! ConsoleCommandsPrivateAPI.GetInstance().DisableCommandAutoRegistration
        Register()
    endIf
endEvent

function Register()
    if ! IsRegistered
        _commandId = ConsoleCommands.Add(GetCommandName()) ; TODO deal with if GetCommandName is ""
        ConsoleCommands.RegisterScript(GetCommandName(), self)
    endIf
endFunction

function Reset()
    _commandId = 0
    _parseResult = 0
    _printedText = ""
    _unregisteredName = ""
endFunction

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

bool property IsRegistered
    bool function get()
        return _commandId != 0
    endFunction
endProperty

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

; Customize the command's name
function Name(string commandName)
    if IsRegistered
        ; TODO
    else
        _unregisteredName = commandName
    endIf
endFunction

string function GetCommandName()
    if IsRegistered
        string registeredName = JMap.getStr(_commandId, "name")
        if registeredName
            return registeredName
        else
            return "Error-No-Registered-Name"
        endIf
    else
        if _unregisteredName
            return _unregisteredName
        else
            string fullScriptNameText = self
            int spaceIndex = StringUtil.Find(fullScriptNameText, " ")
            string scriptNameText = StringUtil.Substring(fullScriptNameText, 1, spaceIndex - 1)
            int commandIndex = StringUtil.Find(scriptNameText, "Command")
            if commandIndex == (StringUtil.GetLength(scriptNameText) - 7) ; Length of "Command"
                return StringUtil.Substring(scriptNameText, 0, commandIndex)
            else
                return scriptNameText ; The full name of the script
            endIf
        endIf
    endIf
endFunction
