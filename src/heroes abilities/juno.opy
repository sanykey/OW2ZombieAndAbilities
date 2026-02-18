#!mainFile "../main.opy"

## for juno rift ability:
playervar juno_last_rift
playervar juno_rift2_placement
playervar juno_rift2_fx
playervar juno_rift2_destination
playervar juno_rift1_placement
playervar juno_rift1_fx
playervar juno_rift1_destination
playervar juno_rift2_active
playervar juno_rift1_active
playervar juno_rift
playervar juno_hyper_hud
playervar juno_rift_icon

## for juno rift ability:
playervar juno_transfer_pos
playervar juno_transfer_from
playervar juno_transfer_to
playervar juno_transfer_fx
playervar juno_transfer_started


enum JUN_I:
  RIFT0_EFFECT0
  RIFT0_EFFECT1
  RIFT0_EFFECT2
  RIFT0_EFFECT3
  
  RIFT1_EFFECT0
  RIFT1_EFFECT1
  RIFT1_EFFECT2
  RIFT1_EFFECT3

  LAST_RIFT
  RIFT2_ACTIVE
  RIFT2_PLACEMENT
  RIFT2_DESTINATION
  RIFT2_FX

  RIFT1_ACTIVE
  RIFT1_PLACEMENT
  RIFT1_DESTINATION
  RIFT1_FX

  RIFT_HUD

rule "[Juno] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.JUNO

  eventPlayer.juno_rift2_active = false
  eventPlayer.juno_rift1_active = false
  eventPlayer.juno_rift1_destination = vect(0, 1000, 0)
  eventPlayer.juno_rift2_destination = vect(0, 1000, 0)

  eventPlayer.heroInfoVertFix0 = 2
  eventPlayer.heroInfoText0 = "{} <fg721fa3FF>Juno</fg>:\n
  {} {}Glide Boost{}:
    - Duration increased 4 → 6 secs\n\n
  {} {}Orbital ray{}:
    - Immobilizes, lifts enemies into the air, and deals continuous damage.\n\n
  {} NEW! {}Hyper Rift{}:
    - Press {}[Interact] + [Ability2]{} buttons to create a rift that connects to
      any existing one, allowing your team to travel between them. 
      To begin traveling, approach a rift and hold {}[Interact]{} button.
    - Cooldown shared with Hyper ring.\n\n
  ".format(
    heroIcon(Hero.JUNO),
    abilityIconString(Hero.JUNO, Button.ABILITY_1),
    "<fg721fa3FF>",
    "</fg>",
    abilityIconString(Hero.JUNO, Button.ULTIMATE),
    "<fg721fa3FF>",
    "</fg>",
    iconString(Icon.SPIRAL),
    "<fg721fa3FF>",
    "</fg>",
    "<fgdb9342FF>",
    "</fg>",
    "<fgdb9342FF>",
    "</fg>"
  )

  eventPlayer.heroInfoVertFix1 = 3.5
  eventPlayer.heroInfoHorFix1 = 11
  eventPlayer.heroInfoText1 = "" 

  hudText(
    eventPlayer if not eventPlayer.isHeroDescriptionOpened else null,
    null,
    "{}{} Hyper rift: {} {}".format(
      ABILITI_TEXT_INTEND,
      iconString(Icon.SPIRAL),
      ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)) if eventPlayer.getAbilityCooldown(Button.ABILITY_2) else "<fgA0E81BFF>✓</fg> <fg94a0a544>({} + {})</fg>".format(
        inputBindingString(Button.INTERACT),
        inputBindingString(Button.ABILITY_2)
      ),
      ". Place second rift! " if eventPlayer.juno_rift2_active and not eventPlayer.juno_rift1_active else ""
    ),
    "{}{}".format(
      ABILITI_CHARGES_INTEND,
      ["", "■□□□□□ ", "■■□□□□ ", "■■■□□□ ", "■■■■□□ ", "■■■■■□ ", "■■■■■■ "][eventPlayer.abilState0]
    ),
    HudPosition.TOP,
    2.5,
    null,
    Color.WHITE,
    Color.WHITE
  )
  eventPlayer.heroEffectsIds[JUN_I.RIFT_HUD] = getLastCreatedText()


  waitUntil(eventPlayer.getHero() != Hero.JUNO, INFINITY)
  clearHeroInfo()

  destroyHudText(eventPlayer.heroEffectsIds[JUN_I.RIFT_HUD])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT0])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT1])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT2])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT3])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT0])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT1])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT2])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT3])
  eventPlayer.juno_rift2_active = false
  eventPlayer.juno_rift1_active = false


