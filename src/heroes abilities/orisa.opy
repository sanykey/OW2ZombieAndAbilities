#!mainFile "../main.opy"

enum ORI_I:
  HALT_BEAM_0
  HALT_BEAM_1
  HALT_BEAM_2
  HALT_BEAM_3
  HALT_BEAM_4
  HALT_PROJECTILE
  HALT_HUD
  BARRIER_LANDING_EFFECT
  BARRIER_CHECK_BACK_EFFECT
  BARRIER_CHECK_FORWARD_EFFECT

#!define ORISA_HALT_MAX_DISTANCE 100
#!define ORISA_HALT_PROJECTILE_SPEED 25
#!define ORISA_HALT_PULL_RADIUS 10
#!define ORISA_HALT_PULL_STRENGTH 18
#!define ORISA_HALT_CD 8
#!define ORISA_BARRIER_BALLISTIC_SPEED 25
#!define ORISA_BARRIER_BALLISTIC_GRAVITY 9.84
#!define ORISA_BARRIER_BALLISTIC_STEP 0.08
#!define ORISA_BARRIER_BALLISTIC_MAX_TIME 10
#!define ORISA_BARRIER_CHECK_HEIGHT 3
#!define ORISA_BARRIER_CHECK_SCAN_RANGE 2.25
#!define ORISA_BARRIER_CHECK_SCAN_STEP 0.1
#!define ORISA_BARRIER_CHECK_MAX_GAP 2.4
#!define ORISA_BARRIER_CHECK_MIN_GAP 0.2
#!define ORISA_BARRIER_CHECK_GAP_SCALE 0.5

def ClearOrisaBeamsSub():
  @Name "ClearOrisaBeamsSub"
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_BEAM_0])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_BEAM_1])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_BEAM_2])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_BEAM_3])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_BEAM_4])

rule "[Orisa] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.ORISA
  #!optimizeForSize

  wait(1) # waiting for the previous hero to clear hero data
  setHeroInfoText0(f"<fg458b42FF>Orisa</fg>:\n
  Perk <txD359> <fg458b42FF>Protective barrier</fg>:
      - Pushes back enemies and takes damage on contact.\n\n
  <txD358> NEW! <fg458b42FF>Halt</fg>:
      - Double press <fgdb9342FF>Melee</fg> to launch a projectile forward.
      - Press <fgdb9342FF>Interact</fg> or <fgdb9342FF>Melee</fg> again or collide with a wall to detonate it.
      - Detonation pulls nearby enemies to the projectile.\n\n
  ", -3)

  eventPlayer.abilityCDHud(
    "{}<txD358> Halt: {}".format(
      ABILITI_TEXT_INTEND,
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>Ready</fg> <fg94a0a544>(double [{}])</fg>".format(inputBindingString(Button.MELEE))
    ),
    eventPlayer.heroEffectsIds[ORI_I.HALT_HUD]
  )

  createProjectileEffect(
    getPlayers(Team.1) if eventPlayer.abilState0 else null,
    Projectile.ORB,
    eventPlayer,
    updateEveryFrame(eventPlayer.abilPos0),
    vect(0, 0, 0)
  )
  eventPlayer.heroEffectsIds[ORI_I.HALT_PROJECTILE] = getLastCreatedEntity()
  createEffect(
    getPlayers(Team.1) if eventPlayer.abilPos4 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
    Effect.SPHERE,
    Color.LIME_GREEN,
    updateEveryFrame(eventPlayer.abilPos4),
    0.25,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[ORI_I.BARRIER_LANDING_EFFECT] = getLastCreatedEntity()
  createEffect(
    getPlayers(Team.1) if eventPlayer.abilPos2 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
    Effect.SPHERE,
    Color.BLUE,
    updateEveryFrame(eventPlayer.abilPos2),
    0.08,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_BACK_EFFECT] = getLastCreatedEntity()
  createEffect(
    getPlayers(Team.1) if eventPlayer.abilPos3 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
    Effect.SPHERE,
    Color.BLUE,
    updateEveryFrame(eventPlayer.abilPos3),
    0.08,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_FORWARD_EFFECT] = getLastCreatedEntity()

  waitUntil(eventPlayer.getHero() != Hero.ORISA, INFINITY)
  clearHeroInfoSub()
  destroyHudText(eventPlayer.heroEffectsIds[ORI_I.HALT_HUD])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_PROJECTILE])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_LANDING_EFFECT])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_BACK_EFFECT])
  destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_FORWARD_EFFECT])
  ClearOrisaBeamsSub()


rule "[Orisa] Orisa gains a health pool when another player attaches to her":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.attach2p[Attach2P.CHILD]
  
  eventPlayer.addHealthPool(Health.NORMAL, eventPlayer.attach2p[Attach2P.CHILD].getMaxHealth() / 4, true, false)
  eventPlayer.attach2p[Attach2P.HEALTH_POOL] = getLastCreatedHealthPool()

  waitUntil(not entityExists(eventPlayer.attach2p[Attach2P.CHILD]), INFINITY)
  removeHealthPool(eventPlayer.attach2p[Attach2P.HEALTH_POOL])
  eventPlayer.attach2p = []


# abilState0 - halt projectile active
# abilState1 - halt detonation requested
# abilPos0   - halt projectile position
# abilPos1   - halt projectile start position
# abilDir0   - halt projectile direction
rule "[Orisa] Launch Halt projectile":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  @Condition not eventPlayer.abilState0
  

  if eventPlayer.abilityCD:
    return

  # double press melee
  waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), 0.3)
  if eventPlayer.isHoldingButton(Button.MELEE):
    return
  waitUntil(eventPlayer.isHoldingButton(Button.MELEE), 0.3)
  if not eventPlayer.isHoldingButton(Button.MELEE):
    return

  eventPlayer.abilState0 = getTotalTimeElapsed() + 0.4
  eventPlayer.abilState1 = false
  eventPlayer.abilDir0 = normalize(eventPlayer.getFacingDirection())
  eventPlayer.abilPos0 = eventPlayer.getEyePosition() + eventPlayer.abilDir0 * 1.5
  eventPlayer.abilPos1 = eventPlayer.abilPos0
  stopChasingVariable(eventPlayer.abilPos0)
  chaseAtRate(
    eventPlayer.abilPos0,
    eventPlayer.abilPos0 + eventPlayer.abilDir0 * ORISA_HALT_MAX_DISTANCE,
    ORISA_HALT_PROJECTILE_SPEED
  )


rule "[Orisa] Request Halt detonation":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.abilState0
  @Condition (eventPlayer.isHoldingButton(Button.MELEE) and eventPlayer.abilState0 < getTotalTimeElapsed()) or eventPlayer.isHoldingButton(Button.INTERACT)

  eventPlayer.abilState1 = true

rule "[Orisa] Detonate Halt projectile":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.abilState0
  @Condition (
    eventPlayer.abilState1 or
    distance(
      eventPlayer.abilPos0,
      raycast(eventPlayer.abilPos0, eventPlayer.abilPos0 + eventPlayer.abilDir0 * 2, null, eventPlayer, true).getHitPosition()
    ) <= 1 or
    distance(eventPlayer.abilPos1, eventPlayer.abilPos0) >= ORISA_HALT_MAX_DISTANCE
  )
  #!optimizeForSize

  stopChasingVariable(eventPlayer.abilPos0)
  playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION, Color.TEAM_1, eventPlayer.abilPos0, 25)
  playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION_SOUND, Color.WHITE, eventPlayer.abilPos0, 150)
  wait(0.45)

  eventPlayer.list0 = getPlayersInRadius(
    eventPlayer.abilPos0,
    ORISA_HALT_PULL_RADIUS,
    Team.ZOMBIES,
    LosCheck.SURFACES_AND_ALL_BARRIERS
  )
  eventPlayer.list0 = sorted(
    eventPlayer.list0,
    lambda player: distance(eventPlayer.abilPos0, player) * -1
  )

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  for I in range(len(eventPlayer.list0)):
    eventPlayer.list0[I].applyImpulse(
      directionTowards(eventPlayer.list0[I].getPosition(), eventPlayer.abilPos0),
      ORISA_HALT_PULL_STRENGTH,
      Relativity.TO_WORLD,
      Impulse.CANCEL_CONTRARY_MOTION
    )
    eventPlayer.list0[I].setStatusEffect(eventPlayer, Status.ROOTED, 0.7)

    if I < 5:
      createBeam(
        getPlayers(Team.PLAYERS),
        Beam.BAD,
        eventPlayer.abilPos0,
        eventPlayer.list0[evalOnce(I)],
        Color.LIME_GREEN,
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
      )
      eventPlayer.heroEffectsIds[I] = getLastCreatedEntity()

  wait(0.35)
  ClearOrisaBeamsSub()

  eventPlayer.abilityCD = ORISA_HALT_CD
  eventPlayer.abilState0 = false

