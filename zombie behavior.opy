#!mainFile "main.opy"



rule "Bots use ultimate at 100%":
  @Event eachPlayer
  @Team 2
  @Hero torbjorn
  @Condition eventPlayer.getUltCharge() == 100

  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.5)
  eventPlayer.stopForcingButton(Button.ULTIMATE)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START

rule "Bots antifall safety and fall damage after cc damage from players":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ROADHOG

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

# rule "Warning icon for zombies ":
#   @Event eachPlayer
#   @Team 2

#   # bot target warning icon (flashing)
#   createIcon(
#     [player for player in getPlayers(Team.1) if eventPlayer.isAlive() and distance(eventPlayer, player) < 10 and not player.isInViewAngle(eventPlayer.getPosition(), 55)],
#     eventPlayer,
#     Icon.WARNING,
#     IconReeval.VISIBILITY_POSITION_AND_COLOR,
#     Color.RED if (((ceil(getTotalTimeElapsed() * (4 if distance(eventPlayer.getPosition(), localPlayer.getPosition()) > 10 else 8))) % 2) == 0) else Color.YELLOW
#   )


rule "Zombies loS teleport warning":
  @Event eachPlayer
  @Team 2
  createIcon(
    getPlayers(Team.1) if eventPlayer.zombiesfly else null,
    eventPlayer,
    Icon.EYE,
    IconReeval.VISIBILITY_POSITION_AND_COLOR,
    Color.RED
  )

rule "Bots face target players and move":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ROADHOG
  
  # Bots move toward players
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  # Bots face nearest players
  eventPlayer.startFacing(
    directionTowards(
      eventPlayer.getEyePosition(),
      eventPlayer.targetPlayer.getEyePosition()
    ), 400
  )

  # eventPlayer.setFacing(
  #   directionTowards(eventPlayer.getEyePosition(),
  #   (getRealClosestPlayer(((sorted([player for player in getLivingPlayers(Team.1) if player.isAlive()], lambda i: distance(eventPlayer, i)))[0]).getEyePosition(), Team.1)).getEyePosition()),
  #   Relativity.TO_WORLD
  # )


rule "Bots attack near player":
  @Event eachPlayer
  @Team 2
  @Hero torbjorn
  @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == true

  eventPlayer.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed()
  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)

  waitUntil(not getPlayersInRadius(eventPlayer, 4, Team.1))
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)


rule "Bots moves":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ROADHOG

  if not RULE_CONDITION:
    eventPlayer.money = 0
    return

  if (not eventPlayer.isAlive() or eventPlayer.zombiesfly):
    goto lbl_0

  # bot in restricted area:
  if eventPlayer.isInSpawnRoom():
    eventPlayer.teleport(random.choice(spawnPointsList))
  if distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3:
    eventPlayer.teleport(vect(79.382, 13.147, -110.093))
  if distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2:
    eventPlayer.teleport(vect(86.903, 14.219, -101.238))
  if distance(eventPlayer, vect(97.65, 11.233, -30.593)) < 3:
    eventPlayer.teleport(vect(96.475, 12.392, -35.419))
  if distance(eventPlayer, vect(103.937, 11.178, -30.358)) < 2:
    eventPlayer.teleport(vect(107.719, 11.178, -33.024))
  if distance(eventPlayer, vect(113.037, 12.696, -10.145)) < 3:
    eventPlayer.teleport(vect(113.894, 11.178, -15.333))
  if distance(eventPlayer, vect(140.251, 12.481, -17.63)) < 3:
    eventPlayer.teleport(vect(133.957, 12.363, -18.225))

  eventPlayer.targetPlayer = (
    sorted(
      [player for player in getLivingPlayers(Team.1) if player.isAlive()],
      lambda i: distance(eventPlayer, i) + (
        10 if not isInLoS(eventPlayer, i) else 0
      ) + (
        50 if i.state[SI.IS_INVISIBLE] and (distance(eventPlayer, i) > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
      )
    )
  )[0]

  if not eventPlayer.targetPlayer:
    goto lbl_0

  # Perhaps the bot has fallen into a place it can't get out of and has not been interacted with in any way
  if eventPlayer.abilTemp1 and eventPlayer.abilTemp1 < getTotalTimeElapsed():
    eventPlayer.money = 0
    eventPlayer.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed()
    eventPlayer.teleport(random.choice(spawnPointsList))
    goto lbl_0


  eventPlayer.temp1 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)

  # Bots under player impulse
  if eventPlayer.getVerticalFacingAngle() < -70 and getRealClosestPlayer(eventPlayer, Team.1).isUsingUltimate() == false: # no need to jump after players who use ultimates (doomfist, mercy and etc)
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    eventPlayer.applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  
  # bot unstuck
  if (
    eventPlayer.abilPos0 and
    distance(eventPlayer.abilPos0, eventPlayer.temp1) < 2 and
    not eventPlayer.hasBadStatus
  ):
    eventPlayer.money += 1
    # try to jump if the movement has slowed down
    if eventPlayer.money > 5:
      eventPlayer.forceButtonPress(Button.JUMP)

    if eventPlayer.money > 60:
      eventPlayer.teleport(random.choice(spawnPointsList))
      eventPlayer.money = 0
  else:
    eventPlayer.abilPos0 = eventPlayer.temp1
    eventPlayer.money = 0

  lbl_0:
  wait(0.3)
  loop()

