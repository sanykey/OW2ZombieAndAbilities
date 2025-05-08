#!mainFile "main.opy"

rule "Bots antifall safety and fall damage after cc damage from players":
  @Event eachPlayer
  @Team 2

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
    if eventPlayer.state[SI.LAST_CC_ATTACK_TIME] >= getTotalTimeElapsed():
      # If the bot has less health than the expected damage, then just let the bot fall down
      if eventPlayer.getHealth() > ceil(ZOMBIE_FALL_DAMAGE * (eventPlayer.state[SI.LAST_CC_ATTACKER].damageStat / 100)):
        damage(eventPlayer, eventPlayer.state[SI.LAST_CC_ATTACKER], ZOMBIE_FALL_DAMAGE)
        eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.state[SI.LAST_CC_ATTACK_TIME] = false
      else:
        eventPlayer.setEnvironmentalKillCreditor(eventPlayer.state[SI.LAST_CC_ATTACKER])
    else:
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  wait(0.2)
  loop()

rule "Warning icon for zombies ":
  @Event eachPlayer
  @Team 2

  # bot target warning icon (flashing)
  createIcon(
    [player for player in getPlayers(Team.1) if eventPlayer.isAlive() and distance(eventPlayer, player) < 10 and not player.isInViewAngle(eventPlayer.getPosition(), 55)],
    eventPlayer,
    Icon.WARNING,
    IconReeval.VISIBILITY_POSITION_AND_COLOR,
    Color.RED if (((ceil(getTotalTimeElapsed() * (4 if distance(eventPlayer.getPosition(), localPlayer.getPosition()) > 10 else 8))) % 2) == 0) else Color.YELLOW
  )

rule "Bots face nearest players and move":
  @Event eachPlayer
  @Team 2
  
  # Bots move toward players
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  # Bots face nearest players
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(),
      ((
        sorted(
          [player for player in getLivingPlayers(Team.1) if player.isAlive()],
          lambda i: distance(eventPlayer, i) + (
            10 if not isInLoS(eventPlayer, i) else 0
          ) + (
            50 if i.state[SI.IS_INVISIBLE] and (distance(eventPlayer, i) > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
          )
        )
      )[0]).getEyePosition()
    ), 400
  )

  # eventPlayer.setFacing(
  #   directionTowards(eventPlayer.getEyePosition(),
  #   (getClosestPlayer(((sorted([player for player in getLivingPlayers(Team.1) if player.isAlive()], lambda i: distance(eventPlayer, i)))[0]).getEyePosition(), Team.1)).getEyePosition()),
  #   Relativity.TO_WORLD
  # )


rule "Bots attack near player":
  @Event eachPlayer
  @Team 2
  @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == true

  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)

  waitUntil(getPlayersInRadius(eventPlayer, 4, Team.1) == false)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)


rule "Bots use ultimate at 100%":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getUltCharge() == 100

  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.5)
  eventPlayer.stopForcingButton(Button.ULTIMATE)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START

rule "TP zombies - out of map safety":
  @Event eachPlayer
  @Team 2
  @Condition (
    eventPlayer.isAlive() and eventPlayer.abilTemp1 and eventPlayer.abilTemp1 < getTotalTimeElapsed()
  )
  smallMessage(getAllPlayers(), "teleport: out of map safety")
  eventPlayer.abilTemp1 = 30 + getTotalTimeElapsed()
  eventPlayer.teleport(nearestWalkablePosition(eventPlayer))

