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

playervar ballisticsEyePos
playervar ballisticsHorizontalDir
playervar ballisticsLaunchAngle
playervar ballisticsVx
playervar ballisticsVy
playervar ballisticsTime
playervar ballisticsSegmentStart
playervar ballisticsSegmentEnd
playervar ballisticsImpactPos
playervar ballisticsFlyingT
playervar ballisticsDrawTrajectory
playervar ballisticsCameraEnabledLocal
playervar ballisticsCameraPos

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


def ClearBallisticsEffectsSub():
  @Name "Sub: Clear Ballistics Effects"

  destroyEffect(debugBallisticsTrajectoryEffects)
  debugBallisticsTrajectoryEffects = []

  if debugProjectile[DePE.MOVING_EFFECT] != null:
    destroyEffect(debugProjectile[DePE.MOVING_EFFECT])
    debugProjectile[DePE.MOVING_EFFECT] = null

def PredictBallisticsSub():
  @Name "Sub: Predict Ballistics"

  eventPlayer.ballisticsEyePos = eventPlayer.getEyePosition()
  eventPlayer.ballisticsHorizontalDir = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), 0)
  eventPlayer.ballisticsLaunchAngle = verticalAngleOfDirection(eventPlayer.getFacingDirection() + vect(0, debugProjectile[DePE.START_ANGLE_CORRECTION], 0)) * -1

  if eventPlayer.ballisticsLaunchAngle < -89:
    eventPlayer.ballisticsLaunchAngle = -90
  elif eventPlayer.ballisticsLaunchAngle > 89:
    eventPlayer.ballisticsLaunchAngle = 90

  eventPlayer.ballisticsVx = debugProjectile[DePE.START_SPEED] * cosDeg(eventPlayer.ballisticsLaunchAngle)
  eventPlayer.ballisticsVy = debugProjectile[DePE.START_SPEED] * sinDeg(eventPlayer.ballisticsLaunchAngle)

  eventPlayer.ballisticsTime = 0
  debugProjectile[DePE.COLLISION_TIME] = debugProjectile[DePE.MAX_TIME]
  debugProjectile[DePE.LANDING_POSITION] = eventPlayer.ballisticsEyePos

  while eventPlayer.ballisticsTime <= debugProjectile[DePE.MAX_TIME]:
    eventPlayer.ballisticsSegmentStart = (
      eventPlayer.ballisticsEyePos
      + eventPlayer.ballisticsHorizontalDir * eventPlayer.ballisticsVx * eventPlayer.ballisticsTime
      + Vector.UP * (eventPlayer.ballisticsVy * eventPlayer.ballisticsTime - ((debugProjectile[DePE.GRAVITY] * (eventPlayer.ballisticsTime ** 2)) / 2))
    )

    eventPlayer.ballisticsSegmentEnd = (
      eventPlayer.ballisticsEyePos
      + eventPlayer.ballisticsHorizontalDir * eventPlayer.ballisticsVx * (eventPlayer.ballisticsTime + debugProjectile[DePE.STEP_TIME])
      + Vector.UP * (
        eventPlayer.ballisticsVy * (eventPlayer.ballisticsTime + debugProjectile[DePE.STEP_TIME])
        - ((debugProjectile[DePE.GRAVITY] * ((eventPlayer.ballisticsTime + debugProjectile[DePE.STEP_TIME]) ** 2)) / 2)
      )
    )

    eventPlayer.ballisticsImpactPos = raycast(
      eventPlayer.ballisticsSegmentStart,
      eventPlayer.ballisticsSegmentEnd,
      getAllPlayers(),
      eventPlayer,
      true
    ).getHitPosition()

    if eventPlayer.ballisticsDrawTrajectory and debugProjectile[DePE.SHOW_TRAJECTORY] and eventPlayer.ballisticsTime > 0:
      createBeam(
        localPlayerVisibilityForDevelopers(),
        Beam.GRAPPLE,
        evalOnce(eventPlayer.ballisticsSegmentStart),
        evalOnce(eventPlayer.ballisticsImpactPos),
        Color.WHITE,
        EffectReeval.VISIBILITY_POSITION_AND_RADIUS
      )
      debugBallisticsTrajectoryEffects[len(debugBallisticsTrajectoryEffects)] = getLastCreatedEntity()

    if eventPlayer.ballisticsImpactPos != eventPlayer.ballisticsSegmentEnd:
      debugProjectile[DePE.LANDING_POSITION] = eventPlayer.ballisticsImpactPos
      debugProjectile[DePE.COLLISION_TIME] = eventPlayer.ballisticsTime + debugProjectile[DePE.STEP_TIME]
      break

    eventPlayer.ballisticsTime += debugProjectile[DePE.STEP_TIME]
    debugProjectile[DePE.LANDING_POSITION] = eventPlayer.ballisticsSegmentEnd

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
    "{}
    {}Trigger {} <fg84c951FF>{}</fg> {}</fg>
    {}Preset {} <fg84c951FF>{} {} {}</fg> {}</fg>
    {}Save spot</fg>
    {}Load spot {} <fg84c951FF>{} {} {} {}</fg> {}</fg>
    {}Shoot delay</fg> {} <fg84c951FF>{}</fg> {}
    {}Starting speed</fg> {} <fg84c951FF>{}</fg> {}
    {}Starting angle</fg> {} <fg84c951FF>{}</fg> {}
    {}Gravity</fg> {} <fg84c951FF>{}</fg> {}
    -- Camera:
    {}Toggle camera:</fg> <fg84c951FF>{}</fg>
    {}Offset z</fg> {} <fg84c951FF>{}</fg> {}
    {}Offset y</fg> {} <fg84c951FF>{}</fg> {}
    -- Draw Trajectory:
    {}Show trajectory:</fg> <fg84c951FF>{}</fg>
    {}Clear effects</fg>
    {}Step time</fg> {} <fg84c951FF>{}</fg> {}
    {}Max time</fg> {} <fg84c951FF>{}</fg> {}
    ----------
    Predicted impact: <fg84c951FF>{}</fg>
    Last hit: <fg84c951FF>{}</fg>
    Predicted collision time: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("Ballistics"),

      debugSelectedActionText(1),
      leftArrowForMenuItem(1),
      debugButtons[debugProjectile[DePE.TRIGGER_INDEX]],
      rightArrowForMenuItem(1),

      debugSelectedActionText(2),
      leftArrowForMenuItem(2),
      heroIcon(debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.HERO]),
      debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.HERO],
      triggerNameByIndex(debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.TRIGGER_INDEX]),
      rightArrowForMenuItem(2),

      
      debugSelectedActionText(3),
      debugSelectedActionText(4),
      leftArrowForMenuItem(4),
      "[{}]".format(debugBallisticsSpotIndex) if len(debugBallisticsSpots) > 0 else "[none]",
      heroIcon(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.HERO]) if len(debugBallisticsSpots) > 0 else "",
      triggerNameByIndex(debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.TRIGGER_INDEX]) if len(debugBallisticsSpots) > 0 else "none",
      debugBallisticsSpots[debugBallisticsSpotIndex][DePSD.POSITION] if len(debugBallisticsSpots) > 0 else "none",
      rightArrowForMenuItem(4),

      debugSelectedActionText(5),
      leftArrowForMenuItem(5),
      debugProjectile[DePE.SHOOT_DELAY],
      rightArrowForMenuItem(5),

      debugSelectedActionText(6),
      leftArrowForMenuItem(6),
      debugProjectile[DePE.START_SPEED],
      rightArrowForMenuItem(6),

      debugSelectedActionText(7),
      leftArrowForMenuItem(7),
      debugProjectile[DePE.START_ANGLE_CORRECTION],
      rightArrowForMenuItem(7),

      debugSelectedActionText(8),
      leftArrowForMenuItem(8),
      debugProjectile[DePE.GRAVITY],
      rightArrowForMenuItem(8),

      debugSelectedActionText(9),
      debugBallisticsCameraEnabled,
      debugSelectedActionText(10),
      leftArrowForMenuItem(10),
      debugBallisticsCameraOffset.z,
      rightArrowForMenuItem(10),
      debugSelectedActionText(11),
      leftArrowForMenuItem(11),
      debugBallisticsCameraOffset.y,
      rightArrowForMenuItem(11),
      debugSelectedActionText(12),
      debugProjectile[DePE.SHOW_TRAJECTORY],
      debugSelectedActionText(13),

      debugSelectedActionText(14),
      leftArrowForMenuItem(14),
      debugProjectile[DePE.STEP_TIME],
      rightArrowForMenuItem(14),

      debugSelectedActionText(15),
      leftArrowForMenuItem(15),
      debugProjectile[DePE.MAX_TIME],
      rightArrowForMenuItem(15),

      debugProjectile[DePE.LANDING_POSITION],
      debugProjectile[DePE.LAST_HIT_POSITION],
      debugProjectile[DePE.COLLISION_TIME]
    ),
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

  if debugSelectedAction == 2:
    debugProjectile[DePE.TRIGGER_INDEX] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.TRIGGER_INDEX]
    debugProjectile[DePE.START_SPEED] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.START_SPEED]
    debugProjectile[DePE.GRAVITY] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.GRAVITY]
    debugProjectile[DePE.START_ANGLE_CORRECTION] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.START_ANGLE_CORRECTION]
    debugProjectile[DePE.SHOOT_DELAY] = debugBallisticsPresets[debugBallisticsPresetIndex][DeBPrE.SHOOT_DELAY]

  elif debugSelectedAction == 3:
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

  elif debugSelectedAction == 4:
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

  elif debugSelectedAction == 9:
    debugBallisticsCameraEnabled = not debugBallisticsCameraEnabled
    if not debugBallisticsCameraEnabled:
      eventPlayer.stopCamera()
      eventPlayer.ballisticsCameraEnabledLocal = false

  elif debugSelectedAction == 12:
    debugProjectile[DePE.SHOW_TRAJECTORY] = not debugProjectile[DePE.SHOW_TRAJECTORY]

  elif debugSelectedAction == 13:
    ClearBallisticsEffectsSub()



def RightBallisticsSub():
  @Name "Sub: Right Ballistics"

  if debugSelectedAction == 1:
    if debugProjectile[DePE.TRIGGER_INDEX] >= len(debugButtons) - 1:
      debugProjectile[DePE.TRIGGER_INDEX] = 0
    else:
      debugProjectile[DePE.TRIGGER_INDEX]++

  elif debugSelectedAction == 2:
    if debugBallisticsPresetIndex >= len(debugBallisticsPresets) - 1:
      debugBallisticsPresetIndex = 0
    else:
      debugBallisticsPresetIndex++

  elif debugSelectedAction == 4 and len(debugBallisticsSpots) > 0:
    if debugBallisticsSpotIndex >= len(debugBallisticsSpots) - 1:
      debugBallisticsSpotIndex = 0
    else:
      debugBallisticsSpotIndex++

  elif debugSelectedAction == 5:
    debugProjectile[DePE.SHOOT_DELAY] += incWithModificators(0.01)

  elif debugSelectedAction == 6:
    debugProjectile[DePE.START_SPEED] += incWithModificators(0.01)

  elif debugSelectedAction == 7:
    debugProjectile[DePE.START_ANGLE_CORRECTION] += incWithModificators(0.01)

  elif debugSelectedAction == 8:
    debugProjectile[DePE.GRAVITY] += incWithModificators(0.01)

  elif debugSelectedAction == 10:
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y,
      debugBallisticsCameraOffset.z - incWithModificators(0.1)
    )

  elif debugSelectedAction == 11:
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y + incWithModificators(0.1),
      debugBallisticsCameraOffset.z
    )

  elif debugSelectedAction == 14:
    debugProjectile[DePE.STEP_TIME] += incWithModificators(0.01)

  elif debugSelectedAction == 15:
    debugProjectile[DePE.MAX_TIME] += incWithModificators(0.1)


rule "[debug] (Right) Ballistics":
  RuleHeaderForDebugMenuInputThrottle(Vector.RIGHT)
  @Condition debugModesArr[debugMode] == "Ballistics"

  autoSwitch(RightBallisticsSub())



def LeftBallisticsSub():
  @Name "Sub: Left Ballistics"

  if debugSelectedAction == 1:
    if debugProjectile[DePE.TRIGGER_INDEX] <= 0:
      debugProjectile[DePE.TRIGGER_INDEX] = len(debugButtons) - 1
    else:
      debugProjectile[DePE.TRIGGER_INDEX]--

  elif debugSelectedAction == 2:
    if debugBallisticsPresetIndex <= 0:
      debugBallisticsPresetIndex = len(debugBallisticsPresets) - 1
    else:
      debugBallisticsPresetIndex--

  elif debugSelectedAction == 4 and len(debugBallisticsSpots) > 0:
    if debugBallisticsSpotIndex <= 0:
      debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1
    else:
      debugBallisticsSpotIndex--

  elif debugSelectedAction == 5:
    debugProjectile[DePE.SHOOT_DELAY] = max(0, debugProjectile[DePE.SHOOT_DELAY] - incWithModificators(0.01))

  elif debugSelectedAction == 6:
    debugProjectile[DePE.START_SPEED] = max(0.01, debugProjectile[DePE.START_SPEED] - incWithModificators(0.01))

  elif debugSelectedAction == 7:
    debugProjectile[DePE.START_ANGLE_CORRECTION] -= incWithModificators(0.01)

  elif debugSelectedAction == 8:
    debugProjectile[DePE.GRAVITY] = max(0, debugProjectile[DePE.GRAVITY] - incWithModificators(0.01))

  elif debugSelectedAction == 10:
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y,
      debugBallisticsCameraOffset.z + incWithModificators(0.1)
    )

  elif debugSelectedAction == 11:
    debugBallisticsCameraOffset = vect(
      debugBallisticsCameraOffset.x,
      debugBallisticsCameraOffset.y - incWithModificators(0.1),
      debugBallisticsCameraOffset.z
    )

  elif debugSelectedAction == 14:
    debugProjectile[DePE.STEP_TIME] = max(0.01, debugProjectile[DePE.STEP_TIME] - incWithModificators(0.01))

  elif debugSelectedAction == 15:
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

  eventPlayer.ballisticsDrawTrajectory = false
  PredictBallisticsSub()
  wait(0.05, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] Update ballistics camera":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition debugBallisticsCameraEnabled
  @Condition eventPlayer == hostPlayer or eventPlayer.developer

  eventPlayer.ballisticsCameraPos = raycast(
    debugProjectile[DePE.LANDING_POSITION],
    debugProjectile[DePE.LANDING_POSITION] + Vector.UP * debugBallisticsCameraOffset.y + directionTowards(debugProjectile[DePE.LANDING_POSITION], eventPlayer) + worldVector(debugBallisticsCameraOffset, eventPlayer, Transform.ROTATION),
    null,
    eventPlayer,
    false
  ).getHitPosition()
  eventPlayer.startCamera(eventPlayer.ballisticsCameraPos, debugProjectile[DePE.LANDING_POSITION], 90)
  eventPlayer.ballisticsCameraEnabledLocal = true
  wait(0.05, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] Disable ballistics camera":
  @Event eachPlayer
  @Condition eventPlayer.ballisticsCameraEnabledLocal
  @Condition (
    not debugBallisticsCameraEnabled
    or not debugMenuIsOpened
    or debugModesArr[debugMode] != "Ballistics"
    or not (eventPlayer == hostPlayer or eventPlayer.developer)
  )

  eventPlayer.stopCamera()
  eventPlayer.ballisticsCameraEnabledLocal = false

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

  eventPlayer.ballisticsDrawTrajectory = true
  PredictBallisticsSub()
  debugProjectile[DePE.LAST_HIT_POSITION] = debugProjectile[DePE.LANDING_POSITION]

  eventPlayer.ballisticsFlyingT = 0
  chaseAtRate(eventPlayer.ballisticsFlyingT, 100, 1)

  createEffect(
    localPlayerVisibilityForDevelopers(),
    Effect.SPHERE,
    Color.GREEN,
    (
      eventPlayer.ballisticsEyePos
      + eventPlayer.ballisticsHorizontalDir * eventPlayer.ballisticsVx * updateEveryFrame(eventPlayer.ballisticsFlyingT)
      + Vector.UP * (
        eventPlayer.ballisticsVy * updateEveryFrame(eventPlayer.ballisticsFlyingT)
        - ((debugProjectile[DePE.GRAVITY] * (updateEveryFrame(eventPlayer.ballisticsFlyingT) ** 2)) / 2)
      )
    ),
    0.2,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.MOVING_EFFECT] = getLastCreatedEntity()

  waitUntil(
    eventPlayer.ballisticsFlyingT >= debugProjectile[DePE.COLLISION_TIME],
    debugProjectile[DePE.MAX_TIME] + 0.5
  )

  stopChasingVariable(eventPlayer.ballisticsFlyingT)
  if debugProjectile[DePE.MOVING_EFFECT] != null:
    destroyEffect(debugProjectile[DePE.MOVING_EFFECT])
    debugProjectile[DePE.MOVING_EFFECT] = null
