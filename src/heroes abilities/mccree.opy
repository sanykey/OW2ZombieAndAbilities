#!mainFile "../main.opy"

enum CASSIDY_I:
  LASSO_0
  LASSO_1
  LASSO_2
  LASSO_3
  LASSO_4
  LASSO_5
  LASSO_6
  LASSO_7
  LASSO_8
  LASSO_HUD
  SMOKE_0
  SMOKE_1
  SMOKE_2
  

rule "[Cassydy] Init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.CASSIDY

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = 3
  eventPlayer.heroInfoHorFix0 = 8
  eventPlayer.heroInfoText0 = "{} <fgad5a5fFF>Cassidy</fg>:\n
  {} <fgad5a5fFF>Peacekeeper</fg>:
      - Alternate fire pushes enemies back.\n\n
  {} <fgad5a5fFF>Combat Roll</fg>:
      - Detonates a flashbang at the starting point of the roll, stunning enemies for 0.5 second. 
      - Hold the button to jump at the end of the roll.\n\n
  {} <fgad5a5fFF>Flashbang</fg>:
      - Stuns enemies for 1 second.
      - Throwing it at your feet creates a smoke screen that lowers enemy attack priority.\n\n

  ".format(
    heroIcon(Hero.CASSIDY),
    abilityIconString(Hero.CASSIDY, Button.SECONDARY_FIRE),
    abilityIconString(Hero.CASSIDY, Button.ABILITY_1),
    abilityIconString(Hero.CASSIDY, Button.ABILITY_2)
  )

  eventPlayer.heroInfoVertFix1 = 4.7
  eventPlayer.heroInfoHorFix1 = 9.5
  eventPlayer.heroInfoText1 = "
  {} <fgad5a5fFF>Deadeye</fg>:
      - On activation, freezes enemies in your line of sight for 2.5 seconds.\n\n
  {} NEW! <fgad5a5fFF>Lasso</fg>:
      - Hold the <fgdb9342FF>Melee</fg> button to pull and knock down the caught enemy.
  ".format(
    abilityIconString(Hero.CASSIDY, Button.ULTIMATE),
    abilityIconString(Hero.ROADHOG, Button.ABILITY_1)
  )

  # lasso effects
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null, 
    Beam.GRAPPLE, eventPlayer, vect(1, 0, 0) + ((eventPlayer + eventPlayer.abilPos0) / 2), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_0] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, vect(1, 0, 0) + ((eventPlayer.abilPos0 + eventPlayer) / 2), eventPlayer.abilPos0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_1] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0, eventPlayer.abilPos0 + vect(1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_2] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(1, 0, 0.5), eventPlayer.abilPos0 + vect(1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_3] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(1, 0, 1), eventPlayer.abilPos0 + vect(0.1, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_4] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(0.1, 0, 1.5), eventPlayer.abilPos0 + vect(-0.6, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_5] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(-0.6, 0, 1.5), eventPlayer.abilPos0 + vect(-1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_6] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(-1, 0, 1), eventPlayer.abilPos0 + vect(-1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_7] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.abilPos0 else null,
    Beam.GRAPPLE, eventPlayer.abilPos0 + vect(-1, 0, 0.5), eventPlayer.abilPos0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_8] = getLastCreatedEntity()

  hudText(
    eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
    null,
    "{}{} Lasso: {}".format(
      ABILITI_TEXT_INTEND,
      abilityIconString(Hero.ROADHOG, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>✓</fg> <fg94a0a544>(hold {})</fg>".format(inputBindingString(Button.MELEE))
    ),
    null,
    HudPosition.TOP,
    2.5,
    null,
    Color.WHITE,
    null
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_HUD] = getLastCreatedText()

  # debug(eventPlayer.targetPlayer0)
  # debug(eventPlayer.abilPos0)
  # debug(eventPlayer.abilDir0)
  # debug(eventPlayer.abilState0)
  # debug(eventPlayer.listisInvisible)

  waitUntil(eventPlayer.getHero() != Hero.CASSIDY, INFINITY)
  clearHeroInfo()
  destroyHudText(eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_HUD])
  for eventPlayer.I in range(9):
    destroyEffect(eventPlayer.heroEffectsIds[eventPlayer.I])

rule "[Cassydy] throw the lasso":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition not eventPlayer.abilPos0
  @Condition not eventPlayer.targetPlayer0
  @Condition not eventPlayer.abilDir0
  @Condition eventPlayer.isAlive() == true

  if eventPlayer.abilityCD:
    return

  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.abilPos0 = raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0)
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer0 = false
  chaseAtRate(eventPlayer.abilPos0, raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0), 10)
  eventPlayer.abilDir0 = false
  eventPlayer.abilState0 = false

  eventPlayer.abilDir0 = eventPlayer.getFacingDirection()
  chaseAtRate(eventPlayer.abilDir0, vect(0, -100, 0), 1)
  chaseAtRate(eventPlayer.abilPos0, eventPlayer.abilPos0 + eventPlayer.abilDir0 * 10, 30)
  eventPlayer.targetPlayer0 = false
  eventPlayer.abilState0 = true

  waitUntil(
    distance(eventPlayer.abilPos0, raycast(eventPlayer.abilPos0, eventPlayer.abilPos0 + eventPlayer.abilDir0 * 10, null, eventPlayer, true).getHitPosition()) <= 1, # lasso hit a wall
    3
  )
  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.abilState0 = false
  eventPlayer.abilityCD = 12
  wait(0.5)
  eventPlayer.abilPos0 = false
  eventPlayer.abilDir0 = false
  eventPlayer.abilState0 = true
  

