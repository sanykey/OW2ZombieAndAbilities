#!mainFile "../main.opy"

rule "Bots use ultimate at 100%":
  @Event eachPlayer
  @Team 2
  @Hero torbjorn
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getUltCharge() == 100

  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.5)
  eventPlayer.stopForcingButton(Button.ULTIMATE)
  wait(1, Wait.ABORT_WHEN_FALSE)
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
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.getHero() == Hero.ROADHOG or eventPlayer.getHero() == Hero.MAUGA
  @Condition eventPlayer.targetPlayer0
  @Condition eventPlayer.zomDistancesToPlayersArr[eventPlayer.targetPlayer0.getSlot()] < 3

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
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  
  # Bots move toward players
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

rule "Bots attack near player":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition not eventPlayer.zombiesfly
  @Condition eventPlayer.getHero() == Hero.TORBJORN
  @Condition eventPlayer.targetPlayer0
  @Condition eventPlayer.zomDistancesToPlayersArr[eventPlayer.targetPlayer0.getSlot()] < 4

  # eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
  eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  wait(0.25)
  eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
  wait(1)
  if ruleCondition:
    loop()

rule "Bots moves":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO

  # if not RULE_CONDITION:
  #   eventPlayer.money = 0
  #   return

  # cache players and distances to players
  eventPlayer.list0 = []
  for eventPlayer.I in range(MAX_PLAYERS):
    eventPlayer.temp0 = getPlayersInSlot(eventPlayer.I, Team.1)

    if (eventPlayer.temp0 and eventPlayer.temp0.hasSpawned() and eventPlayer.temp0.isAlive() and not eventPlayer.temp0.isInSecretShop):
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.I] = distance(eventPlayer, eventPlayer.temp0)
      eventPlayer.zomIsInLoSPlayersArr[eventPlayer.I] = isInLoS(eventPlayer, eventPlayer.temp0)
      eventPlayer.list0.append(eventPlayer.temp0)
    else:
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.I] = INFINITY
      eventPlayer.zomIsInLoSPlayersArr[eventPlayer.I] = false
     
  eventPlayer.targetPlayer0 = (
    sorted(
      eventPlayer.list0,
      lambda i: eventPlayer.zomDistancesToPlayersArr[i.getSlot()] + (
        10 if not eventPlayer.zomIsInLoSPlayersArr[i.getSlot()] else 0
      ) + (
        200 if not i.isReady else 0
      ) + (
        100 if i.isInvisible > getTotalTimeElapsed() and (eventPlayer.zomDistancesToPlayersArr[i.getSlot()] > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
      )
    )
  )[0]

  if not eventPlayer.targetPlayer0:
    goto lbl_0

  # Bots face target players
  eventPlayer.setFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()),
    Relativity.TO_WORLD
  )

  # Don’t do anything if the bot flies through walls toward the player or jumps over a chasm (antifall)
  if eventPlayer.zombiesfly or eventPlayer.abilState0:
    goto lbl_0

  # bot in restricted area:
  # if eventPlayer.isInSpawnRoom():
  #   eventPlayer.teleport(random.choice(spawnPointsList))
    # goto lbl_0

  # Bots under player impulse
  if (
    eventPlayer.getVerticalFacingAngle() < -70 and
    not eventPlayer.targetPlayer0.isUsingUltimate() and 
    distance(eventPlayer, eventPlayer.targetPlayer0) > 2 # todo: fix inRadius
  ): # no need to jump after players who use ultimates (doomfist, mercy and etc)
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.2)
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  

  eventPlayer.temp1 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)
  # bot unstuck
  if (
    eventPlayer.abilPos0 and
    distance(eventPlayer.abilPos0, eventPlayer.temp1) < 3 and
    not eventPlayer.hasBadStatus
  ):
    eventPlayer.money += 1
    # try to jump if the movement has slowed down

    if eventPlayer.money > 30:
      eventPlayer.teleport(random.choice(spawnPointsList))
      eventPlayer.abilPos0 = eventPlayer.temp1
      eventPlayer.money = 0
    elif eventPlayer.money > 10:
      eventPlayer.forceButtonPress(Button.JUMP)
      wait()
      eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    elif eventPlayer.money > 5:
      eventPlayer.forceButtonPress(Button.JUMP)
  else:
    eventPlayer.abilPos0 = eventPlayer.temp1
    eventPlayer.money = 0

  lbl_0:
  wait(0.3)
  if ruleCondition:
    loop()

rule "Zombies loS teleport (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition not eventPlayer.zombiesfly
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER
  @Condition eventPlayer.targetPlayer0
  @Condition not eventPlayer.zomIsInLoSPlayersArr[eventPlayer.targetPlayer0.getSlot()]
  @Condition not eventPlayer.hasStatus(Status.HACKED)
  @Condition not eventPlayer.hasStatus(Status.ROOTED)
  @Condition not eventPlayer.hasStatus(Status.STUNNED)
  @Condition not eventPlayer.hasStatus(Status.ASLEEP)
  @Condition not eventPlayer.hasStatus(Status.KNOCKED_DOWN)
  
  wait(5, Wait.ABORT_WHEN_FALSE)
  eventPlayer.zombiesfly = true
  eventPlayer.disallowButton(Button.PRIMARY_FIRE)
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.targetPlayer0.getEyePosition()), 25, 20, Relativity.TO_WORLD)
  wait(0.2)

  eventPlayer.applyImpulse(Vector.FORWARD, 5, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setInvisibility(Invis.ALL)
  waitUntil(isInLoS(getRealClosestPlayer(eventPlayer, Team.1), eventPlayer), 30)
  wait(0.4)
  eventPlayer.setGravity(100)
  eventPlayer.enableEnvironmentCollision()
  eventPlayer.stopAcceleration()
  # eventPlayer.teleport(nearestWalkablePosition(eventPlayer))
  wait(0.1)
  eventPlayer.setInvisibility(Invis.NONE)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayersInRadius(eventPlayer, 10, Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 80)

  if getRealPlayersInRadius(eventPlayer, 5, Team.1): # If a zombie bot came out of the wall very close to the player, give the player time to react
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1.5)
    wait(1.2)
  else:
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.5)
  eventPlayer.allowButton(Button.PRIMARY_FIRE)
  eventPlayer.enablePlayerCollision()
  eventPlayer.zombiesfly = false

  if ruleCondition:
    loop()


rule "zombies fly faster":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.zombiesfly == true
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  @Condition eventPlayer.targetPlayer0
  @Condition eventPlayer.zomDistancesToPlayersArr[eventPlayer.targetPlayer0.getSlot()] > 35
  
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.applyImpulse(Vector.FORWARD, 40, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START


# rule "Bot has bad status":
#   @Event eachPlayer
#   @Team 2
#   @Condition eventPlayer.hasSpawned()
#   @Condition eventPlayer.isAlive()
#   @Condition eventPlayer.hasBadStatus == false
#   @Condition (
#     eventPlayer.hasStatus(Status.HACKED) or
#     eventPlayer.hasStatus(Status.FROZEN) or
#     eventPlayer.hasStatus(Status.KNOCKED_DOWN) or
#     eventPlayer.hasStatus(Status.ASLEEP) or
#     eventPlayer.hasStatus(Status.STUNNED)
#   ) == true
  
#   eventPlayer.hasBadStatus = true
#   waitUntil(
#     not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and
#     not eventPlayer.hasStatus(Status.ASLEEP) and
#     not eventPlayer.hasStatus(Status.FROZEN) and
#     not eventPlayer.hasStatus(Status.STUNNED),
#     INFINITY
#   )
#   eventPlayer.hasBadStatus = false