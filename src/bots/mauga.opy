#!mainFile "../main.opy"

rule "Create [Team2 Mauga] bot":
  @Condition roundNumber >= 1 and not isBotsDisabled
  wait(3)
  waitUntil(getPlayersInSlot(MAX_ZOMBIES - 2, Team.2).isAlive(), INFINITY)
  createDummy(Hero.MAUGA, Team.2, MAX_ZOMBIES - 2, random.choice(spawnPointsList))
  wait(0.1)
  getPlayersInSlot(MAX_ZOMBIES - 2, Team.2).startForcingName("Zombie Cha")
  # getPlayersInSlot(MAX_ZOMBIES - 2, Team.2).startScalingSize(0.7, false)


rule "[Team2 Mauga] Charger":
  @Event eachPlayer
  @Team 2
  @Hero mauga
  @Condition eventPlayer.targetPlayer
  @Condition not eventPlayer.hasBadStatus
  @Condition eventPlayer.isOnGround()
  @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
  @Condition not eventPlayer.isUsingAbility1()
  @Condition abs(
    angleBetweenVectors(
      eventPlayer.getFacingDirection(),directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer.getEyePosition())
    )
  ) < 35
  @Condition (
    distance(eventPlayer, eventPlayer.targetPlayer) < 5 or
    verticalAngleOfDirection(directionTowards(eventPlayer, eventPlayer.targetPlayer)) > -35
  )
  
  wait(0.25, Wait.ABORT_WHEN_FALSE)
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(), 
      eventPlayer.targetPlayer.getEyePosition()
    ), 
    1500
  )
  wait(0.1)
  # eventPlayer.startThrottleInDirection(vect(0, 0, -1), 0.35, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)

  #Charger walk backwards duration
  # for eventPlayer.pNoCooldownsCount_bCount2 in range(0, 1, 0.064):
  #   if eventPlayer.hasBadStatus or eventPlayer.isDead():
  #     eventPlayer.abilState0 = false
  #     async(restoreDefaultFacingMovement, AsyncBehavior.NOOP)
  #     return
  #   wait(0.064)

  eventPlayer.startThrottleInDirection(
    directionTowards(eventPlayer.getPosition(), eventPlayer.targetPlayer.getPosition()),
    0.65,
    Relativity.TO_WORLD,
    Throttle.REPLACE_EXISTING,
    ThrottleReeval.NONE
  )
  eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  #Charge End

  waitUntil(not eventPlayer.isUsingAbility1(), 2)
  eventPlayer.stopThrottleInDirection()
  eventPlayer.stopFacing()
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  # eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)


rule "[Team2 Mauga] Charger knockback":
  @Event playerDealtDamage
  @Team 2
  @Hero mauga
  @Condition eventAbility == Button.ABILITY_1
  
  if not eventPlayer.isUsingAbility1():
      return
  eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)