rule "BOT INITIALIZATION":
    @Event eachPlayer
    @Team 2
    @Condition isGameInProgress() == true
    @Condition specialGameModeSetup != true
    
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startHealingOverTime(null, 9999, 9999)
    eventPlayer.reviveTimer = 0
    if len(customTelePositions) > 0:
        eventPlayer.customTelePos = customTelePositions[0]
        del customTelePositions[0]
    else:
        eventPlayer.customTelePos = null
    eventPlayer.canTeleport = false
    #Damage over time duration
    chaseAtRate(eventPlayer.damageOverTimeDuration, -1, 0.95, ChaseRateReeval.NONE)
    #Bot target warning icon (flashing)
    createIcon([player for player in eventPlayer.botTarget if eventPlayer.isAlive() and not player.isInViewAngle(eventPlayer.getPosition(), 55)], eventPlayer, Icon.WARNING, IconReeval.VISIBILITY_POSITION_AND_COLOR, Color.RED if (((ceil(getTotalTimeElapsed() * (4 if distance(eventPlayer.getPosition(), localPlayer.getPosition()) > 10 else 8))) % 2) == 0) else Color.YELLOW)
    waitUntil(eventPlayer.hasSpawned(), 2)
    eventPlayer.setMaxHealth(40 if eventPlayer.getHero() in [Hero.SYMMETRA, Hero.HAZARD, Hero.ILLARI] else 1)
    eventPlayer.initialMaxHealth = eventPlayer.getMaxHealth()
    #Bot Health Pool
    eventPlayer.addHealthPool(Health.NORMAL, max(0, eventPlayer.health - eventPlayer.initialMaxHealth), true)
    #Bot Health Pool
    eventPlayer.addHealthPool(Health.NORMAL, max(0, eventPlayer.health - 10000), true)
    eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)
    eventPlayer.setRespawnTime(30)
    if not eventPlayer in bosses:
        botRespawnInitialization()
    eventPlayer.canTeleport = true


rule "KILL BOTS THAT ARE STUCK OR ARE NOT MOVING":
    @Event eachPlayer
    @Team 2
    @Condition gameStatus == true
    @Condition eventPlayer.teleporting != true
    @Condition eventPlayer.specialThrottling != true
    @Condition eventPlayer.attached != true
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer in bosses == false
    @Condition (eventPlayer.getThrottle() == vect(0, 0, 0) or eventPlayer.getHorizontalSpeed() < 1 * eventPlayer.botThrottleSpeed * eventPlayer.movementSpeed) == true
    @Condition all([distance(eventPlayer.getPosition(), player.getPosition()) > 2.1 * eventPlayer.size for player in playerTargetList]) == true
    
    if eventPlayer.botTarget != null:
        wait(random.uniform(7.5, 12.5), Wait.ABORT_WHEN_FALSE)
    else:
        wait(5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(vect(0, -500, 0))
    if ruleCondition:
        loop()


rule "BOT DIES":
    @Event playerDied
    @Team 2
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isDead() == true
    @Condition eventPlayer in bosses == false
    
    wait(3 if eventPlayer.getHero() in [Hero.SYMMETRA, Hero.ANA] else 0)
    eventPlayer.botTarget = null
    eventPlayer.potentialTargets = []
    eventPlayer.stopAllDamageOverTime()
    eventPlayer.stopThrottleInDirection()
    eventPlayer.stopFacing()
    if not eventWasEnvironment or attacker.getTeam() == Team.1:
        #Miniboss kill bonus
        if eventPlayer in miniBoss and objectiveTypes[0] == 1:
            playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, null, objectivePositions, 100)
            objectiveCaptureValue += 10
            wait(2)
        #Remove miniboss from zombie
        miniBoss[miniBoss.index(eventPlayer)] = 0
        eventPlayer.disableNameplatesFor(getAllPlayers())
        #Allow for custom revive times
        waitUntil(eventPlayer.reviveTimer > 0, 0.125)
        if eventPlayer.reviveTimer <= 0:
            eventPlayer.reviveTimer = 1 + ((getMatchTime() + matchEndTime) / 60)
        if len(spawnTimes) < numberOfBots:
            spawnTimes.append(eventPlayer.reviveTimer)
        if eventPlayer.customTelePos:
            customTelePositions.append(eventPlayer.customTelePos)
        wait(1)
        waitUntil(eventPlayer.damageOverTimeDuration <= 0, 10)
        updateBotSpawnPoints()
        destroyDummy(Team.2, eventPlayer.getSlot())
        return
    elif eventWasEnvironment and distance(eventPlayer.getPosition(), vect(eventPlayer.telePos.x, eventPlayer.getPosition().y, eventPlayer.telePos.z)) < 10:
        eventPlayer.successfullyTeleported = false
    eventPlayer.teleporting = true
    eventPlayer.teleport(vect(500, 50, 500))
    wait(0.25)
    eventPlayer.resurrect()


rule "TELEPORT BOTS (GENERAL)":
    @Event eachPlayer
    @Team 2
    @Condition gameStatus == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer in bosses == false
    @Condition getNumberOfLivingPlayers(Team.1) > 0
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    teleportBots()


rule "TELEPORT BOTS WHEN NOT USED FOR TOO LONG":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.teleporting != true
    @Condition gameStatus == true
    @Condition eventPlayer.attached != true
    @Condition eventPlayer.targeting != true
    @Condition eventPlayer.botTarget == null
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer in bosses == false
    @Condition (all([not isInLoS(i.getEyePosition(), eventPlayer.getPosition() + vect(0, losHeightCheck, 0)) for i in [player for player in playerTargetList if player.invisible]])) == true
    
    if eventPlayer.successfullyTeleported:
        wait(5, Wait.ABORT_WHEN_FALSE)
    else:
        wait(0.5, Wait.ABORT_WHEN_FALSE)
        wait(max(1, 10 - distance(eventPlayer.getPosition(), eventPlayer.averagePlayersPos) / 8), Wait.ABORT_WHEN_FALSE)
        if eventPlayer.successfullyTeleported:
            loop()
    teleportBots()
    loop()


