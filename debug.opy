#!mainFile "main.opy"

rule "[debug] Add money and health":
  @Event playerJoined
  @Team 1
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 1000000
  eventPlayer.health_stat += 10000
  eventPlayer.setMaxHealth(eventPlayer.health_stat)

  # eventPlayer.healing_stat += 10000
  # eventPlayer.setHealingDealt(eventPlayer.healing_stat)
  # eventPlayer.stateArr[stateI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY + 0 if eventPlayer.healing_stat < 100 else ceil(HEAL_AMOUNT_FOR_MONEY * (eventPlayer.healing_stat / 500))

rule "Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
  # @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    roundRemainingBots += 12
    damage(getPlayers(Team.2), getPlayers(Team.2), 99999)
    smallMessage(eventPlayer, "Bots disabled")
  else:
    isBotsDisabled = false
    smallMessage(eventPlayer, "Bots enabled")


rule "Init":
  @Condition roundNumber == 1
  
  isBotsDisabled = false
  # server loading stats:
  hudText(getPlayersInSlot(0, Team.1), getServerLoad(), getAverageServerLoad(), getPeakServerLoad(), HudPosition.LEFT, 7, Color.GREEN, Color.ORANGE, Color.RED, HudReeval.VISIBILITY_AND_STRING)
  # Player 1 current coordinates
  hudSubtext(getPlayersInSlot(0, Team.1), "P1: {0}".format(getPlayersInSlot(0, Team.1).getPosition()), HudPosition.TOP, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  hudSubtext(getPlayersInSlot(0, Team.1), "Current [{0}] vect: {1}".format(debugCurrentVectNum, debugVectsArr[debugCurrentVectNum].getPosition()), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)

  hudSubtext(getPlayersInSlot(0, Team.1), "Healing {0} < {1}".format(getPlayersInSlot(0, Team.1).stateArr[stateI.HEALING_TRACKER] ,getPlayersInSlot(0, Team.1).stateArr[stateI.HEALING_TRACKER_THRESHOLD]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)

  
rule "Show beam and info to current debugging vector":
  @Event eachPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  debugVectsArr = []
  for I in range(13, 24):
    debugVectsArr[I - 13] = vectList[I]

  if debugCurrentVectNum >= len(debugVectsArr) - 1:
    debugCurrentVectNum = 0
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr)))
  else:
    debugCurrentVectNum += 1
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr)))
  
  destroyEffect(debugCurrentVectEffectArr[0])
  destroyEffect(debugCurrentVectEffectArr[1])
  createBeam(
    getAllPlayers(),
    Beam.GOOD,
    eventPlayer.getEyePosition() + vect(0, -0.25, 0),
    debugVectsArr[debugCurrentVectNum], 
    Color.GREEN,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugCurrentVectEffectArr[0] = getLastCreatedEntity()

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    debugVectsArr[debugCurrentVectNum],
    1,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugCurrentVectEffectArr[1] = getLastCreatedEntity()


    