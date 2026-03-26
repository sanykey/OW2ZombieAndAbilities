#!mainFile "../main.opy"

globalvar debugAllyBotCreated
globalvar debugSelectedTeam1Player
globalvar debugPerkLevelUp
globalvar debugHeroForBotIndex

rule "[debug] add Players debug mode":
  debugModesArr.append("Players")

rule "[debug] init Players debug mode":
  ConditionForInitMode("Players")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 12
  if not debugSelectedTeam1Player:
    tmp0 = sorted(
      getPlayers(Team.1),
      lambda i: i.getSlot()
    )
    debugSelectedTeam1Player = tmp0[false]

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    f"{debugMenuTitle(\"Players\")}
    {debugSelectedActionText(1)}Add ally bot: {leftArrowForMenuItem(1)} <fg84c951FF>{heroIcon(getAllHeroes()[debugHeroForBotIndex])}</fg> {rightArrowForMenuItem(1)}</fg>
    {debugSelectedActionText(2)}Player: {leftArrowForMenuItem(2)} <fg84c951FF>{heroIcon(debugSelectedTeam1Player.getHero())} {debugSelectedTeam1Player} ({debugSelectedTeam1Player.getSlot()})</fg> {rightArrowForMenuItem(2)}</fg> <fg94a0a544>← [S_FIRE/P_FIRE] →</fg>
    {debugSelectedActionText(3)}Kill</fg>
    {debugSelectedActionText(4)}Remove ally bot</fg> <fg94a0a544>[+Crouch] = all</fg>
    {debugSelectedActionText(5)}Damage upgrade: {leftArrowForMenuItem(5)} <fg84c951FF>{debugSelectedTeam1Player.damageBoostPercent}</fg> {rightArrowForMenuItem(5)}</fg>
    {debugSelectedActionText(6)}Health upgrade (heal): {leftArrowForMenuItem(6)} <fg84c951FF>{debugSelectedTeam1Player.healthBoostPercent}</fg> {rightArrowForMenuItem(6)}</fg>
    {debugSelectedActionText(7)}Healing upgrade (ressurect): {leftArrowForMenuItem(7)} <fg84c951FF>{debugSelectedTeam1Player.healingBoostPercent}</fg> {rightArrowForMenuItem(7)}</fg>
    {debugSelectedActionText(8)}Set invincible:</fg> <fg84c951FF>{debugSelectedTeam1Player.hasStatus(Status.INVINCIBLE)}</fg>
    {debugSelectedActionText(9)}Enable AI:</fg> <fg84c951FF>{debugSelectedTeam1Player.isReady__isBotRespawning}</fg>
    {debugSelectedActionText(10)}Money: {leftArrowForMenuItem(10)} <fg84c951FF>{debugSelectedTeam1Player.money__botStuckTimes}</fg> {rightArrowForMenuItem(10)}</fg>
    {debugSelectedActionText(11)}Perk level up</fg>
    {debugSelectedActionText(12)}Teleport to me </fg> <fg94a0a544>[+Crouch] = to player</fg>
    ----------
    health: <fg84c951FF>{debugSelectedTeam1Player.getHealth()}</fg>
    max health: <fg84c951FF>{debugSelectedTeam1Player.getMaxHealth()}</fg>
    start autoheal time: <fg84c951FF>{debugSelectedTeam1Player.state[SI.START_AUTO_HEAL_TIME]}</fg>
    revivers: <fg84c951FF>{debugSelectedTeam1Player.revivers}</fg>
    reviveTimer: <fg84c951FF>{debugSelectedTeam1Player.reviveTimer}</fg>
    botTarget: <fg84c951FF>{debugSelectedTeam1Player.botTarget}</fg>
    <fg94a0a544>If you die, say `Thanks` and the bot will 
    move to your position to revive you.</fg>
    ",
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)

def NextPlayersub():
  @Name "Sub: next player"
  eventPlayer.list0 = sorted(
    getPlayers(Team.1),
    lambda i: i.getSlot()
  )
  eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedTeam1Player or player.getSlot() > debugSelectedTeam1Player.getSlot()][false]
  debugSelectedTeam1Player = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0[false]

def PrevPlayersub():
  @Name "Sub: prev player"
  eventPlayer.list0 = sorted(
    getPlayers(Team.1),
    lambda i: i.getSlot()
  )
  eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedTeam1Player or player.getSlot() < debugSelectedTeam1Player.getSlot()].last()
  debugSelectedTeam1Player = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0.last()

