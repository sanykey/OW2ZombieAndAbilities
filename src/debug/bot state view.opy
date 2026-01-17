#!mainFile "../main.opy"

globalvar debugSelectedPlayer
globalvar debugSelectedPlayerEff
globalvar debugCommonBotsList = [Hero.TORBJORN, Hero.JUNKRAT, Hero.SYMMETRA]
globalvar debugCommonBotIndex

rule "[debug] add BotStateView debug mode":
  debugModesArr.append("BotStateView")

rule "[debug] init Bot state view mode":
  ConditionForInitMode("BotStateView")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 10

  if not debugSelectedPlayer:
    debugSelectedPlayer = getPlayersInSlot(0, Team.2)

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
    "{}
    {}Place spawn point:</fg> <fg84c951FF>{}</fg>
    {}Select bot closest to reticle</fg> <fg84c951FF>{} {}</fg> <fg94a0a544>[PRIMARY_FIRE]</fg>
    {}Current bot: {} <fg84c951FF>{} {}</fg> {}</fg>
    {}Max zombie bots (add/remove): {} <fg84c951FF>{}</fg> {}</fg>
    {}Round number (start): {} <fg84c951FF>{}</fg> {}</fg>
    {}Kill all bots</fg>
    {}Common bots (replace): {} <fg84c951FF>{}</fg> {}</fg>
    {}Add Roadhog</fg>
    {}Add Mauga</fg>
    {}Add Widowmaker</fg>
    --------------------
    Total Time Elapsed: <fg84c951FF>{}</fg>
    health: <fg84c951FF>{}</fg>
    max health: <fg84c951FF>{}</fg>
    ult charge: <fg84c951FF>{}</fg>
    pos: <fg84c951FF>{}</fg>
    facing dir: <fg84c951FF>{}</fg>
    Stuck Points: <fg84c951FF>{}</fg>
    Fly Through Walls Points: <fg84c951FF>{}</fg>
    Target: <fg84c951FF>{}</fg>
    Distance to target: <fg84c951FF>{}</fg>
    Horizontal speed: <fg84c951FF>{}</fg>
    Default speed: <fg84c951FF>{}</fg>
    botDistancesToEnemiesArr: <fg84c951FF>{}</fg>
    zomIsInLoSPlayersArr: <fg84c951FF>{}</fg>
    lastCcAttacker: <fg84c951FF>{}</fg>
    lastCcAttackTime: <fg84c951FF>{}</fg>
    lastCcWasInAir: <fg84c951FF>{}</fg>
    botWidowmakerAvaliableSpawnSpots: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("BotStateView"),

      debugSelectedActionText(1),
      debugBotsSpawnPoint,

      debugSelectedActionText(2),
      heroIcon(hostPlayer.getRealPlayerClosestToReticle(Team.2).getHero()),
      hostPlayer.getRealPlayerClosestToReticle(Team.2),

      debugSelectedActionText(3),
      "←" if debugSelectedAction == 3 else "",
      heroIcon(debugSelectedPlayer.getHero()),
      debugSelectedPlayer,
      "→" if debugSelectedAction == 3 else "",

      debugSelectedActionText(4),
      "←" if debugSelectedAction == 4 else "",
      wSettingsMaxZombieBots,
      "→" if debugSelectedAction == 4 else "",

      debugSelectedActionText(5),
      "←" if debugSelectedAction == 5 else "",
      roundNumber,
      "→" if debugSelectedAction == 5 else "",

      debugSelectedActionText(6),

      debugSelectedActionText(7),
      "←" if debugSelectedAction == 7 else "",
      heroIcon(debugCommonBotsList[debugCommonBotIndex]),
      "→" if debugSelectedAction == 7 else "",
      debugSelectedActionText(8),
      debugSelectedActionText(9),
      debugSelectedActionText(10),

      getTotalTimeElapsed(),
      debugSelectedPlayer.getHealth(),
      debugSelectedPlayer.getMaxHealth(),
      debugSelectedPlayer.getUltCharge(),
      debugSelectedPlayer.getPosition(),
      debugSelectedPlayer.getFacingDirection(),
      debugSelectedPlayer.money__botStuckTimes,
      debugSelectedPlayer.botWantsPhasePoints,
      debugSelectedPlayer.botTarget,
      distance(debugSelectedPlayer, debugSelectedPlayer.botTarget),
      debugSelectedPlayer.getHorizontalSpeed(),
      5.5 / 100 * zomSpeedPct,
      debugSelectedPlayer.botDistancesToEnemiesArr,
      debugSelectedPlayer.zomIsInLoSPlayersArr,
      debugSelectedPlayer.lastCcAttacker,
      debugSelectedPlayer.lastCcAttackTime,
      debugSelectedPlayer.lastCcWasInAir,
      botWidowmakerAvaliableSpawnSpots
    ),
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
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or debugSelectedAction == 2 and eventPlayer.isHoldingButton(Button.MELEE)

  debugSelectedPlayer = eventPlayer.getRealPlayerClosestToReticle(Team.2)

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 3: # next bot
    debugSelectedPlayer = getPlayersInSlot(
      0 if (debugSelectedPlayer.getSlot() >= getNumberOfPlayers(Team.2) - 1) else debugSelectedPlayer.getSlot() + 1, 
      Team.2
    )

  elif debugSelectedAction == 4:
    if not isGameStarted and not isBotsDisabled:
      RemoveBotsSub()
    if wSettingsMaxZombieBots >= 30:
      wSettingsMaxZombieBots = 1
    else:
      wSettingsMaxZombieBots++

  elif debugSelectedAction == 5:
    if roundNumber >= 250:
      roundNumber = 0
    else:
      roundNumber++

  elif debugSelectedAction == 7:
    if debugCommonBotIndex >= len(debugCommonBotsList) - 1:
      debugCommonBotIndex = 0
    else:
      debugCommonBotIndex++

