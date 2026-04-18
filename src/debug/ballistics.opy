#!mainFile "../main.opy"
globalvar debugProjectile
globalvar debugButtons = [Button.ABILITY_1, Button.ABILITY_2, Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE]
globalvar debugBallisticsSpots = []
globalvar debugBallisticsSpotIndex = 0
globalvar debugBallisticsTrajectoryEffects = []
globalvar debugBallisticsPresets = []
globalvar debugBallisticsPresetIndex = 0
globalvar debugBallisticsCameraEnabled = false
globalvar debugBallisticsCameraOffset = vect(0, 5, -5)
globalvar debugBallisticsState = []
globalvar debugBallisticsFlyingT = 0

enum DePE: # DebugProjectileE
  VELOCITY
  POSITION
  SHOOT_DELAY
  START_ANGLE_CORRECTION
  START_SPEED
  GRAVITY
  TIMEOUT
  TRIGGER_INDEX
  EFFECT
  VERTICALBEAM
  VICTUM
  LANDING_POSITION
  LANDING_EFFECT
  MOVING_EFFECT
  SHOW_TRAJECTORY
  STEP_TIME
  MAX_TIME
  COLLISION_TIME
  LAST_HIT_POSITION
  LAST_HIT_EFFECT
  SPOT_MARKER_EFFECT

enum DePSD: # DebugProjectileShotDataE
  HERO
  POSITION
  FACING
  TRIGGER_INDEX
  SHOOT_DELAY
  START_SPEED
  START_ANGLE_CORRECTION
  GRAVITY
  SHOW_TRAJECTORY
  STEP_TIME
  MAX_TIME

enum DePrT: # DebugProjectileTriggerE
  ABILITY_1
  ABILITY_2
  PRIMARY_FIRE
  SECONDARY_FIRE
  ULTIMATE

enum DeBPrE: # DebugBallisticsPresetE
  HERO
  TRIGGER_INDEX
  START_SPEED
  GRAVITY
  START_ANGLE_CORRECTION
  SHOOT_DELAY

enum DeBS: # DebugBallisticsStateE
  EYE_POS
  HORIZONTAL_DIR
  LAUNCH_ANGLE
  VX
  VY
  TIME
  SEGMENT_START
  SEGMENT_END
  IMPACT_POS
  DRAW_TRAJECTORY
  CAMERA_ENABLED_LOCAL
  CAMERA_POS


def ClearBallisticsEffectsSub():
  @Name "Sub: Clear Ballistics Effects"

  destroyEffect(debugBallisticsTrajectoryEffects)
  debugBallisticsTrajectoryEffects = []

  if debugProjectile[DePE.MOVING_EFFECT] != null:
    destroyEffect(debugProjectile[DePE.MOVING_EFFECT])
    debugProjectile[DePE.MOVING_EFFECT] = null

def PredictBallisticsSub():
  @Name "Sub: Predict Ballistics"

  debugBallisticsState[DeBS.EYE_POS] = eventPlayer.getEyePosition()
  debugBallisticsState[DeBS.HORIZONTAL_DIR] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), 0)
  debugBallisticsState[DeBS.LAUNCH_ANGLE] = verticalAngleOfDirection(eventPlayer.getFacingDirection() + vect(0, debugProjectile[DePE.START_ANGLE_CORRECTION], 0)) * -1

  if debugBallisticsState[DeBS.LAUNCH_ANGLE] < -89:
    debugBallisticsState[DeBS.LAUNCH_ANGLE] = -90
  elif debugBallisticsState[DeBS.LAUNCH_ANGLE] > 89:
    debugBallisticsState[DeBS.LAUNCH_ANGLE] = 90

  debugBallisticsState[DeBS.VX] = debugProjectile[DePE.START_SPEED] * cosDeg(debugBallisticsState[DeBS.LAUNCH_ANGLE])
  debugBallisticsState[DeBS.VY] = debugProjectile[DePE.START_SPEED] * sinDeg(debugBallisticsState[DeBS.LAUNCH_ANGLE])

  debugBallisticsState[DeBS.TIME] = 0
  debugProjectile[DePE.COLLISION_TIME] = debugProjectile[DePE.MAX_TIME]
  debugProjectile[DePE.LANDING_POSITION] = debugBallisticsState[DeBS.EYE_POS]

  while debugBallisticsState[DeBS.TIME] <= debugProjectile[DePE.MAX_TIME]:
    debugBallisticsState[DeBS.SEGMENT_START] = (
      debugBallisticsState[DeBS.EYE_POS]
      + debugBallisticsState[DeBS.HORIZONTAL_DIR] * debugBallisticsState[DeBS.VX] * debugBallisticsState[DeBS.TIME]
      + Vector.UP * (debugBallisticsState[DeBS.VY] * debugBallisticsState[DeBS.TIME] - ((debugProjectile[DePE.GRAVITY] * (debugBallisticsState[DeBS.TIME] ** 2)) / 2))
    )

    debugBallisticsState[DeBS.SEGMENT_END] = (
      debugBallisticsState[DeBS.EYE_POS]
      + debugBallisticsState[DeBS.HORIZONTAL_DIR] * debugBallisticsState[DeBS.VX] * (debugBallisticsState[DeBS.TIME] + debugProjectile[DePE.STEP_TIME])
      + Vector.UP * (
        debugBallisticsState[DeBS.VY] * (debugBallisticsState[DeBS.TIME] + debugProjectile[DePE.STEP_TIME])
        - ((debugProjectile[DePE.GRAVITY] * ((debugBallisticsState[DeBS.TIME] + debugProjectile[DePE.STEP_TIME]) ** 2)) / 2)
      )
    )

    debugBallisticsState[DeBS.IMPACT_POS] = raycast(
      debugBallisticsState[DeBS.SEGMENT_START],
      debugBallisticsState[DeBS.SEGMENT_END],
      getAllPlayers(),
      eventPlayer,
      true
    ).getHitPosition()

    if debugBallisticsState[DeBS.DRAW_TRAJECTORY] and debugProjectile[DePE.SHOW_TRAJECTORY] and debugBallisticsState[DeBS.TIME] > 0:
      createBeam(
        localPlayerVisibilityForDevelopers(),
        Beam.GRAPPLE,
        evalOnce(debugBallisticsState[DeBS.SEGMENT_START]),
        evalOnce(debugBallisticsState[DeBS.IMPACT_POS]),
        Color.WHITE,
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
      )
      debugBallisticsTrajectoryEffects[len(debugBallisticsTrajectoryEffects)] = getLastCreatedEntity()

    if debugBallisticsState[DeBS.IMPACT_POS] != debugBallisticsState[DeBS.SEGMENT_END]:
      debugProjectile[DePE.LANDING_POSITION] = debugBallisticsState[DeBS.IMPACT_POS]
      debugProjectile[DePE.COLLISION_TIME] = debugBallisticsState[DeBS.TIME] + debugProjectile[DePE.STEP_TIME]
      break

    debugBallisticsState[DeBS.TIME] += debugProjectile[DePE.STEP_TIME]
    debugProjectile[DePE.LANDING_POSITION] = debugBallisticsState[DeBS.SEGMENT_END]

macro triggerNameByIndex(triggerIndex):
  (
    "ABILITY_1" if triggerIndex == DePrT.ABILITY_1
    else "ABILITY_2" if triggerIndex == DePrT.ABILITY_2
    else "PRIMARY_FIRE" if triggerIndex == DePrT.PRIMARY_FIRE
    else "SECONDARY_FIRE" if triggerIndex == DePrT.SECONDARY_FIRE
    else "ULTIMATE"
  )


rule "[debug] add Ballistics debug mode":
  debugModesArr.append("Ballistics")

  # Defaults for Junkrat Ability 1 (Concussion Mine)
  debugProjectile[DePE.SHOOT_DELAY] = 0
  debugProjectile[DePE.START_ANGLE_CORRECTION] = 0.09
  debugProjectile[DePE.START_SPEED] = 25
  debugProjectile[DePE.GRAVITY] = 20.3
  debugProjectile[DePE.SHOW_TRAJECTORY] = true
  debugProjectile[DePE.STEP_TIME] = 0.08
  debugProjectile[DePE.MAX_TIME] = 10
  debugProjectile[DePE.LANDING_POSITION] = vect(0, 0, 0)
  debugProjectile[DePE.LAST_HIT_POSITION] = vect(0, 0, 0)

  # table with known presets https://docs.google.com/spreadsheets/d/1dSwYRCoLo5utIMTa139u4AtAzrHwE9_bctpm3t3b-yc/edit?gid=0#gid=0
  debugBallisticsPresets = [
    [Hero.JUNKRAT, DePrT.ABILITY_1, 25, 20.3, 0.09, 0],
    [Hero.JUNKRAT, DePrT.PRIMARY_FIRE, 25, 12.327, 0.074, 0],
    [Hero.ANA, DePrT.ABILITY_2, 30, 9.84, 0, 0],
    [Hero.ASHE, DePrT.ABILITY_2, 25, 8.03, 0.07, 0],
    [Hero.BAPTISTE, DePrT.SECONDARY_FIRE, 60, 20.1, 0.01, 0],
    [Hero.BAPTISTE, DePrT.ABILITY_2, 60, 20.1, 0.01, 0],
    [Hero.JUNKER_QUEEN, DePrT.SECONDARY_FIRE, 35, 8.5, 0.02, 0],
    [Hero.BASTION, DePrT.SECONDARY_FIRE, 40, 9.75, 0, 0],
    [Hero.ORISA, DePrT.SECONDARY_FIRE, 70, 7.5, 0, 0.3],
    [Hero.ORISA, DePrT.ABILITY_2, 25, 9.84, 0, 0.128, "Barrier perk"], # barrier perk
    [Hero.CASSIDY, DePrT.ABILITY_2, 25, 12, 0.025, 0],
    [Hero.SIGMA, DePrT.ABILITY_2, 37.4, 18.45, 0.1, 0.656],
    [Hero.RAMATTRA, DePrT.ABILITY_2, 30, 9.75, 0, 0],
    [Hero.ZARYA, DePrT.SECONDARY_FIRE, 25, 9.84, 0.1, 0],
    [Hero.ZARYA, DePrT.ULTIMATE, 25, 9.84, 0.1, 0],
    [Hero.TORBJORN, DePrT.PRIMARY_FIRE, 70, 9.797, 0.015, 0],
    [Hero.TORBJORN, DePrT.PRIMARY_FIRE, 40, 30.05, 0, 0],
    [Hero.TORBJORN, DePrT.ABILITY_1, 17, 20, 0, 0],
    [Hero.TRACER, DePrT.ULTIMATE, 15, 30.8, 0.19, 0.144],
    [Hero.KIRIKO, DePrT.ABILITY_2, 35, 9.1, 0.015, 0],
    [Hero.HANZO, DePrT.PRIMARY_FIRE, 25, 9.98, 0, 0]
  ]
  debugBallisticsPresetIndex = 0


rule "[debug] init Bot state view mode":
  ConditionForInitMode("Ballistics")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 15

  if len(debugBallisticsSpots) <= 0:
    debugBallisticsSpotIndex = 0
  elif debugBallisticsSpotIndex >= len(debugBallisticsSpots):
    debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1
  if debugBallisticsPresetIndex >= len(debugBallisticsPresets):
    debugBallisticsPresetIndex = 0

  createEffect(
    localPlayerVisibilityForDevelopers() if debugBallisticsCameraEnabled else null,
    Effect.SPHERE,
    Color.PURPLE,
    updateEveryFrame(debugProjectile[DePE.LANDING_POSITION]),
    0.25,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.LANDING_EFFECT] = getLastCreatedEntity()
  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.WHITE,
    updateEveryFrame(debugProjectile[DePE.LAST_HIT_POSITION]),
    0.25,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.LAST_HIT_EFFECT] = getLastCreatedEntity()
  createEffect(
    localPlayerVisibilityForDevelopers() if len(debugBallisticsSpots) > 0 else null,
    Effect.RING,
    Color.AQUA,
    updateEveryFrame(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.POSITION] if len(debugBallisticsSpots) > 0 else debugProjectile[DePE.LANDING_POSITION]),
    0.22,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.SPOT_MARKER_EFFECT] = getLastCreatedEntity()

  hudSubheader(
    localPlayerVisibilityForDevelopers(),
    f"{debugMenuTitle(\"Ballistics\")}
    {debugSelectedActionText(1)}Trigger {leftArrowForMenuItem(1)} <fg84c951FF>{debugButtons[debugProjectile[DePE.TRIGGER_INDEX]]}</fg> {rightArrowForMenuItem(1)}</fg>
    {debugSelectedActionText(2)}Preset {leftArrowForMenuItem(2)} <fg84c951FF>{heroIcon(debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.HERO])} {debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.HERO]} {triggerNameByIndex(debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.TRIGGER_INDEX])}</fg> {rightArrowForMenuItem(2)}</fg>
    {debugSelectedActionText(3)}Save spot</fg>
    {debugSelectedActionText(4)}Load spot {leftArrowForMenuItem(4)} <fg84c951FF>[{debugBallisticsSpotIndex}] {heroIcon(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.HERO])} {triggerNameByIndex(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.TRIGGER_INDEX])} {debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.POSITION]}</fg> {rightArrowForMenuItem(4)}</fg>
    {debugSelectedActionText(5)}Shoot delay</fg> {leftArrowForMenuItem(5)} <fg84c951FF>{debugProjectile[DePE.SHOOT_DELAY]}</fg> {rightArrowForMenuItem(5)}
    {debugSelectedActionText(6)}Starting speed</fg> {leftArrowForMenuItem(6)} <fg84c951FF>{debugProjectile[DePE.START_SPEED]}</fg> {rightArrowForMenuItem(6)}
    {debugSelectedActionText(7)}Starting angle</fg> {leftArrowForMenuItem(7)} <fg84c951FF>{debugProjectile[DePE.START_ANGLE_CORRECTION]}</fg> {rightArrowForMenuItem(7)}
    {debugSelectedActionText(8)}Gravity</fg> {leftArrowForMenuItem(8)} <fg84c951FF>{debugProjectile[DePE.GRAVITY]}</fg> {rightArrowForMenuItem(8)}
    -- Camera:
    {debugSelectedActionText(9)}Toggle camera:</fg> <fg84c951FF>{debugBallisticsCameraEnabled}</fg>
    {debugSelectedActionText(10)}Offset z</fg> {leftArrowForMenuItem(10)} <fg84c951FF>{debugBallisticsCameraOffset.z}</fg> {rightArrowForMenuItem(10)}
    {debugSelectedActionText(11)}Offset y</fg> {leftArrowForMenuItem(11)} <fg84c951FF>{debugBallisticsCameraOffset.y}</fg> {rightArrowForMenuItem(11)}
    -- Draw Trajectory:
    {debugSelectedActionText(12)}Show trajectory:</fg> <fg84c951FF>{debugProjectile[DePE.SHOW_TRAJECTORY]}</fg>
    {debugSelectedActionText(13)}Clear effects</fg>
    {debugSelectedActionText(14)}Step time</fg> {leftArrowForMenuItem(14)} <fg84c951FF>{debugProjectile[DePE.STEP_TIME]}</fg> {rightArrowForMenuItem(14)}
    {debugSelectedActionText(15)}Max time</fg> {leftArrowForMenuItem(15)} <fg84c951FF>{debugProjectile[DePE.MAX_TIME]}</fg> {rightArrowForMenuItem(15)}
    ----------
    Last hit pos: <fg84c951FF>{debugProjectile[DePE.LAST_HIT_POSITION]}</fg>
    Projective time: <fg84c951FF>{debugProjectile[DePE.COLLISION_TIME]}</fg>
    ",
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)

  destroyHudText(debugModeHud)
  destroyEffect(debugProjectile[DePE.LANDING_EFFECT])
  destroyEffect(debugProjectile[DePE.LAST_HIT_EFFECT])
  destroyEffect(debugProjectile[DePE.SPOT_MARKER_EFFECT])
  ClearBallisticsEffectsSub()


