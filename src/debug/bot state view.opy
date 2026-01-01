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
    {}Select bot closest to reticle</fg> <fg84c951FF>{} {}</fg> <fg94a0a544>[PRIMARY_FIRE]</fg>
    {}Current bot: {} <fg84c951FF>{} {}</fg> {}</fg>
    {}Place spawn point:</fg> <fg84c951FF>{}</fg>
    {}Max zombie bots (add/remove): {} <fg84c951FF>{}</fg> {}</fg>
    {}Round number (start): {} <fg84c951FF>{}</fg> {}</fg>
    {}Kill all bots</fg>
    {}Common bots (replace): {} <fg84c951FF>{}</fg> {}</fg>
    {}Add Roadhog
    {}Add Mauga
    {}Add Widowmaker
    --------------------
    health: <fg84c951FF>{}</fg>
    max health: <fg84c951FF>{}</fg>
    ult charge: <fg84c951FF>{}</fg>
    pos: <fg84c951FF>{}</fg>
    facing dir: <fg84c951FF>{}</fg>
    Total Time Elapsed: <fg84c951FF>{}</fg>
    Stuck Points: <fg84c951FF>{}</fg>
    target0: <fg84c951FF>{}</fg>
    abilPos0: <fg84c951FF>{}</fg>
    tmp1: <fg84c951FF>{}</fg>
    zomDistancesToPlayersArr: <fg84c951FF>{}</fg>
    zomIsInLoSPlayersArr: <fg84c951FF>{}</fg>
    list1: <fg84c951FF>{}</fg>
    abilState0: <fg84c951FF>{}</fg>
    abilState1: <fg84c951FF>{}</fg>
    lastCcAttacker: <fg84c951FF>{}</fg>
    lastCcAttackTime: <fg84c951FF>{}</fg>
    lastCcWasInAir: <fg84c951FF>{}</fg>
    botWidowmakerAvaliableSpawnSpots: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("BotStateView"),
      debugSelectedActionText(1),
      heroIcon(hostPlayer.getRealPlayerClosestToReticle(Team.2).getHero()),
      hostPlayer.getRealPlayerClosestToReticle(Team.2),

      debugSelectedActionText(2),
      "←" if debugSelectedAction == 2 else "",
      heroIcon(debugSelectedPlayer.getHero()),
      debugSelectedPlayer,
      "→" if debugSelectedAction == 2 else "",

      debugSelectedActionText(3),
      debugBotsSpawnPoint,

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
      debugSelectedPlayer.money__zomStuckPoints,
      debugSelectedPlayer.target0,
      debugSelectedPlayer.abilPos0,
      debugSelectedPlayer.tmp1,
      debugSelectedPlayer.zomDistancesToPlayersArr,
      debugSelectedPlayer.zomIsInLoSPlayersArr,
      debugSelectedPlayer.list1,
      debugSelectedPlayer.abilState0,
      debugSelectedPlayer.abilState1,
      debugSelectedPlayer.lastCcAttacker,
      debugSelectedPlayer.lastCcAttackTime,
      debugSelectedPlayer.lastCcWasInAir,
      1
      # todo: botWidowmakerAvaliableSpawnSpots
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
  ConditionForDebugPageInteract("BotStateView")
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or debugSelectedAction == 1 and eventPlayer.isHoldingButton(Button.MELEE)

  debugSelectedPlayer = eventPlayer.getRealPlayerClosestToReticle(Team.2)

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 2: # next bot
    debugSelectedPlayer = getPlayersInSlot(
      0 if (debugSelectedPlayer.getSlot() >= getNumberOfPlayers(Team.2) - 1) else debugSelectedPlayer.getSlot() + 1, 
      Team.2
    )

  elif debugSelectedAction == 4:
    if not isGameStarted and not isBotsDisabled:
      RemoveBotsSub()
    if wSettingsMaxZombieBots >= 15:
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
  
  if debugSelectedAction == 2: # previous bot
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
      wSettingsMaxZombieBots = 15
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

  if debugSelectedAction == 3: # Place/Remove debug spawn point for bots
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
    [player for player in getLivingPlayers(Team.2) if filterIsNotEliteHeroForZombie(player)].startForcingHero(debugCommonBotsList[debugCommonBotIndex])
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
    
# rule "[debug] init bot respawn state":
#   hudSubheader(
#     localPlayer if localPlayer.developer else null,
#     "Bots respawn state:
#     roundRemainingBots: {}
#     getNumberOfLivingPlayers: {}
#     debugBotsSpawnPoint: {}
#     --------------------
#     alive: [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
#     debugWaitBotRespawnTimeArr: [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
#     debugWaitBotRespawnSlotArr: [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
#     debugWaitBotRespawnWaitStart: [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}]
#     ".format(
#       roundRemainingBots,
#       getNumberOfLivingPlayers(Team.2),
#       debugBotsSpawnPoint,