rule "Bots moves":
  @Event eachPlayer
  @Team 2

  if not eventPlayer.isAlive():
    goto lbl_0

  if eventPlayer.money >= 10:
    smallMessage(getAllPlayers(), "random teleport (money)")
    eventPlayer.teleport(random.choice(Y))
    eventPlayer.money = 0
    eventPlayer.abilTemp1 = 30 + getTotalTimeElapsed()
    goto lbl_0

  eventPlayer.temp1 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)

  # Bots under player impulse
  if eventPlayer.getVerticalFacingAngle() < -70 and getClosestPlayer(eventPlayer, Team.1).isUsingUltimate() == false: # no need to jump after players who use ultimates (doomfist, mercy and etc)
    smallMessage(getAllPlayers(), "Bots under player impulse")
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    eventPlayer.applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  # try to jump if the movement has slowed down
  # elif eventPlayer.getSpeed() < 0.5 and not eventPlayer.isHoldingButton(Button.JUMP):
  #   smallMessage(getAllPlayers(), "jump, speed < 0.25")
  #   eventPlayer.forceButtonPress(Button.JUMP)

  if eventPlayer.abilPos0 and distance(eventPlayer.abilPos0, eventPlayer.temp1) < 1:
    # smallMessage(getAllPlayers(), "no move?, {} = {}".format(eventPlayer.abilPos0, eventPlayer.temp1))
    eventPlayer.money += 1
    eventPlayer.forceButtonPress(Button.JUMP)
  else:
    eventPlayer.abilPos0 = eventPlayer.temp1
    eventPlayer.money = 0

  # if eventPlayer.money > 0 and distance(eventPlayer, getClosestPlayer(eventPlayer, Team.1)) <= 8:
  #   smallMessage(getAllPlayers(), "set money = 0")
  #   eventPlayer.money = 0
  # elif eventPlayer.money >= 5:
  #   smallMessage(getAllPlayers(), "random teleport")
  #   eventPlayer.teleport(random.choice(Y))
  #   eventPlayer.money = 0
  #   goto lbl_0

  # if eventPlayer.getSpeed() < 0.25 and not eventPlayer.isHoldingButton(Button.JUMP):
  #   smallMessage(getAllPlayers(), "jump, speed < 0.25")
  #   eventPlayer.forceButtonPress(Button.JUMP)
  #   eventPlayer.money += 1
  # else:
  #   eventPlayer.money = 0

  

  lbl_0:
  wait(0.5)
  loop()


rule "zombies fly faster":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.zombiesfly == true
  @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.1)) > 35
  
  wait(0.2)
  eventPlayer.applyImpulse(Vector.FORWARD, 40, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1)
  if RULE_CONDITION:
      goto RULE_START

rule "Zombies loS teleport":
  @Event eachPlayer
  @Team 2
  @Hero torbjorn
  @Condition eventPlayer.isAlive() == true
  @Condition isInLoS(eventPlayer, getClosestPlayer(eventPlayer, Team.1)) == false
  
  wait(5, Wait.ABORT_WHEN_FALSE)
  eventPlayer.zombiesfly = true
  eventPlayer.disallowButton(Button.PRIMARY_FIRE)
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), ((sorted([player for player in getLivingPlayers(Team.1) if player.T == 0], lambda i: distance(eventPlayer, i)))[0]).getEyePosition()), 25, 20, Relativity.TO_WORLD)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  wait(0.2)
  eventPlayer.applyImpulse(Vector.FORWARD, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setInvisibility(Invis.ALL)
  waitUntil(isInLoS(eventPlayer, getClosestPlayer(eventPlayer, Team.1)), 30)
  eventPlayer.zombiesfly = false
  wait(0.4)
  eventPlayer.setGravity(100)
  eventPlayer.enableEnvironmentCollision()
  eventPlayer.stopAcceleration()
  eventPlayer.teleport(nearestWalkablePosition(eventPlayer))
  eventPlayer.applyImpulse(Vector.DOWN, 10, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(0.1)
  eventPlayer.setInvisibility(Invis.NONE)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayersInRadius(eventPlayer, 10, Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 80)
  eventPlayer.setStatusEffect(null, Status.ROOTED, 1)
  wait(1.2)
  eventPlayer.allowButton(Button.PRIMARY_FIRE)
  eventPlayer.enablePlayerCollision()
  if RULE_CONDITION:
      goto RULE_START




# rule "TP Dead Zombies":
#   @Event eachPlayer
#   @Team 2
#   @Condition eventPlayer.isDead() == true
  
#   wait(1.2)
#   if not RULE_CONDITION:
#       return
#   wait(0.8)
#   if not RULE_CONDITION:
#       return
#   eventPlayer.teleport(vect(0, -500, 0))
#   if RULE_CONDITION:
#       goto RULE_START


