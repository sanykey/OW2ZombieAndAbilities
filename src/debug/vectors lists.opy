#!mainFile "../main.opy"

globalvar debugVectorsLists = [
  ["Hero buy spots", VL_BUY_HERO_SPOTS_OFFSET, VL_BUY_HERO_SPOTS_LEN],
  ["Bot sniper spots", VL_BOT_SNIPER_SPOTS_OFFSET, VL_BOT_SNIPER_SPOTS_LEN],
]
globalvar debugVectorsListsEffects = []
globalvar debugVectorsListIndex
globalvar debugVectorsIndex = VL_BUY_HERO_SPOTS_OFFSET
globalvar debugCustomVectors = []
globalvar debugCustomVectorsEffects = []
globalvar debugCustomVectorIndex = 0
globalvar debugVectorEditMode = 0 # 0 = Main, 1 = Custom
globalvar debugSphereRadius = 0
globalvar debugSphereEffect

globalvar debugShowVectors
globalvar debugShowZones
globalvar debugShowZoneEffects

rule "[debug] add VectorsLists debug mode":
  debugModesArr.append("VectorsLists")

rule "[debug] init VectorsLists debug mode":
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "VectorsLists"

  wait(0.1)

  debugSelectedAction = 0
  debugMaxAction = 14

  hudSubheader(
    localPlayerVisibilityForDevelopers(),
    "{}
    {}List type: {} <fg84c951FF>{}</fg> {}</fg>
    {}Changing mode: {} <fg84c951FF>{}</fg> {}</fg>
    {}Vector (teleport): {} <fg84c951FF>{}: {}</fg> {}</fg>
    {}Create vector</fg>
    {}Custom Vector (teleport): {} <fg84c951FF>{}: {}</fg> {}</fg>
    {}Move X: {} <fg84c951FF>{}</fg> {}</fg>
    {}Move Z: {} <fg84c951FF>{}</fg> {}</fg>
    {}Move Y: {} <fg84c951FF>{}</fg> {}</fg>
    {}Sphere radius: {} <fg84c951FF>{}</fg> {}</fg>
    {}Show vectors: <fg84c951FF>{}</fg></fg>
    {}Show zones</fg>
    {}Save current pos to log</fg>
    {}Save vector to log</fg>
    {}Save custom vectors to log</fg>
    --------------------
    List offset: {}
    Last vect: {}
    List len: {}
    Distance to vect: {}
    Distance to custom vect: {}
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
      "Main" if debugVectorEditMode == 0 else "Custom",
      "→" if debugSelectedAction == 2 else "",

      debugSelectedActionText(3),
      "←" if debugSelectedAction == 3 else "",
      debugVectorsIndex,
      vectList[debugVectorsIndex],
      "→" if debugSelectedAction == 3 else "",

      debugSelectedActionText(4),

      debugSelectedActionText(5),
      "←" if debugSelectedAction == 5 else "",
      debugCustomVectorIndex if len(debugCustomVectors) else "none",
      debugCustomVectors[debugCustomVectorIndex] if len(debugCustomVectors) else "none",
      "→" if debugSelectedAction == 5 else "",

      # Move X
      debugSelectedActionText(6),
      "←" if debugSelectedAction == 6 else "",
      (
        vectList[debugVectorsIndex].x
        if debugVectorEditMode == 0
        else debugCustomVectors[debugCustomVectorIndex].x
        if len(debugCustomVectors)
        else "none"
      ),
      "→" if debugSelectedAction == 6 else "",

      # Move Z
      debugSelectedActionText(7),
      "←" if debugSelectedAction == 7 else "",
      (
        vectList[debugVectorsIndex].z
        if debugVectorEditMode == 0
        else debugCustomVectors[debugCustomVectorIndex].z
        if len(debugCustomVectors)
        else "none"
      ),
      "→" if debugSelectedAction == 7 else "",

      # Move Y
      debugSelectedActionText(8),
      "←" if debugSelectedAction == 8 else "",
      (
        vectList[debugVectorsIndex].y
        if debugVectorEditMode == 0
        else debugCustomVectors[debugCustomVectorIndex].y
        if len(debugCustomVectors)
        else "none"
      ),
      "→" if debugSelectedAction == 8 else "",

      debugSelectedActionText(9),
      "←" if debugSelectedAction == 9 else "",
      debugSphereRadius,
      "→" if debugSelectedAction == 9 else "",

      debugSelectedActionText(10),
      debugShowVectors,
      debugSelectedActionText(11),
      debugSelectedActionText(12),
      debugSelectedActionText(13),
      debugSelectedActionText(14),
      debugVectorsLists[debugVectorsListIndex][true],
      debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1,
      debugVectorsLists[debugVectorsListIndex][2],
      distance(localPlayer, vectList[debugVectorsIndex]),
      distance(localPlayer, debugCustomVectors[debugCustomVectorIndex]) if len(debugCustomVectors) else "none",
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
  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.AQUA,
    (
      vectList[debugVectorsIndex]
      if debugVectorEditMode == 0 or not len(debugCustomVectors)
      else debugCustomVectors[debugCustomVectorIndex]
    ),
    debugSphereRadius,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugSphereEffect = getLastCreatedEntity()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)
  destroyEffect(debugSphereEffect)


def DebugCreateVectorsTextsSub():
  @Name "SUB: [debug] Show vectors texts"
  debugVectorsListsEffects = []
  debugCustomVectorsEffects = []
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

  for I in range(0, len(debugCustomVectors)):
    createInWorldText(
      localPlayerVisibilityForDevelopers(),
      "{}".format(I),
      debugCustomVectors[I],
      1,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_AND_COLOR,
      Color.RED if debugCustomVectorIndex == evalOnce(I) else Color.AQUA
    )
    debugCustomVectorsEffects.append(getLastCreatedText())
  
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
  for I in range(0, len(debugCustomVectorsEffects)):
    destroyInWorldText(debugCustomVectorsEffects[I])

def DebugRefreshMainVectTextSub():
  @Name "SUB: [debug] Refresh selected main vector text"
  if not debugShowVectors:
    return

  eventPlayer.tmp0 = debugVectorsIndex - debugVectorsLists[debugVectorsListIndex][true]
  if eventPlayer.tmp0 < 0 or eventPlayer.tmp0 >= len(debugVectorsListsEffects):
    return

  destroyInWorldText(debugVectorsListsEffects[eventPlayer.tmp0])
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "{}".format(debugVectorsIndex),
    vectList[debugVectorsIndex],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_AND_COLOR,
    Color.ORANGE if debugVectorsIndex == evalOnce(debugVectorsIndex) else Color.WHITE
  )
  debugVectorsListsEffects[eventPlayer.tmp0] = getLastCreatedText()

def DebugRefreshCustomVectTextSub():
  @Name "SUB: [debug] Refresh selected custom vector text"
  if not debugShowVectors:
    return
  if debugCustomVectorIndex < 0 or debugCustomVectorIndex >= len(debugCustomVectorsEffects):
    return
  if debugCustomVectorIndex >= len(debugCustomVectors):
    return

  destroyInWorldText(debugCustomVectorsEffects[debugCustomVectorIndex])
  createInWorldText(
    localPlayerVisibilityForDevelopers(),
    "{}".format(debugCustomVectorIndex),
    debugCustomVectors[debugCustomVectorIndex],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_AND_COLOR,
    Color.BLUE if debugCustomVectorIndex == evalOnce(debugCustomVectorIndex) else Color.AQUA
  )
  debugCustomVectorsEffects[debugCustomVectorIndex] = getLastCreatedText()

rule "[debug] Activate selected action for VectorsLists mode":
  ConditionForActivateSelectedAction("VectorsLists")

  if debugSelectedAction == 3: # [debug] teleport to selected vector
    eventPlayer.teleport(vectList[debugVectorsIndex])
  elif debugSelectedAction == 4: # [debug] create custom vector from raycast hit
    debugCustomVectors.append(
      raycast(
        eventPlayer.getEyePosition(),
        eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1000,
        getAllPlayers(),
        eventPlayer,
        true
      ).getHitPosition()
    )
    debugCustomVectorIndex = len(debugCustomVectors) - 1
    if debugShowVectors:
      DebugDeleteVectorsTextsSub()
      DebugCreateVectorsTextsSub()
  elif debugSelectedAction == 5: # [debug] teleport to selected custom vector
    if len(debugCustomVectors):
      eventPlayer.teleport(debugCustomVectors[debugCustomVectorIndex])
  elif debugSelectedAction == 10: # [debug] disable/enable vectors
    if not debugShowVectors:
      debugShowVectors = true
      DebugCreateVectorsTextsSub()
    else:
      debugShowVectors = false
      DebugDeleteVectorsTextsSub()
  elif debugSelectedAction == 11: # [debug] disable/enable zones
    debugShowZones = not debugShowZones
  elif debugSelectedAction == 12: # [debug] Save current pos to log
    logToInspector(
      "pos: {}\neye pos: {}\nfacing dir: {}".format(
        eventPlayer.getPosition(),
        eventPlayer.getEyePosition(),
        eventPlayer.getFacingDirection()
      )
    )
  elif debugSelectedAction == 13: # [debug] Save selected main vector to log
    logToInspector(
      "main vect [{}]: {}".format(
        debugVectorsIndex,
        vectList[debugVectorsIndex]
      )
    )
  elif debugSelectedAction == 14: # [debug] Save all custom vectors to log
    if not len(debugCustomVectors):
      logToInspector("custom vectors list is empty")
    else:
      eventPlayer.tmp0 = ""
      for I in range(0, len(debugCustomVectors)):
        eventPlayer.tmp0 = f"{eventPlayer.tmp0}- {debugCustomVectors[I]}\n"
      logToInspector(eventPlayer.tmp0)

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

  if debugSelectedAction == 2: # next vector edit mode
    if debugVectorEditMode >= 1:
      debugVectorEditMode = 0
    else:
      debugVectorEditMode++

  if debugSelectedAction == 3: # next vector
    if debugVectorsIndex >= debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1:
      debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true]
    else:
      debugVectorsIndex++
  
  if debugSelectedAction == 5: # next custom vector
    if len(debugCustomVectors):
      if debugCustomVectorIndex >= len(debugCustomVectors) - 1:
        debugCustomVectorIndex = 0
      else:
        debugCustomVectorIndex++

  if debugSelectedAction == 6: # move X+
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x + incWithModificators(0.01),
        vectList[debugVectorsIndex].y,
        vectList[debugVectorsIndex].z
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x + incWithModificators(0.01),
        debugCustomVectors[debugCustomVectorIndex].y,
        debugCustomVectors[debugCustomVectorIndex].z
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 7: # move Z+
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x,
        vectList[debugVectorsIndex].y,
        vectList[debugVectorsIndex].z + incWithModificators(0.01)
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x,
        debugCustomVectors[debugCustomVectorIndex].y,
        debugCustomVectors[debugCustomVectorIndex].z + incWithModificators(0.01)
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 8: # move Y+
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x,
        vectList[debugVectorsIndex].y + incWithModificators(0.01),
        vectList[debugVectorsIndex].z
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x,
        debugCustomVectors[debugCustomVectorIndex].y + incWithModificators(0.01),
        debugCustomVectors[debugCustomVectorIndex].z
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 9: # sphere radius+
    debugSphereRadius += incWithModificators(0.01)

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

  if debugSelectedAction == 2: # prev vector edit mode
    if debugVectorEditMode <= 0:
      debugVectorEditMode = 1
    else:
      debugVectorEditMode--

  if debugSelectedAction == 3: # prev vector
    if debugVectorsIndex <= debugVectorsLists[debugVectorsListIndex][true]:
      debugVectorsIndex = debugVectorsLists[debugVectorsListIndex][true] + debugVectorsLists[debugVectorsListIndex][2] - 1
    else:
      debugVectorsIndex--

  if debugSelectedAction == 5: # prev custom vector
    if len(debugCustomVectors):
      if debugCustomVectorIndex <= 0:
        debugCustomVectorIndex = len(debugCustomVectors) - 1
      else:
        debugCustomVectorIndex--

  if debugSelectedAction == 6: # move X-
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x - incWithModificators(0.01),
        vectList[debugVectorsIndex].y,
        vectList[debugVectorsIndex].z
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x - incWithModificators(0.01),
        debugCustomVectors[debugCustomVectorIndex].y,
        debugCustomVectors[debugCustomVectorIndex].z
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 7: # move Z-
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x,
        vectList[debugVectorsIndex].y,
        vectList[debugVectorsIndex].z - incWithModificators(0.01)
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x,
        debugCustomVectors[debugCustomVectorIndex].y,
        debugCustomVectors[debugCustomVectorIndex].z - incWithModificators(0.01)
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 8: # move Y-
    if debugVectorEditMode == 0:
      vectList[debugVectorsIndex] = vect(
        vectList[debugVectorsIndex].x,
        vectList[debugVectorsIndex].y - incWithModificators(0.01),
        vectList[debugVectorsIndex].z
      )
      DebugRefreshMainVectTextSub()
    elif len(debugCustomVectors):
      debugCustomVectors[debugCustomVectorIndex] = vect(
        debugCustomVectors[debugCustomVectorIndex].x,
        debugCustomVectors[debugCustomVectorIndex].y - incWithModificators(0.01),
        debugCustomVectors[debugCustomVectorIndex].z
      )
      DebugRefreshCustomVectTextSub()

  if debugSelectedAction == 9: # sphere radius-
    debugSphereRadius -= incWithModificators(0.01)
    if debugSphereRadius < 0:
      debugSphereRadius = 0

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
