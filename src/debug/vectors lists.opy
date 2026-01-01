#!mainFile "../main.opy"

globalvar debugVectorsLists = [
  ["Hero buy spots", VL_BUY_HERO_SPOTS_OFFSET, VL_BUY_HERO_SPOTS_LEN],
  ["Bot spawn points", VL_SPAWN_POINTS_A_OFFSET, VL_SPAWN_POINTS_LEN],
  ["Bot sniper spots", VL_BOT_SNIPER_SPOTS_OFFSET, VL_BOT_SNIPER_SPOTS_LEN],
]
globalvar debugVectorsListsEffects
globalvar debugVectorsListIndex
globalvar debugVectorsIndex = VL_BUY_HERO_SPOTS_OFFSET

globalvar debugShowVectors
globalvar debugShowZones
globalvar debugShowZoneEffects

rule "[debug] add VectorsLists debug mode":
  debugModesArr.append("VectorsLists")

rule "[debug] init VectorsLists debug mode":
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "VectorsLists"

  wait(0.1)

  debugSelectedAction = 0
  debugMaxAction = 8

  hudSubheader(
    localPlayerVisibilityForDevelopers(),
    "{}
    {}List type: {} <fg84c951FF>{}</fg> {}</fg>
    {}Vector (teleport): {} <fg84c951FF>{}: {}</fg> {}</fg>
    {}Move X: {} <fg84c951FF>{}</fg> {}</fg>
    {}Move Z: {} <fg84c951FF>{}</fg> {}</fg>
    {}Move Y: {} <fg84c951FF>{}</fg> {}</fg>
    {}Show vectors: <fg84c951FF>{}</fg></fg>
    {}Show zones</fg>
    {}Save current pos to log</fg>
    --------------------
    List offset: {}
    Last vect: {}
    List len: {}
    Distance to vect: {}
    Pos: <fg84c951FF>{}</fg>
    Eye pos: <fg84c951FF>{}</fg>
    Facing dir: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("VectorsLists"),
      debugSelectedActionText(1),
      "←" if debugSelectedAction == 1 else "",
      debugVectorsLists[debugVectorsListIndex][false],
      "→" if debugSelectedAction == 1 else "",

      debugSelectedActionText(2),
      "←" if debugSelectedAction == 2 else "",
      debugVectorsIndex,
      vectList[debugVectorsIndex],
      "→" if debugSelectedAction == 2 else "",

      # Move X
      debugSelectedActionText(3),
      "←" if debugSelectedAction == 3 else "",
      vectList[debugVectorsIndex].x,
      "→" if debugSelectedAction == 3 else "",

      # Move Z
      debugSelectedActionText(4),
      "←" if debugSelectedAction == 4 else "",
      vectList[debugVectorsIndex].z,
      "→" if debugSelectedAction == 4 else "",

      # Move Y
      debugSelectedActionText(5),
      "←" if debugSelectedAction == 5 else "",
      vectList[debugVectorsIndex].y,
      "→" if debugSelectedAction == 5 else "",

      debugSelectedActionText(6),
      debugShowVectors,
      debugSelectedActionText(7),
      debugSelectedActionText(8),
      debugVectorsLists[debugVectorsListIndex][true],
      debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1,
      debugVectorsLists[debugVectorsListIndex][2],
      distance(localPlayer, vectList[debugVectorsIndex]),
      localPlayer.getPosition(),
      localPlayer.getEyePosition(),
      localPlayer.getFacingDirection()
    ),
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)


def DebugCreateVectorsTextsSub():
  @Name "SUB: [debug] Show vectors texts"
  debugVectorsListsEffects = []
  for I in range(debugVectorsLists[debugVectorsListIndex][true], debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2]):
    createInWorldText(
      localPlayerVisibilityForDevelopers(),
      "{}".format(I),
      vectList[I],
      1,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_AND_COLOR,
      Color.ORANGE if debugVectorsIndex == evalOnce(I) else Color.WHITE
    )
    debugVectorsListsEffects.append(getLastCreatedText())
  
  # createBeam(
  #   localPlayerVisibilityForDevelopers(),
  #   Beam.TORBJORN_TURRET_SIGHT,
  #   hostPlayer.getEyePosition() + vect(0, -0.25, 0),
  #   vectList[debugVectorsIndex], 
  #   Color.TEAM_1,
  #   EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  # )

def DebugDeleteVectorsTextsSub():
  @Name "SUB: [debug] Delete Vectors Texts"
  for I in range(0, len(debugVectorsListsEffects)):
    destroyInWorldText(debugVectorsListsEffects[I])

rule "[debug] Activate selected action for VectorsLists mode":
  ConditionForActivateSelectedAction("VectorsLists")

  if debugSelectedAction == 2: # [debug] teleport to selected vector
    eventPlayer.teleport(vectList[debugVectorsIndex])
  elif debugSelectedAction == 6: # [debug] disable/enable vectors
    if not debugShowVectors:
      debugShowVectors = true
      DebugCreateVectorsTextsSub()
    else:
      debugShowVectors = false
      DebugDeleteVectorsTextsSub()
  elif debugSelectedAction == 7: # [debug] disable/enable zones
    debugShowZones = not debugShowZones
  elif debugSelectedAction == 8: # [debug] Save current pos to log
    logToInspector(
      "pos: {}\neye pos: {}\nfacing dir: {}".format(
        eventPlayer.getPosition(),
        eventPlayer.getEyePosition(),
        eventPlayer.getFacingDirection()
      )
    )

rule "[debug] (RIGHT) VectorsLists":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "VectorsLists"
  
  if debugSelectedAction == 1: # next vector list
    DebugDeleteVectorsTextsSub()
    if debugVectorsListIndex >= len(debugVectorsLists) - 1:
      debugVectorsListIndex = 0
    else:
      debugVectorsListIndex++
    debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true]
    if debugShowVectors:
      DebugCreateVectorsTextsSub()

  if debugSelectedAction == 2: # next vector
    if debugVectorsIndex >= debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1:
      debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true]
    else:
      debugVectorsIndex++

rule "[debug] (LEFT) VectorsLists":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "VectorsLists"
  
  if debugSelectedAction == 1: # prev vector list
    DebugDeleteVectorsTextsSub()
    if debugVectorsListIndex <= 0:
      debugVectorsListIndex = len(debugVectorsLists) - 1
    else:
      debugVectorsListIndex--
    debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true]
    if debugShowVectors:
      DebugCreateVectorsTextsSub()

  if debugSelectedAction == 2: # prev vector
    if debugVectorsIndex <= debugVectorsLists[debugVectorsListIndex][true]:
      debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1
    else:
      debugVectorsIndex--

rule "[debug] Clear effects for ShowZones":
  @Condition not debugShowZones
  @Condition debugShowZoneEffects

  for I in range(0, len(debugShowZoneEffects), 2):
    destroyEffect(debugShowZoneEffects[I])
    destroyInWorldText(debugShowZoneEffects[I + 1])


rule "[debug] Create effects for ShowZones":
  @Condition debugShowZones
  debugShowZoneEffects = []

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.AQUA,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_A],
    ZONE_A_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone A\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_A]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_A],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.AQUA
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.GREEN,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_B],
    ZONE_B_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone B\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_B]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_B],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GREEN
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.LIGHT_RED,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_C],
    ZONE_C_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone C\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_C]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_C],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.LIGHT_RED
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.YELLOW,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_D],
    ZONE_D_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone D\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_D]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_D],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.YELLOW
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.GRAY,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_E],
    ZONE_E_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone E\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_E]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_E],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GRAY
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.PURPLE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_F],
    ZONE_F_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone F\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_F]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_F],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.PURPLE
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.ORANGE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_G],
    ZONE_G_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone G\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_G]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_G],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.ORANGE
  )
  debugShowZoneEffects.append(getLastCreatedText())


  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.BLUE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_H],
    ZONE_H_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone H\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_H]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_H],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.BLUE
  )
  debugShowZoneEffects.append(getLastCreatedText())

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.RED,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_I],
    ZONE_I_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  debugShowZoneEffects.append(getLastCreatedEntity())
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "Zone I\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_I]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_I],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.RED
  )
  debugShowZoneEffects.append(getLastCreatedText())