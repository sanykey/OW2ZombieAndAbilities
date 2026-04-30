#!mainFile "../main.opy"
#!optimizeForSize

enum WID_I:
  GRAPPLING_HOOK_HUD
  WALLHACK_SHOT_BEAM
  WALLHACK_SHOT_CHARGE_HUD
  WALLHACK_SHOT_HIT_HUD

rule "[Widowmaker] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER

  wait(1) # waiting for the previous hero to clear hero data

  # Hero info:
  setHeroInfoText0(
    f"{heroIcon(Hero.WIDOWMAKER)} <fgA686ABFF>Widowmaker</fg>:\n
    {abilityIconString(Hero.WIDOWMAKER, Button.PRIMARY_FIRE)} <fgA686ABFF>Widow's Kiss</fg>:
        - Scoped shots reveals enemies ({REVEAL_DURATION} seconds).
        - Fully charged scoped shots pierce through walls and one enemy.
        - Improved aerial scoping control.\n\n
    {abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1)} <fgA686ABFF>Grappling Hook</fg>:
        - Gain a second hook charge.
        - Drop venom grenades while grappling.
        - Hold the crouch button at the end of a grapple to briefly cling to nearby walls.\n\n
    {abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_2)} <fgA686ABFF>Venom Mine</fg>:
        - Slows and reveals enemies hit for {REVEAL_DURATION} seconds.\n\n
    ", 3
  )

  # Grappling Hook charges hud
  hudText(
    eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
    null,
    "{}{} Next Charge in: {}".format(
      ABILITI_TEXT_INTEND, 
      abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1),
      floor(eventPlayer.abilityCD)
    ),
    "{0}{1}".format(ABILITI_TEXT_INTEND, ["□", "<fgFFFFFFFF>■</fg>"][eventPlayer.heroState1]),
    HudPosition.TOP,
    2.5,
    null,
    Color.PURPLE,
    Color.VIOLET
  )
  eventPlayer.heroEffectsIds[WID_I.GRAPPLING_HOOK_HUD] = getLastCreatedText()

  eventPlayer.heroState1 = 1 # Grappling Hook charges

  # Wallhack huds
  createInWorldText(
    eventPlayer if eventPlayer.heroState3 > getTotalTimeElapsed() else null,
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
    ) if eventPlayer.heroState2 == 100 else
    "{0}{1} Phantom bullet charge: {2}%".format(
      ABILITI_CHARGES_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), floor(eventPlayer.heroState2)
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

  clearHeroInfoSub()


# rule "[Widowmaker] Deplete hook charge":
#   @Event eachPlayer
#   @Hero widowmaker
#   @Team 1
#   @Condition eventPlayer.isUsingAbility1()
  
#   waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
#   if not eventPlayer.getAbilityCooldown(Button.ABILITY_1):
#     return

#   if eventPlayer.heroState1 > 0:
#     eventPlayer.heroState1 -= 1
#     eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


# rule "[Widowmaker] Recharge hook":
#   @Event eachPlayer
#   @Hero widowmaker
#   @Team 1
#   @Condition eventPlayer.heroState1 < 1
#   @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  
#   wait(0.4, Wait.ABORT_WHEN_FALSE)

#   eventPlayer.abilityCD = 12
#   waitUntil(not eventPlayer.abilityCD, 12)

#   eventPlayer.heroState1 += 1
#   if ruleCondition:
#     loop()
#   wait(0.25)
#   if ruleCondition:
#     loop()

# # Falling stars: 
# rule "[Widowmaker] Falling stars":
#   @Event eachPlayer
#   @Hero widowmaker
#   @Team 1
#   @Condition eventPlayer.isUsingAbility1()
#   @Condition eventPlayer.getSpeed() >= 20
  
#   while eventPlayer.isUsingAbility1():
#     createProjectile(
#       Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE,
#       eventPlayer,
#       null,
#       Vector.UP,
#       Relativity.TO_WORLD,
#       ModifyHealth.DAMAGE,
#       Team.ZOMBIES,
#       30,
#       1,
#       4,
#       DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION,
#       DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND,
#       0,
#       10,
#       3,
#       0,
#       0,
#       35
#     )
#     wait(0.15)
#   for eventPlayer.I0 in range(4):
#     wait(0.05)
#     createProjectile(
#       Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE,
#       eventPlayer,
#       null,
#       Vector.UP + (directionFromAngles(eventPlayer.getHorizontalFacingAngle() + eventPlayer.I0 * 90, 0)),
#       Relativity.TO_WORLD,
#       ModifyHealth.DAMAGE,
#       Team.ZOMBIES,
#       30,
#       1,
#       3,
#       DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND,
#       0,
#       8,
#       3,
#       0,
#       0,
#       45
#     )

# rule "[Widowmaker] When grappling hook ends, latch onto any nearby wall":
#   @Event eachPlayer
#   @Hero widowmaker
#   @Team 1
#   @Condition eventPlayer.isUsingAbility1() == true
  
#   waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
#   if not eventPlayer.isHoldingButton(Button.CROUCH):
#     return
#   if eventPlayer.getAltitude() < 1:
#     return

#   eventPlayer.abilState1 = true # Is hooked to the wall after the grappling hook
#   eventPlayer.applyImpulse(eventPlayer.getVelocity(), -0.01, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
#   eventPlayer.setGravity(0)
#   eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)

#   waitUntil( # todo: hasBadStatus?
#     eventPlayer.isHoldingButton(Button.JUMP) or true in [
#       eventPlayer.hasStatus(Status.HACKED),
#       eventPlayer.isCrowdControlled()
#     ],
#     10
#   )
#   eventPlayer.setGravity(100)
#   eventPlayer.stopForcingThrottle()
#   eventPlayer.abilState1 = false

  # todo: remove or replace:
  # playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 75)


# You have to calculate the direction before you shoot. If you do it during the shot, the recoil from the shot can affect the counts
rule "[Widowmaker] Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire()
  @Condition not eventPlayer.isFiringPrimaryFire()
  @Condition eventPlayer.heroState2 >= 100
  @Condition any([
    player for player in getLivingPlayers(Team.ZOMBIES) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE)
  ])
  
  # Facing direction before shooting. Saving this variable because aim shifts due to recoil:
  eventPlayer.heroState0 = eventPlayer.getFacingDirection() 

  wait()
  if (
    not eventPlayer.isFiringSecondaryFire() or
    eventPlayer.heroState2 < 100 or
    not eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES), WALLHACK_SHOT_IN_VIEW_ANGLE)
  ):
    eventPlayer.heroState0 = false
    return

  if (eventPlayer.isFiringPrimaryFire()):
    return
  loop()

rule "[Widowmaker] damage through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.heroState0 == true

  # rule triggers only when the weapon is fully charged
  if eventPlayer.heroState2 < 100:
    return

  # determine the target that received direct damage
  tmp2 = raycast(
    eventPlayer.getEyePosition(),
    eventPlayer.getEyePosition() + eventPlayer.heroState0 * 200,
    getPlayers(Team.ZOMBIES),
    eventPlayer,
    true
  ).getPlayerHit()

  tmp3 = false
  list0 = [
    player for player in getPlayers(Team.ZOMBIES) if player.isAlive() and eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE)
  ]

  for I in range(len(list0)):
    # If true, it means there's already been a hit through a wall or an enemy. Cancel damage to others if no widowmaker's ultimate are present:
    if not eventPlayer.isUsingUltimate() and tmp3: 
      break

    if tmp2 == list0[I]: # a direct hit prevents wall penetration damage for this target
      # do nothing

    else: # Check for headshot through obstacles 
      eventPlayer.calcRayIntersectsSphere(
        eventPlayer.heroState0,
        list0[I].getEyePosition() + (list0[I].getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
        ZOMBIE_HEAD_HITBOX_RADIUS
      )

      if subroutineResult:
        damage(
          list0[I],
          eventPlayer,
          300
        )
        if not tmp3:
          # Store hit info to show the effect and prevent redundant penetrations
          tmp3 = eventPlayer.heroState0
        eventPlayer.heroState3 = 0.5 + getTotalTimeElapsed() # Wallhack shot last headshot time for headshot message
      else:
        # Check for bodyshot through obstacles
        eventPlayer.calcRayIntersectsSphere(
          eventPlayer.heroState0,
          list0[I].getPosition() + vect(0, 0.6, 0),
          ZOMBIE_BODY_HITBOX_RADIUS
        )

        if subroutineResult:
          damage(
            list0[I],
            eventPlayer,
            120
          )
          if not tmp3:
            # Store hit info to show the effect and prevent redundant penetrations
            tmp3 = eventPlayer.heroState0

  # Create a beam effect if there was a hit through obstacles
  if tmp3:
    createBeam(
      getAllPlayers(),
      Beam.BAD,
      eventPlayer.getEyePosition() + vect(0, -0.45, 0),
      subroutineResult,
      Color.VIOLET,
      EffectReeval.COLOR
    )
    eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_BEAM] = getLastCreatedEntity()
    wait(0.5)
    destroyEffect(eventPlayer.heroEffectsIds[WID_I.WALLHACK_SHOT_BEAM])
  

# rule "[Widowmaker] Felt More Alive":
#   @Event eachPlayer
#   @Hero widowmaker
#   @Team 1
#   @Condition eventPlayer.isFiringSecondaryFire() == true
#   @Condition eventPlayer.isInAir() == true
#   @Condition eventPlayer.abilState1 == false
  
#   wait(0.333, Wait.ABORT_WHEN_FALSE)
#   eventPlayer.setGravity(30)
#   waitUntil(not eventPlayer.isFiringSecondaryFire() or not eventPlayer.isInAir(), INFINITY)
#   eventPlayer.setGravity(100)

rule "[Widowmaker] Wallhack shot charge":
  @Event eachPlayer
  @Team 1
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() and not eventPlayer.isFiringPrimaryFire()
  
  eventPlayer.heroState2 = 0 # Wallhack shot charge
  wait(0.27)
  if not ruleCondition:
    return

  chaseAtRate(eventPlayer.heroState2, 100, 100, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == true)
  stopChasingVariable(eventPlayer.heroState2)
  eventPlayer.heroState2 = 0
  
  if (eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == true):
    eventPlayer.heroState2 = 0
    wait(0.27)
    chaseAtRate(eventPlayer.heroState2, 100, 100, ChaseRateReeval.NONE)
    waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == false)
    stopChasingVariable(eventPlayer.heroState2)
    eventPlayer.heroState2 = 0
    goto RULE_START
