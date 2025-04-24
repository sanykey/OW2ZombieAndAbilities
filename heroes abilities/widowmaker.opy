#!mainFile "../main.opy"

# Party Favours: Gain a second hook charge
rule "[Widowmaker] Party Favours":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.isCombatant == true
  
  hudText(eventPlayer, null, "                                                                                   {0} Next Charge in: {1}s".format(abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1), floor(eventPlayer.abilityCountdown)), "                                                          {0}".format(["□ □", "■ □", "■ ■"][eventPlayer.abilityCharges]), HudPosition.TOP, 2.5, null, Color.PURPLE, Color.VIOLET)
  eventPlayer.HUDs[2] = getLastCreatedText()
  eventPlayer.abilityCharges = 1
  waitUntil(not eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] or not eventPlayer.isCombatant, INFINITY)
  destroyHudText(eventPlayer.HUDs[2])
  eventPlayer.setAbility1Enabled(true)


rule "[Widowmaker] Party Favours - Deplete hook charge":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.isUsingAbility1() == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  if not eventPlayer.getAbilityCooldown(Button.ABILITY_1):
    return
  eventPlayer.abilityCharges -= 1
  eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0.5)


rule "[Widowmaker] Party Favours - Recharge hook ":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.abilityCharges < 2
  
  wait(0.4, Wait.ABORT_WHEN_FALSE)
  eventPlayer.abilityCountdown = 10
  while eventPlayer.abilityCountdown > 0:
    wait(1)
    eventPlayer.abilityCountdown -= 1
  eventPlayer.abilityCharges += 1
  if ruleCondition:
    loop()
  wait(0.25)
  if ruleCondition:
    loop()


rule "[Widowmaker] Party Favours - Availability":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.abilityCharges <= 0
  
  eventPlayer.setAbility1Enabled(false)
  waitUntil(eventPlayer.abilityCharges != 0, INFINITY)
  eventPlayer.setAbility1Enabled(true)
  wait(0.25)
  if ruleCondition:
      loop()

# Falling stars: 
rule "[Widowmaker] Falling stars":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_FALLING_STARS] == true
  @Condition eventPlayer.isUsingAbility1() == true
  @Condition eventPlayer.getSpeed() >= 20
  
  while eventPlayer.isUsingAbility1():
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP, Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 60, 1, 4, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 10, 3, 0, 0, 35)
    wait(0.15)
  for eventPlayer.temp1 in range(4):
    wait(0.05)
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP + (directionFromAngles(eventPlayer.getHorizontalFacingAngle() + eventPlayer.temp1 * 90, 0)), Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 60, 1, 3, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 8, 3, 0, 0, 45)

# Silk web: When grappling hook ends, temporarily latch onto any nearby walls
rule "[Widowmaker] Silk web":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.isUsingAbility1() == true
  @Condition eventPlayer.talents[TI.WIDOWMAKER_SILK_WEB] == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0, 0.5)
  if eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0:
    return
  if eventPlayer.getAltitude() < 1:
    return
  eventPlayer.temp1 = eventPlayer.getPosition()
  eventPlayer.applyImpulse(eventPlayer.getVelocity(), -0.01, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setGravity(0)
  eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)
  waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or true in [eventPlayer.hasStatus(Status.HACKED), eventPlayer.hasStatus(Status.KNOCKED_DOWN), eventPlayer.hasStatus(Status.ASLEEP), eventPlayer.hasStatus(Status.FROZEN), eventPlayer.hasStatus(Status.STUNNED)] or distance(eventPlayer.getPosition(), eventPlayer.temp1) > 0.5 or eventPlayer.isHoldingButton(Button.ABILITY_1), 6)
  eventPlayer.setGravity(100)
  eventPlayer.stopForcingThrottle()
  playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 75)


