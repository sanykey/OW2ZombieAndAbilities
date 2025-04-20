#!mainFile "main.opy"

rule "Create location buy positions":
  @Condition roundNumber == 1
  
  # init vectors
  lockedAreaVectsArrCompressed = compress([
    # Effects for purchase access to prohibited zone [0-3]
    vect(7.613, 5.326, -34.916),
    vect(31.577, 6.126, -62.399),
    vect(99.296, 13.977, -72.064),
    vect(86.651, 14.036, -32.931),

    # Areas in doorways that push away approaching players when the doorway is not yet open [4-12] 
    vect(19, 7, -50.013),
    vect(40.631, 8.265, -77.59),
    vect(51.561, 8.095, -58.373),
    vect(23.088, 12.063, -89.42),
    vect(78.65, 14.171, -53.779),
    vect(103.219, 15.554, -60.019),
    vect(91.888, 22.491, -53.112),
    vect(87.651, 15, -28.387),
    vect(107.743, 12.171, -31.426),

    # Effects for forbidden zones in doorways [13-24]
    vect(12.505, 5.485, -40.846),
    vect(22.609, 6.314, -45.045),
    vect(20.011, 6.314, -40.406),
    vect(35.156, 7.335, -73.588),
    vect(38.782, 6.526, -58.722),
    vect(42.152, 6.553, -49.632),
    vect(23.027, 11.884, -89.054),
    vect(78.467, 14.036, -56.311),
    vect(100.524, 14.045, -66.87),
    vect(89.352, 22.145, -62.564),
    vect(107.37, 12.166, -33.617),
    vect(87.614, 14.166, -29.335),

    # Large zones that teleport the player away from themselves if the player manages to pass through a forbidden doorway [25-30]
    vect(13.044, 9.697, -73.344),
    vect(52.662, 9.768, -31.962),
    vect(59.416, 19.498, -77.513),
    vect(95.991, 12.171, -38.315),
    vect(104.593, 16, -22.372),
    vect(89.614, 18, -19.296),

    # Places where players are teleported to if players try to enter forbidden areas [31-36]
    vect(13.466, 4.35, -34.792),
    vect(27.294, 6.507, -25.489),
    vect(25.171, 6.554, -64.938),
    vect(76.454, 14.112, -65.339),
    vect(106.979, 12.171, -37.458),
    vect(86.536, 14.171, -37.365)
  ])
  lockedAreaVectsArr = decompressVectors(lockedAreaVectsArrCompressed)

  # Create buy location positions and effects
  # [position_vector, price]
  # location_buy_positions_arr = [2500, 5000, 7500, 5000]
  T = []
  for I in range(len(location_buy_positions_arr)):
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, lockedAreaVectsArr[I], 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(
      getPlayers(Team.1),
      l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 2500 * (I + 1))),
      lockedAreaVectsArr[I],
      1,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY
    )
    T.append(getLastCreatedText())

  W = []
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[13], 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[14], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[15], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[16], 3.25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[17], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[18], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[19], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[20], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[21], 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[22], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[23], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, lockedAreaVectsArr[24], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())

rule "Locked area 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[4]) < 10
  @Condition unlocked_locations == 0
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[5]) < 10
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[6]) < 15
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[7]) < 5
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[8]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[9]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 6":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[10]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 7":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[11]) < 4
  @Condition unlocked_locations != 4
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[11], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 8":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[12]) < 5
  @Condition unlocked_locations != 4
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(lockedAreaVectsArr[12], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START

rule "Teleport from restricted area 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[25]) < 35
  @Condition unlocked_locations == 0
  
  eventPlayer.teleport(lockedAreaVectsArr[31])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[26]) < 15
  @Condition unlocked_locations == 0
  
  eventPlayer.teleport(lockedAreaVectsArr[32])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[27]) < 30
  @Condition unlocked_locations == 1
  
  eventPlayer.teleport(lockedAreaVectsArr[33])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[28]) < 25
  @Condition unlocked_locations == 2
  
  eventPlayer.teleport(lockedAreaVectsArr[34])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[29]) < 4
  @Condition unlocked_locations != 4
  
  eventPlayer.teleport(lockedAreaVectsArr[35])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, lockedAreaVectsArr[30]) < 4
  @Condition unlocked_locations != 4
  
  eventPlayer.teleport(lockedAreaVectsArr[36])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Unlock next location A":
  @Event eachPlayer
  @Team 1
  @Condition distance(lockedAreaVectsArr[0], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlocked_locations == 0
  @Condition eventPlayer.money >= 2500
  
  unlocked_locations = 1
  destroyEffect(W[0])
  destroyEffect(W[1])
  destroyEffect(W[2])
  destroyEffect(T[0])
  destroyInWorldText(T[1])
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 2500


rule "Unlock next location B":
  @Event eachPlayer
  @Team 1
  @Condition distance(lockedAreaVectsArr[1], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlocked_locations == 1
  @Condition eventPlayer.money >= 5000
  
  unlocked_locations = 2
  destroyEffect(W[3])
  destroyEffect(W[4])
  destroyEffect(W[5])
  destroyEffect(W[6])
  destroyEffect(T[2])
  destroyInWorldText(T[3])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 5000


rule "Unlock next location C":
  @Event eachPlayer
  @Team 1
  @Condition distance(lockedAreaVectsArr[2], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlocked_locations == 2
  @Condition eventPlayer.money >= 7500
  
  unlocked_locations = 3
  destroyEffect(W[7])
  destroyEffect(W[8])
  destroyEffect(W[9])
  destroyEffect(T[4])
  destroyInWorldText(T[5])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 7500


rule "Unlock next location D":
  @Event eachPlayer
  @Team 1
  @Condition distance(lockedAreaVectsArr[3], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlocked_locations == 3
  @Condition eventPlayer.money >= 5000
  
  unlocked_locations = 4
  destroyEffect(W[10])
  destroyEffect(W[11])
  destroyEffect(T[6])
  destroyInWorldText(T[7])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 5000

rule "Clear locked areas data when everything is open":
  @Condition unlocked_locations == 4
  W = []
  lockedAreaVectsArr = []