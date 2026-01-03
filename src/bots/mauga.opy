#!mainFile "../main.opy"

rule "[Team2 Mauga] Add Mauga to Team.2":
  @Condition roundNumber >= ADD_MAUGA_ROUND
  @Condition roundRemainingBots <= 0
  @Condition not getPlayersOnHero(Hero.MAUGA, Team.2)

  GetCandidateForEliteZombieSub() # returns tmp1
  setZombieHero(tmp1, Hero.MAUGA)

rule "[Team2 Mauga] Charge":
  @Event eachPlayer
  @Team 2
  @Hero mauga
  @Condition eventPlayer.zomTarget
  @Condition eventPlayer.isInLoSZombieTarget()
  @Condition eventPlayer.isOnGround()
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  @Condition not eventPlayer.isUsingAbility1()
  @Condition abs(
    angleBetweenVectors(
      eventPlayer.getFacingDirection(),
      directionTowards(eventPlayer.getEyePosition(), eventPlayer.zomTarget.getEyePosition())
    )
  ) < 35
  @Condition (
    eventPlayer.getDistanceToZombieTarget() < 5 or
    verticalAngleOfDirection(directionTowards(eventPlayer, eventPlayer.zomTarget)) > -35
  )
  
  wait(1, Wait.ABORT_WHEN_FALSE)
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(), 
      eventPlayer.zomTarget.getEyePosition()
    ), 
    1500
  )
  wait(0.1)
  eventPlayer.startThrottleInDirection(
    directionTowards(eventPlayer.getPosition(), eventPlayer.zomTarget.getPosition()),
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


rule "[Team2 Mauga] Charge knockback when damage dealt":
  @Event playerDealtDamage
  @Team 2
  @Hero mauga
  @Condition eventAbility == Button.ABILITY_1
  
  if eventPlayer.isUsingAbility1():
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)