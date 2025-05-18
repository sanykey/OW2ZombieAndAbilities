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
  victim.state[SI.LAST_CC_ATTACKER] = attacker
  victim.state[SI.LAST_CC_ATTACK_TIME] = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  victim.state[SI.LAST_CC_WAS_IN_AIR] = victim.isInAir()


rule "Zombie took damage":
  @Event playerTookDamage
  @Team 2

  if not victim.expectedHealth:
    victim.expectedHealth = floor(victim.getHealth() - eventDamage)
  else:
    victim.expectedHealth -= floor(eventDamage)

  if not attacker.lastDamageDealtAmount:
    attacker.lastDamageDealtAmount = floor(eventPlayer.getStatistic(Stat.DAMAGE_DEALT) + eventDamage)
  else:
    attacker.lastDamageDealtAmount += eventDamage

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
rule "HealthPack":
  @Event playerReceivedHealing
  @Team 1
  @Condition eventWasHealthPack == true

  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()
  eventPlayer.setMoveSpeed(150)
  wait(5, Wait.ABORT_WHEN_FALSE)
  eventPlayer.setMoveSpeed(100)


rule "Start auto healing overеime":
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


# def clearTurretsDamagersList():
#   @Name "Clear turrets damagers list"
#   wait(0.2)
#   if eventPlayer.list:
#     for eventPlayer.temp0 in range(len(eventPlayer.list)):
#       eventPlayer.list[eventPlayer.temp0].lastDamageDealtAmount = floor(eventPlayer.list[eventPlayer.temp0].getStatistic(Stat.DAMAGE_DEALT))

#   eventPlayer.list = false


rule "Calculate zombie damage took from turrets and bob":
  turretsVictimZombies = [player for player in getLivingPlayers(Team.2) if (
    player.expectedHealth and
    player.expectedHealth - player.getHealth() > 3
  )]

  if not turretsVictimZombies:
    goto lbl_0

  turretsDamageOwners = [player for player in getPlayers(Team.1) if (
    player.hasSpawned() and (
      player.getHero() == Hero.SYMMETRA or
      player.getHero() == Hero.TORBJORN or
      player.getHero() == Hero.ASHE
    ) and
    (player.getStatistic(Stat.DAMAGE_DEALT) - player.lastDamageDealtAmount > 5) 
  )]

  for turretsI in range(len(turretsVictimZombies)):
    turretsVictimZombies[turretsI].expectedHealth = floor(turretsVictimZombies[turretsI].getHealth())

    if turretsDamageOwners:
      for turretsJ in range(len(turretsDamageOwners)):
        turretsVictimZombies.damageAssitsToSlot[turretsDamageOwners[turretsJ].getSlot()] = 5 + getTotalTimeElapsed()
        
  if turretsDamageOwners:
    for turretsI in range(len(turretsDamageOwners)):
      turretsDamageOwners[turretsI].lastDamageDealtAmount = floor(turretsDamageOwners[turretsI].getStatistic(Stat.DAMAGE_DEALT))

  lbl_0:
  wait(0.05)
  loop()


  # if (
  #   eventPlayer.expectedHealth and
  #   eventPlayer.expectedHealth - eventPlayer.getHealth() > 3
  # ):
  #   eventPlayer.list = [player for player in getLivingPlayers(Team.1) if (
  #     player.hasSpawned() and (
  #       player.getHero() == Hero.SYMMETRA or
  #       player.getHero() == Hero.TORBJORN or
  #       player.getHero() == Hero.ASHE
  #     ) and
  #     (player.getStatistic(Stat.DAMAGE_DEALT) - player.lastDamageDealtAmount > 5) 
  #   )]
  #   # smallMessage(
  #   #   getAllPlayers(), 
  #   #   "Turret? expectedHealth: {}, currentHP: {}".format(
  #   #     evalOnce(eventPlayer.expectedHealth), evalOnce(eventPlayer.getHealth())
  #   #   )
  #   # )
  #   eventPlayer.expectedHealth = floor(eventPlayer.getHealth())

  #   if eventPlayer.list:
  #     for eventPlayer.temp0 in range(len(eventPlayer.list)):
  #       eventPlayer.list[eventPlayer.temp0].lastDamageDealtAmount = floor(eventPlayer.list[eventPlayer.temp0].getStatistic(Stat.DAMAGE_DEALT))

  #     smallMessage(
  #       getAllPlayers(), 
  #       "TURRET! {}".format(eventPlayer.list[0])
  #     )


# rule "Calculate damage dealt from turrets":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.getHero() == Hero.SYMMETRA or eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ASHE

  # turretsDamageOwners = [player for player in getLivingPlayers(Team.1) if (
  #   player.hasSpawned() and (
  #     player.getHero() == Hero.SYMMETRA or
  #     player.getHero() == Hero.TORBJORN or
  #     player.getHero() == Hero.ASHE
  #   ) and
  #   (player.getStatistic(Stat.DAMAGE_DEALT) - player.lastDamageDealtAmount > 5) 
  # )]

#   wait(0.05)
#   loop()


  # if (
  #   eventPlayer.lastDamageDealtAmount and
  #   (eventPlayer.getStatistic(Stat.DAMAGE_DEALT) - eventPlayer.lastDamageDealtAmount > 5) 
  # ):
  #   smallMessage(getAllPlayers(), "turret damage! last: {}, cur: {}".format(eventPlayer.lastDamageDealtAmount, eventPlayer.getStatistic(Stat.DAMAGE_DEALT)))
  #   wait()
  #   eventPlayer.lastDamageDealtAmount = floor(eventPlayer.getStatistic(Stat.DAMAGE_DEALT))

  # wait(0.05)
  # loop()

rule "debug":
  @Event eachPlayer
  @Team 1

  debug(eventPlayer.lastDamageDealtAmount)
  debug(eventPlayer.getStatistic(Stat.DAMAGE_DEALT))
  debug(turretsDamageOwners)
  debug(turretsVictimZombies)

rule "debug":
  @Event eachPlayer
  @Team 2
  debug(eventPlayer.damageAssitsToSlot)