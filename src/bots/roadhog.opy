#!mainFile "../main.opy"

rule "[Team2 Roadhog] Add Roadhog to Team.2":
  @Condition roundNumber > 20
  @Condition roundRemainingBots <= 0
  @Condition not getPlayersOnHero(Hero.ROADHOG, Team.2)

  GetCandidateForEliteZombieSub() # returns tmp1
  setZombieHero(tmp1, Hero.ROADHOG)

rule "Create [Team2 Roadhog] bot":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  wait(1)
  eventPlayer.startForcingName("Zombie catcher {}".format(eventPlayer.getSlot()))
  eventPlayer.startScalingSize(0.7, false)

rule "[Team2 Roadhog] trying to hook":
  @Event eachPlayer
  @Team 2
  @Hero roadhog
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.zombiesfly
  @Condition eventPlayer.target0
  @Condition eventPlayer.isInLoSZombieTarget()
  @Condition eventPlayer.getDistanceToZombieTarget() < 35
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)

  wait(1, Wait.ABORT_WHEN_FALSE)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 35)
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(),
      eventPlayer.target0.getEyePosition()
    ), 400
  )
  
  wait(0.7, Wait.ABORT_WHEN_FALSE)
  eventPlayer.startScalingSize(2, false)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  wait(0.25)
  eventPlayer.startScalingSize(0.7, false)
  eventPlayer.stopFacing()
