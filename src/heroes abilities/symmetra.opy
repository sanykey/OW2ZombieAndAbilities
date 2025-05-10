#!mainFile "../main.opy"

# useful links:
# - [Shield Tracking](https://workshop.codes/XQG9N)

#!define SYM_ULT_DURATION 12
#!define SYM_BARRIER_PUSH_ENENT_WAIT 0.3

rule "[Symmetra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SYMMETRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 2
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg91bbd1FF>Symmetra</fg>:\n
  {} {}Photon barrier{}:
    - Pushes back enemies and takes damage on contact.
    - On deployment, deals damage to nearby enemies equal to 50% of their maximum health..
    - If the barrier malfunctions, a message will appear and your ultimate charge will be refunded.
  ".format(
    heroIcon(Hero.SYMMETRA),
    abilityIconString(Hero.SYMMETRA, Button.ULTIMATE),
    "<fg91bbd1FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.SYMMETRA, INFINITY)
  clearHeroInfo()


# variables:
# abilPos0: Barrier position
# abilPos1: Barrier position without height
# abilPos2: Barrier checker position A
# abilPos3: Barrier checker position B
# temp1: Calc. (Sym position or Barrier position) + height for Barrier checker positions
# temp2: Player position when ult started
# temp3: Barrier direction. boolean: false = Sideways, true = Forward
# abilDir1: Barrier direction perpendicular vector
# abilTemp1: For the first range check from players to deal damage to them
rule "[Symmetra] Create barrier (ultimate)":
  @Event eachPlayer
  @Hero symmetra
  @Condition eventPlayer.isAlive() == true
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

  eventPlayer.temp3 = true # Barrier direction. boolean: false = Sideways, true = Forward
  eventPlayer.abilPos0 = false # Barrier position

  while true:
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), 99999)
    eventPlayer.temp3 = not eventPlayer.temp3 # chage barrier direction

    waitUntil(not eventPlayer.isAlive() or any([eventPlayer.isHoldingButton(i) for i in [
      Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE, Button.ABILITY_1, Button.ABILITY_2
    ]]), INFINITY)

    if (
      not eventPlayer.isAlive() or
      eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or
      eventPlayer.isHoldingButton(Button.ABILITY_1) or
      eventPlayer.isHoldingButton(Button.ABILITY_2)
    ):
      return

    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.isUsingUltimate():
      break

    wait(0.1)

  # start creating barrier::

  eventPlayer.abilPos0 = raycast( # get barrier position
    raycast(
      eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, eventPlayer, true
    ).getHitPosition() + vect(0, 0.01, 0), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0) - vect(0, 3, 0), null, eventPlayer, true
  ).getHitPosition()
  eventPlayer.abilPos1 = vect(eventPlayer.abilPos0.x, 0, eventPlayer.abilPos0.z) # Barrier position without height

  eventPlayer.abilDir1 = normalize(crossProduct( # Barrier direction perpendicular vector
    worldVector( # get barrier direction vector
      Vector.LEFT if eventPlayer.temp3 == false else Vector.FORWARD, eventPlayer, Transform.ROTATION
    ), 
    Vector.UP
  ))

  eventPlayer.temp2 = eventPlayer.getEyePosition()
  wait(0.65) # Waiting for the game to create a barrier

  # Create barrier checker and damager positions:
  eventPlayer.temp1 = ((eventPlayer.temp2 if eventPlayer.temp3 else eventPlayer.abilPos0) + Vector.UP * 45) 
  eventPlayer.abilPos2 = eventPlayer.temp1 + eventPlayer.abilDir1 * (0.2 if eventPlayer.temp3 else 1.5)
  eventPlayer.abilPos3 = eventPlayer.temp1 + eventPlayer.abilDir1 * (-0.2 if eventPlayer.temp3 else -1.5)

  if (
    isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
    not isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.PASS_THROUGH_BARRIERS)
  ):
    # Perhaps the roof blocked the view between the barrier check vectors. Try setting the vectors much lower
    eventPlayer.temp1 = ((eventPlayer.temp2 if eventPlayer.temp3 else eventPlayer.abilPos0) + Vector.UP * 1.5) 
    eventPlayer.abilPos2 = eventPlayer.temp1 + eventPlayer.abilDir1 * 0.2
    eventPlayer.abilPos3 = eventPlayer.temp1 + eventPlayer.abilDir1 * -0.2
    if (
      isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
      not isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.PASS_THROUGH_BARRIERS)
    ):
      eventPlayer.setUltCharge(100)
      smallMessage(eventPlayer, "Barrier deploy failed! Try again")
      return

  eventPlayer.state[SI.BARRIER_DAMAGE_FROM] = eventPlayer.abilPos2
  eventPlayer.state[SI.BARRIER_DAMAGE_DIR] = normalize(eventPlayer.abilPos3 - eventPlayer.abilPos2)
  eventPlayer.state[SI.BARRIER_ACTIVE] = true
  eventPlayer.abilTemp1 = true # For the first range check from players to deal damage to them
  # smallMessage(eventPlayer, "barrier up")

