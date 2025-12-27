#!mainFile "../main.opy"

globalvar botWidowmakerSpawnCD
globalvar botWidowmakerAvaliableSpawnSpots

# some code from [Defend Castle - PvE](https://workshop.codes/BQEGS)

rule "[Team2 Widowmaker] died":
  @Event playerDied
  @Team 2
  @Hero widowmaker

  destroyEffect(eventPlayer.heroEffectsIds)
  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  setZombieHero(eventPlayer, commonZombieHero)
  botWidowmakerSpawnCD = getTotalTimeElapsed() + 30

rule "[Team2 Widowmaker] search actual sniper spots":
  @Condition botWidowmakerSpawnCD < getTotalTimeElapsed()

  botWidowmakerAvaliableSpawnSpots = []
  for I in range(VL_BOT_SNIPER_SPOTS_OFFSET, VL_BOT_SNIPER_SPOTS_OFFSET + VL_BOT_SNIPER_SPOTS_LEN):
    if isInLoS(vectList[I], getLivingPlayers(Team.1)):
      botWidowmakerAvaliableSpawnSpots.append(vectList[I])

  wait(7, Wait.ABORT_WHEN_FALSE)
    loop()

def BotWidowmakerChangePositon():
  @Name "[Team2 Widowmaker] change position"

  eventPlayer.teleport(random.choice(botWidowmakerAvaliableSpawnSpots))
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 2)
  playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "[Team2 Widowmaker] Add WIDOWMAKER to Team.2":
  @Condition roundNumber > 20
  @Condition botWidowmakerSpawnCD < getTotalTimeElapsed()
  @Condition botWidowmakerAvaliableSpawnSpots
  @Condition roundRemainingBots > getNumberOfLivingPlayers(Team.2)
  @Condition not getPlayersOnHero(Hero.WIDOWMAKER, Team.2)

  GetCandidateForEliteZombieSub() # returns temp1
  setZombieHero(temp1, Hero.WIDOWMAKER)

rule "[Team2 Widowmaker] Respawn":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()

  eventPlayer.stopForcingThrottle()
  wait(0.1)
  BotWidowmakerChangePositon()
  eventPlayer.startForcingButton(Button.SECONDARY_FIRE)
  createBeam(
    getPlayers(Team.1),
    Beam.TORBJORN_TURRET_SIGHT,
    eventPlayer.getEyePosition(),
    updateEveryFrame(
      raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 999, null, eventPlayer, false).getHitPosition()
    ),
    Color.RED,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds = getLastCreatedEntity()

rule "[Team2 Widowmaker] trigger change position":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER
  @Condition botWidowmakerSpawnCD < getTotalTimeElapsed()
  
  wait(5, Wait.ABORT_WHEN_FALSE)
  if not eventPlayer.targetPlayer0 and botWidowmakerAvaliableSpawnSpots:
    BotWidowmakerChangePositon()
  loop()

rule "[Team2 Widowmaker] - see player":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()

  eventPlayer.list0 = [] # avaliable targets
  for eventPlayer.I in range(MAX_PLAYERS):
    eventPlayer.temp0 = getPlayersInSlot(eventPlayer.I, Team.1)

    if (eventPlayer.temp0 and eventPlayer.temp0.hasSpawned() and eventPlayer.temp0.isAlive() and isInLoS(eventPlayer, eventPlayer.temp0)):
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.I] = distance(eventPlayer, eventPlayer.temp0)
      eventPlayer.list0.append(eventPlayer.temp0)
    else:
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.I] = INFINITY
      eventPlayer.zomIsInLoSPlayersArr[eventPlayer.I] = false
     
  eventPlayer.targetPlayer0 = (
    sorted(
      eventPlayer.list0,
      lambda i: eventPlayer.zomDistancesToPlayersArr[i.getSlot()] + (
        100 if i.isInvisible > getTotalTimeElapsed() and (eventPlayer.zomDistancesToPlayersArr[i.getSlot()] > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
      )
    )
  )[0]

  if eventPlayer.targetPlayer0:
    eventPlayer.setFacing(
      directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()),
      Relativity.TO_WORLD
    )
  wait(0.1)
  if ruleCondition:
    loop()
    
rule "[Team2 Widowmaker] shoot":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition not eventPlayer.isReloading()
  @Condition eventPlayer.targetPlayer0
  
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1) # We're warning the players that the widowmaker is about to take a shot
  wait(1)
  eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)

  wait(2)
  if ruleCondition:
    loop()