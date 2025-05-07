#!mainFile "../main.opy"

enum JUN_I:
  RIFT0_EFFECT0 = 0
  RIFT0_EFFECT1 = 1
  RIFT0_EFFECT2 = 2
  RIFT0_EFFECT3 = 3
  RIFT1_EFFECT0 = 4
  RIFT1_EFFECT1 = 5
  RIFT1_EFFECT2 = 6
  RIFT1_EFFECT3 = 7

  LAST_RIFT = 8
  RIFT2_ACTIVE = 9
  RIFT2_PLACEMENT = 10
  RIFT2_DESTINATION = 11
  RIFT2_FX = 12

  RIFT1_ACTIVE = 13
  RIFT1_PLACEMENT = 10
  RIFT1_DESTINATION = 11
  RIFT1_FX = 12

rule "[Juno] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.JUNO

  eventPlayer.juno_rift2_active = false
  eventPlayer.juno_rift1_active = false
  eventPlayer.juno_rift1_destination = vect(0, 1000, 0)
  eventPlayer.juno_rift2_destination = vect(0, 1000, 0)

  eventPlayer.state[SI.TALENTS_COUNT] = 5
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = 2
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg721fa3FF>Juno</fg>:\n
  {} {}Sleep dart{}:
    - Hitting an enemy puts other enemies within a 3-meter radius to sleep.\n\n
  {} <fg721fa3FF>Biotic gredane</fg>:
    - Slows enemies by 50%.\n\n
  {} {}Nano boost{}:
    - Can now be used on Ana herself.
    - Increases movement speed by 30%.\n\n
  Melee:
    - Has a 20% chance to put an enemy to sleep.
  ".format(
    heroIcon(Hero.JUNO),
    abilityIconString(Hero.JUNO, Button.ABILITY_1),
    "<fg721fa3FF>",
    "</fg>",
    abilityIconString(Hero.JUNO, Button.ABILITY_2),
    abilityIconString(Hero.JUNO, Button.ULTIMATE),
    "<fg721fa3FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.JUNO, INFINITY)
  clearHeroInfo()

  destroyEffect(eventPlayer.juno_rift2_fx[0])
  destroyEffect(eventPlayer.juno_rift2_fx[1])
  destroyEffect(eventPlayer.juno_rift2_fx[2])
  destroyEffect(eventPlayer.juno_rift2_fx[3])
  destroyEffect(eventPlayer.juno_rift1_fx[0])
  destroyEffect(eventPlayer.juno_rift1_fx[1])
  destroyEffect(eventPlayer.juno_rift1_fx[2])
  destroyEffect(eventPlayer.juno_rift1_fx[3])
  eventPlayer.juno_rift2_active = false
  eventPlayer.juno_rift1_active = false



rule "Juno Hyper Rift placement":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition eventPlayer.isUsingAbility2() == true and eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.juno_last_rift != 2
  
  eventPlayer.cancelPrimaryAction()
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
  wait(0.24)
  destroyEffect(eventPlayer.juno_rift2_fx[0])
  destroyEffect(eventPlayer.juno_rift2_fx[1])
  destroyEffect(eventPlayer.juno_rift2_fx[2])
  destroyEffect(eventPlayer.juno_rift2_fx[3])
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
  eventPlayer.juno_rift2_fx[0] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift2_placement), directionTowards(eventPlayer.juno_rift2_placement, eventPlayer.juno_rift1_destination), 0.15, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift2_fx[1] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.ZARYA_GRAVITON, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift2_placement), eventPlayer.getFacingDirection(), 0.135, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift2_fx[2] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.TURQUOISE, eventPlayer.juno_rift2_destination, 0.65, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.juno_rift2_fx[3] = getLastCreatedEntity()
  eventPlayer.juno_rift2_active = true
  if eventPlayer.juno_rift1_active == true:
      smallMessage(getPlayers(eventPlayer.getTeam()), l"{0} {1} {2}".format(abilityIconString(Hero.JUNO, Button.ABILITY_2), "Hyper Rift created by", l"{0} {1}".format(eventPlayer.getHero(), l"({0})".format(eventPlayer))))


