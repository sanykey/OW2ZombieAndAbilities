#!mainFile "main.opy"

rule "Enable 3P Camera":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.stopCamera()
  wait(0.5)
  eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.1, 0.8, -0.3), eventPlayer, Transform.ROTATION) + Vector.UP * 1.25 + eventPlayer.getFacingDirection() * -1.7, eventPlayer + eventPlayer.getFacingDirection() * 60)
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [ON]")
  smallMessage(eventPlayer, "Hold for a higher angle")
  wait(3)
  if not RULE_CONDITION:
      return
  eventPlayer.startCamera(eventPlayer + worldVector(vect(-0.3, 1, -0.5), eventPlayer, Transform.ROTATION) + Vector.UP * 1.45 + eventPlayer.getFacingDirection() * -1.9, eventPlayer + eventPlayer.getFacingDirection() * 60)
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")


rule "Disable 3P Camera":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  wait(2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.stopCamera()
  playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  smallMessage(eventPlayer, "3P Camera [OFF]")

rule "Pause 3P camera during emote":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isCommunicatingEmote() == true
  
  eventPlayer.stopCamera()


rule "Stop 3P Camera On Death":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isDead() == true
  
  eventPlayer.stopCamera()

rule "[Bastion] Stop 3P Camera During Ultimate":
  @Event eachPlayer
  @Team 1
  @Hero bastion
  @Condition eventPlayer.isUsingUltimate() == true
  
  eventPlayer.stopCamera()

rule "[Junkrat] Stop 3P Camera During Ultimate":
  @Event eachPlayer
  @Team 1
  @Hero junkrat
  @Condition eventPlayer.isUsingUltimate() == true
  
  eventPlayer.stopCamera()