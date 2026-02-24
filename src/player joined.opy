#!mainFile "main.opy"

# globalvar vipPlayers = ["snky"] # List of players who received special privileges
globalvar devPlayers = ["snky"] # List of players who received develop privileges

rule "Player joined setup": 
  @Event playerJoined
  @Team 1
  @Condition not eventPlayer.isDummy()

  eventPlayer.setRespawnTime(PLAYER_RESPAWN_TIME)
  eventPlayer.healthBoostPercent = 100 + (5 * roundNumber)
  eventPlayer.damageBoostPercent = 100 + (3 * roundNumber)
  eventPlayer.healingBoostPercent = 100 + (3 * roundNumber)

  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
  eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)

  eventPlayer.earnMoney(
    wSettingsStartMoney + (2500 * roundNumber)
    + ((eventPlayer.damageBoostPercent - 100) / DAMAGE_UPGRADE_AMOUNT * UPGRADE_PRICE)
    + ((eventPlayer.healthBoostPercent - 100) / HEALTH_UPGRADE_AMOUNT * UPGRADE_PRICE)
    + ((eventPlayer.healingBoostPercent - 100) / HEALING_UPGRADE_AMOUNT * UPGRADE_PRICE)
  )
  eventPlayer.purchasedHeroes = [Hero.DVA]
  
  # grant develop privileges
  if "{0}".format(eventPlayer) in devPlayers:
    eventPlayer.developer = true
    bigMessage(getAllPlayers(), "Mod developer [{}] joined the game".format(eventPlayer))
    # eventPlayer.startScalingSize(0.7, false)

  eventPlayer.startForcingHero(Hero.DVA)
  eventPlayer.respawn()
  if not eventPlayer.isDummy():
    eventPlayer.teleport(vect(-27.412, 8.678, -12.564))

# rule "Player joined zombie team": 
#   @Event playerJoined
#   @Team 2
#   eventPlayer.startForcingHero(Hero.TORBJORN)
#   eventPlayer.isHeroDescriptionOpened = false

rule "Player spawned setup":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.hasSpawned()
  @Condition not eventPlayer.isDummy() or (eventPlayer.isDummy() and eventPlayer.getHero() == Hero.ORISA)

  eventPlayer.addHealthPool(Health.ARMOR, teamArmor, true)
  eventPlayer.boostStats[PV_TEAM_ARMOR_POOL] = getLastCreatedHealthPool()

  SetHeroTypeSub()
  UpdateCombatantsSub()

  if not eventPlayer.isReady__isBotRespawning:
    wait(1.5)
    eventPlayer.setFacing(vect(0.93, 0.05, -0.35), Relativity.TO_WORLD)

rule "Show game tips in start":
  @Event eachPlayer
  @Team 1 
  @Condition not eventPlayer.isReady__isBotRespawning
  @Condition not eventPlayer.isDummy()

  while not eventPlayer.isReady__isBotRespawning: 
    if distance(eventPlayer, vect(-27.33, -1.94, -12.68)) > 6:
      eventPlayer.isReady__isBotRespawning = true
    wait(1)

rule "Player left Match, destroy effects, texts and hud":
  @Event playerLeft
  @Team 1
  @Condition not eventPlayer.isDummy() or (eventPlayer.isDummy() and eventPlayer.getHero() == Hero.ORISA)
  UpdateCombatantsSub()
  # DetachP2PSub()
  destroyHudText(eventPlayer.effectsIds[PLAYER_STATUS_HUD])
  destroyEffect(eventPlayer.effectsIds[REVIVE_CIRCLE_EFFECT])
  destroyInWorldText(eventPlayer.effectsIds[REVIVE_TEXT])