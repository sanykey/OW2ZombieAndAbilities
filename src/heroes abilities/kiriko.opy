#!mainFile "../main.opy"
#!optimizeForSize
#!define KIR_ALT_SWIFT_STEP_CD 12
#!define KIR_ALT_SWIFT_STEP_DISTANCE 15

rule "[Kiriko] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.KIRIKO

  setHeroInfoText0(
    f"{heroIcon(Hero.KIRIKO)} <fgd4878fFF>Kiriko</fg>:\n
    {abilityIconString(Hero.KIRIKO, Button.ABILITY_1)} <fgd4878fFF>Swift step</fg>:
      - Can teleport forward without targeting an ally. Increased cooldown: 12 seconds.
    ", -3
  )

  waitUntil(eventPlayer.getHero() != Hero.KIRIKO, INFINITY)
  clearHeroInfoSub()


rule "[Kiriko] Teleport":
  @Event eachPlayer
  @Hero kiriko
  @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) <= 0

  wait()
  if (eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0):
    return
  
  eventPlayer.applyImpulse(Vector.UP, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 10)
  playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 200)
  playEffect(eventPlayer, DynamicEffect.BAD_EXPLOSION, Color.WHITE, eventPlayer, 200)
  
  eventPlayer.teleport(
    raycast(
      eventPlayer.getPosition(), eventPlayer.getFacingDirection() * KIR_ALT_SWIFT_STEP_DISTANCE + eventPlayer.getPosition(), null, eventPlayer, true
    ).getHitPosition()
  )
  playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 10)
  eventPlayer.setAbilityCooldown(Button.ABILITY_1, KIR_ALT_SWIFT_STEP_CD)
  waitUntil(eventPlayer.isOnGround(), 4)
  if distance(eventPlayer, nearestWalkablePosition(eventPlayer)) >= 0.6:
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer))