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
      - Pushes back enemies and takes damage on contact.
  ".format(
    heroIcon(Hero.REINHARDT),
    abilityIconString(Hero.REINHARDT, Button.SECONDARY_FIRE),
    "<fg94a1a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.REINHARDT, INFINITY)
  clearHeroInfo()


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

  eventPlayer.list = (
    [player for player in getPlayersInRadius(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1, 6, Team.2) if (
      distance(player, eventPlayer.getPosition() + eventPlayer.getFacingDirection()) < 2 or (
        not isInLoS(eventPlayer, player, BarrierLos.BLOCKED_BY_ALL_BARRIERS) and
        isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) and
        player != eventPlayer
      )
    )]
  )
  eventPlayer.list.applyImpulse(normalize(eventPlayer.getFacingDirection() + vect(0, 0.2679, 0)), 6, Relativity.TO_WORLD)

  # save information about bots being pushed to account for damage when falling down
  eventPlayer.list.state[SI.LAST_CC_ATTACKER] = eventPlayer
  eventPlayer.list.state[SI.LAST_CC_ATTACK_TIME] = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list.state[SI.LAST_CC_WAS_IN_AIR] = false

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) * REI_BARRIER_PUSH_ENENT_WAIT
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.getEyePosition() - eventPlayer.state[SI.BARRIER_DAMAGE_FROM])

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()

# rule "[Reinhard] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero reinhardt

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.temp2,
#     2,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )