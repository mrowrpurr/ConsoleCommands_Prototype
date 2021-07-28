![Custom Console Commands](Images/Logo.png)

---

> _Thanks to milzschnitte for reverse engineering the Console menu value locations_

---

Utility mod for mod authors.

Makes it easy to create your own custom commands for the ~ Skyrim console.

# Installation

Download manually or using your favorite mod manager.

In your scripts, import `Scripts/Source/

---

**Note:** you cannot run these console commands fro the Main Menu. These commands can only be run from in-game._






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
