#!mainFile "../main.opy"

#!define DEBUG_BOTS_SP_EFFECT_RADIUS 0.2
#!define DEBUG_BOTS_TARGET_LAST_POS_EFF_RADIUS 0.2

globalvar debugSelectedPlayer
globalvar debugSelectedPlayerEff
globalvar debugCommonBotsList = [Hero.TORBJORN, Hero.JUNKRAT, Hero.SYMMETRA]
globalvar debugCommonBotIndex
globalvar debugBotsSpawnPointEffect
globalvar debugBotTargetLastPositionEffect

rule "[debug] add BotStateView debug mode":
  debugModesArr.append("BotStateView")

rule "[debug] init Bot state view mode":
  ConditionForInitMode("BotStateView")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 12

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
    "{}
    {}Place spawn point:</fg> <fg84c951FF>{}</fg>
    {}Select bot closest to reticle</fg> <fg84c951FF>{} {}</fg> <fg94a0a544>[PRIMARY_FIRE]</fg>
    {}Current bot: {} <fg84c951FF>{} {}</fg> {}</fg>
    {}Round bots slots: {} <fg84c951FF>{}</fg> {}</fg>
    {}Max zombie bots (add/remove): {} <fg84c951FF>{}</fg> {}</fg>
    {}Round number (start): {} <fg84c951FF>{}</fg> {}</fg>
    {}Kill all bots</fg>
    {}Common bots (replace): {} <fg84c951FF>{}</fg> {}</fg>
    {}Add Roadhog</fg>
    {}Add Mauga</fg>
    {}Add Widowmaker</fg>
    {}Random heroes</fg>
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
    lastCcAttacker: <fg84c951FF>{}</fg>
    lastCcAttackTime: <fg84c951FF>{}</fg>
    lastCcWasInAir: <fg84c951FF>{}</fg>
    botWidowmakerAvaliableSpawnSpots: <fg84c951FF>{}</fg>
    botTargetLos: <fg84c951FF>{}</fg>
    botTargetLastPosition: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("BotStateView"),

      # Place spawn point
      debugSelectedActionText(1),
      debugBotsSpawnPoint,

      # Select bot closest to reticle
      debugSelectedActionText(2),
      heroIcon(hostPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES).getHero()),
      hostPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES),

      # Current bot
      debugSelectedActionText(3),
      "←" if debugSelectedAction == 3 else "",
      heroIcon(debugSelectedPlayer.getHero()),
      debugSelectedPlayer,
      "→" if debugSelectedAction == 3 else "",

      # Round bots slots
      debugSelectedActionText(4),
      "←" if debugSelectedAction == 4 else "",
      roundMaxBotsSlots,
      "→" if debugSelectedAction == 4 else "",

      # Max zombie bots
      debugSelectedActionText(5),
      "←" if debugSelectedAction == 5 else "",
      wSettingsMaxZombieBots,
      "→" if debugSelectedAction == 5 else "",

      debugSelectedActionText(6),
      "←" if debugSelectedAction == 6 else "",
      roundNumber,
      "→" if debugSelectedAction == 6 else "",

      debugSelectedActionText(7),

      debugSelectedActionText(8),
      "←" if debugSelectedAction == 8 else "",
      heroIcon(debugCommonBotsList[debugCommonBotIndex]),
      "→" if debugSelectedAction == 8 else "",

      debugSelectedActionText(9),
      debugSelectedActionText(10),
      debugSelectedActionText(11),

      debugSelectedActionText(12),

      getTotalTimeElapsed(),
      debugSelectedPlayer.getHealth(),
      debugSelectedPlayer.getMaxHealth(),
      debugSelectedPlayer.getUltCharge(),
      debugSelectedPlayer.getPosition(),
      debugSelectedPlayer.getFacingDirection(),
      debugSelectedPlayer.money__botStuckTimes,
      debugSelectedPlayer.botWantsWallPhasePoints,
      debugSelectedPlayer.botTarget,
      distance(debugSelectedPlayer, debugSelectedPlayer.botTarget),
      debugSelectedPlayer.getHorizontalSpeed(),
      5.5 / 100 * zomSpeedPct,
      debugSelectedPlayer.lastCcAttacker,
      debugSelectedPlayer.lastCcAttackTime,
      debugSelectedPlayer.lastCcWasInAir,
      botWidowmakerAvaliableSpawnSpots,
      debugSelectedPlayer.botTargetLos,
      debugSelectedPlayer.botTargetLastPosition
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

  debugSelectedPlayer = eventPlayer.getRealPlayerClosestToReticle(Team.ZOMBIES)

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "BotStateView"
  
  if debugSelectedAction == 3: # next bot
    debugSelectedPlayer = getPlayersInSlot(
      0 if (debugSelectedPlayer.getSlot() >= getNumberOfPlayers(Team.ZOMBIES) - 1) else debugSelectedPlayer.getSlot() + 1, 
      Team.ZOMBIES
    )

  elif debugSelectedAction == 4:
    if roundMaxBotsSlots >= 30:
      roundMaxBotsSlots = 1
    else:
      roundMaxBotsSlots++

  elif debugSelectedAction == 5:
    if wSettingsMaxZombieBots >= 30:
      wSettingsMaxZombieBots = 1
    else:
      wSettingsMaxZombieBots++

  elif debugSelectedAction == 6:
    if roundNumber >= 250:
      roundNumber = 0
    else:
      roundNumber++

  elif debugSelectedAction == 8:
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
      (getNumberOfPlayers(Team.ZOMBIES) - 1) if (debugSelectedPlayer.getSlot() == 0) else debugSelectedPlayer.getSlot() - 1, 
      Team.ZOMBIES
    )
    debugSelectedPlayer.startForcingOutlineFor(localPlayer if (localPlayer.developer or localPlayer == hostPlayer) else null, false, Color.ORANGE)

  elif debugSelectedAction == 4:
    if roundMaxBotsSlots <= 0:
      roundMaxBotsSlots = 30
    else:
      roundMaxBotsSlots--

  elif debugSelectedAction == 5:
    if wSettingsMaxZombieBots <= 0:
      wSettingsMaxZombieBots = 30
    else:
      wSettingsMaxZombieBots--

  elif debugSelectedAction == 6:
    if roundNumber <= 0:
      roundNumber = 250
    else:
      roundNumber--

  elif debugSelectedAction == 8:
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
  elif debugSelectedAction == 5: # Remove/add bots
    if isBotsDisabled == false:
      RemoveBotsSub()
    else:
      AddBotsSub()
  elif debugSelectedAction == 6:
    if isBotsDisabled:
      AddBotsSub()

    if not isGameStarted:
      MatchStartSub()
    else:
      roundNumber--
      kill(getLivingPlayers(Team.ZOMBIES))
      roundRemainingBots = 0
  elif debugSelectedAction == 7: # Place/Remove debug spawn point for bots
    roundRemainingBots = 0
    kill(getLivingPlayers(Team.ZOMBIES))
  elif debugSelectedAction == 8: # Common bots replace
    [player for player in getLivingPlayers(Team.ZOMBIES) if filterIsCommonBot(player)].startForcingHero(debugCommonBotsList[debugCommonBotIndex])
    commonZombieHero = debugCommonBotsList[debugCommonBotIndex]

  elif debugSelectedAction == 9:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.ROADHOG)
  elif debugSelectedAction == 10:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.MAUGA)
  elif debugSelectedAction == 11:
    GetCandidateForEliteZombieSub()
    setZombieHero(tmp1, Hero.WIDOWMAKER)
  elif debugSelectedAction == 12:
    eventPlayer.list0 = getPlayers(Team.ZOMBIES)
    for I in range(len(eventPlayer.list0) - 1):
      eventPlayer.list0[I].startForcingHero(random.choice(getAllHeroes()))

rule "[debug] effect for debugBotsSpawnPoint":
  @Condition debugBotsSpawnPoint

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    debugBotsSpawnPoint,
    DEBUG_BOTS_SP_EFFECT_RADIUS,
    EffectReeval.POSITION_AND_RADIUS
  )

  debugBotsSpawnPointEffect = getLastCreatedEntity()
  waitUntil(not ruleCondition, INFINITY)
  destroyEffect(debugBotsSpawnPointEffect)

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