#!mainFile "../main.opy"

#!define SIG_BARRIER_PUSH_ENENT_WAIT 0.2

rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SIGMA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -2
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg94a0a5FF>Sigma</fg>:\n
  {} {}Experimental barrier{}:
      - Pushes back enemies when stationary, taking damage on contact.
      - Pushes enemies back while flying, but takes increased damage during flight.
      - HP upgrades do not increase the barrier's health, but reduce the damage it receives.
      - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
  ".format(
    heroIcon(Hero.SIGMA),
    abilityIconString(Hero.SIGMA, Button.SECONDARY_FIRE),
    "<fg94a0a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.SIGMA, INFINITY)
  clearHeroInfo()


rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Hero sigma 
  @Condition updateEveryFrame(eventPlayer.isFiringSecondaryFire()) == true

  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  eventPlayer.abilPos0 = raycast(
    eventPlayer.getEyePosition(),
    eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2.25,
    null,
    eventPlayer,
    true
  ).getHitPosition()
  eventPlayer.abilDir0 = eventPlayer.getFacingDirection()
  
  chaseAtRate(
    eventPlayer.abilPos0,
    raycast(
      eventPlayer.abilPos0,
      eventPlayer.abilPos0 + evalOnce(eventPlayer.getFacingDirection()),
      null,
      eventPlayer,
      true
    ).getHitPosition() + evalOnce(eventPlayer.getFacingDirection()) * -0.01,
    20
  )
  waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)
  stopChasingVariable(eventPlayer.abilPos0)

  # calculate position for barier damaging
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilPos0

  waitUntil(updateEveryFrame(eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE)) != null, INFINITY)
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false

rule "[Sigma] Barrier Effect":
  @Event eachPlayer
  @Team 1
  @Hero sigma
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE] == true
  
  eventPlayer.list = [player for player in getPlayersInRadius(eventPlayer.abilPos0, 3.5, Team.2) if player.isAlive()]

  # save information about bots being pushed to account for damage when falling down
  eventPlayer.list.lastCcAttacker = eventPlayer
  eventPlayer.list.lastCcAttackTime = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list.lastCcWasInAir = false

  # calculate position for barier damaging
  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilPos0 + Vector.UP * 1.8
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = eventPlayer.abilDir0

  # calculate damage to barrier
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (botsDamageBoostPercent / 100)) * SIG_BARRIER_PUSH_ENENT_WAIT

  if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    eventPlayer.list.applyImpulse(
      normalize(eventPlayer.abilDir0 + vect(0, 0.2679, 0)), 16, Relativity.TO_WORLD
    )
    eventPlayer.state[SI.BARRIER_DAMAGE_STACK] *= 1.5 # more damage when mooving 

  else:
    # Check is barrier exists
    eventPlayer.temp1 = eventPlayer.state[SI.BARRIER_DAMAGE_FROM] + eventPlayer.abilDir0 * 0.8
    if (
      eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) == null and (
        isInLoS(
          eventPlayer.state[SI.BARRIER_DAMAGE_FROM],
          eventPlayer.temp1,
          BarrierLos.BLOCKED_BY_ALL_BARRIERS
        ) or 
        not isInLoS(
          eventPlayer.state[SI.BARRIER_DAMAGE_FROM],
          eventPlayer.temp1,
          BarrierLos.PASS_THROUGH_BARRIERS
        )
      )
    ):
      smallMessage(eventPlayer, "Barrier deploy failed! Try again")
      eventPlayer.state[SI.BARRIER_ACTIVE] = false
      eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false
      return

    for eventPlayer.I in range(len(eventPlayer.list)):
      eventPlayer.list[eventPlayer.I].applyImpulse(
        normalize(
          eventPlayer.abilDir0 *
          (-1 if isInLoS(eventPlayer.list[eventPlayer.I], eventPlayer.abilPos0, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else 1)
          + vect(0, 0.2679, 0)
        ) 
        ,
        10,
        Relativity.TO_WORLD
      )

  wait(SIG_BARRIER_PUSH_ENENT_WAIT)

  if RULE_CONDITION:
    loop()

# rule "[Ramattra] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero sigma 

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.BLUE,
#     eventPlayer.abilPos0,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.state[SI.BARRIER_DAMAGE_FROM],
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )


#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.GREEN,
#     eventPlayer.temp1,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

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
  #   eventPlayer.abilPos0,
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

