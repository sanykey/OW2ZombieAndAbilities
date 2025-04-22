#!mainFile "main.opy"

rule "Bots move toward players":
  @Event eachPlayer
  @Team 2
  @Condition matchIsOver == false
  
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)


rule "Bots face nearest players":
  @Event eachPlayer
  @Team 2
  @Condition matchIsOver == false
  
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), ((sorted([player for player in getLivingPlayers(Team.1) if player.downedStartTime == false], lambda i: distance(eventPlayer, i)))[0]).getEyePosition()), 400)
  eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (getClosestPlayer(((sorted([player for player in getLivingPlayers(Team.1) if player.downedStartTime == false], lambda i: distance(eventPlayer, i)))[0]).getEyePosition(), Team.1)).getEyePosition()), Relativity.TO_WORLD)


rule "Bots Unstuck [A]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getSpeed() < 0.25
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.forceButtonPress(Button.JUMP)


rule "Bots Unstuck [B]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.money += 1
    wait(15, Wait.ABORT_WHEN_FALSE)
    if eventPlayer.getSpeed() <= 0.5:
        goto lbl_0
    eventPlayer.money = 0
    lbl_0:


rule "Bots Unstuck [C]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.money >= 5
    @Condition getPlayersInRadius(eventPlayer, 8, Team.1) == false
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.teleport(random.choice(Y))
    eventPlayer.money = 0


rule "Bots Unstuck [D]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.1)) <= 8
    
    eventPlayer.money = 0


rule "Bots Unstuck [E]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer.getEyePosition(), raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100, null, eventPlayer, false).getHitPosition()) < 1
    @Condition eventPlayer.isAlive() == true
    
    wait(8, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(random.choice(Y))


rule "Bots attack near player":
    @Event eachPlayer
    @Team 2
    @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == true
    @Condition Hero.TORBJORN == true
    
    eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)


rule "Bots don't attack near player":
    @Event eachPlayer
    @Team 2
    @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == false
    
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)


rule "Bots use ultimate at 100%":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getUltCharge() == 100
    
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "Bots under player impulse":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getVerticalFacingAngle() < -70
    @Condition matchIsOver == false
    @Condition getClosestPlayer(eventPlayer, Team.1).isUsingUltimate() == false
    
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    eventPlayer.applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(1)
    eventPlayer.forceButtonPress(Button.ABILITY_1)

rule "Bots safety A":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(73.557, -8, -84.315)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 23, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety B":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(95.242, -8, -89.781)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety C":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(117.06, -2.181, -85.971)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety D":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(55.486, 1.618, -37.515)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety E":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(46.004, -7.45, -14.713)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety F":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(31.594, -7.571, 3.942)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety G":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(38.556, -7.571, -2.741)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety H":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(38.556, -30.571, -2.741)) < 30
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety I":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(-22.025, -0.631, -59.645)) < 12
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "Bots safety J":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(-6.388, -4.792, -109.846)) < 16
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


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
  @Condition eventPlayer.hasSpawned() == true
  @Condition eventPlayer.isAlive() == true
  @Condition eventPlayer.isDead() == false
  @Condition zombiesflyIOnandOff == true
  @Condition distance(getClosestPlayer(eventPlayer, Team.1), vect(-20.695, 7.574, -86.552)) > 14
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


