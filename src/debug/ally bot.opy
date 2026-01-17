#!mainFile "../main.opy"

#!define MAX_ALLY_BOTS 6
#!define MIN_ALLY_BOT_SLOT 7

globalvar debugAllyBotCreated
globalvar debugSelectedAllyBot

rule "[debug] add AllyBots debug mode":
  debugModesArr.append("AllyBots")

rule "[debug] init Bot state view mode":
  ConditionForInitMode("AllyBots")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 9

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    "{}
    {}Add ally bot in my position (max: {})</fg>
    {}Current bot: {} <fg84c951FF>{} {} ({})</fg> {}</fg> <fg94a0a544>← [S_FIRE/P_FIRE] →</fg>
    {}Kill bot</fg>
    {}Remove ally bot</fg> <fg94a0a544>[+Crouch] = all</fg>
    {}Damage upgrade: {} <fg84c951FF>{}</fg> {}</fg>
    {}Health upgrade (heal): {} <fg84c951FF>{}</fg> {}</fg>
    {}Healing upgrade (ressurect): {} <fg84c951FF>{}</fg> {}</fg>
    {}Set invincible:</fg> <fg84c951FF>{}</fg>
    {}Enable AI:</fg> <fg84c951FF>{}</fg>
    ----------
    health: <fg84c951FF>{}</fg>
    max health: <fg84c951FF>{}</fg>
    revivers: <fg84c951FF>{}</fg>
    reviveTimer: <fg84c951FF>{}</fg>
    botTarget: <fg84c951FF>{}</fg>
    <fg94a0a544>If you die, say `Thanks` and the bot will 
    move to your position to revive you.</fg>
    ".format(
      debugMenuTitle("AllyBots"),
      debugSelectedActionText(1),
      MAX_ALLY_BOTS,
      debugSelectedActionText(2),

      leftArrowForMenuItem(2),
      heroIcon(debugSelectedAllyBot.getHero()),
      debugSelectedAllyBot,
      debugSelectedAllyBot.getSlot(),
      rightArrowForMenuItem(2),

      debugSelectedActionText(3),
      debugSelectedActionText(4),

      debugSelectedActionText(5),
      leftArrowForMenuItem(5),
      debugSelectedAllyBot.damageBoostPercent,
      rightArrowForMenuItem(5),

      debugSelectedActionText(6),
      leftArrowForMenuItem(6),
      debugSelectedAllyBot.healthBoostPercent,
      rightArrowForMenuItem(6),

      debugSelectedActionText(7),
      leftArrowForMenuItem(7),
      debugSelectedAllyBot.healingBoostPercent,
      rightArrowForMenuItem(7),

      debugSelectedActionText(8),
      debugSelectedAllyBot.hasStatus(Status.INVINCIBLE),

      debugSelectedActionText(9),
      debugSelectedAllyBot.isReady,

      # ----------
      debugSelectedAllyBot.getHealth(),
      debugSelectedAllyBot.getMaxHealth(),
      debugSelectedAllyBot.revivers,
      debugSelectedAllyBot.reviveTimer,
      debugSelectedAllyBot.botTarget
    ),
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)

def NextAllyBotSub():
  @Name "Sub: next ally bot"
  eventPlayer.list0 = sorted(
    [player for player in getPlayers(Team.1) if player.isDummy()],
    lambda i: i.getSlot()
  )
  eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedAllyBot or player.getSlot() > debugSelectedAllyBot.getSlot()][false]
  debugSelectedAllyBot = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0[false]

def PrevAllyBotSub():
  @Name "Sub: prev ally bot"
  eventPlayer.list0 = sorted(
    [player for player in getPlayers(Team.1) if player.isDummy()],
    lambda i: i.getSlot()
  )
  eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedAllyBot or player.getSlot() < debugSelectedAllyBot.getSlot()].last()
  debugSelectedAllyBot = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0.last()

rule "[debug] Activate selected action for AllyBots mode":
  ConditionForActivateSelectedAction("AllyBots")

  if debugSelectedAction == 1: # Add bot
    for I in range(MIN_ALLY_BOT_SLOT, MIN_ALLY_BOT_SLOT + MAX_ALLY_BOTS):
      if not getPlayersInSlot(I, Team.1):
        createDummy(Hero.ORISA, Team.1, I, eventPlayer.getPosition(), eventPlayer.getFacingDirection())
        debugAllyBotCreated = true
        if not debugSelectedAllyBot:
          wait(0.1)
          debugSelectedAllyBot = [player for player in getPlayers(Team.1) if player.isDummy()][0]
        return
  elif debugSelectedAction == 3: # Kill bot
    kill(debugSelectedAllyBot)
  elif debugSelectedAction == 4: # Remove all ally bots
    if eventPlayer.isHoldingButton(Button.CROUCH):
      for I in range(MIN_ALLY_BOT_SLOT, MIN_ALLY_BOT_SLOT + MAX_ALLY_BOTS):
        destroyDummy(Team.1, I)
    else:
      destroyDummy(Team.1, debugSelectedAllyBot.getSlot())
      NextAllyBotSub()
    debugAllyBotCreated = any([player for player in getPlayers(Team.1) if player.isDummy()])
  elif debugSelectedAction == 6: # Heal
    heal(debugSelectedAllyBot, null, INFINITY)
  elif debugSelectedAction == 7: # Ressurect
    debugSelectedAllyBot.resurrect()
  elif debugSelectedAction == 8: # set INVINCIBLE
    if debugSelectedAllyBot.hasStatus(Status.INVINCIBLE):
      debugSelectedAllyBot.clearStatusEffect(Status.INVINCIBLE)
    else:
      debugSelectedAllyBot.setStatusEffect(debugSelectedAllyBot, Status.INVINCIBLE, INFINITY)
  elif debugSelectedAction == 9: # enable AI
    debugSelectedAllyBot.isReady = not debugSelectedAllyBot.isReady


rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "AllyBots"

  if debugSelectedAction == 2: # next bot
    NextAllyBotSub()
  elif debugSelectedAction == 5:
    debugSelectedAllyBot.damageBoostPercent += incWithModificators(10)
    debugSelectedAllyBot.setDamageDealt(debugSelectedAllyBot.damageBoostPercent)
  elif debugSelectedAction == 6:
    debugSelectedAllyBot.healthBoostPercent += incWithModificators(10)
    debugSelectedAllyBot.setMaxHealth(debugSelectedAllyBot.healthBoostPercent)
  elif debugSelectedAction == 7:
    debugSelectedAllyBot.healingBoostPercent += incWithModificators(10)
    debugSelectedAllyBot.setHealingDealt(debugSelectedAllyBot.healingBoostPercent)

rule "[debug] (Left) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "AllyBots"

  if debugSelectedAction == 2: # previous bot
    PrevAllyBotSub()
  
  elif debugSelectedAction == 5:
    debugSelectedAllyBot.damageBoostPercent -= incWithModificators(10)
    debugSelectedAllyBot.setDamageDealt(debugSelectedAllyBot.damageBoostPercent)
  elif debugSelectedAction == 6:
    debugSelectedAllyBot.healthBoostPercent -= incWithModificators(10)
    debugSelectedAllyBot.setMaxHealth(debugSelectedAllyBot.healthBoostPercent)
  elif debugSelectedAction == 7:
    debugSelectedAllyBot.healingBoostPercent -= incWithModificators(10)
    debugSelectedAllyBot.setHealingDealt(debugSelectedAllyBot.healingBoostPercent)

rule "[debug] Fast next ally bot":
  RuleHeaderDebugPageInteractCondition("AllyBots")
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  NextAllyBotSub()

rule "[debug] Fast prev ally bot":
  RuleHeaderDebugPageInteractCondition("AllyBots")
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  PrevAllyBotSub()


rule "[debug] Ally bot: Init":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isDummy()
  
  eventPlayer.healthBoostPercent += 10000
  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  wait()
  heal(eventPlayer, null, INFINITY)
  eventPlayer.startForcingName("Ally bot {}".format(eventPlayer.getSlot()))

macro getAllyBotTarget():
  eventPlayer.tmp1 = false      # current target distance
  eventPlayer.tmp2 = false      # distance to best canditate to target
  eventPlayer.botTarget = false # target being pursued by the zombie

  eventPlayer.list0 = getPlayers(Team.2)
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
  @Condition eventPlayer.isReady

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
  if not eventPlayer.isReady:
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
