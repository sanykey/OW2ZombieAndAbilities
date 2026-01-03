#!mainFile "../main.opy"

globalvar botWidowmakerSpawnCD
globalvar botWidowmakerAvaliableSpawnSpots

#!define ZOM_WINDOW_RESPAWN_CD 40

rule "[Team2 Widowmaker] search actual sniper spots":
  @Condition roundNumber >= ADD_WIDOWMAKER_ROUND
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
  @Condition roundNumber >= ADD_WIDOWMAKER_ROUND
  @Condition botWidowmakerSpawnCD < getTotalTimeElapsed()
  @Condition botWidowmakerAvaliableSpawnSpots
  @Condition roundRemainingBots > getNumberOfLivingPlayers(Team.2)
  @Condition not getPlayersOnHero(Hero.WIDOWMAKER, Team.2)

  GetCandidateForEliteZombieSub() # returns tmp1
  setZombieHero(tmp1, Hero.WIDOWMAKER)

rule "[Team2 Widowmaker] init":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER and eventPlayer.hasSpawned() and eventPlayer.isAlive()

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

  waitUntil(not ruleCondition, INFINITY)

  destroyEffect(eventPlayer.heroEffectsIds)
  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  setZombieHero(eventPlayer, commonZombieHero)
  if eventPlayer.isDead():
    botWidowmakerSpawnCD = getTotalTimeElapsed() + ZOM_WINDOW_RESPAWN_CD

rule "[Team2 Widowmaker] trigger change position":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.WIDOWMAKER
  @Condition botWidowmakerSpawnCD < getTotalTimeElapsed()
  
  wait(5, Wait.ABORT_WHEN_FALSE)
  if not eventPlayer.zomTarget and botWidowmakerAvaliableSpawnSpots:
    BotWidowmakerChangePositon()
  loop()

rule "[Team2 Widowmaker] - see player":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()

  if eventPlayer.zomAIstep == 0: # Execute once every 5 steps for optimization
    SearchTargetsSub()

  if eventPlayer.zomTarget:
    eventPlayer.setFacing(
      directionTowards(eventPlayer.getEyePosition(), eventPlayer.zomTarget.getEyePosition()),
      Relativity.TO_WORLD
    )

  # If Widowmaker is the only one remaining this round, replace her with a standard bot (no cooldown)
  #   that automatically moves toward players to end the round faster.
  if roundRemainingBots == 1: 
    setZombieHero(eventPlayer, commonZombieHero)

  # Step counter — used to run certain actions only periodically for optimization:
  eventPlayer.zomAIstep = 0 if eventPlayer.zomAIstep >= 4 else eventPlayer.zomAIstep + 1
  wait(0.2)
  if ruleCondition:
    loop()
    
rule "[Team2 Widowmaker] shoot":
  @Event eachPlayer
  @Team 2
  @Hero widowmaker
  @Condition eventPlayer.hasSpawned() and eventPlayer.isAlive()
  @Condition not eventPlayer.isReloading()
  @Condition eventPlayer.zomTarget
  
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1) # We're warning the players that the widowmaker is about to take a shot
  wait(1)
  eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)

  wait(2)
  if ruleCondition:
    loop()