rule "[debug] Activate selected action for Ballistics mode":
  ConditionForActivateSelectedAction("Ballistics")

  if debugSelectedAction == 2: # Preset
    debugProjectile[DePE.TRIGGER_INDEX] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.TRIGGER_INDEX]
    debugProjectile[DePE.START_SPEED] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.START_SPEED]
    debugProjectile[DePE.GRAVITY] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.GRAVITY]
    debugProjectile[DePE.START_ANGLE_CORRECTION] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.START_ANGLE_CORRECTION]
    debugProjectile[DePE.SHOOT_DELAY] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.SHOOT_DELAY]

  elif debugSelectedAction == 3: # Save spot
    eventPlayer.tmp0 = [
      eventPlayer.getHero(),
      eventPlayer.getPosition(),
      eventPlayer.getFacingDirection(),
      debugProjectile[DePE.TRIGGER_INDEX],
      debugProjectile[DePE.SHOOT_DELAY],
      debugProjectile[DePE.START_SPEED],
      debugProjectile[DePE.START_ANGLE_CORRECTION],
      debugProjectile[DePE.GRAVITY],
      debugProjectile[DePE.SHOW_TRAJECTORY],
      debugProjectile[DePE.STEP_TIME],
      debugProjectile[DePE.MAX_TIME]
    ]
    debugBallisticsSpots[len(debugBallisticsSpots)] = eventPlayer.tmp0
    debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1

  elif debugSelectedAction == 4: # Load spot
    if len(debugBallisticsSpots) > 0:
      if debugBallisticsSpotIndex >= len(debugBallisticsSpots):
        debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1

      if eventPlayer.getHero() != debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.HERO]:
        eventPlayer.startForcingHero(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.HERO])
        wait()

      eventPlayer.teleport(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.POSITION])
      eventPlayer.setFacing(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.FACING], Relativity.TO_WORLD)
      debugProjectile[DePE.TRIGGER_INDEX] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.TRIGGER_INDEX]
      debugProjectile[DePE.SHOOT_DELAY] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.SHOOT_DELAY]
      debugProjectile[DePE.START_SPEED] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.START_SPEED]
      debugProjectile[DePE.START_ANGLE_CORRECTION] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.START_ANGLE_CORRECTION]
      debugProjectile[DePE.GRAVITY] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.GRAVITY]
      debugProjectile[DePE.SHOW_TRAJECTORY] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.SHOW_TRAJECTORY]
      debugProjectile[DePE.STEP_TIME] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.STEP_TIME]
      debugProjectile[DePE.MAX_TIME] = debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.MAX_TIME]

  elif debugSelectedAction == 9: # Toggle camera
    debugBallisticsCameraEnabled = not debugBallisticsCameraEnabled
    if not debugBallisticsCameraEnabled:
      eventPlayer.stopCamera()
      debugBallisticsState[DeBS.CAMERA_ENABLED_LOCAL] = false

  elif debugSelectedAction == 12: # Show trajectory
    debugProjectile[DePE.SHOW_TRAJECTORY] = not debugProjectile[DePE.SHOW_TRAJECTORY]

  elif debugSelectedAction == 13: # Clear effects
    ClearBallisticsEffectsSub()

def RightBallisticsSub():
  @Name "Sub: Right Ballistics"

  if debugSelectedAction == 1: # Trigger next
    if debugProjectile[DePE.TRIGGER_INDEX] >= len(debugButtons) - 1:
      debugProjectile[DePE.TRIGGER_INDEX] = 0
    else:
      debugProjectile[DePE.TRIGGER_INDEX]++

  elif debugSelectedAction == 2: # Preset next
    if debugBallisticsPresetIndex >= len(debugBallisticsPresets) - 1:
      debugBallisticsPresetIndex = 0
    else:
      debugBallisticsPresetIndex++

  elif debugSelectedAction == 4 and len(debugBallisticsSpots) > 0: # Load spot next
    if debugBallisticsSpotIndex >= len(debugBallisticsSpots) - 1:
      debugBallisticsSpotIndex = 0
    else:
      debugBallisticsSpotIndex++

  elif debugSelectedAction == 5: # Shoot delay increase
    debugProjectile[DePE.SHOOT_DELAY] += incWithModificators(0.01)

  elif debugSelectedAction == 6: # Starting speed increase
    debugProjectile[DePE.START_SPEED] += incWithModificators(0.01)

  elif debugSelectedAction == 7: # Starting angle increase
    debugProjectile[DePE.START_ANGLE_CORRECTION] += incWithModificators(0.01)

  elif debugSelectedAction == 8: # Gravity increase
    debugProjectile[DePE.GRAVITY] += incWithModificators(0.01)

  elif debugSelectedAction == 10: # Offset z increase
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y,
      debugBallisticsCameraOffset.z - incWithModificators(0.1)
    )

  elif debugSelectedAction == 11: # Offset y increase
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y + incWithModificators(0.1),
      debugBallisticsCameraOffset.z
    )

  elif debugSelectedAction == 14: # Step time increase
    debugProjectile[DePE.STEP_TIME] += incWithModificators(0.01)

  elif debugSelectedAction == 15: # Max time increase
    debugProjectile[DePE.MAX_TIME] += incWithModificators(0.1)


rule "[debug] (Right) Ballistics":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "Ballistics"

  autoSwitch(RightBallisticsSub())

def LeftBallisticsSub():
  @Name "Sub: Left Ballistics"

  if debugSelectedAction == 1: # Trigger previous
    if debugProjectile[DePE.TRIGGER_INDEX] <= 0:
      debugProjectile[DePE.TRIGGER_INDEX] = len(debugButtons) - 1
    else:
      debugProjectile[DePE.TRIGGER_INDEX]--

  elif debugSelectedAction == 2: # Preset previous
    if debugBallisticsPresetIndex <= 0:
      debugBallisticsPresetIndex = len(debugBallisticsPresets) - 1
    else:
      debugBallisticsPresetIndex--

  elif debugSelectedAction == 4 and len(debugBallisticsSpots) > 0: # Load spot previous
    if debugBallisticsSpotIndex <= 0:
      debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1
    else:
      debugBallisticsSpotIndex--

  elif debugSelectedAction == 5: # Shoot delay decrease
    debugProjectile[DePE.SHOOT_DELAY] = max(0, debugProjectile[DePE.SHOOT_DELAY] - incWithModificators(0.01))

  elif debugSelectedAction == 6: # Starting speed decrease
    debugProjectile[DePE.START_SPEED] = max(0.01, debugProjectile[DePE.START_SPEED] - incWithModificators(0.01))

  elif debugSelectedAction == 7: # Starting angle decrease
    debugProjectile[DePE.START_ANGLE_CORRECTION] -= incWithModificators(0.01)

  elif debugSelectedAction == 8: # Gravity decrease
    debugProjectile[DePE.GRAVITY] = max(0, debugProjectile[DePE.GRAVITY] - incWithModificators(0.01))

  elif debugSelectedAction == 10: # Offset z decrease
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y,
      debugBallisticsCameraOffset.z + incWithModificators(0.1)
    )

  elif debugSelectedAction == 11: # Offset y decrease
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y - incWithModificators(0.1),
      debugBallisticsCameraOffset.z
    )

  elif debugSelectedAction == 14: # Step time decrease
    debugProjectile[DePE.STEP_TIME] = max(0.01, debugProjectile[DePE.STEP_TIME] - incWithModificators(0.01))

  elif debugSelectedAction == 15: # Max time decrease
    debugProjectile[DePE.MAX_TIME] = max(0.1, debugProjectile[DePE.MAX_TIME] - incWithModificators(0.1))


rule "[debug] (Left) Ballistics":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "Ballistics"

  autoSwitch(LeftBallisticsSub())


rule "[debug] Predict landing before shot":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition debugBallisticsCameraEnabled
  @Condition eventPlayer == hostPlayer or eventPlayer.developer

  debugBallisticsState[DeBS.DRAW_TRAJECTORY] = false
  PredictBallisticsSub()
  wait(0.05, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] Update ballistics camera":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition debugBallisticsCameraEnabled
  @Condition eventPlayer == hostPlayer or eventPlayer.developer

  debugBallisticsState[DeBS.CAMERA_POS] = raycast(
    debugProjectile[DePE.LANDING_POSITION],
    debugProjectile[DePE.LANDING_POSITION] + Vector.UP * debugBallisticsCameraOffset.y + directionTowards(debugProjectile[DePE.LANDING_POSITION], eventPlayer) + worldVector(debugBallisticsCameraOffset, eventPlayer, Transform.ROTATION),
    null,
    eventPlayer,
    false
  ).getHitPosition()
  eventPlayer.startCamera(debugBallisticsState[DeBS.CAMERA_POS], debugProjectile[DePE.LANDING_POSITION], 90)
  debugBallisticsState[DeBS.CAMERA_ENABLED_LOCAL] = true
  wait(0.05, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] Disable ballistics camera":
  @Event eachPlayer
  @Condition debugBallisticsState[DeBS.CAMERA_ENABLED_LOCAL]
  @Condition (
    not debugBallisticsCameraEnabled
    or not debugMenuIsOpened
    or debugModesArr[debugMode] != "Ballistics"
    or not (eventPlayer == hostPlayer or eventPlayer.developer)
  )

  eventPlayer.stopCamera()
  debugBallisticsState[DeBS.CAMERA_ENABLED_LOCAL] = false

rule "[debug] Trigger shot":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition (
    (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.ABILITY_1 and eventPlayer.isUsingAbility1())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.ABILITY_2 and eventPlayer.isUsingAbility2())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.PRIMARY_FIRE and eventPlayer.isFiringPrimaryFire())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.SECONDARY_FIRE and eventPlayer.isFiringSecondaryFire())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.ULTIMATE and eventPlayer.isUsingUltimate())
  )

  wait(debugProjectile[DePE.SHOOT_DELAY])

  if debugProjectile[DePE.MOVING_EFFECT] != null:
    destroyEffect(debugProjectile[DePE.MOVING_EFFECT])
    debugProjectile[DePE.MOVING_EFFECT] = null

  debugBallisticsState[DeBS.DRAW_TRAJECTORY] = true
  PredictBallisticsSub()
  debugProjectile[DePE.LAST_HIT_POSITION] = debugProjectile[DePE.LANDING_POSITION]

  debugBallisticsFlyingT = 0
  chaseAtRate(debugBallisticsFlyingT, 100, 1)

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.GREEN,
    (
      debugBallisticsState[DeBS.EYE_POS]
      + debugBallisticsState[DeBS.HORIZONTAL_DIR] * debugBallisticsState[DeBS.VX] * updateEveryFrame(debugBallisticsFlyingT)
      + Vector.UP * (
        debugBallisticsState[DeBS.VY] * updateEveryFrame(debugBallisticsFlyingT)
        - ((debugProjectile[DePE.GRAVITY] * (updateEveryFrame(debugBallisticsFlyingT) ** 2)) / 2)
      )
    ),
    0.2,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.MOVING_EFFECT] = getLastCreatedEntity()

  waitUntil(
    debugBallisticsFlyingT >= debugProjectile[DePE.COLLISION_TIME],
    debugProjectile[DePE.MAX_TIME] + 0.5
  )

  stopChasingVariable(debugBallisticsFlyingT)
  if debugProjectile[DePE.MOVING_EFFECT] != null:
    destroyEffect(debugProjectile[DePE.MOVING_EFFECT])
    debugProjectile[DePE.MOVING_EFFECT] = null
