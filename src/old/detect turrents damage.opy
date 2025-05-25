#!define WAIT_TURRENT_DAMAGE_OWNERS 0.45

# [Bot fake death]:
# There is a bug in workshop: damage from turrets and Bob is not detected. To get around this problem, we compare the damage received 
#   by zombies and current health, and the damage dealt by players with the damage statistics. If there are discrepancies at the same time,
#   then fix the damage from turrets. This is not a very accurate method, but it is acceptable.
# This functionality was required because the “Bot fake death” mechanic was introduced, where zombies don't die and it is impossible to
#   track “fake death” from turrets damage
rule "Detect zombie damage took from turrets and bob":
  @Condition getPlayersOnHero(Hero.SYMMETRA, Team.1) or getPlayersOnHero(Hero.TORBJORN, Team.1) or getPlayersOnHero(Hero.ASHE, Team.1)

  turretsVictimZombies = [player for player in getLivingPlayers(Team.2) if (
    player.expectedHealth and
    player.expectedHealth - player.getHealth() > 3
  )]

  if not turretsVictimZombies:
    goto lbl_1

  # “player.getStatistic(Stat.DAMAGE_DEALT)” in 'turretsDamageOwners' is updated with a delay, so it has to be waited for:
  waitUntil(len(turretsDamageOwners) > 0, WAIT_TURRENT_DAMAGE_OWNERS) 

  for turretsI in range(len(turretsVictimZombies)):
    turretsVictimZombies[turretsI].expectedHealth = floor(turretsVictimZombies[turretsI].getHealth())

    if turretsDamageOwners:
      for turretsJ in range(len(turretsDamageOwners)):
        turretsVictimZombies.turretDamageTimeToSlot[turretsDamageOwners[turretsJ].getSlot()] = 5 + getTotalTimeElapsed()

  lbl_1:
  wait(0.1)
  if RULE_CONDITION:
    loop()

# [Bot fake death] 
rule "Detect players damage deal from turrets and bob":
  @Condition getPlayersOnHero(Hero.SYMMETRA, Team.1) or getPlayersOnHero(Hero.TORBJORN, Team.1) or getPlayersOnHero(Hero.ASHE, Team.1)

  turretsDamageOwners = [player for player in getPlayers(Team.1) if (
    player.hasSpawned() and (
      player.getHero() == Hero.SYMMETRA or
      player.getHero() == Hero.TORBJORN or
      player.getHero() == Hero.ASHE
    ) and
    (player.getStatistic(Stat.DAMAGE_DEALT) - player.lastDamageDealtAmount > 5) 
  )]

  if turretsDamageOwners:
    for turretsK in range(len(turretsDamageOwners)):
      if turretsDamageOwners[turretsK].lastDamageDealtTime < getTotalTimeElapsed():
        turretsDamageOwners[turretsK].lastDamageDealtAmount = floor(turretsDamageOwners[turretsK].getStatistic(Stat.DAMAGE_DEALT))

  lbl_0:
  wait(0.1)
  if RULE_CONDITION:
    loop()


# rule "[debug] detect turrets damage (team1)":
#   @Event eachPlayer
#   @Condition eventPlayer == hostPlayer

#   debug(eventPlayer.lastDamageDealtAmount)
#   debug(eventPlayer.getStatistic(Stat.DAMAGE_DEALT))
  
#   debug(turretsVictimZombies)
#   debug(turretsDamageOwners)

# rule "[debug] detect turrets damage (team2)":
#   @Event eachPlayer
#   @Team 2
#   @Slot 0
#   debug(eventPlayer.damageAssitsToSlot)
#   debug(eventPlayer.downedStartTime)
  
# rule "[debug] detect turrets damage (team2)":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0
#   debug(eventPlayer.defensiveAssistsStat)
#   debug(eventPlayer.damageBlockedStat)
#   debug(eventPlayer.damageTakenStat)
#   debug(eventPlayer.damageDealtStat)
#   debug(eventPlayer.deathsStat)