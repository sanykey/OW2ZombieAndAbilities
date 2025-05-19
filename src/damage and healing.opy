#!mainFile "main.opy"

rule "player Dealt Knockback":
  @Event playerDealtKnockback
  @Team 1
  
  # [Sombra] melee from invisible - steal money and stun
  if (
    eventPlayer.getHero() == Hero.SOMBRA and
    eventPlayer.isInvisible and
    eventAbility == Button.MELEE
  ):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    damage(victim, eventPlayer, 40)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.PURPLE, victim, 0.25)
    smallMessage(eventPlayer, "{0} points".format(25 * eventPlayer.H))
    eventPlayer.money += 25 * eventPlayer.H

  # Save last cc damage from player for fall damage
  victim.lastCcAttacker = attacker
  victim.lastCcAttackTime = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  victim.lastCcWasInAir = victim.isInAir()


rule "Zombie took damage":
  @Event playerTookDamage
  @Team 2

  # collect zombie health statistics for damage detection by turrets
  if not victim.expectedHealth:
    victim.expectedHealth = floor(victim.getHealth() - eventDamage)
  else:
    victim.expectedHealth -= floor(eventDamage)

  # collect player damage statistics for damage detection by turrets
  if not attacker.lastDamageDealtAmount:
    attacker.lastDamageDealtAmount = floor(eventPlayer.getStatistic(Stat.DAMAGE_DEALT) + eventDamage)
  else:
    attacker.lastDamageDealtAmount += eventDamage
  attacker.lastDamageDealtTime = getTotalTimeElapsed() + 0.5

  # [Cassydy] stun effect for flashbang
  if (attacker.getHero() == Hero.CASSIDY and eventAbility == Button.ABILITY_2):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)

  victim.damageAssitsToSlot[attacker.getSlot()] = 5 + getTotalTimeElapsed() # save damage stats for money
  # todo: ??
  victim.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed() # for check zombie out of map safety

rule "Player took damage":
  @Event playerTookDamage
  @Team 1

  # [Sombra] invisible off
  if eventPlayer.isInvisible == true:
    eventPlayer.setStatusEffect(null, Status.HACKED, 0.05)
    eventPlayer.isInvisible = false 

  # [Team2 Roadhog] chance to hack player when melee
  if (
    attacker.getHero() == Hero.ROADHOG and
    eventAbility == Button.MELEE and 
    random.randint(1, 100) <= 40
  ):
    eventPlayer.setStatusEffect(null, Status.HACKED, 1.5)

  # [Team2 Mauga] Burning players
  if (
    attacker.getHero() == Hero.MAUGA and
    eventAbility == Button.ABILITY_1
  ):
    eventPlayer.setStatusEffect(null, Status.BURNING, 5)

  eventPlayer.state[SI.LAST_DAMAGE_TIME] = getTotalTimeElapsed()
  wait(15, Wait.RESTART_WHEN_TRUE)
  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()


rule "Player burning":
  @Event eachPlayer
  @Condition eventPlayer.hasStatus(Status.BURNING)

  damage(eventPlayer, getPlayersOnHero(Hero.MAUGA, Team.2), 4)
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  loop()


# code from [Hacked Healthpack/Sombra Healing Detector](https://workshop.codes/EF7H3)
rule "HealthPack with auto heal and speed boost":
  @Event playerReceivedHealing
  @Team 1
  @Condition eventWasHealthPack == true

  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()
  eventPlayer.setMoveSpeed(150)
  wait(5, Wait.ABORT_WHEN_FALSE)
  eventPlayer.setMoveSpeed(100)


rule "Start auto healing overеtime":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.START_AUTO_HEAL_TIME] + AUTO_HEALING_OVERTIME_DURATION > getTotalTimeElapsed()

  eventPlayer.startHealingOverTime(eventPlayer, AUTO_HEALING_OVERTIME_DURATION, 20 + (((20 * eventPlayer.healthStat / 100) - 20) / 5))

  waitUntil(
    eventPlayer.state[SI.LAST_DAMAGE_TIME] + 0.1 > getTotalTimeElapsed() or
    eventPlayer.state[SI.START_AUTO_HEAL_TIME] + AUTO_HEALING_OVERTIME_DURATION < getTotalTimeElapsed(),
    INFINITY
  )
  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = false
  eventPlayer.stopAllHealingOverTime()


rule "Healing points":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.HEALING_TRACKER] >= eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] 

  eventPlayer.state[SI.HEALING_RESULT] = floor(eventPlayer.state[SI.HEALING_TRACKER] / HEAL_AMOUNT_FOR_MONEY) * MONEY_FOR_HEALING * eventPlayer.H
  eventPlayer.money += eventPlayer.state[SI.HEALING_RESULT]
  smallMessage(eventPlayer, "<TX C000000000039DD> +${0}".format(eventPlayer.state[SI.HEALING_RESULT]))
  teamScore += eventPlayer.state[SI.HEALING_RESULT]
  eventPlayer.state[SI.HEALING_TRACKER] = 0

rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  
  # healing yourself gives less points
  eventPlayer.state[SI.HEALING_TRACKER] += eventHealing / 3 if healee == eventPlayer else eventHealing



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


# rule "debug detect turrets damage (team1)":
#   @Event eachPlayer
#   @Condition eventPlayer == hostPlayer

#   debug(eventPlayer.lastDamageDealtAmount)
#   debug(eventPlayer.getStatistic(Stat.DAMAGE_DEALT))
  
#   debug(turretsVictimZombies)
#   debug(turretsDamageOwners)

# rule "debug detect turrets damage (team2)":
#   @Event eachPlayer
#   @Team 2
#   @Slot 0
#   debug(eventPlayer.damageAssitsToSlot)
#   debug(eventPlayer.downedStartTime)
  