rule "Juno Hyper Rift second placement":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition eventPlayer.isUsingAbility2() == true and eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.juno_last_rift == 2
  
  eventPlayer.cancelPrimaryAction()
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
  wait(0.24)
  destroyEffect(eventPlayer.juno_rift1_fx[0])
  destroyEffect(eventPlayer.juno_rift1_fx[1])
  destroyEffect(eventPlayer.juno_rift1_fx[2])
  destroyEffect(eventPlayer.juno_rift1_fx[3])
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
  eventPlayer.juno_rift1_fx[0] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift1_placement), directionTowards(eventPlayer.juno_rift1_placement, eventPlayer.juno_rift2_destination), 0.15, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift1_fx[1] = getLastCreatedEntity()
  createProjectileEffect(getAllPlayers(), Projectile.ZARYA_GRAVITON, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_rift1_placement), eventPlayer.getFacingDirection(), 0.135, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
  eventPlayer.juno_rift1_fx[2] = getLastCreatedEntity()
  createEffect(getAllPlayers(), Effect.GOOD_AURA, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 0.85, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  eventPlayer.juno_rift1_fx[3] = getLastCreatedEntity()
  eventPlayer.juno_rift1_active = true
  if eventPlayer.juno_rift2_active == true:
      smallMessage(getPlayers(eventPlayer.getTeam()), l"{0} {1} {2}".format(abilityIconString(Hero.JUNO, Button.ABILITY_2), "Hyper Rift created by", l"{0} {1}".format(eventPlayer.getHero(), l"({0})".format(eventPlayer))))


rule "Juno Hyper Rift icon":
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


rule "Juno Hyper Rift transfer":
  @Event eachPlayer
  @Condition eventPlayer.getHero() == Hero.JUNO
  @Condition (eventPlayer.juno_rift2_active == true and eventPlayer.juno_rift1_active == true) == true
  @Condition (
    len(getPlayersInRadius(eventPlayer.juno_rift2_destination, 1.5, Team.1)) > 0 or
    len(getPlayersInRadius(eventPlayer.juno_rift1_destination, 1.5, Team.1)) > 0
  ) == true

  eventPlayer.list = getPlayersInRadius(eventPlayer.juno_rift1_destination, 1.5, Team.1)
  eventPlayer.list2 = getPlayersInRadius(eventPlayer.juno_rift2_destination, 1.5, Team.1)

  if (eventPlayer.list):
    smallMessage(eventPlayer, 'rift1!')

  if (eventPlayer.list2):
    smallMessage(eventPlayer, 'rift2!')

  wait(0.032)
  if (
    distance(eventPlayer.juno_rift2_destination, eventPlayer.getEyePosition()) <= 1.5 and distance(eventPlayer.juno_rift1_destination, eventPlayer.getEyePosition()) > 1.5
  ):
      playEffect(getAllPlayers(), DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift2_destination, 1)
      eventPlayer.setInvisibility(Invis.ALL)
      eventPlayer.startForcingPosition(eventPlayer.juno_rift2_destination, false)
      eventPlayer.setStatusEffect(null, Status.FROZEN, 20)
      eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 20)
      eventPlayer.juno_transfer_pos = eventPlayer.juno_rift2_destination
      eventPlayer.startCamera(updateEveryFrame(raycast(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_pos + eventPlayer.getFacingDirection() * -5, null, eventPlayer, true).getHitPosition()), eventPlayer.juno_transfer_pos)
      chaseAtRate(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift1_destination, 20)
      createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_transfer_pos), directionTowards(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift2_destination), 0.035, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
      eventPlayer.juno_rift2_fx[4] = getLastCreatedEntity()
      waitUntil(distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift2_destination) <= distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift1_destination), 10)
      eventPlayer.stopForcingPosition()
      eventPlayer.teleport(eventPlayer.juno_rift1_destination)
      eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
      wait(distance(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift1_destination) / 20)
      eventPlayer.stopCamera()
      wait(0.1)
      eventPlayer.clearStatusEffect(Status.FROZEN)
      eventPlayer.clearStatusEffect(Status.PHASED_OUT)
      eventPlayer.setInvisibility(Invis.NONE)
      playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 1)
      playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_DISAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift2_destination, 1)
      destroyEffect(eventPlayer.juno_rift2_fx[4])
      eventPlayer.stopForcingPosition()
  elif (
    distance(eventPlayer.juno_rift1_destination, eventPlayer.getEyePosition()) <= 1.5 and distance(eventPlayer.juno_rift2_destination, eventPlayer.getEyePosition()) > 1.5
  ):
      # eventPlayer.juno_rift1_active = false
      playEffect(getAllPlayers(), DynamicEffect.SYMMETRA_TELEPORTER_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 1)
      eventPlayer.setInvisibility(Invis.ALL)
      eventPlayer.startForcingPosition(eventPlayer.juno_rift1_destination, false)
      eventPlayer.setStatusEffect(null, Status.FROZEN, 20)
      eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 20)
      eventPlayer.juno_transfer_pos = eventPlayer.juno_rift1_destination
      eventPlayer.startCamera(updateEveryFrame(raycast(eventPlayer.juno_transfer_pos, eventPlayer.juno_transfer_pos + eventPlayer.getFacingDirection() * -5, null, eventPlayer, true).getHitPosition()), eventPlayer.juno_transfer_pos)
      chaseAtRate(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift2_destination, 20)
      createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, getPlayers(eventPlayer.getTeam()), updateEveryFrame(eventPlayer.juno_transfer_pos), directionTowards(eventPlayer.juno_rift2_destination, eventPlayer.juno_rift1_destination), 0.035, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
      eventPlayer.juno_rift1_fx[4] = getLastCreatedEntity()
      waitUntil(distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift1_destination) <= distance(eventPlayer.juno_transfer_pos, eventPlayer.juno_rift2_destination), 10)
      eventPlayer.stopForcingPosition()
      eventPlayer.teleport(eventPlayer.juno_rift2_destination)
      eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
      wait(distance(eventPlayer.juno_rift1_destination, eventPlayer.juno_rift2_destination) / 20)
      eventPlayer.stopCamera()
      wait(0.1)
      eventPlayer.clearStatusEffect(Status.FROZEN)
      eventPlayer.clearStatusEffect(Status.PHASED_OUT)
      eventPlayer.setInvisibility(Invis.NONE)
      playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_REAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift2_destination, 1)
      playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_DISAPPEAR, eventPlayer.getTeam(), eventPlayer.juno_rift1_destination, 1)
      destroyEffect(eventPlayer.juno_rift1_fx[4])
      eventPlayer.stopForcingPosition()
