#!mainFile "main.opy"

rule "Change 3p Camera state":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state_arr[0] != eventPlayer.state_arr[1]

  eventPlayer.state_arr[1] = eventPlayer.state_arr[0]
  if eventPlayer.state_arr[0] == 3:
    smallMessage(eventPlayer, l"{0}: {1}".format("ON", eventPlayer.state_arr[0]))
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.1, 0.8, -0.3), eventPlayer, Transform.ROTATION) + Vector.UP * 1.25 + eventPlayer.getFacingDirection() * -1.7, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return

  if eventPlayer.state_arr[0] == 4:
    smallMessage(eventPlayer, l"{0}: {1}".format("ON HA", eventPlayer.state_arr[0]))
    eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.3, 1, -0.5), eventPlayer, Transform.ROTATION) + Vector.UP * 1.45 + eventPlayer.getFacingDirection() * -1.9, eventPlayer + eventPlayer.getFacingDirection() * 60)
    return

  smallMessage(eventPlayer, l"{0}: {1}".format("OFF", eventPlayer.state_arr[0]))
  eventPlayer.stopCamera()

rule "Enable 3P Camera (Interact + R)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.state_arr[0] = 0
  wait(0.5)
  eventPlayer.state_arr[0] = 3
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [ON]")
  smallMessage(eventPlayer, "Hold for a higher angle")
  wait(3)
  if not RULE_CONDITION:
      return
  eventPlayer.state_arr[0] = 4
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")

rule "Pause 3p camera when player is aiming (for Ana, Ashe, Widowmaker)":
  @Event eachPlayer
  @Condition eventPlayer.state_arr[0] > 2
  @Condition eventPlayer.isFiringSecondaryFire() == true # @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  @Condition (eventPlayer.getCurrentHero() == Hero.WIDOWMAKER or eventPlayer.getCurrentHero() == Hero.ASHE or eventPlayer.getCurrentHero() == Hero.ANA) == true

  if eventPlayer.state_arr[0] == 3:
    eventPlayer.state_arr[0] = 1
  else:
    if eventPlayer.state_arr[0] == 4:
      eventPlayer.state_arr[0] = 2
    else:
      return

  waitUntil(eventPlayer.isFiringSecondaryFire() == false, 99999)

  if eventPlayer.state_arr[0] == 1:
    eventPlayer.state_arr[0] = 3
    return

  if eventPlayer.state_arr[0] == 2:
    eventPlayer.state_arr[0] = 4


rule "Disable 3P Camera":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.state_arr[0] = 0
  eventPlayer.stopCamera()
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [OFF]")

rule "Pause 3P camera during emote":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state_arr[0] > 2
  @Condition eventPlayer.isCommunicatingEmote() == true

  if eventPlayer.state_arr[0] == 3:
    eventPlayer.state_arr[0] = 1
  else:
    if eventPlayer.state_arr[0] == 4:
      eventPlayer.state_arr[0] = 2
    else:
      return

  waitUntil(eventPlayer.isCommunicatingEmote() == false, 99999)

  if eventPlayer.state_arr[0] == 1:
    eventPlayer.state_arr[0] = 3
    return
  if eventPlayer.state_arr[0] == 2:
    eventPlayer.state_arr[0] = 4


rule "Stop 3P Camera On Death":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isDead() == true
  
  eventPlayer.state_arr[0] = 0

rule "Pause 3P Camera During Ultimate (junkrat and bastion)":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.state_arr[0] > 2
  @Condition eventPlayer.isUsingUltimate() == true
  @Condition (eventPlayer.getCurrentHero() == Hero.BASTION or eventPlayer.getCurrentHero() == Hero.JUNKRAT) == true
  
  if eventPlayer.state_arr[0] == 3:
    eventPlayer.state_arr[0] = 1
  else:
    if eventPlayer.state_arr[0] == 4:
      eventPlayer.state_arr[0] = 2
    else:
      return

  waitUntil(eventPlayer.isUsingUltimate() == false, 99999)

  if eventPlayer.state_arr[0] == 1:
    eventPlayer.state_arr[0] = 3
    return
  if eventPlayer.state_arr[0] == 2:
    eventPlayer.state_arr[0] = 4
