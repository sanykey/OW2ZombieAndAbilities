#!mainFile "../main.opy"

rule "[debug] Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    for I in range(wSettingsMaxZombieBots):
      destroyDummy(Team.2, I)
    roundNumber -= 1
    roundRemainingBots = 0
    smallMessage(eventPlayer, "Bots disabled (ctrl + shift + interact)")
  else:
    isBotsDisabled = false
    smallMessage(eventPlayer, "Bots enabled (ctrl + shift + interact)")
