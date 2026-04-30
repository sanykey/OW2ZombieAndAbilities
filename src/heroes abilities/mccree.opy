#!mainFile "../main.opy"
#!optimizeForSize

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

  setHeroInfoText0(
    f"{heroIcon(Hero.CASSIDY)} <fgad5a5fFF>Cassidy</fg>:\n
    {abilityIconString(Hero.CASSIDY, Button.SECONDARY_FIRE)} <fgad5a5fFF>Peacekeeper</fg>:
      - Alternate fire pushes enemies back.\n\n
    {abilityIconString(Hero.CASSIDY, Button.ABILITY_1)} <fgad5a5fFF>Combat Roll</fg>:
      - Detonates a flashbang at the starting point of the roll, stunning enemies for 0.5 second. 
      - Hold the button to jump at the end of the roll.\n\n
    {abilityIconString(Hero.CASSIDY, Button.ABILITY_2)} <fgad5a5fFF>Flashbang</fg>:
      - Stuns enemies for 1 second.
      - Throwing it at your feet creates a smoke screen that lowers enemy attack priority.
    ", 3, 8
  )

  setHeroInfoText1(
    f"
    {abilityIconString(Hero.CASSIDY, Button.ULTIMATE)} <fgad5a5fFF>Deadeye</fg>:
      - On activation, freezes enemies in your line of sight for 2.5 seconds.\n\n
    {abilityIconString(Hero.ROADHOG, Button.ABILITY_1)} NEW! <fgad5a5fFF>Lasso</fg>:
      - Hold the <fgdb9342FF>Melee</fg> button to pull and knock down the caught enemy.
    ", 4.7, 9.5
  )

  # lasso effects
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null, 
    Beam.GRAPPLE, eventPlayer, vect(1, 0, 0) + ((eventPlayer + eventPlayer.heroState0) / 2), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_0] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, vect(1, 0, 0) + ((eventPlayer.heroState0 + eventPlayer) / 2), eventPlayer.heroState0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_1] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0, eventPlayer.heroState0 + vect(1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_2] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(1, 0, 0.5), eventPlayer.heroState0 + vect(1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_3] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(1, 0, 1), eventPlayer.heroState0 + vect(0.1, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_4] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(0.1, 0, 1.5), eventPlayer.heroState0 + vect(-0.6, 0, 1.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_5] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(-0.6, 0, 1.5), eventPlayer.heroState0 + vect(-1, 0, 1), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_6] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(-1, 0, 1), eventPlayer.heroState0 + vect(-1, 0, 0.5), Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_7] = getLastCreatedEntity()
  createBeam(
    getPlayers(Team.1) if eventPlayer.heroState0 else null,
    Beam.GRAPPLE, eventPlayer.heroState0 + vect(-1, 0, 0.5), eventPlayer.heroState0, Color.ORANGE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_8] = getLastCreatedEntity()

  # Lasson ability CD info:
  eventPlayer.abilityCDHud(
    "{}{} Lasso: {}".format(
      ABILITI_TEXT_INTEND,
      abilityIconString(Hero.ROADHOG, Button.ABILITY_1),
      ceil(eventPlayer.abilityCD) if eventPlayer.abilityCD else "<fgA0E81BFF>✓</fg> <fg94a0a544>(double [{}])</fg>".format(inputBindingString(Button.MELEE))
    ),
    eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_HUD]
  )

  waitUntil(eventPlayer.getHero() != Hero.CASSIDY, INFINITY)
  clearHeroInfoSub()
  destroyHudText(eventPlayer.heroEffectsIds[CASSIDY_I.LASSO_HUD])
  for I in range(9):
    destroyEffect(eventPlayer.heroEffectsIds[I])

rule "[Cassydy] throw the lasso":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  @Condition not eventPlayer.heroState0
  @Condition not eventPlayer.heroState1 # target
  @Condition not eventPlayer.heroState2 # direction

  if eventPlayer.abilityCD:
    return

  # detect double press melee button:
  waitUntil(not eventPlayer.isHoldingButton(Button.MELEE), 0.3)
  if eventPlayer.isHoldingButton(Button.MELEE):
    return
  waitUntil(eventPlayer.isHoldingButton(Button.MELEE), 0.3)
  if not eventPlayer.isHoldingButton(Button.MELEE):
    return

  eventPlayer.heroState0 = raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0)
  stopChasingVariable(eventPlayer.heroState0)
  stopChasingVariable(eventPlayer.heroState2)
  eventPlayer.heroState1 = false
  chaseAtRate(eventPlayer.heroState0, raycast(eventPlayer, eventPlayer + vect(0, 5, 0), null, eventPlayer, true).getHitPosition() + vect(0, -1, 0), 10)
  eventPlayer.heroState2 = false
  eventPlayer.heroState5 = false

  eventPlayer.heroState2 = eventPlayer.getFacingDirection()
  chaseAtRate(eventPlayer.heroState2, vect(0, -100, 0), 1)
  chaseAtRate(eventPlayer.heroState0, eventPlayer.heroState0 + eventPlayer.heroState2 * 10, 30)
  eventPlayer.heroState1 = false
  eventPlayer.heroState5 = true

  waitUntil(
    distance(eventPlayer.heroState0, raycast(eventPlayer.heroState0, eventPlayer.heroState0 + eventPlayer.heroState2 * 10, null, eventPlayer, true).getHitPosition()) <= 1, # lasso hit a wall
    3
  )
  stopChasingVariable(eventPlayer.heroState0)
  stopChasingVariable(eventPlayer.heroState2)
  eventPlayer.heroState5 = false
  eventPlayer.abilityCD = CASSIDY_LASSO_CD
  wait(0.5)
  eventPlayer.heroState0 = false
  eventPlayer.heroState2 = false
  eventPlayer.heroState5 = true
  

rule "[Cassydy] lasso hit a player":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.heroState0
  @Condition eventPlayer.heroState5
  @Condition not eventPlayer.heroState1
  @Condition distance(eventPlayer.heroState0, getRealClosestPlayer(eventPlayer.heroState0, getOppositeTeam(eventPlayer.getTeam()))) <= 3
  @Condition getNumberOfPlayers(getOppositeTeam(eventPlayer.getTeam())) != 0
  @Condition getRealClosestPlayer(eventPlayer.heroState0, getOppositeTeam(eventPlayer.getTeam())).isDead() != true

  stopChasingVariable(eventPlayer.heroState0)
  stopChasingVariable(eventPlayer.heroState2)
  eventPlayer.heroState1 = getRealClosestPlayer(eventPlayer.heroState0, getOppositeTeam(eventPlayer.getTeam()))
  eventPlayer.heroState1.setGravity(0)
  eventPlayer.heroState0 = eventPlayer.heroState1.getPosition()
  chaseAtRate(eventPlayer.heroState0, vect(0, 1, -1) + eventPlayer.heroState1.getPosition(), 300)
  eventPlayer.heroState1.setStatusEffect(eventPlayer, Status.STUNNED, 1)
  eventPlayer.heroState1.applyImpulse(directionTowards(eventPlayer.heroState1, eventPlayer), 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  damage(eventPlayer.heroState1, eventPlayer, 10)

  eventPlayer.heroState1.setCrowdControlAttack(eventPlayer)

  eventPlayer.heroState1.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 5)

  waitUntil(distance(eventPlayer, eventPlayer.heroState1) <= 8, 2)
  eventPlayer.heroState1.setGravity(100)
  eventPlayer.heroState1.stopAcceleration()
  # eventPlayer.heroState1.clearStatusEffect(Status.STUNNED)

  stopChasingVariable(eventPlayer.heroState0)
  stopChasingVariable(eventPlayer.heroState2)
  eventPlayer.heroState1 = false
  eventPlayer.heroState0 = false
  eventPlayer.heroState5 = false
  eventPlayer.heroState2 = false
  eventPlayer.abilityCD = CASSIDY_LASSO_CD


rule "[Cassydy] Detonates a flashbang while rolling":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.isUsingAbility1()

  eventPlayer.heroState3 = eventPlayer.getPosition()
  wait(0.1)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.WHITE, eventPlayer.heroState3, 1)

  # todo: remove or replace:
  # playEffect(getAllPlayers(), DynamicEffect.WRECKING_BALL_MINEFIELD_EXPLOSION_SOUND, Color.WHITE, eventPlayer.heroState3, 100)
  list0 = getPlayersInRadius(eventPlayer.heroState3, 3, Team.ZOMBIES)

  damage(list0, eventPlayer, 15)
  list0.setStatusEffect(eventPlayer, Status.STUNNED, 1.5)

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
  @Condition eventPlayer.isUsingAbility2()
  @Condition eventPlayer.getVerticalFacingAngle() > 60
  
  eventPlayer.heroState4 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 7, getLivingPlayers(Team.ALL), eventPlayer, true).getHitPosition()
  wait(0.25)
  playEffect(getAllPlayers(), DynamicEffect.WINSTON_JUMP_PACK_LANDING, Color.TEAM_1, eventPlayer.heroState4, 1)
  createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, eventPlayer.heroState4, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_0] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.RING, Color.WHITE, eventPlayer.heroState4, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_1] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.CLOUD, Color.WHITE, eventPlayer.heroState4 + Vector.UP * 0.5, 6)
  eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_2] = getLastCreatedEntity()
  eventPlayer.heroState6 = true
  wait(4)
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_0])
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_1])
  destroyEffect(eventPlayer.heroEffectsIds[CASSIDY_I.SMOKE_2])
  eventPlayer.heroState6 = false

rule "[Cassidy] Smoke Bomb - Hide":
  @Event eachPlayer
  @Hero cassidy
  @Condition eventPlayer.heroState6
  
  getPlayersInRadius(eventPlayer.heroState4, 6, Team.1).isInvisible = getTotalTimeElapsed() + 0.25

  wait(0.2)
  if ruleCondition:
    loop()


rule "[Cassidy] Ultimate root":
  @Event eachPlayer
  @Team 1
  @Hero cassidy
  @Condition eventPlayer.isUsingUltimate()
  
  wait(0.02)
  eventPlayer.getPlayersInViewAngle(Team.ZOMBIES, 90).setStatusEffect(null, Status.ROOTED, 4)