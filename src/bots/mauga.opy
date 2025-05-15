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
  @Condition eventPlayer.targetPlayer != null
  @Condition eventPlayer.crowdControlled != true
  @Condition eventPlayer.abilState0 != true
  @Condition eventPlayer.isOnGround()
  @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
  @Condition eventPlayer.isUsingAbility1() == false
  @Condition eventPlayer.getThrottle() != vect(0, 0, 0)
  @Condition abs(angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer.getEyePosition()))) < 35
  @Condition (distance(eventPlayer.getPosition(), eventPlayer.targetPlayer.getPosition()) < 5 or verticalAngleOfDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.targetPlayer.getPosition())) > -35) == true
  
  wait(0.25, Wait.ABORT_WHEN_FALSE)
  eventPlayer.specialFacing = true
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.lastTarget.getEyePosition()), 1500 if eventPlayer.attached else 0 if eventPlayer.crowdControlled else 100)
  eventPlayer.abilState0 = true
  eventPlayer.startThrottleInDirection(vect(0, 0, -1), 0.35, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
  #Charger walk backwards duration
  for eventPlayer.pNoCooldownsCount_bCount2 in range(0, 1, 0.064):
      if eventPlayer.crowdControlled or eventPlayer.isDead():
          eventPlayer.specialFacing = false
          eventPlayer.abilState0 = false
          async(restoreDefaultFacingMovement, AsyncBehavior.NOOP)
          return
      wait(0.064)
  eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.targetPlayer.getPosition() if eventPlayer.botTempValue == null else eventPlayer.botTempValue), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
  eventPlayer.specialFacing = true
  eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)
  eventPlayer.forceButtonPress(Button.ABILITY_1)
  #Charge End
  waitUntil(not eventPlayer.isUsingAbility1(), 2 if eventPlayer in bosses else 3.5)
  eventPlayer.stopThrottleInDirection()
  eventPlayer.stopFacing()
  eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
  eventPlayer.setMoveSpeed(100)
  eventPlayer.specialFacing = false
  eventPlayer.abilState0 = false
  async(restoreDefaultFacingMovement, AsyncBehavior.NOOP)
  waitUntil(not eventPlayer.isUsingAbility1(), 10)
  eventPlayer.setAbilityCooldown(Button.ABILITY_1, 4 if eventPlayer in bosses else 6)


rule "[Team2 Mauga] Charger knockback":
  @Event playerDealtDamage
  @Team 2
  @Hero mauga
  @Condition eventAbility == Button.ABILITY_1
  
  if not eventPlayer.isUsingAbility1():
      return
  eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)