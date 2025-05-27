#!mainFile "main.opy"

# THRESHOLD
playervar healingTracker
playervar selfHealingTracker

# save information about bots being pushed to account for damage when falling down
macro Player.setCrowdControlAttack(self, attacker0, duration=LAST_CC_ATTACK_DURATION):
  self.lastCcAttacker = attacker0
  self.lastCcAttackTime = duration + getTotalTimeElapsed()
  self.lastCcWasInAir = self.isInAir()


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
    smallMessage(eventPlayer, "{0} points".format(25))
    eventPlayer.money += 25

  victim.setCrowdControlAttack(attacker)

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
    eventPlayer.setStatusEffect(null, Status.BURNING, 10)

  eventPlayer.state[SI.LAST_DAMAGE_TIME] = getTotalTimeElapsed()
  wait(15, Wait.RESTART_WHEN_TRUE)
  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()

# BURNING effect that triggered [Team2 Mauga]
rule "Player burning":
  @Event eachPlayer
  @Condition eventPlayer.hasStatus(Status.BURNING)

  damage(eventPlayer, getPlayersOnHero(Hero.MAUGA, Team.2), 4)

  if eventPlayer.hasStatus(Status.INVINCIBLE) or eventPlayer.hasStatus(Status.PHASED_OUT):
    eventPlayer.clearStatusEffect(Status.BURNING)

  wait(0.2, Wait.ABORT_WHEN_FALSE)
  loop()


# code from [Hacked Healthpack/Sombra Healing Detector](https://workshop.codes/EF7H3)
rule "HealthPack with auto heal and speed boost":
  @Event playerReceivedHealing
  @Team 1
  @Condition eventWasHealthPack == true

  # Clear the BURNING effect that triggered [Team2 Mauga]
  if eventPlayer.hasStatus(Status.BURNING):
    eventPlayer.clearStatusEffect(Status.BURNING)
  wait()

  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed()
  eventPlayer.setMoveSpeed(150)
  wait(5, Wait.ABORT_WHEN_FALSE)
  eventPlayer.setMoveSpeed(100)


rule "Start auto healing overеtime":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.START_AUTO_HEAL_TIME] + AUTO_HEALING_OVERTIME_DURATION > getTotalTimeElapsed()

  eventPlayer.startHealingOverTime(eventPlayer, AUTO_HEALING_OVERTIME_DURATION, 20 + (((20 * eventPlayer.healthBoostPercent / 100) - 20) / 5))

  waitUntil(
    eventPlayer.state[SI.LAST_DAMAGE_TIME] + 0.1 > getTotalTimeElapsed() or
    eventPlayer.state[SI.START_AUTO_HEAL_TIME] + AUTO_HEALING_OVERTIME_DURATION < getTotalTimeElapsed(),
    INFINITY
  )
  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = false
  eventPlayer.stopAllHealingOverTime()


rule "Healing money":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.healingTracker >= eventPlayer.healingTrackerThreshold

  eventPlayer.temp0 = eventPlayer.healingTracker * MONEY_FOR_HEALING
  eventPlayer.money += eventPlayer.temp0
  smallMessage(eventPlayer, "<TX C000000000039DD> +${0}".format(eventPlayer.temp0))
  eventPlayer.healingTracker = 0

rule "Self Healing money":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.selfHealingTracker >= eventPlayer.healingTrackerThreshold

  eventPlayer.temp0 = eventPlayer.selfHealingTracker * MONEY_FOR_SELF_HEALING
  eventPlayer.money += eventPlayer.temp0
  smallMessage(eventPlayer, "<TX C000000000039DD> +${0}".format(eventPlayer.temp0))
  eventPlayer.selfHealingTracker = 0

rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  
  # healing yourself gives less points
  if healee == eventPlayer:
    eventPlayer.selfHealingTracker += eventHealing
    eventPlayer.selfHealingCurrentStat += eventHealing
  else:
    eventPlayer.healingTracker += eventHealing
    eventPlayer.healingCurrentStat += eventHealing