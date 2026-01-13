#!mainFile "../main.opy"

#!define ZOM_FLY_POINTS 6
#!define ZOM_MAX_TARGET_DISTANCE 50
#!define ZOM_MELEE_ATTACK_DISTANCE 3
#!define ZOM_MELEE_ATTACK_CACHE_TIME 1.5

macro Player.getDistanceToZombieTarget(self):
  self.zomDistancesToPlayersArr[self.zomTarget.getSlot()]

macro Player.isInLoSZombieTarget(self):
  self.zomIsInLoSPlayersArr[self.zomTarget.getSlot()]

macro Player.isRecentlyDealMeleeDemage(self):
  eventPlayer.zomLastMeleeAttackTimeArr[eventPlayer.tmp0.getSlot()] > getTotalTimeElapsed() - ZOM_MELEE_ATTACK_CACHE_TIME

def SearchTargetsSub():
  @Name "Sub: search Targets"
  # cache players and distances to players
  eventPlayer.zomMeleeAttackTargets = [] # current melee attack targets
  eventPlayer.zomDistancesToPlayersArr = [] # cached distances from bot to players
  eventPlayer.zomIsInLoSPlayersArr = [] # cached IsInLineOfSight from bot to players

  eventPlayer.tmp1 = false      # current target weight
  eventPlayer.tmp2 = false      # weight of best canditate to target
  eventPlayer.zomTarget = false # target being pursued by the zombie

  for eventPlayer.I in range(len(combatants)):
    eventPlayer.tmp0 = combatants[eventPlayer.I]
    if (eventPlayer.tmp0):
      # distance to current player:
      eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] = (
        # Treat distance as minimal if the bot recently dealt melee damage :
        2 if eventPlayer.isRecentlyDealMeleeDemage() else

        # Optimization: First, try to estimate distance using cheaper methods:
        9999 if (
          abs(eventPlayer.getPosition().x - eventPlayer.tmp0.getPosition().x) > ZOM_MAX_TARGET_DISTANCE 
          or abs(eventPlayer.getPosition().z - eventPlayer.tmp0.getPosition().z) > ZOM_MAX_TARGET_DISTANCE 
        ) else

        distance(eventPlayer, eventPlayer.tmp0)
      )

      if eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] < ZOM_MAX_TARGET_DISTANCE: # For optimization, check IsInLineOfSight only at short distances.
        # Treat LoS = true if the bot recently dealt melee damage:
        eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] = (
          eventPlayer.isRecentlyDealMeleeDemage()
          or isInLoS(eventPlayer.getEyePosition(), eventPlayer.tmp0.getPosition() + LosHeightCheckVectConst) 
        )

      # collect current melee attack targets
      if (eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] < ZOM_MELEE_ATTACK_DISTANCE and eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] and eventPlayer.isInViewAngle(eventPlayer.tmp0.getPosition(), 90)):
        eventPlayer.zomMeleeAttackTargets.append(eventPlayer.tmp0)

      eventPlayer.tmp1 = (
        eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()]
        + (10 if not eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] else 0) # Low priority for targets behind walls
        + ( # for sombra invisible:
          100 if eventPlayer.tmp0.isInvisible > getTotalTimeElapsed() and (eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] > 4 or not eventPlayer.isInViewAngle(eventPlayer.tmp0.getPosition(), 90)) else 0
        ) - ( # High priority for tank targets (except Baby D.Va):
          3 if (
              eventPlayer.tmp0.heroType == HeroType.TANK
              and eventPlayer.zomIsInLoSPlayersArr[eventPlayer.tmp0.getSlot()] 
              and not (eventPlayer.tmp0.getCurrentHero() == Hero.DVA and eventPlayer.tmp0.isInAlternateForm())
            ) else 0 
        )
      )

      if not eventPlayer.tmp2 or eventPlayer.tmp2 > eventPlayer.tmp1:
        eventPlayer.tmp2 = eventPlayer.tmp1
        eventPlayer.zomTarget = eventPlayer.tmp0


macro botAntifall():
  eventPlayer.tmp0 = false
  # For the starting location. Which is the lowest and the height of the fatal fall into the abyss starts noticeably lower:
  if eventPlayer.getPosition().x < 0 and eventPlayer.getPosition().z > -35: 
    if eventPlayer.getPosition().y < -6:
      eventPlayer.tmp0 = true
  elif eventPlayer.getPosition().x > 43: # ZONE B
    if eventPlayer.getPosition().y < 4.7:
      eventPlayer.tmp0 = true
  else:
    if eventPlayer.getPosition().y < 0: # Other
      eventPlayer.tmp0 = true

  if not eventPlayer.tmp0:
    goto lbl_1

  # If the player was dealing cc damage before the bot fell, then try to deal damage to the bot from the fall
  if eventPlayer.lastCcAttackTime >= getTotalTimeElapsed():

    # Allow the bot to fall if expected fall damage is greater than its current health
    if eventPlayer.getHealth() < ZOMBIE_FALL_DAMAGE * eventPlayer.lastCcAttacker.damageBoostPercent / 100:

      # If no vanilla knockback would grant the kill, assign it using setEnvironmentalKillCreditor
      if not eventPlayer.lastCcVanilaKnockback:
        eventPlayer.setEnvironmentalKillCreditor(eventPlayer.lastCcAttacker)
      goto lbl_1

    else:
      damage(eventPlayer, eventPlayer.lastCcAttacker, ZOMBIE_FALL_DAMAGE)
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
      eventPlayer.lastCcAttackTime = false
  else:
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  lbl_1:

