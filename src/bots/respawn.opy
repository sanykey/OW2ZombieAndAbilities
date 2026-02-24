#!mainFile "../main.opy"

globalvar deadZombieTeamPlayers
globalvar roundRemainingBotsToRespawn
globalvar respawnBotIndex
globalvar createDummyI
globalvar createDummyQuantity
globalvar lastCreatedDummy
playervar teleportPos
playervar respawnNearFallback

#!define PLAYERS_VANILLA_SPAWN_POINT_VECT vect(101.77, 14.62, -113.01)
#!define PLAYERS_VANILLA_SPAWN_POINT_RADIUS 16.74

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

#!define ZOMBIE_RESPAWN_DISTANCE 17
#!define ZOMBIE_RESPAWN_MIN_DISTANCE 12
#!define ZOMBIE_RESPAWN_SEARCH_ATTEMPTS 8
#!define ZOMBIE_RESPAWN_ANGLE_STEP 45
def GetRandomTeleportPosSub():
  @Name "GetRandomTeleportPosNearCombatantSub"
  if not combatants:
    eventPlayer.teleportPos = nearestWalkablePosition(eventPlayer.getPosition())
    goto lbl_1

  eventPlayer.respawnNearFallback = true
  eventPlayer.teleportPos = null
  eventPlayer.tmp5 = null

  for I in range(ZOMBIE_RESPAWN_SEARCH_ATTEMPTS):
    eventPlayer.tmp1 = random.choice(combatants)
    eventPlayer.tmp2 = (random.randint(0, 359) + (I * ZOMBIE_RESPAWN_ANGLE_STEP)) % 360

    eventPlayer.tmp3 = nearestWalkablePosition(
      (
        eventPlayer.tmp1 + worldVector(
          vect(
            ZOMBIE_RESPAWN_DISTANCE * cos(eventPlayer.tmp2),
            0,
            ZOMBIE_RESPAWN_DISTANCE * sin(eventPlayer.tmp2)
          ),
          eventPlayer.tmp1,
          Transform.ROTATION
        )
      ).getPosition()
    )

    if distance(eventPlayer.tmp3, PLAYERS_VANILLA_SPAWN_POINT_VECT) < PLAYERS_VANILLA_SPAWN_POINT_RADIUS:
      continue

    if getRealPlayersInRadius(eventPlayer.tmp3, ZOMBIE_RESPAWN_MIN_DISTANCE, Team.PLAYERS, LosCheck.OFF):
      continue

    if getRealPlayersInRadius(eventPlayer.tmp3 + LosHeightCheckVectConst, BOT_MAX_TARGET_DISTANCE, Team.PLAYERS, LosCheck.SURFACES):
      eventPlayer.teleportPos = eventPlayer.tmp3

      eventPlayer.respawnNearFallback = false
      break
    else:
      eventPlayer.tmp5 = eventPlayer.tmp3
      eventPlayer.respawnNearFallback = false

  if not eventPlayer.teleportPos:
    if eventPlayer.tmp5:
      eventPlayer.teleportPos = eventPlayer.tmp5
    else:
      eventPlayer.teleportPos = nearestWalkablePosition(eventPlayer.getPosition())

  lbl_1:

def GetSpawnPointSub():
  @Name "GetSpawnPointSub"

  if debugZombieBotsSpawnPoint:
    eventPlayer.teleportPos = debugZombieBotsSpawnPoint
  else:
    GetRandomTeleportPosSub()

def RessurectZombieBotSub():
  @Name "RessurectZombieBotSub"
  if eventPlayer.zomForceHeroOnRespawn:
    eventPlayer.startForcingHero(eventPlayer.zomForceHeroOnRespawn)
    eventPlayer.zomForceHeroOnRespawn = false
    eventPlayer.resurrect()
  else:
    eventPlayer.resurrect()

  if eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO:
    eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  if zomInstantUltimates and eventPlayer.getHero() == Hero.TORBJORN:
    eventPlayer.setUltCharge(100)

  wait()
  heal(eventPlayer, null, INFINITY)

def TeleportWithAnimationSub():
  @Name "TeleportWithAnimationSub"
  eventPlayer.isReady__isBotRespawning = true
  eventPlayer.disableEnvironmentCollision(true)
  eventPlayer.disablePlayerCollision()
  eventPlayer.teleport(eventPlayer.teleportPos + vect(0, -1.5, 0))

  wait()

  # "rising from underground" spawn animation:
  eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 1.5)
  wait(0.2)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayersInRadius(eventPlayer, 10, Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 80)
  eventPlayer.isReady__isBotRespawning = getTotalTimeElapsed()
  eventPlayer.startForcingPosition(eventPlayer.teleportPos + vect(0, -1.2 + (getTotalTimeElapsed() - eventPlayer.isReady__isBotRespawning), 0))
  wait()
  while eventPlayer.getPosition().y <= eventPlayer.teleportPos.y:
    wait(0.1)
  eventPlayer.stopForcingPosition()
  
  eventPlayer.enableEnvironmentCollision()
  eventPlayer.enablePlayerCollision()

  eventPlayer.isReady__isBotRespawning = false

  # STUNNED is a safety buffer when a bot had to spawn too close to players.
  if eventPlayer.respawnNearFallback:
    wait(0.85)
    if eventPlayer.isAlive():
      eventPlayer.setStatusEffect(null, Status.STUNNED, 2)


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

  ResetBotStuckTimesSub()
  ResetCrowdControlTimeSub()
  eventPlayer.botTargetLastPosition = null
  eventPlayer.botWallPhase = false
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
        OffmapPositionConst,
        OffmapPositionConst
      )
      wait(0.1 if getAverageServerLoad() < 200 else 0.5)

rule "Respawn bots loop":
  @Condition roundNumber > 0
  @Condition not isBotsDisabled
  @Condition combatants

  respawnBotIndex = (respawnBotIndex + 1) % wSettingsMaxZombieBots
  tmp0 = getPlayers(Team.ZOMBIES)[respawnBotIndex]

  if tmp0.isDead() and roundRemainingBots > getNumberOfLivingPlayers(Team.ZOMBIES):
    tmp0.isReady__isBotRespawning = true
  wait(0.2 if getAverageServerLoad() < 200 else 0.8, Wait.ABORT_WHEN_FALSE)

  if ruleCondition:
    loop()

rule "Respawn bot":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isDead()
  @Condition eventPlayer.isReady__isBotRespawning
  
  GetSpawnPointSub()
  async(RessurectZombieBotSub, AsyncBehavior.NOOP)
  TeleportWithAnimationSub()

#!define NUMBER_OF_LAST_ZOMBIES_FOR_ICON 4
rule "Last zombie icons":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.hasSpawned()
  @Condition roundRemainingBots < NUMBER_OF_LAST_ZOMBIES_FOR_ICON and roundRemainingBots > 0
  @Condition not eventPlayer.effectsIds[ZOMBIE_LAST_ICON]
  @Condition getNumberOfLivingPlayers(Team.ZOMBIES) < NUMBER_OF_LAST_ZOMBIES_FOR_ICON

  createIcon(
    combatants,
    eventPlayer,
    Icon.SKULL,
    IconReeval.POSITION,
    Color.RED
  )
  eventPlayer.effectsIds[ZOMBIE_LAST_ICON] = getLastCreatedEntity()
