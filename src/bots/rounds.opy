#!mainFile "../main.opy"

#!define ROUND_START_DELAY 0.1
#!define MAX_REMAINING_ZOMBIES_IN_ROUND 35

# I accidentally discovered that if preventing bots from being killed and just teleporting them to respawn - it makes the server noticeably more stable
def botFakeDeathHandle():
  @Name "Team2 bot fake death handle"

  eventPlayer.downedStartTime = true
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 0.1) # Resetting continuing damage effects
  # todo: if is not alive?
  eventPlayer.temp0 = eventPlayer.getPosition()
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION, Team.1, eventPlayer.temp0, 5)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Team.1, eventPlayer.temp0, 200)

  if isBotsDisabled == false:
    roundRemainingBots -= 1

  if roundRemainingBots <= 0:
    isRoundEnd = true

  eventPlayer.setUltCharge(0)
  eventPlayer.lastCcAttacker = false
  eventPlayer.lastCcAttackTime = false
  eventPlayer.lastCcWasInAir = false

  # eventPlayer.clearStatusEffect(Status.BURNING)
  eventPlayer.teleport(vect(-16.80, 1.23, 18.75))
  eventPlayer.setStatusEffect(null, Status.ROOTED, INFINITY)
  
  wait(0.2) # wait for turrets damage detect
  heal(eventPlayer, null, INFINITY)
  wait()
  eventPlayer.expectedHealth = eventPlayer.getHealth()
  wait(1)

  # money for kill:
  eventPlayer.list = [player for player in getPlayers(Team.1) if eventPlayer.damageAssitsToSlot[player.getSlot()] > getTotalTimeElapsed()]
  smallMessage(eventPlayer.list, "+${}: kill".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list.kills += 1
  teamScore += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.damageAssitsToSlot = []

  # respawn:
  eventPlayer.temp0 = len([player for player in getLivingPlayers(Team.2) if not player.downedStartTime])

  if eventPlayer.temp0 < roundRemainingBots:
    eventPlayer.teleport(random.choice(spawnPointsList))
    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.downedStartTime = false


# Bots shouldn't die (Bot fake death), but just in case, let's keep an eye on the event
rule "Bot died":
  @Event playerDied
  @Team 2
  # @Condition roundRemainingBots > 0

  botFakeDeathHandle()

rule "Bot fake death - low hp (alternative way)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHealth() < 10
  @Condition eventPlayer.hasStatus(Status.UNKILLABLE)
  botFakeDeathHandle()

rule "Create bots":
  @Condition not isBotsDisabled
  @Condition isGameStarted == true
  @Condition getNumberOfPlayers(Team.2) < wSettingsMaxZombieBots
  
  wait(3, Wait.ABORT_WHEN_FALSE)
  if isBotsDisabled:
    return

  for I in range(wSettingsMaxZombieBots):
    if not getPlayersInSlot(I, Team.2):
      createDummy(Hero.TORBJORN, Team.2, I, random.choice(spawnPointsList))
      getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
      getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
      getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])
      getPlayers(Team.2).setStatusEffect(null, Status.UNKILLABLE, INFINITY)


rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
  destroyIcon(lastZombieEf) # remove last zombie marker
  bigMessage(getAllPlayers(), l"Round {0}".format(roundNumber))
  setObjectiveDescription(localPlayer, "Round {}".format(roundNumber), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  
  # Resurrect and heal all players
  temp2 = [player for player in getPlayers(Team.1) if player.downedStartTime]
  if temp2:
    temp2.teleport(nearestWalkablePosition(random.choice(getLivingPlayers(Team.1)) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
    temp2.downedStartTime = false
    temp2.resurrect()

  zombieStats[ZI.HP_STAT] = (ZOMBIE_BASE_HP + 10 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))
  zombieStats[ZI.DAMAGE_STAT] = (ZOMBIE_BASE_DAMAGE + 8 * getNumberOfPlayers(Team.1) + ((roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (roundNumber / (3.3 - getNumberOfPlayers(Team.1) / 8))))

  wait(0.25)
  heal(getPlayers(Team.1), null, INFINITY)
  wait(ROUND_START_DELAY)
  bigMessage(getAllPlayers(), "Starting Round!")
  roundRemainingBots = wSettingsMaxZombieBots + roundNumber if (wSettingsMaxZombieBots + roundNumber) < MAX_REMAINING_ZOMBIES_IN_ROUND else MAX_REMAINING_ZOMBIES_IN_ROUND

  getPlayers(Team.2).setMaxHealth(zombieStats[ZI.HP_STAT])
  getPlayers(Team.2).setDamageDealt(zombieStats[ZI.DAMAGE_STAT])

  # for zombieRespawnI in range(wSettingsMaxZombieBots):
  #   if isBotsDisabled == true or roundNumber == 1:
  #     break
  #   getPlayersInSlot(zombieRespawnI, Team.2).respawn()
  #   wait(0.25)

  if roundNumber >= 3:
    botWidowmakerCanRespawn = true

  getPlayers(Team.2).setStatusEffect(null, Status.UNKILLABLE, INFINITY)
  getPlayers(Team.2).clearStatusEffect(Status.ROOTED)

  for botsRespawnTemp in range(getNumberOfPlayers(Team.2)):
    if getPlayers(Team.2)[botsRespawnTemp].downedStartTime:
      getPlayers(Team.2)[botsRespawnTemp].teleport(random.choice(spawnPointsList))
      getPlayers(Team.2)[botsRespawnTemp].downedStartTime = false
      getPlayers(Team.2)[botsRespawnTemp].clearStatusEffect(Status.ROOTED)
      heal(getPlayers(Team.2)[botsRespawnTemp], null, INFINITY)
      wait(0.5)

  isRoundEnd = false

rule "Respawn bots":
  @Condition roundNumber >= 1
  @Condition isBotsDisabled == false

  if isRoundEnd:
    goto lbl_0

  if (getNumberOfLivingPlayers(Team.2) < wSettingsMaxZombieBots and getNumberOfLivingPlayers(Team.2) < roundRemainingBots):
    botsRespawnTemp = random.choice(getDeadPlayers(Team.2))
    botsRespawnTemp.respawn()
    wait()

    if roundNumber > 0 and botsRespawnTemp.getSlot() == wSettingsMaxZombieBots - 1:
      botsRespawnTemp.startForcingHero(Hero.ROADHOG)
    elif roundNumber > 0 and botsRespawnTemp.getSlot() == wSettingsMaxZombieBots - 2:
      botsRespawnTemp.startForcingHero(Hero.MAUGA)
    # elif roundNumber > 0 and botsRespawnTemp.getSlot() == wSettingsMaxZombieBots - 3:
    #   botsRespawnTemp.startForcingHero(Hero.ECHO)
    #   botsRespawnTemp.setMaxHealth(zombieStats[ZI.HP_STAT] / 2)
    # elif botsRespawnTemp.getHero() == Hero.WIDOWMAKER:
    #   botsRespawnTemp.setMaxHealth(zombieStats[ZI.HP_STAT])
    #   botsRespawnTemp.startForcingHero(Hero.TORBJORN)
      
    else:
      botsRespawnTemp.respawn()

    botsRespawnTemp.setStatusEffect(null, Status.UNKILLABLE, INFINITY)

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

# rule "Mark last zombie":
#   @Event eachPlayer
#   @Team 2
#   @Condition isRoundEnd == false
#   @Condition roundRemainingBots < 2
#   @Condition getNumberOfLivingPlayers(Team.2) == 1
#   @Condition eventPlayer.isAlive() == true
  
#   createIcon(getPlayers(Team.1), eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
#   lastZombieEf = getLastCreatedEntity()


rule "[debug] icons for bots":
  @Event eachPlayer
  @Team 2
  
  createIcon(getPlayers(Team.1) if not eventPlayer.downedStartTime else null, eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
  createIcon(getPlayers(Team.1) if eventPlayer.downedStartTime else null, eventPlayer, Icon.NO, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)