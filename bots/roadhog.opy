#!mainFile "../main.opy"

rule "[Team2 Roadhog] Bot zombie roadhog melee":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  @Condition getPlayersInRadius(eventPlayer, 3, Team.1) == true

  eventPlayer.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed()
  eventPlayer.forceButtonPress(Button.MELEE)

  wait(1)
  if ruleCondition:
    loop()

rule "[Team2 Roadhog] trying to hook":
  @Event eachPlayer
  @Team 2
  @Hero roadhog

  if isInLoS(eventPlayer, eventPlayer.targetPlayer) and distance(eventPlayer, eventPlayer.targetPlayer) < 35:
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ROSE, eventPlayer, 1)
    wait(0.3)
    getPlayersOnHero(Hero.ROADHOG, Team.2).startScalingSize(2, false)
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.25)
    getPlayersOnHero(Hero.ROADHOG, Team.2).startScalingSize(0.7, false)

  wait(3 + (MAX_PLAYERS - getNumberOfPlayers(Team.1)))
  if ruleCondition:
      loop()
