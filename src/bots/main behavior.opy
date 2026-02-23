#!mainFile "../main.opy"

#!define BOT_WALL_PHASE_POINTS 15

#!define BOT_MAX_NOT_LOS_TARGET_DISTANCE 25
#!define BOT_MELEE_ATTACK_DISTANCE 3
#!define BOT_LOS_TARGET_CACHE_TIME 0.39
#!define BOT_OLD_POS_STUCK_DISTANCE 2.5
#!define BOT_OLD_POS_STUCK_RESET_DISTANCE 5
#!define BOT_IN_LOS_SEARCH_TARGET_DISTANCE 40

#!define ZOM_MELEE_ATTACK_CACHE_TIME 1.5

playervar botTargetLos


macro Player.getDistanceToBotTarget(self):
  distance(self, self.botTarget)

macro Player.isInLoSBotTarget(self):
  self.botTargetLos + BOT_LOS_TARGET_CACHE_TIME > getTotalTimeElapsed()

# todo: ??
macro Player.isRecentlyDealMeleeDemage(self, target):
  eventPlayer.zomLastMeleeAttackTimeArr[target.getSlot()] > getTotalTimeElapsed() - ZOM_MELEE_ATTACK_CACHE_TIME


def TeleportToRandomSpawnPointSub():
  @Name "TeleportToRandomSpawnPointSub"
  ResetBotStuckTimesSub()
  GetRandomTeleportPosSub()
  TeleportWithAnimationSub()

def SearchTargetsSub():
  @Name "SearchTargetsSub"

  eventPlayer.list0 = [
    player for player in getPlayersInRadius(eventPlayer.getEyePosition(), BOT_IN_LOS_SEARCH_TARGET_DISTANCE, Team.PLAYERS, LosCheck.SURFACES)
    if player.isAlive() and player.hasSpawned()
  ]

  eventPlayer.tmp0 = sorted(
    [
      player for player in combatants
      if player.hasSpawned() and not player.isInvisible and player.isAlive()
    ],
    lambda sortedPlayer: (
      distance(eventPlayer, sortedPlayer)
      + (7 if not sortedPlayer in eventPlayer.list0 else 0) # Low priority for targets behind walls
      + ( # for sombra invisible:
        100 if sortedPlayer.isInvisible > getTotalTimeElapsed() and distance(eventPlayer, sortedPlayer) > 4 or not eventPlayer.isInViewAngle(sortedPlayer.getPosition(), 90) else 0
      ) - ( # High priority for tank targets (except Baby D.Va):
        3 if (
            sortedPlayer.heroType == HeroType.TANK
            and not (sortedPlayer.getCurrentHero() == Hero.DVA and sortedPlayer.isInAlternateForm())
          ) else 0 
      )
    )
  )[0]

  if eventPlayer.tmp0 != eventPlayer.botTarget: # If the target has changed
    eventPlayer.botTargetLastPosition = null # delete the information about the last visible position of the previous target.
    eventPlayer.botTarget = eventPlayer.tmp0
    eventPlayer.botTargetLos = getTotalTimeElapsed() if eventPlayer.botTarget in eventPlayer.list0 else null

rule "bot targeting polling ":
  @Event eachPlayer
  @Team 2
  @Condition roundNumber
  @Condition eventPlayer.isAlive()

  SearchTargetsSub()
  wait(1.5, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

def SetDefaultThrottleSub():
  @Name "SetDefaultThrottleSub"
  eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)

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
  if eventPlayer.isCrowdControlTime():
    # Allow the bot to fall if expected fall damage is greater than its current health
    if eventPlayer.getHealth() < ZOMBIE_FALL_DAMAGE * eventPlayer.lastCcAttacker.damageBoostPercent / 100:

      # If no vanilla knockback would grant the kill, assign it using setEnvironmentalKillCreditor
      if not eventPlayer.lastCcVanilaKnockback:
        eventPlayer.setEnvironmentalKillCreditor(eventPlayer.lastCcAttacker)
      goto lbl_1

    else:
      damage(eventPlayer, eventPlayer.lastCcAttacker, ZOMBIE_FALL_DAMAGE)
      eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
      ResetCrowdControlTimeSub()
  else:
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

  lbl_1:

