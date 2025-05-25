#!mainFile "../main.opy"

def botWidowmakerRespawn():
  @Name "[Team2 Widowmaker] respawn"
  createBeam(
    null if eventPlayer.hasBadStatus else getAllPlayers(),
    Beam.TORBJORN_TURRET_SIGHT,
    eventPlayer.getEyePosition(),
    updateEveryFrame(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 999, null, eventPlayer, false).getHitPosition()),
    Color.RED,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.abilPos1 = getLastCreatedEntity()
  eventPlayer.stopForcingThrottle()
  eventPlayer.startScalingSize(1, false)
  eventPlayer.startForcingButton(Button.SECONDARY_FIRE)

def botTeleportToSpawn():
  zombieToResp.teleport(random.choice(spawnPointsList))

def postRespawnTeleportFixes():
  if zombieToResp.isDead():
    zombieToResp.respawn()
    zombieToResp.setStatusEffect(null, Status.UNKILLABLE, INFINITY)

  heal(zombieToResp, null, INFINITY)
  wait()
  zombieToResp.expectedHealth = zombieToResp.getHealth()
  zombieToResp.clearStatusEffect(Status.KNOCKED_DOWN)
  zombieToResp.clearStatusEffect(Status.PHASED_OUT)
  zombieToResp.downedStartTime = false

def botPrepareToRespawn():
  @Name "[Bot fake death] respawn"
  zombieToResp.isZombieReadyToRespawn = false

  if zombieToResp.getHero() == Hero.WIDOWMAKER and (botWidowmakerRespawnTime > getTotalTimeElapsed() or not botSniperPositionsPlayerisInLoS):
    zombieToResp.startForcingHero(Hero.TORBJORN)
  # elif zombieToResp.getHero() == Hero.ECHO and botEchoRespawnTime > getTotalTimeElapsed():
  #   zombieToResp.startForcingHero(Hero.TORBJORN)

  # [Team2 Roadhog] create bot:
  if roundNumber > 4 and len(getPlayersOnHero(Hero.ROADHOG)) < 1:
    zombieToResp.startForcingHero(Hero.ROADHOG)
  # [Team2 Mauga] create bot:
  elif roundNumber > 2 and len(getPlayersOnHero(Hero.MAUGA)) < 1:
    zombieToResp.startForcingHero(Hero.MAUGA)
  # [Team2 Widowmaker] respawn:
  # elif (
  #   roundNumber > 2 and
  #   botSniperPositionsPlayerisInLoS and
  #   not getPlayersOnHero(Hero.WIDOWMAKER, Team.2) and 
  #   botWidowmakerRespawnTime < getTotalTimeElapsed() and
  #   zombieToResp.getHero() != Hero.ROADHOG and
  #   zombieToResp.getHero() != Hero.MAUGA
  # ):
  #   zombieToResp.startForcingHero(Hero.WIDOWMAKER)
  #   botWidowmakerRespawn()
  #   wait()
  #   botWidowmakerChangePositon()
  #   postRespawnTeleportFixes()
  #   return

  botTeleportToSpawn()
  wait(0.1)
  postRespawnTeleportFixes()

  # [Team2 Echo] respawn:
  # elif ( 
  #   roundNumber > 4 and
  #   not getPlayersOnHero(Hero.ECHO, Team.2) and
  #   botEchoRespawnTime < getTotalTimeElapsed() and
  #   zombieToResp.getHero() != Hero.ROADHOG and 
  #   zombieToResp.getHero() != Hero.MAUGA and
  #   [player for player in botSniperPositions if isInLoS(player, getPlayers(Team.1))]
  # ):
  #   zombieToResp.startForcingHero(Hero.ECHO)


  # reset negative statuses and dot damage:
  # wait()
  # if zombieToResp.getHealth() < 2:
  #   smallMessage(getAllPlayers(), "has dot damage?")
  #   zombieToResp.temp0 = zombieToResp.getHero()
  #   zombieToResp.startForcingHero(Hero.MOIRA)
  #   wait()
  #   zombieToResp.startForcingHero(zombieToResp.temp0)
  #   zombieToResp.damageAssitsToSlot = []



rule "[Bot fake death] Respawn bots":
  @Condition isGameStarted == true

  # Create bots
  if getNumberOfPlayers(Team.2) < wSettingsMaxZombieBots and not isBotsDisabled:
    smallMessage(hostPlayer, "[Server]: Create zombie bots")
    for createDummyI in range(wSettingsMaxZombieBots):
      if not getPlayersInSlot(createDummyI, Team.2):
        createDummy(Hero.TORBJORN, Team.2, createDummyI, random.choice(spawnPointsList))
        wait(0.4)


  zombieSlotsToRespawn = (
    (roundRemainingBots if roundRemainingBots < wSettingsMaxZombieBots else wSettingsMaxZombieBots) -
    len([player for player in getLivingPlayers(Team.2) if not player.downedStartTime])
  )

  if zombieSlotsToRespawn < 1:
    goto lbl_0

  zombieRespawnList = [player for player in getLivingPlayers(Team.2) if player.isZombieReadyToRespawn]
  zombieRespawnListLen = len(zombieRespawnList) 
  for zombieRespI in range(zombieRespawnListLen if zombieRespawnListLen <= zombieSlotsToRespawn else zombieSlotsToRespawn):
    zombieToResp = zombieRespawnList[zombieRespI]
    botPrepareToRespawn()
    wait(0.7)

  lbl_0:
  wait(0.5, Wait.ABORT_WHEN_FALSE)
  loop()