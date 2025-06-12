#!mainFile "../main.opy"

rule "[debug] Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    for I in range(wSettingsMaxZombieBots):
      destroyDummy(Team.2, I)

    if roundNumber > 0:
      roundNumber -= 1
    roundRemainingBots = 0
    hostPlayer.setMoveSpeed(200)
    smallMessage(eventPlayer, "Bots disabled (ctrl + shift + interact)")
  else:
    isBotsDisabled = false
    hostPlayer.setMoveSpeed(100)
    smallMessage(eventPlayer, "Bots enabled (ctrl + shift + interact)")

rule "[debug] open switch hero hud":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  @Condition eventPlayer.isHoldingButton(Button.RELOAD)

  eventPlayer.purchasedHeroes = getAllHeroes()
  openSwitchHeroHud()