rule "BOT STUN MANAGEMENT":
    @Event eachPlayer
    @Team 2
    @Condition (eventPlayer.hasStatus(Status.KNOCKED_DOWN) or eventPlayer.hasStatus(Status.ASLEEP) or eventPlayer.hasStatus(Status.FROZEN) or eventPlayer.hasStatus(Status.STUNNED)) == true
    
    eventPlayer.crowdControlled = true
    wait(0.125)
    if ruleCondition:
        loop()
    eventPlayer.crowdControlled = false


rule "UPDATE SUCCESSFUL TELEPORT STATUS":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget != null
    @Condition eventPlayer.teleporting != true
    @Condition eventPlayer.successfullyTeleported != true
    @Condition specialGameModeSetup != true
    @Condition eventPlayer in bosses == false
    
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    if not eventPlayer.successfullyTeleported:
        eventPlayer.successfullyTeleported = true
    if distance(eventPlayer.telePos, eventPlayer.averagePlayersPos) < botMaxTeleportRange[1]:
        eventPlayer.waypoint = eventPlayer.getPosition()
        updateBotSpawnPoints()


rule "BOT TARGET VISIBLE":
    @Event eachPlayer
    @Team 2
    @Condition specialGameModeSetup != true
    @Condition eventPlayer.teleporting != true
    @Condition eventPlayer.initializing != true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition (eventPlayer.botTarget == null or any([not i.invisible and distance(i.getPosition(), eventPlayer.getPosition()) < 7.5 for i in playerTargetList.exclude(eventPlayer.botTarget)])) == true
    @Condition (any([not player.invisible and distance(eventPlayer.getPosition(), player.getPosition()) < 150 and isInLoS(player.getEyePosition(), eventPlayer.getPosition() + vect(0, losHeightCheck, 0)) for player in playerTargetList])) == true
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    async(selectTarget, AsyncBehavior.RESTART)
    wait(1)
    if ruleCondition:
        loop()


rule "BOT TAKES DAMAGE AND SWITCHES TARGETS":
    @Event playerTookDamage
    @Team 2
    @Condition eventPlayer.botTarget != null
    @Condition (attacker != eventPlayer.botTarget or eventPlayer in miniBoss) == true
    @Condition eventPlayer.isAlive() == true
    @Condition attacker.getTeam() != victim.getTeam()
    
    async(selectTarget, AsyncBehavior.NOOP)
    wait(2)


def selectTarget():
    @Name "selectTarget"
    
    eventPlayer.targeting = true
    #Set potential targets empty
    eventPlayer.potentialTargets = []
    #Miniboss prioritizes players on objective
    if eventPlayer in miniBoss:
        eventPlayer.potentialTargets.append([player for player in playersOnObjective if not player.isDummy()])
    #Prioitize dummy bots
    eventPlayer.potentialTargets.append([player for player in playerTargetList if player.isDummy()])
    #Add players who are below bot to target list
    eventPlayer.potentialTargets.append(sorted([i for i in playerTargetList.exclude(eventPlayer.potentialTargets) if i.getPosition().y - eventPlayer.getPosition().y < 2.5], lambda i: distance(eventPlayer.getPosition(), i.getPosition())))
    #Add remaining players
    eventPlayer.potentialTargets.append(sorted(playerTargetList.exclude(eventPlayer.potentialTargets), lambda i: distance(eventPlayer.getPosition(), i.getPosition())))
    #Remove invisible players
    eventPlayer.potentialTargets = [player for player in eventPlayer.potentialTargets if not player.invisible]
    for eventPlayer.pPowerUpCount_bTeleCount in range(len(eventPlayer.potentialTargets)):
        eventPlayer.testTarget = eventPlayer.potentialTargets[eventPlayer.pPowerUpCount_bTeleCount]
        if isInLoS(eventPlayer.testTarget.getEyePosition(), eventPlayer.getPosition() + vect(0, losHeightCheck, 0)):
            break
        #wait()
    if eventPlayer.isAlive():
        eventPlayer.botTarget = eventPlayer.testTarget
        eventPlayer.lastTarget = eventPlayer.botTarget
        async(restoreDefaultFacingMovement, AsyncBehavior.RESTART)
    eventPlayer.targeting = false


def restoreDefaultFacingMovement():
    @Name "restoreDefaultFacingMovement"
    
    if eventPlayer.botTarget != null:
        if not eventPlayer.specialFacing:
            eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition()), 1500 if eventPlayer.attached else 0 if eventPlayer.crowdControlled else 100)
        if not eventPlayer.specialThrottling:
            eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()), eventPlayer.botThrottleSpeed if distance(eventPlayer.getPosition(), vect(eventPlayer.botTarget.getPosition().x, eventPlayer.getPosition().y, eventPlayer.botTarget.getPosition().z)) > 2 * min(1, eventPlayer.size) else 0, Relativity.TO_WORLD)
    else:
        eventPlayer.startThrottleInDirection(eventPlayer.getFacingDirection(), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        eventPlayer.startFacing(eventPlayer.getThrottle(), 100, Relativity.TO_PLAYER)


rule "DESELECT BOT TARGET":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.teleporting != true
    @Condition eventPlayer.botTarget != null
    @Condition (eventPlayer.botTarget.invisible or not eventPlayer.botTarget in playerTargetList or not isInLoS(eventPlayer.botTarget.getEyePosition(), eventPlayer.getPosition() + vect(0, losHeightCheck, 0))) == true
    
    eventPlayer.botTarget = null
    if not eventPlayer.specialThrottling:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), eventPlayer.lastTarget.getPosition() + normalize(worldVector(eventPlayer.lastTarget.getThrottle(), eventPlayer.lastTarget, Transform.ROTATION)) * -2), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
    if not eventPlayer.specialFacing:
        eventPlayer.startFacing(eventPlayer.getThrottle(), 0 if eventPlayer.crowdControlled else 100, Relativity.TO_PLAYER)
    wait(0.125, Wait.RESTART_WHEN_TRUE)
    if ruleCondition:
        loop()


