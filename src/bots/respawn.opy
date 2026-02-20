#!mainFile "../main.opy"

globalvar deadZombieTeamPlayers
globalvar roundRemainingBotsToRespawn
globalvar respawnBotIndex
globalvar lastBots
globalvar createDummyI
globalvar createDummyQuantity
playervar teleportPos

# #!define MAX_DUMMY_BOTS 18
# Checks whether any dummy bot needs to be removed from the zombies team in order to create a dummy bot in team1. 
#   This is necessary due to the limitation on the number of bots in the workshop.
# def ReleaseZomBotsSlotSub():
#   @Name "ReleaseZomBotsSlotSub"

#   tmp0 = len([player for player in getNumberOfPlayers(Team.PLAYERS) if player.isDummy()])

#   # If the total number of dummy bots does not exceed the maximum allowed by the workshop, then do nothing:
#   if ((getNumberOfPlayers(Team.ZOMBIES) + tmp0 + 1) <= MAX_DUMMY_BOTS):
#     return

#   # First, dead and common dummy bots are removed
#   tmp1 = sorted(
#     getPlayers(Team.ZOMBIES),
#     lambda sortedPlayer: (
#       (0 if sortedPlayer in commonBotsHeroes else 2)
#       + (0 if sortedPlayer.isDead() else 1)
#     )
#   )

#   for I in range(tmp0 - MAX_DUMMY_BOTS):
#     destroyDummy(Team.ZOMBIES, tmp1[I].getSlot())
  
# def RestoreZomBotsSlotsSub():
#   @Name "RestoreZomBotsSlotsSub"

#   if getNumberOfPlayers(Team.ZOMBIES) + tmp0 == MAX_DUMMY_BOTS:
#     return


macro filterIsCommonBot(player):
  (
    player.getHero() in commonBotsHeroes
    and (not player.zomForceHeroOnRespawn or player.zomForceHeroOnRespawn in commonBotsHeroes)
  )

def GetCandidateForEliteZombieSub():
  @Name "SUB: Get Candidate For Elite Zombie"
  tmp1 = random.choice(
    [player for player in getPlayers(Team.ZOMBIES) if filterIsCommonBot(player)]
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
    combatants if eventPlayer.botWallPhase else null,
    eventPlayer,
    Icon.EYE,
    IconReeval.VISIBILITY_AND_POSITION,
    Color.RED
  )

rule "Zombie died":
  @Event playerDied
  @Team 2

  eventPlayer.stopForcingThrottle()
  roundRemainingBots -= 1
  eventPlayer.setUltCharge(0)
  eventPlayer.money__botStuckTimes = 0
  # eventPlayer.resetCrowdControlAttack() # todo: fix?
  teamScore += 1
  if eventPlayer.effectsIds[ZOMBIE_LAST_ICON]:
    destroyIcon(eventPlayer.effectsIds[ZOMBIE_LAST_ICON])
    eventPlayer.effectsIds[ZOMBIE_LAST_ICON] = null


rule "Recreate bots":
  @Condition isGameStarted
  @Condition not isBotsDisabled
  @Condition roundRemainingBots
  @Condition getNumberOfPlayers(Team.ZOMBIES) != roundMaxBotsSlots

  # Delete unnecessary bots:
  if getNumberOfPlayers(Team.ZOMBIES) > roundMaxBotsSlots: 
    tmp0 = sorted(
      getPlayers(Team.ZOMBIES),
      lambda sortedPlayer: (
        (0 if sortedPlayer in commonBotsHeroes else 2)
        + (0 if sortedPlayer.isDead() else 1)
      )
    )

    createDummyQuantity = getNumberOfPlayers(Team.ZOMBIES) - roundMaxBotsSlots
    for I in range(createDummyQuantity):
      destroyDummy(Team.ZOMBIES, tmp0[I].getSlot())
  
  # Or add missing bots:
  else:
    createDummyQuantity = roundMaxBotsSlots - getNumberOfPlayers(Team.ZOMBIES)
    for createDummyI in range(createDummyQuantity):
      createDummy(
        commonZombieHero,
        Team.ZOMBIES,
        -1,
        debugBotsSpawnPoint if debugBotsSpawnPoint else random.choice(spawnPointsList),
        random.choice(spawnPointsList)
      )
      wait(0.1 if getAverageServerLoad() < 200 else 0.5)


#!define ZOMBIE_RESPAWN_DISTANCE 17