rule "[Widowmaker] Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == false
  @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(getOppositeTeam(eventPlayer.getTeam())), 4) == true

  temp1 = eventPlayer.getPlayerClosestToReticle(Team.2)
  temp2 = raycast(
    eventPlayer.getEyePosition(),
    eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200,
    getAllPlayers(),
    eventPlayer,
    true
  ).getHitPosition()

  temp3 = eventPlayer.getEyePosition() + (normalize(temp2 - eventPlayer.getEyePosition()) * distance(eventPlayer.getEyePosition(), temp1.getEyePosition()))

  wait(0.016)
  if (
    eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(getOppositeTeam(eventPlayer.getTeam())), 3) == false or
    eventPlayer.isFiringSecondaryFire() == false
  ):
    temp1 = false
    temp2 = false
    temp3 = false
    return

  if (eventPlayer.isFiringPrimaryFire() == false):
    loop()

rule "[Widowmaker] Widow ult dmg through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == true
  # @Condition eventPlayer.isUsingUltimate() == true
  # @Condition eventPlayer.isFiringPrimaryFire() == true
  # @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(getOppositeTeam(eventPlayer.getTeam())), 2.5) == true

  eventPlayer.setUltCharge(100)

  destroyEffect(eventPlayer.HUDs[HI.DEBUG])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG2])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG3])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG4])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG5])

  if temp1 == false:
    return

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.RED,
    temp1.getEyePosition() + (temp1.getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
    0.15,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG4] = getLastCreatedEntity()
  wait(0.016)
  # createEffect(
  #   getAllPlayers(),
  #   Effect.SPHERE,
  #   Color.GREEN,
  #   temp1.getPosition() + vect(0, 0.6, 0),
  #   0.7,
  #   EffectReeval.VISIBILITY_AND_COLOR
  # )
  # eventPlayer.HUDs[HI.DEBUG5] = getLastCreatedEntity()
  # wait(0.016)

  if distance(temp3, temp1.getEyePosition() + (temp1.getFacingDirection() + vect(0, 0, -0.5)) * 0.25) <= 0.15:
    smallMessage(eventPlayer, "HEADSHOT!")
  elif distance(temp3, temp1.getPosition() + vect(0, 0.6, 0)) <= 0.7:
    smallMessage(eventPlayer, "SHOT!")

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.YELLOW,
    temp2,
    0.1,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG] = getLastCreatedEntity()
  wait(0.016)

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.BLUE,
    temp3,
    0.1,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG2] = getLastCreatedEntity()

  wait(0.016)
  createBeam(
    getAllPlayers(),
    Beam.BAD,
    eventPlayer.getEyePosition(),
    temp3,
    Color.BLUE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG3] = getLastCreatedEntity()

  damage(
    eventPlayer.getPlayerClosestToReticle(Team.2),
    eventPlayer,
    1
  )

rule "[Widowmaker] Felt More Alive":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_FELT_MORE_ALIVE] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isInAir() == true
  
  wait(0.333, Wait.ABORT_WHEN_FALSE)
  eventPlayer.abilityActive = true
  eventPlayer.setGravity(30)
  waitUntil(not eventPlayer.isFiringSecondaryFire() or not eventPlayer.isInAir(), INFINITY)
  eventPlayer.abilityActive = false
  eventPlayer.setGravity(100)

rule "[Widowmaker] Widow mine slow and reveal for all":
  @Event playerTookDamage
  @Condition eventAbility == Button.ABILITY_2
  @Condition attacker.getCurrentHero() == Hero.WIDOWMAKER
  
  victim.revealed = 5 + getTotalTimeElapsed()

  eventPlayer.setMoveSpeed(30)
  wait(5)
  eventPlayer.setMoveSpeed(ZOMBIE_BASE_MOVE_SPEED)

rule "[Widowmaker] Baiser De Soie":
  @Event playerDealtDamage
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_BRAISER_DE_SOIE] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventAbility == Button.PRIMARY_FIRE

  victim.revealed = 5 + getTotalTimeElapsed()


rule "[Widowmaker] Charge shots":
  @Event eachPlayer
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
  
  wait(0.33)
  if not ruleCondition:
      return
  chaseAtRate(eventPlayer.widowmakerChargeShot, 120, 120, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false)
  eventPlayer.widowmakerChargeShot = 12
