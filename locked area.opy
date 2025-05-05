#!mainFile "main.opy"

rule "Create location buy positions":
  # Create buy location positions and effects. lockedAreaEffectsArr [0-7] indexes
  lockedAreaEffectsArr = []
  for I in range(4):
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, vectList[I], 1, EffectReeval.VISIBILITY)
    lockedAreaEffectsArr.append(getLastCreatedEntity())
    createInWorldText(
      getPlayers(Team.1),
      l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 2500 * (I + 1))),
      vectList[I],
      1,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY
    )
    lockedAreaEffectsArr.append(getLastCreatedText())

  ## Create closed doorway effects. lockedAreaEffectsArr [8-19] indexes: ##
  # doorways to Area A:
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[13], 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[14], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[15], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  
  # doorways to Area B:
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[16], 3.25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[17], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[18], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[19], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  
  # doorways to Area C:
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[20], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[21], 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[22], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  
  # doorways to Area D:
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[23], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())
  createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vectList[24], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  lockedAreaEffectsArr.append(getLastCreatedEntity())

rule "Locked area 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[4]) < 10
  @Condition unlockedLocations == 0
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[5]) < 10
  @Condition unlockedLocations == 1
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[6]) < 15
  @Condition unlockedLocations == 1
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[7]) < 5
  @Condition unlockedLocations == 1
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[8]) < 10
  @Condition unlockedLocations == 2
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[9]) < 10
  @Condition unlockedLocations == 2
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 6":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[10]) < 10
  @Condition unlockedLocations == 2
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[9], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 7":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[11]) < 4
  @Condition unlockedLocations != 4
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[11], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START


rule "Locked area 8":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[12]) < 5
  @Condition unlockedLocations != 4
  @Condition matchIsOver == false
  
  eventPlayer.applyImpulse(directionTowards(vectList[12], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.25)
  if RULE_CONDITION:
      goto RULE_START

rule "Teleport from restricted area 0":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[25]) < 35
  @Condition unlockedLocations == 0
  
  eventPlayer.teleport(vectList[31])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 1":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[26]) < 15
  @Condition unlockedLocations == 0
  
  eventPlayer.teleport(vectList[32])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 2":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[27]) < 30
  @Condition unlockedLocations == 1
  
  eventPlayer.teleport(vectList[33])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[28]) < 25
  @Condition unlockedLocations == 2
  
  eventPlayer.teleport(vectList[34])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 4":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[29]) < 4
  @Condition unlockedLocations != 4
  
  eventPlayer.teleport(vectList[35])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Teleport from restricted area 5":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[30]) < 4
  @Condition unlockedLocations != 4
  
  eventPlayer.teleport(vectList[36])
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "Unlock next location A":
  @Event eachPlayer
  @Team 1
  @Condition distance(vectList[vectListI.BUY_LOCATION_A], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlockedLocations == 0
  @Condition eventPlayer.money >= 2500
  
  unlockedLocations = 1
  # Remove closed doorway effects:
  destroyEffect(lockedAreaEffectsArr[8])
  destroyEffect(lockedAreaEffectsArr[9])
  destroyEffect(lockedAreaEffectsArr[10])

  destroyEffect(lockedAreaEffectsArr[0])
  destroyInWorldText(lockedAreaEffectsArr[1])
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 2500


rule "Unlock next location B":
  @Event eachPlayer
  @Team 1
  @Condition distance(vectList[vectListI.BUY_LOCATION_B], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlockedLocations == 1
  @Condition eventPlayer.money >= 5000
  
  unlockedLocations = 2
  # Remove closed doorway effects:
  destroyEffect(lockedAreaEffectsArr[11])
  destroyEffect(lockedAreaEffectsArr[12])
  destroyEffect(lockedAreaEffectsArr[13])
  destroyEffect(lockedAreaEffectsArr[14])

  destroyEffect(lockedAreaEffectsArr[2])
  destroyInWorldText(lockedAreaEffectsArr[3])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 5000


rule "Unlock next location C":
  @Event eachPlayer
  @Team 1
  @Condition distance(vectList[vectListI.BUY_LOCATION_C], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlockedLocations == 2
  @Condition eventPlayer.money >= 7500
  
  unlockedLocations = 3
  # Remove closed doorway effects:
  destroyEffect(lockedAreaEffectsArr[15])
  destroyEffect(lockedAreaEffectsArr[16])
  destroyEffect(lockedAreaEffectsArr[17])

  destroyEffect(lockedAreaEffectsArr[4])
  destroyInWorldText(lockedAreaEffectsArr[5])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 7500


rule "Unlock next location D":
  @Event eachPlayer
  @Team 1
  @Condition distance(vectList[vectListI.BUY_LOCATION_D], eventPlayer) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition unlockedLocations == 3
  @Condition eventPlayer.money >= 10000
  
  unlockedLocations = 4
  # Remove closed doorway effects:
  destroyEffect(lockedAreaEffectsArr[18])
  destroyEffect(lockedAreaEffectsArr[19])

  destroyEffect(lockedAreaEffectsArr[6])
  destroyInWorldText(lockedAreaEffectsArr[7])
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
  eventPlayer.money -= 10000

rule "Clear locked areas data when everything is open":
  @Condition unlockedLocations == 4
  lockedAreaEffectsArr = null