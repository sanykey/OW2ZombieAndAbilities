#!mainFile "../main.opy"

rule "[debug] init positions measuring effects":
  # positions and distance info for hostplayer and debug vects
  hudSubtext(
    hostPlayer,
    "pos: {}\neye pos: {}".format(hostPlayer.getPosition(), hostPlayer.getEyePosition()),
    HudPosition.RIGHT,
    -10,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )
  hudSubtext(
    hostPlayer,
    "distance between points: {0}\nhorizontal distance: {1}\nvertical distance: {2}".format(
      distance(debugPos1, debugPos2), magnitude(vect(1, 0, 1) * (debugPos1 - debugPos2)), abs(debugPos1.y - debugPos2.y)
    ),
    HudPosition.RIGHT,
    -8,
    Color.AQUA,
    HudReeval.VISIBILITY_AND_STRING
  )
  hudSubtext(
    hostPlayer,
    "midpoint: {0}".format((debugPos1 + debugPos2) / 2),
    HudPosition.RIGHT,
    -7,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )

  createInWorldText(localPlayer, "1: {}".format(debugPos1), debugPos1, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer, Effect.SPHERE, Color.SKY_BLUE, debugPos1, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(localPlayer, "2: {}".format(debugPos2), debugPos2, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer, Effect.SPHERE, Color.ROSE, debugPos2, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createBeam(localPlayer, Beam.TORBJORN_TURRET_SIGHT, debugPos2, debugPos1, Color.WHITE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

  createEffect(localPlayer, Effect.SPHERE, Color.LIME_GREEN, debugPos3, debugSize3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(localPlayer, "Sphere: {}, size: {}".format(debugPos3, debugSize3), debugPos3, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.LIME_GREEN)

rule "[debug] set ruler pos1":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  
  debugPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
  playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos1, 100)
  playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos1, true)


rule "[debug] set ruler pos2":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  
  debugPos2 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
  playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos2, 100)
  playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos2, true)


rule "[debug] set shpere pos":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2)
  
  debugPos3 = eventPlayer.getPosition()
  playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos3, 100)
  playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos3, true)

rule "[debug] set shpere size+":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_1)
  
  debugSize3 +=1
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)

rule "[debug] set shpere size-":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.JUMP)
  
  debugSize3 -=1
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)