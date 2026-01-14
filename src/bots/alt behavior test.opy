#!mainFile "../main.opy"


playervar crowdControlled
playervar targeting
playervar botTarget
playervar potentialTargets
playervar pPowerUpCount_bTeleCount
playervar testTarget
playervar lastTarget
#/*
macro getCurrentZomSpeed():
  5.5 / 100 * zomSpeedPct

def restoreDefaultFacingMovement():
    @Name "restoreDefaultFacingMovement"
    
    if eventPlayer.botTarget:
      eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 0 if eventPlayer.crowdControlled else 100)
      eventPlayer.startThrottleInDirection(
        directionTowards(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()),
        getCurrentZomSpeed() if distance(eventPlayer.getPosition(), vect(eventPlayer.botTarget.getPosition().x, eventPlayer.getPosition().y, eventPlayer.botTarget.getPosition().z)) > 2 else 0,
        Relativity.TO_WORLD
      )
    else:
      eventPlayer.startThrottleInDirection(eventPlayer.getFacingDirection(), getCurrentZomSpeed(), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
      eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)


def selectTarget():
    @Name "selectTarget"
    
    eventPlayer.targeting = true
    #Set potential targets empty
    eventPlayer.potentialTargets = []
    #Miniboss prioritizes players on objective

    #Prioitize dummy bots
    eventPlayer.potentialTargets.append([player for player in combatants if player.isDummy()])

    #Add players who are below bot to target list
    eventPlayer.potentialTargets.append(
      sorted([i for i in combatants.exclude(eventPlayer.potentialTargets) if i.getPosition().y - eventPlayer.getPosition().y < 2.5], lambda i: distance(eventPlayer.getPosition(), i.getPosition()))
    )
   
    #Add remaining players
    eventPlayer.potentialTargets.append(sorted(combatants.exclude(eventPlayer.potentialTargets), lambda i: distance(eventPlayer.getPosition(), i.getPosition())))
    #Remove invisible players
    eventPlayer.potentialTargets = [player for player in eventPlayer.potentialTargets]
    for eventPlayer.pPowerUpCount_bTeleCount in range(len(eventPlayer.potentialTargets)):
        eventPlayer.testTarget = eventPlayer.potentialTargets[eventPlayer.pPowerUpCount_bTeleCount]
        if isInLoS(eventPlayer.testTarget.getEyePosition(), eventPlayer.getPosition() + vect(0, LosHeightCheckVectConst, 0)):
            break
        #wait()
    if eventPlayer.isAlive():
        eventPlayer.botTarget = eventPlayer.testTarget
        eventPlayer.lastTarget = eventPlayer.botTarget
        async(restoreDefaultFacingMovement, AsyncBehavior.RESTART)
    eventPlayer.targeting = false


rule "BOT INITIALIZATION":
  @Event eachPlayer
  @Team 2
  
  eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)
  eventPlayer.crowdControlled = false
  eventPlayer.targeting = false

rule "BOT STUN MANAGEMENT":
    @Event eachPlayer
    @Team 2
    @Condition (eventPlayer.hasStatus(Status.KNOCKED_DOWN) or eventPlayer.hasStatus(Status.ASLEEP) or eventPlayer.hasStatus(Status.FROZEN) or eventPlayer.hasStatus(Status.STUNNED))
    
    eventPlayer.crowdControlled = true
    wait(0.125)
    if ruleCondition:
      loop()
    eventPlayer.crowdControlled = false

rule "BOT TARGET VISIBLE":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.hasSpawned()
    @Condition (not eventPlayer.botTarget or any([distance(i.getPosition(), eventPlayer.getPosition()) < 7.5 for i in combatants.exclude(eventPlayer.botTarget)]))
    @Condition (any([distance(eventPlayer.getPosition(), player.getPosition()) < 150 and isInLoS(player.getEyePosition(), eventPlayer.getPosition() + vect(0, LosHeightCheckVectConst, 0)) for player in combatants]))
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    async(selectTarget, AsyncBehavior.RESTART)
    wait(1)
    if ruleCondition:
        loop()


