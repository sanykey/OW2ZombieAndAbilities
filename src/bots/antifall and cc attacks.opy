#!mainFile "../main.opy"

# save information about bots being pushed to account for damage when falling down
macro Player.setCrowdControlAttack(self, attacker0, duration=LAST_CC_ATTACK_DURATION):
  self.lastCcAttacker = attacker0
  self.lastCcAttackTime = duration + getTotalTimeElapsed()
  self.lastCcWasInAir = self.isInAir()

rule "Bots Antifall and fall damage from cc attacks from players":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.downedStartTime

  eventPlayer.temp1 = false
  # For the starting location. Which is the lowest and the height of the fatal fall into the abyss starts noticeably lower:
  if eventPlayer.getPosition().x < 0 and eventPlayer.getPosition().z > -35: 
    if eventPlayer.getPosition().y < -6:
      eventPlayer.temp1 = true
  elif eventPlayer.getPosition().x > 43: # ZONE B
    if eventPlayer.getPosition().y < 4.7:
      eventPlayer.temp1 = true
  else:
    if eventPlayer.getPosition().y < 0: # Other
      eventPlayer.temp1 = true

  if eventPlayer.temp1:
    # If the player was dealing cc damage before the bot fell, then try to deal damage to the bot from the fall
    if eventPlayer.lastCcAttackTime >= getTotalTimeElapsed():
      eventPlayer.setEnvironmentalKillCreditor(eventPlayer.lastCcAttacker) # Just to be safe.

      damage(eventPlayer, eventPlayer.lastCcAttacker, ZOMBIE_FALL_DAMAGE)
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
      eventPlayer.lastCcAttackTime = false
    else:
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  wait(0.2)
  loop()