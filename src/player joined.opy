#!mainFile "main.opy"

# globalvar vipPlayers = ["snky"] # List of players who received special privileges
globalvar devPlayers = ["snky"] # List of players who received develop privileges

rule "Player joined setup": 
  @Event playerJoined
  @Team 1

  eventPlayer.setRespawnTime(INFINITY)
  eventPlayer.healthBoostPercent = 100 + (5 * roundNumber)
  eventPlayer.damageBoostPercent = 100 + (3 * roundNumber)
  eventPlayer.healingBoostPercent = 100 + (3 * roundNumber)
  eventPlayer.money = wSettingsStartMoney + (2500 * roundNumber)
  eventPlayer.purchasedHeroes = [Hero.DVA]
  
  # grant develop privileges
  if "{0}".format(eventPlayer) in devPlayers:
    eventPlayer.developer = true
    bigMessage(getAllPlayers(), "Mod developer [{}] joined the game".format(eventPlayer))

  eventPlayer.startForcingHero(Hero.DVA)
  eventPlayer.respawn()
  eventPlayer.teleport(vect(-27.412, 8.678, -12.564))

rule "Player spawned setup":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.hasSpawned()

  eventPlayer.addHealthPool(Health.SHIELDS, teamShields, true)
  eventPlayer.boostStats[PV_TEAM_SHIELDS_POOL] = getLastCreatedHealthPool()
  wait()
  eventPlayer.addHealthPool(Health.ARMOR, teamArmor, true)
  eventPlayer.boostStats[PV_TEAM_ARMOR_POOL] = getLastCreatedHealthPool()

  if not eventPlayer.isReady:
    wait(1.5)
    eventPlayer.setFacing(vect(0.93, 0.05, -0.35), Relativity.TO_WORLD)

rule "Show game tips in start":
  @Event eachPlayer
  @Condition not eventPlayer.isReady
  waitUntil(distance(eventPlayer, vect(-27.33, -1.94, -12.68)) < 6)

  eventPlayer.isHeroDescriptionOpened = true

  while not eventPlayer.isReady: 
    if distance(eventPlayer, vect(-27.33, -1.94, -12.68)) > 6:
      eventPlayer.isHeroDescriptionOpened = false
      eventPlayer.isReady = true
    wait(1)

rule "Player left Match, destroy effects, texts and hud":
  @Event playerLeft
  destroyHudText(eventPlayer.effectsIds[HI.PLAYER_STATUS])
  destroyEffect(eventPlayer.effectsIds[HI.REVIVE_EFFECT])
  destroyIcon(eventPlayer.effectsIds[HI.REVIVE_ICON])