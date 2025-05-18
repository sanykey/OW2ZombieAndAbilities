#!mainFile "../main.opy"

rule "Waiting for players ready":
  @Event eachPlayer
  @Team 1
  @Condition isGameStarted == false
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.isHoldingButton(Button.CROUCH) 

  wait(0.5, Wait.ABORT_WHEN_FALSE)
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

rule "Bot died alt":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHealth() < 10
  @Condition eventPlayer.hasStatus(Status.UNKILLABLE)

  roundRemainingBots -= 1
  eventPlayer.temp0 = eventPlayer.getPosition()
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION, Team.1, eventPlayer.temp0, 5)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Team.1, eventPlayer.temp0, 200)
  wait()
  eventPlayer.setUltCharge(0)

  eventPlayer.list = [player for player in getPlayers(Team.1) if eventPlayer.damageAssitsToSlot[player.getSlot()] > getTotalTimeElapsed() ]

  smallMessage(eventPlayer.list, "${0} Kill".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list.money += MONEY_FOR_ZOMBIE_KILL
  teamScore += MONEY_FOR_ZOMBIE_KILL

  if roundRemainingBots <= MAX_ZOMBIES:
    eventPlayer.setStatusEffect(null, Status.ROOTED, INFINITY)
    eventPlayer.teleport(hiddenVector)
  else:
    eventPlayer.teleport(random.choice(spawnPointsList))
  wait()
  heal(eventPlayer, null, INFINITY)
  wait()
  eventPlayer.expectedHealth = eventPlayer.getHealth()

rule "disable auto respawn": 
  @Event playerJoined
  # @Team 2

  eventPlayer.disableRespawn()
  # todo: fix?
  # if not isDebugAutoRespawn:


rule "Create bots":
  @Condition not isBotsDisabled
  @Condition isGameStarted == true
  @Condition getNumberOfPlayers(Team.2) < MAX_ZOMBIES
  
  wait(3, Wait.ABORT_WHEN_FALSE)
  if isBotsDisabled:
    return

  for I in range(MAX_ZOMBIES):
    if not getPlayersInSlot(I, Team.2):
      createDummy(Hero.TORBJORN, Team.2, I, random.choice(spawnPointsList))
      getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
      getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
      getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])


rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
  destroyIcon(lastZombieEf) # remove last zombie marker
  bigMessage(getAllPlayers(), l"Round {0}".format(roundNumber))
  
  # Resurrect and heal all players
  
  temp2 = [player for player in getPlayers(Team.1) if player.downedStartTime]
  if temp2:
    temp2.teleport(nearestWalkablePosition(random.choice(getLivingPlayers(Team.1)) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
    temp2.downedStartTime = 0
    temp2.resurrect()

  zombieStats[ZI.HP_STAT] = (ZOMBIE_BASE_HP + 10 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  zombieStats[ZI.DAMAGE_STAT] = (ZOMBIE_BASE_DAMAGE + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))

  wait(0.25)
  heal(getPlayers(Team.1), null, INFINITY)

  wait(5)
  bigMessage(getAllPlayers(), "Starting Round!")
  roundRemainingBots = MAX_ZOMBIES + 40 + roundNumber if (MAX_ZOMBIES + roundNumber) < 35 else 35

  getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
  getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])

  # for zombieRespawnI in range(MAX_ZOMBIES):
  #   if isBotsDisabled == true or roundNumber == 1:
  #     break
  #   getPlayersInSlot(zombieRespawnI, Team.2).respawn()
  #   wait(0.25)

  if roundNumber >= 3:
    botWidowmakerCanRespawn = true

  getPlayers(Team.2).setStatusEffect(null, Status.UNKILLABLE, INFINITY)
  getPlayers(Team.2).clearStatusEffect(Status.ROOTED)

  for botsRespawnTemp in range(getNumberOfPlayers(Team.2)):
    getPlayers(Team.2)[botsRespawnTemp].teleport(random.choice(spawnPointsList))
    wait(0.1)

  isRoundEnd = false
  heal(getPlayers(Team.2), null, INFINITY)


rule "Respawn bots":
  @Condition roundNumber >= 1
  @Condition isBotsDisabled == false

  if isRoundEnd:
    goto lbl_0

  if (getNumberOfLivingPlayers(Team.2) < MAX_ZOMBIES and getNumberOfLivingPlayers(Team.2) < roundRemainingBots):
    botsRespawnTemp = random.choice(getDeadPlayers(Team.2))
    botsRespawnTemp.respawn()
    wait()

    if roundNumber > 0 and botsRespawnTemp.getSlot() == MAX_ZOMBIES - 1:
      botsRespawnTemp.startForcingHero(Hero.ROADHOG)
    elif roundNumber > 0 and botsRespawnTemp.getSlot() == MAX_ZOMBIES - 2:
      botsRespawnTemp.startForcingHero(Hero.MAUGA)
    # elif roundNumber > 0 and botsRespawnTemp.getSlot() == MAX_ZOMBIES - 3:
    #   botsRespawnTemp.startForcingHero(Hero.ECHO)
    #   botsRespawnTemp.setMaxHealth(zombieStats[ZI.HP_STAT] / 2)
    # elif botsRespawnTemp.getHero() == Hero.WIDOWMAKER:
    #   botsRespawnTemp.setMaxHealth(zombieStats[ZI.HP_STAT])
    #   botsRespawnTemp.startForcingHero(Hero.TORBJORN)
      
    else:
      botsRespawnTemp.respawn()

  # widowmaker respawn
  # if (
  #   botWidowmakerCanRespawn and
  #   roundRemainingBots > 4 and
  #   [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  # ):
  #   botsRespawnTemp = random.choice([player for player in getLivingPlayers(Team.2) if player.getHero() == Hero.TORBJORN])
  #   if botsRespawnTemp:
  #     botsRespawnTemp.stopForcingThrottle()
  #     wait()
  #     botsRespawnTemp.startForcingHero(Hero.WIDOWMAKER)
  #     botsRespawnTemp.setMaxHealth(zombieStats[ZI.HP_STAT] / 2)
  #     botWidowmakerCanRespawn = false

  lbl_0:
  wait(3, Wait.ABORT_WHEN_FALSE)
  loop()

rule "Mark last zombie":
  @Event eachPlayer
  @Team 2
  @Condition isRoundEnd == false
  @Condition roundRemainingBots < 2
  @Condition getNumberOfLivingPlayers(Team.2) == 1
  @Condition eventPlayer.isAlive() == true
  
  createIcon(getPlayers(Team.1), eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
  lastZombieEf = getLastCreatedEntity()


rule "Match end":
  @Condition not isDebugAutoRespawn
  @Condition isGameStarted
  @Condition all(
    [player.isDead() or not player.hasSpawned() for player in getPlayers(Team.1)]
  )
  
  matchIsOver = true
  destroyAllEffects()
  destroyAllInWorldTexts()
  wait(3)
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Survived", roundNumber, l"Rounds"))
  bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Total", l"{0}:".format(l"Score"), teamScore))
  wait(4)
  declareTeamVictory(Team.2)
