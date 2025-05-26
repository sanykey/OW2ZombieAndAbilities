#!mainFile "main.opy"

rule "Team 1 (Death)":
  @Event playerDied
  @Team 1
  @Condition not isDebugAutoRespawn

  if not eventPlayer.downedStartTime:
    pause3PCamera()
    smallMessage(getAllPlayers(), "{0} was downed!".format(eventPlayer))
    eventPlayer.downedStartTime = getTotalTimeElapsed()
    eventPlayer.reviveTimer = 0
  if eventWasEnvironment:
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer))

rule "Revive, check player in radius, unset is downed":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.downedStartTime
  @Condition eventPlayer.downedStartTime + 1 < getTotalTimeElapsed()
  
  eventPlayer.revivers = [player for player in getPlayers(Team.1) if player.isAlive() and distance(eventPlayer, vect(player.getPosition().x, eventPlayer.getPosition().y, player.getPosition().z)) <= 3 and abs(eventPlayer.getPosition().y - player.getPosition().y) <= 3]
  if eventPlayer.revivers == []:
    eventPlayer.reviveTimer = 0
  else:
    eventPlayer.reviveTimer += REVIVE_TIMER_TICK
    if eventPlayer.reviveTimer >= 100:
      smallMessage(getAllPlayers(), "{0} has been revived!".format(eventPlayer))
      eventPlayer.downedStartTime = 0
      eventPlayer.resurrect()
  wait(0.2)
  if ruleCondition:
    loop()


rule "Team 1: Player gets up":
  @Event eachPlayer
  @Team 1
  @Condition not eventPlayer.downedStartTime
  
  playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 200)
  eventPlayer.setHealth(INFINITY)
  eventPlayer.revivers = []
  unpause3PCamera()
  wait(2.5, Wait.ABORT_WHEN_FALSE)
  if not ruleCondition:
    return
  if eventPlayer.getSlot() == ALLY_BOT_PLAYER_SLOT:
    eventPlayer.communicate(Comms.READY)

