Scriptname CCC_EffectScript extends activemagiceffect  

CCC_PlayerScript property PlayerScript auto
CCC_QuestScript property QuestScript auto

Event OnEffectStart(Actor target, Actor caster)
    Debug.Trace("CALLING PLAYER SCRIPT")
    PlayerScript.StartListeningToConsole()
EndEvent