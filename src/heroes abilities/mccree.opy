#!mainFile "../main.opy"


rule "[Cassydy] Init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.CASSIDY

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 2
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = 1
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg765dbdFF>Cassidy</fg>:\n

  ".format(
    heroIcon(Hero.CASSIDY)
  )

  # lasso effects
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer, vect(1, 0, 0) + ((eventPlayer + eventPlayer.abilPos0) / 2), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[0] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, vect(1, 0, 0) + ((eventPlayer.abilPos0 + eventPlayer) / 2), eventPlayer.abilPos0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[1] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0, eventPlayer.abilPos0 + vect(1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[2] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(1, 0, 0.5), eventPlayer.abilPos0 + vect(1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[3] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(1, 0, 1), eventPlayer.abilPos0 + vect(0.1, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[4] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(0.1, 0, 1.5), eventPlayer.abilPos0 + vect(-0.6, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[5] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(-0.6, 0, 1.5), eventPlayer.abilPos0 + vect(-1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[6] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(-1, 0, 1), eventPlayer.abilPos0 + vect(-1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[7] = getLastCreatedEntity()
  createBeam(getPlayers(Team.1) if eventPlayer.abilPos0 else null, Beam.GOOD, eventPlayer.abilPos0 + vect(-1, 0, 0.5), eventPlayer.abilPos0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroState[8] = getLastCreatedEntity()

  debug(eventPlayer.targetPlayer)
  debug(eventPlayer.abilPos0)
  debug(eventPlayer.abilDir0)
  debug(eventPlayer.abilState0)

  waitUntil(eventPlayer.getHero() != Hero.CASSIDY, INFINITY)
  clearHeroInfo()

  for eventPlayer.I in range(9):
    destroyEffect(eventPlayer.heroState[eventPlayer.I])

rule "[Cassydy] throw the lasso":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition not eventPlayer.abilPos0
  @Condition not eventPlayer.targetPlayer
  @Condition not eventPlayer.abilDir0
  @Condition eventPlayer.isAlive() == true

  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.abilPos0 = raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0)
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer = false
  chaseAtRate(eventPlayer.abilPos0, raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0), 10)
  eventPlayer.abilDir0 = false
  eventPlayer.abilState0 = false

  eventPlayer.abilDir0 = eventPlayer.getFacingDirection()
  chaseAtRate(eventPlayer.abilDir0, vect(0, -100, 0), 1)
  chaseAtRate(eventPlayer.abilPos0, eventPlayer.abilPos0 + eventPlayer.abilDir0 * 10, 30)
  eventPlayer.targetPlayer = false
  eventPlayer.abilState0 = true

rule "[Cassydy] lasso hit a wall":
  @Event eachPlayer
  @Hero cassidy
  @Condition distance(eventPlayer.abilPos0, raycast(eventPlayer.abilPos0, eventPlayer.abilPos0 + eventPlayer.abilDir0 * 10, null, eventPlayer, true).getHitPosition()) <= 1
  @Condition eventPlayer.targetPlayer == 0
  @Condition eventPlayer.abilPos0 != 0
  @Condition eventPlayer.abilDir0 != 0
  
  eventPlayer.abilState0 = false
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  wait(1)
  eventPlayer.abilPos0 = false
  eventPlayer.abilDir0 = false
  eventPlayer.abilState0 = true

rule "[Cassydy] lasso hit a player":
  @Event eachPlayer
  @Hero cassidy
  @Condition distance(eventPlayer.abilPos0, getClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam()))) <= 3
  @Condition eventPlayer.abilPos0 != 0
  @Condition eventPlayer.targetPlayer == 0
  @Condition getNumberOfPlayers(getOppositeTeam(eventPlayer.getTeam())) != 0
  @Condition getClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam())).isDead() != true
  @Condition eventPlayer.abilState0 == true
  
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer = getClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam()))
  eventPlayer.targetPlayer.setGravity(0)
  eventPlayer.abilPos0 = eventPlayer.targetPlayer.getPosition()
  chaseAtRate(eventPlayer.abilPos0, vect(0, 1, -1) + eventPlayer.targetPlayer.getPosition(), 300)
  eventPlayer.targetPlayer.setStatusEffect(eventPlayer, Status.STUNNED, 1)
  eventPlayer.targetPlayer.applyImpulse(directionTowards(eventPlayer.targetPlayer, eventPlayer), 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  damage(eventPlayer.targetPlayer, eventPlayer, 10)
  eventPlayer.targetPlayer.state[SI.LAST_CC_ATTACKER] = eventPlayer
  eventPlayer.targetPlayer.state[SI.LAST_CC_ATTACK_TIME] = LAST_CC_ATTACK_DURATION + getTotalTimeElapsed()
  eventPlayer.targetPlayer.state[SI.LAST_CC_WAS_IN_AIR] = false
  eventPlayer.targetPlayer.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 2)

  waitUntil(distance(eventPlayer, eventPlayer.targetPlayer) <= 8, 2)
  eventPlayer.targetPlayer.setGravity(100)
  eventPlayer.targetPlayer.stopAcceleration()
  eventPlayer.targetPlayer.clearStatusEffect(Status.STUNNED)
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer = false
  eventPlayer.abilPos0 = false
  eventPlayer.abilState0 = false
  eventPlayer.abilDir0 = false