#       getPlayersInSlot(0, Team.2).isAlive() and getPlayersInSlot(0, Team.2).hasSpawned(),
#       getPlayersInSlot(1, Team.2).isAlive() and getPlayersInSlot(1, Team.2).hasSpawned(), 
#       getPlayersInSlot(2, Team.2).isAlive() and getPlayersInSlot(2, Team.2).hasSpawned(),
#       getPlayersInSlot(3, Team.2).isAlive() and getPlayersInSlot(3, Team.2).hasSpawned(),
#       getPlayersInSlot(4, Team.2).isAlive() and getPlayersInSlot(4, Team.2).hasSpawned(),
#       getPlayersInSlot(5, Team.2).isAlive() and getPlayersInSlot(5, Team.2).hasSpawned(),
#       getPlayersInSlot(6, Team.2).isAlive() and getPlayersInSlot(6, Team.2).hasSpawned(),
#       getPlayersInSlot(7, Team.2).isAlive() and getPlayersInSlot(7, Team.2).hasSpawned(),
#       getPlayersInSlot(8, Team.2).isAlive() and getPlayersInSlot(8, Team.2).hasSpawned(),
#       getPlayersInSlot(9, Team.2).isAlive() and getPlayersInSlot(9, Team.2).hasSpawned(),
#       getPlayersInSlot(10, Team.2).isAlive() and getPlayersInSlot(10, Team.2).hasSpawned(),
#       getPlayersInSlot(11, Team.2).isAlive() and getPlayersInSlot(11, Team.2).hasSpawned(),
#       getPlayersInSlot(12, Team.2).isAlive() and getPlayersInSlot(12, Team.2).hasSpawned(),
#       getPlayersInSlot(13, Team.2).isAlive() and getPlayersInSlot(13, Team.2).hasSpawned(),

#       debugWaitBotRespawnTimeArr[0],
#       debugWaitBotRespawnTimeArr[1],
#       debugWaitBotRespawnTimeArr[2],
#       debugWaitBotRespawnTimeArr[3],
#       debugWaitBotRespawnTimeArr[4],
#       debugWaitBotRespawnTimeArr[5],
#       debugWaitBotRespawnTimeArr[6],
#       debugWaitBotRespawnTimeArr[7],
#       debugWaitBotRespawnTimeArr[8],
#       debugWaitBotRespawnTimeArr[9],
#       debugWaitBotRespawnTimeArr[10],
#       debugWaitBotRespawnTimeArr[11],
#       debugWaitBotRespawnTimeArr[12],
#       debugWaitBotRespawnTimeArr[13],

#       debugWaitBotRespawnSlotArr[0], 
#       debugWaitBotRespawnSlotArr[1],
#       debugWaitBotRespawnSlotArr[2],
#       debugWaitBotRespawnSlotArr[3],
#       debugWaitBotRespawnSlotArr[4],
#       debugWaitBotRespawnSlotArr[5], 
#       debugWaitBotRespawnSlotArr[6],
#       debugWaitBotRespawnSlotArr[7],
#       debugWaitBotRespawnSlotArr[8],
#       debugWaitBotRespawnSlotArr[9],
#       debugWaitBotRespawnSlotArr[10], 
#       debugWaitBotRespawnSlotArr[11],
#       debugWaitBotRespawnSlotArr[12],
#       debugWaitBotRespawnSlotArr[13],

#       debugWaitBotRespawnWaitStart[0], 
#       debugWaitBotRespawnWaitStart[1],
#       debugWaitBotRespawnWaitStart[2],
#       debugWaitBotRespawnWaitStart[3],
#       debugWaitBotRespawnWaitStart[4],
#       debugWaitBotRespawnWaitStart[5], 
#       debugWaitBotRespawnWaitStart[6],
#       debugWaitBotRespawnWaitStart[7],
#       debugWaitBotRespawnWaitStart[8],
#       debugWaitBotRespawnWaitStart[9],
#       debugWaitBotRespawnWaitStart[10], 
#       debugWaitBotRespawnWaitStart[11],
#       debugWaitBotRespawnWaitStart[12],
#       debugWaitBotRespawnWaitStart[13]
#     ),
#     HudPosition.ACTUALLY_LEFT,
#     6,
#     Color.WHITE,
#     HudReeval.VISIBILITY_STRING_AND_COLOR
#   )