#!mainFile "main.opy"

globalvar vipPlayers = ["snky"] # List of players who received special privileges



rule "Player joined setup": 
  @Event playerJoined
  @Team 1

  eventPlayer.setRespawnTime(INFINITY)

  eventPlayer.healthBoostPercent = 100
  eventPlayer.damageBoostPercent = 100
  eventPlayer.healingBoostPercent = 100
  eventPlayer.money = wSettingsStartMoney 
  eventPlayer.purchasedHeroes = [Hero.DVA]
  eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY

  # Change character for vip players
  # if "{0}".format(eventPlayer) in vipPlayers == true:
  #   wait(2)
  #   eventPlayer.startForcingHero(Hero.SOMBRA)
  # else:

  if roundNumber >= 15:
    waitUntil(eventPlayer.hasSpawned(), INFINITY)
    eventPlayer.money += 15000
    eventPlayer.healthBoostPercent += 100
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    wait(0.064)
    heal(eventPlayer, null, INFINITY)
    eventPlayer.setDamageReceived(25)
    wait(10)
    smallMessage(eventPlayer, "Welcome! A Late Joiner Buff has been activated!")
    wait(5)
    smallMessage(eventPlayer, "Bonus Points, HP & Temp Damage Reduction (180s)")
    wait(180)
    eventPlayer.setDamageReceived(85)
    smallMessage(eventPlayer, "Your damage reduction buff has now ended. Good luck!")

  # Late joiner catchup [25]
  if roundNumber >= 25:
    eventPlayer.money += 30000
    eventPlayer.healthBoostPercent += 200
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)

  # "Late joiner catchup [50]"
  if roundNumber >= 50:
    eventPlayer.money += 50000
    eventPlayer.healthBoostPercent += 300
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)

  eventPlayer.startForcingHero(Hero.DVA)
  eventPlayer.respawn()
  eventPlayer.teleport(vect(-27.412, 8.678, -12.564))

rule "Player spawned setup":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.hasSpawned()

  if teamShields:
    eventPlayer.addHealthPool(Health.SHIELDS, teamShields, true)
  if teamArmor:
    eventPlayer.addHealthPool(Health.ARMOR, teamArmor, true)

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
