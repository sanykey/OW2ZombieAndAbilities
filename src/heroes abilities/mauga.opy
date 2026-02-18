#!mainFile "../main.opy"

#!define MAU_INNER_CHECK_RADIUS 7.2
#!define MAU_OUTER_CHECK_RADIUS 8.2
#!define MAU_ULT_DURATION 8



rule "[Mauga] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.MAUGA

  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fgdc847dFF>Mauga</fg>:\n
  {} {}Cage fight{}:
    - Slows enemies within the ability’s radius by 75%.
    - Pushes back enemies outside the barrier and takes damage on contact.
    - If the barrier malfunctions, a message will appear and your ultimate charge will be refunded.
  ".format(
    heroIcon(Hero.MAUGA),
    abilityIconString(Hero.MAUGA, Button.ULTIMATE),
    "<fgdc847dFF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.MAUGA, INFINITY)
  clearHeroInfo()


rule "[Mauga] Create barrier (ultimate)":
  @Event eachPlayer
  @Hero mauga
  @Condition eventPlayer.isUsingUltimate()

  wait(0.43) # wait animation before barrier placement

  eventPlayer.tmp2 = distance(
    eventPlayer.getEyePosition(), 
    raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * 3,
      null,
      eventPlayer,
      true
    ).getHitPosition()
  )

  if (
    eventPlayer.tmp2 < 1.85
  ):
    eventPlayer.tmp3 = 1.26 - (1.85 - eventPlayer.tmp2)
  else:
    eventPlayer.tmp3 = 1.26

  eventPlayer.abilPos0 = raycast(
    eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.tmp3,
    eventPlayer.getEyePosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.tmp3 + Vector.DOWN * 25,
    null,
    eventPlayer,
    true
  ).getHitPosition()

  # smallMessage(eventPlayer, "dist: {}".format(distance(
  #   eventPlayer.abilPos0, eventPlayer.getPosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.tmp3
  # )))

  if distance(
    eventPlayer.abilPos0, eventPlayer.getPosition() + worldVector(Vector.FORWARD, eventPlayer, Transform.ROTATION) * eventPlayer.tmp3
  ) > 2.58:
    eventPlayer.abilPos0 = raycast(
      eventPlayer.getEyePosition(),
      eventPlayer.getEyePosition() + Vector.DOWN * 25,
      null,
      eventPlayer,
      true
    ).getHitPosition()
  
  wait(0.1)
  eventPlayer.tmp1 = eventPlayer.abilPos0 + Vector.UP * 3
  eventPlayer.tmp2 = false
  eventPlayer.tmp3 = false
  eventPlayer.list0 = [Vector.LEFT, Vector.RIGHT, Vector.FORWARD, Vector.BACKWARD]
  for eventPlayer.I in range(len(eventPlayer.list0)):
    if (
      not isInLoS(
        eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_INNER_CHECK_RADIUS,
        eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_OUTER_CHECK_RADIUS,
        BarrierLos.BLOCKED_BY_ALL_BARRIERS
      ) and isInLoS(
        eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_INNER_CHECK_RADIUS,
        eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_OUTER_CHECK_RADIUS,
        BarrierLos.PASS_THROUGH_BARRIERS
      )
    ):
      eventPlayer.tmp2 = eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_INNER_CHECK_RADIUS
      eventPlayer.tmp3 = eventPlayer.tmp1 + eventPlayer.list0[eventPlayer.I] * MAU_OUTER_CHECK_RADIUS
      break

  if not eventPlayer.tmp2 or not eventPlayer.tmp3:
    smallMessage(eventPlayer, "Barrier deploy failed! Try again")
    wait(0.7)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(0.016)
    eventPlayer.stopForcingButton(Button.ULTIMATE)
    wait(0.2)
    eventPlayer.setUltCharge(100)
    return

  # keep the position without height, for more accurate calculations in the cylindrical barrier:
  eventPlayer.abilPos1 = vect(eventPlayer.abilPos0.x, false, eventPlayer.abilPos0.z) 
  eventPlayer.isActiveBarrier = true
  eventPlayer.barrierDamageFrom = eventPlayer.tmp2
  eventPlayer.barrierDamageDir = normalize(eventPlayer.tmp3 - eventPlayer.tmp2)

#!define MAU_BARRIER_PUSH_ENENT_WAIT 0.1

rule "[Mauga] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero mauga
  @Condition eventPlayer.isActiveBarrier

  eventPlayer.list0 = getRealPlayersInRadius(eventPlayer.abilPos0, 10, Team.ZOMBIES)
  
  for eventPlayer.I in range(len(eventPlayer.list0)):
    # pushes back enemies outside barrier:
    if distance(
      vect(eventPlayer.list0[eventPlayer.I].getPosition().x, false, eventPlayer.list0[eventPlayer.I].getPosition().z),
      eventPlayer.abilPos1
    ) > 7:
      eventPlayer.list0[eventPlayer.I].applyImpulse(
        normalize(
          (eventPlayer.list0[eventPlayer.I].getEyePosition() - eventPlayer.abilPos0) + barrierPushVectUpFix
        ),
        7,
        Relativity.TO_WORLD
      )
      damage(eventPlayer.list0[eventPlayer.I], eventPlayer, 0.1)
      eventPlayer.barrierDamageStack += (
        TORBJORN_HAMMER_BASE_DMG 
        * 2.2
        * MAU_BARRIER_PUSH_ENENT_WAIT 
        * (zomDamagePct / 100)
      )

      eventPlayer.list0[eventPlayer.I].setCrowdControlAttack(eventPlayer)

    else: # slow down players inside barrier
      eventPlayer.list0[eventPlayer.I].state[SI.CHANGED_SPEED_TIME] = getTotalTimeElapsed() + 0.5
      eventPlayer.list0[eventPlayer.I].state[SI.CHANGED_SPEED_AMOUNT] = 25

  wait(MAU_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()


rule "[Mauga] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero mauga
  @Condition eventPlayer.isActiveBarrier
  
  waitUntil(
    isInLoS(eventPlayer.tmp2, eventPlayer.tmp3, BarrierLos.BLOCKED_BY_ALL_BARRIERS), MAU_ULT_DURATION
  )
  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false


# debug:
rule "[Mauga][debug]":
  @Event eachPlayer
  @Team 1
  @Hero mauga

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.TURQUOISE,
  #   eventPlayer.abilPos0,
  #   11.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.RED,
  #   eventPlayer.abilPos0,
  #   8,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.RED,
  #   eventPlayer.abilPos0,
  #   0.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.PURPLE,
  #   eventPlayer.tmp1,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.BLUE,
  #   eventPlayer.tmp2,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.GREEN,
  #   eventPlayer.tmp3,
  #   0.1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )