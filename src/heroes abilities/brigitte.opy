#!mainFile "../main.opy"

rule "[Brigitte] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.BRIGITTE

  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg8b625eFF>Brigitte</fg>:\n
  {} {}Barrier shield{}:
    - Pushes back enemies and takes damage on contact.\n\n
  {} <fg8b625eFF>Shield bash</fg>:
    - Stuns an enemy for 2 seconds.
  ".format(
    heroIcon(Hero.BRIGITTE),
    abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE),
    "<fg8b625eFF>",
    "</fg>",
    "<TX C00000000003339>"
  )

  waitUntil(eventPlayer.getHero() != Hero.BRIGITTE, INFINITY)
  clearHeroInfo()


rule "[Brigitte] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero brigitte
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
  eventPlayer.list.lastCcAttacker = eventPlayer
  eventPlayer.list.lastCcAttackTime = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list.lastCcWasInAir = false

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (botsDamageBoostPercent / 100)) * REI_BARRIER_PUSH_ENENT_WAIT
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.getEyePosition() - eventPlayer.state[SI.BARRIER_DAMAGE_FROM])

  wait(REI_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()

rule "[Brigitte] Bash":
  @Event playerDealtDamage
  @Team 1
  @Hero brigitte
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition eventAbility == Button.PRIMARY_FIRE
  
  victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)


# rule "[Brigitte] debug":
#   @Event eachPlayer
#   @Team 1

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * -1,
#     6,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

  