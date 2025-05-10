#!mainFile "../main.opy"

enum WIDOWMAKER_SI:
  LAST_HEADSHOT = 0
  SILK_WEB = 1
  PF_COOLDOWN = 2
  PF_CHARGES = 3

rule "[Widowmaker] Talent texts":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER

  wait(1) # waiting for the previous hero to clear hero data
  # todo: debug
  eventPlayer.state[SI.TALENTS_COUNT] = 7
  eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] = true
  eventPlayer.talents[TI.WIDOWMAKER_FALLING_STARS] = true
  eventPlayer.talents[TI.WIDOWMAKER_SILK_WEB] = true
  eventPlayer.talents[TI.WIDOWMAKER_FELT_MORE_ALIVE] = true
  eventPlayer.talents[TI.WIDOWMAKER_BRAISER_DE_SOIE] = true
  eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] = true
  eventPlayer.talents[TI.WIDOWMAKER_TRACKER_VENOM] = true

  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = 3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fgA686ABFF>Widowmaker</fg>:\n
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
  waitUntil(eventPlayer.getHero() != Hero.WIDOWMAKER, INFINITY)
  clearHeroInfo()

# Party Favours: Gain a second hook charge
rule "[Widowmaker] Party Favours":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER
  
  hudText(
    eventPlayer if not eventPlayer.state[SI.IS_TALENTS_HUD_OPENNED] else null,
    null,
    "{0}{1} Next Charge in: {2}".format(ABILITI_TEXT_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ABILITY_1), floor(eventPlayer.heroState[WIDOWMAKER_SI.PF_COOLDOWN])),
    "{0}{1}".format(ABILITI_TEXT_INTEND, ["□", "<fgFFFFFFFF>■</fg>"][eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES]]),
    HudPosition.TOP,
    2.5,
    null,
    Color.PURPLE,
    Color.VIOLET
  )
  eventPlayer.HUDs[HI.WIDOWMAKER_PARTY_FAMOURS] = getLastCreatedText()
  eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES] = 1

  waitUntil(eventPlayer.getHero() != Hero.WIDOWMAKER, INFINITY)
  destroyHudText(eventPlayer.HUDs[HI.WIDOWMAKER_PARTY_FAMOURS])


rule "[Widowmaker] Party Favours - Deplete hook charge":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.isUsingAbility1() == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  if not eventPlayer.getAbilityCooldown(Button.ABILITY_1):
    return

  if eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES] > 0:
    eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES] -= 1
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


rule "[Widowmaker] Party Favours - Recharge hook ":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PARTY_FAMOURS] == true
  @Condition eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES] < 1
  @Condition not eventPlayer.getAbilityCooldown(Button.ABILITY_1)
  
  wait(0.4, Wait.ABORT_WHEN_FALSE)
  eventPlayer.heroState[WIDOWMAKER_SI.PF_COOLDOWN] = 12
  while eventPlayer.heroState[WIDOWMAKER_SI.PF_COOLDOWN] > 0:
    wait(1)
    eventPlayer.heroState[WIDOWMAKER_SI.PF_COOLDOWN] -= 1

  eventPlayer.heroState[WIDOWMAKER_SI.PF_CHARGES] += 1
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
  @Condition eventPlayer.talents[TI.WIDOWMAKER_FALLING_STARS] == true
  @Condition eventPlayer.isUsingAbility1() == true
  @Condition eventPlayer.getSpeed() >= 20
  
  while eventPlayer.isUsingAbility1():
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP, Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 30, 1, 4, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 10, 3, 0, 0, 35)
    wait(0.15)
  for eventPlayer.abilTemp1 in range(4):
    wait(0.05)
    createProjectile(Projectile.RAMATTRA_RAVENOUS_VORTEX_SPHERE, eventPlayer, null, Vector.UP + (directionFromAngles(eventPlayer.getHorizontalFacingAngle() + eventPlayer.abilTemp1 * 90, 0)), Relativity.TO_WORLD, ModifyHealth.DAMAGE, Team.2, 30, 1, 3, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION, DynamicEffect.WIDOWMAKER_VENOM_MINE_EXPLOSION_SOUND, 0, 8, 3, 0, 0, 45)

# Silk web: When grappling hook ends, temporarily latch onto any nearby walls
rule "[Widowmaker] Silk web":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isUsingAbility1() == true
  @Condition eventPlayer.talents[TI.WIDOWMAKER_SILK_WEB] == true
  
  waitUntil(not eventPlayer.isUsingAbility1(), INFINITY)
  if not eventPlayer.isHoldingButton(Button.CROUCH):
    return
  if eventPlayer.getAltitude() < 1:
    return

  eventPlayer.heroState[WIDOWMAKER_SI.SILK_WEB] = true
  eventPlayer.applyImpulse(eventPlayer.getVelocity(), -0.01, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setGravity(0)
  eventPlayer.startForcingThrottle(0, 0, 0, 0, 0, 0)

  waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or true in [eventPlayer.hasStatus(Status.HACKED), eventPlayer.hasStatus(Status.KNOCKED_DOWN), eventPlayer.hasStatus(Status.ASLEEP), eventPlayer.hasStatus(Status.FROZEN), eventPlayer.hasStatus(Status.STUNNED)], 10)
  eventPlayer.setGravity(100)
  eventPlayer.stopForcingThrottle()
  eventPlayer.heroState[WIDOWMAKER_SI.SILK_WEB] = false
  playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, Color.WHITE, eventPlayer.getPosition(), 75)


rule "[Widowmaker] Phantom bullets headshot hud":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true

  createInWorldText(
    eventPlayer if eventPlayer.heroState[WIDOWMAKER_SI.LAST_HEADSHOT] > getTotalTimeElapsed() else null,
    "X headshot",
    updateEveryFrame(localPlayer.getEyePosition() + (100 * (0 * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) + ((-0.1 - 0.2) * (directionFromAngles(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 190))) + 3 * localPlayer.getFacingDirection()))),
    0.9,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
    Color.LIGHT_RED,
    SpecVisibility.ALWAYS
  )
  eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_HIT] = getLastCreatedText()

  hudText(
    eventPlayer if eventPlayer.isFiringSecondaryFire() == true else null,
    null,
    "{0}{1} Phantom bullet charge: <fg00FF00FF>100%</fg>".format(ABILITI_TEXT_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE)) if eventPlayer.widowmakerChargeShot == 100 else
    "{0}{1} Phantom bullet charge: {2}%".format(ABILITI_TEXT_INTEND, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE), floor(eventPlayer.widowmakerChargeShot)),
    null,
    HudPosition.TOP,
    2.5,
    null,
    Color.PURPLE,
    null
  )
  eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_CHARGE] = getLastCreatedText()

  waitUntil(not eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] or eventPlayer.getHero() != Hero.WIDOWMAKER, INFINITY)
  destroyInWorldText(eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_HIT])
  destroyHudText(eventPlayer.HUDs[HI.WIDOWMAKER_PHANTOM_BULLET_CHARGE])


# You have to calculate the direction before you shoot. If you do it during the shot, the recoil from the shot can affect the counts
rule "[Widowmaker] Phantom bullets - Aiming through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == false
  @Condition len([player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()]) > 0

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

