#!mainFile "../main.opy"
#!optimizeForSize

enum RAM_I:
  BARRIER_CENTER
  BARRIER_CHECK_BACK
  BARRIER_CHECK_FORWARD
  BARRIER_LEFT_BACK
  BARRIER_LEFT_FORWARD
  BARRIER_RIGHT_BACK
  BARRIER_RIGHT_FORWARD
  BARRIER_PUSH_DIRECTION
  BARRIER_PUSH_BACK_DIRECTION

rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.RAMATTRA

  wait(1) # waiting for the previous hero to clear hero data

  setHeroInfoText0(
    f"{heroIcon(Hero.RAMATTRA)} <fg9d8cd0FF>Rammatra</fg>:\n
    {abilityIconString(Hero.RAMATTRA, Button.SECONDARY_FIRE)} <fg9d8cd0FF>Void barrier</fg>:
        - Pushes back enemies and takes damage on contact.
        - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.RAMATTRA, INFINITY)
  clearHeroInfoSub()


rule "[Ramattra] Barrier up":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isFiringSecondaryFire()
  @Condition not (eventPlayer.isUsingAbility1() or eventPlayer.isUsingUltimate())

  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    return

  tmp1 = raycast(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 35, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 35, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0) - vect(0, 3, 0), null, eventPlayer, true).getHitPosition()
  
  # tmp2 = getPlayersInRadius(tmp1, 3.5, Team.ZOMBIES)
  # #Barrier launches away
  # tmp2.applyImpulse(vectorTowards(eventPlayer.getPosition(), tmp1) + vect(0, 5, 0), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  # playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.PURPLE, tmp1, 3)

  tmp2 = tmp1 + normalize(vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)) * 0.1 + Vector.UP * 1.5
  tmp3 = tmp1 + normalize(vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)) * 0.8 + Vector.UP * 1.5

  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CENTER] = tmp2
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] = tmp2
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] = tmp3
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK] = tmp2 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_FORWARD] = tmp3 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK] = tmp2 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_FORWARD] = tmp3 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_DIRECTION] = (
    normalize(
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] - eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] + BarrierPushVectUpFixConst
    )
  )

  eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_BACK_DIRECTION] = (
    normalize(
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] - eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] + BarrierPushVectUpFixConst
    )
  )

  wait(0.16)
  # try center:
  if (
    isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
    not isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
  ):
    # try left side:
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] = eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK]
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] = eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_FORWARD]
    if (
      isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
      not isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
    ):
      # try right side:
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] = eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK]
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] = eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_FORWARD]
      if (
        isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
        not isInLoS(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD], eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
      ):
        FailedBarrierDeploySub()
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        return

  eventPlayer.isActiveBarrier = true
  eventPlayer.barrierCheckVectA = eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD]
  eventPlayer.barrierCheckVectB = eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK]

#!define RAM_BARRIER_PUSH_ENENT_WAIT 0.1
rule "[Ramattra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isActiveBarrier

  list0 = getRealPlayersInRadius(eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK], 3, Team.ZOMBIES)
  list0.append([player for player in getRealPlayersInRadius(eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK], 3, Team.ZOMBIES) if player not in list0])

  list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.damageFromBarrier(list0)
  eventPlayer.damageBarrier(2.2 * RAM_BARRIER_PUSH_ENENT_WAIT * len(list0))

  [player for player in list0 if (
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK]) > 
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_DIRECTION],
    3,
    Relativity.TO_WORLD
  )

  [player for player in list0 if (
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK]) < 
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_BACK_DIRECTION],
    3,
    Relativity.TO_WORLD
  )

  wait(RAM_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
    loop()

rule "[Ramattra] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isActiveBarrier
  
  waitUntil(
    isInLoS(
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK],
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD],
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    10
  )
  ClearBarrierStateSub()


# rule "[debug]":
  # hudHeader(
  #   eventPlayer,
  #   "CD: {}, Using:{}, Res:{}, Ch: {}".format(
  #     eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE),
  #     eventPlayer.isFiringSecondaryFire(),
  #     eventPlayer.getAbilityResource(Button.SECONDARY_FIRE),
  #     eventPlayer.getAbilityCharge(Button.SECONDARY_FIRE)
  #   ),
  #   HudPosition.TOP,
  #   0,
  #   Color.WHITE,
  #   HudReeval.VISIBILITY_AND_STRING,
  #   SpecVisibility.ALWAYS
  # )

  # debug:
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.LIGHT_RED,
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.LIME_GREEN,
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.YELLOW,
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.YELLOW,
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   rgb(45, 187, 209, 20),
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK],
  #   1.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   rgb(45, 187, 209, 20),
  #   eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK],
  #   1.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )