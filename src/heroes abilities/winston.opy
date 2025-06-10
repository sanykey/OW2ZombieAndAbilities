#!mainFile "../main.opy"

rule "[Winston] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WINSTON

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fga0a9baFF>Winston</fg>:\n
  {} {}Barrier projector{}:
      - Pushes out enemies and takes damage on contact.
      - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
  ".format(
    heroIcon(Hero.WINSTON),
    abilityIconString(Hero.WINSTON, Button.ABILITY_2),
    "<fga0a9baFF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.WINSTON, INFINITY)
  clearHeroInfo()
  

#!define WIN_INNER_CHECK_RADIUS 4.9
#!define WIN_OUTER_CHECK_RADIUS 5.1

rule "[Winston] Create barrier and save position":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isUsingAbility2()
  @SuppressWarnings w_chased_var_in_for w_ow2_rule_condition_chase

  eventPlayer.abilTemp1 = false
  eventPlayer.abilPos0 = eventPlayer.getEyePosition() # current Barrier projectile position

  # Barrier projectile drop location:
  eventPlayer.abilPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + Vector.DOWN * 50, null, getAllPlayers(), false).getHitPosition()

  chaseAtRate(eventPlayer.abilTemp1, 10000, 9.8)
  chaseAtRate(
    eventPlayer.abilPos0,
    eventPlayer.abilPos1,
    eventPlayer.abilTemp1
  )

  waitUntil(eventPlayer.abilPos0 == eventPlayer.abilPos1, 12)
  stopChasingVariable(eventPlayer.abilTemp1)
  stopChasingVariable(eventPlayer.abilPos0)
  wait(0.1)

  eventPlayer.barrierDamageFrom = null
  eventPlayer.list0 = [Vector.UP, vect(0, 1, 1), vect(0, 1, -1), vect(1, 1, 0), vect(-1, 1, 0)]

  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.barrierDamageDir = eventPlayer.list0[eventPlayer.I]
    eventPlayer.abilPos1 = eventPlayer.abilPos0 + eventPlayer.barrierDamageDir * WIN_INNER_CHECK_RADIUS
    if (
      not isInLoS(
        eventPlayer.abilPos1,
        eventPlayer.abilPos1 + eventPlayer.barrierDamageDir,
        BarrierLos.BLOCKED_BY_ALL_BARRIERS
      ) and isInLoS(
        eventPlayer.abilPos1,
        eventPlayer.abilPos1 + eventPlayer.barrierDamageDir,
        BarrierLos.PASS_THROUGH_BARRIERS
      )
    ):
      eventPlayer.barrierDamageFrom = eventPlayer.abilPos1
      break

  if not eventPlayer.barrierDamageFrom:
    smallMessage(eventPlayer, "Barrier deploy failed! Try again")
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)

  eventPlayer.isActiveBarrier = true

  waitUntil(
    isInLoS(
      eventPlayer.barrierDamageFrom,
      eventPlayer.barrierDamageFrom + eventPlayer.barrierDamageDir,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    8
  )

  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false


#!define WIN_BARRIER_PUSH_ENENT_WAIT 0.1
rule "[Winston] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isActiveBarrier

  eventPlayer.list0 = getRealPlayersInRadius(eventPlayer.abilPos0, 6, Team.2)

  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.list0[eventPlayer.I].applyImpulse(
      horDirectionTowards(eventPlayer.abilPos0, eventPlayer.list0[eventPlayer.I].getPosition()) + barrierPushVectUpFix,
      10 if distance(eventPlayer.abilPos0, eventPlayer.list0[eventPlayer.I]) < 5 else 4,
      Relativity.TO_WORLD
    )

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  eventPlayer.barrierDamageStack += (
    len(eventPlayer.list0) *
    (TORBJORN_HAMMER_BASE_DMG * WIN_BARRIER_PUSH_ENENT_WAIT * 2.3) * 
    (botsDamageBoostPercent / 100)
  )

  wait(WIN_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()

# rule "[Winston] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero winston 

#   debug(eventPlayer.barrierDamageFrom)
#   debug(eventPlayer.barrierDamageDir)

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.BLUE,
#     eventPlayer.barrierDamageFrom,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.barrierDamageFrom + eventPlayer.barrierDamageDir,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.GREEN,
#     eventPlayer.abilPos0,
#     0.5,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )