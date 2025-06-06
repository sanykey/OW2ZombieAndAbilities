#!mainFile "../main.opy"

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
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg9d8cd0FF>Rammatra</fg>:\n
  {} {}Void barrier{}:
      - Pushes back enemies and takes damage on contact.
      - If the barrier malfunctions, a message will appear and the ability cooldown is refunded.
  ".format(
    heroIcon(Hero.RAMATTRA),
    abilityIconString(Hero.RAMATTRA, Button.SECONDARY_FIRE),
    "<fg9d8cd0FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.RAMATTRA, INFINITY)
  clearHeroInfo()


rule "[Ramattra] Barrier up":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isFiringSecondaryFire()
  @Condition not (eventPlayer.isUsingAbility1() or eventPlayer.isUsingUltimate())

  waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)
  if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
    return

  eventPlayer.temp1 = raycast(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 35, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 35, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0) - vect(0, 3, 0), null, eventPlayer, true).getHitPosition()
  
  # eventPlayer.temp2 = getPlayersInRadius(eventPlayer.temp1, 3.5, Team.2)
  # #Barrier launches away
  # eventPlayer.temp2.applyImpulse(vectorTowards(eventPlayer.getPosition(), eventPlayer.temp1) + vect(0, 5, 0), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  # playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.PURPLE, eventPlayer.temp1, 3)

  eventPlayer.temp2 = eventPlayer.temp1 + normalize(vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)) * 0.1 + Vector.UP * 1.5
  eventPlayer.temp3 = eventPlayer.temp1 + normalize(vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)) * 0.8 + Vector.UP * 1.5

  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CENTER] = eventPlayer.temp2
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] = eventPlayer.temp2
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] = eventPlayer.temp3
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK] = eventPlayer.temp2 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_FORWARD] = eventPlayer.temp3 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK] = eventPlayer.temp2 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_FORWARD] = eventPlayer.temp3 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  
  eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_DIRECTION] = (
    normalize(
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] - eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] + vect(0, 0.2679, 0)
    )
  )

  eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_BACK_DIRECTION] = (
    normalize(
      eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] - eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD] + vect(0, 0.2679, 0)
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
        smallMessage(eventPlayer, "Barrier deploy failed! Try again")
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        return

  eventPlayer.isActiveBarrier = true

  eventPlayer.barrierDamageFrom = eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD]
  eventPlayer.barrierDamageDir = normalize(eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK] - eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD])

#!define RAM_BARRIER_PUSH_ENENT_WAIT 0.1
rule "[Ramattra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isActiveBarrier

  eventPlayer.list0 = getPlayersInRadius(eventPlayer.heroEffectsIds[RAM_I.BARRIER_RIGHT_BACK], 3, Team.2)
  eventPlayer.list0.append([player for player in getPlayersInRadius(eventPlayer.heroEffectsIds[RAM_I.BARRIER_LEFT_BACK], 3, Team.2) if player not in eventPlayer.list0])

  eventPlayer.list0.setCrowdControlAttack(eventPlayer)

  [player for player in eventPlayer.list0 if (
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK]) > 
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_DIRECTION],
    3,
    Relativity.TO_WORLD
  )
  wait(0.016)
  [player for player in eventPlayer.list0 if (
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_BACK]) < 
    distance(player, eventPlayer.heroEffectsIds[RAM_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroEffectsIds[RAM_I.BARRIER_PUSH_BACK_DIRECTION],
    3,
    Relativity.TO_WORLD
  )
  
  eventPlayer.barrierDamageStack += (
    len(eventPlayer.list0) *
    (TORBJORN_HAMMER_BASE_DMG  * RAM_BARRIER_PUSH_ENENT_WAIT * 2.2) *
    (botsDamageBoostPercent / 100)
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
  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false


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