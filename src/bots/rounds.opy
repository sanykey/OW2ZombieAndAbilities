#!mainFile "../main.opy"

#!define ROUND_START_DELAY 0.1
#!define MAX_REMAINING_ZOMBIES_IN_ROUND 40
#!define BOT_WIDOWMAKER_RESPAWN_COOLDOWN 15
#!define BOT_ECHO_RESPAWN_COOLDOWN 15
#!define BOT_FAKE_DIE_HP_THRESHOLD 10

def afterDeathPreTeleportEffects():
  @Name "Team2 Bots pre death teleport effect"
  heal(eventPlayer, null, INFINITY)
  wait()
  eventPlayer.expectedHealth = eventPlayer.getHealth()
  playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_2, eventPlayer.getEyePosition(), 1)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Team.1, eventPlayer.getEyePosition(), 200)
  botsDeathPlaceIcons[eventPlayer.getSlot()] = eventPlayer.getPosition()


# [Bot fake death] I accidentally discovered that if preventing bots from being killed and just teleporting them to respawn - it makes the server noticeably more stable
def botFakeDeathHandle():
  @Name "Team2 bot fake death handle"

  # [Team2 Widowmaker] died
  if eventPlayer.getHero() == Hero.WIDOWMAKER:
    botWidowmakerClear()
    botWidowmakerRespawnTime = getTotalTimeElapsed() + BOT_WIDOWMAKER_RESPAWN_COOLDOWN
  # [Team2 Echo] died:
  elif eventPlayer.getHero() == Hero.ECHO:
    botEchoDetachPlayer()
    botEchoRespawnTime = getTotalTimeElapsed() + BOT_ECHO_RESPAWN_COOLDOWN

  eventPlayer.downedStartTime = true
  eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, INFINITY) # Stop current zombie ability
  wait()
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 1.1) # Resetting continuing damage effects
  eventPlayer.temp0 = eventPlayer.getEyePosition()

  if isBotsDisabled == false:
    roundRemainingBots -= 1

  if roundRemainingBots <= 0:
    isRoundEnd = true

  eventPlayer.setUltCharge(0)
  eventPlayer.lastCcAttacker = false
  eventPlayer.lastCcAttackTime = false
  eventPlayer.lastCcWasInAir = false

  # money, effects and team score for kills:
  eventPlayer.list = [player for player in getPlayers(Team.1) if eventPlayer.damageAssitsToSlot[player.getSlot()] > getTotalTimeElapsed()]
  smallMessage(eventPlayer.list, "<TX C00000000021569> +${}".format(MONEY_FOR_ZOMBIE_KILL)) # <TX C00000000003389> - turret icon
  eventPlayer.list.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list.kills += 1
  eventPlayer.list.lastKillTime = getTotalTimeElapsed()
  teamScore += MONEY_FOR_ZOMBIE_KILL

  wait(1) # wait for turrets damage detect

  # Turret damage has to be counted with a delay, so it is counted separately from other types of damage
  eventPlayer.list = [player for player in getPlayers(Team.1) if (
    eventPlayer.turretDamageTimeToSlot[player.getSlot()] >= getTotalTimeElapsed() and
    eventPlayer.damageAssitsToSlot[player.getSlot()] < getTotalTimeElapsed()
  )]
  smallMessage(eventPlayer.list, "<TX C00000000003389> +${}".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list.kills += 1
  eventPlayer.damageAssitsToSlot = []
  eventPlayer.turretDamageTimeToSlot = []

  # respawn:
  eventPlayer.list = [player for player in getLivingPlayers(Team.2) if not player.downedStartTime]

  if len(eventPlayer.list) >= roundRemainingBots:
    afterDeathPreTeleportEffects()
    eventPlayer.teleport(vect(-16.80, 1.23, 18.75))
    return

  if botWidowmakerRespawnTime > getTotalTimeElapsed() and eventPlayer.getHero() == Hero.WIDOWMAKER:
    eventPlayer.startForcingHero(Hero.TORBJORN)
  elif botEchoRespawnTime > getTotalTimeElapsed() and eventPlayer.getHero() == Hero.ECHO:
    eventPlayer.startForcingHero(Hero.TORBJORN)
  

  # [Team2 Roadhog] create bot:
  if roundNumber > 4 and len(getPlayersOnHero(Hero.ROADHOG)) < 1:
    eventPlayer.startForcingHero(Hero.ROADHOG)

  # [Team2 Mauga] create bot:
  elif roundNumber > 4 and len(getPlayersOnHero(Hero.MAUGA)) < 1:
    eventPlayer.startForcingHero(Hero.MAUGA)

  # [Team2 Widowmaker] respawn:
  elif (
    roundNumber > 2 and
    not getPlayersOnHero(Hero.WIDOWMAKER, Team.2) and 
    botWidowmakerRespawnTime < getTotalTimeElapsed() and
    eventPlayer.getHero() != Hero.ROADHOG and
    eventPlayer.getHero() != Hero.MAUGA and
    [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  ):
    afterDeathPreTeleportEffects()
    eventPlayer.startForcingHero(Hero.WIDOWMAKER)
    goto lbl_0

  # [Team2 Echo] respawn:
  # elif ( 
  #   roundNumber > 4 and
  #   not getPlayersOnHero(Hero.ECHO, Team.2) and
  #   botEchoRespawnTime < getTotalTimeElapsed() and
  #   eventPlayer.getHero() != Hero.ROADHOG and 
  #   eventPlayer.getHero() != Hero.MAUGA and
  #   [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  # ):
  #   eventPlayer.startForcingHero(Hero.ECHO)
  #   goto lbl_0
    
  afterDeathPreTeleportEffects()
  eventPlayer.teleport(random.choice(spawnPointsList))
  lbl_0:
  eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
  eventPlayer.downedStartTime = false
  if eventPlayer.isDead():
    eventPlayer.respawn()


rule "Create bots death place icons":
  botsDeathPlaceIcons = []
  for I in range(wSettingsMaxZombieBots):
    botsDeathPlaceIcons[I] = hiddenVector
    createInWorldText(
      getPlayers(Team.1),
      "<TX C0000000000B667>", # <TX C0000000000B666> <TX C0000000001C365> <TX C0000000002178B>
      botsDeathPlaceIcons[evalOnce(I)],
      1.7,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
      color=rgb(false,false,false,95)
    )

# Bots shouldn't die (Bot fake death), but just in case, let's keep an eye on the event
rule "Bot died":
  @Event playerDied
  @Team 2
  botFakeDeathHandle()

rule "Bot fake death - low hp (alternative way)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHealth() < BOT_FAKE_DIE_HP_THRESHOLD
  @Condition eventPlayer.hasStatus(Status.UNKILLABLE)
  botFakeDeathHandle()

rule "Setup created bots":
  @Event eachPlayer
  @Team 2
  getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
  eventPlayer.setMaxHealth(zombieStats[ZI.HP_STAT])
  wait()
  heal(eventPlayer, null, INFINITY)
  eventPlayer.setDamageDealt(zombieStats[ZI.DAMAGE_STAT])
  eventPlayer.setStatusEffect(null, Status.UNKILLABLE, INFINITY)
  eventPlayer.expectedHealth = eventPlayer.getHealth()
  eventPlayer.startModifyingVoicelinePitch(0.5 * (sinDeg(getTotalTimeElapsed() * evalOnce(random.uniform(360, 720)))))

  # debug:
  createIcon(getPlayers(Team.1) if not eventPlayer.downedStartTime else null, eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
  wait()
  createIcon(getPlayers(Team.1) if eventPlayer.downedStartTime else null, eventPlayer, Icon.NO, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)

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


rule "Round start":
  @Condition isGameStarted == true
  @Condition roundRemainingBots <= 0
  @Condition matchIsOver == false
  
  roundNumber += 1
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
  getPlayers(Team.2).setStatusEffect(null, Status.UNKILLABLE, INFINITY)

  # respawn bots
  for botsRespawnTemp in range(getNumberOfPlayers(Team.2)):
    if getPlayers(Team.2)[botsRespawnTemp].downedStartTime:
      getPlayers(Team.2)[botsRespawnTemp].teleport(random.choice(spawnPointsList))
      getPlayers(Team.2)[botsRespawnTemp].downedStartTime = false
      getPlayers(Team.2)[botsRespawnTemp].expectedHealth = getPlayers(Team.2)[botsRespawnTemp].getHealth()
      getPlayers(Team.2)[botsRespawnTemp].clearStatusEffect(Status.KNOCKED_DOWN)
      heal(getPlayers(Team.2)[botsRespawnTemp], null, INFINITY)
      wait(0.5)

  isRoundEnd = false

rule "Check bots state":
  @Condition roundNumber >= 1
  @Condition isBotsDisabled == false

  if isRoundEnd:
    goto lbl_0

  botsCheckList = [player for player in getLivingPlayers(Team.2) if not player.downedStartTime]

  for botsCheckTemp in range(len(botsCheckList)):
    # If an immortal zombie bot appears, heal it so it can be teleported away:
    if botsCheckList[botsCheckTemp].getHealth() < BOT_FAKE_DIE_HP_THRESHOLD:
      heal(botsCheckList[botsCheckTemp], null, BOT_FAKE_DIE_HP_THRESHOLD + true) 
    
    # Add icons to last zombies:
    # if roundRemainingBots < 5:
    #   createIcon(getPlayers(Team.1), evalOnce(botsCheckList[botsCheckTemp]), Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
    #   botsCheckList[botsCheckTemp].lastZombieIcon = getLastCreatedEntity()

  lbl_0:
  wait(3, Wait.ABORT_WHEN_FALSE)
  loop()

# rule "[debug] lastKillTime":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0

#   debug(eventPlayer.lastKillTime)