rule "[debug] (Left) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 3: # previous bot
    debugSelectedPlayer.stopForcingOutlineFor(getAllPlayers())
    debugSelectedPlayer = getPlayersInSlot(
      (getNumberOfPlayers(Team.2) - 1) if (debugSelectedPlayer.getSlot() == 0) else debugSelectedPlayer.getSlot() - 1, 
      Team.2
    )
    debugSelectedPlayer.startForcingOutlineFor(localPlayer if (localPlayer.developer or localPlayer == hostPlayer) else null, false, Color.ORANGE)

  elif debugSelectedAction == 4:
    if not isGameStarted and not isBotsDisabled:
      RemoveBotsSub()
    if wSettingsMaxZombieBots <= 0:
      wSettingsMaxZombieBots = 30
    else:
      wSettingsMaxZombieBots--

  elif debugSelectedAction == 5:
    if roundNumber <= 0:
      roundNumber = 250
    else:
      roundNumber--

  elif debugSelectedAction == 7:
    if debugCommonBotIndex <= 0:
      debugCommonBotIndex = len(debugCommonBotsList) - 1
    else:
      debugCommonBotIndex--


rule "[debug] Activate selected action for Common mode":
  ConditionForActivateSelectedAction("BotStateView")

  if debugSelectedAction == 1: # Place/Remove debug spawn point for bots
    if debugBotsSpawnPoint:
      debugBotsSpawnPoint = false
    else:
      debugBotsSpawnPoint = eventPlayer.getPosition()
  if debugSelectedAction == 4: # Remove/add bots
    if isBotsDisabled == false:
      RemoveBotsSub()
    else:
      AddBotsSub()
  elif debugSelectedAction == 5:
    if isBotsDisabled:
      AddBotsSub()

    if not isGameStarted:
      MatchStartSub()
    else:
      roundNumber--
      kill(getLivingPlayers(Team.2))
      roundRemainingBots = 0
  elif debugSelectedAction == 6: # Place/Remove debug spawn point for bots
    roundRemainingBots = 0
    kill(getLivingPlayers(Team.2))
  elif debugSelectedAction == 7: # Common bots replace
    [player for player in getLivingPlayers(Team.2) if filterIsCommonBot(player)].startForcingHero(debugCommonBotsList[debugCommonBotIndex])
    commonZombieHero = debugCommonBotsList[debugCommonBotIndex]

  elif debugSelectedAction == 8:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.ROADHOG)
  elif debugSelectedAction == 9:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.MAUGA)
  elif debugSelectedAction == 10:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.WIDOWMAKER)
