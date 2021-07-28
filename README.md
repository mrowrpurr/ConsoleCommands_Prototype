![Custom Console Commands](Images/Logo.png)

---

> _Thanks to milzschnitte for reverse engineering the Console menu value locations_

---

## Main API:

```psc
Event OnInit()
  RegisterForModEvent(CustomConsoleCommands.RegisterCommand("Gold"), "OnGoldCommand")
EndEvent

; Usage:
;   gold 42
Event OnGoldCommand(string eventName, string argument, float numArg, Form sender)
    Form gold = Game.GetForm(0xf)
    int amount = argument as int
    if amount
      Game.GetPlayer().AddItem(gold, amount)
    endIf
EndEvent
```