rule "TP zombies - unstuck":
  (getPlayersInRadius(vect(3.091, 2.247, -17.704), 10, Team.2, LosCheck.SURFACES)).teleport(vect(1.132, 20.089, -19.823))
  (getPlayersInRadius(vect(-12.378, 5.097, -34.259), 5, Team.2)).teleport(vect(0.101, 23.998, -44.359))
  (getPlayersInRadius(vect(-1.145, 3.667, -39.316), 6, Team.2, LosCheck.SURFACES)).teleport(vect(-0.261, 22.204, -44.404))
  (getPlayersInRadius(vect(15.848, 7.994, -90.851), 10, Team.2, LosCheck.SURFACES)).teleport(vect(28.388, 23.999, -77.358))
  (getPlayersInRadius(vect(24.036, 8.27, -78.566), 5, Team.2, LosCheck.SURFACES)).teleport(vect(28.731, 23.782, -77.651))
  (getPlayersInRadius(vect(28.386, 12.384, -72.409), 7, Team.2, LosCheck.SURFACES)).teleport(vect(28.434, 24.681, -77.613))
  (getPlayersInRadius(vect(32.782, 12.895, -62.098), 10, Team.2, LosCheck.SURFACES)).teleport(vect(32.252, 28.811, -62.989))
  (getPlayersInRadius(vect(25.647, 7.127, -65.76), 4, Team.2, LosCheck.SURFACES)).teleport(vect(33.059, 29.8, -61.908))
  wait(3)
  (getPlayersInRadius(vect(31.289, 15.066, -80.316), 8, Team.2, LosCheck.SURFACES)).teleport(vect(28.742, 24.286, -75.762))
  (getPlayersInRadius(vect(48.269, 9.478, -82.557), 4, Team.2, LosCheck.SURFACES)).teleport(vect(40.025, 26.225, -89.891))
  (getPlayersInRadius(vect(58.067, 13.898, -83.654), 3, Team.2)).teleport(vect(59.735, 27.819, -94.077))
  (getPlayersInRadius(vect(58.142, 13.844, -45.419), 20, Team.2, LosCheck.SURFACES)).teleport(vect(61.413, 29.607, -64.452))
  (getPlayersInRadius(vect(58.782, 6.967, -89.932), 10, Team.2, LosCheck.SURFACES)).teleport(vect(91.211, 28.671, -105.211))
  (getPlayersInRadius(vect(80.716, 17.162, -44.114), 3, Team.2)).teleport(vect(93.987, 21.168, -42.504))
  (getPlayersInRadius(vect(96.582, 13.487, -48.938), 3, Team.2, LosCheck.SURFACES)).teleport(vect(93.268, 22.982, -39.651))
  (getPlayersInRadius(vect(121.993, 13.065, -60.141), 5, Team.2, LosCheck.SURFACES)).teleport(vect(140.365, 16.675, -48.367))
  wait(3)
  (getPlayersInRadius(vect(88.565, 16.192, -65.133), 7, Team.2, LosCheck.SURFACES)).teleport(vect(89.356, 22.269, -62.706))
  (getPlayersInRadius(vect(89.977, 15.013, -60.462), 7, Team.2, LosCheck.SURFACES)).teleport(vect(89.492, 22.387, -62.533))
  (getPlayersInRadius(vect(20.249, 6.953, -68.597), 3, Team.2, LosCheck.SURFACES)).teleport(vect(29.205, 23.499, -76.354))
  (getPlayersInRadius(vect(24.041, 7.135, -70.411), 5, Team.2, LosCheck.SURFACES)).teleport(vect(29.143, 24.435, -76.566))
  (getPlayersInRadius(vect(36.134, 5.771, -64.275), 6, Team.2, LosCheck.SURFACES)).teleport(vect(32.505, 30.313, -61.992))
  (getPlayersInRadius(vect(59.225, 8.24, -72.92), 6, Team.2, LosCheck.SURFACES)).teleport(vect(71.519, 32.305, -69.113))
  (getPlayersInRadius(vect(116.396, 10.248, -25.683), 3, Team.2)).teleport(vect(140.733, 17.537, -48.556))
  (getPlayersInRadius(vect(111.728, 10.279, -31.635), 3, Team.2, LosCheck.SURFACES)).teleport(vect(141.542, 17.749, -49.632))
  (getPlayersInRadius(vect(-11.018, 5.184, -69.178), 10, Team.2, LosCheck.SURFACES)).teleport(vect(0.444, 28.635, -71.721))
  wait(3)
  (getPlayersInRadius(vect(102.051, 15.302, -59.177), 4, Team.2, LosCheck.SURFACES)).teleport(vect(94.504, 22.69, -40.078))
  (getPlayersInRadius(vect(110.146, 14.225, -55.734), 5, Team.2, LosCheck.SURFACES)).teleport(vect(94.008, 23.258, -40.989))
  (getPlayersInRadius(vect(49.292, 9.359, -75.924), 4, Team.2, LosCheck.SURFACES)).teleport(vect(36.874, 28.629, -92.688))
  (getPlayersInRadius(vect(-1.286, 7.401, 1.344), 7, Team.2, LosCheck.SURFACES)).teleport(vect(13.986, 26.094, -19.284))
  (getPlayersInRadius(vect(111.21, 11.751, -31.995), 4.5, Team.2)).teleport(vect(92.943, 23.321, -43.165))
  (getPlayersInRadius(vect(119.561, 15.654, -65.815), 3.5, Team.2)).teleport(vect(93.444, 23.192, -42.299))
  (getPlayersInRadius(vect(123.839, 23.192, -25.383), 6, Team.2)).teleport(vect(127.364, 20.743, -14.823))
  wait(3)
  goto RULE_START