# code from [Juno Orbital Ray Detection | Workshop.codes](https://workshop.codes/YETHW)
rule "[Juno] Track Orbital Ray Position":
  @Event eachPlayer
  @Hero juno
  @Condition eventPlayer.isUsingUltimate() == false
  
  stopChasingVariable(eventPlayer.abilPos0)
  eventPlayer.abilPos0 = vect(0, 999, 0)
  waitUntil(eventPlayer.isUsingUltimate(), INFINITY)
  eventPlayer.abilPos1 = eventPlayer.getPosition() + directionFromAngles(eventPlayer.getHorizontalFacingAngle(), 0) * 22.5
  eventPlayer.abilPos0 = eventPlayer.getPosition() + directionTowards(eventPlayer.getPosition(), eventPlayer.abilPos1) * 3
  wait(1)
  chaseAtRate(eventPlayer.abilPos0, evalOnce(eventPlayer.abilPos1), 2.25)


# code from [Overwatch: The Reworked Showdown](https://workshop.codes/JZCBZ)
rule "[Juno] Ultimate - abduct enemies":
  @Event eachPlayer
  @Hero juno
  @Condition eventPlayer.isUsingUltimate() == true
  
  wait(0.7, Wait.ABORT_WHEN_FALSE)

  eventPlayer.list0 = [player for player in getLivingPlayers(Team.ZOMBIES) if distance(player.getPosition() * vect(1, 0, 1), eventPlayer.abilPos0) <= 8]
  
  eventPlayer.list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.list0.setGravityState(0, 0.5)
  eventPlayer.list0.setSpeedState(0, 0.5)
  damage(eventPlayer.list0, eventPlayer, 2.5)

  for eventPlayer.I in range(len(eventPlayer.list0)):
    eventPlayer.list0[eventPlayer.I].applyImpulse(
      normalize((eventPlayer.abilPos0 + Vector.UP * 20) - eventPlayer.list0[eventPlayer.I].getPosition()),
      13,
      Relativity.TO_WORLD,
      Impulse.INCORPORATE_CONTRARY_MOTION
    )
  wait(0.1)
  if ruleCondition:
    loop()