macro botUnstuck():
  if eventPlayer.isOnGround():
    eventPlayer.tmp0 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)
    if (
      eventPlayer.moneyTotal__zomStuckPrevPosition and
      distance(eventPlayer.moneyTotal__zomStuckPrevPosition, eventPlayer.tmp0) < 0.7
    ):
      eventPlayer.money__zomStuckPoints += 1

      # try to jump if the movement has slowed down:
      if eventPlayer.money__zomStuckPoints > 15:
        eventPlayer.teleport(random.choice(spawnPointsList))
        eventPlayer.moneyTotal__zomStuckPrevPosition = eventPlayer.tmp0
        eventPlayer.money__zomStuckPoints = 0
      elif eventPlayer.money__zomStuckPoints > 5:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait()
        eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
      elif eventPlayer.money__zomStuckPoints > 3:
        eventPlayer.forceButtonPress(Button.JUMP)

    else:
      eventPlayer.moneyTotal__zomStuckPrevPosition = eventPlayer.tmp0
      eventPlayer.money__zomStuckPoints = 0

macro botUnderPlayerImpulse():
  if (
    eventPlayer.zomDistancesToPlayersArr[eventPlayer.zomTarget.getSlot()] > 2
    and not eventPlayer.zomTarget.isUsingUltimate()
    and eventPlayer.getVerticalFacingAngle() < -70
  ): # no need to jump after players who use ultimates (doomfist, mercy and etc)
    eventPlayer.applyImpulse(
      worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION),
      20,
      Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION
    )
    wait(0.2)
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

macro checkVendettaCounterAttack():
  # [Vendetta] pushes in front of her if an attack was blocked by her guard
  eventPlayer.tmp0 = [ # find Vendetta player with block stance
    player for player in eventPlayer.zomMeleeAttackTargets if (
      Hero.VENDETTA == player.getCurrentHero()
      and player.isFiringSecondaryFire()
      and player.abilState0 < getTotalTimeElapsed()
      and player.isInViewAngle(eventPlayer.getPosition(), 90)
    )
  ][0]

  if eventPlayer.tmp0:
    eventPlayer.tmp0.list0 = [
      player for player in getPlayers(Team.2) if (
        player.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] <= 4
        and eventPlayer.tmp0.isInViewAngle(player.getPosition(), 90)
      )
    ]

    eventPlayer.tmp0.abilState0 = 1 + getTotalTimeElapsed() # set talent cooldown
    eventPlayer.tmp0.list0.pushInFacingDirectionAndUp(eventPlayer.tmp0, 10)
    eventPlayer.tmp0.list0.setCrowdControlAttack(eventPlayer.tmp0)
    damage(eventPlayer.tmp0.list0, eventPlayer.tmp0, 0.1) # Deal a small amount of damage to earn assist money while holding guard

macro flyThroughWallsPoints():
  if eventPlayer.zomIsInLoSPlayersArr[eventPlayer.zomTarget.getSlot()] or eventPlayer.hasStatus(Status.HACKED):
    eventPlayer.zomFlyThroughWallsPoints = false
  else:
    eventPlayer.zomFlyThroughWallsPoints++
    if ( # If the target is far away, teleport to the nearest available spawn point:
      eventPlayer.zomFlyThroughWallsPoints == (ZOM_FLY_POINTS - 1)
      and spawnPointsList
      and eventPlayer.zomDistancesToPlayersArr[eventPlayer.zomTarget.getSlot()] > 40
    ):
      eventPlayer.teleport(random.choice(spawnPointsList))

macro botAttack():
  if (
    eventPlayer.getHero() == Hero.TORBJORN 
    and eventPlayer.getUltCharge() == 100 
    and not eventPlayer.isUsingUltimate() 
    and eventPlayer.zomDistancesToPlayersArr[eventPlayer.zomTarget.getSlot()] < 12
  ):
    eventPlayer.forceButtonPress(Button.ULTIMATE)

  if eventPlayer.isUsingUltimate() and eventPlayer.zomDistancesToPlayersArr[eventPlayer.zomTarget.getSlot()] < 5:
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
  else:
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

  if eventPlayer.zomMeleeAttackTargets and not eventPlayer.zomFlyThroughWalls:
    eventPlayer.startForcingButton(Button.MELEE)
    eventPlayer.money__zomStuckPoints = false # Reset zomStuckPoints because the bot slowed down due to entering melee combat.

    # Zombie bot gains ultimate charge from number of hits dealt:
    if eventPlayer.zomAIstep == 0:
      eventPlayer.setUltCharge(eventPlayer.getUltCharge() + 3)

  else:
    eventPlayer.stopForcingButton(Button.MELEE)

