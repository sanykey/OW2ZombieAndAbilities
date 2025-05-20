#!mainFile "main.opy"

rule "[debug] User init":
  # show ServerLoad info
  hudSubheader(
    localPlayer if localPlayer == hostPlayer else false,
    "Server load: {} / AVG: {}/ Max: {}
      Entities: {}
    ".format(
      getServerLoad(),
      getAverageServerLoad(),
      getPeakServerLoad(),
      getNumberOfEntityIds()
    ),
    HudPosition.RIGHT,
    -5,
    rgb(255, 280 - getAverageServerLoad(), 0),
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

  # positions and distance info for hostplayer and debug vects
  hudSubtext(
    hostPlayer if debugIsNoclip else null,
    "pos: {}".format(hostPlayer.getPosition()),
    HudPosition.RIGHT,
    -10,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )
  hudSubtext(
    hostPlayer if debugIsNoclip else null,
    "eye pos: {}".format(hostPlayer.getEyePosition()),
    HudPosition.RIGHT,
    -9,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )
  hudSubtext(
    hostPlayer if debugIsNoclip else null,
    "distance between points: {0}\nhorizontal distance: {1}\nvertical distance: {2}".format(
      distance(debugPos1, debugPos2), magnitude(vect(1, 0, 1) * (debugPos1 - debugPos2)), abs(debugPos1.y - debugPos2.y)
    ),
    HudPosition.RIGHT,
    -8,
    Color.AQUA,
    HudReeval.VISIBILITY_AND_STRING
  )
  hudSubtext(
    hostPlayer if debugIsNoclip else null,
    "midpoint: {0}".format((debugPos1 + debugPos2) / 2),
    HudPosition.RIGHT,
    -7,
    Color.ROSE,
    HudReeval.VISIBILITY_AND_STRING
  )

  createInWorldText(localPlayer if debugIsNoclip else null, "1: {}".format(debugPos1), debugPos1, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer if debugIsNoclip else null, Effect.SPHERE, Color.SKY_BLUE, debugPos1, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(localPlayer if debugIsNoclip else null, "2: {}".format(debugPos2), debugPos2, 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING)
  createEffect(localPlayer if debugIsNoclip else null, Effect.SPHERE, Color.ROSE, debugPos2, 0.05, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createBeam(localPlayer if debugIsNoclip else null, Beam.TORBJORN_TURRET_SIGHT, debugPos2, debugPos1, Color.WHITE, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "[debug] toggle noclip":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ULTIMATE)
  
  debugIsNoclip = not debugIsNoclip
  if not debugIsNoclip:
    eventPlayer.clearStatusEffect(Status.INVINCIBLE)
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.setUltCharge(0)
    kill(eventPlayer)
    eventPlayer.resurrect()
    eventPlayer.setGravity(100)
    wait()
    eventPlayer.downedStartTime = false
  else:
    eventPlayer.startForcingHero(Hero.MERCY)
    wait()
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INFINITY)
    eventPlayer.setUltCharge(100)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.setGravity(0)

rule "[debug] refresh noclip":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition debugIsNoclip != false
  @Condition eventPlayer.isUsingUltimate() == false
  
  eventPlayer.setUltCharge(100)
  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.4)
  eventPlayer.setStatusEffect(null, Status.HACKED, 0.05)


rule "[debug] Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    for I in range(wSettingsMaxZombieBots):
      destroyDummy(Team.2, I)
    smallMessage(eventPlayer, "Bots disabled (ctrl + shift + interact)")
  else:
    isBotsDisabled = false
    smallMessage(eventPlayer, "Bots enabled (ctrl + shift + interact)")


rule "set pos1":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition debugIsNoclip
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
  
  debugPos1 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
  playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos1, 100)
  playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos1, true)


rule "set pos2":
  @Event eachPlayer
  @Condition eventPlayer == hostPlayer
  @Condition debugIsNoclip
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
  
  debugPos2 = raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000, getAllPlayers(), eventPlayer, true).getHitPosition()
  playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATOR_REAPPEAR_SOUND, Color.TEAM_1, debugPos2, 100)
  playEffect(eventPlayer, DynamicEffect.SIGMA_HYPERSPHERE_IMPLOSION, Color.TEAM_1, debugPos2, true)