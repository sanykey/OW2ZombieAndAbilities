#!mainFile "../main.opy"

#!define WIN_INNER_CHECK_RADIUS 4.9
#!define WIN_OUTER_CHECK_RADIUS 5.1
#!define WIN_BARRIER_PUSH_ENENT_WAIT 0.3

rule "[Winston] init":
  @Event eachPlayer
  @Team 1
  @Hero winston

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fga0a9baFF>Winston</fg>:\n
  {} {}Barrier projector</fg>:
      - Pushes enemies outside and takes damage because of it.
  ".format(
    heroIcon(Hero.WINSTON),
    abilityIconString(Hero.WINSTON, Button.ABILITY_2),
    "<fga0a9baFF>"
  )

  waitUntil(eventPlayer.getHero() != Hero.WINSTON, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.state[SI.HERO_INFO_TEXT] = ""

# abilPos0: current Barrier projectile position
# abilPos1: Barrier projectile drop location
rule "[Winston] Create barrier and save position":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.isUsingAbility2()

  eventPlayer.abilTemp1 = false
  eventPlayer.abilPos0 = eventPlayer.getEyePosition()
  eventPlayer.abilPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + Vector.DOWN * 50, null, getAllPlayers(), false).getHitPosition()

  chaseAtRate(eventPlayer.abilTemp1, 10000, 9.8)
  chaseAtRate(
    eventPlayer.abilPos0,
    eventPlayer.abilPos1,
    eventPlayer.abilTemp1
  )

  waitUntil(eventPlayer.abilPos0 == eventPlayer.abilPos1, 12)
  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilPos0 + Vector.UP * 5.5
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.abilPos0 - (eventPlayer.abilPos0 + Vector.UP * 5.5))
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

  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false


rule "[Winston] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero winston
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]

  eventPlayer.list = getPlayersInRadius(eventPlayer.abilPos0, 6, Team.2)

  for eventPlayer.I in range(len(eventPlayer.list)):
    eventPlayer.list[eventPlayer.I].applyImpulse(normalize(eventPlayer.list[eventPlayer.I].getPosition() - eventPlayer.abilPos0 + vect(0, 0.5, 0.866)), 12 - distance(eventPlayer.abilPos0, eventPlayer.list[eventPlayer.I]), Relativity.TO_WORLD)

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) / WIN_BARRIER_PUSH_ENENT_WAIT

  wait(WIN_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()