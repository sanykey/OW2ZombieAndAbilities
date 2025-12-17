#!mainFile "main.opy"

# save information about bots being pushed to account for damage when falling down
macro Player.setCrowdControlAttack(self, attacker0, isVanilaKnockback=false, duration=LAST_CC_ATTACK_DURATION):
  self.lastCcAttacker = attacker0
  self.lastCcAttackTime = duration + getTotalTimeElapsed()
  self.lastCcWasInAir = self.isInAir()
  self.lastCcVanilaKnockback = isVanilaKnockback
  self.money = 0 # Zero the parameter that makes the bot jump when it gets stuck in obstacles

rule "player Dealt Knockback":
  @Event playerDealtKnockback
  @Team 1

  # Some attacks can hurt the attackers themselves, such as Sigma's accretion attacks
  if victim.getTeam() == Team.1:
    return

  victim.setCrowdControlAttack(attacker, true)
  
  # [Sombra] melee from invisible - steal money and stun:
  if (
    eventPlayer.getHero() == Hero.SOMBRA and
    eventPlayer.isInvisible and
    eventAbility == Button.MELEE
  ):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    damage(victim, eventPlayer, 40)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.PURPLE, victim, 0.25)
    eventPlayer.money += 50

  # [Reinhardt] Shield bash:
  if eventPlayer.getHero() == Hero.REINHARDT and eventPlayer.isFiringSecondaryFire():
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)

  # [Brigitte] Shield bash:
  if eventPlayer.getHero() == Hero.BRIGITTE and eventPlayer.isFiringSecondaryFire():
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)
    getRealPlayersInRadius(victim, 2, Team.2, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.STUNNED, 2)

rule "Zombie took damage":
  @Event playerTookDamage
  @Team 2

  # [Cassydy] stun effect for flashbang:
  if (attacker.getHero() == Hero.CASSIDY and eventAbility == Button.ABILITY_2):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
  # [Doomfist] Ult Knock Down:
  elif (attacker.getHero() == Hero.DOOMFIST):
    if eventAbility == Button.ULTIMATE:
      victim.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 3)
    elif eventAbility == Button.ABILITY_1:
      victim.setSpeedState(50, 3)
  # [Widowmaker]:
  elif attacker.getHero() == Hero.WIDOWMAKER: 
    # widow mines slow and reveal enemy
    if eventAbility == Button.ABILITY_2: 
      victim.setRevealed()
      victim.setSpeedState(30, 1)
    # todo: fix:
    # Reveal enemies when scoped hit
    elif eventAbility == Button.PRIMARY_FIRE and eventAbility == Button.SECONDARY_FIRE: 
      victim.setRevealed()

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
  @Team 1
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
  # smallMessage(eventPlayer, "<TX C000000000039DD> +${0}".format(eventPlayer.temp0))
  eventPlayer.healingTracker = 0

rule "Self Healing money":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.selfHealingTracker >= eventPlayer.healingTrackerThreshold

  eventPlayer.temp0 = eventPlayer.selfHealingTracker * MONEY_FOR_SELF_HEALING
  eventPlayer.money += eventPlayer.temp0
  # smallMessage(eventPlayer, "<TX C000000000039DD> +${0}".format(eventPlayer.temp0))
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

rule "Zombie elimination money and ult charge":
  @Event playerEarnedElimination
  @Team 1

  eventPlayer.temp0 = (
    MONEY_FOR_ELIMINATIONS +
    (MONEY_FOR_CRITICAL_FINAL_BLOW if eventWasCriticalHit else 0) +
    (MONEY_FOR_MELEE_FINAL_BLOW if eventAbility == Button.MELEE else 0) +
    (MONEY_FOR_HACKED_ELIMS if victim.isHacked else 0)
  )
  if victim.isHacked:
    eventPlayer.currentHackedElims += 1

  if eventWasCriticalHit:
    eventPlayer.currentCriticalFinalBlows += 1
  elif eventAbility == Button.MELEE:
    eventPlayer.currentMeleeFinalBlows += 1

  # smallMessage(eventPlayer, "<TX C00000000021569> +${}".format(eventPlayer.temp0))
  eventPlayer.money += eventPlayer.temp0

  
  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + ULT_CHARGE_FOR_KILL)

playervar currentOffensiveAssistsStat

rule "Offensive assists money and ult charge":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS) > eventPlayer.currentOffensiveAssistsStat

  eventPlayer.temp0 = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS) - eventPlayer.currentOffensiveAssistsStat
  eventPlayer.currentOffensiveAssistsStat = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS)

  eventPlayer.temp1 = MONEY_FOR_OFFENSIVE_ASSISTS * eventPlayer.temp0
  # smallMessage(eventPlayer, "Assist: +${}".format(eventPlayer.temp1))
  eventPlayer.money += eventPlayer.temp1

  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + (ULT_CHARGE_FOR_KILL * eventPlayer.temp0))

playervar currentDefensiveAssistsStat

rule "Defensive assists money and ult charge":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) > eventPlayer.currentDefensiveAssistsStat

  eventPlayer.temp0 = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) - eventPlayer.currentDefensiveAssistsStat
  eventPlayer.currentDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS)

  eventPlayer.temp1 = MONEY_FOR_DEFENSIVE_ASSISTS * eventPlayer.temp0
  # smallMessage(eventPlayer, "Assist: +${}".format(eventPlayer.temp1))
  eventPlayer.money += eventPlayer.temp1

  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + (ULT_CHARGE_FOR_KILL * eventPlayer.temp0))
