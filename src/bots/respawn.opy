#!mainFile "../main.opy"

macro filterIsNotEliteHeroForZombie(player):
  (
    player.getHero() != Hero.ROADHOG
    and player.zomForceHeroOnRespawn != Hero.ROADHOG
    and player.getHero() != Hero.MAUGA
    and player.zomForceHeroOnRespawn != Hero.MAUGA
    and player.getHero() != Hero.WIDOWMAKER
    and player.zomForceHeroOnRespawn != Hero.WIDOWMAKER
  )

def GetCandidateForEliteZombieSub():
  @Name "SUB: Get Candidate For Elite Zombie"
  tmp1 = random.choice(
    [player for player in getPlayers(Team.2) if filterIsNotEliteHeroForZombie(player)]
  )

macro setZombieHero(zomPlayer, zomHero):
  if zomPlayer.isAlive():
    zomPlayer.startForcingHero(zomHero)
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
  wait()
  heal(eventPlayer, null, INFINITY)


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

globalvar createDummyI
rule "Create bots":
  if not isGameStarted or isBotsDisabled or getNumberOfPlayers(Team.2) >= wSettingsMaxZombieBots:
    goto lbl_0

  smallMessage(hostPlayer, "[Server]: Create zombie bots")
  for createDummyI in range(wSettingsMaxZombieBots):
    if isBotsDisabled:
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

  lbl_0:
  wait(1.5)
  loop()

globalvar deadTeam2Players
globalvar roundRemainingBotsToRespawn
globalvar respawnBotIndex

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
      wait(0.1 if getAverageServerLoad() < 200 else 0.5, Wait.ABORT_WHEN_FALSE)

  wait(0.3, Wait.ABORT_WHEN_FALSE)
  loop()
