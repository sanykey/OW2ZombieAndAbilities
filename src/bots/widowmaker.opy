#!mainFile "../main.opy"

rule "[Team2 Widowmaker] global init":
  botSniperPositions = [
    vect(13.33, 11.61, -42.38),
    vect(13.86, 12.56, -82.01),
    vect(22.09, 12.30, -73.98),
    vect(32.08, 8.79, -48.16),
    vect(33.31, 14.89, -85.18),
    vect(56.24, 23.98, -103.35),
    vect(50.73, 19.47, -78.32),
    vect(98.86, 19.71, -72.58),
    vect(89.35, 22.09, -62.54),
    vect(81.28, 17.02, -38.14),
    vect(117.72, 20.17, -42.66),
    vect(125.06, 16.04, -19.54),
    vect(110.83, 14.02, -47.27)
  ]

def botWidowmakerClear():
  @Name "[Team2 Widowmaker] clear after switch"
  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  destroyEffect(eventPlayer.abilPos1)

def botWidowmakerChangePositon():
  @Name "[Team2 Widowmaker] change position"

  if botSniperPositionsPlayerisInLoS:
    eventPlayer.teleport(botSniperPositionsPlayerisInLoS[random.randint(0, len(eventPlayer.list0) - 1)])
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 2)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)

rule "[Team2 Widowmaker] check isInLoS players from botSniperPositions":
  botSniperPositionsPlayerisInLoS = (
    [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  )

  wait(1, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

rule "[Team2 Widowmaker] trigger change position":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive() and not eventPlayer.downedStartTime

  botWidowmakerChangePositon()

  wait(15, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

# code from [Defend Castle - PvE](https://workshop.codes/BQEGS)
rule "[Team2 Widowmaker] - see player":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive() and not eventPlayer.downedStartTime
  @Condition eventPlayer.isReloading() == false
  @Condition eventPlayer.targetPlayer0 == null
  @Condition not eventPlayer.hasBadStatus
  #CAN SEE PLAYER
  @Condition any([isInLoS(eventPlayer.getEyePosition(), i.getEyePosition()) for i in getLivingPlayers(Team.1)]) == true
  
  eventPlayer.targetPlayer0 = (
    sorted(
      [player for player in getLivingPlayers(Team.1) if player.hasSpawned() and player.isInvisible < getTotalTimeElapsed() and isInLoS(eventPlayer.getEyePosition(), player.getEyePosition()) == true],
      lambda i: distance(eventPlayer.getPosition(), i.getPosition())
    )
  )[0]
  eventPlayer.abilState3 = getTotalTimeElapsed() + random.uniform(1, 1.6)
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()), INFINITY)
    
    
rule "[Team2 Widowmaker] - SHOOT":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive() and not eventPlayer.downedStartTime
  @Condition eventPlayer.isReloading() == false
  @Condition eventPlayer.targetPlayer0 != null
  @Condition eventPlayer.hasBadStatus == false
  @Condition getTotalTimeElapsed() >= eventPlayer.abilState3
  
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1) # We're warning the players that the widowmaker is about to take a shot
  wait(0.35)
  if (eventPlayer.targetPlayer0.isInvisible < getTotalTimeElapsed()):
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
  eventPlayer.stopFacing()
  eventPlayer.targetPlayer0 = null
