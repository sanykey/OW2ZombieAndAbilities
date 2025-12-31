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
  debugMaxAction = 4

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    "{}
    {}Add ally bot in my position (max: {})</fg>
    {}Current bot: {} <fg84c951FF>{} {}</fg> {}</fg>
    {}Kill bot</fg>
    {}Remove all ally bots</fg>
    ----------
    revivers: {}
    reviveTimer: {}
    <fg94a0a544>If you die, say `Thanks` and the bot will 
    move to your position to revive you.</fg>
    ".format(
      debugMenuTitle("AllyBots"),
      debugSelectedActionText(1),
      MAX_ALLY_BOTS,
      debugSelectedActionText(2),
      "←" if debugSelectedAction == 2 else "",
      heroIcon(debugSelectedAllyBot.getHero()),
      debugSelectedAllyBot,
      "→" if debugSelectedAction == 2 else "",
      debugSelectedActionText(3),
      debugSelectedActionText(4),
      debugSelectedAllyBot.revivers,
      debugSelectedAllyBot.reviveTimer
    ),
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)


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
    for I in range(MIN_ALLY_BOT_SLOT, MIN_ALLY_BOT_SLOT + MAX_ALLY_BOTS):
      destroyDummy(Team.1, I)
    debugAllyBotCreated = false

rule "[debug] (Right) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "AllyBots"

  if debugSelectedAction == 2: # next bot
    eventPlayer.list0 = sorted(
      [player for player in getPlayers(Team.1) if player.isDummy()],
      lambda i: i.getSlot()
    )
    eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedAllyBot or player.getSlot() > debugSelectedAllyBot.getSlot()][false]
    debugSelectedAllyBot = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0[false]


rule "[debug] (Left) BotStateView":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "AllyBots"

  if debugSelectedAction == 2: # previous bot
    eventPlayer.list0 = sorted(
      [player for player in getPlayers(Team.1) if player.isDummy()],
      lambda i: i.getSlot()
    )
    eventPlayer.tmp0 = [player for player in eventPlayer.list0 if not debugSelectedAllyBot or player.getSlot() < debugSelectedAllyBot.getSlot()].last()
    debugSelectedAllyBot = eventPlayer.tmp0 if eventPlayer.tmp0 else eventPlayer.list0.last()
  

rule "[debug] Ally bot: Init":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isDummy()
  
  eventPlayer.startForcingName("Ally bot {}".format(eventPlayer.getSlot()))
  eventPlayer.isReady = true
  eventPlayer.healthBoostPercent += 10000
  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  eventPlayer.damageBoostPercent = 10000
  eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
  eventPlayer.target0 = getPlayers(Team.2)[0]
  eventPlayer.startFacing(
    (vect(0, 0, 0) if eventPlayer.abilState0 else 1.5 * directionTowards(eventPlayer, eventPlayer.target0)) + (directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition() + 0.25 * Vector.UP)),
    300
  )

rule "[debug] Ally bot: Find Target":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isDummy()

  eventPlayer.tmp0 = (
    sorted(
      [player for player in getLivingPlayers(Team.2) if (not player.hasStatus(Status.ASLEEP)) and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition() + 0.5 * Vector.DOWN)],
      lambda i: ((0.25 if i == eventPlayer.target0 else 1) * distance(eventPlayer, i))
    )
  )[0]
  if eventPlayer.tmp0:
    eventPlayer.abilState0 = true
    eventPlayer.target0 = eventPlayer.tmp0
  else:
    eventPlayer.abilState0 = false
  wait(0.5)
  if ruleCondition:
    loop()


rule "[debug] Ally bot: Start / Stop Shooting":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isDummy()
  @Condition (eventPlayer.abilState0 and not eventPlayer.isMoving())
  
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  waitUntil(not (eventPlayer.abilState0 and not eventPlayer.isMoving()), INFINITY)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    

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