rule "anti-fall debug":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive() == true
  @Condition distance(eventPlayer, vect(0, 0, 0)) < 2.5
  
  eventPlayer.applyImpulse(Vector.UP, 100, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "TP Dead Zombies":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isDead() == true
  
  wait(1.2)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  eventPlayer.teleport(vect(0, -500, 0))
  if RULE_CONDITION:
      goto RULE_START


rule "TP zombies - out of map safety":
  @Event playerTookDamage
  @Team 2
  @Condition eventPlayer.isAlive() == true
  
  wait(0.8)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  wait(5)
  if not RULE_CONDITION:
      return
  wait(5)
  if not RULE_CONDITION:
      return
  wait(5)
  if not RULE_CONDITION:
      return
  wait(5)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  wait(0.8)
  if not RULE_CONDITION:
      return
  eventPlayer.teleport(nearestWalkablePosition(eventPlayer))


rule "Bot Unstuck Impulse":
  (getPlayersInRadius(vect(17.097, 10.74, -40.957), 2.5, Team.2)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(-11.16, 4.025, -34.68), 3, Team.2)).applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(-9.9, 0.939, -18.942), 3, Team.2)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(19.211, 2.451, -7.818), 5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(24.885, 3.767, -20.888), 2.5, Team.2)).applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(6.902, 4.92, -36.626), 2, Team.2)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(20.258, 5.603, -36.284), 2.5, Team.2)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(13.708, 6.083, -52.621), 2, Team.2)).applyImpulse(Vector.UP, 8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(3)
  (getPlayersInRadius(vect(7.089, 6.927, -60.219), 3, Team.2)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(-9.134, 4.253, -65.629), 5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(-3.273, 4.809, -80.28), 3, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(3.195, 5.236, -86.303), 3.5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(23.452, 7.662, -77.825), 3, Team.2)).applyImpulse(Vector.UP, 30, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(26.28, 6.439, -66.695), 3, Team.2)).applyImpulse(Vector.UP, 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(31.094, 6.225, -53.456), 3.5, Team.2)).applyImpulse(Vector.UP, 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(10.381, 11.68, -84.666), 5, Team.2)).applyImpulse(Vector.UP, 7, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(3)
  (getPlayersInRadius(vect(7.725, 6.256, -55.297), 2.5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(25.433, 12.26, -72.218), 5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(31.671, 15.214, -81.142), 6, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(36.614, 5.902, -68.585), 5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(53.746, 8.11, -61.281), 3.5, Team.2)).applyImpulse(Vector.UP, 30, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(60.127, 12.762, -60.252), 4, Team.2)).applyImpulse(Vector.UP, 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(47.936, 8.756, -82.268), 3.5, Team.2)).applyImpulse(Vector.UP, 100, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(42.046, 11.516, -97.12), 4, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(3)
  (getPlayersInRadius(vect(35.184, 10.652, -94.534), 2.5, Team.2)).applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(47.421, 10.828, -102.541), 5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 30, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(55.16, 11.648, -99.523), 3, Team.2)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(58.568, 11.781, -87.569), 2.5, Team.2)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(53.195, 19.273, -82.589), 5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(60.597, 19.398, -77.446), 3, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(66.473, 19.691, -70.913), 10, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(64.318, 18.139, -85.599), 3.5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(65.791, 14.767, -79.315), 3.5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(56.709, 22.31, -67.619), 8, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(3)
  (getPlayersInRadius(vect(74.729, 13.783, -70.925), 3.5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 12, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(63.506, 18.923, -103.766), 3.5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(61.349, 12.869, -101.019), 2.5, Team.2)).applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(66.948, 11.001, -107.991), 6, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 17, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(79.398, 16.166, -44.52), 4, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 100, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(87.213, 14.047, -42.176), 3.5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(120.997, 11.845, -60.474), 4.5, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 7, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(125.876, 15.218, -16.958), 4, Team.2, LosCheck.SURFACES)).applyImpulse(Vector.UP, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  (getPlayersInRadius(vect(59.01, 19.048, -85.711), 1.5, Team.2)).applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  wait(3)
  goto RULE_START


