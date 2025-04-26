#!mainFile "../main.opy"

enum WIDOWMAKER_SI:
  LAST_HEADSHOT = 0

def sqrtNewton():
  @Name "Subroutine: Calculate square root"
  eventPlayer.raycast[RI.SQRT_RESULT] = eventPlayer.raycast[RI.DISC] / 2
  for eventPlayer.temp3 in range(5):
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

  eventPlayer.raycast[RI.T1] = ((eventPlayer.raycast[RI.B] * -1) - eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])
  eventPlayer.raycast[RI.T2] = ((eventPlayer.raycast[RI.B] * -1) + eventPlayer.raycast[RI.SQRT_RESULT]) / (2 * eventPlayer.raycast[RI.A])

  eventPlayer.raycast[RI.C] = 0

  if (eventPlayer.raycast[RI.T1] >= 0 and eventPlayer.raycast[RI.T2] >= 0):
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T1] if eventPlayer.raycast[RI.T1] < eventPlayer.raycast[RI.T2] else eventPlayer.raycast[RI.T2]
  elif eventPlayer.raycast[RI.T1] >= 0:
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T1]
  elif eventPlayer.raycast[RI.T2] >= 0:
    eventPlayer.raycast[RI.C] = eventPlayer.raycast[RI.T2]
  else:
    return

  eventPlayer.raycast[RI.RESULT] = vect(
    eventPlayer.getEyePosition().x + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].x,
    eventPlayer.getEyePosition().y + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].y,
    eventPlayer.getEyePosition().z + eventPlayer.raycast[RI.C] * eventPlayer.raycast[RI.FACING_DIRECTION].z
  )

# Party Favours: Gain a second hook charge
rule "[Widowmaker] Party Favours":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.isCombatant == true
  
  hudText(eventPlayer, null, "                                                                                   {0} Next Charge in: {1}s".format(abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1), floor(eventPlayer.abilityCountdown)), "                                                          {0}".format(["□ □", "■ □", "■ ■"][eventPlayer.abilityCharges]), HudPosition.TOP, 2.5, null, Color.PURPLE, Color.VIOLET)
  eventPlayer.HUDs[HI.WIDOWMAKER_PARTY_FAMOURS] = getLastCreatedText()

  eventPlayer.abilityCharges = 1
  waitUntil(not eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] or not eventPlayer.isCombatant or not eventPlayer.getHero() == Hero.WIDOWMAKER, INFINITY)
  destroyHudText(eventPlayer.HUDs[HI.WIDOWMAKER_PARTY_FAMOURS])
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


rule "[Widowmaker] Phantom bullets headshot marker":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.isCombatant == true

  createInWorldText(
    eventPlayer if eventPlayer.talentState[WIDOWMAKER_SI.LAST_HEADSHOT] > getTotalTimeElapsed() else null,
    "X headshot",
    updateEveryFrame(localPlayer.getEyePosition() + (100 * (0 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + ((-0.1 - 0.2) * (directionFromAngles(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))),
    0.9,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
    Color.LIGHT_RED,
    SpecVisibility.ALWAYS
  )
  eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_HIT] = getLastCreatedText()

  waitUntil(not eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] or not eventPlayer.isCombatant or eventPlayer.getHero() != Hero.WIDOWMAKER, INFINITY)
  destroyHudText(eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_HIT])


# You have to calculate the direction before you shoot. If you do it during the shot, the recoil from the shot can affect the counts
rule "[Widowmaker] Phantom bullets - Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == false
  @Condition len([player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()]) > 0

  eventPlayer.raycast[RI.FACING_DIRECTION] = eventPlayer.getFacingDirection()
  wait(0.016)
  if (
    eventPlayer.isFiringSecondaryFire() == false or
    eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), WALLHACK_SHOT_IN_VIEW_ANGLE) == false
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
  @Condition eventPlayer.raycast[RI.FACING_DIRECTION] == true

  if eventPlayer.widowmakerChargeShot < 9:
    return

  eventPlayer.temp3 = false
  eventPlayer.temp2 = [player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()]

  for eventPlayer.temp1 in range(len(eventPlayer.temp2)):
    if eventPlayer.temp3 == true:
      break
    if raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + eventPlayer.raycast[RI.FACING_DIRECTION] * 200,
      getAllPlayers(),
      eventPlayer,
      true
    ).getPlayerHit() == eventPlayer.temp2[eventPlayer.temp1]:
      # do nothing
    else:
      eventPlayer.raycast[RI.SPHERE_POS] = eventPlayer.temp2[eventPlayer.temp1].getEyePosition() + (eventPlayer.temp2[eventPlayer.temp1].getFacingDirection() + vect(0, 0, -0.5)) * 0.25 # headshot shpere
      eventPlayer.raycast[RI.RADIUS] = ZOMBIE_HEAD_HITBOX_RADIUS
      rayIntersectionsWithSphere()

      if eventPlayer.raycast[RI.RESULT] == true:
        damage(
          eventPlayer.temp2[eventPlayer.temp1],
          eventPlayer,
          30 * eventPlayer.widowmakerChargeShot
        )
        eventPlayer.temp3 = eventPlayer.raycast[RI.FACING_DIRECTION]
        eventPlayer.talentState[WIDOWMAKER_SI.LAST_HEADSHOT] = 0.5 + getTotalTimeElapsed() # for headshot message
      else:

        eventPlayer.raycast[RI.SPHERE_POS] = eventPlayer.temp2[eventPlayer.temp1].getPosition() + vect(0, 0.6, 0) # player center shpere
        eventPlayer.raycast[RI.RADIUS] = ZOMBIE_BODY_HITBOX_RADIUS
        rayIntersectionsWithSphere()

        if eventPlayer.raycast[RI.RESULT] == true:
          damage(
            eventPlayer.temp2[eventPlayer.temp1],
            eventPlayer,
            12 * eventPlayer.widowmakerChargeShot
          )
          eventPlayer.temp3 = eventPlayer.raycast[RI.FACING_DIRECTION]


  if eventPlayer.temp3 == true:
    createBeam(
      getAllPlayers(),
      Beam.BAD,
      eventPlayer.getEyePosition() + vect(0, -0.45, 0),
      eventPlayer.raycast[RI.RESULT],
      Color.VIOLET,
      EffectReeval.COLOR
    )
    eventPlayer.HUDs[HI.WALLHACK_SHOT] = getLastCreatedEntity()
    wait(0.5)
    destroyEffect(eventPlayer.HUDs[HI.WALLHACK_SHOT])
  

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

rule "[Widowmaker] Tracker Venom - widow mines slow and reveal enemy for all":
  @Event playerTookDamage
  @Condition attacker.getCurrentHero() == Hero.WIDOWMAKER
  @Condition attacker.talents[TI.WIDOWMAKER_TRACKER_VENOM] == true
  @Condition eventAbility == Button.ABILITY_2
  
  victim.revealed = 10 + getTotalTimeElapsed()

  eventPlayer.setMoveSpeed(30)
  wait(5)
  eventPlayer.setMoveSpeed(ZOMBIE_BASE_MOVE_SPEED)

rule "[Widowmaker] Baiser De Soie":
  @Event playerDealtDamage
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_BRAISER_DE_SOIE] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventAbility == Button.PRIMARY_FIRE

  victim.revealed = 10 + getTotalTimeElapsed()


rule "[Widowmaker] Charge shots":
  @Event eachPlayer
  @Condition eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == false
  
  eventPlayer.widowmakerChargeShot = 1
  wait(0.27)
  if not ruleCondition:
    return

  chaseAtRate(eventPlayer.widowmakerChargeShot, 10, 10, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == true)
  stopChasingVariable(eventPlayer.widowmakerChargeShot)
  
  if (eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == true):
    eventPlayer.widowmakerChargeShot = 1
    wait(0.27)
    chaseAtRate(eventPlayer.widowmakerChargeShot, 10, 10, ChaseRateReeval.NONE)
    waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == false)
    stopChasingVariable(eventPlayer.widowmakerChargeShot)
    goto RULE_START
