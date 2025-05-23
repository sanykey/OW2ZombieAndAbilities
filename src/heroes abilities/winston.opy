#!mainFile "../main.opy"

#!define WIN_INNER_CHECK_RADIUS 4.9
#!define WIN_OUTER_CHECK_RADIUS 5.1
#!define WIN_BARRIER_PUSH_ENENT_WAIT 0.3

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

# abilPos0: current Barrier projectile position
# abilPos1: Barrier projectile drop location
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
  eventPlayer.isActiveBarrier = true
  eventPlayer.barrierDamageFrom = eventPlayer.abilPos0 + Vector.UP * 5.5
  eventPlayer.barrierDamageDir = normalize(eventPlayer.abilPos0 - (eventPlayer.abilPos0 + Vector.UP * 5.5))
  stopChasingVariable(eventPlayer.abilTemp1)
  wait(0.1)

  eventPlayer.abilTemp1 = getTotalTimeElapsed()
  waitUntil(
    isInLoS(
      eventPlayer.abilPos0 + Vector.UP * WIN_INNER_CHECK_RADIUS,
      eventPlayer.abilPos0 + Vector.UP * WIN_OUTER_CHECK_RADIUS,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilPos0 + Vector.LEFT * WIN_INNER_CHECK_RADIUS,
      eventPlayer.abilPos0 + Vector.LEFT * WIN_OUTER_CHECK_RADIUS,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilPos0 + Vector.RIGHT * WIN_INNER_CHECK_RADIUS,
      eventPlayer.abilPos0 + Vector.RIGHT * WIN_OUTER_CHECK_RADIUS,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilPos0 + Vector.FORWARD * WIN_INNER_CHECK_RADIUS,
      eventPlayer.abilPos0 + Vector.FORWARD * WIN_OUTER_CHECK_RADIUS,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ) and isInLoS(
      eventPlayer.abilPos0 + Vector.BACKWARD * WIN_INNER_CHECK_RADIUS,
      eventPlayer.abilPos0 + Vector.BACKWARD * WIN_OUTER_CHECK_RADIUS,
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    11.9
  )

  if eventPlayer.abilTemp1 >= getTotalTimeElapsed():
    smallMessage(eventPlayer, "Barrier deploy failed! Try again")
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)

  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false


rule "[Winston] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isActiveBarrier

  eventPlayer.list0 = getPlayersInRadius(eventPlayer.abilPos0, 6, Team.2)

  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.list0[eventPlayer.I].applyImpulse(
      normalize(eventPlayer.list0[eventPlayer.I].getEyePosition() - eventPlayer.abilPos0), 15 - distance(eventPlayer.abilPos0, eventPlayer.list0[eventPlayer.I]), Relativity.TO_WORLD
    )

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  eventPlayer.barrierDamageStack += len(eventPlayer.list0) * (TORBJORN_HAMMER_BASE_DMG * (botsDamageBoostPercent / 100)) / WIN_BARRIER_PUSH_ENENT_WAIT

  wait(WIN_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()