rule "BOT WANDERS":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget == null
    @Condition eventPlayer.specialThrottling != true
    @Condition eventPlayer.specialFacing != true
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.hasStatus(Status.ROOTED) == false
    #Allows if bot bumps into something
    @Condition eventPlayer.getHorizontalSpeed() < eventPlayer.botThrottleSpeed * eventPlayer.movementSpeed * 3.5
    @Condition specialGameModeSetup != true
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.startThrottleInDirection(directionFromAngles(horizontalAngleOfDirection(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) + random.uniform(90, 270), 0), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
    wait(1)
    if ruleCondition:
        loop()


rule "BOTS JUMP":
    @Event eachPlayer
    @Team 2
    @Condition specialGameModeSetup != true
    @Condition eventPlayer.specialThrottling == false
    @Condition eventPlayer.attached != true
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isJumping() != true
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.hasStatus(Status.ROOTED) == false
    @Condition eventPlayer.isCrouching() == false
    @Condition (eventPlayer.botTarget == null or distance(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()) > 2) == true
    #Allows if bot bumps into something
    @Condition eventPlayer.getHorizontalSpeed() < eventPlayer.botThrottleSpeed * eventPlayer.movementSpeed * 3.5
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.JUMP)
    if ruleCondition:
        loop()


rule "BOTS MOVE THROUGH SPAWN DOORS":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget != null
    @Condition eventPlayer.wallCollisionEnabled == true
    @Condition eventPlayer.canWallPhase == true
    @Condition eventPlayer.attached != true
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasStatus(Status.ROOTED) == false
    @Condition eventPlayer.getThrottle() != vect(0, 0, 0)
    @Condition (eventPlayer.isOnGround() or eventPlayer in bosses and eventPlayer.getAltitude() < 10) == true
    #Allows if bot bumps into something
    @Condition eventPlayer.getSpeedInDirection(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) < eventPlayer.botThrottleSpeed * eventPlayer.movementSpeed * 3
    #Makes sure bot is moving forward
    @Condition eventPlayer.getSpeedInDirection(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) >= 0
    @Condition isInLoS(eventPlayer.getPosition() + vect(0, 0.75, 0) * eventPlayer.size, eventPlayer.getPosition() + vect(0, 0.75, 0) * eventPlayer.size + normalize(worldVector(eventPlayer.getThrottle(), eventPlayer, Transform.ROTATION)) * 3 * eventPlayer.size) == true
    
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.disableEnvironmentCollision(false)
    eventPlayer.wallCollisionEnabled = false
    if eventPlayer in bosses:
        wait(2, Wait.RESTART_WHEN_TRUE)
    else:
        wait(1)
    if ruleCondition:
        loop()
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.wallCollisionEnabled = true
    if not eventPlayer in bosses:
        wait(5)


rule "BOTS MELEE":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.botTarget != null
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.isMeleeing() != true
    @Condition distance(eventPlayer.getPosition(), eventPlayer.botTarget.getPosition()) < 3 * eventPlayer.size
    @Condition eventPlayer.botTarget.getHorizontalSpeed() < 15 * eventPlayer.botTarget.movementSpeed
    
    if eventPlayer.getHero() == Hero.HAZARD and not eventPlayer.botTempValue and not eventPlayer.abilityArray1 and eventPlayer in bosses:
        eventPlayer.botTempvalue2 = true
        eventPlayer.specialFacing = true
        eventPlayer.chase1 = -20
        eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.botTarget.getEyePosition() + vect(eventPlayer.chase1, 0, 0)), 9999 if eventPlayer.chase1 == -20 else 100)
        chaseOverTime(eventPlayer.chase1, 25, 3)
        for eventPlayer.pBouncePadCount1 in range(5):
            eventPlayer.setUltCharge(100)
            wait()
            eventPlayer.clearStatusEffect(Status.HACKED)
            eventPlayer.forceButtonPress(Button.ULTIMATE)
            wait(0.8)
            if eventPlayer.crowdControlled or eventPlayer.hasStatus(Status.HACKED):
                break
            waitUntil(not eventPlayer.isUsingUltimate(), 99999)
        eventPlayer.specialFacing = false
        restoreDefaultFacingMovement()
        stopChasingVariable(eventPlayer.chase1)
        eventPlayer.abilityArray1 += 10
        eventPlayer.botTempvalue2 = false
    wait(0.125, Wait.ABORT_WHEN_FALSE)
    eventPlayer.forceButtonPress(Button.MELEE)
    if ruleCondition:
        loop()


