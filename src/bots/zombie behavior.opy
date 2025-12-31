#!mainFile "../main.opy"

macro Player.getDistanceToZombieTarget(self):
  self.zomDistancesToPlayersArr[self.target0.getSlot()]

macro Player.isInLoSZombieTarget(self):
  self.zomIsInLoSPlayersArr[self.target0.getSlot()]

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


rule "Zombies loS teleport warning":
  @Event eachPlayer
  @Team 2

  createIcon(
    getPlayers(Team.1) if eventPlayer.zombiesfly else null,
    eventPlayer,
    Icon.EYE,
    IconReeval.VISIBILITY_AND_POSITION,
    Color.RED
  )

macro Player.calcCombatantDistAndLoSToBots(self, zombieBot):
  self.zomDistancesToPlayersArr[zombieBot.getSlot()] = distance(self, zombieBot)
  self.zomIsInLoSPlayersArr[zombieBot.getSlot()] = isInLoS(self, zombieBot)

rule "Bots moves":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO

  # cache players and distances to players
  eventPlayer.list1 = [] # current melee attack targets
  eventPlayer.zomDistancesToPlayersArr = []
  eventPlayer.zomIsInLoSPlayersArr = []

  if not combatants:
    goto lbl_0

  for eventPlayer.I in range(len(combatants)):
    eventPlayer.tmp0 = combatants[eventPlayer.I]
    if (eventPlayer.tmp0):
      # collect avaliable targets
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] = distance(eventPlayer, eventPlayer.tmp0)
      eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] = isInLoS(eventPlayer, eventPlayer.tmp0)

      # collect current melee attack targets
      if (eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] < 3 and eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] and eventPlayer.isInViewAngle(eventPlayer.tmp0.getPosition(), 90)):
        eventPlayer.list1.append(eventPlayer.tmp0)
     
  eventPlayer.target0 = (
    sorted(
      combatants,
      lambda i: eventPlayer.zomDistancesToPlayersArr[i.getSlot()] + ( 
        10 if not eventPlayer.zomIsInLoSPlayersArr[i.getSlot()] else 0 # Low priority for targets behind walls
      ) + (
        200 if not i.isReady else 0
      ) + (
        100 if i.isInvisible > getTotalTimeElapsed() and (eventPlayer.zomDistancesToPlayersArr[i.getSlot()] > 4 or not eventPlayer.isInViewAngle(i.getPosition(), 90)) else 0
      ) - (
        3 if eventPlayer.zomIsInLoSPlayersArr[i.getSlot()] and i.heroType == HeroType.TANK and not (i.getCurrentHero() == Hero.DVA and i.isInAlternateForm()) else 0 # High priority for tank targets (except Baby D.Va)
      )
    )
  )[0]

  if not eventPlayer.target0:
    goto lbl_0

  # Bots face target players
  eventPlayer.setFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()),
    Relativity.TO_WORLD
  )

  # Don’t do anything if the bot flies through walls
  if eventPlayer.zombiesfly:
    goto lbl_0

  if eventPlayer.list1:
    eventPlayer.startForcingButton(Button.MELEE)
  else:
    eventPlayer.stopForcingButton(Button.MELEE)

  # Don’t do anything if the bot jumps over a chasm (antifall)
  if eventPlayer.abilState0:
    goto lbl_0

  # Bots under player impulse
  if (
    eventPlayer.getVerticalFacingAngle() < -70 and
    not eventPlayer.target0.isUsingUltimate() and 
    distance(eventPlayer, eventPlayer.target0) > 2 # todo: fix inRadius
  ): # no need to jump after players who use ultimates (doomfist, mercy and etc)
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.2)
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  

  eventPlayer.tmp0 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)
  # bot unstuck
  if (
    eventPlayer.abilPos0 and
    distance(eventPlayer.abilPos0, eventPlayer.tmp0) < 3
    # not eventPlayer.hasBadStatus
  ):
    eventPlayer.money += 1
    # try to jump if the movement has slowed down

    if eventPlayer.money > 30:
      eventPlayer.teleport(random.choice(spawnPointsList))
      eventPlayer.abilPos0 = eventPlayer.tmp0
      eventPlayer.money = 0
    elif eventPlayer.money > 10:
      eventPlayer.forceButtonPress(Button.JUMP)
      wait()
      eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    elif eventPlayer.money > 5:
      eventPlayer.forceButtonPress(Button.JUMP)
  else:
    eventPlayer.abilPos0 = eventPlayer.tmp0
    eventPlayer.money = 0

  lbl_0:
  wait(0.3, Wait.ABORT_WHEN_FALSE)
  if not eventPlayer.zombiesfly and eventPlayer.list1:
    # [Vendetta] pushes in front of her if an attack was blocked by her guard
    eventPlayer.tmp3 = [
      player for player in eventPlayer.list1 if Hero.VENDETTA == player.getCurrentHero() and player.isFiringSecondaryFire() and player.abilState0 < getTotalTimeElapsed() and player.isInViewAngle(eventPlayer.getPosition(), 90)
    ]
    if eventPlayer.tmp3:
      eventPlayer.tmp3.list0 = [
        player for player in getRealPlayersInRadius(eventPlayer.tmp3.getPosition(), 4, Team.2) if eventPlayer.tmp3.isInViewAngle(player.getPosition(), 90)
      ]

      eventPlayer.tmp3.abilState0 = 1 + getTotalTimeElapsed()
      eventPlayer.tmp3.list0.pushInFacingDirectionAndUp(eventPlayer.tmp3, 12)
      eventPlayer.tmp3.list0.setCrowdControlAttack(eventPlayer.tmp3)
      damage(eventPlayer.tmp3.list0, eventPlayer.tmp3, 0.1) # Deal a small amount of damage to earn assist money while holding guard

  if ruleCondition:
    loop()

rule "Zombies loS teleport (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition not eventPlayer.zombiesfly
  @Condition eventPlayer.target0
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO
  @Condition not eventPlayer.zomIsInLoSPlayersArr[eventPlayer.target0.getSlot()]
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
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.target0.getEyePosition()), 25, 20, Relativity.TO_WORLD)
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
  @Condition eventPlayer.zombiesfly
  @Condition eventPlayer.target0
  @Condition eventPlayer.zomDistancesToPlayersArr[eventPlayer.target0.getSlot()] > 35
  
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  eventPlayer.applyImpulse(Vector.FORWARD, 40, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  wait(1, Wait.ABORT_WHEN_FALSE)
  if RULE_CONDITION:
    goto RULE_START