macro botUnstuck():
  if eventPlayer.isCrowdControlTime() or eventPlayer.isReady__isBotRespawning: 
    ResetBotStuckTimesSub()
  elif eventPlayer.isOnGround():
    eventPlayer.tmp0 = vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().y)
    if eventPlayer.getDistanceToBotTarget() > 1.5 and eventPlayer.getHorizontalSpeed() < ((5.5 / 100 * zomSpeedPct) - 2):
      # eventPlayer.forceButtonPress(Button.MELEE) # todo: нужна задержка до прыжка??
      eventPlayer.forceButtonPress(Button.JUMP) # try to jump if the movement has slowed down:
      if (
        eventPlayer.moneyTotal__botOldPosition and
        distance(eventPlayer.moneyTotal__botOldPosition, eventPlayer.tmp0) < BOT_OLD_POS_STUCK_DISTANCE
      ):
        eventPlayer.money__botStuckTimes += 5
        if eventPlayer.money__botStuckTimes > 25:
          TeleportToRandomSpawnPointSub()
        elif eventPlayer.money__botStuckTimes > 10:
          eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
      else:
        eventPlayer.moneyTotal__botOldPosition = eventPlayer.tmp0
        eventPlayer.money__botStuckTimes = 0
    elif eventPlayer.money__botStuckTimes > 0:
      if distance(eventPlayer.moneyTotal__botOldPosition, eventPlayer.tmp0) > BOT_OLD_POS_STUCK_RESET_DISTANCE:
        eventPlayer.money__botStuckTimes = 0
      else:
        eventPlayer.money__botStuckTimes -= 1

# Make the bot jump if its target is above it
macro botUnderPlayerImpulse():
  if (
    eventPlayer.getDistanceToBotTarget() > 2
    and not eventPlayer.botTarget.isUsingUltimate() # no need to jump after players who use ultimates (doomfist, mercy and etc)
    and eventPlayer.getVerticalFacingAngle() < -70
  ):
    # The bot applies a horizontal impulse in a random direction to overcome ledges or obstacles blocking its path to high ground:
    eventPlayer.applyImpulse(
      worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION),
      20,
      Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION
    )
    wait(0.2)
    # Upward impulse toward the high ground where the target is located:
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

macro checkVendettaCounterAttack():
  # [Vendetta] pushes in front of her if an attack was blocked by her guard
  eventPlayer.tmp0 = [ # find Vendetta player with block stance
    player for player in eventPlayer.botMeleeAttackTargets if (
      Hero.VENDETTA == player.getCurrentHero()
      and player.isFiringSecondaryFire()
      and player.abilState0 < getTotalTimeElapsed()
      and player.isInViewAngle(eventPlayer.getPosition(), 90)
    )
  ][0]

  if eventPlayer.tmp0:
    eventPlayer.tmp0.list0 = [
      player for player in getPlayers(Team.ZOMBIES) if (
        distance(player, eventPlayer.tmp0) <= 4
        and eventPlayer.tmp0.isInViewAngle(player.getPosition(), 90)
      )
    ]

    eventPlayer.tmp0.abilState0 = 1 + getTotalTimeElapsed() # set talent cooldown
    eventPlayer.tmp0.list0.pushInFacingDirectionAndUp(eventPlayer.tmp0, 10)
    eventPlayer.tmp0.list0.setCrowdControlAttack(eventPlayer.tmp0)
    damage(eventPlayer.tmp0.list0, eventPlayer.tmp0, 0.1) # Deal a small amount of damage to earn assist money while holding guard

macro flyThroughWallsPoints():
  if eventPlayer.isInLoSBotTarget() or eventPlayer.botWallPhase or eventPlayer.hasStatus(Status.HACKED) or eventPlayer.isCrowdControlTime(): # todo: Crowd controlled
    eventPlayer.botWantsWallPhasePoints = false
  else:
    eventPlayer.botWantsWallPhasePoints++