rule "[Widowmaker] Phantom bullets - damage through walls":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.talents[TI.WIDOWMAKER_PHANTOM_BULLETS] == true
  @Condition eventPlayer.raycast[RI.FACING_DIRECTION] == true

  if eventPlayer.widowmakerChargeShot < 100:
    return

  eventPlayer.temp3 = false
  eventPlayer.temp2 = [player for player in getPlayers(Team.2) if eventPlayer.isInViewAngle(player, WALLHACK_SHOT_IN_VIEW_ANGLE) and player.isAlive()]

  for eventPlayer.temp1 in range(len(eventPlayer.temp2)):
    # If eventPlayer.temp3 == true, it means there's already been a hit through a wall or an enemy. Cancel damage to others if no ultimates are present
    if eventPlayer.temp3 and eventPlayer.isUsingUltimate(): 
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
          300
        )
        if not eventPlayer.temp3:
          eventPlayer.temp3 = eventPlayer.raycast[RI.FACING_DIRECTION]
        eventPlayer.heroState[WIDOWMAKER_SI.LAST_HEADSHOT] = 0.5 + getTotalTimeElapsed() # for headshot message
      else:

        eventPlayer.raycast[RI.SPHERE_POS] = eventPlayer.temp2[eventPlayer.temp1].getPosition() + vect(0, 0.6, 0) # player center shpere
        eventPlayer.raycast[RI.RADIUS] = ZOMBIE_BODY_HITBOX_RADIUS
        rayIntersectionsWithSphere()

        if eventPlayer.raycast[RI.RESULT] == true:
          damage(
            eventPlayer.temp2[eventPlayer.temp1],
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
    eventPlayer.HUDs[HI.WALLHACK_SHOT] = getLastCreatedEntity()
    wait(0.5)
    destroyEffect(eventPlayer.HUDs[HI.WALLHACK_SHOT])
  

rule "[Widowmaker] Felt More Alive":
  @Event eachPlayer
  @Hero widowmaker
  @Team 1
  @Condition eventPlayer.talents[TI.WIDOWMAKER_FELT_MORE_ALIVE] == true
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventPlayer.isInAir() == true
  @Condition eventPlayer.heroState[WIDOWMAKER_SI.SILK_WEB] == false
  
  wait(0.333, Wait.ABORT_WHEN_FALSE)
  eventPlayer.setGravity(30)
  waitUntil(not eventPlayer.isFiringSecondaryFire() or not eventPlayer.isInAir(), INFINITY)
  eventPlayer.setGravity(100)

rule "[Widowmaker] Tracker Venom - widow mines slow and reveal enemy for all":
  @Event playerTookDamage
  @Condition attacker.getCurrentHero() == Hero.WIDOWMAKER
  @Condition attacker.talents[TI.WIDOWMAKER_TRACKER_VENOM] == true
  @Condition eventAbility == Button.ABILITY_2
  
  victim.revealed = REVEAL_DURATION + getTotalTimeElapsed()

  eventPlayer.setMoveSpeed(ZOMBIE_SPEED / 3)
  wait(5)
  eventPlayer.setMoveSpeed(ZOMBIE_SPEED)

rule "[Widowmaker] Baiser De Soie":
  @Event playerDealtDamage
  @Hero widowmaker
  @Condition eventPlayer.talents[TI.WIDOWMAKER_BRAISER_DE_SOIE] == true
  @Condition eventAbility == Button.PRIMARY_FIRE
  @Condition eventAbility == Button.SECONDARY_FIRE

  victim.revealed = REVEAL_DURATION + getTotalTimeElapsed()

rule "[Widowmaker] Phantom bullets - Charge":
  @Event eachPlayer
  @Team 1
  @Hero widowmaker
  @Condition eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == false
  
  eventPlayer.widowmakerChargeShot = 0
  wait(0.27)
  if not ruleCondition:
    return

  chaseAtRate(eventPlayer.widowmakerChargeShot, 100, 100, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == true)
  stopChasingVariable(eventPlayer.widowmakerChargeShot)
  eventPlayer.widowmakerChargeShot = 0
  
  if (eventPlayer.isFiringSecondaryFire() == true and eventPlayer.isFiringPrimaryFire() == true):
    eventPlayer.widowmakerChargeShot = 0
    wait(0.27)
    chaseAtRate(eventPlayer.widowmakerChargeShot, 100, 100, ChaseRateReeval.NONE)
    waitUntil(eventPlayer.isFiringSecondaryFire() == false or eventPlayer.isFiringPrimaryFire() == false)
    stopChasingVariable(eventPlayer.widowmakerChargeShot)
    eventPlayer.widowmakerChargeShot = 0
    goto RULE_START