rule "BOT TAKES DAMAGE AND SWITCHES TARGETS":
    @Event playerTookDamage
    @Team 2
    @Condition eventPlayer.botTarget
    @Condition (attacker != eventPlayer.botTarget)
    @Condition eventPlayer.isAlive()
    @Condition attacker.getTeam() != victim.getTeam()
    
    async(selectTarget, AsyncBehavior.NOOP)
    wait(2)

rule "DESELECT BOT TARGET":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget != null
    @Condition (not eventPlayer.botTarget in combatants or not isInLoS(eventPlayer.botTarget.getEyePosition(), eventPlayer.getPosition() + vect(0, LosHeightCheckVectConst, 0))) == true
    
    eventPlayer.botTarget = null
    eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.lastTarget.getPosition() + normalize(worldVector(eventPlayer.lastTarget.getThrottle(), eventPlayer.lastTarget, Transform.ROTATION)) * -2), getCurrentZomSpeed(), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
    eventPlayer.startFacing(eventPlayer.getThrottle(), 0 if eventPlayer.crowdControlled else 100, Relativity.TO_PLAYER)
    wait(0.125, Wait.RESTART_WHEN_TRUE)
    if ruleCondition:
        loop()


rule "BOT WANDERS":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget == null
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.hasStatus(Status.ROOTED) == false
    #Allows if bot bumps into something
    @Condition eventPlayer.getHorizontalSpeed() < (getCurrentZomSpeed() - 0.3)
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startThrottleInDirection(directionFromAngles(horizontalAngleOfDirection(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) + random.uniform(90, 270), 0), getCurrentZomSpeed(), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
    wait(1)
    if ruleCondition:
        loop()


rule "BOTS JUMP":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isJumping() != true
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.hasStatus(Status.ROOTED) == false
    @Condition eventPlayer.isCrouching() == false
    @Condition (eventPlayer.botTarget == null or distance(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()) > 2) == true
    #Allows if bot bumps into something
    @Condition eventPlayer.getHorizontalSpeed() < (getCurrentZomSpeed() - 0.3)
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.JUMP)
    if ruleCondition:
        loop()



rule "BOTS MELEE":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget
    @Condition not eventPlayer.crowdControlled
    @Condition not eventPlayer.isMeleeing()
    @Condition distance(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()) < 3
    # @Condition eventPlayer.botTarget.getHorizontalSpeed() < 15 * eventPlayer.botTarget.movementSpeed
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.MELEE)
    if ruleCondition:
      loop()

#*/

# rule "UPDATE SUCCESSFUL TELEPORT STATUS":
#     @Event eachPlayer
#     @Team 2
#     @Condition eventPlayer.botTarget
#     @Condition not eventPlayer.successfullyTeleported
    
#     wait(0.5, Wait.ABORT_WHEN_FALSE)
#     if not eventPlayer.successfullyTeleported:
#         eventPlayer.successfullyTeleported = true
#     if distance(eventPlayer.telePos, eventPlayer.averagePlayersPos) < botMaxTeleportRange[1]:
#         eventPlayer.waypoint = eventPlayer.getPosition()
#         updateBotSpawnPoints()

# rule "TELEPORT BOTS WHEN NOT USED FOR TOO LONG":
#     @Event eachPlayer
#     @Team 2
#     @Condition not eventPlayer.targeting
#     @Condition not eventPlayer.botTarget
#     @Condition eventPlayer.isAlive()
#     @Condition (all([not isInLoS(i.getEyePosition(), eventPlayer.getPosition() + vect(0, LosHeightCheckVectConst, 0)) for i in [player for player in combatants if player.invisible]])) == true
    
#     if eventPlayer.successfullyTeleported:
#       wait(5, Wait.ABORT_WHEN_FALSE)
#     else:
#       wait(0.5, Wait.ABORT_WHEN_FALSE)
#       wait(max(1, 10 - distance(eventPlayer.getPosition(), eventPlayer.averagePlayersPos) / 8), Wait.ABORT_WHEN_FALSE)
#       if eventPlayer.successfullyTeleported:
#         loop()
#     teleportBots()
#     loop()

# rule "KILL BOTS THAT ARE STUCK OR ARE NOT MOVING":
#     @Event eachPlayer
#     @Team 2
#     @Condition gameStatus == true
#     @Condition eventPlayer.crowdControlled != true
#     @Condition eventPlayer.isAlive() == true
#     @Condition (eventPlayer.getThrottle() == vect(0, 0, 0) or eventPlayer.getHorizontalSpeed() < 1 * eventPlayer.botThrottleSpeed * eventPlayer.movementSpeed) == true
#     @Condition all([distance(eventPlayer.getPosition(), player.getPosition()) > 2.1 * eventPlayer.size for player in combatants]) == true
    
