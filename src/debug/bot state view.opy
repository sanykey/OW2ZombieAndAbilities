#!mainFile "../main.opy"

#!define DEBUG_BOTS_SP_EFFECT_RADIUS 0.2
#!define DEBUG_BOTS_TARGET_LAST_POS_EFF_RADIUS 0.2

globalvar debugSelectedPlayer
globalvar debugSelectedPlayerEff
globalvar debugCommonBotsList = [Hero.TORBJORN, Hero.JUNKRAT, Hero.SYMMETRA]
globalvar debugCommonBotIndex
globalvar debugZombieBotsSpawnPointEffect
globalvar debugBotTargetLastPositionEffect

rule "[debug] add BotStateView debug mode":
  debugModesArr.append("BotStateView")

rule "[debug] init Bot state view mode":
  ConditionForInitMode("BotStateView")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 9

  if not debugSelectedPlayer:
    debugSelectedPlayer = getPlayersInSlot(0, Team.ZOMBIES)

  createIcon(
    localPlayer if (localPlayer.developer or localPlayer == hostPlayer) and debugSelectedPlayer else null,
    debugSelectedPlayer.getEyePosition() - Vector.UP * 0.1,
    Icon.RING_THICK,
    IconReeval.VISIBILITY_AND_POSITION,
    Color.ORANGE,
    true
  )
  debugSelectedPlayerEff = getLastCreatedEntity()

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    f"{debugMenuTitle(\"BotStateView\")}
    {debugSelectedActionText(1)}Round number (start): {leftArrowForMenuItem(1)} <fg84c951FF>{roundNumber}</fg> {rightArrowForMenuItem(1)}</fg>
    {debugSelectedActionText(2)}Place spawn point:</fg> <fg84c951FF>{debugZombieBotsSpawnPoint}</fg>
    {debugSelectedActionText(3)}Select closest to reticle</fg> <fg84c951FF>{heroIcon(hostPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES).getHero())} {hostPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES)}</fg> <fg94a0a544>[SHIFT]</fg>
    {debugSelectedActionText(4)}Current bot: {leftArrowForMenuItem(4)} <fg84c951FF>{heroIcon(debugSelectedPlayer.getHero())} {debugSelectedPlayer}</fg> {rightArrowForMenuItem(4)}</fg> <fg94a0a544>← [S_FIRE/P_FIRE] →</fg>
    {debugSelectedActionText(5)}Round bots slots: {leftArrowForMenuItem(5)} <fg84c951FF>{roundMaxBotsSlots}</fg> {rightArrowForMenuItem(5)}</fg>
    {debugSelectedActionText(6)}Max zombie bots (add/remove): {leftArrowForMenuItem(6)} <fg84c951FF>{wSettingsMaxZombieBots}</fg> {rightArrowForMenuItem(6)}</fg>
    {debugSelectedActionText(7)}Kill all bots</fg>
    {debugSelectedActionText(8)}Common bots (replace): {leftArrowForMenuItem(8)} <fg84c951FF>{heroIcon(debugCommonBotsList[debugCommonBotIndex])}</fg> {rightArrowForMenuItem(8)}</fg>
    {debugSelectedActionText(9)}Random heroes</fg>
    --------------------
    Total Time Elapsed: <fg84c951FF>{getTotalTimeElapsed()}</fg>
    health: <fg84c951FF>{debugSelectedPlayer.getHealth()}</fg>
    max health: <fg84c951FF>{debugSelectedPlayer.getMaxHealth()}</fg>
    ult charge: <fg84c951FF>{debugSelectedPlayer.getUltCharge()}</fg>
    pos: <fg84c951FF>{debugSelectedPlayer.getPosition()}</fg>
    facing dir: <fg84c951FF>{debugSelectedPlayer.getFacingDirection()}</fg>
    isBotRespawning: <fg84c951FF>{debugSelectedPlayer.isReady__isBotRespawning}</fg>
    Stuck Points: <fg84c951FF>{debugSelectedPlayer.money__botStuckTimes}</fg>
    Fly Through Walls Points: <fg84c951FF>{debugSelectedPlayer.botWantsWallPhasePoints}</fg>
    Target: <fg84c951FF>{debugSelectedPlayer.botTarget}</fg>
    Distance to target: <fg84c951FF>{distance(debugSelectedPlayer, debugSelectedPlayer.botTarget)}</fg>
    Horizontal speed: <fg84c951FF>{debugSelectedPlayer.getHorizontalSpeed()}</fg>
    Default speed: <fg84c951FF>{5.5 / 100 * zomSpeedPct}</fg>
    lastCcAttacker: <fg84c951FF>{debugSelectedPlayer.lastCcAttacker}</fg>
    lastCcAttackTime: <fg84c951FF>{debugSelectedPlayer.lastCcAttackTime}</fg>
    lastCcWasInAir: <fg84c951FF>{debugSelectedPlayer.lastCcWasInAir}</fg>
    botWidowmakerAvaliableSpawnSpots: <fg84c951FF>{botWidowmakerAvaliableSpawnSpots}</fg>
    botTargetLos: <fg84c951FF>{debugSelectedPlayer.botTargetLos}</fg>
    botTargetLastPosition: <fg84c951FF>{debugSelectedPlayer.botTargetLastPosition}</fg>
    ",
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)
  destroyIcon(debugSelectedPlayerEff)


rule "[debug] Select bot closest to reticle":
  RuleHeaderDebugPageInteractCondition("BotStateView")
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)

  debugSelectedPlayer = eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES)

rule "[debug] Fast next zombie bot":
  RuleHeaderDebugPageInteractCondition("BotStateView")
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

  debugSelectedPlayer = getPlayersInSlot(
    0 if (debugSelectedPlayer.getSlot() >= getNumberOfPlayers(Team.ZOMBIES) - 1) else debugSelectedPlayer.getSlot() + 1,
    Team.ZOMBIES
  )

rule "[debug] Fast prev zombie bot":
  RuleHeaderDebugPageInteractCondition("BotStateView")
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

  debugSelectedPlayer.stopForcingOutlineFor(getAllPlayers())
  debugSelectedPlayer = getPlayersInSlot(
    (getNumberOfPlayers(Team.ZOMBIES) - 1) if (debugSelectedPlayer.getSlot() == 0) else debugSelectedPlayer.getSlot() - 1,
    Team.ZOMBIES
  )
  debugSelectedPlayer.startForcingOutlineFor(localPlayer if (localPlayer.developer or localPlayer == hostPlayer) else null, false, Color.ORANGE)

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 1: # Round number (start) increase
    if roundNumber >= 250:
      roundNumber = 0
    else:
      roundNumber++

  elif debugSelectedAction == 4: # Current bot next
    debugSelectedPlayer = getPlayersInSlot(
      0 if (debugSelectedPlayer.getSlot() >= getNumberOfPlayers(Team.ZOMBIES) - 1) else debugSelectedPlayer.getSlot() + 1, 
      Team.ZOMBIES
    )

  elif debugSelectedAction == 5: # Round bots slots increase
    if roundMaxBotsSlots >= 30:
      roundMaxBotsSlots = 1
    else:
      roundMaxBotsSlots++

  elif debugSelectedAction == 6: # Max zombie bots (add/remove) increase
    if wSettingsMaxZombieBots >= 30:
      wSettingsMaxZombieBots = 1
    else:
      wSettingsMaxZombieBots++

  elif debugSelectedAction == 8: # Common bots (replace) next
    if debugCommonBotIndex >= len(debugCommonBotsList) - 1:
      debugCommonBotIndex = 0
    else:
      debugCommonBotIndex++

