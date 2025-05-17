#!mainFile "../main.opy"

rule "[Kiriko] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.KIRIKO

  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fgd4878fFF>Kiriko</fg>:\n
  {} {}Swift step{}:
    - Can teleport forward without targeting an ally. Increased cooldown: 12 seconds.
  ".format(
    heroIcon(Hero.KIRIKO),
    abilityIconString(Hero.KIRIKO, Button.ABILITY_1),
    "<fgd4878fFF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.KIRIKO, INFINITY)
  clearHeroInfo()


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
      eventPlayer.getPosition(), eventPlayer.getFacingDirection() * 15 + eventPlayer.getPosition(), null, eventPlayer, true
    ).getHitPosition()
  )
  playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 10)
  eventPlayer.setAbilityCooldown(Button.ABILITY_1, 12)
  waitUntil(eventPlayer.isOnGround(), 4)
  if distance(eventPlayer, nearestWalkablePosition(eventPlayer)) >= 0.6:
      eventPlayer.teleport(nearestWalkablePosition(eventPlayer))