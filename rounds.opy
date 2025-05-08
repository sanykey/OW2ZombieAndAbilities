#!mainFile "main.opy"

rule "Waiting for players ready":
  @Event eachPlayer
  @Team 1
  @Condition isGameStarted == false
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

  smallMessage(getAllPlayers(), "START!")
  isGameStarted = true

rule "Bot died":
  @Event playerDied
  @Team 2
  @Condition roundRemainingBots > 0

  eventPlayer.setUltCharge(0)

  if isBotsDisabled == false:
    roundRemainingBots -= 1

  if roundRemainingBots <= 0:
    isRoundEnd = true

rule "disable bot auto respawn":
  @Event playerJoined
  @Team 2

  eventPlayer.disableRespawn()

rule "Create bots":
  @Condition isBotsDisabled == false
  @Condition isGameStarted == true
  @Condition getNumberOfPlayers(Team.2) < MAX_ZOMBIES
  @Condition getPlayers(Team.1).hasSpawned() == true
  
  wait(1)
  if isBotsDisabled == true:
    return
  for I in range(MAX_ZOMBIES):
    createDummy(Hero.TORBJORN, Team.2, I, random.choice(spawnPointsList))
  getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
  getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
  getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])


rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
  destroyIcon(J[21]) # remove last zombie marker
  bigMessage(getAllPlayers(), l"Round {0}".format(roundNumber))
  
  # Resurrect and heal all players
  temp1 = [player for player in getPlayers(Team.1) if not player.downedStartTime]
  temp2 = [player for player in getPlayers(Team.1) if player.downedStartTime]
  temp2.teleport(nearestWalkablePosition(random.choice(temp1) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
  temp2.downedStartTime = 0
  temp2.resurrect()

  zombieStats[ZI.HP_STAT] = (ZOMBIE_BASE_HP + 10 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  zombieStats[ZI.DAMAGE_STAT] = (ZOMBIE_BASE_DAMAGE + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))

  wait(0.25)
  heal(getPlayers(Team.1), null, INFINITY)

  wait(5)
  bigMessage(getAllPlayers(), "Starting Round!")
  roundRemainingBots = 10 + roundNumber * 2

  getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
  getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])

  for zombieRespawnI in range(MAX_ZOMBIES):
    if isBotsDisabled == true:
      break
    getPlayersInSlot(zombieRespawnI, Team.2).respawn()
    wait(0.25)

  isRoundEnd = false
  heal(getPlayers(Team.2), null, 9999)

rule "Respawn bots":
  @Condition isRoundEnd == false
  @Condition roundNumber >= 1
  @Condition getNumberOfLivingPlayers(Team.2) < roundRemainingBots
  @Condition getNumberOfLivingPlayers(Team.2) < MAX_ZOMBIES
  @Condition isBotsDisabled == false
  
  wait(3, Wait.ABORT_WHEN_FALSE)
  random.choice(getDeadPlayers(Team.2)).respawn()
  if RULE_CONDITION:
    goto RULE_START

rule "Mark last zombie":
  @Event eachPlayer
  @Team 2
  @Condition isRoundEnd == false
  @Condition roundRemainingBots < 2
  @Condition getNumberOfLivingPlayers(Team.2) == 1
  @Condition eventPlayer.isAlive() == true
  
  createIcon(getPlayers(Team.1), eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
  J[21] = getLastCreatedEntity()

rule "Match end":
  @Condition not isDebugAutoRespawn
  @Condition all([player.isDead() for player in getPlayers(Team.1)]) == true
  @Condition getPlayers(Team.1).hasSpawned() == true
  
  matchIsOver = true
  destroyAllEffects()
  destroyAllInWorldTexts()
  wait(3)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Survived", roundNumber, l"Rounds"))
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Total", l"{0}:".format(l"Score"), teamScore))
  wait(4)
  declareTeamVictory(Team.2)

rule "[Bot Anti-Spawn Check A]":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isInSpawnRoom() == true
  
  eventPlayer.teleport(random.choice(spawnPointsList))
