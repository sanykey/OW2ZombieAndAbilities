#!mainFile "../main.opy"

rule "Bots use ultimate at 100%":
  @Event eachPlayer
  @Team 2
  @Hero torbjorn
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isAlive()

  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.5)
  eventPlayer.stopForcingButton(Button.ULTIMATE)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START

rule "Bots antifall safety and fall damage after cc damage from players":
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


rule "[Team2 Roadhog][Team2 Mauga] Bot zombie melee":
  @Event eachPlayer
  @Team 2
  @Condition getPlayersInRadius(eventPlayer, 3, Team.1) == true
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.getHero() == Hero.ROADHOG or eventPlayer.getHero() == Hero.MAUGA

  eventPlayer.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed()
  eventPlayer.forceButtonPress(Button.MELEE)

  wait(1)
  if ruleCondition:
    loop()

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
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  
  # Bots move toward players
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

  # Bots face nearest players
  # eventPlayer.startFacing(
  #   directionTowards(
  #     eventPlayer.getEyePosition(),
  #     eventPlayer.targetPlayer0.getEyePosition()
  #   ), 400
  # )


rule "Bots attack near player":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.downedStartTime
  @Condition eventPlayer.getHero() == Hero.TORBJORN
  @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == true

  eventPlayer.abilTemp1 = BOT_MAX_INACTIVITY_DURATION + getTotalTimeElapsed()
  eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)

  waitUntil(not getPlayersInRadius(eventPlayer, 4, Team.1))
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)


rule "Bots moves":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.downedStartTime

  if not RULE_CONDITION:
    eventPlayer.money = 0
    return

  # Bots face target players
  eventPlayer.setFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()),
    Relativity.TO_WORLD
  )

  if (eventPlayer.zombiesfly):
    goto lbl_0

  # bot in restricted area:
  # if eventPlayer.isInSpawnRoom():
  #   eventPlayer.teleport(random.choice(spawnPointsList))
    # goto lbl_0

  eventPlayer.targetPlayer0 = (
    sorted(
      [player for player in getLivingPlayers(Team.1) if player.hasSpawned()],
      lambda i: distance(eventPlayer, i) + (
        10 if not isInLoS(eventPlayer, i) else 0
      ) + (
        100 if i.isInvisible > getTotalTimeElapsed() and (distance(eventPlayer, i) > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
      ) + (
        200 if not i.isReady else 0
      )
    )
  )[0]

  if not eventPlayer.targetPlayer0:
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
  @Condition distance(eventPlayer, eventPlayer.targetPlayer0) > 35
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.applyImpulse(Vector.FORWARD, 40, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START


rule "Zombies loS teleport (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.downedStartTime
  @Condition eventPlayer.zombiesfly == false
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER
  @Condition eventPlayer.targetPlayer0.isAlive()
  @Condition not eventPlayer.hasBadStatus
  @Condition not eventPlayer.hasStatus(Status.HACKED)
  @Condition not eventPlayer.hasStatus(Status.ROOTED)
  @Condition not isInLoS(eventPlayer, eventPlayer.targetPlayer0)
  @Condition not (eventPlayer.abilTemp1 and eventPlayer.abilTemp1 < getTotalTimeElapsed())
  
  
  wait(6, Wait.ABORT_WHEN_FALSE)
  eventPlayer.zombiesfly = true
  eventPlayer.disallowButton(Button.PRIMARY_FIRE)
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()), 25, 20, Relativity.TO_WORLD)
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

  if getRealPlayersInRadius(eventPlayer, 4, Team.1): # If a zombie bot came out of the wall very close to the player, give the player time to react
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1.5)
    wait(1.2)
  eventPlayer.allowButton(Button.PRIMARY_FIRE)
  eventPlayer.enablePlayerCollision()
  eventPlayer.zombiesfly = false

  if RULE_CONDITION:
    goto RULE_START


rule "Bot has bad status":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasSpawned()
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.downedStartTime
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