rule "[Symmetra] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]
  
  waitUntil(
    isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS), SYM_ULT_DURATION
  )
  eventPlayer.state[SI.BARRIER_ACTIVE] = false
  eventPlayer.state[SI.BARRIER_DAMAGE_STACK] = false

rule "[Symmetra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.state[SI.BARRIER_ACTIVE]

  eventPlayer.list = [player for player in getPlayers(Team.2) if player.isAlive()]
  eventPlayer.list2 = [] # players to push one side
  eventPlayer.list3 = [] # players to push second side

  for eventPlayer.I in range(len(eventPlayer.list)):
    eventPlayer.temp1 = dotProduct( # distance between player and barrier
      vect(eventPlayer.list[eventPlayer.I].getPosition().x, 0, eventPlayer.list[eventPlayer.I].getPosition().z) - eventPlayer.abilPos1,
      eventPlayer.abilDir1
    )

    # get players to push from barrier
    if abs(eventPlayer.temp1) < 3:
      eventPlayer.state[SI.BARRIER_DAMAGE_STACK] += (TORBJORN_HAMMER_BASE_DMG * (zombieStats[ZI.DAMAGE_STAT] / 100)) * SYM_BARRIER_PUSH_ENENT_WAIT

      if eventPlayer.temp1 > 0:
        eventPlayer.list2.append(eventPlayer.list[eventPlayer.I])
      else:
        eventPlayer.list3.append(eventPlayer.list[eventPlayer.I])


  if (len(eventPlayer.list2)):
    eventPlayer.list2.applyImpulse(
      eventPlayer.abilDir1 + vect(0, 0.2679, 0),
      7,
      Relativity.TO_WORLD
    )
    wait(0.016)
  if (len(eventPlayer.list3)):
    eventPlayer.list3.applyImpulse(
      eventPlayer.abilDir1 * -1 + vect(0, 0.2679, 0),
      7,
      Relativity.TO_WORLD
    )


  eventPlayer.list2.append(eventPlayer.list3)
  # save information about bots being pushed to account for damage when falling down
  eventPlayer.list2.state[SI.LAST_CC_ATTACKER] = eventPlayer
  eventPlayer.list2.state[SI.LAST_CC_ATTACK_TIME] = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.list2.state[SI.LAST_CC_WAS_IN_AIR] = false

  # damage enemies on barrier deployment
  if eventPlayer.abilTemp1:
    eventPlayer.abilTemp1 = false
    for eventPlayer.I in range(len(eventPlayer.list2)):
      # todo: optimize?
      damage(eventPlayer.list2[eventPlayer.I], eventPlayer, ceil(eventPlayer.list2[eventPlayer.I].getMaxHealth() / 2))
  
  wait(SYM_BARRIER_PUSH_ENENT_WAIT) # Higher values cause enemies to pass through the barrier
  if ruleCondition:
      loop()


# rule "[Symmetra] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero symmetra

#   hudHeader(
#     eventPlayer,
#     "DIR: {}, Active: {}, USING ULT: {}
#     ".format(
#       eventPlayer.temp3,
#       eventPlayer.state[SI.BARRIER_ACTIVE],
#       eventPlayer.isUsingUltimate()
#     ),
#     HudPosition.TOP,
#     0,
#     Color.WHITE,
#     HudReeval.VISIBILITY_AND_STRING,
#     SpecVisibility.ALWAYS
#   )

#   # debug:
#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.abilPos0,
#     0.4,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.RED,
#     eventPlayer.abilPos2,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.RED,
#     eventPlayer.abilPos3,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )