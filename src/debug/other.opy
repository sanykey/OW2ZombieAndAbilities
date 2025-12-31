#!mainFile "../main.opy"

# rule "[debug]":
#   @Event eachPlayer
#   @Team 1
#   debug(hostPlayer.getFacingDirection())

# rule "[debug] Charge ultimate":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
#   eventPlayer.setUltCharge(100)

#   damage([player for player in getPlayers(Team.1) if player.isDummy()], null, INFINITY)
  

# rule "[debug] Create ally dummy":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer == hostPlayer
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
#   @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
  
#   createDummy(eventPlayer.getHero(), Team.1, getNumberOfPlayers(Team.1), nearestWalkablePosition(hostPlayer), hostPlayer.getPosition())

# rule "[debug] Kill random ally dummy":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer == hostPlayer
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
#   @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
  
#   eventPlayer.tmp1 = random.choice([player for player in getLivingPlayers(Team.1) if player.isDummy()])
#   destroyDummy(Team.1, eventPlayer.tmp1.getSlot())


# rule "[debug] debug objects":
#   debug(hostPlayer.isCommunicatingEmote())
#   debug(hostPlayer.isCommunicatingVoiceline())
#   debug(getPlayersInSlot(0, Team.2).zombiesfly)
#   debug(getPlayersInSlot(0, Team.2).money)
#   debug(getPlayersInSlot(0, Team.2).abilTemp1)
#   debug(getTotalTimeElapsed())
#   debug(getPlayersInSlot(0, Team.2).abilPos0)
#   debug(isInLoS(getPlayersInSlot(0, Team.2), getPlayersInSlot(0, Team.2).target0))

  # debug(secretShopZoneEffects)
  # debug(zonesHeroBuyLen)
  # debug(zonesHeroBuyOffset)
  # debug(hostPlayer.purchasedHeroes)

# rule "[debug] Kill random zombie":
#   @Event eachPlayer
#   @Team 1
#   @Condition eventPlayer == hostPlayer
#   @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
  
#   eventPlayer.tmp1 = random.choice(getLivingPlayers(Team.2))
#   damage(eventPlayer.tmp1, eventPlayer, 99999)

# rule "[debug] show current position":
  # hudSubtext(
  #   getPlayersInSlot(0, Team.1),
  #   "P0: {0}".format(getPlayersInSlot(0, Team.1).getEyePosition()),
  #   HudPosition.TOP,
  #   -10,
  #   Color.WHITE,
  #   HudReeval.VISIBILITY_AND_STRING
  # )
  # debug(getPlayersInSlot(0, Team.1).getEyePosition())
  # debug(getPlayersInSlot(0, Team.1).getPosition())
  

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

#   destroyEffect(eventPlayer.effectsIds[HI.DEBUG])
#   destroyEffect(eventPlayer.effectsIds[HI.DEBUG2])
#   destroyEffect(eventPlayer.effectsIds[HI.DEBUG3])

#   wait(2)
#   createBeam(
#     getAllPlayers(),
#     Beam.TORBJORN_TURRET_SIGHT,
#     eventPlayer.getEyePosition() + vect(0, -0.45, 0),
#     eventPlayer.raycast[RI.FACING_DIRECTION] * 50,
#     Color.TEAM_2,
#     EffectReeval.COLOR
#   )
#   eventPlayer.effectsIds[HI.DEBUG] = getLastCreatedEntity()

#   createBeam(
#     getAllPlayers(),
#     Beam.BAD,
#     eventPlayer.getEyePosition() + vect(0, -0.45, 0),
#     eventPlayer.raycast[RI.RESULT],
#     Color.TEAM_1,
#     EffectReeval.COLOR
#   )
#   eventPlayer.effectsIds[HI.DEBUG2] = getLastCreatedEntity()
  

  # tmp1 = eventPlayer.getEyePosition() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y], 0)

#   createBeam(
#     getAllPlayers(),
#     Beam.BAD,
#     eventPlayer.getEyePosition(),
#     raycast(
#       tmp1,
#       tmp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     Color.GREEN,
#     EffectReeval.COLOR
#   )
#   eventPlayer.effectsIds[HI.DEBUG] = getLastCreatedEntity()

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
#   eventPlayer.effectsIds[HI.DEBUG2] = getLastCreatedEntity()

#   createEffect(
#     getAllPlayers(),
#     Effect.SPHERE,
#     Color.GREEN,
#     raycast(
#       tmp1,
#       tmp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     0.1,
#     EffectReeval.VISIBILITY_AND_COLOR
#   )
#   eventPlayer.effectsIds[HI.DEBUG3] = getLastCreatedEntity()


# rule "Debug: persistent dot":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1

#   destroyEffect(eventPlayer.effectsIds[HI.DEBUG4])
#   tmp1 = eventPlayer.getEyePosition() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_EYE_POSITION_Y], 0)

#   createEffect(
#     getAllPlayers(),
#     Effect.SPHERE,
#     Color.BLUE,
#     raycast(
#       tmp1,
#       tmp1 + ((eventPlayer.getFacingDirection() + vect(0, eventPlayer.state[SI.RAYCAST_CALIBRATION_FACING_DIRECTION_Y], 0)) * 200)
# ,
#       getAllPlayers(),
#       eventPlayer,
#       true
#     ).getHitPosition(),
#     0.1,
#     EffectReeval.VISIBILITY_AND_COLOR
#   )


#   eventPlayer.effectsIds[HI.DEBUG4] = getLastCreatedEntity()

#   wait(0.02)
#   loop()

# rule "In Aim":
#   @Event eachPlayer
#   @Slot 0
#   @Team 1

#   hudSubtext(
#     getPlayersInSlot(0, Team.1),
#     "in Aim: {0}".format(eventPlayer.isInViewAngle(eventPlayer.getRealPlayerClosestToReticle(getOppositeTeam(eventPlayer.getTeam())), 3)),
#     HudPosition.TOP,
#     9,
#     Color.WHITE,
#     HudReeval.VISIBILITY_AND_STRING
#   )

