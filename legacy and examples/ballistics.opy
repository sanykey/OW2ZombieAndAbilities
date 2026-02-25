#!mainFile "../main.opy"
globalvar debugProjectile
globalvar debugButtons = [Button.ABILITY_1, Button.ABILITY_2, Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE]
globalvar debugBallisticsSpots = []
globalvar debugBallisticsSpotIndex = 0

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

enum DePSD: # DebugProjectileShotDataE
  HERO
  POSITION
  FACING
  TRIGGER_INDEX
  SHOOT_DELAY
  START_SPEED
  START_ANGLE_CORRECTION
  GRAVITY

enum DePrT: # DebugProjectileTriggerE
  ABILITY_1
  ABILITY_2
  PRIMARY_FIRE
  SECONDARY_FIRE
  ULTIMATE

rule "[debug] add Ballistics debug mode":
  debugModesArr.append("Ballistics")
  debugProjectile[DePE.SHOOT_DELAY] = 0.136
  debugProjectile[DePE.START_ANGLE_CORRECTION] = 0.09
  debugProjectile[DePE.START_SPEED] = 25
  debugProjectile[DePE.GRAVITY] = 206.995

rule "[debug] init Bot state view mode":
  ConditionForInitMode("Ballistics")

  wait(0.1)
  debugSelectedAction = 0
  debugMaxAction = 7

  createEffect(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    Effect.SPHERE,
    Color.RED,
    updateEveryFrame(debugProjectile[DePE.POSITION]), 0.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.EFFECT] = getLastCreatedEntity()
  createBeam(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    Beam.TORBJORN_TURRET_SIGHT,
    debugProjectile[DePE.POSITION] + Vector.DOWN * 1,
    debugProjectile[DePE.POSITION] + Vector.UP * 1,
    Color.TEAM_1,
    EffectReeval.VISIBILITY_POSITION_AND_RADIUS
  )
  debugProjectile[DePE.VERTICALBEAM] = getLastCreatedEntity()

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    "{}
    {}Trigger {} <fg84c951FF>{}</fg> {}</fg>
    {}Save spot</fg>
    {}Load spot {} <fg84c951FF>{}</fg> {}</fg>
    {}Shoot delay</fg> {} <fg84c951FF>{}</fg> {}
    {}Starting speed</fg> {} <fg84c951FF>{}</fg> {}
    {}Starting angle</fg> {} <fg84c951FF>{}</fg> {}
    {}Gravity</fg> {} <fg84c951FF>{}</fg> {}
    ----------
    Projectile position: <fg84c951FF>{}</fg>
    Projectile velocity: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("Ballistics"),

      debugSelectedActionText(1),
      leftArrowForMenuItem(1),
      debugButtons[debugProjectile[DePE.TRIGGER_INDEX]],
      rightArrowForMenuItem(1),

      debugSelectedActionText(2),
      debugSelectedActionText(3),
      leftArrowForMenuItem(3),
      debugBallisticsSpotIndex if len(debugBallisticsSpots) > 0 else "none",
      rightArrowForMenuItem(3),
      debugSelectedActionText(4),
      leftArrowForMenuItem(4),
      debugProjectile[DePE.SHOOT_DELAY],
      rightArrowForMenuItem(4),
      debugSelectedActionText(5),
      leftArrowForMenuItem(5),
      debugProjectile[DePE.START_SPEED],
      rightArrowForMenuItem(5),
      debugSelectedActionText(6),
      leftArrowForMenuItem(6),
      debugProjectile[DePE.START_ANGLE_CORRECTION],
      rightArrowForMenuItem(6),
      debugSelectedActionText(7),
      leftArrowForMenuItem(7),
      debugProjectile[DePE.GRAVITY],
      rightArrowForMenuItem(7),
      debugProjectile[DePE.POSITION],
      debugProjectile[DePE.VELOCITY]
    ),
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)
  destroyEffect(debugProjectile[DePE.EFFECT])
  destroyEffect(debugProjectile[DePE.VERTICALBEAM])


rule "[debug] Activate selected action for Ballistics mode":
  ConditionForActivateSelectedAction("Ballistics")

  if debugSelectedAction == 2:
    eventPlayer.tmp0 = [
      eventPlayer.getHero(),
      eventPlayer.getPosition(),
      eventPlayer.getFacingDirection(),
      debugProjectile[DePE.TRIGGER_INDEX],
      debugProjectile[DePE.SHOOT_DELAY],
      debugProjectile[DePE.START_SPEED],
      debugProjectile[DePE.START_ANGLE_CORRECTION],
      debugProjectile[DePE.GRAVITY]
    ]

    debugBallisticsSpots[len(debugBallisticsSpots)] = eventPlayer.tmp0
    debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1
  elif debugSelectedAction == 3:
    if len(debugBallisticsSpots) > 0:
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


def RightBallisticsSub():
  @Name "Sub: Right Ballistics"
  if debugSelectedAction == 1:
    if debugProjectile[DePE.TRIGGER_INDEX] >= len(debugButtons) - 1:
      debugProjectile[DePE.TRIGGER_INDEX] = 0
    else:
      debugProjectile[DePE.TRIGGER_INDEX]++
  elif debugSelectedAction == 3 and len(debugBallisticsSpots) > 0:
    if debugBallisticsSpotIndex >= len(debugBallisticsSpots) - 1:
      debugBallisticsSpotIndex = 0
    else:
      debugBallisticsSpotIndex++
  elif debugSelectedAction == 4:
    debugProjectile[DePE.SHOOT_DELAY] += incWithModificators(0.01)
  elif debugSelectedAction == 5:
    debugProjectile[DePE.START_SPEED] += incWithModificators(0.01)
  elif debugSelectedAction == 6:
    debugProjectile[DePE.START_ANGLE_CORRECTION] += incWithModificators(0.01)
  elif debugSelectedAction == 7:
    debugProjectile[DePE.GRAVITY] += incWithModificators(0.01)

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
  elif debugSelectedAction == 3 and len(debugBallisticsSpots) > 0:
    if debugBallisticsSpotIndex <= 0:
      debugBallisticsSpotIndex = len(debugBallisticsSpots) - 1
    else:
      debugBallisticsSpotIndex--
  elif debugSelectedAction == 4:
    debugProjectile[DePE.SHOOT_DELAY] -= incWithModificators(0.01)
  elif debugSelectedAction == 5:
    debugProjectile[DePE.START_SPEED] -= incWithModificators(0.01)
  elif debugSelectedAction == 6:
    debugProjectile[DePE.START_ANGLE_CORRECTION] -= incWithModificators(0.01)
  elif debugSelectedAction == 7:
    debugProjectile[DePE.GRAVITY] -= incWithModificators(0.01)

rule "[debug] (Left) Ballistics":
  RuleHeaderForDebugMenuInputThrottle(Vector.LEFT)
  @Condition debugModesArr[debugMode] == "Ballistics"

  autoSwitch(LeftBallisticsSub())

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
  debugProjectile[DePE.POSITION] = eventPlayer.getEyePosition()
  debugProjectile[DePE.TIMEOUT] = 0
  debugProjectile[DePE.VICTUM] = null
  
  if eventPlayer.getVerticalFacingAngle() <= -88.99:
    debugProjectile[DePE.VELOCITY] = Vector.UP * debugProjectile[DePE.START_SPEED]
  elif eventPlayer.getVerticalFacingAngle() >= 88.99:
    debugProjectile[DePE.VELOCITY] = Vector.DOWN * debugProjectile[DePE.START_SPEED]
  else:
    debugProjectile[DePE.VELOCITY] = (normalize(eventPlayer.getFacingDirection() + Vector.UP * debugProjectile[DePE.START_ANGLE_CORRECTION])) * debugProjectile[DePE.START_SPEED]

  while (
    raycast(
      debugProjectile[DePE.POSITION],
      debugProjectile[DePE.POSITION] + debugProjectile[DePE.VELOCITY] / 61.881,
      getLivingPlayers(getOppositeTeam(eventPlayer.getTeam())),
      null,
      true
    ).getHitPosition() == debugProjectile[DePE.POSITION] + debugProjectile[DePE.VELOCITY] / 61.881 and debugProjectile[DePE.TIMEOUT] <= 10
  ):
    debugProjectile[DePE.VELOCITY] -= vect(0, 0.098 * debugProjectile[DePE.GRAVITY] / 62.5, 0)
    debugProjectile[DePE.POSITION] += debugProjectile[DePE.VELOCITY] / 62.5
    debugProjectile[DePE.TIMEOUT] += 0.016
    wait()
  debugProjectile[DePE.VICTUM] = raycast(
    debugProjectile[DePE.POSITION], debugProjectile[DePE.POSITION] + debugProjectile[DePE.VELOCITY] / 61.881, getLivingPlayers(getOppositeTeam(eventPlayer.getTeam())), null, true
  ).getPlayerHit()
