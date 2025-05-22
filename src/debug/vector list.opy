#!mainFile "../main.opy"

rule "[debug] Create debbugging vectors list":
  debugVectsArr = []

  ####################################
  # change here:
  
  
  for I in range(VL_BUY_HERO_SPOTS_OFFSET, VL_BUY_HERO_SPOTS_OFFSET + VL_BUY_HERO_SPOTS_LEN):
    debugVectsArr[I - VL_BUY_HERO_SPOTS_OFFSET] = vectList[I]
  
  
    # end change here:
  #####################################


  createBeam(
    getPlayersInSlot(0, Team.1),
    Beam.TORBJORN_TURRET_SIGHT,
    getPlayersInSlot(0, Team.1).getEyePosition() + vect(0, -0.25, 0),
    debugVectsArr[debugCurrentVectNum], 
    Color.TEAM_1,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )

  createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, debugVectsArr[debugCurrentVectNum], 1.7, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

  createEffect(
    getPlayersInSlot(0, Team.1),
    Effect.SPHERE,
    Color.GREEN,
    debugVectsArr[debugCurrentVectNum],
    1,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )

  hudHeader(
    getPlayersInSlot(0, Team.1),
    "vect {0}: {1} ({2})".format(debugCurrentVectNum, debugVectsArr[debugCurrentVectNum], distance(getPlayersInSlot(0, Team.1), debugVectsArr[debugCurrentVectNum])),
    HudPosition.TOP,
    0,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING,
    SpecVisibility.ALWAYS
  )

rule "[debug] Show next vector":
  @Event eachPlayer
  @Team 1
  @Slot 0
  @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  if debugCurrentVectNum >= len(debugVectsArr) - 1:
    debugCurrentVectNum = 0
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
  else:
    debugCurrentVectNum += 1
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
  
rule "[debug] Show prev vector":
  @Event eachPlayer
  @Team 1
  @Slot 0
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

  if debugCurrentVectNum <= 0:
    debugCurrentVectNum = len(debugVectsArr) - 1
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
  else:
    debugCurrentVectNum -= 1
    smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))