#     if eventPlayer.botTarget != null:
#         wait(random.uniform(7.5, 12.5), Wait.ABORT_WHEN_FALSE)
#     else:
#         wait(5, Wait.ABORT_WHEN_FALSE)
#     eventPlayer.teleport(vect(0, -500, 0))
#     if ruleCondition:
#         loop()


# rule "BOT DIES":
#     @Event playerDied
#     @Team 2
#     @Condition isGameInProgress() == true
#     @Condition eventPlayer.isDead() == true
    
#     wait(3 if eventPlayer.getHero() in [Hero.SYMMETRA, Hero.ANA] else 0)
#     eventPlayer.botTarget = null
#     eventPlayer.potentialTargets = []
#     eventPlayer.stopAllDamageOverTime()
#     eventPlayer.stopThrottleInDirection()
#     eventPlayer.stopFacing()
#     if not eventWasEnvironment or attacker.getTeam() == Team.1:
#         #Miniboss kill bonus
#         if eventPlayer in miniBoss and objectiveTypes[0] == 1:
#             playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, null, objectivePositions, 100)
#             objectiveCaptureValue += 10
#             wait(2)
#         #Remove miniboss from zombie
#         miniBoss[miniBoss.index(eventPlayer)] = 0
#         eventPlayer.disableNameplatesFor(getAllPlayers())
#         #Allow for custom revive times
#         waitUntil(eventPlayer.reviveTimer > 0, 0.125)
#         if eventPlayer.reviveTimer <= 0:
#             eventPlayer.reviveTimer = 1 + ((getMatchTime() + matchEndTime) / 60)
#         if len(spawnTimes) < numberOfBots:
#             spawnTimes.append(eventPlayer.reviveTimer)
#         if eventPlayer.customTelePos:
#             customTelePositions.append(eventPlayer.customTelePos)
#         wait(1)
#         waitUntil(eventPlayer.damageOverTimeDuration <= 0, 10)
#         updateBotSpawnPoints()
#         destroyDummy(Team.2, eventPlayer.getSlot())
#         return
#     elif eventWasEnvironment and distance(eventPlayer.getPosition(), vect(eventPlayer.telePos.x, eventPlayer.getPosition().y, eventPlayer.telePos.z)) < 10:
#         eventPlayer.successfullyTeleported = false
#     eventPlayer.teleporting = true
#     eventPlayer.teleport(vect(500, 50, 500))
#     wait(0.25)
#     eventPlayer.resurrect()


# def enterExitTeleport():
#     @Name "enterExitTeleport"
    
#     if eventPlayer.teleporting:
#         eventPlayer.setInvisibility(Invis.ALL)
#         eventPlayer.stopThrottleInDirection()
#         eventPlayer.setGravity(0)
#     else:
#         eventPlayer.setStatusEffect(null, Status.ROOTED, 0.25)
#         eventPlayer.setInvisibility(Invis.NONE)
#         eventPlayer.setGravity(100)
#         if eventPlayer.botTarget == null:
#             if eventPlayer.telePos in botSpawnPoints:
#                 eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), waypoints[botSpawnPoints.index(eventPlayer.telePos)]), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
#             else:
#                 eventPlayer.startThrottleInDirection(directionFromAngles(random.randint(-90, 90) + horizontalAngleOfDirection(directionTowards(eventPlayer.getPosition(), sorted([player for player in getLivingPlayers(Team.1) if player.hasSpawned()], lambda i: distance(eventPlayer.getPosition(), i.getPosition()))[0].getPosition())), 0), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
#         elif eventPlayer.botTarget != null:
#             async(restoreDefaultFacingMovement, AsyncBehavior.NOOP)


# def teleportBots():
#     @Name "teleportBots"
    
