#!mainFile "../main.opy"

#!define SpawnTp random.choice(spawnPointsList)
#!define PlayerTp (nearestWalkablePosition(angleToDirection(random.uniform(0, 360), random.uniform(-3, 3)) * random.uniform(5, 12) + eventPlayer.botTarget.getPosition()))

playervar option
playervar botStrafeTime
playervar botStrafeDir
playervar botSocialDistancing

def botTpToPlayer():
    if eventPlayer.getCurrentHero() == Hero.MOIRA:
        eventPlayer.teleport(nearestWalkablePosition(raycast(eventPlayer.botTarget, PlayerTp, null, null, false).getHitPosition()))
    else:
        eventPlayer.teleport(PlayerTp)
    wait()

def botResetOldPos():
    eventPlayer.moneyTotal__botOldPosition = eventPlayer.getPosition()
    eventPlayer.money__botStuckTimes = 0

def botRespawn(): # also change round end spawning & spawn queue
    eventPlayer.teleport(SpawnTp)
    eventPlayer.resurrect()
    eventPlayer.isReady = true
    eventPlayer.botWantsWallPhasePoints = true
    # wait(0.016, Wait.RESTART_WHEN_TRUE)
    wait()
    eventPlayer.setHealth(eventPlayer.getMaxHealth()) # bug where health > max hp on res


def clearTarget(): # clear all bots' targeting from non existent players
    [x for x in getPlayers(Team.1) if not entityExists(eventPlayer.botTarget)].botTarget = null

def botPhase(): # go to target player through walls
    eventPlayer.botWantsWallPhasePoints = false
    eventPlayer.stopForcingThrottle()
    eventPlayer.stopFacing()
    eventPlayer.stopForcingButton(Button.JUMP)
    switch eventPlayer.getCurrentHero():
        case Hero.ECHO:
            eventPlayer.disableEnvironmentCollision(true)
            # eventPlayer.option = true # want to use flight boost
            if distance(eventPlayer, eventPlayer.botTarget) > 30:
                eventPlayer.applyImpulse(vect(1,0,1)*directionTowards(eventPlayer, eventPlayer.botTarget), 50, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
            break
        case Hero.REAPER:
            if distance(eventPlayer, eventPlayer.botTarget) > 10: # far tp
                eventPlayer.forceButtonPress(Button.ABILITY_2)
                eventPlayer.option = eventPlayer.getPosition()
                eventPlayer.startScalingSize(0.01, false)
                eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 4)
                wait()
                botTpToPlayer()
                eventPlayer.setFacing(Vector.DOWN, Relativity.TO_WORLD)
                eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
                wait()
                eventPlayer.teleport(eventPlayer.option)
                eventPlayer.stopScalingSize()
                eventPlayer.clearStatusEffect(Status.PHASED_OUT)
            else: # close phase
                eventPlayer.setGravity(0)
                eventPlayer.disableEnvironmentCollision(false)
                eventPlayer.startForcingButton(Button.ABILITY_1)
                eventPlayer.setMoveSpeed(zomSpeedPct)
                waitUntil(eventPlayer.isUsingAbility1(), 3)
                eventPlayer.stopForcingButton(Button.ABILITY_1)
                # eventPlayer.applyImpulse(directionTowards(eventPlayer, eventPlayer.botTarget.getEyePosition()), 15, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
                eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 100, 20, Relativity.TO_WORLD, AccelReeval.DIRECTION_RATE_AND_MAX_SPEED)
                waitUntil(distance(eventPlayer, eventPlayer.botTarget) < 5 and isInLoS(eventPlayer.botTarget, eventPlayer, BarrierLos.PASS_THROUGH_BARRIERS), 3)
                eventPlayer.stopAcceleration()
                eventPlayer.setGravity(100)
                eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
                wait()
                eventPlayer.enableEnvironmentCollision()
                eventPlayer.cancelPrimaryAction()
            break
        case Hero.MOIRA:
            eventPlayer.startForcingButton(Button.ABILITY_1)
            waitUntil(eventPlayer.isUsingAbility1(), 5)
            # eventPlayer.forceButtonPress(Button.ABILITY_1)
            botTpToPlayer()
            wait()
            eventPlayer.stopForcingButton(Button.ABILITY_1)
            break
        case Hero.TORBJORN:
            eventPlayer.setGravity(0)
            eventPlayer.disableEnvironmentCollision(false)
            eventPlayer.setMoveSpeed(zomSpeedPct)
            waitUntil(eventPlayer.isUsingAbility1(), 3)
            # eventPlayer.applyImpulse(directionTowards(eventPlayer, eventPlayer.botTarget.getEyePosition()), 15, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
            eventPlayer.startAcceleration(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 100, 20, Relativity.TO_WORLD, AccelReeval.DIRECTION_RATE_AND_MAX_SPEED)
            waitUntil(distance(eventPlayer, eventPlayer.botTarget) < 5 and isInLoS(eventPlayer.botTarget, eventPlayer, BarrierLos.PASS_THROUGH_BARRIERS), 3)
            eventPlayer.stopAcceleration()
            eventPlayer.setGravity(100)
            eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
            wait()
            eventPlayer.enableEnvironmentCollision()
            eventPlayer.cancelPrimaryAction()
    wait()
    botResetOldPos()

def botChase(): # start walking towards target player
    eventPlayer.botStrafeTime++
    if eventPlayer.botStrafeTime > 10:
        eventPlayer.botStrafeTime = 0
        eventPlayer.botStrafeDir = random.randint(-1,1)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 420, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    # prevent walking too far fwd
    if distance(eventPlayer, eventPlayer.botTarget) > eventPlayer.botSocialDistancing:
        eventPlayer.startForcingThrottle(1, 1, 0, 1, eventPlayer.botStrafeDir, 1)
        if eventPlayer.getCurrentHero() == Hero.ECHO:
            eventPlayer.option = true
    else:
        eventPlayer.startForcingThrottle(0, 1, 1, 1, 0, 1)
        if eventPlayer.getCurrentHero() == Hero.ECHO:
            eventPlayer.option = false
    # check stuck. stuck times is reset on melee/beam/etc
    if distance(eventPlayer, eventPlayer.moneyTotal__botOldPosition) < 3.5:
        eventPlayer.money__botStuckTimes++
        if eventPlayer.money__botStuckTimes > 30:
            botPhase()
            botChase()

rule "bot targeting & repos polling (offense)":
  @Event eachPlayer
  @Team 2
  @Condition roundNumber > 0
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.hasStatusEffect(Status.STUNNED)
  do:
      if eventPlayer.isReady:
          eventPlayer.isReady = false
          eventPlayer.botWantsWallPhasePoints = true
          eventPlayer.botTarget = random.choice([x for x in getPlayers(Team.1) if not x.isInvisible or x.isDead() or not x.hasSpawned()])
          goto lbl_0
      # temp set bot target to arr of players in los & within 40m, sorted by distance
      eventPlayer.botTarget = sorted([x for x in getPlayersInRadius(eventPlayer.getEyePosition(), 40, Team.1, LosCheck.SURFACES)
          if not (x.isInvisible or x.isDead() or not x.hasSpawned())], lambda y: distance(eventPlayer, y))

      if eventPlayer.botTarget != []: # player found
          eventPlayer.botTarget = eventPlayer.botTarget[0]
          eventPlayer.enableEnvironmentCollision()
          botChase()
      else: # nobody in los, find closest player out of los to tp to
          eventPlayer.botTarget = sorted([x for x in getLivingPlayers(Team.1)
              if x.hasSpawned() and not x.isInvisible and x.isAlive()], lambda y: distance(eventPlayer, y))
          lbl_0:
          if eventPlayer.botTarget != []: # target found
              wait(0.32)
              if eventPlayer.botWantsWallPhasePoints: # 2nd try already
                  # if eventPlayer.getCurrentHero() == Hero.MOIRA:
                  #     smallMessage(hostPlayer, "moira no see nobody")
                  eventPlayer.botTarget = eventPlayer.botTarget[0]
                  botPhase()
                  botChase()
              else: # delay to not immediately vanish
                  eventPlayer.botWantsWallPhasePoints = true
                  wait(0.48, Wait.IGNORE_CONDITION)
                  continue
          else: # do nothing if no target still
              eventPlayer.stopForcingThrottle()
              botRespawn()
              wait(1.2)
      wait(0.24)
  while RULE_CONDITION


rule "reaper polling (attacks, jumps)":
  @Event eachPlayer
  @Team 2
  @Condition roundNumber > 0
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.botTarget.isInvisible
  do:
      if distance(eventPlayer.getEyePosition(), eventPlayer.botTarget) < 3 and isInLoS(eventPlayer, eventPlayer.botTarget, BarrierLos.PASS_THROUGH_BARRIERS):
          # if roundNumber % 7 == 0:
          #     eventPlayer.setUltCharge(100)
          #     eventPlayer.cancelPrimaryAction()
          #     wait()
          #     eventPlayer.forceButtonPress(Button.ULTIMATE)
          # else:
          eventPlayer.forceButtonPress(Button.MELEE)
          botResetOldPos()
      # horiz distance < 8, vert distance > 0.8
      if magnitude((eventPlayer.getPosition() - eventPlayer.botTarget.getPosition()) * vect(1,0,1)) < 8 and eventPlayer.botTarget.getPosition().y - eventPlayer.getPosition().y > 2:
          eventPlayer.setJumpVerticalSpeed(100 + 6 * abs(eventPlayer.getPosition().y - eventPlayer.botTarget.y))
          wait()
          eventPlayer.forceButtonPress(Button.JUMP)
          wait()
          if eventPlayer.botTarget.getPosition().y - eventPlayer.getPosition().y > 3.5:
              eventPlayer.applyImpulse(angleToDirection(random.uniform(0,359), 0), 20, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
          eventPlayer.setJumpVerticalSpeed(100)
      wait(0.56, Wait.IGNORE_CONDITION)
  while RULE_CONDITION