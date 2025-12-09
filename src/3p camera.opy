#!mainFile "main.opy"

playervar prevCameraState
playervar cameraState
  # 0: OFF
  # 1: Temporary OFF
  # 2: Temporary OFF higher angle
  # 3: ON
  # 4: ON higher angle


def pause3PCamera():
  @Name "Subroutine: Pause 3P Camera"
  if eventPlayer.cameraState == 3:
    eventPlayer.cameraState = 1
  else:
    if eventPlayer.cameraState == 4:
      eventPlayer.cameraState = 2

def unpause3PCamera():
  @Name "Subroutine: Unpause 3P Camera"

  if eventPlayer.cameraState == 1:
    eventPlayer.cameraState = 3
    return

  if eventPlayer.cameraState == 2:
    eventPlayer.cameraState = 4


rule "Change 3p Camera state":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState != eventPlayer.prevCameraState

  eventPlayer.prevCameraState = eventPlayer.cameraState
  if eventPlayer.cameraState == 3:
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.1, 0.8, -0.3), eventPlayer, Transform.ROTATION) + Vector.UP * 1.25 + eventPlayer.getFacingDirection() * -1.7, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return

  if eventPlayer.cameraState == 4:
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.3, 1, -0.5), eventPlayer, Transform.ROTATION) + Vector.UP * 1.45 + eventPlayer.getFacingDirection() * -1.9, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return
  eventPlayer.stopCamera()

# rule "Switch 3P Camera (INTERACT + CROUCH)":
#   @Event eachPlayer
#   @Condition not eventPlayer.isDummy()
#   @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.CROUCH)

#   waitUntil(
#     (
#       not (eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.INTERACT)) or 
#       eventPlayer.isHoldingButton(Button.MELEE)
#     ),
#     HERO_INFO_HOLD_DURATION
#   )

#   # The player has called up the hero information window, the camera does not need to be changed
#   if (eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isHoldingButton(Button.MELEE)): 
#     return

#   if eventPlayer.cameraState == 0:
#     eventPlayer.cameraState = 3
#     smallMessage(eventPlayer, "3P Camera [ON]")
#   elif eventPlayer.cameraState == 3:
#     eventPlayer.cameraState = 4
#     smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")
#   else:
#     eventPlayer.cameraState = 0
#     smallMessage(eventPlayer, "3P Camera [OFF]")
#   playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)

rule "Pause 3p camera when player is aiming (for Ana, Ashe, Widowmaker)":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState > 2
  @Condition eventPlayer.isFiringSecondaryFire() == true # @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  @Condition (eventPlayer.getCurrentHero() == Hero.WIDOWMAKER or eventPlayer.getCurrentHero() == Hero.ASHE or eventPlayer.getCurrentHero() == Hero.ANA) == true

  pause3PCamera()
  waitUntil(eventPlayer.isFiringSecondaryFire() == false, INFINITY)
  unpause3PCamera()

rule "Pause 3P camera and charge ult during emote":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState > 2
  @Condition eventPlayer.isCommunicatingEmote()

  pause3PCamera()
  wait()
  while "{}".format(eventPlayer.isCommunicatingEmote()) != "0": 
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + 1)
    waitUntil("{}".format(eventPlayer.isCommunicatingEmote()) == "0", EMOTE_ULT_CHARE_PER_SECONDS)

  unpause3PCamera()

rule "Pause 3P Camera During Ultimate (junkrat and bastion)":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState > 2
  @Condition eventPlayer.isUsingUltimate()
  @Condition (
    eventPlayer.getCurrentHero() == Hero.BASTION or
    eventPlayer.getCurrentHero() == Hero.JUNKRAT or
    eventPlayer.getCurrentHero() == Hero.DOOMFIST
  ) == true
  
  pause3PCamera()
  waitUntil(eventPlayer.isUsingUltimate() == false, INFINITY)
  unpause3PCamera()

rule "Pause 3P camera during rein barrier hold":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState > 2
  @Condition eventPlayer.getCurrentHero() == Hero.REINHARDT or eventPlayer.getCurrentHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  pause3PCamera()
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  unpause3PCamera()