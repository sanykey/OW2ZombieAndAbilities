#!mainFile "../main.opy"

#!define REI_BARRIER_PUSH_ENENT_WAIT 0.1

rule "[Reinhard] init":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg94a1a5FF>Reinhardt</fg>:\n
  {} {}Barrier field{}:
      - Pushes back enemies and takes damage because of it.
  ".format(
    heroIcon(Hero.REINHARDT),
    abilityIconString(Hero.REINHARDT, Button.SECONDARY_FIRE),
    "<fg94a1a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.REINHARDT, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.state[SI.HERO_INFO_TEXT] = ""


rule "[Reinhard] Damage barrier when pushing enemies every 0.5 sec":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false

rule "[Reinhard] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero reinhardt
  @Condition eventPlayer.isFiringSecondaryFire()

  eventPlayer.temp1 = (
    [player for player in getPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.2) if not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and player != eventPlayer]
  )
  eventPlayer.temp1.applyImpulse(normalize(eventPlayer.getFacingDirection() + vect(0, 0.2679, 0)), 6, Relativity.TO_WORLD)

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.temp1) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) * REI_BARRIER_PUSH_ENENT_WAIT
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.getEyePosition() - eventPlayer.state[SI.BARRIER_DAMAGE_FROM])

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()
