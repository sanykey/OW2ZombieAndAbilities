#!mainFile "main.opy"

rule "[Sombra] melee from invisible":
  @Event playerDealtKnockback
  @Team 1
  
  # [Sombra] melee from invisible
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

  # [Cassydy] stun effect for flashbang
  if (attacker.getHero() == Hero.CASSIDY and eventAbility == Button.ABILITY_2):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)

  victim.damageAssitsToSlot[attacker.getSlot()] = 5 + getTotalTimeElapsed() # save damage stats for money
  # todo: ??
  victim.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed() # for check zombie out of map safety

rule "Player took damage":
  @Event playerTookDamage
  @Team 1

  # sombra's invisible off
  if eventPlayer.isInvisible == true:
    eventPlayer.setStatusEffect(null, Status.HACKED, 0.05)
    eventPlayer.isInvisible = false 

  # [Team2 Roadhog]
  if (
    attacker.getHero() == Hero.ROADHOG and
    eventAbility == Button.MELEE and 
    random.randint(1, 100) <= 40
  ):
    eventPlayer.setStatusEffect(null, Status.HACKED, 1.5)

  eventPlayer.state[SI.LAST_DAMAGE_TIME] = getTotalTimeElapsed()
  wait(15, Wait.RESTART_WHEN_TRUE)
  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()

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