macro Player.respawnBot(self):
  if debugBotsSpawnPoint:
    self.teleport(debugBotsSpawnPoint)
  else:
    tmp1 = random.choice(combatants)
    tmp2 = random.randint(0, 360)
    self.teleportPos = nearestWalkablePosition(
        (
            tmp1 + worldVector(vect(ZOMBIE_RESPAWN_DISTANCE * cos(tmp2), 0, ZOMBIE_RESPAWN_DISTANCE * sin(tmp2)), tmp1, Transform.ROTATION)
        ).getPosition()
    )
    self.teleport(self.teleportPos)
    
    # self.setStatusEffect(null, Status.KNOCKED_DOWN, 0.6)
    # wait(0.2)
    # self.setGravity(20)
    # self.disableEnvironmentCollision(true)
    # self.teleport(tmp3 + vect(0, -1.5, 0))
    # self.applyImpulse(Vector.UP, 3.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    # wait(0.4)
    # self.setGravity(100)
    # self.enableEnvironmentCollision()

    # self.teleport(random.choice(spawnPointsList))
  wait()
  if self.zomForceHeroOnRespawn:
    self.startForcingHero(self.zomForceHeroOnRespawn)
    self.zomForceHeroOnRespawn = false
    self.resurrect()
  else:
    self.resurrect()

  # self.setStatusEffect(null, Status.KNOCKED_DOWN, 1)
  # wait(0.2)
  # self.setGravity(20)
  # self.disableEnvironmentCollision(true)

  # self.teleport(debugBotsSpawnPoint + vect(0, -1.5, 0))
  # wait()

  # playEffect(getAllPlayers(), DynamicEffect.SIGMA_ACCRETION_IMPACT, rgb(220, 175, 100), self.getEyePosition(), 3)
  # playEffect(getAllPlayers(), DynamicEffect.SIGMA_ACCRETION_IMPACT_SOUND, Color.GRAY, self.getEyePosition(), 50)
  # self.applyImpulse(Vector.UP, 3.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  # wait(0.4)
  # self.clearStatusEffect(Status.KNOCKED_DOWN)
  # self.setGravity(100)
  # self.enableEnvironmentCollision()

  if self.getHero() != Hero.WIDOWMAKER and self.getHero() != Hero.ECHO:
    self.startForcingThrottle(1, 1, 0, 1, 0, 1)

  if zomInstantUltimates and self.getHero() == Hero.TORBJORN:
    self.setUltCharge(100)

  wait()
  heal(self, null, INFINITY)


rule "Respawn bots loop":
  @Condition roundNumber > 0
  @Condition not isBotsDisabled

  respawnBotIndex = (respawnBotIndex + true) % wSettingsMaxZombieBots
  tmp0 = getPlayers(Team.ZOMBIES)[respawnBotIndex]

  if tmp0.isDead() and roundRemainingBots > getNumberOfLivingPlayers(Team.ZOMBIES):
    tmp0.isReady = true
  wait(0.2 if getAverageServerLoad() < 200 else 0.8, Wait.ABORT_WHEN_FALSE)

  if ruleCondition:
    loop()

rule "Respawn bot":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isReady
  
  if debugBotsSpawnPoint:
    eventPlayer.teleportPos = debugBotsSpawnPoint
  else:
    eventPlayer.tmp1 = random.choice(combatants)
    eventPlayer.tmp2 = random.randint(0, 359)
    eventPlayer.teleportPos = nearestWalkablePosition(
        (
            eventPlayer.tmp1 + worldVector(vect(ZOMBIE_RESPAWN_DISTANCE * cos(eventPlayer.tmp2), 0, ZOMBIE_RESPAWN_DISTANCE * sin(eventPlayer.tmp2)), eventPlayer.tmp1, Transform.ROTATION)
        ).getPosition()
    )

  eventPlayer.setGravity(20)
  eventPlayer.disableEnvironmentCollision(true)
  eventPlayer.teleport(eventPlayer.teleportPos + vect(0, -1.5, 0))

  if eventPlayer.zomForceHeroOnRespawn:
    eventPlayer.startForcingHero(eventPlayer.zomForceHeroOnRespawn)
    eventPlayer.zomForceHeroOnRespawn = false
    eventPlayer.resurrect()
  else:
    eventPlayer.resurrect()

  eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
  wait(0.2)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayersInRadius(eventPlayer, 10, Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 80)
  eventPlayer.applyImpulse(Vector.UP, 2.5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.4)
  eventPlayer.setGravity(100)
  eventPlayer.enableEnvironmentCollision()

  if eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO:
    eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  if zomInstantUltimates and eventPlayer.getHero() == Hero.TORBJORN:
    eventPlayer.setUltCharge(100)

  wait()
  heal(eventPlayer, null, INFINITY)
  eventPlayer.isReady = false

rule "Last zombie icons":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.hasSpawned()
  @Condition roundRemainingBots < 4 and roundRemainingBots > 0
  @Condition not eventPlayer.effectsIds[ZOMBIE_LAST_ICON]
  @Condition getNumberOfLivingPlayers(Team.ZOMBIES) < 4

  createIcon(
    combatants,
    eventPlayer,
    Icon.SKULL,
    IconReeval.POSITION,
    Color.RED
  )
  eventPlayer.effectsIds[ZOMBIE_LAST_ICON] = getLastCreatedEntity()