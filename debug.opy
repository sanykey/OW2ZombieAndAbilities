#!mainFile "main.opy"

rule "[debug] Init":
  hudText(
    localPlayer,
    null,
    "The server is running in development mode.
    The mod is not ready yet.",
    null,
    HudPosition.RIGHT,
    -10,
    null,
    rgb(241, 134, 39),
    null,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

rule "[debug] User init":
  @Event playerJoined
  @Team 1
  # @Slot 0
  
  # waitUntil(eventPlayer.hasSpawned(), INFINITY)
  eventPlayer.state[0] = 4
  eventPlayer.money += 1000000

  if eventPlayer == hostPlayer:
    eventPlayer.startForcingHero(Hero.MAUGA)

  eventPlayer.healthStat += 500
  eventPlayer.setMaxHealth(eventPlayer.healthStat)
  # eventPlayer.damageStat = 10000
  # eventPlayer.setDamageDealt(eventPlayer.damageStat)
  # eventPlayer.healingStat += 10000
  # eventPlayer.setHealingDealt(eventPlayer.healingStat)
  # eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY + 0 if eventPlayer.healingStat < 100 else ceil(HEAL_AMOUNT_FOR_MONEY * (eventPlayer.healingStat / 500))




rule "[debug] Charge ultimate":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  eventPlayer.setUltCharge(100)


rule "[debug] Deactivate bots (Ctrl + shift + interact)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  if isBotsDisabled == false:
    isBotsDisabled = true
    damage(getPlayers(Team.2), getPlayers(Team.2), INFINITY)
    smallMessage(eventPlayer, "Bots disabled")
  else:
    isBotsDisabled = false
    smallMessage(eventPlayer, "Bots enabled")


# rule "Just die":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0
#   @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
#   @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
#   damage(eventPlayer, eventPlayer, INFINITY)


# rule "Init":
#   Player 1 current coordinates
#   hudSubtext(getPlayersInSlot(0, Team.1), "P1: {0}".format(getPlayersInSlot(0, Team.1).getPosition()), HudPosition.TOP, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "Current [{0}] vect: {1}".format(debugCurrentVectNum, debugVectsArr[debugCurrentVectNum].getPosition()), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)

#   hudSubtext(getPlayersInSlot(0, Team.1), "Healing {0} < {1}".format(getPlayersInSlot(0, Team.1).state[SI.HEALING_TRACKER] ,getPlayersInSlot(0, Team.1).state[SI.HEALING_TRACKER_THRESHOLD]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "WidowShotCharge: {0}".format(getPlayersInSlot(0, Team.1).widowmakerChargeShot), HudPosition.TOP, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

#   hudSubtext(getPlayersInSlot(0, Team.1), "Player getEyePosition: {0}".format(getPlayersInSlot(0, Team.1).getEyePosition()), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "victum sphere pos: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.SPHERE_POS]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "Facing direction: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.FACING_DIRECTION]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "A: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.A] * 1000), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "B: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.B] * 1000), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "C: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.C] * 1000), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "DISC: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.DISC]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "DIST SQRT: {0}".format(getPlayersInSlot(0, Team.1).raycast[RI.SQRT_RESULT]), HudPosition.TOP, 5, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)

# rule "Create debbugginh vectors list":

#   debugVectsArr = []
#   for I in range(vectListI.BUY_HERO_OFFSET, vectListI.BUY_HERO_OFFSET + BUY_HERO_LEN):
#     debugVectsArr[I - vectListI.BUY_HERO_OFFSET] = vectList[I]

#   createBeam(
#     getPlayersInSlot(0, Team.1),
#     Beam.GOOD,
#     getPlayersInSlot(0, Team.1).getEyePosition() + vect(0, -0.25, 0),
#     debugVectsArr[debugCurrentVectNum], 
#     Color.GREEN,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   createEffect(
#     getPlayersInSlot(0, Team.1),
#     Effect.SPHERE,
#     Color.GREEN,
#     debugVectsArr[debugCurrentVectNum],
#     1,
#     EffectReeval.VISIBILITY_POSITION_AND_RADIUS
#   )

#   hudHeader(
#     getPlayersInSlot(0, Team.1),
#     "vect {0}: {1} ({2})".format(debugCurrentVectNum, debugVectsArr[debugCurrentVectNum], distance(getPlayersInSlot(0, Team.1), debugVectsArr[debugCurrentVectNum])),
#     HudPosition.TOP,
#     0,
#     Color.WHITE,
#     HudReeval.VISIBILITY_AND_STRING,
#     SpecVisibility.ALWAYS
#   )

  
# rule "Show next vector":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0
#   @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

#   if debugCurrentVectNum >= len(debugVectsArr) - 1:
#     debugCurrentVectNum = 0
#     smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
#   else:
#     debugCurrentVectNum += 1
#     smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
  
# rule "Show prev vector":
#   @Event eachPlayer
#   @Team 1
#   @Slot 0
#   @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

#   if debugCurrentVectNum <= 0:
#     debugCurrentVectNum = len(debugVectsArr) - 1
#     smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))
#   else:
#     debugCurrentVectNum -= 1
#     smallMessage(eventPlayer, "{0} vector of {1}".format(debugCurrentVectNum, len(debugVectsArr) - 1))




# rule "Debug: scope raycast calibration init":
#   getPlayersInSlot(0, Team.1).state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y] = -0.03
#   getPlayersInSlot(0, Team.1).state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y] = -0.045

#   hudSubtext(getPlayersInSlot(0, Team.1), "getEyePosition y: {0}".format(getPlayersInSlot(0, Team.1).state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y] * 10) , HudPosition.TOP, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
#   hudSubtext(getPlayersInSlot(0, Team.1), "getFacingDirection y: {0}".format(getPlayersInSlot(0, Team.1).state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y] * 10) , HudPosition.TOP, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


# rule "Debug: scope raycast calibration change":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true and (
#     eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.CROUCH) or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE
#   )
#   )

#   if (eventPlayer.isHoldingButton(Button.JUMP)):
#     eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y] += 0.005
#   elif (eventPlayer.isHoldingButton(Button.CROUCH)):
#     eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y] -= 0.005
#   elif (eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)):
#     eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y] += 0.005
#   elif (eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)):
#     eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y] -= 0.005

# rule "Debug: scope raycast calibration shoot":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1
#   @Condition eventPlayer.isFiringPrimaryFire() == true

#   destroyEffect(eventPlayer.HUDs[HI.DEBUG])
#   destroyEffect(eventPlayer.HUDs[HI.DEBUG2])
#   destroyEffect(eventPlayer.HUDs[HI.DEBUG3])

#   temp1 = eventPlayer.getEyePosition() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y], 0)

#   createBeam(
#     getAllPlayers(),
#     Beam.BAD,
#     eventPlayer.getEyePosition(),
#     raycast(
#       temp1,
#       temp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     Color.GREEN,
#     EffectReeval.COLOR
#   )
#   eventPlayer.HUDs[HI.DEBUG] = getLastCreatedEntity()

#   createBeam(
#     getAllPlayers(),
#     Beam.BAD,
#     eventPlayer.getEyePosition(),
#     raycast(
#       eventPlayer.getEyePosition(),
#       eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 200,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     Color.RED,
#     EffectReeval.COLOR
#   )
#   eventPlayer.HUDs[HI.DEBUG2] = getLastCreatedEntity()

#   createEffect(
#     getAllPlayers(),
#     Effect.SPHERE,
#     Color.GREEN,
#     raycast(
#       temp1,
#       temp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     0.1,
#     EffectReeval.VISIBILITY_AND_COLOR
#   )
#   eventPlayer.HUDs[HI.DEBUG3] = getLastCreatedEntity()


# rule "Debug: persistent dot":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1

#   destroyEffect(eventPlayer.HUDs[HI.DEBUG4])
#   temp1 = eventPlayer.getEyePosition() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y], 0)

#   createEffect(
#     getAllPlayers(),
#     Effect.SPHERE,
#     Color.BLUE,
#     raycast(
#       temp1,
#       temp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     0.1,
#     EffectReeval.VISIBILITY_AND_COLOR
#   )


#   eventPlayer.HUDs[HI.DEBUG4] = getLastCreatedEntity()

#   wait(0.02)
#   loop()

# rule "In Aim":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1

#   hudSubtext(
#     getPlayersInSlot(0, Team.1),
#     "in Aim: {0}".format(eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(getOppositeTeam(eventPlayer.getTeam())), 3)),
#     HudPosition.TOP,
#     9,
#     Color.WHITE,
#     HudReeval.VISIBILITY_AND_STRING
#   )

