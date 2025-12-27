#!mainFile "../main.opy"
globalvar debugProjectile
globalvar debugChangeSign
globalvar debugChangeMult
globalvar debugButtons = [Button.ABILITY_1, Button.ABILITY_2, Button.PRIMARY_FIRE, Button.SECONDARY_FIRE, Button.ULTIMATE]

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
  debugMaxAction = 6

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
    {}Trigger</fg> <fg84c951FF>{}</fg>
    {}Replay</fg>
    {}Shoot delay [+/-]</fg> <fg84c951FF>{}</fg>
    {}Starting speed [+/-]</fg> <fg84c951FF>{}</fg>
    {}Starting angle [+/-]</fg> <fg84c951FF>{}</fg>
    {}Gravity [+/-]</fg> <fg84c951FF>{}</fg>
    ----------
    Projectile position: <fg84c951FF>{}</fg>
    Projectile velocity: <fg84c951FF>{}</fg>
    ".format(
      debugMenuTitle("Ballistics"),
      debugSelectedActionText(1),
      debugButtons[debugProjectile[DePE.TRIGGER_INDEX]],
      debugSelectedActionText(2),
      debugSelectedActionText(3),
      debugProjectile[DePE.SHOOT_DELAY],
      debugSelectedActionText(4),
      debugProjectile[DePE.START_SPEED],
      debugSelectedActionText(5),
      debugProjectile[DePE.START_ANGLE_CORRECTION],
      debugSelectedActionText(6),
      debugProjectile[DePE.GRAVITY],
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

  if debugSelectedAction == 1:
    if debugProjectile[DePE.TRIGGER_INDEX] >= len(debugButtons) - 1:
      debugProjectile[DePE.TRIGGER_INDEX] = 0
    else:
      debugProjectile[DePE.TRIGGER_INDEX]++


rule "[debug] Increase value":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and (eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE))

  debugChangeSign = 1 if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) else -1
  debugChangeMult = 10 if eventPlayer.isHoldingButton(Button.MELEE) else 100 if eventPlayer.isHoldingButton(Button.RELOAD) else 1

  if debugSelectedAction == 2:
    debugProjectile[DePE.SHOOT_DELAY] += 0.01 * debugChangeSign * debugChangeMult
  elif debugSelectedAction == 3:
    debugProjectile[DePE.START_SPEED] += 0.01 * debugChangeSign * debugChangeMult
  elif debugSelectedAction == 4:
    debugProjectile[DePE.START_ANGLE_CORRECTION] += 0.01 * debugChangeSign * debugChangeMult
  elif debugSelectedAction == 4:
    debugProjectile[DePE.GRAVITY] += 0.01 * debugChangeSign * debugChangeMult

rule "[debug] Trigger shot":
  @Event eachPlayer
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Ballistics"
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition (
    (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.ABILITY_1 and eventPlayer.isUsingAbility1())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.ABILITY_2 and eventPlayer.isUsingAbility2())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.PRIMARY_FIRE and eventPlayer.isFiringPrimaryFire())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.SECONDARY_FIRE and eventPlayer.isFiringSecondaryFire())
    or (debugProjectile[DePE.TRIGGER_INDEX] == DePrT.SECONDARY_FIRE and eventPlayer.isUsingUltimate())
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
