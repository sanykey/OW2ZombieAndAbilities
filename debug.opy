#!mainFile "main.opy"

rule "[debug] Add money and health":
  @Event playerJoined
  @Team 1
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 100000
  eventPlayer.health_stat += 500
  eventPlayer.setMaxHealth(eventPlayer.health_stat)