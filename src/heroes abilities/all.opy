#!mainFile "../main.opy"

macro horDirectionTowards(a, b):
  normalize(vect(b.x, 0, b.z) - vect(a.x, 0, a.z))

macro Player.pushInFacingDirectionAndUp(self, attacker0, speed):
  self.applyImpulse(
    vect(attacker0.getFacingDirection().x, 0.2679 if attacker0.getFacingDirection().y < 0.2679 else attacker0.getFacingDirection().y, attacker0.getFacingDirection().z),
    speed,
    Relativity.TO_WORLD
  )

rule "[Echo - Freeze Beam]":
  @Event playerDealtDamage
  @Team 1
  @Hero echo
  @Condition eventAbility == Button.ABILITY_2
  @Condition attacker != victim
  
  getPlayersInRadius(victim, 5, Team.2).setStatusEffect(eventPlayer, Status.FROZEN, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, victim, 5)
  wait(2.1)



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
  self.state[SI.CHANGED_SPEED_AMOUNT_PREV] = self.state[SI.CHANGED_SPEED_AMOUNT]
  self.state[SI.CHANGED_SPEED_TIME] = getTotalTimeElapsed() + duration
  self.state[SI.CHANGED_SPEED_AMOUNT] = speed

rule "Changed player speed state":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.CHANGED_SPEED_TIME] > getTotalTimeElapsed()
  @Condition eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] != eventPlayer.state[SI.CHANGED_SPEED_AMOUNT]

  eventPlayer.setMoveSpeed(eventPlayer.state[SI.CHANGED_SPEED_AMOUNT])
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = eventPlayer.state[SI.CHANGED_SPEED_TIME]

  waitUntil(eventPlayer.state[SI.CHANGED_SPEED_TIME] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)

  eventPlayer.setMoveSpeed(100)

  eventPlayer.state[SI.CHANGED_SPEED_TIME] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT_PREV] = false
  eventPlayer.state[SI.CHANGED_SPEED_AMOUNT] = false


rule "Low gravitation for player":
  @Event eachPlayer
  @Condition eventPlayer.state[SI.LOW_GRAVITY] > getTotalTimeElapsed()

  eventPlayer.setGravity(0)
  waitUntil(eventPlayer.state[SI.LOW_GRAVITY] < getTotalTimeElapsed() or not eventPlayer.isAlive(), INFINITY)
  eventPlayer.setGravity(100)