rule "[debug] Activate selected action for Players mode":
  ConditionForActivateSelectedAction("Players")

  if debugSelectedAction == 1: # Add ally bot in my position
    createDummy(getAllHeroes()[debugHeroForBotIndex], Team.1, -1, eventPlayer.getPosition(), eventPlayer.getFacingDirection())
    eventPlayer.tmp0 = getLastCreatedEntity()
    eventPlayer.tmp0 = eventPlayer.tmp0[0]
    eventPlayer.tmp0.startForcingName(f"Ally bot {eventPlayer.tmp0.getSlot()}")
    wait()
    heal(eventPlayer.tmp0, null, INFINITY)

    debugAllyBotCreated = true
    if not debugSelectedTeam1Player:
      wait(0.1)
      NextPlayersub()
  elif debugSelectedAction == 3: # Kill
    kill(debugSelectedTeam1Player)
  elif debugSelectedAction == 4: # Remove ally bot
    if eventPlayer.isHoldingButton(Button.CROUCH):
      eventPlayer.tmp0 = getNumberOfPlayers(Team.PLAYERS)
      for I in range(eventPlayer.tmp0):
        destroyDummy(Team.1, I)
    elif debugSelectedTeam1Player.isDummy():
      destroyDummy(Team.1, debugSelectedTeam1Player.getSlot())
      NextPlayersub()
    debugAllyBotCreated = any([player for player in getPlayers(Team.1) if player.isDummy()])
  elif debugSelectedAction == 6: # Health upgrade (heal)
    heal(debugSelectedTeam1Player, null, INFINITY)
  elif debugSelectedAction == 7: # Healing upgrade (ressurect)
    debugSelectedTeam1Player.resurrect()
  elif debugSelectedAction == 8: # Set invincible
    if debugSelectedTeam1Player.hasStatus(Status.INVINCIBLE):
      debugSelectedTeam1Player.clearStatusEffect(Status.INVINCIBLE)
    else:
      debugSelectedTeam1Player.setStatusEffect(debugSelectedTeam1Player, Status.INVINCIBLE, INFINITY)
  elif debugSelectedAction == 9: # Enable AI
    if debugSelectedTeam1Player.isDummy():
      debugSelectedTeam1Player.isReady__isBotRespawning = not debugSelectedTeam1Player.isReady__isBotRespawning
  elif debugSelectedAction == 11: # Perk level up
    createDummy(
      Hero.WRECKING_BALL,
      Team.2,
      -1,
      debugSelectedTeam1Player.getPosition() + directionFromAngles(horizontalAngleOfDirection(debugSelectedTeam1Player.getFacingDirection()), 0) * 1.2,
      directionTowards(
        debugSelectedTeam1Player.getPosition() + directionFromAngles(horizontalAngleOfDirection(debugSelectedTeam1Player.getFacingDirection()), 0) * 1.2,
        debugSelectedTeam1Player
      )
    )
    debugPerkLevelUp = getLastCreatedEntity()
    debugPerkLevelUp = debugPerkLevelUp[0]
    wait()
    debugPerkLevelUp.setMaxHealth(7000)
    wait()
    heal(debugPerkLevelUp, null, 7000)
    damage(debugPerkLevelUp, debugSelectedTeam1Player, 7000)
    wait()
    destroyDummy(Team.2, debugPerkLevelUp.getSlot())
  elif debugSelectedAction == 12: # Teleport to me
    if eventPlayer.isHoldingButton(Button.CROUCH):
      eventPlayer.teleport(debugSelectedTeam1Player.getPosition())
    else:
      debugSelectedTeam1Player.teleport(eventPlayer.getPosition())

def RightBotStateViewSub():
  @Name "Sub: Right Bot State View"
  if debugSelectedAction == 1: # Add ally bot hero next
    if debugHeroForBotIndex >= len(getAllHeroes()) - 1:
      debugHeroForBotIndex = 0
    else:
      debugHeroForBotIndex++
  elif debugSelectedAction == 2: # Player next
    NextPlayersub()
  elif debugSelectedAction == 5: # Damage upgrade increase
    debugSelectedTeam1Player.damageBoostPercent += incWithModificators(10)
    debugSelectedTeam1Player.setDamageDealt(debugSelectedTeam1Player.damageBoostPercent)
  elif debugSelectedAction == 6: # Health upgrade (heal) increase
    debugSelectedTeam1Player.healthBoostPercent += incWithModificators(10)
    debugSelectedTeam1Player.setMaxHealth(debugSelectedTeam1Player.healthBoostPercent)
  elif debugSelectedAction == 7: # Healing upgrade (ressurect) increase
    debugSelectedTeam1Player.healingBoostPercent += incWithModificators(10)
    debugSelectedTeam1Player.setHealingDealt(debugSelectedTeam1Player.healingBoostPercent)
  elif debugSelectedAction == 10: # Money increase
    debugSelectedTeam1Player.money__botStuckTimes += incWithModificators(100)
    debugSelectedTeam1Player.moneyTotal__botOldPosition = debugSelectedTeam1Player.money__botStuckTimes

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "Players"

  autoSwitch(RightBotStateViewSub())


