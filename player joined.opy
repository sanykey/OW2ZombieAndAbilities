#!mainFile "main.opy"

rule "Late Joiner Catchup [15]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 15
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 25000
  eventPlayer.health_stat += 200
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  wait(0.064)
  heal(eventPlayer, null, 99999)
  eventPlayer.setDamageReceived(25)
  wait(10)
  smallMessage(eventPlayer, "Welcome! A Late Joiner Buff has been activated!")
  wait(5)
  smallMessage(eventPlayer, "Bonus Points, HP & Temp Damage Reduction (180s)")
  wait(180)
  eventPlayer.setDamageReceived(85)
  smallMessage(eventPlayer, "Your damage reduction buff has now ended. Good luck!")

rule "Late Joiner Catchup [25]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 25
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 75000
  eventPlayer.health_stat += 500
  eventPlayer.setMaxHealth(eventPlayer.health_stat)


rule "Late Joiner Catchup [50]":
  @Event playerJoined
  @Team 1
  @Condition roundNumber >= 50
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 50000
  eventPlayer.health_stat += 1250
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  wait(1.5)
  heal(eventPlayer, null, 99999)

rule "Team Shields and Armor for Joiner":
  @Event playerJoined
  @Team 1

  eventPlayer.stateArr[stateI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.addHealthPool(Health.SHIELDS, team_shields, true)
  eventPlayer.addHealthPool(Health.ARMOR, team_armor, true)