#!mainFile "../main.opy"

#!define RAM_BARRIER_PUSH_ENENT_WAIT 0.1

enum RAMMATTRA_I:
  BARRIER_CENTER = 1
  BARRIER_CHECK_BACK = 2
  BARRIER_CHECK_FORWARD = 3
  BARRIER_LEFT_BACK = 4
  BARRIER_LEFT_FORWARD = 5
  BARRIER_RIGHT_BACK = 6
  BARRIER_RIGHT_FORWARD = 7
  BARRIER_PUSH_DIRECTION = 8
  BARRIER_PUSH_BACK_DIRECTION = 9

rule "[Ramattra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.RAMATTRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg9d8cd0FF>Rammatra</fg>:\n
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
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.LIME_GREEN,
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.YELLOW,
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   Color.YELLOW,
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_BACK],
  #   0.05,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   rgb(45, 187, 209, 20),
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_BACK],
  #   1.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )
  # createEffect(
  #   getPlayersInSlot(0, Team.1),
  #   Effect.SPHERE,
  #   rgb(45, 187, 209, 20),
  #   eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_BACK],
  #   1.5,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

rule "[Ramattra] Barrier up":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.isFiringSecondaryFire() == true
  @Condition (eventPlayer.isUsingAbility1() or eventPlayer.isUsingUltimate()) == false

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

  eventPlayer.heroState[RAMMATTRA_I.BARRIER_CENTER] = eventPlayer.temp2
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] = eventPlayer.temp2
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD] = eventPlayer.temp3
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_BACK] = eventPlayer.temp2 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_FORWARD] = eventPlayer.temp3 + normalize(crossProduct(Vector.UP, eventPlayer.getFacingDirection())) * 1.5
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_BACK] = eventPlayer.temp2 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_FORWARD] = eventPlayer.temp3 + normalize(crossProduct(eventPlayer.getFacingDirection(), Vector.UP)) * 1.5
  
  eventPlayer.heroState[RAMMATTRA_I.BARRIER_PUSH_DIRECTION] = (
    normalize(
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD] - eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] + vect(0, 0.2679, 0)
    )
  )

  eventPlayer.heroState[RAMMATTRA_I.BARRIER_PUSH_BACK_DIRECTION] = (
    normalize(
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] - eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD] + vect(0, 0.2679, 0)
    )
  )

  wait(0.16)
  # try center:
  if (
    isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
    not isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
  ):
    # try left side:
    eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] = eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_BACK]
    eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD] = eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_FORWARD]
    if (
      isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
      not isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
    ):
      # try right side:
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] = eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_BACK]
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD] = eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_FORWARD]
      if (
        isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
        not isInLoS(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD], eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK], BarrierLos.PASS_THROUGH_BARRIERS)
      ):
        smallMessage(eventPlayer, "Barrier deploy failed! Try again")
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        return

  eventPlayer.state[SI.BARRIER_ACTIVE] = true

  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD]
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK] - eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD])


rule "[Ramattra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]

  eventPlayer.list = getPlayersInRadius(eventPlayer.heroState[RAMMATTRA_I.BARRIER_RIGHT_BACK], 3, Team.2)
  eventPlayer.list.append([player for player in getPlayersInRadius(eventPlayer.heroState[RAMMATTRA_I.BARRIER_LEFT_BACK], 3, Team.2) if player not in eventPlayer.list])

  # save information about bots being pushed to account for damage when falling down
  eventPlayer.list.lastCcAttacker = eventPlayer
  eventPlayer.list.lastCcAttackTime = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list.lastCcWasInAir = false

  [player for player in eventPlayer.list if (
    distance(player, eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK]) > 
    distance(player, eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroState[RAMMATTRA_I.BARRIER_PUSH_DIRECTION],
    6,
    Relativity.TO_WORLD
  )
  wait(0.016)
  [player for player in eventPlayer.list if (
    distance(player, eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK]) < 
    distance(player, eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD])
  )].applyImpulse(
    eventPlayer.heroState[RAMMATTRA_I.BARRIER_PUSH_BACK_DIRECTION],
    6,
    Relativity.TO_WORLD
  )

  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += len(eventPlayer.list) * (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) * RAM_BARRIER_PUSH_ENENT_WAIT

  wait(RAM_BARRIER_PUSH_ENENT_WAIT)
  if ruleCondition:
      loop()

rule "[Ramattra] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero ramattra
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]
  
  waitUntil(
    isInLoS(
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_BACK],
      eventPlayer.heroState[RAMMATTRA_I.BARRIER_CHECK_FORWARD],
      BarrierLos.BLOCKED_BY_ALL_BARRIERS
    ),
    10
  )
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false