macro botTeleportIfTooFar():
  # If a zombie bot is too far from its target, teleport it to a random available spawn point:
  if eventPlayer.getDistanceToBotTarget() > BOT_MAX_TARGET_DISTANCE:
    TeleportToRandomSpawnPointSub()

macro botTargetLosAndObstacleWaipoint():
  eventPlayer.tmp0 = getTotalTimeElapsed() if isInLoS(eventPlayer.botTarget.getEyePosition(), eventPlayer.getEyePosition() + vect(0, LosHeightCheckVectConst, 0)) else null

  # If the target disappears from view by moving behind an obstacle - save a position that allows the bot to navigate around the obstacle.
  if not eventPlayer.tmp0 and eventPlayer.botTargetLos:
    eventPlayer.botTargetLastPosition = eventPlayer.botTarget.getPosition() + normalize(
      worldVector(eventPlayer.botTarget.getThrottle(), eventPlayer.botTarget, Transform.ROTATION)
    ) * -2
  eventPlayer.botTargetLos = eventPlayer.tmp0

  if eventPlayer.botTargetLastPosition and distance(eventPlayer, eventPlayer.botTargetLastPosition) < 1 or eventPlayer.botTargetLos:
    eventPlayer.botTargetLastPosition = null


rule "Zombie bots main polling":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.getHero() != Hero.WIDOWMAKER and eventPlayer.getHero() != Hero.ECHO

  botAntifall()

  if (
    not combatants # When no suitable targets are available, freeze all logic
    or not eventPlayer.botTarget
    # or eventPlayer.isCrowdControlled()
  ):
    ResetBotStuckTimesSub() # Reset zomStuckPoints because ...
    goto lbl_0

  # Bots face target players
  eventPlayer.setFacing(
    directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTargetLastPosition if eventPlayer.botTargetLastPosition else eventPlayer.botTarget),
    Relativity.TO_WORLD
  )

  if eventPlayer.zomAIstep:
    botTeleportIfTooFar()
    botTargetLosAndObstacleWaipoint()
    flyThroughWallsPoints()
    if not eventPlayer.botWallPhase:
      botUnderPlayerImpulse()
      botUnstuck()

  lbl_0:
  eventPlayer.zomAIstep = not eventPlayer.zomAIstep
  wait(0.2, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

rule "bot melee attack polling":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.botTarget
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.botWallPhase

  if distance(eventPlayer.getEyePosition(), eventPlayer.botTarget) < 3:
    eventPlayer.forceButtonPress(Button.MELEE)
    
    # todo: нужно убедиться, чтол удар действительно наносится:
    # eventPlayer.setUltCharge(eventPlayer.getUltCharge() + 3)

    checkVendettaCounterAttack()

  wait(0.56, Wait.ABORT_WHEN_FALSE)
  if ruleCondition:
    loop()

rule "Zombies wall phase (zombiesfly)":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.isAlive()
  @Condition eventPlayer.isDummy()
  @Condition eventPlayer.botWantsWallPhasePoints >= BOT_WALL_PHASE_POINTS
  
  ResetBotStuckTimesSub()
  if eventPlayer.getDistanceToBotTarget() > BOT_MAX_NOT_LOS_TARGET_DISTANCE:
    TeleportToRandomSpawnPointSub()
    return

  eventPlayer.botWallPhase = true
  eventPlayer.setGravity(0)
  eventPlayer.disableEnvironmentCollision(false)
  eventPlayer.disablePlayerCollision()
  eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 25, 20, Relativity.TO_WORLD)
  wait(0.2)

  eventPlayer.applyImpulse(Vector.FORWARD, 5, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.setInvisibility(Invis.ALL)
  waitUntil(eventPlayer.isInLoSBotTarget(), 30)
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
  if any([distance(eventPlayer, player) <= 5 for player in combatants]): 
    eventPlayer.setStatusEffect(null, Status.STUNNED, 1.5)
    wait(1.2)
  else:
    eventPlayer.setStatusEffect(null, Status.ROOTED, 0.5)
  eventPlayer.enablePlayerCollision()
  eventPlayer.botWallPhase = false

  if ruleCondition:
    loop()
