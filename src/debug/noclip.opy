#!mainFile "../main.opy"

rule "[debug] toggle noclip":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ULTIMATE)
  
  debugIsNoclip = not debugIsNoclip
  if not debugIsNoclip:
    eventPlayer.clearStatusEffect(Status.INVINCIBLE)
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.setUltCharge(0)
    kill(eventPlayer)
    eventPlayer.resurrect()
    eventPlayer.setGravity(100)
    wait()
    eventPlayer.downedStartTime = false
  else:
    eventPlayer.startForcingHero(Hero.MERCY)
    wait()
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INFINITY)
    eventPlayer.setUltCharge(100)
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.setGravity(0)

rule "[debug] refresh noclip":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer == hostPlayer
  @Condition debugIsNoclip != false
  @Condition eventPlayer.isUsingUltimate() == false
  
  eventPlayer.setUltCharge(100)
  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.4)
  eventPlayer.setStatusEffect(null, Status.HACKED, 0.05)