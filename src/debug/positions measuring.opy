#!mainFile "../main.opy"


globalvar debugPos1 = vect(-23.86, 8.08, -89.854)
globalvar debugPos2
globalvar debugPos3
globalvar debugSize = 0

rule "[debug] init positions measuring effects":
  # positions and distance info for hostplayer and debug vects

  hudSubheader(
    localPlayer if localPlayer.developer else null,
    "debug mode: {}".format("Place measure tools" if debugMode == 0 else "Move measurement sphere"),
    HudPosition.RIGHT,
    -11,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )


  hudSubheader(
    localPlayer if localPlayer.developer else null,
    "pos: {}\neye pos: {}\nfacing dir: {}".format(localPlayer.getPosition(), localPlayer.getEyePosition(), localPlayer.getFacingDirection()),
    HudPosition.RIGHT,
    -10,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )

  hudSubheader(
    localPlayer if localPlayer.developer else null,
    "distance between points: {}\nhorizontal distance: {}\nvertical distance: {}\nmidpoint: {}".format(
      distance(debugPos1, debugPos2), magnitude(vect(1, 0, 1) * (debugPos1 - debugPos2)), abs(debugPos1.y - debugPos2.y), (debugPos1 + debugPos2) / 2
    ),
    HudPosition.RIGHT,
    -8,
    Color.AQUA,
    HudReeval.VISIBILITY_AND_STRING
  )

  createInWorldText(localPlayer if localPlayer.developer else null, "1: {}, size: {}".format(debugPos1, debugSize), debugPos1, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer if localPlayer.developer else null, Effect.SPHERE, Color.SKY_BLUE, debugPos1, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(localPlayer if localPlayer.developer else null, "2: {}".format(debugPos2), debugPos2, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer if localPlayer.developer else null, Effect.SPHERE, Color.ROSE, debugPos2, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createBeam(localPlayer if localPlayer.developer else null, Beam.TORBJORN_TURRET_SIGHT, debugPos2, debugPos1, Color.WHITE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(localPlayer if localPlayer.developer else null, Effect.SPHERE, Color.LIME_GREEN, debugPos1, debugSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

  createBeam(localPlayer if localPlayer.developer else null, Beam.TORBJORN_TURRET_SIGHT, debugPos1 + Vector.BACKWARD * 50, debugPos1 + Vector.FORWARD * 50, Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createBeam(localPlayer if localPlayer.developer else null, Beam.TORBJORN_TURRET_SIGHT, debugPos1 + Vector.RIGHT * 50, debugPos1 + Vector.LEFT * 50, Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createBeam(localPlayer if localPlayer.developer else null, Beam.TORBJORN_TURRET_SIGHT, debugPos1 + Vector.DOWN * 50, debugPos1 + Vector.UP * 50, Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(localPlayer if localPlayer.developer else null, "+z", debugPos1 + Vector.FORWARD * 2, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION)
  createInWorldText(localPlayer if localPlayer.developer else null, "+x", debugPos1 + Vector.LEFT * 2, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION)
  createInWorldText(localPlayer if localPlayer.developer else null, "+y", debugPos1 + Vector.UP * 2, 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION)

rule "[debug] Interact":
  @Event eachPlayer
  @Condition eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and (
    eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) 
    or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) 
    or eventPlayer.isHoldingButton(Button.RELOAD) 
    or eventPlayer.isHoldingButton(Button.JUMP) 
    or eventPlayer.isHoldingButton(Button.CROUCH)
    or eventPlayer.isHoldingButton(Button.MELEE)
    or eventPlayer.isHoldingButton(Button.ABILITY_1)
    or eventPlayer.isHoldingButton(Button.ABILITY_2)
  )

  if eventPlayer.isHoldingButton(Button.ABILITY_2):
    debugMode += 1
    if debugMode > 1:
      debugMode = 0
    return
  
  if debugMode == 0: # Place measure tools
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
      debugPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
      playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos1, 100)
      playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos1, true)
    elif eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
      debugPos2 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
      playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos2, 100)
      playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos2, true)
    elif eventPlayer.isHoldingButton(Button.ABILITY_1):
      debugPos1 = eventPlayer.getPosition()
      playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos1, 100)
      playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos1, true)
    elif eventPlayer.isHoldingButton(Button.RELOAD):
      debugSize +=0.5
      playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
    elif eventPlayer.isHoldingButton(Button.MELEE):
      debugSize -=0.5
      playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer, 100)
  if debugMode == 1: # Move measurement sphere
    if eventPlayer.isHoldingButton(Button.JUMP):
      debugPos1 = vect(debugPos1.x, debugPos1.y + 0.1, debugPos1.z)
    if eventPlayer.isHoldingButton(Button.CROUCH):
      debugPos1 = vect(debugPos1.x, debugPos1.y - 0.1, debugPos1.z)
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
      debugPos1 = vect(debugPos1.x + 0.1, debugPos1.y, debugPos1.z)
    if eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
      debugPos1 = vect(debugPos1.x - 0.1, debugPos1.y, debugPos1.z)
    if eventPlayer.isHoldingButton(Button.RELOAD):
      debugPos1 = vect(debugPos1.x, debugPos1.y, debugPos1.z + 0.1)
    if eventPlayer.isHoldingButton(Button.MELEE):
      debugPos1 = vect(debugPos1.x, debugPos1.y, debugPos1.z - 0.1)