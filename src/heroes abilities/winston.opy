#!mainFile "../main.opy"
#!optimizeForSize

#!define WIN_INNER_CHECK_RADIUS 4.8
#!define WIN_OUTER_CHECK_RADIUS 5.2
#!define WIN_BARRIER_PUSH_ENENT_WAIT 0.1

# globalvar winstonBarrierCheckDirections = [Vector.UP, vect(0, 1, 1), vect(0, 1, -1), vect(1, 1, 0), vect(-1, 1, 0)]

rule "[Winston] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WINSTON

  wait(1) # waiting for the previous hero to clear hero data

  setHeroInfoText0(
    f"{heroIcon(Hero.WINSTON)} <fga0a9baFF>Winston</fg>:\n
    {abilityIconString(Hero.WINSTON, Button.ABILITY_2)} <fga0a9baFF>Barrier projector</fg>:
      - Pushes out enemies and takes damage on contact.
      - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.WINSTON, INFINITY)
  clearHeroInfoSub()
  
rule "[Winston] Create barrier and save position":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isUsingAbility2()
  @SuppressWarnings w_chased_var_in_for w_ow2_rule_condition_chase

  # todo: предполагаемый фикс бага:
  # stopChasingVariable(eventPlayer.heroState2)
  # stopChasingVariable(eventPlayer.heroState0)

  eventPlayer.heroState2 = null
  eventPlayer.heroState0 = eventPlayer.getEyePosition() # current Barrier projectile position

  # Barrier projectile drop location:
  eventPlayer.heroState1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + Vector.DOWN * 50, null, getAllPlayers(), false).getHitPosition()

  # Waiting for the barrier projectile to reach the drop location:
  chaseAtRate(eventPlayer.heroState2, 10000, 9.8)
  chaseAtRate(
    eventPlayer.heroState0,
    eventPlayer.heroState1,
    eventPlayer.heroState2
  )
  waitUntil(eventPlayer.heroState0 == eventPlayer.heroState1, 12)
  stopChasingVariable(eventPlayer.heroState2)
  stopChasingVariable(eventPlayer.heroState0)
  wait(0.1)

  # checking several positions to place vectors for detecting the barrier:
  # [Vector.UP, vect(0, 1, 1), vect(0, 1, -1), vect(1, 1, 0), vect(-1, 1, 0)]
  list0 = [Vector.UP, Vector.UP + Vector.FORWARD, Vector.UP + Vector.BACKWARD, Vector.UP + Vector.LEFT, Vector.UP + Vector.RIGHT, Vector.UP + Vector.BACKWARD]
  for I in range(len(list0)):
    tmp0 = list0[I]
    tmp1 = eventPlayer.heroState0 + tmp0 * WIN_INNER_CHECK_RADIUS
    tmp2 = eventPlayer.heroState0 + tmp0 * WIN_OUTER_CHECK_RADIUS
    if (
      not isInLoS(
        tmp1,
        tmp2,
        BarrierLos.BLOCKED_BY_ALL_BARRIERS
      ) and isInLoS(
        tmp1,
        tmp2,
        BarrierLos.PASS_THROUGH_BARRIERS
      )
    ):
      eventPlayer.barrierCheckVectA = tmp1
      eventPlayer.barrierCheckVectB = tmp2
      break

  if not eventPlayer.barrierCheckVectA:
    FailedBarrierDeploySub()
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
    return

  eventPlayer.isActiveBarrier = true

  waitUntil(
    isInLoS(
      eventPlayer.barrierCheckVectA,
      eventPlayer.barrierCheckVectB,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    8
  )
  ClearBarrierStateSub()


rule "[Winston] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isActiveBarrier

  list0 = getRealPlayersInRadius(eventPlayer.heroState0, 6, Team.ZOMBIES)

  for I in range(len(list0)):
    list0[I].applyImpulse(
      horDirectionTowards(eventPlayer.heroState0, list0[I].getPosition()) + BarrierPushVectUpFixConst,
      10 if distance(eventPlayer.heroState0, list0[I]) < 5 else 4,
      Relativity.TO_WORLD
    )

  list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.damageFromBarrier(list0)
  eventPlayer.damageBarrier(2.3 * WIN_BARRIER_PUSH_ENENT_WAIT * len(list0))

  wait(WIN_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()

# rule "[Winston] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero winston 

#   debug(eventPlayer.barrierCheckVectA)
#   debug(eventPlayer.barrierCheckVectB)

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.BLUE,
#     eventPlayer.barrierCheckVectA,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.barrierCheckVectB,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.GREEN,
#     eventPlayer.heroState0,
#     0.5,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )
