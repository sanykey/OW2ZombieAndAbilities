#!mainFile "../main.opy"

#!define BOT_WIDOWMAKER_RESPAWN_COOLDOWN 15
#!define BOT_ECHO_RESPAWN_COOLDOWN 15
#!define LAST_ZOMBIES_ICONS_AMOUNT 5


def playEffectsForZombieTeleport():
  playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR, Color.TEAM_2, eventPlayer.getEyePosition(), 1)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Team.1, eventPlayer.getEyePosition(), 200)

def teleportBotToHisHome():
  playEffectsForZombieTeleport()
  eventPlayer.teleport(vectList[VL_ZOMBIE_BOT_HOME])
  eventPlayer.isZombieInHome = true

def botFakeDeathRespawn():
  @Name "[Bot fake death] respawn"  

  # Attempt to prevent simultaneous respawning of several bots (prevent race condition):
  waitUntil(
    floor((getTotalTimeElapsed() - floor(getTotalTimeElapsed())) * 100) % (wSettingsMaxZombieBots * 5) == eventPlayer.getSlot() * 5,
    INFINITY
  )

  # Respawn if there are available roundRemainingBots slots; otherwise, send to base:
  eventPlayer.list0 = [player for player in getLivingPlayers(Team.2) if not player.downedStartTime]
  if len(eventPlayer.list0) >= roundRemainingBots:
    if not eventPlayer.isZombieInHome:
      teleportBotToHisHome()
    return

  if not eventPlayer.isZombieInHome:
    playEffectsForZombieTeleport()

  if botWidowmakerRespawnTime > getTotalTimeElapsed() and eventPlayer.getHero() == Hero.WIDOWMAKER:
    eventPlayer.startForcingHero(Hero.TORBJORN)
  elif botEchoRespawnTime > getTotalTimeElapsed() and eventPlayer.getHero() == Hero.ECHO:
    eventPlayer.startForcingHero(Hero.TORBJORN)
  

  # [Team2 Roadhog] create bot:
  if roundNumber > 4 and len(getPlayersOnHero(Hero.ROADHOG)) < 1:
    eventPlayer.startForcingHero(Hero.ROADHOG)

  # [Team2 Mauga] create bot:
  elif roundNumber > 2 and len(getPlayersOnHero(Hero.MAUGA)) < 1:
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
    eventPlayer.startForcingHero(Hero.WIDOWMAKER)
    botWidowmakerRespawn()
    wait()
    botWidowmakerChangePositon()

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

  if eventPlayer.isDead():
    eventPlayer.respawn()
    eventPlayer.setStatusEffect(null, Status.UNKILLABLE, INFINITY)

  if eventPlayer.getHero() == Hero.WIDOWMAKER or eventPlayer.getHero() == Hero.ECHO:
    eventPlayer.teleport(random.choice(spawnPointsList))
  else:
    eventPlayer.teleport(random.choice(spawnPointsList))

  # reset negative statuses and dot damage:
  if eventPlayer.getHealth() < 2:
    smallMessage(getAllPlayers(), "has dot damage?")
    eventPlayer.temp0 = eventPlayer.getHero()
    eventPlayer.startForcingHero(Hero.MOIRA)
    wait()
    eventPlayer.startForcingHero(eventPlayer.temp0)
    eventPlayer.damageAssitsToSlot = []


  heal(eventPlayer, null, INFINITY)
  wait()
  eventPlayer.expectedHealth = eventPlayer.getHealth()
  eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
  eventPlayer.clearStatusEffect(Status.PHASED_OUT)
  eventPlayer.downedStartTime = false
  eventPlayer.isZombieInHome = false

def GenjiResetShiftStrikeCooldown():
  @Name "[Genji] Reset Shift strike cooldown"
  wait(0.25)
  eventPlayer.list0.setAbilityCooldown(Button.ABILITY_1, 0)
  

# [Bot fake death] I accidentally discovered that if preventing bots from being killed and just teleporting them to respawn - it makes the server noticeably more stable
def botFakeDeathHandle():
  @Name "[Bot fake death] handle"

  eventPlayer.downedStartTime = true
  destroyIcon(eventPlayer.lastZombieIcon)
  eventPlayer.lastZombieIcon = false

  # [Team2 Widowmaker] died
  if eventPlayer.getHero() == Hero.WIDOWMAKER:
    botWidowmakerClear()
    botWidowmakerRespawnTime = getTotalTimeElapsed() + BOT_WIDOWMAKER_RESPAWN_COOLDOWN
  # [Team2 Echo] died:
  elif eventPlayer.getHero() == Hero.ECHO:
    botEchoDetachPlayer()
    botEchoRespawnTime = getTotalTimeElapsed() + BOT_ECHO_RESPAWN_COOLDOWN
  # [Team2 Mauga] died:
  elif eventPlayer.getHero() == Hero.MAUGA and eventPlayer.isUsingAbility1():
    eventPlayer.stopThrottleInDirection()
    eventPlayer.stopFacing()
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.05)

  if isBotsDisabled == false:
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

  # [Genji] Reset Shift strike cooldown for native behavior since bots no longer die
  eventPlayer.list0 = [player for player in eventPlayer.list0 if player.getHero() == Hero.GENJI]
  if eventPlayer.list0:
    async(GenjiResetShiftStrikeCooldown, AsyncBehavior.NOOP)

  teamScore += MONEY_FOR_ZOMBIE_KILL

  eventPlayer.stopAllDamageOverTime()

  # wait 1 second for: 
  # - turrets damage detect
  # - Set the zombie's Status.KNOCKED_DOWN to make it look like it was killed
  # - After using some abilities against zombies, Status.KNOCKED_DOWN status may be reset - restore this status
  eventPlayer.zombieWaitBeforeRespawnI = 0
  while (eventPlayer.zombieWaitBeforeRespawnI < 1.1):
    if not eventPlayer.hasStatus(Status.KNOCKED_DOWN):
      eventPlayer.clearStatusEffect(Status.PHASED_OUT)
      wait()
      eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, INFINITY)
      wait()
      eventPlayer.setStatusEffect(null, Status.PHASED_OUT, INFINITY) # Resetting continuing damage effects and disable the ability to interact with the "dead" bot.
      heal(eventPlayer, null, 2) # heal for detect dot damage
    eventPlayer.zombieWaitBeforeRespawnI += 0.1
    wait(0.1)

  # Turret damage has to be counted with a delay, so it is counted separately from other types of damage
  eventPlayer.list0 = [player for player in getPlayers(Team.1) if (
    eventPlayer.turretDamageTimeToSlot[player.getSlot()] >= getTotalTimeElapsed() and
    eventPlayer.damageAssitsToSlot[player.getSlot()] < getTotalTimeElapsed()
  )]
  smallMessage(eventPlayer.list0, "<TX C00000000003389> +${}".format(MONEY_FOR_ZOMBIE_KILL))
  eventPlayer.list0.money += MONEY_FOR_ZOMBIE_KILL
  eventPlayer.list0.kills += 1
  eventPlayer.damageAssitsToSlot = []
  eventPlayer.turretDamageTimeToSlot = []

  botFakeDeathRespawn()

# rule "[Bot fake death] Create bots death place icons and last zombies icons":
#   botsDeathPlaceIcons = []
#   # Create bots death place icons
#   for I in range(wSettingsMaxZombieBots):
#     botsDeathPlaceIcons[I] = hiddenVector
#     createInWorldText(
#       getPlayers(Team.1),
#       "<TX C0000000000B667>", # <TX C0000000000B666> <TX C0000000001C365> <TX C0000000002178B>
#       botsDeathPlaceIcons[evalOnce(I)],
#       10,
#       Clip.SURFACES,
#       WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
#       color=rgb(false,false,false,95)
#     )

rule "disable bots auto respawn": 
  @Event playerJoined
  @Team 2

  eventPlayer.disableRespawn()


rule "[Bot fake death] clear effects for destroed dummy bots":
  @Event playerLeft
  @Condition getNumberOfPlayers(Team.2) < wSettingsMaxZombieBots
  
  for lastZombiesI in range(LAST_ZOMBIES_ICONS_AMOUNT):
    destroyIcon(lastZombiesIcons[lastZombiesI])

# Bots shouldn't die (Bot fake death), but just in case, let's keep an eye on the event
rule "[Bot fake death] Bot died":
  @Event playerDied
  @Team 2
  botFakeDeathHandle()

rule "[Bot fake death] low hp (alternative way for turrets)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHealth() < BOT_FAKE_DIE_HP_THRESHOLD
  @Condition eventPlayer.isReady
  @Condition not eventPlayer.downedStartTime

  if not eventPlayer.downedStartTime:
  botFakeDeathHandle()

rule "Setup created bots":
  @Event eachPlayer
  @Team 2
  getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")
  eventPlayer.setMaxHealth(botsHealthBoostPercent)
  wait()
  heal(eventPlayer, null, INFINITY)
  eventPlayer.setDamageDealt(botsDamageBoostPercent)
  eventPlayer.setStatusEffect(null, Status.UNKILLABLE, INFINITY)
  eventPlayer.expectedHealth = eventPlayer.getHealth()
  eventPlayer.startModifyingVoicelinePitch(0.5 * (sinDeg(getTotalTimeElapsed() * evalOnce(random.uniform(360, 720)))))
  wait()
  eventPlayer.isReady = true

  # [debug]:
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

  smallMessage(hostPlayer, "Server: Create new zombie bots")
  for createDummyI in range(wSettingsMaxZombieBots):
    if not getPlayersInSlot(createDummyI, Team.2):
      createDummy(Hero.TORBJORN, Team.2, createDummyI, random.choice(spawnPointsList))
      wait(0.1)


rule "Create icons for last zombies":
  @Condition roundNumber > 0

  if roundRemainingBots > 0 and LAST_ZOMBIES_ICONS_AMOUNT >= roundRemainingBots:
    lastZombiesList = [player for player in getLivingPlayers(Team.2) if not player.downedStartTime]
    for lastZombiesI in range(len(lastZombiesList)):
      if not lastZombiesList[lastZombiesI].lastZombieIcon:
        createIcon(getPlayers(Team.1), evalOnce(lastZombiesList[lastZombiesI]), Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
        lastZombiesList[lastZombiesI].lastZombieIcon = getLastCreatedEntity()
        lastZombiesIcons[lastZombiesI] = getLastCreatedEntity() # Save here the IDs of created icons, so that you can delete icons in case Dummy bots will be deleted.

  wait(3)
  loop()

rule "fix broken immortal bots and mark last bots":
  @Event eachPlayer
  @Team 2
  @Condition roundNumber > 0

  if (
    eventPlayer.downedStartTime or
    not eventPlayer.isAlive() or
    eventPlayer.getHealth() > BOT_FAKE_DIE_HP_THRESHOLD or
    not eventPlayer.isReady
  ):
    goto lbl_0

  waitUntil(eventPlayer.downedStartTime == true, 0.5)
  if not eventPlayer.downedStartTime:
    eventPlayer.clearStatusEffect(Status.UNKILLABLE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
    smallMessage(hostPlayer, "Server: Immortal zombie found. Trying not to neutralize immortality")

  lbl_0:
  wait(3, Wait.ABORT_WHEN_FALSE)
  loop()

rule "[Bot fake death] Trigger bot respawn after round start":
  @Event eachPlayer
  @Team 2
  @Condition roundRemainingBots > 0

  if eventPlayer.downedStartTime:
    botFakeDeathRespawn()

# rule "[debug] lastKillTime":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0

#   debug(floor((getTotalTimeElapsed() - floor(getTotalTimeElapsed())) * 100) % (wSettingsMaxZombieBots) * 2)
