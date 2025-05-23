#!mainFile "../main.opy"

enum WID_I:
  GRAPPLING_HOOK_HUD
  WALLHACK_SHOT_BEAM
  WALLHACK_SHOT_CHARGE_HUD
  WALLHACK_SHOT_HIT_HUD

# eventPlayer.abilState0 - Grappling Hook charges
# eventPlayer.abilState1 - is hooked to the wall after the grappling hook
# eventPlayer.abilState2 - Wallhack shot charge
# eventPlayer.abilState3 - Wallhack shot last headshot time

rule "[Widowmaker] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER

  wait(1) # waiting for the previous hero to clear hero data

  # Hero info:
  eventPlayer.heroInfoVertFix0 = 3
  eventPlayer.heroInfoText0 = "{} <fgA686ABFF>Widowmaker</fg>:\n
  {} <fgA686ABFF>Widow's Kiss</fg>:
      - Scoped shots reveals enemies ({} seconds).
      - Fully charged scoped shots pierce through walls and one enemy.
      - Improved aerial scoping control.\n\n
  {} <fgA686ABFF>Grappling Hook</fg>:
      - Gain a second hook charge.
      - Drop venom grenades while grappling.
      - Hold the crouch button at the end of a grapple to briefly cling to nearby walls.\n\n
  {} <fgA686ABFF>Venom Mine</fg>:
      - Slows and reveals enemies hit for {} seconds.\n\n
  ".format(
    heroIcon(Hero.WIDOWMAKER),
    abilityIconString(Hero.WIDOWMAKER, Button.PRIMARY_FIRE),
    REVEAL_DURATION,
    abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1),
    abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_2),
    REVEAL_DURATION
  )
  # {} <fgA686ABFF>Infra sight</fg>:
  #     - Allows shots to pierce through multiple enemies and walls.

  # Grappling Hook charges hud
  hudText(
    eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
    null,
    "{}{} Next Charge in: {}".format(
      ABILITI_TEXT_INTEND, 
      abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1),
      floor(eventPlayer.abilityCD)
    ),
    "{0}{1}".format(ABILITI_TEXT_INTEND, ["□", "<fgFFFFFFFF>■</fg>"][eventPlayer.abilState0]),
    HudPosition.TOP,
    2.5,
    null,
    Color.PURPLE,
    Color.VIOLET
  )
  eventPlayer.heroEffectsIds[WID_I.GRAPPLING_HOOK_HUD] = getLastCreatedText()

  eventPlayer.abilState0 = 1

  # Wallhack huds
  createInWorldText(
    eventPlayer if eventPlayer.abilState3 > getTotalTimeElapsed() else null,
    "X headshot",
    updateEveryFrame(
      localPlayer.getEyePosition() + (100 * (0 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + ((-0.1 - 0.2) * (directionFromAngles(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 190))) + 3 * localPlayer.getFacingDirection()))
    ),
    0.9,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
    Color.LIGHT_RED,
    SpecVisibility.ALWAYS
  )
  eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_HIT_HUD] = getLastCreatedText()
  hudText(
    eventPlayer if eventPlayer.isFiringSecondaryFire() == true else null,
    null,
    "{0}{1} Phantom bullet charge: <fg00FF00FF>100%</fg>".format(
      ABILITI_TEXT_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE)
    ) if eventPlayer.abilState2 == 100 else
    "{0}{1} Phantom bullet charge: {2}%".format(
      ABILITI_TEXT_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), floor(eventPlayer.abilState2)
    ),
    null,
    HudPosition.TOP,
    2.5,
    null,
    Color.PURPLE,
    null
  )
  eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_CHARGE_HUD] = getLastCreatedText()

  waitUntil(eventPlayer.getHero() != Hero.WIDOWMAKER, INFINITY)
  destroyHudText(eventPlayer.heroEffectsIds[WID_I.GRAPPLING_HOOK_HUD])
  destroyHudText(eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_CHARGE_HUD])
  destroyInWorldText(eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_HIT_HUD])

  clearHeroInfo()


rule "[Widowmaker] Deplete hook charge":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isUsingAbility1() == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  if not eventPlayer.getAbilityCooldown(Button.ABILITY_1):
    return

  if eventPlayer.abilState0 > 0:
    eventPlayer.abilState0 -= 1
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


rule "[Widowmaker] Recharge hook":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.abilState0 < 1
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  
  wait(0.4, Wait.ABORT_WHEN_FALSE)

  eventPlayer.abilityCD = 12
  waitUntil(not eventPlayer.abilityCD, 12)

  eventPlayer.abilState0 += 1
  if ruleCondition:
    loop()
  wait(0.25)
  if ruleCondition:
    loop()

# Falling stars: 
rule "[Widowmaker] Falling stars":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isUsingAbility1()
  @Condition eventPlayer.getSpeed() >= 20
  
  while eventPlayer.isUsingAbility1():
    createProjectile(
      Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE,
      eventPlayer,
      null,
      Vector.UP,
      Relativity.TO_WORLD,
      ModifyHealth.DAMAGE,
      Team.2,
      30,
      1,
      4,
      DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION,
      DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND,
      0,
      10,
      3,
      0,
      0,
      35
    )
    wait(0.15)
  for eventPlayer.abilTemp1 in range(4):
    wait(0.05)
    createProjectile(
      Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE,
      eventPlayer,
      null,
      Vector.UP + (directionFromAngles(eventPlayer.getHorizontalFacingAngle() + eventPlayer.abilTemp1 * 90, 0)),
      Relativity.TO_WORLD,
      ModifyHealth.DAMAGE,
      Team.2,
      30,
      1,
      3,
      DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND,
      0,
      8,
      3,
      0,
      0,
      45
    )

rule "[Widowmaker] When grappling hook ends, latch onto any nearby wall":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isUsingAbility1() == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  if not eventPlayer.isHoldingButton(Button.CROUCH):
    return
  if eventPlayer.getAltitude() < 1:
    return

  eventPlayer.abilState1 = true
  eventPlayer.applyImpulse(eventPlayer.getVelocity(), -0.01, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setGravity(0)
  eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)

  waitUntil( # todo: hasBadStatus?
    eventPlayer.isHoldingButton(Button.JUMP) or true in [
      eventPlayer.hasStatus(Status.HACKED),
      eventPlayer.hasStatus(Status.KNOCKED_DOWN),
      eventPlayer.hasStatus(Status.ASLEEP),
      eventPlayer.hasStatus(Status.FROZEN),
      eventPlayer.hasStatus(Status.STUNNED)
    ],
    10
  )
  eventPlayer.setGravity(100)
  eventPlayer.stopForcingThrottle()
  eventPlayer.abilState1 = false
  playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 75)


# You have to calculate the direction before you shoot. If you do it during the shot, the recoil from the shot can affect the counts
rule "[Widowmaker] Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == false
  @Condition len([
    player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()
  ]) > 0

  eventPlayer.raycast[RI.FACING_DIRECTION] = eventPlayer.getFacingDirection()
  wait(0.016)
  if (
    eventPlayer.isFiringSecondaryFire() == false or
    eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(Team.2), WALLHACK_SHOT_IN_VIEW_ANGLE) == false
  ):
    eventPlayer.raycast[RI.FACING_DIRECTION] = false
    return

  if (eventPlayer.isFiringPrimaryFire() == true):
    return
  loop()

rule "[Widowmaker] damage through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.raycast[RI.FACING_DIRECTION] == true

  if eventPlayer.abilState2 < 100:
    return

  eventPlayer.temp3 = false
  eventPlayer.list0 = [
    player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()
  ]

  for eventPlayer.temp1 in range(len(eventPlayer.list0)):
    # If eventPlayer.temp3 == true, it means there's already been a hit through a wall or an enemy. Cancel damage to others if no ultimates are present
    if eventPlayer.temp3 and eventPlayer.isUsingUltimate(): 
      break

    if raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + eventPlayer.raycast[RI.FACING_DIRECTION] * 200,
      getAllPlayers(),
      eventPlayer,
      true
    ).getPlayerHit() == eventPlayer.list0[eventPlayer.temp1]:
      # do nothing
    else:
      eventPlayer.raycast[RI.SPHERE_POS] = eventPlayer.list0[eventPlayer.temp1].getEyePosition() + (eventPlayer.list0[eventPlayer.temp1].getFacingDirection() + vect(0, 0, -0.5)) * 0.25 # headshot shpere
      eventPlayer.raycast[RI.RADIUS] = ZOMBIE_HEAD_HITBOX_RADIUS
      rayIntersectionsWithSphere()

      if eventPlayer.raycast[RI.RESULT] == true:
        damage(
          eventPlayer.list0[eventPlayer.temp1],
          eventPlayer,
          300
        )
        if not eventPlayer.temp3:
          eventPlayer.temp3 = eventPlayer.raycast[RI.FACING_DIRECTION]
        eventPlayer.abilState3 = 0.5 + getTotalTimeElapsed() # for headshot message
      else:

        eventPlayer.raycast[RI.SPHERE_POS] = eventPlayer.list0[eventPlayer.temp1].getPosition() + vect(0, 0.6, 0) # player center shpere
        eventPlayer.raycast[RI.RADIUS] = ZOMBIE_BODY_HITBOX_RADIUS
        rayIntersectionsWithSphere()

        if eventPlayer.raycast[RI.RESULT] == true:
          damage(
            eventPlayer.list0[eventPlayer.temp1],
            eventPlayer,
            120
          )
          if not eventPlayer.temp3:
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
    eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_BEAM] = getLastCreatedEntity()
    wait(0.5)
    destroyEffect(eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_BEAM])
  

rule "[Widowmaker] Felt More Alive":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isInAir() == true
  @Condition eventPlayer.abilState1 == false
  
  wait(0.333, Wait.ABORT_WHEN_FALSE)
  eventPlayer.setGravity(30)
  waitUntil(not eventPlayer.isFiringSecondaryFire() or not eventPlayer.isInAir(), INFINITY)
  eventPlayer.setGravity(100)

rule "[Widowmaker] Tracker Venom - widow mines slow and reveal enemy for all":
  @Event playerTookDamage
  @Condition attacker.getCurrentHero() == Hero.WIDOWMAKER
  @Condition eventAbility == Button.ABILITY_2

  victim.setRevealed()

  # todo: fix:
  eventPlayer.setMoveSpeed(ZOMBIE_SPEED / 3)
  wait(5)
  eventPlayer.setMoveSpeed(ZOMBIE_SPEED)

rule "[Widowmaker] Reveal enemies when scoped hit":
  @Event playerDealtDamage
  @Hero widowmaker
  @Condition eventAbility == Button.PRIMARY_FIRE
  @Condition eventAbility == Button.SECONDARY_FIRE

  victim.setRevealed()

rule "[Widowmaker] Wallhack shot charge":
  @Event eachPlayer
  @Team 1
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() and not eventPlayer.isFiringPrimaryFire()
  
  eventPlayer.abilState2 = 0
  wait(0.27)
  if not ruleCondition:
    return

  chaseAtRate(eventPlayer.abilState2, 100, 100, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == true)
  stopChasingVariable(eventPlayer.abilState2)
  eventPlayer.abilState2 = 0
  
  if (eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == true):
    eventPlayer.abilState2 = 0
    wait(0.27)
    chaseAtRate(eventPlayer.abilState2, 100, 100, ChaseRateReeval.NONE)
    waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == false)
    stopChasingVariable(eventPlayer.abilState2)
    eventPlayer.abilState2 = 0
    goto RULE_START
