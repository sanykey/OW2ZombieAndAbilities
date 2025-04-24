#!mainFile "../main.opy"

def sqrtNewton():
  @Name "Subroutine: Calculate square root"
  eventPlayer.raycast[RI.SQRT_RESULT] = eventPlayer.raycast[RI.DISC] / 2
  for temp1 in range(5):
    eventPlayer.raycast[RI.SQRT_RESULT] = (eventPlayer.raycast[RI.SQRT_RESULT] + (eventPlayer.raycast[RI.DISC] / eventPlayer.raycast[RI.SQRT_RESULT])) / 2

def rayIntersectionsWithSphere():
  @Name "Subroutine: Сalculate the intersections of the ray with the sphere"

  eventPlayer.raycast[RI.RESULT] = false
  eventPlayer.raycast[RI.A] = (
    (eventPlayer.raycast[RI.FACING_DIRECTION].x * eventPlayer.raycast[RI.FACING_DIRECTION].x) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].y * eventPlayer.raycast[RI.FACING_DIRECTION].y) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].z * eventPlayer.raycast[RI.FACING_DIRECTION].z)
  )

  eventPlayer.raycast[RI.XPXS] = eventPlayer.getEyePosition().x - eventPlayer.raycast[RI.SPHERE_POS].x
  eventPlayer.raycast[RI.YPYS] = eventPlayer.getEyePosition().y - eventPlayer.raycast[RI.SPHERE_POS].y
  eventPlayer.raycast[RI.ZPYS] = eventPlayer.getEyePosition().z - eventPlayer.raycast[RI.SPHERE_POS].z

  eventPlayer.raycast[RI.B] = 2 * (
    (eventPlayer.raycast[RI.FACING_DIRECTION].x * eventPlayer.raycast[RI.XPXS]) +
    (eventPlayer.raycast[RI.FACING_DIRECTION].y * eventPlayer.raycast[RI.YPYS]) + 
    (eventPlayer.raycast[RI.FACING_DIRECTION].z * eventPlayer.raycast[RI.ZPYS])
  )

  eventPlayer.raycast[RI.C] = (
    (eventPlayer.raycast[RI.XPXS] * eventPlayer.raycast[RI.XPXS]) +
    (eventPlayer.raycast[RI.YPYS] * eventPlayer.raycast[RI.YPYS]) +
    (eventPlayer.raycast[RI.ZPYS] * eventPlayer.raycast[RI.ZPYS]) -
    (eventPlayer.raycast[RI.RADIUS] * eventPlayer.raycast[RI.RADIUS])
  )

  eventPlayer.raycast[RI.DISC] = (eventPlayer.raycast[RI.B] * eventPlayer.raycast[RI.B]) - (4 * eventPlayer.raycast[RI.A] * eventPlayer.raycast[RI.C])

  if eventPlayer.raycast[RI.DISC] < 0:
    return
  
  sqrtNewton()

  if (((eventPlayer.raycast[RI.B] * -1) - eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])) >= 0:
    eventPlayer.raycast[RI.RESULT] = true
  elif (((eventPlayer.raycast[RI.B] * -1) + eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])) >= 0:
    eventPlayer.raycast[RI.RESULT] = true

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
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP, Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 30, 1, 4, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 10, 3, 0, 0, 35)
    wait(0.15)
  for eventPlayer.temp1 in range(4):
    wait(0.05)
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP + (directionFromAngles(eventPlayer.getHorizontalFacingAngle() + eventPlayer.temp1 * 90, 0)), Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 30, 1, 3, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 8, 3, 0, 0, 45)

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


# You have to calculate the direction before you shoot. If you do it during the shot, the recoil from the shot can affect the counts
rule "[Widowmaker] Phantom bullets - Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == false
  @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 4) == true

  eventPlayer.raycast[RI.FACING_DIRECTION] = eventPlayer.getFacingDirection()
  wait(0.016)
  if (
    eventPlayer.isFiringSecondaryFire() == false or
    eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 4) == false
  ):
    eventPlayer.raycast[RI.FACING_DIRECTION] = false
    return

  if (eventPlayer.isFiringPrimaryFire() == true):
    return
  loop()

rule "[Widowmaker] Phantom bullets - damage through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 4) == true

  eventPlayer.setUltCharge(100)
  destroyEffect(eventPlayer.HUDs[HI.DEBUG])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG2])
  destroyEffect(eventPlayer.HUDs[HI.DEBUG3])

  if eventPlayer.raycast[RI.FACING_DIRECTION] == false:
    smallMessage(eventPlayer, "FAIL")

  temp1 = eventPlayer.getPlayerClosestToReticle(Team.2)

  createBeam(
    getAllPlayers(),
    Beam.BAD,
    eventPlayer.getEyePosition(),
    eventPlayer.getEyePosition() + eventPlayer.raycast[RI.FACING_DIRECTION] * 200,
    Color.BLUE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG] = getLastCreatedEntity()
  wait(0.016)
  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.YELLOW,
    temp1.getPosition() + vect(0, 0.6, 0),
    ZOMBIE_BODY_HITBOX_RADIUS,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG2] = getLastCreatedEntity()
  wait(0.016)
  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.RED,
    temp1.getEyePosition() + (temp1.getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
    ZOMBIE_HEAD_HITBOX_RADIUS,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  eventPlayer.HUDs[HI.DEBUG3] = getLastCreatedEntity()


  eventPlayer.raycast[RI.SPHERE_POS] = temp1.getEyePosition() + (temp1.getFacingDirection() + vect(0, 0, -0.5)) * 0.25 # headshot shpere
  eventPlayer.raycast[RI.RADIUS] = ZOMBIE_HEAD_HITBOX_RADIUS
  rayIntersectionsWithSphere()

  if eventPlayer.raycast[RI.RESULT] == true:
    smallMessage(eventPlayer, "HEAD SHOT!")
    return

  eventPlayer.raycast[RI.SPHERE_POS] = temp1.getPosition() + vect(0, 0.6, 0) # player center shpere
  eventPlayer.raycast[RI.RADIUS] = ZOMBIE_BODY_HITBOX_RADIUS
  rayIntersectionsWithSphere()

  if eventPlayer.raycast[RI.RESULT] == true:
    smallMessage(eventPlayer, "BODY SHOT!")
    return

  smallMessage(eventPlayer, "MISS!")

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