macro botTeleportIfTooFar():
  # If a zombie bot is too far from its target, teleport it to a random available spawn point:
  if eventPlayer.zomDistancesToPlayersArr[eventPlayer.tmp0.getSlot()] > ZOM_MAX_TARGET_DISTANCE and spawnPointsList:
    eventPlayer.teleport(random.choice(spawnPointsList))

rule "Zombie bots main behavior":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO

  if (
    not combatants # When no suitable targets are available, freeze all logic
    or eventPlayer.isCrowdControlled()
  ):
    eventPlayer.zomFlyThroughWallsPoints = false 
    eventPlayer.money__zomStuckPoints = false
    goto lbl_0

  
  if eventPlayer.zomAIstep == 0: # Execute once every 4 steps for optimization
    SearchTargetsSub()
    botTeleportIfTooFar()
    flyThroughWallsPoints()

  botAntifall()

  if not eventPlayer.zomTarget: # No target found — take no action
    goto lbl_0

  # Bots face target players
  eventPlayer.setFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.zomTarget.getEyePosition()),
    Relativity.TO_WORLD
  )

  botAttack()

  if not eventPlayer.zomFlyThroughWalls and eventPlayer.zomMeleeAttackTargets and eventPlayer.zomAIstep == 2:
    checkVendettaCounterAttack()
  
  # Don’t do anything if the bot flies through walls and if the bot jumps over a chasm (antifall)
  if eventPlayer.zomFlyThroughWalls or eventPlayer.tmp0:
    goto lbl_0

  if eventPlayer.zomAIstep == 1 or eventPlayer.zomAIstep == 3: # Execute once every 2 steps for optimization
    botUnderPlayerImpulse()
    botUnstuck()

  lbl_0:
  # Step counter — used to run certain actions only periodically for optimization.
  # For example: Antifall: every 0.2 seconds; Target search: every 0.8 seconds or less frequently::
  eventPlayer.zomAIstep = 0 if eventPlayer.zomAIstep >= 3 else eventPlayer.zomAIstep + 1

  wait(0.2, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

rule "Zombies loS teleport (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.zomFlyThroughWallsPoints >= ZOM_FLY_POINTS
  
  eventPlayer.zomFlyThroughWallsPoints = false
  eventPlayer.zomFlyThroughWalls = true
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.zomTarget.getEyePosition()), 25, 20, Relativity.TO_WORLD)
  wait(0.2)

  eventPlayer.applyImpulse(Vector.FORWARD, 5, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setInvisibility(Invis.ALL)
  waitUntil(any([eventPlayer.zomIsInLoSPlayersArr[player.getSlot()] for player in combatants]), 30)
  wait(0.4)
  eventPlayer.setGravity(100)
  eventPlayer.enableEnvironmentCollision()
  eventPlayer.stopAcceleration()
  # eventPlayer.teleport(nearestWalkablePosition(eventPlayer))
  wait(0.1)
  eventPlayer.setInvisibility(Invis.NONE)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayersInRadius(eventPlayer, 10, Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 80)

  # If the zombie bot came out of the wall very close to a player, give a player time to react
  if any([eventPlayer.zomDistancesToPlayersArr[player.getSlot()] <= 5 for player in combatants]): 
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1.5)
    wait(1.2)
  else:
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.5)
  eventPlayer.enablePlayerCollision()
  eventPlayer.zomFlyThroughWalls = false

  if ruleCondition:
    loop()

# rule "BOT WANDERS":
#   @Event eachPlayer
#   @Team 2
#   @Condition eventPlayer.zomTarget
#   #Allows if bot bumps into something
#   @Condition eventPlayer.getHorizontalSpeed() < (5.5 / 100 * zomSpeedPct - 0.3)
  
#   logToInspector("too slow: {} < {}".format(eventPlayer.getHorizontalSpeed(), 5.5 / 100 * zomSpeedPct - 0.3))
#   wait(0.25, Wait.ABORT_WHEN_FALSE)
#   eventPlayer.stopForcingThrottle()
#   eventPlayer.startThrottleInDirection(
#     directionFromAngles(
#       horizontalAngleOfDirection(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) + random.uniform(90, 270), 0
#     ),
#     5.5 / 100 * zomSpeedPct,
#     Relativity.TO_WORLD,
#     Throttle.REPLACE_EXISTING,
#     ThrottleReeval.NONE
#   )
#   wait(1)
#   if not ruleCondition:
#     logToInspector("Ok!: {} < {}".format(eventPlayer.getHorizontalSpeed(), 5.5 / 100 * zomSpeedPct - 0.3))
#     eventPlayer.stopThrottleInDirection()
#     eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

#   if ruleCondition:
#     loop()
    