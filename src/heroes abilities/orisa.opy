#!mainFile "../main.opy"
#!optimizeForSize

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

# rule "[Orisa] init":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.getHero() == Hero.ORISA

#   wait(1) # waiting for the previous hero to clear hero data
#   setHeroInfoText0(f"<fg458b42FF>Orisa</fg>:\n
#   Perk <txD359> <fg458b42FF>Protective barrier</fg>:
#       - Pushes back enemies and takes damage on contact.\n\n
#   <txD358> NEW! <fg458b42FF>Halt</fg>:
#       - Double press <fgdb9342FF>Melee</fg> to launch a projectile forward.
#       - Press <fgdb9342FF>Interact</fg> or <fgdb9342FF>Melee</fg> again or collide with a wall to detonate it.
#       - Detonation pulls nearby enemies to the projectile.\n\n
#   ", -3)

#   eventPlayer.abilityCDHud(
#     "{}<txD358> Halt: {}".format(
#       ABILITI_TEXT_INTEND,
#       ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>Ready</fg> <fg94a0a544>(double [{}])</fg>".format(inputBindingString(Button.MELEE))
#     ),
#     eventPlayer.heroEffectsIds[ORI_I.HALT_HUD]
#   )

#   createProjectileEffect(
#     getPlayers(Team.1) if eventPlayer.heroState2 else null,
#     Projectile.ORB,
#     eventPlayer,
#     updateEveryFrame(eventPlayer.heroState4),
#     ZeroVectConst
#   )
#   eventPlayer.heroEffectsIds[ORI_I.HALT_PROJECTILE] = getLastCreatedEntity()
#   createEffect(
#     getPlayers(Team.1) if eventPlayer.abilPos4 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
#     Effect.SPHERE,
#     Color.LIME_GREEN,
#     updateEveryFrame(eventPlayer.abilPos4),
#     0.25,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )
#   eventPlayer.heroEffectsIds[ORI_I.BARRIER_LANDING_EFFECT] = getLastCreatedEntity()
#   createEffect(
#     getPlayers(Team.1) if eventPlayer.abilPos2 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
#     Effect.SPHERE,
#     Color.BLUE,
#     updateEveryFrame(eventPlayer.abilPos2),
#     0.08,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )
#   eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_BACK_EFFECT] = getLastCreatedEntity()
#   createEffect(
#     getPlayers(Team.1) if eventPlayer.abilPos3 and eventPlayer.abilState2 and eventPlayer.abilState2 <= getTotalTimeElapsed() else null,
#     Effect.SPHERE,
#     Color.BLUE,
#     updateEveryFrame(eventPlayer.abilPos3),
#     0.08,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )
#   eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_FORWARD_EFFECT] = getLastCreatedEntity()

#   waitUntil(eventPlayer.getHero() != Hero.ORISA, INFINITY)
#   clearHeroInfoSub()
#   destroyHudText(eventPlayer.heroEffectsIds[ORI_I.HALT_HUD])
#   destroyEffect(eventPlayer.heroEffectsIds[ORI_I.HALT_PROJECTILE])
#   destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_LANDING_EFFECT])
#   destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_BACK_EFFECT])
#   destroyEffect(eventPlayer.heroEffectsIds[ORI_I.BARRIER_CHECK_FORWARD_EFFECT])
#   ClearOrisaBeamsSub()


# rule "[Orisa] Orisa gains a health pool when another player attaches to her":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.attach2p[Attach2P.CHILD]
  
#   eventPlayer.addHealthPool(Health.NORMAL, eventPlayer.attach2p[Attach2P.CHILD].getMaxHealth() / 4, true, false)
#   eventPlayer.attach2p[Attach2P.HEALTH_POOL] = getLastCreatedHealthPool()

#   waitUntil(not entityExists(eventPlayer.attach2p[Attach2P.CHILD]), INFINITY)
#   removeHealthPool(eventPlayer.attach2p[Attach2P.HEALTH_POOL])
#   eventPlayer.attach2p = []

# # eventPlayer.heroState0 - halt projectile direction
# # eventPlayer.heroState2 - halt projectile active
# # eventPlayer.heroState3 - halt detonation requested
# # eventPlayer.heroState4 - halt projectile position
# # eventPlayer.heroState5 - halt projectile start position
# rule "[Orisa] Launch Halt projectile":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.isAlive()
#   @Condition eventPlayer.isHoldingButton(Button.MELEE)
#   @Condition not eventPlayer.heroState2
  

#   if eventPlayer.abilityCD:
#     return

#   # double press melee
#   waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), 0.3)
#   if eventPlayer.isHoldingButton(Button.MELEE):
#     return
#   waitUntil(eventPlayer.isHoldingButton(Button.MELEE), 0.3)
#   if not eventPlayer.isHoldingButton(Button.MELEE):
#     return

#   eventPlayer.heroState2 = getTotalTimeElapsed() + 0.4 # halt projectile active
#   eventPlayer.heroState3 = false
#   eventPlayer.heroState0 = normalize(eventPlayer.getFacingDirection()) # halt projectile direction
#   eventPlayer.heroState4 = eventPlayer.getEyePosition() + eventPlayer.heroState0 * 1.5 # halt projectile position
#   eventPlayer.heroState5 = eventPlayer.heroState4 # halt projectile start position
#   stopChasingVariable(eventPlayer.heroState4)
#   chaseAtRate(
#     eventPlayer.heroState4,
#     eventPlayer.heroState4 + eventPlayer.heroState0 * ORISA_HALT_MAX_DISTANCE,
#     ORISA_HALT_PROJECTILE_SPEED
#   )


# rule "[Orisa] Request Halt detonation":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.heroState2
#   @Condition (eventPlayer.isHoldingButton(Button.MELEE) and eventPlayer.heroState2 < getTotalTimeElapsed()) or eventPlayer.isHoldingButton(Button.INTERACT)

#   eventPlayer.heroState3 = true # halt detonation requested

# rule "[Orisa] Detonate Halt projectile":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.heroState2
#   @Condition (
#     eventPlayer.heroState3 or
#     distance(
#       eventPlayer.heroState4,
#       raycast(eventPlayer.heroState4, eventPlayer.heroState4 + eventPlayer.heroState0 * 2, null, eventPlayer, true).getHitPosition()
#     ) <= 1 or
#     distance(eventPlayer.heroState5, eventPlayer.heroState4) >= ORISA_HALT_MAX_DISTANCE
#   )

#   stopChasingVariable(eventPlayer.heroState4)
#   playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION, Color.TEAM_1, eventPlayer.heroState4, 25)
#   playEffect(getAllPlayers(), DynamicEffect.ORISA_HALT_IMPLOSION_SOUND, Color.WHITE, eventPlayer.heroState4, 150)
#   wait(0.45)

#   list0 = getPlayersInRadius(
#     eventPlayer.heroState4,
#     ORISA_HALT_PULL_RADIUS,
#     Team.ZOMBIES,
#     LosCheck.SURFACES_AND_ALL_BARRIERS
#   )
#   list0 = sorted(
#     list0,
#     lambda player: distance(eventPlayer.heroState4, player) * -1
#   )

#   list0.setCrowdControlAttack(eventPlayer)

#   for I in range(len(list0)):
#     list0[I].applyImpulse(
#       directionTowards(list0[I].getPosition(), eventPlayer.heroState4),
#       ORISA_HALT_PULL_STRENGTH,
#       Relativity.TO_WORLD,
#       Impulse.CANCEL_CONTRARY_MOTION
#     )
#     list0[I].setStatusEffect(eventPlayer, Status.ROOTED, 0.7)

#     if I < 5:
#       createBeam(
#         getPlayers(Team.PLAYERS),
#         Beam.BAD,
#         eventPlayer.heroState4,
#         list0[evalOnce(I)],
#         Color.LIME_GREEN,
#         EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#       )
#       eventPlayer.heroEffectsIds[I] = getLastCreatedEntity()

#   wait(0.35)
#   ClearOrisaBeamsSub()

#   eventPlayer.abilityCD = ORISA_HALT_CD
#   eventPlayer.heroState2 = false

# rule "[orisa] Use Barrier or Javelin spin":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.isUsingAbility2()

#   wait(0.13)
#   if eventPlayer.isUsingAbility2(): # it is Javelin spin
#     while eventPlayer.isUsingAbility2() and eventPlayer.isInAir():
#       eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), 6, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
#       wait(0.1)

#   else: # it is Barrier
#     tmp0 = verticalAngleOfDirection(eventPlayer.getFacingDirection()) * -1
#     if tmp0 < -89:
#       tmp0 = -90
#     elif tmp0 > 89:
#       tmp0 = 90

#     eventPlayer.abilState2 = false
#     eventPlayer.abilState3 = false
#     eventPlayer.abilPos4 = eventPlayer.getEyePosition()
#     eventPlayer.abilPos2 = false
#     eventPlayer.abilPos3 = false
#     eventPlayer.heroState1 = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), 0)
#     tmp1 = ORISA_BARRIER_BALLISTIC_SPEED * cosDeg(tmp0)
#     tmp2 = ORISA_BARRIER_BALLISTIC_SPEED * sinDeg(tmp0)
#     eventPlayer.I0 = 0

#     while eventPlayer.I0 <= ORISA_BARRIER_BALLISTIC_MAX_TIME:
#       eventPlayer.abilPos2 = (
#         eventPlayer.getEyePosition()
#         + eventPlayer.heroState1 * tmp1 * eventPlayer.I0
#         + Vector.UP * (
#           tmp2 * eventPlayer.I0
#           - ((ORISA_BARRIER_BALLISTIC_GRAVITY * (eventPlayer.I0 ** 2)) / 2)
#         )
#       )

#       eventPlayer.abilPos3 = (
#         eventPlayer.getEyePosition()
#         + eventPlayer.heroState1 * tmp1 * (eventPlayer.I0 + ORISA_BARRIER_BALLISTIC_STEP)
#         + Vector.UP * (
#           tmp2 * (eventPlayer.I0 + ORISA_BARRIER_BALLISTIC_STEP)
#           - ((ORISA_BARRIER_BALLISTIC_GRAVITY * ((eventPlayer.I0 + ORISA_BARRIER_BALLISTIC_STEP) ** 2)) / 2)
#         )
#       )

#       eventPlayer.abilPos4 = raycast(
#         eventPlayer.abilPos2,
#         eventPlayer.abilPos3,
#         getAllPlayers(),
#         eventPlayer,
#         true
#       ).getHitPosition()

#       if eventPlayer.abilPos4 != eventPlayer.abilPos3:
#         eventPlayer.abilState2 = getTotalTimeElapsed() + eventPlayer.I0 + ORISA_BARRIER_BALLISTIC_STEP
#         break

#       eventPlayer.I0 += ORISA_BARRIER_BALLISTIC_STEP
#       eventPlayer.abilPos4 = eventPlayer.abilPos3

#     if not eventPlayer.abilState2:
#       eventPlayer.abilState2 = getTotalTimeElapsed() + eventPlayer.I0


# rule "[Orisa] Barrier placement check after projectile lands":
#   @Event eachPlayer
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.abilState2
#   @Condition eventPlayer.abilState2 <= getTotalTimeElapsed()
#   @Condition eventPlayer.abilPos4
#   @Condition not eventPlayer.abilState3

#   eventPlayer.abilState3 = true
#   tmp1 = eventPlayer.abilPos4 + Vector.UP * ORISA_BARRIER_CHECK_HEIGHT
#   tmp4 = false
#   tmp5 = false
#   tmp0 = ORISA_BARRIER_CHECK_MAX_GAP

#   while tmp0 >= ORISA_BARRIER_CHECK_MIN_GAP:
#     eventPlayer.abilPos2 = false
#     eventPlayer.abilPos3 = false
#     eventPlayer.I0 = ORISA_BARRIER_CHECK_SCAN_RANGE * -1

#     while eventPlayer.I0 <= ORISA_BARRIER_CHECK_SCAN_RANGE and not eventPlayer.abilPos2:
#       tmp2 = tmp1 + eventPlayer.heroState1 * eventPlayer.I0
#       tmp3 = tmp2 - eventPlayer.heroState1 * tmp0

#       if (
#         not isInLoS(tmp3, tmp2, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
#         isInLoS(tmp3, tmp2, BarrierLos.PASS_THROUGH_BARRIERS)
#       ):
#         eventPlayer.abilPos2 = tmp2
#         eventPlayer.abilPos3 = tmp3

#       eventPlayer.I0 += ORISA_BARRIER_CHECK_SCAN_STEP

#     if eventPlayer.abilPos2:
#       tmp4 = eventPlayer.abilPos2
#       tmp5 = eventPlayer.abilPos3

#     tmp0 *= ORISA_BARRIER_CHECK_GAP_SCALE

#   if not tmp4:
#     return

#   eventPlayer.abilPos2 = tmp4
#   eventPlayer.abilPos3 = tmp5
#   eventPlayer.isActiveBarrier = true
#   eventPlayer.barrierCheckVectA = eventPlayer.abilPos3
#   eventPlayer.barrierCheckVectB = normalize(eventPlayer.abilPos2 - eventPlayer.abilPos3)