#     eventPlayer.teleporting = true
#     updateBotSpawnPoints()
#     enterExitTeleport()
#     eventPlayer.successfullyTeleported = false
#     waitUntil(eventPlayer.canTeleport, 99999)
#     if eventPlayer.customTelePos == null:
#         while eventPlayer.teleporting:
#             botTeleportCenter()
#             wait()
#             eventPlayer.telePos = 0
#             #Teleport with max distance constraint no view angle constraint
#             while eventPlayer.telePos == 0 or any([distance(eventPlayer.telePos, player.getPosition()) < 15 for player in combatants]) or all([distance(eventPlayer.telePos, player.getPosition()) > botMaxTeleportRange[1] for player in combatants]):
#                 eventPlayer.filteredBotSpawnPointGrid = [player for player in botSpawnPoints if distance(player, eventPlayer.averagePlayersPos) < botMaxTeleportRange[1]]
#                 #Filter out spawn points on cooldown
#                 eventPlayer.filteredBotSpawnPointGrid = [player for player in eventPlayer.filteredBotSpawnPointGrid if botSpawnPointTimers[botSpawnPoints.index(player)] < 15]
#                 #Bots utilize saved spawn points
#                 if len(botSpawnPoints) > 0 and len(eventPlayer.filteredBotSpawnPointGrid) > 0:
#                     eventPlayer.telePos = random.choice(eventPlayer.filteredBotSpawnPointGrid)
#                     botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)] += 5
#                     break
#                 else:
#                     eventPlayer.telePos = nearestWalkablePosition(eventPlayer.averagePlayersPos + directionFromAngles(random.uniform(0, 360), random.uniform(-20, 10)) * random.uniform(0, botMaxTeleportRange[1]))
#                 wait(0.25)
#             if all([distance(eventPlayer.telePos, player.getPosition()) > 10 for player in combatants]) and all([not isInLoS(i.getEyePosition(), eventPlayer.telePos + vect(0, LosHeightCheckVectConst, 0)) for i in [player for player in combatants if player.isInViewAngle(eventPlayer.telePos, 55)]]):
#                 eventPlayer.teleport(eventPlayer.telePos)
#                 eventPlayer.teleporting = false
#                 #Teleport was unsuccessful due to line of sight and view angle
#             elif eventPlayer.telePos in botSpawnPoints:
#                 del waypoints[botSpawnPoints.index(eventPlayer.telePos)]
#                 del botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)]
#                 botSpawnPoints.remove(eventPlayer.telePos)
#     else:
#         eventPlayer.teleport(eventPlayer.customTelePos)
#         eventPlayer.customTelePos = null
#         eventPlayer.teleporting = false
#     wait()
#     enterExitTeleport()


# def botTeleportCenter():
#     @Name "botTeleportCenter"
    
#     #Standoff, Extraction, Biomorphing, Zombie Egg
#     if objectiveTypes[0] in [1, 3, 6]:
#         eventPlayer.averagePlayersPos = sorted(combatants, lambda player: distance(player.getPosition(), objectivePositions[0]))[0].getPosition()
#         #Boss
#     elif objectiveTypes[0] == 2:
#         eventPlayer.averagePlayersPos = sorted(combatants, lambda player: distance(player.getPosition(), bosses[0].getPosition()))[0].getPosition()
#         #Survivor Rescue
#     elif objectiveTypes[0] == 4:
#         if survivorToRescue.botFollowTarget == null:
#             eventPlayer.averagePlayersPos = sorted(combatants, lambda player: distance(player.getPosition(), survivorToRescue.getPosition()))[0].getPosition()
#         else:
#             eventPlayer.averagePlayersPos = survivorToRescue.botFollowTarget.getPosition()
#         #Killzone
#     elif objectiveTypes[0] == 5:
#         #If players are in the killzone
#         if len([player for player in combatants if distance(player.getPosition(), objectiveChase1) < objectiveRad]) > 0:
#             #Player closeset to the center of the killzone
#             eventPlayer.averagePlayersPos = sorted(combatants, lambda player: distance(player.getPosition(), objectiveChase1))[0].getPosition()
#         else:
#             #Average player positon
#             locateAveragePlayerLocation()
#         #Satellite Uplink
#     elif objectiveTypes[0] == 7:
#         #Checks if any players are currently repairing terminals
#         if len(playersOnObjective) > 0:
#             eventPlayer.averagePlayersPos = random.choice(playersOnObjective).getPosition()
#         else:
#             #Closest player to sattelite firing position
#             eventPlayer.averagePlayersPos = sorted(combatants, lambda player: distance(player.getPosition(), objectivePositions[0]))[0].getPosition()
#         #Default
#     else:
#         locateAveragePlayerLocation()


# def locateAveragePlayerLocation():
#     @Name "locateAveragePlayerLocation"
    
#     eventPlayer.averagePlayersPos = vect(0, 0, 0)
#     if len(playersOnObjective) == 0 and any([player.getThrottle() != vect(0, 0, 0) for player in combatants]):
#         for eventPlayer.pPowerUpCount_bTeleCount in range(len([player for player in combatants if player.getThrottle() != vect(0, 0, 0)])):
#             eventPlayer.averagePlayersPos += (([player for player in combatants if player.getThrottle() != vect(0, 0, 0)])[eventPlayer.pPowerUpCount_bTeleCount]).getPosition()
#     else:
#         for eventPlayer.pPowerUpCount_bTeleCount in range(len(combatants)):
#             eventPlayer.averagePlayersPos += combatants[eventPlayer.pPowerUpCount_bTeleCount].getPosition()
#     eventPlayer.averagePlayersPos /= eventPlayer.pPowerUpCount_bTeleCount


# def successfulTeleportStatus():
#     @Name "successfulTeleportStatus"
    
#     #Max teleport distance adjustment
#     if not eventPlayer.successfullyTeleported:
#         eventPlayer.successfullyTeleported = true


# def updateBotSpawnPoints():
#     @Name "updateBotSpawnPoints"
    
#     if eventPlayer.successfullyTeleported and eventPlayer.customTelePos == null and not eventPlayer.telePos in botSpawnPoints:
#         botSpawnPoints.append(eventPlayer.telePos)
#         waypoints.append(eventPlayer.waypoint)
#         botSpawnPointTimers.append(0)
#     elif not eventPlayer.successfullyTeleported and eventPlayer.telePos in botSpawnPoints:
#         del waypoints[botSpawnPoints.index(eventPlayer.telePos)]
#         del botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)]
#         botSpawnPoints.remove(eventPlayer.telePos)


# def abilityPlacement():
#     @Name "abilityPlacement"
    
#     wait(0.5)
#     if eventPlayer.crowdControlled == true:
#         return
#     eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
#     eventPlayer.setStatusEffect(null, Status.ROOTED, 1.6)
#     waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_2) == true, 1)
#     if eventPlayer.getAbilityCooldown(Button.ABILITY_2) == true:
#         wait(1)
#         eventPlayer.forceButtonPress(Button.INTERACT)
#     else:
#         eventPlayer.cancelPrimaryAction()


# def abilityThrowdown():
#     @Name "abilityThrowdown"
    
#     if eventPlayer.hasStatus(Status.HACKED):
#         return
#     eventPlayer.disallowButton(Button.MELEE)
#     eventPlayer.startFacing(Vector.DOWN, 999)
#     wait(0.3)
#     eventPlayer.forceButtonPress(Button.ABILITY_2)
#     eventPlayer.allowButton(Button.MELEE)
#     restoreDefaultFacingMovement()
#     if eventPlayer.getHero() == Hero.HAZARD:
#         wait(0.25)
#         if eventPlayer.crowdControlled or eventPlayer.hasStatus(Status.HACKED):
#             return
#         ([player for player in getPlayersInRadius(eventPlayer, 2, Team.2, LosCheck.SURFACES) if player != eventPlayer]).applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
#         eventPlayer.applyImpulse(Vector.UP, distance(eventPlayer.botTarget, eventPlayer) * (2 / eventPlayer.size), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
#         eventPlayer.abilityArray1 += 2


# def entityFloat():
#     @Name "entityFloat"
    
#     #Entities that will be floated
#     eventPlayer.botSpecialPotentialTargets = [player for player in getLivingPlayers(Team.ALL) if player != eventPlayer and distance(eventPlayer.getPosition(), player.getPosition()) < 12 * eventPlayer.size and isInLoS(player.getPosition() + vect(0, LosHeightCheckVectConst, 0), eventPlayer.getPosition() + vect(0, LosHeightCheckVectConst, 0), BarrierLos.BLOCKED_BY_ENEMY_BARRIERS)]

