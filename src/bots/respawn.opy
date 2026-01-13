#!mainFile "../main.opy"


#!define START_BOTS_AMOUNT 6
#!define START_BOTS_ROUNDS 5
globalvar deadTeam2Players
globalvar roundRemainingBotsToRespawn
globalvar respawnBotIndex
globalvar lastBots
globalvar createDummyI = INFINITY

macro filterIsCommonBot(player):
  (
    player.getHero() in commonBotsHeroes
    and (not player.zomForceHeroOnRespawn or player.zomForceHeroOnRespawn in commonBotsHeroes)
  )

def GetCandidateForEliteZombieSub():
  @Name "SUB: Get Candidate For Elite Zombie"
  tmp1 = random.choice(
    [player for player in getPlayers(Team.2) if filterIsCommonBot(player)]
  )

macro setZombieHero(zomPlayer, zomHero):
  if zomPlayer.isAlive():
    zomPlayer.startForcingHero(zomHero)
    if zomHero == commonZombieHero:
      zomPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)
  else:
    zomPlayer.zomForceHeroOnRespawn = zomHero

rule "Setup new bots": 
  @Event playerJoined
  @Team 2

  eventPlayer.startForcingName("Zombie {}".format(eventPlayer.getSlot()))
  eventPlayer.setMoveSpeed(zomSpeedPct)
  eventPlayer.setMaxHealth(zomMaxHealthPct)
  eventPlayer.setDamageDealt(zomDamagePct)
  eventPlayer.startModifyingVoicelinePitch(0.3)
  eventPlayer.setRespawnTime(INFINITY)
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  createIcon(
    combatants if eventPlayer.zomFlyThroughWalls else null,
    eventPlayer,
    Icon.EYE,
    IconReeval.VISIBILITY_AND_POSITION,
    Color.RED
  )
  eventPlayer.effectsIds[ZOMBIE_FLY_ICON] = getLastCreatedEntity()

rule "Zombie bot left":
  @Event playerLeft
  @Team 2
  destroyIcon(eventPlayer.effectsIds[ZOMBIE_FLY_ICON])
  destroyIcon(eventPlayer.effectsIds[ZOMBIE_LAST_ICON])

rule "Zombie died":
  @Event playerDied
  @Team 2

  eventPlayer.stopForcingThrottle()
  roundRemainingBots -= 1
  eventPlayer.setUltCharge(0)
  eventPlayer.money__zomStuckPoints = 0
  eventPlayer.resetCrowdControlAttack()
  eventPlayer.zomDownedTime = getTotalTimeElapsed()
  teamScore += 1
  if eventPlayer.effectsIds[ZOMBIE_LAST_ICON]:
    destroyIcon(eventPlayer.effectsIds[ZOMBIE_LAST_ICON])
    eventPlayer.effectsIds[ZOMBIE_LAST_ICON] = false


rule "Create bots":
  if (
    not isGameStarted
    or isBotsDisabled
    or getNumberOfPlayers(Team.2) >= wSettingsMaxZombieBots
    or (getNumberOfPlayers(Team.2) >= START_BOTS_AMOUNT and roundNumber <= START_BOTS_ROUNDS) # Spawn fewer bots in the first few rounds to make it easier for players to start
    or roundRemainingBots < 1
    or createDummyI != INFINITY # Prevent rule activation while the bot-spawning loop is already running
  ):
    goto lbl_0

  smallMessage(hostPlayer, "[Server]: Create zombie bots")
  for createDummyI in range(START_BOTS_AMOUNT if (roundNumber <= START_BOTS_ROUNDS and wSettingsMaxZombieBots > START_BOTS_ROUNDS) else wSettingsMaxZombieBots):
    if isBotsDisabled:
      createDummyI = INFINITY
      goto lbl_0

    if not getPlayersInSlot(createDummyI, Team.2):
      createDummy(
        commonZombieHero,
        Team.2,
        createDummyI,
        debugBotsSpawnPoint if debugBotsSpawnPoint else random.choice(spawnPointsList),
        random.choice(spawnPointsList)
      )
      wait(0.1 if getAverageServerLoad() < 200 else 0.5)

  createDummyI = INFINITY
  lbl_0:
  wait(1.5)
  loop()


macro Player.respawnBot(self):
  if debugBotsSpawnPoint:
    self.teleport(debugBotsSpawnPoint)
  else:
    self.teleport(random.choice(spawnPointsList))
  wait()
  if self.zomForceHeroOnRespawn:
    self.startForcingHero(self.zomForceHeroOnRespawn)
    self.zomForceHeroOnRespawn = false
    self.resurrect()
  else:
    self.resurrect()
  
  if self.getHero() != Hero.WIDOWMAKER and self.getHero() != Hero.ECHO:
    self.startForcingThrottle(1, 1, 0, 1, 0, 1)

  if zomInstantUltimates and self.getHero() == Hero.TORBJORN:
    self.setUltCharge(100)

  wait()
  heal(self, null, INFINITY)

rule "respawn bots":
  @Condition roundRemainingBots > 0
  @Condition not isBotsDisabled

  roundRemainingBotsToRespawn = roundRemainingBots - getNumberOfLivingPlayers(Team.2)

  if roundRemainingBotsToRespawn > 0:
    deadTeam2Players = sorted(getDeadPlayers(Team.2), lambda i: i.zomDownedTime)
    for respawnBotIndex in range(
      roundRemainingBotsToRespawn if roundRemainingBotsToRespawn < len(deadTeam2Players) else len(deadTeam2Players)
    ):
      deadTeam2Players[respawnBotIndex].respawnBot()
      wait(0.2 if getAverageServerLoad() < 200 else 0.8, Wait.ABORT_WHEN_FALSE)

  elif roundNumber > 1 and roundRemainingBots < 4: # Add icons to the last zombie bots so players can find them quickly
    lastBots = [player for player in getPlayers(Team.2) if player.isAlive() and not player.effectsIds[ZOMBIE_LAST_ICON]]
    for respawnBotIndex in range(len(lastBots)):
      createIcon(
        combatants,
        evalOnce(lastBots[respawnBotIndex]),
        Icon.SKULL,
        IconReeval.POSITION,
        Color.RED
      )
      lastBots[respawnBotIndex].effectsIds[ZOMBIE_LAST_ICON] = getLastCreatedEntity()
      wait()

  wait(0.5, Wait.ABORT_WHEN_FALSE)
  loop()
