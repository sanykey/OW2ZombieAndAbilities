#!mainFile "../main.opy"

#abilState0 used in bots/zombie behavior.opy:rule "Bots attack near player"
 
rule "[Wuyang] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.WUYANG

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg395fb3FF>Wuyang</fg>:\n
  ".format(
    heroIcon(Hero.WUYANG)
  )

  waitUntil(not ruleCondition, INFINITY)
  clearHeroInfo()

rule "[Wuyang] Double jump":
  @Event eachPlayer
  @Hero wuyang
  @Condition eventPlayer.isUsingAbility1()
  @Condition eventPlayer.isHoldingButton(Button.JUMP)
  @Condition eventPlayer.getAltitude() > 0.8
  
  smallMessage(eventPlayer, "JUMP")
  waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isOnGround(), INFINITY)
  smallMessage(eventPlayer, "1")
  if eventPlayer.isInAir() or not eventPlayer.hasStatus(Status.STUNNED):
    if not eventPlayer.isHoldingButton(Button.JUMP):
      smallMessage(eventPlayer, "return")
      return
    smallMessage(eventPlayer, "^^^^")
    eventPlayer.applyImpulse(Vector.UP, 11, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(eventPlayer, DynamicEffect.TRACER_RECALL_REAPPEAR_SOUND, Color.WHITE, eventPlayer, 200)
    wait(0.3)
    waitUntil(eventPlayer.isOnGround(), INFINITY)