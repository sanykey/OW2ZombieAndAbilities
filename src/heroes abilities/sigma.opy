#!mainFile "../main.opy"



rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SIGMA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -2
  eventPlayer.heroInfoText0 = "{} <fg94a0a5FF>Sigma</fg>:\n
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
  @Condition updateEveryFrame(eventPlayer.isFiringSecondaryFire())

  eventPlayer.isActiveBarrier = true
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
  eventPlayer.barrierDamageFrom = eventPlayer.abilPos0

  waitUntil(updateEveryFrame(eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE)) != null, INFINITY)
  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false


#!define SIG_BARRIER_PUSH_ENENT_WAIT 0.2
rule "[Sigma] Barrier Effect":
  @Event eachPlayer
  @Team 1
  @Hero sigma
  @Condition eventPlayer.isActiveBarrier
  
  eventPlayer.list0 = [player for player in getPlayersInRadius(eventPlayer.abilPos0, 3.5, Team.2) if player.isAlive()]

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  # calculate position for barier damaging
  eventPlayer.barrierDamageFrom = eventPlayer.abilPos0 + Vector.UP * 1.8
  eventPlayer.barrierDamageDir = eventPlayer.abilDir0

  # calculate damage to barrier
  eventPlayer.barrierDamageStack += (
    len(eventPlayer.list0) *
    (TORBJORN_HAMMER_BASE_DMG * SIG_BARRIER_PUSH_ENENT_WAIT * 1.5)
    * (botsDamageBoostPercent / 100)
  )

  if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    eventPlayer.list0.applyImpulse(
      normalize(vect(eventPlayer.abilDir0.x, 0.2679, eventPlayer.abilDir0.z)), 16, Relativity.TO_WORLD
    )
    eventPlayer.barrierDamageStack *= 1.5 # more damage when mooving 

  else:
    # Check is barrier exists
    eventPlayer.temp1 = eventPlayer.barrierDamageFrom + eventPlayer.abilDir0 * 0.8
    if (
      eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) == null and (
        isInLoS(
          eventPlayer.barrierDamageFrom,
          eventPlayer.temp1,
          BarrierLos.BLOCKED_BY_ALL_BARRIERS
        ) or 
        not isInLoS(
          eventPlayer.barrierDamageFrom,
          eventPlayer.temp1,
          BarrierLos.PASS_THROUGH_BARRIERS
        )
      )
    ):
      smallMessage(eventPlayer, "Barrier deploy failed! Try again")
      eventPlayer.isActiveBarrier = false
      eventPlayer.barrierDamageStack = false
      wait(0.2)
      eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
      wait()
      eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
      return

    for eventPlayer.I in range(len(eventPlayer.list0)):
      eventPlayer.list0[eventPlayer.I].applyImpulse(
        normalize(
          vect(eventPlayer.abilDir0.x, 0, eventPlayer.abilDir0.z) *
          (-1 if isInLoS(eventPlayer.list0[eventPlayer.I], eventPlayer.abilPos0, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else 1)
          + vect(0, 0.2679, 0)
        ), 
        4,
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
#     eventPlayer.barrierDamageFrom,
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

