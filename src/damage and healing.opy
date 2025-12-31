#!mainFile "main.opy"

enum SI:
  START_AUTO_HEAL_TIME
  IS_INVISIBLE
  CHANGED_SPEED_TIME
  CHANGED_SPEED_AMOUNT
  CHANGED_SPEED_AMOUNT_PREV
  LOW_GRAVITY_AMOUNT
  LOW_GRAVITY_AMOUNT_PREV
  LOW_GRAVITY_TIME

macro horDirectionTowards(a, b):
  normalize(vect(b.x, 0, b.z) - vect(a.x, 0, a.z))

rule "Chase abilityCD":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.abilityCD
  @SuppressWarnings w_ow2_rule_condition_chase
  
  chaseAtRate(eventPlayer.abilityCD, 0, 1)
  waitUntil(not eventPlayer.abilityCD, INFINITY)
  eventPlayer.abilityCD = false
  stopChasingVariable(eventPlayer.abilityCD)
  wait()
  if ruleCondition:
    loop()


macro Player.pushInFacingDirectionAndUp(self, attacker0, speed):
  self.applyImpulse(
    vect(attacker0.getFacingDirection().x, 0.2679 if attacker0.getFacingDirection().y < 0.2679 else attacker0.getFacingDirection().y, attacker0.getFacingDirection().z),
    speed,
    Relativity.TO_WORLD
  )

macro Player.setRevealed(self, duration=REVEAL_DURATION):
  self.revealed = duration + getTotalTimeElapsed()

rule "Revealed zombies":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.revealed >= getTotalTimeElapsed()
  
  if not eventPlayer.effectsIds[REVEALED_ICON]:
    createInWorldText(
      getAllPlayers(),
      "+",
      eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
      0.6,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
      Color.TEAM_2
    )
    eventPlayer.effectsIds[REVEALED_ICON] = getLastCreatedText()

  waitUntil(eventPlayer.revealed < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)
  eventPlayer.revealed = false
  destroyInWorldText(eventPlayer.effectsIds[REVEALED_ICON])

macro Player.setSpeedState(self, speed = 30, duration = 5):
  self.state[SI.CHANGED_SPEED_TIME] = getTotalTimeElapsed() + duration
  self.state[SI.CHANGED_SPEED_AMOUNT] = speed

rule "Changed player speed state":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] != eventPlayer.state[SI.CHANGED_SPEED_AMOUNT]

  eventPlayer.setMoveSpeed(eventPlayer.state[SI.CHANGED_SPEED_AMOUNT])
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = eventPlayer.state[SI.CHANGED_SPEED_AMOUNT]
  waitUntil(ruleCondition or eventPlayer.state[SI.CHANGED_SPEED_TIME] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)
  eventPlayer.setMoveSpeed(zomSpeedPct if eventPlayer.getTeam() == Team.2 else 100)
  eventPlayer.state[SI.CHANGED_SPEED_TIME] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT] = false

macro Player.setGravityState(self, gravity = 30, duration = 5):
  self.state[SI.LOW_GRAVITY_AMOUNT_PREV] = self.state[SI.LOW_GRAVITY_AMOUNT]
  self.state[SI.LOW_GRAVITY_AMOUNT] = gravity
  self.state[SI.LOW_GRAVITY_TIME] = getTotalTimeElapsed() + duration

rule "Changed player gravitation":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.LOW_GRAVITY_AMOUNT] != eventPlayer.state[SI.LOW_GRAVITY_AMOUNT_PREV]

  eventPlayer.setGravity(eventPlayer.state[SI.LOW_GRAVITY_AMOUNT])
  eventPlayer.state[SI.LOW_GRAVITY_AMOUNT_PREV] = eventPlayer.state[SI.LOW_GRAVITY_AMOUNT]
  waitUntil(ruleCondition or eventPlayer.state[SI.LOW_GRAVITY_TIME] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)
  eventPlayer.setGravity(100)
  eventPlayer.state[SI.LOW_GRAVITY_TIME] = false
  eventPlayer.state[SI.LOW_GRAVITY_AMOUNT] = false
  eventPlayer.state[SI.LOW_GRAVITY_AMOUNT_PREV] = false

# save information about bots being pushed to account for damage when falling down
macro Player.setCrowdControlAttack(self, attacker0, isVanilaKnockback=false, duration=LAST_CC_ATTACK_DURATION):
  self.lastCcAttacker = attacker0
  self.lastCcAttackTime = duration + getTotalTimeElapsed()
  self.lastCcWasInAir = self.isInAir()
  self.lastCcVanilaKnockback = isVanilaKnockback
  self.money = 0 # Zero the parameter that makes the bot jump when it gets stuck in obstacles

macro Player.resetCrowdControlAttack(self):
  self.lastCcAttacker = false
  self.lastCcAttackTime = false
  self.lastCcWasInAir = false

rule "player Dealt Knockback":
  @Event playerDealtKnockback
  @Team 1

  # Some attacks can hurt the attackers themselves, such as Sigma's accretion attacks
  if victim.getTeam() == Team.1:
    return

  victim.setCrowdControlAttack(attacker, true)
  
  # [Sombra] Melee from invisible - additional damage, steal money and stun:
  if (
    eventPlayer.getHero() == Hero.SOMBRA and
    eventPlayer.isInvisible and
    eventAbility == Button.MELEE
  ):
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    damage(victim, eventPlayer, 40)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.PURPLE, victim, 0.25)
    eventPlayer.earnMoney(50)

  # [Reinhardt] Shield bash:
  if eventPlayer.getHero() == Hero.REINHARDT and eventPlayer.isFiringSecondaryFire():
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)

  # [Brigitte] Shield bash:
  if eventPlayer.getHero() == Hero.BRIGITTE and eventPlayer.isFiringSecondaryFire():
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)
    getRealPlayersInRadius(victim, 2, Team.2, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.STUNNED, 2)


rule "Player deal damage":
  @Event playerDealtDamage
  @Team 1

  # [Doomfist] Ultimate knock down enemies:
  if (attacker.getHero() == Hero.DOOMFIST):
    if eventAbility == Button.ULTIMATE:
      victim.setStatusEffect(attacker, Status.KNOCKED_DOWN, 3)
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

  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed() + (HEALER_AUTO_HEAL_DELAY if eventPlayer.heroType == HeroType.SUPPORT else AUTO_HEAL_DELAY)
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

rule "HealthPack with auto heal and speed boost":
  @Event playerReceivedHealing
  @Team 1
  @Condition eventWasHealthPack

  # Clear the BURNING effect that triggered [Team2 Mauga]
  if eventPlayer.hasStatus(Status.BURNING):
    eventPlayer.clearStatusEffect(Status.BURNING)
  wait()

  eventPlayer.state[SI.START_AUTO_HEAL_TIME] = getTotalTimeElapsed() + 0.3
  eventPlayer.setSpeedState(150, 5)

rule "Start auto healing overеtime":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[SI.START_AUTO_HEAL_TIME] > getTotalTimeElapsed()

  waitUntil(not ruleCondition, INFINITY)

  eventPlayer.startHealingOverTime(eventPlayer, AUTO_HEALING_OVERTIME_DURATION, 20 + (((20 * eventPlayer.healthBoostPercent / 100) - 20) / 5))

  waitUntil(ruleCondition, AUTO_HEALING_OVERTIME_DURATION)
  eventPlayer.stopAllHealingOverTime()
  if ruleCondition:
    loop()

rule "Healing amount tracker":
  @Event playerDealtHealing
  @Team 1
  
  # healing yourself gives less points
  if healee == eventPlayer:
    eventPlayer.addStat(RoundStats.SELF_HEALING, eventHealing)
  else:
    eventPlayer.addStat(RoundStats.HEALING, eventHealing)
    # Supports trigger auto-heal:
    # if healee.heroType == HeroType.SUPPORT and eventPlayer.state[SI.START_AUTO_HEAL_TIME] > getTotalTimeElapsed() + 3:
    #   eventPlayer.state[SI.START_AUTO_HEAL_TIME] = 3

rule "Zombie elimination money and ult charge":
  @Event playerEarnedElimination
  @Team 1
  if victim.isHacked:
    eventPlayer.addStat(RoundStats.HACKED_ELIMS, true)
  if eventWasCriticalHit:
    eventPlayer.addStat(RoundStats.CRITICAL_FINAL_BLOW, true)
  elif eventAbility == Button.MELEE:
    eventPlayer.addStat(RoundStats.MELEE_FINAL_BLOW, true)
  
  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + ULT_CHARGE_FOR_KILL)

playervar currentOffensiveAssistsStat
rule "Offensive assists money and ult charge":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS) > eventPlayer.currentOffensiveAssistsStat

  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(
      eventPlayer.getUltCharge() + (ULT_CHARGE_FOR_KILL * (eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS) - eventPlayer.currentOffensiveAssistsStat))
    )

  eventPlayer.currentOffensiveAssistsStat = eventPlayer.getStatistic(Stat.OFFENSIVE_ASSISTS)

playervar currentDefensiveAssistsStat
rule "Defensive assists money and ult charge":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) > eventPlayer.currentDefensiveAssistsStat

  if not eventPlayer.isUsingUltimate():
    eventPlayer.setUltCharge(
      eventPlayer.getUltCharge() + (ULT_CHARGE_FOR_KILL * (eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS) - eventPlayer.currentDefensiveAssistsStat))
    )

  eventPlayer.currentDefensiveAssistsStat = eventPlayer.getStatistic(Stat.DEFENSIVE_ASSISTS)
