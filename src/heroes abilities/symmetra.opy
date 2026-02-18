#!mainFile "../main.opy"

# useful links:
# - [Shield Tracking](https://workshop.codes/XQG9N)

#!define SYM_ULT_DURATION 12


rule "[Symmetra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SYMMETRA

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg91bbd1FF>Symmetra</fg>:\n
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
# tmp1: Calc. (Sym position or Barrier position) + height for Barrier checker positions
# tmp2: Player position when ult started
# tmp3: Barrier direction. boolean: false = Sideways, true = Forward
# abilDir1: Barrier direction perpendicular vector
# abilTemp1: For the first range check from players to deal damage to them
rule "[Symmetra] Create barrier (ultimate)":
  @Event eachPlayer
  @Hero symmetra
  @Condition eventPlayer.isAlive() == true
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

  eventPlayer.tmp3 = true # Barrier direction. boolean: false = Sideways, true = Forward
  eventPlayer.abilPos0 = false # Barrier position

  while true:
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), 99999)
    eventPlayer.tmp3 = not eventPlayer.tmp3 # chage barrier direction

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
      Vector.LEFT if eventPlayer.tmp3 == false else Vector.FORWARD, eventPlayer, Transform.ROTATION
    ), 
    Vector.UP
  ))

  eventPlayer.tmp2 = eventPlayer.getEyePosition()
  wait(0.65) # Waiting for the game to create a barrier

  # Create barrier checker and damager positions:
  eventPlayer.tmp1 = ((eventPlayer.tmp2 if eventPlayer.tmp3 else eventPlayer.abilPos0) + Vector.UP * 45) 
  eventPlayer.abilPos2 = eventPlayer.tmp1 + eventPlayer.abilDir1 * (0.2 if eventPlayer.tmp3 else 1.5)
  eventPlayer.abilPos3 = eventPlayer.tmp1 + eventPlayer.abilDir1 * (-0.2 if eventPlayer.tmp3 else -1.5)

  if (
    isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
    not isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.PASS_THROUGH_BARRIERS)
  ):
    # Perhaps the roof blocked the view between the barrier check vectors. Try setting the vectors much lower
    eventPlayer.tmp1 = ((eventPlayer.tmp2 if eventPlayer.tmp3 else eventPlayer.abilPos0) + Vector.UP * 1.5) 
    eventPlayer.abilPos2 = eventPlayer.tmp1 + eventPlayer.abilDir1 * 0.2
    eventPlayer.abilPos3 = eventPlayer.tmp1 + eventPlayer.abilDir1 * -0.2
    if (
      isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
      not isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.PASS_THROUGH_BARRIERS)
    ):
      eventPlayer.setUltCharge(100)
      smallMessage(eventPlayer, "Barrier deploy failed! Try again")
      return

  eventPlayer.barrierDamageFrom = eventPlayer.abilPos2
  eventPlayer.barrierDamageDir = normalize(eventPlayer.abilPos3 - eventPlayer.abilPos2)
  eventPlayer.isActiveBarrier = true
  eventPlayer.abilTemp1 = true # For the first range check from players to deal damage to them
  # smallMessage(eventPlayer, "barrier up")

rule "[Symmetra] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.isActiveBarrier
  
  waitUntil(
    isInLoS(eventPlayer.abilPos2, eventPlayer.abilPos3, BarrierLos.BLOCKED_BY_ALL_BARRIERS), SYM_ULT_DURATION
  )
  eventPlayer.isActiveBarrier = false
  eventPlayer.barrierDamageStack = false

#!define SYM_BARRIER_PUSH_ENENT_WAIT 0.1

rule "[Symmetra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.isActiveBarrier

  eventPlayer.list0 = [player for player in getPlayers(Team.ZOMBIES) if player.isAlive()]
  eventPlayer.list1 = [] # players to push one side
  eventPlayer.list2 = [] # players to push second side

  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.tmp1 = dotProduct( # distance between player and barrier
      vect(eventPlayer.list0[eventPlayer.I].getPosition().x, 0, eventPlayer.list0[eventPlayer.I].getPosition().z) - eventPlayer.abilPos1,
      eventPlayer.abilDir1
    )

    # get players to push from barrier
    if abs(eventPlayer.tmp1) < 3:
      eventPlayer.barrierDamageStack += (
        TORBJORN_HAMMER_BASE_DMG 
        * 3
        * SYM_BARRIER_PUSH_ENENT_WAIT
        * (zomDamagePct / 100)
      )

      if eventPlayer.tmp1 > 0:
        eventPlayer.list1.append(eventPlayer.list0[eventPlayer.I])
      else:
        eventPlayer.list2.append(eventPlayer.list0[eventPlayer.I])


  if (len(eventPlayer.list1)):
    eventPlayer.list1.applyImpulse(
      eventPlayer.abilDir1 + barrierPushVectUpFix,
      5,
      Relativity.TO_WORLD
    )
    wait(0.016)
  if (len(eventPlayer.list2)):
    eventPlayer.list2.applyImpulse(
      eventPlayer.abilDir1 * -1 + barrierPushVectUpFix,
      5,
      Relativity.TO_WORLD
    )

  eventPlayer.list1.append(eventPlayer.list2)
  eventPlayer.list1.setCrowdControlAttack(eventPlayer)
  damage(eventPlayer.list1, eventPlayer, 0.1)

  # damage enemies on barrier deployment
  if eventPlayer.abilTemp1:
    eventPlayer.abilTemp1 = false
    for eventPlayer.I in range(len(eventPlayer.list1)):
      # todo: optimize?
      damage(eventPlayer.list1[eventPlayer.I], eventPlayer, ceil(eventPlayer.list1[eventPlayer.I].getMaxHealth() / 2))
  
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
#       eventPlayer.tmp3,
#       eventPlayer.isActiveBarrier,
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