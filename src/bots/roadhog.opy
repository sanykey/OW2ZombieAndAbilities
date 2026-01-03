#!mainFile "../main.opy"

#!define ZOM_ROADHOG_SCALING_SIZE 0.7

rule "[Team2 Roadhog] Add Roadhog to Team.2":
  @Condition roundNumber >= ADD_ROADHOG_ROUND
  @Condition roundRemainingBots <= 0
  @Condition not getPlayersOnHero(Hero.ROADHOG, Team.2)

  GetCandidateForEliteZombieSub() # returns tmp1
  setZombieHero(tmp1, Hero.ROADHOG)

rule "[Team2 Roadhog] init":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.ROADHOG

  wait(0.5)
  eventPlayer.startForcingName("Zombie catcher {}".format(eventPlayer.getSlot()))
  eventPlayer.startScalingSize(ZOM_ROADHOG_SCALING_SIZE, false)

  waitUntil(not ruleCondition, INFINITY)
  eventPlayer.stopScalingSize()

rule "[Team2 Roadhog] trying to hook":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.zomFlyThroughWalls
  @Condition eventPlayer.zomTarget
  @Condition eventPlayer.isInLoSZombieTarget()
  @Condition eventPlayer.getDistanceToZombieTarget() < 35
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)

  wait(1, Wait.ABORT_WHEN_FALSE)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 35)
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(),
      eventPlayer.zomTarget.getEyePosition()
    ), 400
  )
  
  wait(0.7, Wait.ABORT_WHEN_FALSE)
  eventPlayer.startScalingSize(2, false)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  wait(0.25)
  eventPlayer.startScalingSize(ZOM_ROADHOG_SCALING_SIZE, false)
  eventPlayer.stopFacing()
