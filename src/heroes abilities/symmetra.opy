#!mainFile "../main.opy"
#!optimizeForSize

# useful links:
# - [Shield Tracking](https://workshop.codes/XQG9N)

#!define SYM_BARRIER_PUSH_ENENT_WAIT 0.1
#!define SYM_ULT_DURATION 12

rule "[Symmetra] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SYMMETRA

  setHeroInfoText0(
    f"{heroIcon(Hero.SYMMETRA)} <fg91bbd1FF>Symmetra</fg>:\n
    {abilityIconString(Hero.SYMMETRA, Button.ULTIMATE)} <fg91bbd1FF>Photon barrier</fg>:
    - Pushes back enemies and takes damage on contact.
    - On deployment, deals damage to nearby enemies equal to 50% of their maximum health..
    - If the barrier malfunctions, a message will appear and your ultimate charge will be refunded.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.SYMMETRA, INFINITY)
  clearHeroInfoSub()

# variables:
# tmp1: Calc. (Sym position or Barrier position) + height for Barrier checker positions
# tmp2: Player position when ult started
# abilDir1: Barrier direction perpendicular vector
# abilTemp1: For the first range check from players to deal damage to them
rule "[Symmetra] Create barrier (ultimate)":
  @Event eachPlayer
  @Hero symmetra
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

  eventPlayer.heroState0 = true # Barrier direction. boolean: false = Sideways, true = Forward

  while true:
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), INFINITY)
    eventPlayer.heroState0 = not eventPlayer.heroState0 # change barrier direction

    waitUntil(not eventPlayer.isAlive() or any([eventPlayer.isHoldingButton(i) for i in [
      Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE, Button.ABILITY_1, Button.ABILITY_2
    ]]), INFINITY)

    if ( 
      not eventPlayer.isAlive() or
      eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or
      eventPlayer.isHoldingButton(Button.ABILITY_1) or
      eventPlayer.isHoldingButton(Button.ABILITY_2)
    ):
      return # Cancel barrier placement
    
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.isUsingUltimate():
      break # Confirm barrier placement

    wait(0.1)

  # start creating barrier::
  eventPlayer.heroState1 = raycast( # Barrier placement position
    raycast(
      eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, eventPlayer, true
    ).getHitPosition() + vect(0, 0.01, 0), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 25, null, eventPlayer, true).getHitPosition() + vect(0, 0.01, 0) - vect(0, 3, 0), null, eventPlayer, true
  ).getHitPosition()
  
  eventPlayer.heroState2 = normalize(crossProduct( # Barrier direction perpendicular vector
    worldVector( # get barrier direction vector
      Vector.LEFT if not eventPlayer.heroState0 else Vector.FORWARD, eventPlayer, Transform.ROTATION
    ), 
    Vector.UP
  ))

  # Player position during barrier placement. 
  #   Barrier placement position may be inaccurate, but the player's position is always precise—so it’s better to use that:
  eventPlayer.heroState3 = eventPlayer.getEyePosition() 
  
  wait(0.65) # Waiting for the game to create a barrier

  # Create barrier checker and damager positions:
  tmp1 = ((eventPlayer.heroState3 if eventPlayer.heroState0 else eventPlayer.heroState1) + Vector.UP * 45) 
  eventPlayer.barrierCheckVectA = tmp1 + eventPlayer.heroState2 * (0.2 if eventPlayer.heroState0 else 1.5)
  eventPlayer.barrierCheckVectB = tmp1 + eventPlayer.heroState2 * (-0.2 if eventPlayer.heroState0 else -1.5)

  if (
    isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
    not isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.PASS_THROUGH_BARRIERS)
  ):
    # Perhaps the roof blocked the view between the barrier check vectors. Try setting the vectors much lower
    tmp1 = ((eventPlayer.heroState3 if eventPlayer.heroState0 else eventPlayer.heroState1) + Vector.UP * 1.5) 
    eventPlayer.barrierCheckVectA = tmp1 + eventPlayer.heroState2 * 0.2
    eventPlayer.barrierCheckVectB = tmp1 + eventPlayer.heroState2 * -0.2
    if (
      isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.BLOCKED_BY_ALL_BARRIERS) or
      not isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.PASS_THROUGH_BARRIERS)
    ):
      eventPlayer.setUltCharge(100)
      FailedBarrierDeploySub()
      return

  eventPlayer.isActiveBarrier = true
  eventPlayer.heroState4 = true # For the first range check from players to deal damage to them

rule "[Symmetra] Check is barrier exists":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.isActiveBarrier
  
  waitUntil(
    isInLoS(eventPlayer.barrierCheckVectA, eventPlayer.barrierCheckVectB, BarrierLos.BLOCKED_BY_ALL_BARRIERS), SYM_ULT_DURATION
  )
  ClearBarrierStateSub()

rule "[Symmetra] Barrier push enemies":
  @Event eachPlayer
  @Team 1
  @Hero symmetra
  @Condition eventPlayer.isActiveBarrier

  list0 = getNumberOfPlayers(Team.ZOMBIES)
  list1 = [] # players to push one side
  list2 = [] # players to push second side

  tmp0 = vect(eventPlayer.heroState1.x, 0, eventPlayer.heroState1.z) # Barrier position without height

  for I in range(len(list0)):
    tmp1 = dotProduct( # distance between player and barrier
      vect(list0[I].getPosition().x, 0, list0[I].getPosition().z) - tmp0,
      eventPlayer.heroState2
    )

    # get players to push from barrier
    if abs(tmp1) < 3:
      if tmp1 > 0:
        list1.append(list0[I])
      else:
        list2.append(list0[I])


  if (len(list1)):
    list1.applyImpulse(
      eventPlayer.heroState2 + BarrierPushVectUpFixConst,
      5,
      Relativity.TO_WORLD
    )
    wait()
  if (len(list2)):
    list2.applyImpulse(
      eventPlayer.heroState2 * -1 + BarrierPushVectUpFixConst,
      5,
      Relativity.TO_WORLD
    )

  list1.append(list2)
  list1.setCrowdControlAttack(eventPlayer)
  eventPlayer.damageBarrier(3 * SYM_BARRIER_PUSH_ENENT_WAIT * len(list1))
  eventPlayer.damageFromBarrier(list1)

  if eventPlayer.heroState4: # damage enemies on barrier deployment
    eventPlayer.heroState4 = false
    for I in range(len(list1)):
      damage(list1[I], eventPlayer, ceil(list1[I].getMaxHealth() / 2))
  
  wait(SYM_BARRIER_PUSH_ENENT_WAIT) # Higher values cause enemies to pass through the barrier
  if ruleCondition:
    loop()


# rule "[Symmetra] debug":
#   @Event eachPlayer
#   @Team 1
#   @Hero symmetra

#   debug(eventPlayer.heroState0)
#   debug(eventPlayer.heroState1)
#   debug(eventPlayer.heroState2)
#   debug(eventPlayer.heroState3)
#   debug(eventPlayer.heroState4)
#   debug(eventPlayer.isActiveBarrier)
#   debug(eventPlayer.barrierCheckVectA)
#   debug(eventPlayer.barrierCheckVectB)

#   # debug:
#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.LIGHT_RED,
#     eventPlayer.heroState1,
#     0.4,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.RED,
#     eventPlayer.barrierCheckVectA,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.RED,
#     eventPlayer.barrierCheckVectB,
#     0.05,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )