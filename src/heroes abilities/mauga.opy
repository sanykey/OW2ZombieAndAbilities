#!mainFile "../main.opy"
#!optimizeForSize
#!define MAU_INNER_CHECK_RADIUS 7.2
#!define MAU_OUTER_CHECK_RADIUS 8.2
#!define MAU_ULT_DURATION 8
#!define MAU_BARRIER_PUSH_ENENT_WAIT 0.1

rule "[Mauga] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.MAUGA

  setHeroInfoText0(
    f"{heroIcon(Hero.MAUGA)} <fgdc847dFF>Mauga</fg>:\n
    {abilityIconString(Hero.MAUGA, Button.ULTIMATE)} <fgdc847dFF>Cage fight</fg>:
      - Slows enemies within the ability’s radius by 75%.
      - Pushes back enemies outside the barrier and takes damage on contact.
      - If the barrier malfunctions, a message will appear and your ultimate charge will be refunded.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.MAUGA, INFINITY)
  clearHeroInfoSub()

rule "[Mauga] Create barrier (ultimate)":
  @Event eachPlayer
  @Hero mauga
  @Condition eventPlayer.isUsingUltimate()

  wait(0.43) # wait animation before barrier placement

  eventPlayer.heroState0 = distance(
    eventPlayer.getEyePosition(), 
    raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * 3,
      null,
      eventPlayer,
      true
    ).getHitPosition()
  )
  if eventPlayer.heroState0 < 1.85:
    eventPlayer.heroState1 = 1.26 - (1.85 - eventPlayer.heroState0)
  else:
    eventPlayer.heroState1 = 1.26

  eventPlayer.heroState2 = raycast(
    eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.heroState1,
    eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.heroState1 + Vector.DOWN * 25,
    null,
    eventPlayer,
    true
  ).getHitPosition()

  if distance(
    eventPlayer.heroState2, eventPlayer.getPosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.heroState1
  ) > 2.58:
    eventPlayer.heroState2 = raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + Vector.DOWN * 25,
      null,
      eventPlayer,
      true
    ).getHitPosition()
  
  wait(0.1)
  tmp0 = eventPlayer.heroState2 + Vector.UP * 3
  list0 = [Vector.LEFT, Vector.RIGHT, Vector.FORWARD, Vector.BACKWARD]
  for I in range(len(list0)):
    if (
      not isInLoS(
        tmp0 + list0[I] * MAU_INNER_CHECK_RADIUS,
        tmp0 + list0[I] * MAU_OUTER_CHECK_RADIUS,
        BarrierLos.BLOCKED_BY_ALL_BARRIERS
      ) and isInLoS(
        tmp0 + list0[I] * MAU_INNER_CHECK_RADIUS,
        tmp0 + list0[I] * MAU_OUTER_CHECK_RADIUS,
        BarrierLos.PASS_THROUGH_BARRIERS
      )
    ):
      eventPlayer.barrierCheckVectA = tmp0 + list0[I] * MAU_INNER_CHECK_RADIUS
      eventPlayer.barrierCheckVectB = tmp0 + list0[I] * MAU_OUTER_CHECK_RADIUS
      break

  if not eventPlayer.barrierCheckVectA:
    FailedBarrierDeploySub()
    wait(0.7)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(0.016)
    eventPlayer.stopForcingButton(Button.ULTIMATE)
    wait(0.2)
    eventPlayer.setUltCharge(100)
    return

  # keep the position without height, for more accurate calculations in the cylindrical barrier:
  eventPlayer.heroState3 = vect(eventPlayer.heroState2.x, false, eventPlayer.heroState2.z) 

  eventPlayer.isActiveBarrier = true

rule "[Mauga] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero mauga
  @Condition eventPlayer.isActiveBarrier

  list0 = getRealPlayersInRadius(eventPlayer.heroState2, 10, Team.ZOMBIES)
  
  for I in range(len(list0)):
    # pushes back enemies outside barrier:
    if distance(
      vect(list0[I].getPosition().x, false, list0[I].getPosition().z),
      eventPlayer.heroState3
    ) > 7:
      list0[I].applyImpulse(
        normalize(
          (list0[I].getEyePosition() - eventPlayer.heroState2) + BarrierPushVectUpFixConst
        ),
        7,
        Relativity.TO_WORLD
      )
      damage(list0[I], eventPlayer, 0.1)
      eventPlayer.damageBarrier(2.2 * MAU_BARRIER_PUSH_ENENT_WAIT)
      list0[I].setCrowdControlAttack(eventPlayer)

    else: # slow down players inside barrier
      list0[I].setSpeedState(25, MAU_BARRIER_PUSH_ENENT_WAIT)

  wait(MAU_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()


rule "[Mauga] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero mauga
  @Condition eventPlayer.isActiveBarrier
  
  waitUntil(
    isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.BLOCKED_BY_ALL_BARRIERS), MAU_ULT_DURATION
  )
  ClearBarrierStateSub()

# debug barrier:
# rule "[Mauga][debug]":
#   @Event eachPlayer
#   @Team 1
#   @Hero mauga

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.TURQUOISE,
  #   eventPlayer.heroState2,
  #   11.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.RED,
  #   eventPlayer.heroState2,
  #   8,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.RED,
  #   eventPlayer.heroState2,
  #   0.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.PURPLE,
  #   tmp0,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.BLUE,
  #   eventPlayer.heroState0,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.GREEN,
  #   eventPlayer.heroState1,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )