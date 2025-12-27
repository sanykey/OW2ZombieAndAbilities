#!mainFile "../main.opy"

#!define MAX_ALLY_BOTS 6
#!define MIN_ALLY_BOT_SLOT 7

globalvar debugAllyBotCreated

rule "[debug] add AllyBots debug mode":
  debugModesArr.append("AllyBots")

rule "[debug] init Bot state view mode":
  ConditionForInitMode("AllyBots")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 2

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    "{}
    {}Add ally bot in my position</fg>
    {}Remove all ally bots</fg>
    ----------
    If you die, say `Thanks` and the bot will move to your position to revive you.
    ".format(
      debugMenuTitle("AllyBots"),
      debugSelectedActionText(1),
      debugSelectedActionText(2)
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
        return
  elif debugSelectedAction == 2: # Remove all ally bots
    for I in range(MIN_ALLY_BOT_SLOT, MIN_ALLY_BOT_SLOT + MAX_ALLY_BOTS):
      destroyDummy(Team.1, I)
    debugAllyBotCreated = false

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
  eventPlayer.targetPlayer0 = getPlayers(Team.2)[0]
  eventPlayer.startFacing(
    (vect(0, 0, 0) if eventPlayer.abilState0 else 1.5 * directionTowards(eventPlayer, eventPlayer.targetPlayer0)) + (directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition() + 0.25 * Vector.UP)),
    300
  )

rule "[debug] Ally bot: Find Target":
  @Event eachPlayer
  @Condition debugAllyBotCreated
  @Team 1
  @Hero orisa
  @Condition eventPlayer.isDummy()

  eventPlayer.temp0 = (
    sorted(
      [player for player in getLivingPlayers(Team.2) if (not player.hasStatus(Status.ASLEEP)) and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition() + 0.5 * Vector.DOWN)],
      lambda i: ((0.25 if i == eventPlayer.targetPlayer0 else 1) * distance(eventPlayer, i))
    )
  )[0]
  if eventPlayer.temp0:
    eventPlayer.abilState0 = true
    eventPlayer.targetPlayer0 = eventPlayer.temp0
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
  @Condition not eventPlayer.isAlive() or eventPlayer.downedStartTime
  @Condition eventPlayer.isCommunicating(Comms.THANKS)

  random.choice(
    [player for player in getLivingPlayers(Team.1) if player.isDummy() and player.getHero() == Hero.ORISA]
  ).teleport(eventPlayer.getPosition())