rule "BOTS INFLICT DAMAGE OVER TIME (INFECTION LEVEL MANAGEMENT)":
    @Event playerDealtDamage
    @Team 2
    @Condition eventAbility == Button.MELEE
    @Condition victim.getTeam() == Team.1
    
    victim.startDamageOverTime(eventPlayer, eventPlayer.biteDuration, eventPlayer.biteDamage)
    if eventPlayer.damageOverTimeDuration < eventPlayer.biteDuration:
        eventPlayer.damageOverTimeDuration = eventPlayer.biteDuration
    if createWorkshopSettingBool("Infection", "Melee Infection Enabled", true) and not eventPlayer.hasStatus(Status.HACKED) and not victim.isDummy() and (victim.getHealth() <= (victim.getMaxHealth() if victim.enhancementValues[13] != null else victim.initialMaxHealth)):
        victim.infectionLvl += (2 if eventPlayer in bosses or eventPlayer in miniBoss or eventPlayer.mutationValue == 4 else 1) / ((3 if not victim.infected and victim.getHero() in [Hero.REINHARDT, Hero.HAZARD, Hero.VENDETTA] else 2) if victim.enhancementValues[0] != 2 else 1)
        if not victim.infected and victim.infectionLvl >= 1:
            victim.infected = true


rule "BOTS RECOIL FROM DAMAGE":
    @Event playerTookDamage
    @Team 2
    @Condition eventDamage > 20
    @Condition eventPlayer.crowdControlled != true
    @Condition eventPlayer.attached != true
    @Condition attacker.getTeam() == Team.1
    @Condition victim.isAlive() == true
    @Condition eventDamage > 0.3 * eventPlayer.health
    
    if victim.isInAir() and eventWasCriticalHit:
        victim.setStatusEffect(attacker, Status.KNOCKED_DOWN, 3)
    else:
        victim.setStatusEffect(attacker, Status.STUNNED, 0.5)
    victim.applyImpulse(directionFromAngles(random.uniform(-20, 20) + horizontalAngleOfDirection(eventDirection), 0), eventDamage * 15 / victim.health * eventPlayer.knockbackRecieved, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)


def enterExitTeleport():
    @Name "enterExitTeleport"
    
    if eventPlayer.teleporting:
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.stopThrottleInDirection()
        eventPlayer.setGravity(0)
    else:
        eventPlayer.setStatusEffect(null, Status.ROOTED, 0.25)
        eventPlayer.setInvisibility(Invis.NONE)
        eventPlayer.setGravity(100)
        if eventPlayer.botTarget == null:
            if eventPlayer.telePos in botSpawnPoints:
                eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), waypoints[botSpawnPoints.index(eventPlayer.telePos)]), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            else:
                eventPlayer.startThrottleInDirection(directionFromAngles(random.randint(-90, 90) + horizontalAngleOfDirection(directionTowards(eventPlayer.getPosition(), sorted([player for player in getLivingPlayers(Team.1) if player.hasSpawned()], lambda i: distance(eventPlayer.getPosition(), i.getPosition()))[0].getPosition())), 0), eventPlayer.botThrottleSpeed, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        elif eventPlayer.botTarget != null:
            async(restoreDefaultFacingMovement, AsyncBehavior.NOOP)


def teleportBots():
    @Name "teleportBots"
    
    eventPlayer.teleporting = true
    updateBotSpawnPoints()
    enterExitTeleport()
    eventPlayer.successfullyTeleported = false
    waitUntil(not eventPlayer.initializing and eventPlayer.canTeleport, 99999)
    if eventPlayer.customTelePos == null:
        while eventPlayer.teleporting:
            botTeleportCenter()
            wait()
            eventPlayer.telePos = 0
            #Teleport with max distance constraint no view angle constraint
            while eventPlayer.telePos == 0 or any([distance(eventPlayer.telePos, player.getPosition()) < 15 for player in playerTargetList]) or all([distance(eventPlayer.telePos, player.getPosition()) > botMaxTeleportRange[1] for player in playerTargetList]):
                eventPlayer.filteredBotSpawnPointGrid = [player for player in botSpawnPoints if distance(player, eventPlayer.averagePlayersPos) < botMaxTeleportRange[1]]
                #Filter out spawn points on cooldown
                eventPlayer.filteredBotSpawnPointGrid = [player for player in eventPlayer.filteredBotSpawnPointGrid if botSpawnPointTimers[botSpawnPoints.index(player)] < 15]
                #Bots utilize saved spawn points
                if len(botSpawnPoints) > 0 and len(eventPlayer.filteredBotSpawnPointGrid) > 0:
                    eventPlayer.telePos = random.choice(eventPlayer.filteredBotSpawnPointGrid)
                    botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)] += 5
                    break
                else:
                    eventPlayer.telePos = nearestWalkablePosition(eventPlayer.averagePlayersPos + directionFromAngles(random.uniform(0, 360), random.uniform(-20, 10)) * random.uniform(0, botMaxTeleportRange[1]))
                wait(0.25)
            if all([distance(eventPlayer.telePos, player.getPosition()) > 10 for player in playerTargetList]) and all([not isInLoS(i.getEyePosition(), eventPlayer.telePos + vect(0, losHeightCheck, 0)) for i in [player for player in playerTargetList if player.isInViewAngle(eventPlayer.telePos, 55)]]):
                eventPlayer.teleport(eventPlayer.telePos)
                eventPlayer.teleporting = false
                #Teleport was unsuccessful due to line of sight and view angle
            elif eventPlayer.telePos in botSpawnPoints:
                del waypoints[botSpawnPoints.index(eventPlayer.telePos)]
                del botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)]
                botSpawnPoints.remove(eventPlayer.telePos)
    else:
        eventPlayer.teleport(eventPlayer.customTelePos)
        eventPlayer.customTelePos = null
        eventPlayer.teleporting = false
    wait()
    enterExitTeleport()


def botTeleportCenter():
    @Name "botTeleportCenter"
    
    #Standoff, Extraction, Biomorphing, Zombie Egg
    if objectiveTypes[0] in [1, 3, 6]:
        eventPlayer.averagePlayersPos = sorted(playerTargetList, lambda player: distance(player.getPosition(), objectivePositions[0]))[0].getPosition()
        #Boss
    elif objectiveTypes[0] == 2:
        eventPlayer.averagePlayersPos = sorted(playerTargetList, lambda player: distance(player.getPosition(), bosses[0].getPosition()))[0].getPosition()
        #Survivor Rescue
    elif objectiveTypes[0] == 4:
        if survivorToRescue.botFollowTarget == null:
            eventPlayer.averagePlayersPos = sorted(playerTargetList, lambda player: distance(player.getPosition(), survivorToRescue.getPosition()))[0].getPosition()
        else:
            eventPlayer.averagePlayersPos = survivorToRescue.botFollowTarget.getPosition()
        #Killzone
    elif objectiveTypes[0] == 5:
        #If players are in the killzone
        if len([player for player in playerTargetList if distance(player.getPosition(), objectiveChase1) < objectiveRad]) > 0:
            #Player closeset to the center of the killzone
            eventPlayer.averagePlayersPos = sorted(playerTargetList, lambda player: distance(player.getPosition(), objectiveChase1))[0].getPosition()
        else:
            #Average player positon
            locateAveragePlayerLocation()
        #Satellite Uplink
    elif objectiveTypes[0] == 7:
        #Checks if any players are currently repairing terminals
        if len(playersOnObjective) > 0:
            eventPlayer.averagePlayersPos = random.choice(playersOnObjective).getPosition()
        else:
            #Closest player to sattelite firing position
            eventPlayer.averagePlayersPos = sorted(playerTargetList, lambda player: distance(player.getPosition(), objectivePositions[0]))[0].getPosition()
        #Default
    else:
        locateAveragePlayerLocation()


def locateAveragePlayerLocation():
    @Name "locateAveragePlayerLocation"
    
    eventPlayer.averagePlayersPos = vect(0, 0, 0)
    if len(playersOnObjective) == 0 and any([player.getThrottle() != vect(0, 0, 0) for player in playerTargetList]):
        for eventPlayer.pPowerUpCount_bTeleCount in range(len([player for player in playerTargetList if player.getThrottle() != vect(0, 0, 0)])):
            eventPlayer.averagePlayersPos += (([player for player in playerTargetList if player.getThrottle() != vect(0, 0, 0)])[eventPlayer.pPowerUpCount_bTeleCount]).getPosition()
    else:
        for eventPlayer.pPowerUpCount_bTeleCount in range(len(playerTargetList)):
            eventPlayer.averagePlayersPos += playerTargetList[eventPlayer.pPowerUpCount_bTeleCount].getPosition()
    eventPlayer.averagePlayersPos /= eventPlayer.pPowerUpCount_bTeleCount


def successfulTeleportStatus():
    @Name "successfulTeleportStatus"
    
    #Max teleport distance adjustment
    if not eventPlayer.successfullyTeleported:
        eventPlayer.successfullyTeleported = true


def updateBotSpawnPoints():
    @Name "updateBotSpawnPoints"
    
    if eventPlayer.successfullyTeleported and eventPlayer.customTelePos == null and not eventPlayer.telePos in botSpawnPoints:
        botSpawnPoints.append(eventPlayer.telePos)
        waypoints.append(eventPlayer.waypoint)
        botSpawnPointTimers.append(0)
    elif not eventPlayer.successfullyTeleported and eventPlayer.telePos in botSpawnPoints:
        del waypoints[botSpawnPoints.index(eventPlayer.telePos)]
        del botSpawnPointTimers[botSpawnPoints.index(eventPlayer.telePos)]
        botSpawnPoints.remove(eventPlayer.telePos)


def botRespawnInitialization():
    @Name "botRespawnInitialization"
    
    eventPlayer.initializing = true
    if eventPlayer in bosses:
        eventPlayer.disableNameplatesFor(getAllPlayers())
        eventPlayer.health = 0
        eventPlayer.initialMaxHealth = eventPlayer.getMaxHealth()
    else:
        eventPlayer.enableNameplatesFor(getAllPlayers())
        eventPlayer.size = createWorkshopSettingFloat("Zombies", "Zombie Size", 1, 0, 20)
        eventPlayer.health = botHealthValues[botHeros.index(eventPlayer.getHero())]
        #Scale zombie voice lines with size
        eventPlayer.startModifyingVoicelinePitch(0.5 + (1 / (eventPlayer.size + 1)) + 0.25 * (sinDeg(getTotalTimeElapsed() * evalOnce(random.uniform(360, 720)))))
    eventPlayer.stopForcingButton(Button.CROUCH)
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
    eventPlayer.enableEnvironmentCollision()
    eventPlayer.wallCollisionEnabled = true
    eventPlayer.enablePlayerCollision()
    eventPlayer.playerCollisionEnabled = true
    eventPlayer.canWallPhase = true
    eventPlayer.attached = false
    eventPlayer.specialFacing = false
    eventPlayer.specialThrottling = false
    eventPlayer.canWallPhase = true
    eventPlayer.crowdControlled = false
    eventPlayer.botTempValue = null
    eventPlayer.botTempvalue2 = null
    eventPlayer.botSpecialTarget = null
    eventPlayer.targeting = false
    eventPlayer.bossHealth = -1
    #Chance for a minboss on high difficulties without standoff
    if objectiveValue != 1 and difficultySetting >= 3 and eventPlayer in bosses == false and len([player for player in miniBoss if entityExists(player)]) == 0:
        eventPlayer.randVal = random.randint(1, 199)
        if eventPlayer.randVal == 1:
            minibossMutation()
            wait(2)
    #Chance for a Standoff miniboss
    if objectiveValue == 1 and len(playersOnObjective) >= 1 and len(objectivePositions) != 1 and len([player for player in miniBoss if entityExists(player)]) == 0:
        minibossMutation()
    botStatManagement()
    if eventPlayer in miniBoss == true:
        goto lbl_0
    mutations()
    lbl_0:
    eventPlayer.startScalingSize(eventPlayer.size, false)
    botEntityManagement()
    waitUntil(eventPlayer.getHealth() >= eventPlayer.health, 5)
    eventPlayer.stopAllHealingOverTime()
    eventPlayer.setHealth(eventPlayer.health)
    eventPlayer.initializing = false


