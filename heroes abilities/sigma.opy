#!mainFile "../main.opy"

#!define SIG_BARRIER_PUSH_ENENT_WAIT 0.2

enum SIGMA_I:
  TMP_EFFECT = 0
  BARRIER_FD = 1

rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Hero sigma 

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg94a0a5FF>Winston</fg>:\n
  {} {}Experimental barrier{}:
      - Pushes back enemies when stationary, taking damage on contact.
      - Pushes enemies back while flying, but takes increased damage during flight.
      - HP upgrades do not increase the barrier's health, but reduce the damage it receives.
  ".format(
    heroIcon(Hero.SIGMA),
    abilityIconString(Hero.SIGMA, Button.SECONDARY_FIRE),
    "<fg94a0a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.SIGMA, INFINITY)
  eventPlayer.state[SI.TALENTS_COUNT] = 0
  eventPlayer.state[SI.HERO_INFO_TEXT] = ""

  # todo: debug
  # hudHeader(
  #   eventPlayer,
  #   "CD {} : {}".format(
  #     eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE),
  #     eventPlayer.isFiringSecondaryFire()
  #   ),
  #   HudPosition.TOP,
  #   0,
  #   Color.WHITE,
  #   HudReeval.VISIBILITY_AND_STRING,
  #   SpecVisibility.ALWAYS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.GREEN,
  #   eventPlayer.abilityPosition,
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.LIGHT_RED,
  #   eventPlayer.state[SI.BARRIER_DAMAGE_FROM],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )


rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Hero sigma 
  @Condition updateEveryFrame(eventPlayer.isFiringSecondaryFire()) == true

  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  eventPlayer.abilityPosition = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2.25, null, eventPlayer, true).getHitPosition()
  eventPlayer.heroState[SIGMA_I.BARRIER_FD] = eventPlayer.getFacingDirection()

  createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.WHITE, eventPlayer.abilityPosition, 3.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[SIGMA_I.TMP_EFFECT] = getLastCreatedEntity()

  chaseAtRate(eventPlayer.abilityPosition, raycast(eventPlayer.abilityPosition, eventPlayer.abilityPosition + evalOnce(eventPlayer.getFacingDirection()), null, eventPlayer, true).getHitPosition() + evalOnce(eventPlayer.getFacingDirection()) * -0.01, 20)

  waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)
  stopChasingVariable(eventPlayer.abilityPosition)

  # calculate position for barier damaging
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilityPosition

  waitUntil(updateEveryFrame(eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE)) != null, 99999)
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false
  destroyEffect(eventPlayer.heroState[SIGMA_I.TMP_EFFECT])

rule "[Sigma] Barrier Effect":
  @Event eachPlayer
  @Team 1
  @Hero sigma
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE] == true
  
  eventPlayer.list = [player for player in getPlayersInRadius(eventPlayer.abilityPosition, 3.5, Team.2) if player.isAlive()]

  # calculate position for barier damaging
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilityPosition + Vector.UP * 1.8
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = eventPlayer.heroState[SIGMA_I.BARRIER_FD]

  # calculate damage to barrier
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) * SIG_BARRIER_PUSH_ENENT_WAIT

  if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    eventPlayer.list.applyImpulse(
      normalize(eventPlayer.heroState[SIGMA_I.BARRIER_FD] + vect(0, 0.2679, 0)), 10, Relativity.TO_WORLD
    )
    eventPlayer.state[SI.BARRIER_DAMAGE_STACK] *= 1.5 # more damage when mooving 

  else:
    eventPlayer.list.applyImpulse(
      normalize(eventPlayer.heroState[SIGMA_I.BARRIER_FD] + vect(0, 0.2679, 0)), 15, Relativity.TO_WORLD
    )

  wait(SIG_BARRIER_PUSH_ENENT_WAIT)

  if RULE_CONDITION:
    loop()