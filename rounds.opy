#!mainFile "main.opy"
rule "Bot died":
  @Event playerDied
  @Team 2
  @Condition roundRemainingBots > 0

  eventPlayer.setUltCharge(0)
  roundRemainingBots -= 1
  if roundRemainingBots <= 0:
    isRoundEnd = true

rule "disable bot auto respawn":
  @Event playerJoined
  @Team 2

  eventPlayer.disableRespawn()

rule "Create bots":
  @Condition getNumberOfPlayers(Team.2) < 12
  @Condition getPlayers(Team.1).hasSpawned() == true
  @Condition roundNumber == 1
  
  wait(1)
  for I in range(12):
    createDummy(Hero.TORBJORN, Team.2, I, random.choice(Y))
  getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")


rule "Round start":
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
  destroyIcon(J[21]) # remove last zombie marker
  bigMessage(getAllPlayers(), l"Round {0}".format(roundNumber))
  
  # Resurrect and heal all players
  temp1 = [player for player in combatants if not player.downedStartTime]
  temp2 = [player for player in combatants if player.downedStartTime]
  temp2.teleport(nearestWalkablePosition(random.choice(temp1) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
  temp2.downedStartTime = 0
  
  wait(0.25)
  heal(getPlayers(Team.1), null, 99999)

  wait(5)
  bigMessage(getAllPlayers(), "Starting Round!")
  roundRemainingBots = 10 + roundNumber * 2

  for I in range(MAX_ZOMBIES):
    getPlayersInSlot(I, Team.2).respawn()
    wait(0.25)
  isRoundEnd = false

  getPlayers(Team.2).setMoveSpeed(35 + 5 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  getPlayers(Team.2).setMaxHealth(80 + 15 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  getPlayers(Team.2).setDamageDealt(20 + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  wait(0.25)
  heal(getPlayers(Team.2), null, 9999)

rule "Respawn bots":
  @Condition isRoundEnd == false
  @Condition roundNumber >= 1
  @Condition getNumberOfLivingPlayers(Team.2) < roundRemainingBots
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
  
  eventPlayer.teleport(random.choice(Y))
