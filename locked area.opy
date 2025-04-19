#!mainFile "main.opy"

rule "Create location buy positions":
  @Condition roundNumber == 1

  # [position_vector, price]
  location_buy_positions_arr = [
    [vect(7.613, 5.326, -34.916), 2500],
    [vect(31.577, 6.126, -62.399), 5000],
    [vect(99.296, 13.977, -72.064), 7500],
    [vect(86.651, 14.036, -32.931), 5000],
  ]
  T = []
  for I in range(len(location_buy_positions_arr)):
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, location_buy_positions_arr[I][0], 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), location_buy_positions_arr[I][1])), location_buy_positions_arr[I][0], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    T.append(getLastCreatedText())

rule "Blocked area setup effects":
  @Condition roundNumber == 1

  W = []
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(12.505, 5.485, -40.846), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(22.609, 6.314, -45.045), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(20.011, 6.314, -40.406), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(35.156, 7.335, -73.588), 3.25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(38.782, 6.526, -58.722), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(42.152, 6.553, -49.632), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(23.027, 11.884, -89.054), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(78.467, 14.036, -56.311), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(100.524, 14.045, -66.87), 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(89.352, 22.145, -62.564), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(107.37, 12.166, -33.617), 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(87.614, 14.166, -29.335), 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  W.append(getLastCreatedEntity())

rule "blocked area arrays":
  @Condition roundNumber == 1
  
  V = []
  V.append(vect(19, 7, -50.013))
  V.append(vect(40.631, 8.265, -77.59))
  V.append(vect(51.561, 8.095, -58.373))
  V.append(vect(23.088, 12.063, -89.42))
  V.append(vect(78.65, 14.171, -53.779))
  V.append(vect(103.219, 15.554, -60.019))
  V.append(vect(91.888, 22.491, -53.112))
  V.append(vect(87.651, 15, -28.387))
  V.append(vect(107.743, 12.171, -31.426))

rule "[Locked Area A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[0]) < 10
  @Condition unlocked_locations == 0
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[0], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[1]) < 10
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[2]) < 15
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[3]) < 5
  @Condition unlocked_locations == 1
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[4]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[5]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area G]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[6]) < 10
  @Condition unlocked_locations == 2
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area H]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[7]) < 4
  @Condition D == 0
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[7], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "[Locked Area I]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, V[8]) < 5
  @Condition D == 0
  @Condition match_is_over == false
  
  eventPlayer.applyImpulse(directionTowards(V[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START



rule "[Unlock Next Location A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(vect(7.598, 5.461, -34.812), eventPlayer) <= 2
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


rule "[Unlock Next Location B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(vect(31.805, 6.256, -62.43), eventPlayer) <= 2
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


rule "[Unlock Next Location C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(vect(99.352, 14.111, -71.796), eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlocked_locations == 2
  @Condition eventPlayer.money >= 7500
  
  unlocked_locations = 3
  D = 0
  destroyEffect(W[7])
  destroyEffect(W[8])
  destroyEffect(W[9])
  destroyEffect(T[4])
  destroyInWorldText(T[5])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 7500


rule "[Unlock Next Location D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(vect(86.643, 14.166, -33.07), eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition D == 0
  @Condition eventPlayer.money >= 5000
  
  D = 1
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
  @Condition D == 1
  
  W = []
  V = []
  U = []