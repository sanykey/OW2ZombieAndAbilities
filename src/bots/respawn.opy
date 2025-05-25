#!mainFile "../main.opy"

rule "Clear effects for destroed dummy bots":
  @Event playerLeft
  @Condition getNumberOfPlayers(Team.2) < wSettingsMaxZombieBots
  
  for lastZombiesI in range(LAST_ZOMBIES_ICONS_AMOUNT):
    destroyIcon(lastZombiesIcons[lastZombiesI])

rule "Setup new bots": 
  @Event playerJoined
  @Team 2

  getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
  eventPlayer.setMaxHealth(botsHealthBoostPercent)
  wait()
  heal(eventPlayer, null, INFINITY)
  eventPlayer.setDamageDealt(botsDamageBoostPercent)
  eventPlayer.startModifyingVoicelinePitch(0.3)
  wait()
  eventPlayer.isReady = true
  eventPlayer.setRespawnTime(INFINITY)

rule "Zombie died":
  @Event playerDied
  @Team 2

  roundRemainingBots -= 1

  eventPlayer.setUltCharge(0)
  # reset the information about applying croud control abilities to the bot
  eventPlayer.lastCcAttacker = false
  eventPlayer.lastCcAttackTime = false
  eventPlayer.lastCcWasInAir = false

  # money, effects and team score for kills:
  eventPlayer.list0 = [player for player in getPlayers(Team.1) if eventPlayer.damageAssitsToSlot[player.getSlot()] > getTotalTimeElapsed()]
  smallMessage(eventPlayer.list0, "<TX C00000000021569> +${}".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list0.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list0.kills += 1
  eventPlayer.list0.lastKillTime = getTotalTimeElapsed()
  eventPlayer.damageAssitsToSlot = []
  wait()

  # Attempt to prevent simultaneous respawning of several bots (prevent race condition):
  waitUntil(
    floor((getTotalTimeElapsed() - floor(getTotalTimeElapsed())) * 100) % (wSettingsMaxZombieBots * 5) == eventPlayer.getSlot() * 5,
    INFINITY
  )

  if roundRemainingBots > wSettingsMaxZombieBots or getNumberOfLivingPlayers(Team.2) < roundRemainingBots:
    eventPlayer.teleport(random.choice(spawnPointsList))
    wait()
    eventPlayer.resurrect()

rule "Start round respawn zombies":
  @Condition roundRemainingBots > 0
  @Condition not isBotsDisabled

  zombieRespawnList = getDeadPlayers(Team.2)
  for zombieRespI in range(len(zombieRespawnList)):
    zombieRespawnList[zombieRespI].teleport(random.choice(spawnPointsList))
    wait(0.1)
    zombieRespawnList[zombieRespI].resurrect()


rule "Create bots":
  if not isGameStarted or isBotsDisabled or getNumberOfPlayers(Team.2) >= wSettingsMaxZombieBots:
    goto lbl_0

  smallMessage(hostPlayer, "[Server]: Create zombie bots")
  for createDummyI in range(wSettingsMaxZombieBots):
    if not getPlayersInSlot(createDummyI, Team.2):
      createDummy(Hero.TORBJORN, Team.2, createDummyI, random.choice(spawnPointsList))
      wait(0.4)

  lbl_0:
  wait(0.5, Wait.ABORT_WHEN_FALSE)
  loop()