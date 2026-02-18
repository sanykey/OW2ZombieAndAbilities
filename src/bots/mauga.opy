#!mainFile "../main.opy"

rule "[ZombieTeam Mauga] Add Mauga to Team.ZOMBIES":
  @Condition roundNumber >= ADD_MAUGA_ROUND
  @Condition roundRemainingBots <= 0
  @Condition not getPlayersOnHero(Hero.MAUGA, Team.ZOMBIES)

  GetCandidateForEliteZombieSub() # returns tmp1
  setZombieHero(tmp1, Hero.MAUGA)

rule "[ZombieTeam Mauga] Charge":
  @Event eachPlayer
  @Team 2
  @Hero mauga
  @Condition eventPlayer.botTarget
  @Condition eventPlayer.isInLoSZombieTarget()
  @Condition eventPlayer.isOnGround()
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  @Condition not eventPlayer.isUsingAbility1()
  @Condition abs(
    angleBetweenVectors(
      eventPlayer.getFacingDirection(),
      directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition())
    )
  ) < 35
  @Condition (
    eventPlayer.getDistanceToZombieTarget() < 5 or
    verticalAngleOfDirection(directionTowards(eventPlayer, eventPlayer.botTarget)) > -35
  )
  
  wait(1, Wait.ABORT_WHEN_FALSE)
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(), 
      eventPlayer.botTarget.getEyePosition()
    ), 
    1500
  )
  wait(0.1)
  eventPlayer.startThrottleInDirection(
    directionTowards(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()),
    0.65,
    Relativity.TO_WORLD,
    Throttle.REPLACE_EXISTING,
    ThrottleReeval.NONE
  )
  eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)
  eventPlayer.forceButtonPress(Button.ABILITY_1)

  #Charge End
  waitUntil(not eventPlayer.isUsingAbility1() or not eventPlayer.isAlive(), 2)
  eventPlayer.stopThrottleInDirection()
  eventPlayer.stopFacing()
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  wait(0.1)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