# Hyper Rift code from [What If... Overwatch 3?](https://workshop.codes/4MZP7)
rule "[Juno] Hyper Rift placement":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition eventPlayer.isUsingAbility2() == true and eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.juno_last_rift != 2
  
  eventPlayer.cancelPrimaryAction()
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
  wait(0.24)
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT0])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT1])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT2])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT3])
  eventPlayer.juno_rift2_active = false
  eventPlayer.juno_last_rift = 2
  eventPlayer.juno_rift2_placement = eventPlayer.getEyePosition() + vect(0, -0.3, 0)
  eventPlayer.juno_rift2_destination = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 8.5, null, eventPlayer, true).getHitPosition()
  eventPlayer.juno_rift2_destination = raycast(eventPlayer.juno_rift2_destination, raycast(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift2_destination + eventPlayer.getFacingDirection() * -1.5, null, eventPlayer, true).getHitPosition(), null, eventPlayer, true).getHitPosition()
  #Check space between rift and ground
  if distance(eventPlayer.juno_rift2_destination, raycast(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift2_destination + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition()) < 1.5 and distance(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift2_destination + Vector.UP * 1.5) == 1.5:
      eventPlayer.juno_rift2_destination = raycast(raycast(eventPlayer.juno_rift2_destination + Vector.UP * 0.1, eventPlayer.juno_rift2_destination + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition(), raycast(eventPlayer.juno_rift2_destination + Vector.UP * 0.1, eventPlayer.juno_rift2_destination + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition() + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition()
      #Check space between rift and ceiling
  elif distance(eventPlayer.juno_rift2_destination, raycast(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift2_destination + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition()) < 1.5 and distance(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift2_destination + Vector.DOWN * 1.5) == 1.5:
      eventPlayer.juno_rift2_destination = raycast(raycast(eventPlayer.juno_rift2_destination + Vector.DOWN * 0.1, eventPlayer.juno_rift2_destination + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition(), raycast(eventPlayer.juno_rift2_destination + Vector.DOWN * 0.1, eventPlayer.juno_rift2_destination + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition() + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition()
  createProjectileEffect(getAllPlayers(), Projectile.ECHO_STICKY_BOMB, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift2_placement), eventPlayer.getFacingDirection(), 0.035, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift2_fx = getLastCreatedEntity()
  chaseAtRate(eventPlayer.juno_rift2_placement, eventPlayer.juno_rift2_destination, 15)
  waitUntil(eventPlayer.juno_rift2_placement == eventPlayer.juno_rift2_destination, 5)
  destroyEffect(eventPlayer.juno_rift2_fx)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION, eventPlayer.getTeam(), eventPlayer.juno_rift2_destination, 1)
  createEffect(getAllPlayers(), Effect.BAD_AURA, Color.WHITE, eventPlayer.juno_rift2_placement, 0.35, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT0] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift2_placement), directionTowards(eventPlayer.juno_rift2_placement, eventPlayer.juno_rift1_destination), 0.15, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT1] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.ZARYA_GRAVITON, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift2_placement), eventPlayer.getFacingDirection(), 0.135, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT2] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.TURQUOISE, eventPlayer.juno_rift2_destination, 0.65, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT3] = getLastCreatedEntity()
  eventPlayer.juno_rift2_active = true
  if eventPlayer.juno_rift1_active == true:
      smallMessage(getPlayers(eventPlayer.getTeam()), l"{0} {1} {2}".format(abilityIconString(Hero.JUNO, Button.ABILITY_2), "Hyper Rift created by", l"{0} {1}".format(eventPlayer.getHero(), l"({0})".format(eventPlayer))))


rule "[Juno] Hyper Rift second placement":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition eventPlayer.isUsingAbility2() == true and eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.juno_last_rift == 2
  
  eventPlayer.cancelPrimaryAction()
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 25)
  wait(0.24)
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT0])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT1])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT2])
  destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT3])
  eventPlayer.juno_rift1_active = false
  eventPlayer.juno_last_rift = 1
  eventPlayer.juno_rift1_placement = eventPlayer.getEyePosition() + vect(0, -0.3, 0)
  eventPlayer.juno_rift1_destination = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 8.5, null, eventPlayer, true).getHitPosition()
  eventPlayer.juno_rift1_destination = raycast(eventPlayer.juno_rift1_destination, raycast(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift1_destination + eventPlayer.getFacingDirection() * -1.5, null, eventPlayer, true).getHitPosition(), null, eventPlayer, true).getHitPosition()
  #Check space between rift and ground
  if distance(eventPlayer.juno_rift1_destination, raycast(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift1_destination + Vector.DOWN * 2, null, eventPlayer, true).getHitPosition()) < 2 and distance(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift1_destination + Vector.UP * 2) == 2:
      eventPlayer.juno_rift1_destination = raycast(raycast(eventPlayer.juno_rift1_destination + Vector.UP * 0.1, eventPlayer.juno_rift1_destination + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition(), raycast(eventPlayer.juno_rift1_destination + Vector.UP * 0.1, eventPlayer.juno_rift1_destination + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition() + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition()
      #Check space between rift and ceiling
  elif distance(eventPlayer.juno_rift1_destination, raycast(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift1_destination + Vector.UP * 2, null, eventPlayer, true).getHitPosition()) < 2 and distance(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift1_destination + Vector.DOWN * 2) == 2:
      eventPlayer.juno_rift1_destination = raycast(raycast(eventPlayer.juno_rift1_destination + Vector.DOWN * 0.1, eventPlayer.juno_rift1_destination + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition(), raycast(eventPlayer.juno_rift1_destination + Vector.DOWN * 0.1, eventPlayer.juno_rift1_destination + Vector.UP * 1.5, null, eventPlayer, true).getHitPosition() + Vector.DOWN * 1.5, null, eventPlayer, true).getHitPosition()
  createProjectileEffect(getAllPlayers(), Projectile.ECHO_STICKY_BOMB, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift1_placement), eventPlayer.getFacingDirection(), 0.035, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift1_fx = getLastCreatedEntity()
  chaseAtRate(eventPlayer.juno_rift1_placement, eventPlayer.juno_rift1_destination, 15)
  waitUntil(eventPlayer.juno_rift1_placement == eventPlayer.juno_rift1_destination, 5)
  destroyEffect(eventPlayer.juno_rift1_fx)
  playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 1)
  createEffect(getAllPlayers(), Effect.BAD_AURA, Color.WHITE, eventPlayer.juno_rift1_placement, 0.35, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT0] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift1_placement), directionTowards(eventPlayer.juno_rift1_placement, eventPlayer.juno_rift2_destination), 0.15, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT1] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.ZARYA_GRAVITON, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift1_placement), eventPlayer.getFacingDirection(), 0.135, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT2] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.GOOD_AURA, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 0.85, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT3] = getLastCreatedEntity()
  eventPlayer.juno_rift1_active = true
  if eventPlayer.juno_rift2_active == true:
    eventPlayer.abilState0 = 6
    smallMessage(getPlayers(eventPlayer.getTeam()), l"{0} {1} {2}".format(abilityIconString(Hero.JUNO, Button.ABILITY_2), "Hyper Rift created by", l"{0} {1}".format(eventPlayer.getHero(), l"({0})".format(eventPlayer))))


rule "[Juno] Hyper Rift icon":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition (eventPlayer.juno_rift2_active == true and eventPlayer.juno_rift1_active == true) == true
  
  destroyIcon(eventPlayer.juno_rift_icon[0])
  destroyIcon(eventPlayer.juno_rift_icon[1])
  createIcon(getPlayers(eventPlayer.getTeam()), eventPlayer.juno_rift2_destination + vect(0, 0.6, 0), Icon.ARROW_DOWN, IconReeval.VISIBILITY_AND_POSITION, Color.AQUA, false)
  eventPlayer.juno_rift_icon[0] = getLastCreatedEntity()
  createIcon(getPlayers(eventPlayer.getTeam()), eventPlayer.juno_rift1_destination + vect(0, 0.6, 0), Icon.ARROW_DOWN, IconReeval.VISIBILITY_AND_POSITION, Color.BLUE, false)
  eventPlayer.juno_rift_icon[1] = getLastCreatedEntity()
  waitUntil(eventPlayer.juno_rift2_active != true or eventPlayer.juno_rift1_active != true or eventPlayer.getHero() != Hero.JUNO, 99999)
  destroyIcon(eventPlayer.juno_rift_icon[0])
  destroyIcon(eventPlayer.juno_rift_icon[1])

rule "[Juno] Hyper Rift transfer":
  @Event eachPlayer
  @Condition (
    eventPlayer.juno_transfer_from and eventPlayer.juno_transfer_to and eventPlayer.juno_transfer_started
  )

  pause3PCamera()
  wait(0.1)
  playEffect(getAllPlayers(), DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_transfer_from, 1)
  eventPlayer.setInvisibility(Invis.ALL)
  eventPlayer.startForcingPosition(eventPlayer.juno_transfer_from, false)
  eventPlayer.setStatusEffect(null, Status.FROZEN, 20)
  eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 20)
  eventPlayer.juno_transfer_pos = eventPlayer.juno_transfer_from
  eventPlayer.startCamera(updateEveryFrame(raycast(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_pos + eventPlayer.getFacingDirection() * -5, null, eventPlayer, true).getHitPosition()), eventPlayer.juno_transfer_pos)
  chaseAtRate(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_to, 20)

  createProjectileEffect(
    getAllPlayers(),
    Projectile.SIGMA_HYPERSPHERE,
    getPlayers(eventPlayer.getTeam()),
    updateEveryFrame(eventPlayer.juno_transfer_pos),
    directionTowards(eventPlayer.juno_transfer_to, eventPlayer.juno_transfer_from),
    0.035,
    ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE
  )
  eventPlayer.juno_transfer_fx = getLastCreatedEntity()
  
  waitUntil(distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_from) <= distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_to), 10)
  eventPlayer.stopForcingPosition()
  eventPlayer.teleport(eventPlayer.juno_transfer_to)
  eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
  wait(distance(eventPlayer.juno_transfer_from, eventPlayer.juno_transfer_to) / 20)
  eventPlayer.stopCamera()
  wait(0.1)
  eventPlayer.clearStatusEffect(Status.FROZEN)
  eventPlayer.clearStatusEffect(Status.PHASED_OUT)
  eventPlayer.setInvisibility(Invis.NONE)
  playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_transfer_to, 1)
  playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_DISAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_transfer_from, 1)
  destroyEffect(eventPlayer.juno_transfer_fx)
  eventPlayer.stopForcingPosition()
  unpause3PCamera()
  eventPlayer.juno_transfer_started = false

