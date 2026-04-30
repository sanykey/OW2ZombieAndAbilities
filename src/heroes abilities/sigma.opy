#!mainFile "../main.opy"
#!optimizeForSize

rule "[Sigma] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SIGMA

  wait(1) # waiting for the previous hero to clear hero data

  setHeroInfoText0(
    f"{heroIcon(Hero.SIGMA)} <fg94a0a5FF>Sigma</fg>:\n
    {abilityIconString(Hero.SIGMA, Button.SECONDARY_FIRE)} <fg94a0a5FF>Experimental barrier</fg>:
      - Pushes back enemies when stationary, taking damage on contact.
      - Pushes enemies back while flying, but takes increased damage during flight.
      - HP upgrades do not increase the barrier's health, but reduce the damage it receives.
      - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
    ", -2
  )

  waitUntil(eventPlayer.getHero() != Hero.SIGMA, INFINITY)
  clearHeroInfoSub()


rule "[Sigma] start barrier":
  @Event eachPlayer
  @Team 1
  @Hero sigma 
  @Condition updateEveryFrame(eventPlayer.isFiringSecondaryFire())

  eventPlayer.isActiveBarrier = true
  eventPlayer.barrierCheckVectA = raycast(
    eventPlayer.getEyePosition(),
    eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 2.25,
    null,
    eventPlayer,
    true
  ).getHitPosition()
  eventPlayer.heroState0 = eventPlayer.getFacingDirection() # Barrier movement direction
  
  chaseAtRate(
    eventPlayer.barrierCheckVectA,
    raycast(
      eventPlayer.barrierCheckVectA,
      eventPlayer.barrierCheckVectA + evalOnce(eventPlayer.getFacingDirection()),
      null,
      eventPlayer,
      true
    ).getHitPosition() + evalOnce(eventPlayer.getFacingDirection()) * -0.01,
    20
  )

  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  stopChasingVariable(eventPlayer.barrierCheckVectA)

  eventPlayer.heroState1 = eventPlayer.barrierCheckVectA # barrier position

  # calculate position for barier damaging. place barrier damage points above the center of the barrier to avoid accidentally damaging players and bots on both teams
  eventPlayer.barrierCheckVectA = eventPlayer.barrierCheckVectA + normalize(crossProduct(eventPlayer.heroState0, crossProduct(Vector.UP, eventPlayer.heroState0))) * 1.8
  eventPlayer.barrierCheckVectB = eventPlayer.heroState0
  eventPlayer.heroState2 = eventPlayer.barrierCheckVectA + eventPlayer.heroState0


  waitUntil(updateEveryFrame(eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE)) != null, INFINITY)
  ClearBarrierStateSub()


#!define SIG_BARRIER_PUSH_ENENT_WAIT 0.2
rule "[Sigma] Barrier Effect":
  @Event eachPlayer
  @Team 1
  @Hero sigma
  @Condition eventPlayer.isActiveBarrier
  
  list0 = [player for player in getRealPlayersInRadius(eventPlayer.heroState1, 3.5, Team.ZOMBIES) if player.isAlive()]
  list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.damageFromBarrier(list0)

  # calculate damage to barrier
  eventPlayer.damageBarrier(1.5 * SIG_BARRIER_PUSH_ENENT_WAIT * len(list0) * (100 / eventPlayer.healthBoostPercent))

  if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
    list0.applyImpulse(
      normalize(vect(eventPlayer.heroState0.x, 0.2679, eventPlayer.heroState0.z)), 16, Relativity.TO_WORLD
    )
    eventPlayer.barrierDamageStack *= 1.5 # more damage when mooving 

  else:
    # Check is barrier exists
    if (
      eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) == null and (
        isInLoS(
          eventPlayer.barrierCheckVectA,
          eventPlayer.heroState2,
          BarrierLos.BLOCKED_BY_ALL_BARRIERS
        ) or 
        not isInLoS(
          eventPlayer.barrierCheckVectA,
          eventPlayer.heroState2,
          BarrierLos.PASS_THROUGH_BARRIERS
        )
      )
    ):
      FailedBarrierDeploySub()
      wait(0.2)
      eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
      wait()
      eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
      return

    for I in range(len(list0)):
      list0[I].applyImpulse(
        normalize(
          vect(eventPlayer.heroState0.x, 0, eventPlayer.heroState0.z) *
          (-1 if isInLoS(list0[I], eventPlayer.heroState1, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else 1)
          + BarrierPushVectUpFixConst
        ), 
        4,
        Relativity.TO_WORLD
      )

  wait(SIG_BARRIER_PUSH_ENENT_WAIT)

  if ruleCondition:
    loop()

# rule "[Ramattra] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero sigma 

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.BLUE,
#     eventPlayer.heroState1,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.barrierCheckVectA,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     hostPlayer,
#     Effect.SPHERE,
#     Color.GREEN,
#     eventPlayer.heroState2,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )