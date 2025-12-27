#!mainFile "main.opy"

playervar prevCameraState
playervar cameraState

enum Camera:
  DEFAULT
  CLOSE
  FAR 
  OFF_DEFAULT
  OFF_CLOSE
  OFF_FAR

def pause3PCamera():
  @Name "Subroutine: Pause [3rd person camera]"
  if eventPlayer.cameraState < Camera.OFF_DEFAULT:
    eventPlayer.cameraState = eventPlayer.cameraState + Camera.OFF_DEFAULT

def unpause3PCamera():
  @Name "Subroutine: Unpause [3rd person camera]"
  if eventPlayer.cameraState >= Camera.OFF_DEFAULT:
    eventPlayer.cameraState = eventPlayer.cameraState - Camera.OFF_DEFAULT

rule "[3rd person camera] hold button":
  @Event eachPlayer
  @Condition eventPlayer.isHoldingButton(Button.MELEE)
  @Condition eventPlayer.hasSpawned()
  @Condition eventPlayer.isAlive()
  
  wait(0.5, Wait.ABORT_WHEN_FALSE)

  while ruleCondition:
    if eventPlayer.cameraState >= Camera.FAR:
      eventPlayer.cameraState = Camera.DEFAULT
    else:
      eventPlayer.cameraState++

    if eventPlayer.cameraState == Camera.CLOSE:
      smallMessage(eventPlayer, " 3rd Person, Close")
    elif eventPlayer.cameraState == Camera.FAR:
      smallMessage(eventPlayer, " 3rd Person, Higher Angle")
    elif eventPlayer.cameraState == Camera.DEFAULT:
      smallMessage(eventPlayer, " Default Camera")

    wait(0.8, Wait.ABORT_WHEN_FALSE)


rule "[3rd person camera] Change state":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState != eventPlayer.prevCameraState

  eventPlayer.prevCameraState = eventPlayer.cameraState
  if eventPlayer.cameraState == Camera.CLOSE:
    eventPlayer.startCamera(
      eventPlayer + worldVector(vect(-0.1, 0.8, -0.3), eventPlayer, Transform.ROTATION) + Vector.UP * 1.25 + eventPlayer.getFacingDirection() * -1.7,
      eventPlayer + eventPlayer.getFacingDirection() * 60
    )
  elif eventPlayer.cameraState == Camera.FAR:
    eventPlayer.startCamera(
      eventPlayer + worldVector(vect(-0.3, 1, -0.5), eventPlayer, Transform.ROTATION) + Vector.UP * 1.45 + eventPlayer.getFacingDirection() * -1.9,
      eventPlayer + eventPlayer.getFacingDirection() * 60
    )
  else:
    eventPlayer.stopCamera()


rule "[3rd person camera] Pause camera when player is aiming (for Ana, Ashe, Widowmaker)":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState
  @Condition eventPlayer.isFiringSecondaryFire()
  @Condition (
    eventPlayer.getCurrentHero() == Hero.WIDOWMAKER
    or eventPlayer.getCurrentHero() == Hero.ASHE
    or eventPlayer.getCurrentHero() == Hero.ANA
  )

  pause3PCamera()
  waitUntil(eventPlayer.isFiringSecondaryFire() == false, INFINITY)
  unpause3PCamera()

rule "[3rd person camera] Pause camera and charge ult during emote":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState
  @Condition eventPlayer.isCommunicatingEmote()

  pause3PCamera()
  wait()
  while "{}".format(eventPlayer.isCommunicatingEmote()) != "0": 
    eventPlayer.setUltCharge(eventPlayer.getUltCharge() + 1)
    waitUntil("{}".format(eventPlayer.isCommunicatingEmote()) == "0", EMOTE_ULT_CHARE_PER_SECONDS)

  unpause3PCamera()

rule "[3rd person camera] Pause Camera During Ultimate (junkrat and bastion)":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState
  @Condition eventPlayer.isUsingUltimate()
  @Condition (
    eventPlayer.getCurrentHero() == Hero.BASTION or
    eventPlayer.getCurrentHero() == Hero.JUNKRAT or
    eventPlayer.getCurrentHero() == Hero.DOOMFIST
  )
  
  pause3PCamera()
  waitUntil(eventPlayer.isUsingUltimate() == false, INFINITY)
  unpause3PCamera()

rule "[3rd person camera] Pause camera during rein barrier hold":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.cameraState
  @Condition eventPlayer.getCurrentHero() == Hero.REINHARDT or eventPlayer.getCurrentHero() == Hero.BRIGITTE
  @Condition eventPlayer.isFiringSecondaryFire()

  pause3PCamera()
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  unpause3PCamera()