rule "[Cassydy] lasso hit a player":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.abilPos0
  @Condition eventPlayer.abilState0
  @Condition not eventPlayer.targetPlayer0
  @Condition distance(eventPlayer.abilPos0, getRealClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam()))) <= 3
  @Condition getNumberOfPlayers(getOppositeTeam(eventPlayer.getTeam())) != 0
  @Condition getRealClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam())).isDead() != true

  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer0 = getRealClosestPlayer(eventPlayer.abilPos0, getOppositeTeam(eventPlayer.getTeam()))
  eventPlayer.targetPlayer0.setGravity(0)
  eventPlayer.abilPos0 = eventPlayer.targetPlayer0.getPosition()
  chaseAtRate(eventPlayer.abilPos0, vect(0, 1, -1) + eventPlayer.targetPlayer0.getPosition(), 300)
  eventPlayer.targetPlayer0.setStatusEffect(eventPlayer, Status.STUNNED, 1)
  eventPlayer.targetPlayer0.applyImpulse(directionTowards(eventPlayer.targetPlayer0, eventPlayer), 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  damage(eventPlayer.targetPlayer0, eventPlayer, 10)

  eventPlayer.targetPlayer0.setCrowdControlAttack(eventPlayer)

  eventPlayer.targetPlayer0.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 5)

  waitUntil(distance(eventPlayer, eventPlayer.targetPlayer0) <= 8, 2)
  eventPlayer.targetPlayer0.setGravity(100)
  eventPlayer.targetPlayer0.stopAcceleration()
  # eventPlayer.targetPlayer0.clearStatusEffect(Status.STUNNED)

  stopChasingVariable(eventPlayer.abilPos0)
  stopChasingVariable(eventPlayer.abilDir0)
  eventPlayer.targetPlayer0 = false
  eventPlayer.abilPos0 = false
  eventPlayer.abilState0 = false
  eventPlayer.abilDir0 = false
  eventPlayer.abilityCD = 12


rule "[Cassydy] Detonates a flashbang while rolling":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isUsingAbility1()

  eventPlayer.abilPos1 = eventPlayer.getPosition()
  wait(0.1)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.WHITE, eventPlayer.abilPos1, 1)
  playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_MINEFIELD_EXPLOSION_SOUND, Color.WHITE, eventPlayer.abilPos1, 100)
  eventPlayer.list0 = getPlayersInRadius(eventPlayer.abilPos1, 3, Team.2)

  damage(eventPlayer.list0, eventPlayer, 15)
  eventPlayer.list0.setStatusEffect(eventPlayer, Status.STUNNED, 1.5)

rule "[Cassydy] damage effects":
  @Event playerDealtDamage
  @Hero cassidy

  # [Cassydy] Knockback enemies when using alternate fire
  if eventAbility == Button.SECONDARY_FIRE:
    if victim.hasStatus(Status.KNOCKED_DOWN):
      return

    victim.setCrowdControlAttack(eventPlayer)
    victim.setGravityState(0, 0.15)
    if distance(eventPlayer, victim) <= 15:
      victim.applyImpulse(attacker.getFacingDirection(), 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    else:
      victim.applyImpulse(attacker.getFacingDirection(), max(5, 30 - distance(eventPlayer, victim)), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  # [Cassydy] stun effect for flashbang:
  elif eventAbility == Button.ABILITY_2: 
    victim.setStatusEffect(eventPlayer, Status.STUNNED, 2)

rule "[Cassydy] Roll leap":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isUsingAbility1()
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
  
  wait(0.30, Wait.ABORT_WHEN_FALSE)
  eventPlayer.applyImpulse(Vector.UP, 13, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

rule "[Cassidy] Smoke Bomb":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isUsingAbility2() == true
  @Condition eventPlayer.getVerticalFacingAngle() > 60
  
  eventPlayer.abilPos2 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 7, getLivingPlayers(Team.ALL), eventPlayer, true).getHitPosition()
  wait(0.25)
  playEffect(getAllPlayers(), DynamicEffect.WINSTON_JUMP_PACK_LANDING, Color.TEAM_1, eventPlayer.abilPos2, 1)
  createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, eventPlayer.abilPos2, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_0] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, eventPlayer.abilPos2, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_1] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, eventPlayer.abilPos2 + Vector.UP * 0.5, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_2] = getLastCreatedEntity()
  eventPlayer.abilState2 = true
  wait(4)
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_0])
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_1])
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_2])
  eventPlayer.abilState2 = false

rule "[Cassidy] Smoke Bomb - Hide":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.abilState2
  
  eventPlayer.list0 = getPlayersInRadius(eventPlayer.abilPos2, 6, Team.1)
  eventPlayer.list0.isInvisible = getTotalTimeElapsed() + 0.25

  wait(0.2)
  if ruleCondition:
    loop()


rule "[Cassidy] Ultimate root":
  @Event eachPlayer
  @Team 1
  @Hero cassidy
  @Condition eventPlayer.isUsingUltimate() == true
  
  wait(0.02)
  eventPlayer.getPlayersInViewAngle(Team.2, 90).setStatusEffect(null, Status.ROOTED, 4)