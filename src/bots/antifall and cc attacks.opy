#!mainFile "../main.opy"

rule "Bots Antifall and fall damage from cc attacks from players":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER
  @Condition eventPlayer.isAlive()

  wait(0.2)
  eventPlayer.abilState0 = false
  # For the starting location. Which is the lowest and the height of the fatal fall into the abyss starts noticeably lower:
  if eventPlayer.getPosition().x < 0 and eventPlayer.getPosition().z > -35: 
    if eventPlayer.getPosition().y < -6:
      eventPlayer.abilState0 = true
  elif eventPlayer.getPosition().x > 43: # ZONE B
    if eventPlayer.getPosition().y < 4.7:
      eventPlayer.abilState0 = true
  else:
    if eventPlayer.getPosition().y < 0: # Other
      eventPlayer.abilState0 = true

  if not eventPlayer.abilState0:
    goto RULE_START

  # If the player was dealing cc damage before the bot fell, then try to deal damage to the bot from the fall
  if eventPlayer.lastCcAttackTime >= getTotalTimeElapsed():

    # Allow the bot to fall if expected fall damage is greater than its current health
    if eventPlayer.getHealth() < ZOMBIE_FALL_DAMAGE * eventPlayer.lastCcAttacker.damageBoostPercent / 100:

      # If no vanilla knockback would grant the kill, assign it using setEnvironmentalKillCreditor
      if not eventPlayer.lastCcVanilaKnockback:
        eventPlayer.setEnvironmentalKillCreditor(eventPlayer.lastCcAttacker)
      goto RULE_START

    else:
      damage(eventPlayer, eventPlayer.lastCcAttacker, ZOMBIE_FALL_DAMAGE)
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
      eventPlayer.lastCcAttackTime = false
  else:
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  if ruleCondition:
    loop()