rule "[Juno] Get players for hyper Rift transfer":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition eventPlayer.juno_rift2_active and eventPlayer.juno_rift1_active

  eventPlayer.list0 = [player for player in getPlayersInRadius(eventPlayer.juno_rift1_destination, 2, Team.1) if (
    player.isAlive() and
    not player.juno_transfer_started and
    player.isHoldingButton(Button.INTERACT)
  )]
  eventPlayer.list1 = [player for player in getPlayersInRadius(eventPlayer.juno_rift2_destination, 2, Team.1) if (
    player.isAlive() and
    not player.juno_transfer_started and
    player.isHoldingButton(Button.INTERACT)
  )]

  if (eventPlayer.list0):
    eventPlayer.list0.juno_transfer_from = eventPlayer.juno_rift1_destination
    eventPlayer.list0.juno_transfer_to = eventPlayer.juno_rift2_destination
    eventPlayer.list0.juno_transfer_started = true
    eventPlayer.abilState0 -= len(eventPlayer.list0)

  if (eventPlayer.list1):
    eventPlayer.list1.juno_transfer_from = eventPlayer.juno_rift2_destination
    eventPlayer.list1.juno_transfer_to = eventPlayer.juno_rift1_destination
    eventPlayer.list1.juno_transfer_started = true
    eventPlayer.abilState0 -= len(eventPlayer.list1)

  if eventPlayer.abilState0 < 1:
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT0])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT1])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT2])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT0_EFFECT3])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT0])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT1])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT2])
    destroyEffect(eventPlayer.heroEffectsIds[JUN_I.RIFT1_EFFECT3])
    eventPlayer.juno_rift2_active = false
    eventPlayer.juno_rift1_active = false
    eventPlayer.juno_last_rift = false


  wait(0.1)
  if ruleCondition:
    loop()


# rule "[Juno] debug":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.getHero() == Hero.JUNO

#   debug(eventPlayer.abilPos0)
#   debug(eventPlayer.list0)