rule "[orisa] Use Barrier or Javelin spin":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isUsingAbility2()

  wait(0.13)
  if eventPlayer.isUsingAbility2(): # it is Javelin spin
    while eventPlayer.isUsingAbility2() and eventPlayer.isInAir():
      eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), 6, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
      wait(0.1)

  else: # it is Barrier
    eventPlayer.tmp0 = verticalAngleOfDirection(eventPlayer.getFacingDirection()) * -1
    if eventPlayer.tmp0 < -89:
      eventPlayer.tmp0 = -90
    elif eventPlayer.tmp0 > 89:
      eventPlayer.tmp0 = 90

    eventPlayer.isActiveBarrier = false
    eventPlayer.abilState2 = false
    eventPlayer.abilState3 = false
    eventPlayer.abilPos4 = eventPlayer.getEyePosition()
    eventPlayer.abilPos2 = false
    eventPlayer.abilPos3 = false
    eventPlayer.abilDir1 = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), 0)
    eventPlayer.tmp1 = ORISA_BARRIER_BALLISTIC_SPEED * cosDeg(eventPlayer.tmp0)
    eventPlayer.tmp2 = ORISA_BARRIER_BALLISTIC_SPEED * sinDeg(eventPlayer.tmp0)
    eventPlayer.asyncI0 = 0

    while eventPlayer.asyncI0 <= ORISA_BARRIER_BALLISTIC_MAX_TIME:
      eventPlayer.abilPos2 = (
        eventPlayer.getEyePosition()
        + eventPlayer.abilDir1 * eventPlayer.tmp1 * eventPlayer.asyncI0
        + Vector.UP * (
          eventPlayer.tmp2 * eventPlayer.asyncI0
          - ((ORISA_BARRIER_BALLISTIC_GRAVITY * (eventPlayer.asyncI0 ** 2)) / 2)
        )
      )

      eventPlayer.abilPos3 = (
        eventPlayer.getEyePosition()
        + eventPlayer.abilDir1 * eventPlayer.tmp1 * (eventPlayer.asyncI0 + ORISA_BARRIER_BALLISTIC_STEP)
        + Vector.UP * (
          eventPlayer.tmp2 * (eventPlayer.asyncI0 + ORISA_BARRIER_BALLISTIC_STEP)
          - ((ORISA_BARRIER_BALLISTIC_GRAVITY * ((eventPlayer.asyncI0 + ORISA_BARRIER_BALLISTIC_STEP) ** 2)) / 2)
        )
      )

      eventPlayer.abilPos4 = raycast(
        eventPlayer.abilPos2,
        eventPlayer.abilPos3,
        getAllPlayers(),
        eventPlayer,
        true
      ).getHitPosition()

      if eventPlayer.abilPos4 != eventPlayer.abilPos3:
        eventPlayer.abilState2 = getTotalTimeElapsed() + eventPlayer.asyncI0 + ORISA_BARRIER_BALLISTIC_STEP
        break

      eventPlayer.asyncI0 += ORISA_BARRIER_BALLISTIC_STEP
      eventPlayer.abilPos4 = eventPlayer.abilPos3

    if not eventPlayer.abilState2:
      eventPlayer.abilState2 = getTotalTimeElapsed() + eventPlayer.asyncI0


rule "[Orisa] Barrier placement check after projectile lands":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition eventPlayer.abilState2
  @Condition eventPlayer.abilState2 <= getTotalTimeElapsed()
  @Condition eventPlayer.abilPos4
  @Condition not eventPlayer.abilState3

  eventPlayer.abilState3 = true
  eventPlayer.tmp1 = eventPlayer.abilPos4 + Vector.UP * ORISA_BARRIER_CHECK_HEIGHT
  eventPlayer.tmp4 = false
  eventPlayer.tmp5 = false
  eventPlayer.tmp0 = ORISA_BARRIER_CHECK_MAX_GAP

  while eventPlayer.tmp0 >= ORISA_BARRIER_CHECK_MIN_GAP:
    eventPlayer.abilPos2 = false
    eventPlayer.abilPos3 = false
    eventPlayer.asyncI0 = ORISA_BARRIER_CHECK_SCAN_RANGE * -1

    while eventPlayer.asyncI0 <= ORISA_BARRIER_CHECK_SCAN_RANGE and not eventPlayer.abilPos2:
      eventPlayer.tmp2 = eventPlayer.tmp1 + eventPlayer.abilDir1 * eventPlayer.asyncI0
      eventPlayer.tmp3 = eventPlayer.tmp2 - eventPlayer.abilDir1 * eventPlayer.tmp0

      if (
        not isInLoS(eventPlayer.tmp3, eventPlayer.tmp2, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
        isInLoS(eventPlayer.tmp3, eventPlayer.tmp2, BarrierLos.PASS_THROUGH_BARRIERS)
      ):
        eventPlayer.abilPos2 = eventPlayer.tmp2
        eventPlayer.abilPos3 = eventPlayer.tmp3

      eventPlayer.asyncI0 += ORISA_BARRIER_CHECK_SCAN_STEP

    if eventPlayer.abilPos2:
      eventPlayer.tmp4 = eventPlayer.abilPos2
      eventPlayer.tmp5 = eventPlayer.abilPos3

    eventPlayer.tmp0 *= ORISA_BARRIER_CHECK_GAP_SCALE

  if not eventPlayer.tmp4:
    eventPlayer.isActiveBarrier = false
    return

  eventPlayer.abilPos2 = eventPlayer.tmp4
  eventPlayer.abilPos3 = eventPlayer.tmp5
  eventPlayer.isActiveBarrier = true
  eventPlayer.barrierDamageFrom = eventPlayer.abilPos3
  eventPlayer.barrierDamageDir = normalize(eventPlayer.abilPos2 - eventPlayer.abilPos3)