def LeftBotStateViewSub():
  @Name "Sub: Left Bot State View"
  if debugSelectedAction == 1: # Add ally bot hero previous
    if debugHeroForBotIndex <= 0:
      debugHeroForBotIndex = len(getAllHeroes()) - 1
    else:
      debugHeroForBotIndex--
  elif debugSelectedAction == 2: # Player previous
    PrevPlayersub()
  elif debugSelectedAction == 5: # Damage upgrade decrease
    debugSelectedTeam1Player.damageBoostPercent -= incWithModificators(10)
    debugSelectedTeam1Player.setDamageDealt(debugSelectedTeam1Player.damageBoostPercent)
  elif debugSelectedAction == 6: # Health upgrade (heal) decrease
    debugSelectedTeam1Player.healthBoostPercent -= incWithModificators(10)
    debugSelectedTeam1Player.setMaxHealth(debugSelectedTeam1Player.healthBoostPercent)
  elif debugSelectedAction == 7: # Healing upgrade (ressurect) decrease
    debugSelectedTeam1Player.healingBoostPercent -= incWithModificators(10)
    debugSelectedTeam1Player.setHealingDealt(debugSelectedTeam1Player.healingBoostPercent)
  elif debugSelectedAction == 10: # Money decrease
    debugSelectedTeam1Player.money__botStuckTimes -= incWithModificators(100)
    debugSelectedTeam1Player.moneyTotal__botOldPosition = debugSelectedTeam1Player.money__botStuckTimes

rule "[debug] (Left) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "Players"

  autoSwitch(LeftBotStateViewSub())

rule "[debug] Fast next ally bot":
  RuleHeaderDebugPageInteractCondition("Players")
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  NextPlayersub()

rule "[debug] Fast prev ally bot":
  RuleHeaderDebugPageInteractCondition("Players")
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  PrevPlayersub()


# rule "[debug] Ally bot: Init":
#   @Event eachPlayer
#   @Condition debugAllyBotCreated
#   @Team 1
#   @Hero orisa
#   @Condition eventPlayer.isDummy()
  
#   eventPlayer.healthBoostPercent += 10000
#   eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
#   wait()
#   heal(eventPlayer, null, INFINITY)
#   eventPlayer.startForcingName("Ally bot {}".format(eventPlayer.getSlot()))

macro getAllyBotTarget():
  eventPlayer.tmp1 = false      # current target distance
  eventPlayer.tmp2 = false      # distance to best canditate to target
  eventPlayer.botTarget = false # target being pursued by the zombie

  eventPlayer.list0 = getPlayers(Team.ZOMBIES)
  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.tmp0 = eventPlayer.list0[eventPlayer.I]
    if not eventPlayer.tmp0 or eventPlayer.tmp0.isDead():
      continue

    eventPlayer.tmp1 = distance(eventPlayer, eventPlayer.tmp0)

    if eventPlayer.tmp1 > 40 or (eventPlayer.tmp2 and eventPlayer.tmp1 > eventPlayer.tmp2):
      continue

    if isInLoS(eventPlayer, eventPlayer.tmp0):
      eventPlayer.botTarget = eventPlayer.tmp0
      eventPlayer.tmp2 = eventPlayer.tmp1
    

rule "[debug] Ally bot: Find Target and attack":
  @Event eachPlayer
  @Team 1
  @Hero orisa
  @Condition debugAllyBotCreated
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.isReady__isBotRespawning

  if eventPlayer.zomAIstep == 0:
    getAllyBotTarget()

  if eventPlayer.botTarget:
    eventPlayer.setFacing(
      directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()),
      Relativity.TO_WORLD
    )

    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  else:
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

  eventPlayer.zomAIstep = 0 if eventPlayer.zomAIstep >= 4 else eventPlayer.zomAIstep + 1
  wait(0.2)
  if not eventPlayer.isReady__isBotRespawning:
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

  if ruleCondition:
    loop()

rule "[debug] Teleport ally bot to died player":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.isDead()
  @Condition eventPlayer.isCommunicating(Comms.THANKS)

  random.choice(
    [player for player in getLivingPlayers(Team.1) if player.isDummy() and player.getHero() == Hero.ORISA]
  ).teleport(eventPlayer.getPosition())
