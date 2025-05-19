#!mainFile "../main.opy"

rule "Create [Team2 Roadhog] bot":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  
  eventPlayer.startForcingName("Zombie catcher")
  eventPlayer.startScalingSize(0.7, false)

rule "[Team2 Roadhog] trying to hook":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  @Condition eventPlayer.isAlive()

  if (
    eventPlayer.targetPlayer0.isInvisible < getTotalTimeElapsed() and
    isInLoS(eventPlayer, eventPlayer.targetPlayer0, BarrierLos.BLOCKED_BY_ENEMY_BARRIERS) and
    distance(eventPlayer, eventPlayer.targetPlayer0) < 35
  ):
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
    eventPlayer.startFacing(
      directionTowards(
        eventPlayer.getEyePosition(),
        eventPlayer.targetPlayer0.getEyePosition()
      ), 400
    )
    wait(0.3)
    getPlayersOnHero(Hero.ROADHOG, Team.2).startScalingSize(2, false)
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.25)
    getPlayersOnHero(Hero.ROADHOG, Team.2).startScalingSize(0.7, false)
    eventPlayer.stopFacing()

  wait(8)
  if ruleCondition:
      loop()
