#!mainFile "main.opy"

def pause3PCamera():
  @Name "Subroutine: Pause 3P Camera"
  if eventPlayer.state[0] == 3:
    eventPlayer.state[0] = 1
  else:
    if eventPlayer.state[0] == 4:
      eventPlayer.state[0] = 2

def unpause3PCamera():
  @Name "Subroutine: Unpause 3P Camera"

  if eventPlayer.state[0] == 1:
    eventPlayer.state[0] = 3
    return

  if eventPlayer.state[0] == 2:
    eventPlayer.state[0] = 4


rule "Change 3p Camera state":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[0] != eventPlayer.state[1]

  eventPlayer.state[1] = eventPlayer.state[0]
  if eventPlayer.state[0] == 3:
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.1, 0.8, -0.3), eventPlayer, Transform.ROTATION) + Vector.UP * 1.25 + eventPlayer.getFacingDirection() * -1.7, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return

  if eventPlayer.state[0] == 4:
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.3, 1, -0.5), eventPlayer, Transform.ROTATION) + Vector.UP * 1.45 + eventPlayer.getFacingDirection() * -1.9, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return
  eventPlayer.stopCamera()

rule "Enable 3P Camera (Interact + R)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.downedStartTime == false
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.state[0] = 0
  wait(0.5)
  eventPlayer.state[0] = 3
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [ON]")
  smallMessage(eventPlayer, "Hold for a higher angle")
  wait(3)
  if not RULE_CONDITION:
      return
  eventPlayer.state[0] = 4
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")

rule "Pause 3p camera when player is aiming (for Ana, Ashe, Widowmaker)":
  @Event eachPlayer
  @Condition eventPlayer.state[0] > 2
  @Condition eventPlayer.isFiringSecondaryFire() == true # @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  @Condition (eventPlayer.getCurrentHero() == Hero.WIDOWMAKER or eventPlayer.getCurrentHero() == Hero.ASHE or eventPlayer.getCurrentHero() == Hero.ANA) == true

  pause3PCamera()
  waitUntil(eventPlayer.isFiringSecondaryFire() == false, INFINITY)
  unpause3PCamera()


rule "Disable 3P Camera":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.state[0] = 0
  eventPlayer.stopCamera()
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [OFF]")

rule "Pause 3P camera during emote":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[0] > 2
  @Condition eventPlayer.isCommunicatingEmote() == true

  pause3PCamera()
  waitUntil(eventPlayer.isCommunicatingEmote() == false, INFINITY)
  unpause3PCamera()

rule "Pause 3P Camera During Ultimate (junkrat and bastion)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[0] > 2
  @Condition eventPlayer.isUsingUltimate() == true
  @Condition (eventPlayer.getCurrentHero() == Hero.BASTION or eventPlayer.getCurrentHero() == Hero.JUNKRAT) == true
  
  pause3PCamera()
  waitUntil(eventPlayer.isUsingUltimate() == false, INFINITY)
  unpause3PCamera()

rule "Pause 3P camera during rein shild hold":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state[0] > 2
  @Condition eventPlayer.getCurrentHero() == Hero.REINHARDT
  @Condition eventPlayer.isFiringSecondaryFire()

  pause3PCamera()
  waitUntil(not eventPlayer.isFiringSecondaryFire(), INFINITY)
  unpause3PCamera()