def botEntityManagement():
    @Name "botEntityManagement"
    
    if eventPlayer.botHero != eventPlayer.getHero() or eventPlayer in bosses:
        eventPlayer.botHero = eventPlayer.getHero()
        #Destroy all current hero effects and texts
        for eventPlayer.entityCount in range(len(eventPlayer.generalPlayerBotEntities)):
            destroyEffect(eventPlayer.generalPlayerBotEntities[eventPlayer.entityCount])
            wait()
        eventPlayer.explosionColor1 = Color.YELLOW
        eventPlayer.explosionColor2 = Color.ORANGE
        eventPlayer.generalPlayerBotEntities = []
        if eventPlayer.getHero() == Hero.ROADHOG:
            eventPlayer.setHealingReceived(30)
            if eventPlayer in bosses:
                #Gas Projectile 1
                createEffect([player for player in getAllPlayers() if eventPlayer.chase1 != null], Effect.BAD_AURA, Color.LIME_GREEN, eventPlayer.chase1, 0.4 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
                #Gas Projectile 2
                createEffect([player for player in getAllPlayers() if eventPlayer.chase1 != null], Effect.GOOD_AURA, Color.LIME_GREEN, eventPlayer.chase1, 0.2 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
                #Gas Clouds
                for eventPlayer.entityCount in range(3):
                    #Cloud Effect
                    createEffect([player for player in getAllPlayers() if eventPlayer.abilityArray1[evalOnce(eventPlayer.entityCount)] != null], Effect.CLOUD, Color.LIME_GREEN, eventPlayer.abilityArray1[evalOnce(eventPlayer.entityCount)], eventPlayer.abilityArray2[evalOnce(eventPlayer.entityCount)] + 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                    eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
                    #Cloud Effect ring
                    createEffect([player for player in getAllPlayers() if eventPlayer.abilityArray1[evalOnce(eventPlayer.entityCount)] != null], Effect.RING, Color.LIME_GREEN, eventPlayer.abilityArray1[evalOnce(eventPlayer.entityCount)], eventPlayer.abilityArray2[evalOnce(eventPlayer.entityCount)] + 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                    eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            else:
                #Roadhog toxic cloud
                createEffect([player for player in getAllPlayers() if eventPlayer.chase2 > 0], Effect.CLOUD, Color.LIME_GREEN, eventPlayer, 10 * eventPlayer.size + 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.MERCY:
            #Mercy tentacle
            createBeam([player for player in getAllPlayers() if eventPlayer.botTempValue != 0], Beam.BAD, eventPlayer.getEyePosition() + vect(0, 0.5, 0) * eventPlayer.size if eventPlayer.isInAir() else eventPlayer.getEyePosition(), eventPlayer.chase1, Color.LIME_GREEN, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            #Tentacle sound effect
            createEffect([player for player in getAllPlayers() if eventPlayer.botTempValue != 0], Effect.ENERGY_SOUND, Color.WHITE, eventPlayer.chase1, 400, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            #Tentacle end visual effect
            createEffect([player for player in getAllPlayers() if eventPlayer.botTempValue != 0], Effect.GOOD_AURA, Color.LIME_GREEN, eventPlayer.chase1, 0.1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            #Boss only
            if eventPlayer in bosses:
                #Ultimate lift aura
                createEffect([player for player in getAllPlayers() if eventPlayer.isUsingUltimate() and player.isInViewAngle(eventPlayer.getPosition(), 60)], Effect.GOOD_AURA, Color.YELLOW, eventPlayer.getPosition(), 12 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.WRECKING_BALL:
            #Ground strike location
            createEffect([player for player in getAllPlayers() if eventPlayer.botTempValue], Effect.RING, Color.TEAM_2, raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + vect(0, -100, 0), getAllPlayers(), getAllPlayers(), false).getHitPosition() if eventPlayer.botTempValue else evalOnce(vect(0, -100, 0)), 1 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            eventPlayer.setMaxAmmo(0, 40)
        elif eventPlayer.getHero() == Hero.REAPER:
            #Boss Only
            if eventPlayer in bosses:
                #Using Wraith Form
                createEffect([player for player in getAllPlayers() if eventPlayer.isUsingAbility1() and player.isInViewAngle(eventPlayer.getPosition(), 60)], Effect.BAD_AURA, Color.GRAY, eventPlayer.getPosition(), 12 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
                #Using Wraith Form
                createEffect([player for player in getAllPlayers() if eventPlayer.isUsingAbility1()], Effect.CLOUD, Color.WHITE, eventPlayer, 12 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.PHARAH:
            #Charging attack effect
            createEffect([player for player in getAllPlayers() if eventPlayer.chase1 > 0], Effect.GOOD_AURA, Color.BLUE, eventPlayer, eventPlayer.chase1 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.SIGMA:
            createEffect([player for player in getAllPlayers() if eventPlayer.isUsingAbility1()], Effect.CLOUD, Color.TURQUOISE, eventPlayer.botTarget.getEyePosition(), 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.ILLARI:
            #Charging attack effect
            createEffect([player for player in getAllPlayers() if eventPlayer.chase1 > 0], Effect.GOOD_AURA, Color.ORANGE, eventPlayer, eventPlayer.chase1 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.WINSTON:
            #Charging attack effect
            createEffect([player for player in getAllPlayers() if eventPlayer.isAlive() and not eventPlayer in bosses and eventPlayer.botTempValue <= 1], Effect.GOOD_AURA, Color.RED, eventPlayer, eventPlayer.chase1 * eventPlayer.size, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
            #Boss only
            if eventPlayer in bosses:
                #Darkness visual
                createEffect([player for player in getAllPlayers() if gameSmolderEvent], Effect.BAD_AURA, Color.BLACK, localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 30, 200, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
                #Darkness visual
                createEffect([player for player in getAllPlayers() if gameSmolderEvent], Effect.BAD_AURA, Color.RED, localPlayer.getEyePosition() + (localPlayer.getFacingDirection() * (33 + evalOnce(random.uniform(-0.5, 0.5)))), 200, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
                eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())
        elif eventPlayer.getHero() == Hero.DOOMFIST:
            #Meteor strike/Seismic Slam location
            createEffect([player for player in getAllPlayers() if eventPlayer.isUsingUltimate() or eventPlayer.isUsingAbility1()], Effect.RING, Color.ORANGE, raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + vect(0, -100, 0), getAllPlayers(), getAllPlayers(), false).getHitPosition() if eventPlayer.isUsingUltimate() or eventPlayer.isUsingAbility1() else evalOnce(vect(0, -100, 0)), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())


def botStatManagement():
    @Name "botStatManagement"
    
    eventPlayer.biteDamage = biteDamages[botHeros.index(eventPlayer.getHero())]
    #Re-calibrate bite damage
    eventPlayer.biteDamage *= 100 / damageDealt[botHeros.index(eventPlayer.getHero())]
    eventPlayer.biteDuration = biteDurations[botHeros.index(eventPlayer.getHero())]
    #Range from 0 to 1 in terms of throttle
    eventPlayer.botThrottleSpeed = throttleSpeeds[botHeros.index(eventPlayer.getHero())]
    eventPlayer.damageDealt = damageDealt[botHeros.index(eventPlayer.getHero())] / 100
    eventPlayer.setDamageDealt(eventPlayer.damageDealt * 100)
    eventPlayer.setDamageReceived(100)
    eventPlayer.movementSpeed = 1
    eventPlayer.setMoveSpeed(eventPlayer.movementSpeed * 100 + ((len([player for player in getDeadPlayers(Team.1) if player.deathTimer <= 0])) * 3))
    eventPlayer.setJumpVerticalSpeed(100)
    eventPlayer.setHealingReceived(100)
    eventPlayer.setProjectileSpeed(100)
    eventPlayer.setProjectileGravity(100)
    eventPlayer.knockbackRecieved = 1
    eventPlayer.setKnockbackReceived(100)
    if eventPlayer.getHero() == Hero.REINHARDT:
        eventPlayer.knockbackRecieved = 0.7
        eventPlayer.setKnockbackReceived(100 * eventPlayer.knockbackRecieved)
    elif eventPlayer.getHero() == Hero.MERCY:
        eventPlayer.setProjectileSpeed(20)
    elif eventPlayer.getHero() == Hero.ILLARI:
        eventPlayer.setKnockbackDealt(25)
    elif eventPlayer.getHero() == Hero.WINSTON:
        eventPlayer.size *= 0.7
        eventPlayer.chase1 = 2
        eventPlayer.startScalingBarriers(eventPlayer.size)
    elif eventPlayer.getHero() == Hero.ANA or eventPlayer.getHero() == Hero.KIRIKO:
        eventPlayer.setProjectileGravity(500)
    elif eventPlayer.getHero() == Hero.SIGMA:
        eventPlayer.setProjectileSpeed(100 * eventPlayer.size * 0.5)
        eventPlayer.setPrimaryFireEnabled(true)
    elif eventPlayer.getHero() == Hero.MAUGA:
        eventPlayer.setKnockbackDealt(120)
    elif eventPlayer.getHero() == Hero.HAZARD:
        chaseAtRate(eventPlayer.abilityArray1, 0, 1)


def enableMutations():
    @Name "enableMutations"
    
    availableMutations[0] = 1 if createWorkshopSettingBool("Mutations", "Speed", true) else -1
    availableMutations[1] = 2 if createWorkshopSettingBool("Mutations", "Size Growth", true, 1) else -1
    availableMutations[2] = 3 if createWorkshopSettingBool("Mutations", "Size Reduction", true, 2) else -1
    availableMutations[3] = 4 if createWorkshopSettingBool("Mutations", "Radioactive", true, 3) else -1
    availableMutations[4] = 5 if createWorkshopSettingBool("Mutations", "Heavy", true, 4) else -1
    availableMutations.remove(-1)


def mutations():
    @Name "mutations"
    
    #Zombies have a chance to mutate. Bosses cannot mutate
    if len(availableMutations) > 0 and not eventPlayer in bosses and (random.uniform(0, 100) < (100 if challengeSetting == 3 or challengeSetting == 5 else createWorkshopSettingFloat("Mutations", "Chance to mutate percentage", 25, 0, 100))):
        eventPlayer.mutationValue = random.choice(availableMutations)
        #Speed
        if eventPlayer.mutationValue == 1:
            eventPlayer.movementSpeed *= 1.5
            eventPlayer.setMoveSpeed(eventPlayer.movementSpeed * 100)
            eventPlayer.defaultOutlineColor = Color.PURPLE
            eventPlayer.startForcingName("SPEED")
            #Size Growth
        elif eventPlayer.mutationValue == 2:
            eventPlayer.size *= 1.5
            eventPlayer.health *= eventPlayer.size
            eventPlayer.defaultOutlineColor = Color.VIOLET
            eventPlayer.startForcingName("XL")
            #Size Reduction
        elif eventPlayer.mutationValue == 3:
            eventPlayer.size *= 0.6
            eventPlayer.health *= eventPlayer.size
            eventPlayer.defaultOutlineColor = Color.ROSE
            eventPlayer.startForcingName("XS")
            #Radioactive
        elif eventPlayer.mutationValue == 4:
            eventPlayer.biteDuration *= 1.5
            eventPlayer.defaultOutlineColor = Color.LIME_GREEN
            eventPlayer.startForcingName("Radioactive")
            #Heavy
        elif eventPlayer.mutationValue == 5:
            eventPlayer.knockbackRecieved *= 0.5
            eventPlayer.setKnockbackReceived(100 * eventPlayer.knockbackRecieved)
            #Scale move speed
            eventPlayer.movementSpeed *= eventPlayer.knockbackRecieved
            eventPlayer.setMoveSpeed(100 * eventPlayer.movementSpeed)
            #Scale health
            eventPlayer.health /= eventPlayer.knockbackRecieved
            eventPlayer.defaultOutlineColor = Color.BLACK
            eventPlayer.startForcingName("Heavy")
        #Mutation outline for players
        eventPlayer.startForcingOutlineFor(getAllPlayers(), true, eventPlayer.defaultOutlineColor)
    else:
        eventPlayer.mutationValue = 0
        eventPlayer.defaultOutlineColor = null
        #Default ouline for players
        eventPlayer.stopForcingOutlineFor(getAllPlayers())
        eventPlayer.stopForcingName()


def minibossMutation():
    @Name "minibossMutation"
    
    miniBoss.append(eventPlayer)
    eventPlayer.startForcingHero(random.choice([Hero.REINHARDT, Hero.WRECKING_BALL, Hero.JUNKER_QUEEN, Hero.DOOMFIST, Hero.KIRIKO, Hero.MAUGA, Hero.HAZARD]))
    if zombieSetting == 6:
        eventPlayer.startForcingHero(random.choice([Hero.REINHARDT, Hero.WRECKING_BALL]))
    elif zombieSetting == 7:
        eventPlayer.startForcingHero(Hero.ROADHOG)
    eventPlayer.health = 2500
    eventPlayer.size *= 1.55
    eventPlayer.startForcingOutlineFor(getAllPlayers(), true, Color.ORANGE)
    eventPlayer.startForcingName("Contestor")
    #Skull Icon
    createIcon([player for player in getAllPlayers() if eventPlayer.initializing == false and eventPlayer in bosses == false], eventPlayer.getEyePosition() + Vector.UP, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.ORANGE)
    eventPlayer.generalPlayerBotEntities.append(getLastCreatedEntity())


rule "MINIBOSS MESSAGE":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer in miniBoss == true
    @Condition objectiveTypes[0] != 1
    @Condition gameStatus == true
    @Condition eventPlayer.initializing != false
    
    wait(0.25, Wait.ABORT_WHEN_FALSE)
    bigMessage(getAllPlayers(), "A Contestor approaches")


def abilityPlacement():
    @Name "abilityPlacement"
    
    wait(0.5)
    if eventPlayer.crowdControlled == true:
        return
    eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 1.6)
    waitUntil(eventPlayer.getAbilityCooldown(Button.ABILITY_2) == true, 1)
    if eventPlayer.getAbilityCooldown(Button.ABILITY_2) == true:
        wait(1)
        eventPlayer.forceButtonPress(Button.INTERACT)
    else:
        eventPlayer.cancelPrimaryAction()


def abilityThrowdown():
    @Name "abilityThrowdown"
    
    if eventPlayer.hasStatus(Status.HACKED):
        return
    eventPlayer.disallowButton(Button.MELEE)
    eventPlayer.startFacing(Vector.DOWN, 999)
    wait(0.3)
    eventPlayer.forceButtonPress(Button.ABILITY_2)
    eventPlayer.allowButton(Button.MELEE)
    restoreDefaultFacingMovement()
    if eventPlayer.getHero() == Hero.HAZARD:
        wait(0.25)
        if eventPlayer.crowdControlled or eventPlayer.hasStatus(Status.HACKED):
            return
        ([player for player in getPlayersInRadius(eventPlayer, 2, Team.2, LosCheck.SURFACES) if player != eventPlayer]).applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(Vector.UP, distance(eventPlayer.botTarget, eventPlayer) * (2 / eventPlayer.size), Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.abilityArray1 += 2


def entityFloat():
    @Name "entityFloat"
    
    #Entities that will be floated
    eventPlayer.botSpecialPotentialTargets = [player for player in getLivingPlayers(Team.ALL) if player != eventPlayer and distance(eventPlayer.getPosition(), player.getPosition()) < 12 * eventPlayer.size and isInLoS(player.getPosition() + vect(0, losHeightCheck, 0), eventPlayer.getPosition() + vect(0, losHeightCheck, 0), BarrierLos.BLOCKED_BY_ENEMY_BARRIERS)]