rule "[debug] (Left) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 1: # Round number (start) decrease
    if roundNumber <= 0:
      roundNumber = 250
    else:
      roundNumber--

  elif debugSelectedAction == 4: # Current bot previous
    debugSelectedPlayer.stopForcingOutlineFor(getAllPlayers())
    debugSelectedPlayer = getPlayersInSlot(
      (getNumberOfPlayers(Team.ZOMBIES) - 1) if (debugSelectedPlayer.getSlot() == 0) else debugSelectedPlayer.getSlot() - 1, 
      Team.ZOMBIES
    )
    debugSelectedPlayer.startForcingOutlineFor(localPlayer if (localPlayer.developer or localPlayer == hostPlayer) else null, false, Color.ORANGE)

  elif debugSelectedAction == 5: # Round bots slots decrease
    if roundMaxBotsSlots <= 0:
      roundMaxBotsSlots = 30
    else:
      roundMaxBotsSlots--

  elif debugSelectedAction == 6: # Max zombie bots (add/remove) decrease
    if wSettingsMaxZombieBots <= 0:
      wSettingsMaxZombieBots = 30
    else:
      wSettingsMaxZombieBots--

  elif debugSelectedAction == 8: # Common bots (replace) previous
    if debugCommonBotIndex <= 0:
      debugCommonBotIndex = len(debugCommonBotsList) - 1
    else:
      debugCommonBotIndex--


rule "[debug] Activate selected action for Common mode":
  ConditionForActivateSelectedAction("BotStateView")

  if debugSelectedAction == 2: # Place spawn point
    if debugZombieBotsSpawnPoint:
      debugZombieBotsSpawnPoint = false
    else:
      debugZombieBotsSpawnPoint = eventPlayer.getPosition()
  elif debugSelectedAction == 6: # Max zombie bots (add/remove)
    if isBotsDisabled == false:
      RemoveBotsSub()
    else:
      AddBotsSub()
  elif debugSelectedAction == 1: # Round number (start)
    if isBotsDisabled:
      AddBotsSub()

    if not isGameStarted:
      MatchStartSub()
    else:
      roundNumber--
      kill(getLivingPlayers(Team.ZOMBIES))
      roundRemainingBots = 0
  elif debugSelectedAction == 7: # Kill all bots
    roundRemainingBots = 0
    kill(getLivingPlayers(Team.ZOMBIES))
  elif debugSelectedAction == 8: # Common bots (replace)
    [player for player in getLivingPlayers(Team.ZOMBIES) if filterIsCommonBot(player)].startForcingHero(debugCommonBotsList[debugCommonBotIndex])
    commonZombieHero = debugCommonBotsList[debugCommonBotIndex]

  elif debugSelectedAction == 9: # Random heroes
    eventPlayer.list0 = getPlayers(Team.ZOMBIES)
    for I in range(len(eventPlayer.list0) - 1):
      eventPlayer.list0[I].startForcingHero(random.choice(getAllHeroes()))

rule "[debug] effect for debugZombieBotsSpawnPoint":
  @Condition debugZombieBotsSpawnPoint

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    debugZombieBotsSpawnPoint,
    DEBUG_BOTS_SP_EFFECT_RADIUS,
    EffectReeval.POSITION_AND_RADIUS
  )

  debugZombieBotsSpawnPointEffect = getLastCreatedEntity()
  waitUntil(not ruleCondition, INFINITY)
  destroyEffect(debugZombieBotsSpawnPointEffect)

rule "[debug] effect for botTargetLastPosition":
  @Condition debugModesArr[debugMode] == "BotStateView"
  @Condition debugSelectedPlayer and debugSelectedPlayer.botTargetLastPosition

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.RED,
    debugSelectedPlayer.botTargetLastPosition,
    DEBUG_BOTS_TARGET_LAST_POS_EFF_RADIUS,
    EffectReeval.POSITION_AND_RADIUS
  )

  debugBotTargetLastPositionEffect = getLastCreatedEntity()
  waitUntil(not ruleCondition, INFINITY)
  destroyEffect(debugBotTargetLastPositionEffect)