rule "zombies fly faster":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.zombiesfly == true
  @Condition distance(eventPlayer, eventPlayer.targetPlayer) > 35
  @Condition eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ROADHOG
  
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.applyImpulse(Vector.FORWARD, 40, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START


rule "Zombies loS teleport (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive() == true
  @Condition eventPlayer.zombiesfly == false
  @Condition eventPlayer.getHero() == Hero.TORBJORN or eventPlayer.getHero() == Hero.ROADHOG
  @Condition eventPlayer.targetPlayer.isAlive()
  @Condition isInLoS(eventPlayer, eventPlayer.targetPlayer) == false
  @Condition not (eventPlayer.abilTemp1 and eventPlayer.abilTemp1 < getTotalTimeElapsed())
  
  wait(6, Wait.ABORT_WHEN_FALSE)
  eventPlayer.zombiesfly = true
  eventPlayer.disallowButton(Button.PRIMARY_FIRE)
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer.getEyePosition()), 25, 20, Relativity.TO_WORLD)
  playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  wait(0.2)
  eventPlayer.applyImpulse(Vector.FORWARD, 5, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setInvisibility(Invis.ALL)
  waitUntil(isInLoS(eventPlayer, getRealClosestPlayer(eventPlayer, Team.1)), 30)
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
  eventPlayer.setStatusEffect(null, Status.ROOTED, 1.5)
  wait(1.2)
  eventPlayer.allowButton(Button.PRIMARY_FIRE)
  eventPlayer.enablePlayerCollision()
  eventPlayer.zombiesfly = false

  if RULE_CONDITION:
    goto RULE_START


rule "Bot has bad status":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isDummy() == true
  @Condition eventPlayer.hasSpawned() == true
  @Condition eventPlayer.isAlive() == true
  @Condition eventPlayer.hasBadStatus == false
  @Condition (
    eventPlayer.hasStatus(Status.HACKED) or
    eventPlayer.hasStatus(Status.FROZEN) or
    eventPlayer.hasStatus(Status.KNOCKED_DOWN) or
    eventPlayer.hasStatus(Status.ASLEEP) or
    eventPlayer.hasStatus(Status.STUNNED)
  ) == true
  
  eventPlayer.hasBadStatus = true
  waitUntil(
    not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and
    not eventPlayer.hasStatus(Status.ASLEEP) and
    not eventPlayer.hasStatus(Status.FROZEN) and
    not eventPlayer.hasStatus(Status.STUNNED),
    INFINITY
  )
  eventPlayer.hasBadStatus = false