#!include "settings.opy"

#Global variables

globalvar newLine 0
globalvar zombiesflyIOnandOff 26
globalvar Credits_Pug 27
globalvar Credits_Hannon 28
globalvar Credits_SashayAsh 29
globalvar team_shields 30
globalvar team_armor 31
globalvar heroes_shop_data 32

#Player variables

playervar money 0
playervar healing_tracker 1
playervar health_stat 10
playervar damage_stat 11
playervar healing_stat 12
playervar zombiesfly 26

#Activated extensions
#!extension explosionSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots

#!include "debug.opy"
#!include "player joined.opy"
#!include "buy hero.opy"

rule "[Mode State]":
    newLine = 0
    B = 0
    C = 0
    P = 0
    Q = []
    Q.append(Hero.DVA)
    Q.append(Hero.ORISA)
    Q.append(Hero.REINHARDT)
    Q.append(Hero.ROADHOG)
    Q.append(Hero.SIGMA)
    Q.append(Hero.WINSTON)
    Q.append(Hero.WRECKING_BALL)
    Q.append(Hero.ZARYA)
    T = []
    Y = []
    hudHeader(getPlayers(Team.1), l"Round {0}".format(newLine), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudHeader(getPlayers(Team.1), l"{0} {1}".format(B, l"Enemies"), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    O = false
    M[0] = vect(500, 25, 500)
    M[1] = vect(500, 25, 500)
    M[2] = vect(500, 25, 500)
    M[3] = vect(500, 25, 500)
    M[4] = vect(500, 25, 500)
    M[5] = vect(500, 25, 500)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.VIOLET, M[0], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.YELLOW, M[1], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.GREEN, M[2], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.AQUA, M[3], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.ROSE, M[4], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getPlayers(Team.1), Effect.ORB, Color.ORANGE, M[5], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    hudHeader([player for player in getPlayers(Team.1) if player.S[1] == 1], l"Points", HudPosition.TOP, 1, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader([player for player in getPlayers(Team.1) if player.S[2] == 1], l"Speed", HudPosition.TOP, 1, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader([player for player in getPlayers(Team.1) if player.S[4] == 1], "Honey, I Shrunk The Team!", HudPosition.TOP, 1, Color.ROSE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader([player for player in getPlayers(Team.1) if player.S[0] == 1], "Total Mayhem", HudPosition.TOP, 1, Color.VIOLET, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader([player for player in getPlayers(Team.1) if player.S[5] == 1], l"Challenge Accepted", HudPosition.TOP, 1, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader([player for player in getPlayers(Team.1) if player.S[3] == 1], l"Freezing", HudPosition.TOP, 1, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    G = vect(500, 0, 500)
    zombiesflyIOnandOff = true
    M[6] = vect(500, 25, 500)
    createEffect(getPlayers(Team.1), Effect.GOOD_AURA, Color.BLUE, M[6], 0.7, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    hudHeader([player for player in getPlayers(Team.1) if player.S[6] == 1], "Time Distortion", HudPosition.TOP, 1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    Credits_Pug = createWorkshopSettingEnum("[Credits]", "Original Mode by", 0, ["Pug"], 1)
    Credits_Hannon = createWorkshopSettingEnum("[Credits]", "Remastered by", 0, ["Hannon#21462 - [81FKK]"], 1)
    Credits_SashayAsh = createWorkshopSettingEnum("[Credits]", "Updated by", 0, ["SashayAsh"], 1)
    team_shields = 0
    team_armor = 0


rule "[Start Game]":
    @Condition C == 4
    @Condition D == 1
    
    W = []
    V = []
    U = []


rule "[Unlimited Match Time]":
    @Condition getMatchTime() < 10
    @Condition O == false
    
    setMatchTime(3599)


rule "[Player HUD]":
    @Condition newLine == 1
    
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(0, Team.1).getCurrentHero()), getPlayersInSlot(0, Team.1)), getPlayersInSlot(0, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(1, Team.1).getCurrentHero()), getPlayersInSlot(1, Team.1)), getPlayersInSlot(1, Team.1).money), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(2, Team.1).getCurrentHero()), getPlayersInSlot(2, Team.1)), getPlayersInSlot(2, Team.1).money), HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(3, Team.1).getCurrentHero()), getPlayersInSlot(3, Team.1)), getPlayersInSlot(3, Team.1).money), HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    S[0] = vect(500, 0, 500)
    S[1] = vect(500, 0, 500)
    S[2] = vect(500, 0, 500)
    S[3] = vect(500, 0, 500)
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(4, Team.1).getCurrentHero()), getPlayersInSlot(4, Team.1)), getPlayersInSlot(4, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(5, Team.1).getCurrentHero()), getPlayersInSlot(5, Team.1)), getPlayersInSlot(5, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    S[4] = vect(500, 0, 500)
    S[5] = vect(500, 0, 500)
    S[6] = vect(500, 0, 500)


rule "[Round Start - Global B]":
    @Condition B <= 0
    @Condition O == false
    
    newLine += 1
    Z = 1
    destroyIcon(J[21])
    bigMessage(getAllPlayers(), l"Round {0}".format(newLine))
    P = 0
    getDeadPlayers(Team.1).teleport(nearestWalkablePosition(random.choice(getLivingPlayers(Team.1)) + vect(random.randint(-5, 5), 0, random.randint(-5, 5))))
    getDeadPlayers(Team.1).resurrect()
    S[0] = vect(500, 0, 500)
    S[1] = vect(500, 0, 500)
    S[2] = vect(500, 0, 500)
    S[3] = vect(500, 0, 500)
    wait(0.25)
    heal(getPlayers(Team.1), null, 99999)
    wait(5)
    bigMessage(getAllPlayers(), "Starting Round!")
    getPlayersInSlot(0, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(1, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(2, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(3, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(4, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(5, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(6, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(7, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(8, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(9, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(10, Team.2).respawn()
    wait(0.25)
    getPlayersInSlot(11, Team.2).respawn()
    wait(0.25)
    getPlayers(Team.2).setMoveSpeed(35 + 5 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    getPlayers(Team.2).setMaxHealth(80 + 15 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    getPlayers(Team.2).setDamageDealt(20 + 8 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    wait(1)
    heal(getPlayers(Team.2), null, 9999)


rule "[Round Start - Global Z]":
    @Condition Z == 1
    @Condition O == false
    
    B = 10 + newLine * 2
    wait(1)
    Z = 0


rule "[Enraged Zombies - 10]":
    @Event eachPlayer
    @Team 2
    @Slot 0
    @Condition newLine > 9
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 20
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "[Enraged Zombies - 10]":
    @Event eachPlayer
    @Team 2
    @Slot 0
    @Condition newLine > 9
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 20
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "[Mark Last Zombie]":
    @Event eachPlayer
    @Team 2
    @Condition B < 2
    @Condition getNumberOfLivingPlayers(Team.2) == 1
    @Condition eventPlayer.isAlive() == true
    
    createIcon(getPlayers(Team.1), eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
    J[21] = getLastCreatedEntity()


rule "[Match End]":
    @Condition all([player.isDead() for player in getPlayers(Team.1)]) == true
    @Condition getPlayers(Team.1).hasSpawned() == true
    
    O = true
    destroyAllEffects()
    destroyAllInWorldTexts()
    wait(3)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Survived", newLine, l"Rounds"))
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Total", l"{0}:".format(l"Score"), R))
    wait(4)
    declareTeamVictory(Team.2)


rule "[World Effects]":
    @Condition newLine == 1

    createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ORANGE, vect(74.955, 13, -52.677), 1, EffectReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.BLUE, vect(75.589, 13, -50.533), 1, EffectReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ROSE, vect(-18.833, 7.3, -85.965), 1, EffectReeval.VISIBILITY)
    createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(139, 12, -18.3), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(114, 12, -11.6), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(97.277, 12.025, -32.134), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
    createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
    createInWorldText(getPlayers(Team.1), "♥ Credits ♥", vect(131.044, 13, 3.854), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
    createInWorldText(getPlayers(Team.1), "Special thanks to all the community for the feedback and testing!", vect(131.044, 12.5, 3.854), 0.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
    createInWorldText(getPlayers(Team.1), "OG by: Pug | Remade by: Hannon#21462 | Updated by: SashayAsh", vect(131.044, 12.75, 3.854), 0.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
    createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ROSE, vect(131, 12.6, 3.8), 5, EffectReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.RING, Color.AQUA, vect(130.268, 12.998, -57.335), 1.1, EffectReeval.VISIBILITY)
    createEffect(getPlayers(Team.1), Effect.CLOUD, Color.AQUA, vect(-4.685, 0.3, -8.427), 3, EffectReeval.VISIBILITY)


rule "[Bot Stats]":
    @Condition getNumberOfPlayers(Team.2) < 12
    @Condition getPlayers(Team.1).hasSpawned() == true
    @Condition newLine == 1
    
    wait(0.5)
    createDummy(Hero.TORBJORN, Team.2, 0, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 1, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 2, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 3, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 4, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 5, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 6, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 7, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 8, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 9, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 10, random.choice(Y))
    createDummy(Hero.TORBJORN, Team.2, 11, random.choice(Y))
    getPlayers(Team.2).setMoveSpeed(35 + 5 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    getPlayers(Team.2).setMaxHealth(80 + 15 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    getPlayers(Team.2).setDamageDealt(20 + 8 * getNumberOfPlayers(Team.1) + ((newLine / (3.3 - getNumberOfPlayers(Team.1) / 8)) * (newLine / (3.3 - getNumberOfPlayers(Team.1) / 8))))
    getPlayersOnHero(Hero.TORBJORN, Team.2).startForcingName("Zombie")


rule "[Disable Bot Respawn]":
    @Event playerJoined
    @Team 2
    
    eventPlayer.disableRespawn()


rule "[Spawn Bots]":
    @Condition getNumberOfLivingPlayers(Team.2) < B
    @Condition B < 13
    @Condition newLine > 1
    
    wait(2.5, Wait.ABORT_WHEN_FALSE)
    random.choice(getDeadPlayers(Team.2)).respawn()
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "[Drop] Total Mayhem":
    @Event playerDied
    @Team 2
    @Slot 0
    
    eventPlayer.healing_tracker = random.randint(1, 35)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[0] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Drop] Points Orb":
    @Event playerDied
    @Team 2
    @Slot 1
    
    eventPlayer.healing_tracker = random.randint(1, 20)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[1] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Drop] Speed Orb":
    @Event playerDied
    @Team 2
    @Slot 2
    @Condition newLine < 40
    
    eventPlayer.healing_tracker = random.randint(1, 25)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[2] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    wait(0.25)
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Drop] Freeze Orb":
    @Event playerDied
    @Team 2
    @Slot 3
    
    eventPlayer.healing_tracker = random.randint(1, 25)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[3] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Drop] Honey, I Shrunk The Team Orb":
    @Event playerDied
    @Team 2
    @Slot 4
    
    eventPlayer.healing_tracker = random.randint(1, 30)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[4] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Drop] Challenge Orb":
    @Event playerDied
    @Team 2
    @Slot 5
    
    eventPlayer.healing_tracker = random.randint(1, 30)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[5] = nearestWalkablePosition(eventPlayer) + vect(0, 0.5, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    wait(0.25)
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:


rule "[Bots Move Toward Players]":
    @Event eachPlayer
    @Team 2
    @Condition O == false
    
    eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)


rule "[Bots Face Nearest Players]":
    @Event eachPlayer
    @Team 2
    @Condition O == false
    
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), ((sorted([player for player in getLivingPlayers(Team.1) if player.T == 0], lambda i: distance(eventPlayer, i)))[0]).getEyePosition()), 400)
    eventPlayer.setFacing(directionTowards(eventPlayer.getEyePosition(), (getClosestPlayer(((sorted([player for player in getLivingPlayers(Team.1) if player.T == 0], lambda i: distance(eventPlayer, i)))[0]).getEyePosition(), Team.1)).getEyePosition()), Relativity.TO_WORLD)


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


rule "Bots Attack Near Player":
    @Event eachPlayer
    @Team 2
    @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == true
    @Condition Hero.TORBJORN == true
    
    eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
    eventPlayer.startForcingButton(Button.PRIMARY_FIRE)


rule "[Bots Don't Attack Near Player]":
    @Event eachPlayer
    @Team 2
    @Condition getPlayersInRadius(eventPlayer, 4, Team.1) == false
    
    eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)


rule "[Bots Use Ultimate At 100%]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getUltCharge() == 100
    
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "[Bots Under Player Impulse]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getVerticalFacingAngle() < -70
    @Condition O == false
    @Condition getClosestPlayer(eventPlayer, Team.1).isUsingUltimate() == false
    
    eventPlayer.applyImpulse(worldVector(vect(random.randint(-10, 10), 0, random.randint(-10, 10)), eventPlayer, Transform.ROTATION), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    eventPlayer.applyImpulse(Vector.UP, 18, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(1)
    eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "[Bot Action Choice]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, getClosestPlayer(eventPlayer, Team.1)) <= 20
    
    eventPlayer.Z = random.randint(1, 3)
    wait(8, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "[Bots Safety A]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(73.557, -8, -84.315)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 23, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety B]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(95.242, -8, -89.781)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety C]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(117.06, -2.181, -85.971)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety D]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(55.486, 1.618, -37.515)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety E]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(46.004, -7.45, -14.713)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety F]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(31.594, -7.571, 3.942)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety G]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(38.556, -7.571, -2.741)) < 15
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety H]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(38.556, -30.571, -2.741)) < 30
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety I]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(-22.025, -0.631, -59.645)) < 12
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Bots Safety J]":
    @Event eachPlayer
    @Team 2
    @Condition distance(eventPlayer, vect(-6.388, -4.792, -109.846)) < 16
    
    eventPlayer.applyImpulse(Vector.UP, 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)


rule "[Zombie Points - Elimination]":
    @Event playerEarnedElimination
    @Team 1
    @Condition eventWasCriticalHit == false
    @Condition victim.getCurrentHero() == Hero.TORBJORN
    
    eventPlayer.money += 200 * eventPlayer.H
    smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(200 * eventPlayer.H, l"Points")))
    eventPlayer.startHealingOverTime(eventPlayer, 5, 30)
    R += 200 * eventPlayer.H


rule "[Zombie Points - Critical Hit]":
    @Event playerEarnedElimination
    @Team 1
    @Condition eventWasCriticalHit == true
    @Condition victim.getCurrentHero() == Hero.TORBJORN
    
    eventPlayer.money += 275 * eventPlayer.H
    smallMessage(attacker, l"{0} + {1}".format(l"", l"{0} {1}".format(275 * eventPlayer.H, l"Points")))
    eventPlayer.startHealingOverTime(eventPlayer, 5, 30)
    R += 275 * eventPlayer.H


rule "[Anti-Spawn Check A]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isInSpawnRoom() == true
    
    eventPlayer.teleport(random.choice(Y))


rule "[Anti-Spawn Check B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3
    
    eventPlayer.teleport(vect(79.382, 13.147, -110.093))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Anti-Spawn Check C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2
    
    eventPlayer.teleport(vect(86.903, 14.219, -101.238))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Anti-Spawn Check D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(97.65, 11.233, -30.593)) < 3
    
    eventPlayer.teleport(vect(96.475, 12.392, -35.419))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Anti-Spawn Check E]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(103.937, 11.178, -30.358)) < 2
    
    eventPlayer.teleport(vect(107.719, 11.178, -33.024))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Anti-Spawn Check F]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(113.037, 12.696, -10.145)) < 3
    
    eventPlayer.teleport(vect(113.894, 11.178, -15.333))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Anti-Spawn Check G]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(140.251, 12.481, -17.63)) < 3
    
    eventPlayer.teleport(vect(133.957, 12.363, -18.225))
    wait(2, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


rule "[Spawn Points Array A]":
    @Condition distance(vect(-6.965, 2.94, -7.146), getClosestPlayer(vect(-6.965, 2.94, -7.146), Team.1)) <= 48
    
    Y.append(vect(14.282, 26.122, -19.096))
    Y.append(vect(-25.084, 25.057, -28.765))
    Y.append(vect(-2.267, 19.938, -41.17))
    Y.append(vect(5.665, 17.621, 2.067))
    Y.append(vect(16.374, 13.098, -40.81))


rule "[Spawn Points Array A-]":
    @Condition distance(vect(-6.965, 2.94, -7.146), getClosestPlayer(vect(-6.965, 2.294, -7.146), Team.1)) > 48
    
    Y.remove(vect(14.282, 26.122, -19.096))
    Y.remove(vect(-25.084, 25.057, -28.765))
    Y.remove(vect(-2.267, 19.938, -41.17))
    Y.remove(vect(5.665, 17.621, 2.067))
    Y.remove(vect(16.374, 13.098, -40.81))


rule "[Spawn Points Array B]":
    @Condition distance(vect(13.044, 9.697, -73.344), getClosestPlayer(vect(13.044, 9.797, -73.344), Team.1)) <= 35
    
    Y.append(vect(15.598, 30.551, -60.258))
    Y.append(vect(-6.03, 18.558, -47.35))
    Y.append(vect(11.556, 20.229, -87.682))
    Y.append(vect(-5.797, 12.818, -90.005))
    Y.append(vect(9.321, 17.186, -40.356))
    Y.append(vect(29.662, 26.681, -74.951))
    Y.append(vect(38.069, 13.312, -50.538))
    Y.append(vect(19.593, 10.464, -98.064))


rule "[Spawn Points Array B-]":
    @Condition distance(vect(13.044, 9.697, -73.344), getClosestPlayer(vect(13.044, 9.697, -73.344), Team.1)) > 35
    
    Y.remove(vect(15.598, 30.551, -60.258))
    Y.remove(vect(-6.03, 18.558, -47.35))
    Y.remove(vect(11.556, 20.229, -87.682))
    Y.remove(vect(-5.797, 12.818, -90.005))
    Y.remove(vect(9.321, 17.186, -40.356))
    Y.remove(vect(29.662, 26.681, -74.951))
    Y.remove(vect(38.069, 13.312, -50.538))
    Y.remove(vect(19.593, 10.464, -98.064))


rule "[Spawn Points Array C]":
    @Condition distance(vect(-22.86, 8.08, -88.854), getClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) <= 15
    @Condition D == 1
    
    Y.append(vect(74.194, 17.928, -49.807))


rule "[Spawn Points Array C-]":
    @Condition distance(vect(-22.86, 8.08, -88.854), getClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) > 15
    @Condition D == 1
    
    Y.remove(vect(74.194, 17.928, -49.807))


rule "[Spawn Points Array D]":
    @Condition distance(vect(59.416, 19.498, -77.513), getClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) <= 30
    
    Y.append(vect(60.556, 9.729, -92.999))
    Y.append(vect(57.692, 14.745, -78.916))
    Y.append(vect(37.146, 27.607, -58.074))
    Y.append(vect(94.023, 34.402, -65.749))
    Y.append(vect(29.377, 19.108, -81.452))
    Y.append(vect(36.546, 14.432, -106.335))
    Y.append(vect(60.876, 8.672, -74.696))


rule "[Spawn Points Array D-]":
    @Condition distance(vect(59.416, 19.498, -77.513), getClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) > 30
    
    Y.remove(vect(60.556, 9.729, -92.999))
    Y.remove(vect(57.692, 14.745, -78.916))
    Y.remove(vect(37.146, 27.607, -58.074))
    Y.remove(vect(94.023, 34.402, -65.749))
    Y.remove(vect(29.377, 19.108, -81.452))
    Y.remove(vect(36.546, 14.432, -106.335))
    Y.remove(vect(60.876, 8.672, -74.696))


rule "[Spawn Points Array E]":
    @Condition distance(vect(75.315, 22.594, -101.637), getClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) <= 50
    
    Y.append(vect(94.023, 34.402, -65.749))
    Y.append(vect(74.277, 14.12, -110.609))
    Y.append(vect(90.938, 30.988, -109.069))
    Y.append(vect(57.687, 21.96, -76.518))
    Y.append(vect(63.86, 16.823, -100.725))


rule "[Spawn Points Array E-]":
    @Condition distance(vect(75.315, 22.594, -101.637), getClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) > 50
    
    Y.remove(vect(94.023, 34.402, -65.749))
    Y.remove(vect(74.277, 14.12, -110.609))
    Y.remove(vect(90.938, 30.988, -109.069))
    Y.remove(vect(57.687, 21.96, -76.518))
    Y.remove(vect(63.86, 16.823, -100.725))


rule "[Spawn Points Array F]":
    @Condition distance(vect(108.196, 14.309, -22.096), getClosestPlayer(vect(108.196, 14.299, -22.094), Team.1)) <= 45
    
    Y.append(vect(74.194, 17.928, -49.807))
    Y.append(vect(124.358, 23.829, -26.451))
    Y.append(vect(97.865, 22.892, -42.244))
    Y.append(vect(128.632, 23.521, -7.378))
    Y.append(vect(122.998, 16.026, -66.952))
    Y.append(vect(142.909, 17.319, -45))


rule "[Spawn Points Array F-]":
    @Condition distance(vect(108.195, 14.3, -22.094), getClosestPlayer(vect(108.196, 14.309, -22.096), Team.1)) > 45
    
    Y.remove(vect(74.194, 17.928, -49.807))
    Y.remove(vect(124.358, 23.829, -26.451))
    Y.remove(vect(97.865, 22.892, -42.244))
    Y.remove(vect(128.632, 23.521, -7.378))
    Y.remove(vect(122.998, 16.026, -66.952))
    Y.remove(vect(142.909, 17.319, -45))


rule "[Spawn Points Array G]":
    @Condition distance(vect(140.011, 12.178, -61.257), getClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) <= 15
    
    Y.append(vect(74.194, 17, -49.807))
    Y.append(vect(124.358, 23, -26.451))
    Y.append(vect(97.865, 22, -42.244))
    Y.append(vect(128.632, 23, -7.378))
    Y.append(vect(122.998, 16, -66.952))
    Y.append(vect(142.909, 17, -45))


rule "[Spawn Points Array G-]":
    @Condition distance(vect(140.011, 12.178, -61.257), getClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) > 15
    
    Y.remove(vect(74.194, 17, -49.807))
    Y.remove(vect(124.358, 23, -26.451))
    Y.remove(vect(97.865, 22, -42.244))
    Y.remove(vect(128.632, 23, -7.378))
    Y.remove(vect(122.998, 16, -66.952))
    Y.remove(vect(142.909, 17, -45))


rule "[Blocked Area Arrays]":
    @Condition newLine == 1
    
    V = []
    V.append(vect(19, 7, -50.013))
    V.append(vect(40.631, 8.265, -77.59))
    V.append(vect(51.561, 8.095, -58.373))
    V.append(vect(23.088, 12.063, -89.42))
    V.append(vect(78.65, 14.171, -53.779))
    V.append(vect(103.219, 15.554, -60.019))
    V.append(vect(91.888, 22.491, -53.112))
    V.append(vect(87.651, 15, -28.387))
    V.append(vect(107.743, 12.171, -31.426))


rule "[Blocked Area Setup Effects]":
    @Condition newLine == 1
    
    W = []
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(12.505, 5.485, -40.846), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(22.609, 6.314, -45.045), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(20.011, 6.314, -40.406), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(35.156, 7.335, -73.588), 3.25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(38.782, 6.526, -58.722), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(42.152, 6.553, -49.632), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(23.027, 11.884, -89.054), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(78.467, 14.036, -56.311), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(100.524, 14.045, -66.87), 2.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(89.352, 22.145, -62.564), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(107.37, 12.166, -33.617), 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())
    createEffect(getPlayers(Team.1), Effect.BAD_AURA, Color.WHITE, vect(87.614, 14.166, -29.335), 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    W.append(getLastCreatedEntity())


rule "[Locked Area A]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[0]) < 10
    @Condition C == 0
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[0], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[1]) < 10
    @Condition C == 1
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[2]) < 15
    @Condition C == 1
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[3]) < 5
    @Condition C == 1
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[4], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area E]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[4]) < 10
    @Condition C == 2
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area F]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[5]) < 10
    @Condition C == 2
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area G]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[6]) < 10
    @Condition C == 2
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[5], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area H]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[7]) < 4
    @Condition D == 0
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[7], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Locked Area I]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, V[8]) < 5
    @Condition D == 0
    @Condition O == false
    
    eventPlayer.applyImpulse(directionTowards(V[8], eventPlayer), 25, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.25)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area A]":
    @Condition newLine == 1
    
    U = []
    U.append(vect(13.044, 9.697, -73.344))
    U.append(vect(52.662, 9.768, -31.962))
    U.append(vect(59.416, 19.498, -77.513))
    U.append(vect(95.991, 12.171, -38.315))
    U.append(vect(104.593, 16, -22.372))
    U.append(vect(89.614, 18, -19.296))


rule "[Teleport Area B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[0]) < 35
    @Condition C == 0
    
    eventPlayer.teleport(vect(13.466, 4.35, -34.792))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[1]) < 15
    @Condition C == 0
    
    eventPlayer.teleport(vect(27.294, 6.507, -25.489))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[2]) < 30
    @Condition C == 1
    
    eventPlayer.teleport(vect(25.171, 6.554, -64.938))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area E]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[3]) < 25
    @Condition C == 2
    
    eventPlayer.teleport(vect(76.454, 14.112, -65.339))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area F]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[4]) < 4
    @Condition D == 0
    
    eventPlayer.teleport(vect(106.979, 12.171, -37.458))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Teleport Area G]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, U[5]) < 4
    @Condition D == 0
    
    eventPlayer.teleport(vect(86.536, 14.171, -37.365))
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Next Location Setup Effects]":
    @Condition newLine == 1
    
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, vect(7.613, 5.326, -34.916), 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 2500)), vect(7.613, 5.326, -34.916), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    T.append(getLastCreatedText())
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, vect(31.577, 6.126, -62.399), 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 5000)), vect(31.577, 6.126, -62.399), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    T.append(getLastCreatedText())
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, vect(99.296, 13.977, -72.064), 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 7500)), vect(99.296, 13.977, -72.064), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    T.append(getLastCreatedText())
    createEffect(getPlayers(Team.1), Effect.RING, Color.WHITE, vect(86.651, 14.036, -32.931), 1, EffectReeval.VISIBILITY)
    T.append(getLastCreatedEntity())
    createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format(l"{0} {1}".format(l"Next", l"Location"), 5000)), vect(86.651, 14.036, -32.931), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY)
    T.append(getLastCreatedText())


rule "[Unlock Next Location A]":
    @Event eachPlayer
    @Team 1
    @Condition distance(vect(7.598, 5.461, -34.812), eventPlayer) <= 2
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition C == 0
    @Condition eventPlayer.money >= 2500
    
    C = 1
    destroyEffect(W[0])
    destroyEffect(W[1])
    destroyEffect(W[2])
    destroyEffect(T[0])
    destroyInWorldText(T[1])
    playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
    eventPlayer.money -= 2500


rule "[Unlock Next Location B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(vect(31.805, 6.256, -62.43), eventPlayer) <= 2
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition C == 1
    @Condition eventPlayer.money >= 5000
    
    C = 2
    destroyEffect(W[3])
    destroyEffect(W[4])
    destroyEffect(W[5])
    destroyEffect(W[6])
    destroyEffect(T[2])
    destroyInWorldText(T[3])
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
    eventPlayer.money -= 5000


rule "[Unlock Next Location C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(vect(99.352, 14.111, -71.796), eventPlayer) <= 2
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition C == 2
    @Condition eventPlayer.money >= 7500
    
    C = 3
    D = 0
    destroyEffect(W[7])
    destroyEffect(W[8])
    destroyEffect(W[9])
    destroyEffect(T[4])
    destroyInWorldText(T[5])
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
    eventPlayer.money -= 7500


rule "[Unlock Next Location D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(vect(86.643, 14.166, -33.07), eventPlayer) <= 2
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition D == 0
    @Condition eventPlayer.money >= 5000
    
    D = 1
    destroyEffect(W[10])
    destroyEffect(W[11])
    destroyEffect(T[6])
    destroyInWorldText(T[7])
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, eventPlayer, 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Next", l"Location", l"{0}!".format(l"Unlocked")))
    eventPlayer.money -= 5000


rule "[Disable Spawn Room Hero Swap]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.hasSpawned() == true
    
    eventPlayer.disableRespawn()
    eventPlayer.F = false
    eventPlayer.H = 1


rule "[Upgrade Stats Setup]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.health_stat == 0
    
    eventPlayer.health_stat = 100
    eventPlayer.damage_stat = 100
    eventPlayer.healing_stat = 100


rule "[Upgrade Stats HUD]":
    @Event eachPlayer
    @Team 1
    @Condition N == 1
    
    hudHeader(eventPlayer, l"{0} : {1} : {2}".format(l"{0} {1}".format("HP", eventPlayer.health_stat), l"{0} {1}".format(l"Damage", eventPlayer.damage_stat), l"{0} {1}".format(l"Healing", eventPlayer.healing_stat)), HudPosition.TOP, -1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)


rule "[Healing Points]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.healing_tracker >= 120
    
    eventPlayer.money += 75 * eventPlayer.H
    eventPlayer.healing_tracker = 0
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(75 * eventPlayer.H, "Points")))
    R += 75 * eventPlayer.H


rule "[Healing Amount Tracker]":
    @Event playerDealtHealing
    @Team 1
    @Condition healee == eventPlayer == false
    
    eventPlayer.healing_tracker += eventHealing


rule "[Self Healing Amount Tracker]":
    @Event playerDealtHealing
    @Team 1
    @Condition healee == eventPlayer == true
    
    eventPlayer.healing_tracker += eventHealing / 2


rule "[Revive Effects]":
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[0], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[0], getPlayersInSlot(0, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[1], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[1], getPlayersInSlot(1, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[2], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[2], getPlayersInSlot(2, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[3], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[3], getPlayersInSlot(3, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[4], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[4], getPlayersInSlot(0, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, S[5], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, S[5], getPlayersInSlot(1, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "[Revive Player A]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[0]) <= 4
    @Condition eventPlayer != getPlayersInSlot(0, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(0, Team.1)
    chaseOverTime(getPlayersInSlot(0, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(0, Team.1).teleport(eventPlayer)
    getPlayersInSlot(0, Team.1).resurrect()
    P += 1
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.YELLOW, S[0], 100)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, getPlayersInSlot(0, Team.1), 10)
    S[0] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).O = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(0, Team.1), null, 100000)
    getPlayersInSlot(0, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player A]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[0]) > 4
    @Condition eventPlayer != getPlayersInSlot(0, Team.1)
    
    getPlayersInSlot(0, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(0, Team.1).C)


rule "[Revive Player B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[1]) <= 4
    @Condition eventPlayer != getPlayersInSlot(1, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(1, Team.1)
    chaseOverTime(getPlayersInSlot(1, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(1, Team.1).teleport(eventPlayer)
    getPlayersInSlot(1, Team.1).resurrect()
    P += 1
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[1], 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(1, Team.1), 100)
    S[1] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).P = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(1, Team.1), null, 100000)
    getPlayersInSlot(1, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player B]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[1]) > 4
    @Condition eventPlayer != getPlayersInSlot(1, Team.1)
    
    getPlayersInSlot(1, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(1, Team.1).C)


rule "[Revive Player C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[2]) <= 4
    @Condition eventPlayer != getPlayersInSlot(2, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(2, Team.1)
    chaseOverTime(getPlayersInSlot(2, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(2, Team.1).teleport(eventPlayer)
    getPlayersInSlot(2, Team.1).resurrect()
    P += 1
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[2], 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(2, Team.1), 100)
    S[2] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).Q = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(2, Team.1), null, 100000)
    getPlayersInSlot(2, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player C]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[2]) > 4
    @Condition eventPlayer != getPlayersInSlot(2, Team.1)
    
    getPlayersInSlot(2, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(2, Team.1).C)


rule "[Revive Player D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[3]) <= 4
    @Condition eventPlayer != getPlayersInSlot(3, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(3, Team.1)
    chaseOverTime(getPlayersInSlot(3, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(3, Team.1).teleport(eventPlayer)
    getPlayersInSlot(3, Team.1).resurrect()
    P += 1
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[3], 10)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(3, Team.1), 100)
    S[3] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).R = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(3, Team.1), null, 100000)
    getPlayersInSlot(3, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player D]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[3]) > 4
    @Condition eventPlayer != getPlayersInSlot(3, Team.1)
    
    getPlayersInSlot(3, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(3, Team.1).C)


rule "[Revive Player E]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[4]) <= 4
    @Condition eventPlayer != getPlayersInSlot(4, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(4, Team.1)
    chaseOverTime(getPlayersInSlot(4, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(4, Team.1).teleport(eventPlayer)
    getPlayersInSlot(4, Team.1).resurrect()
    P += 1
    playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[4], 10)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(4, Team.1), 100)
    S[4] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).Q = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(4, Team.1), null, 100000)
    getPlayersInSlot(4, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player E]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[4]) > 4
    @Condition eventPlayer != getPlayersInSlot(4, Team.1)
    
    getPlayersInSlot(4, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(4, Team.1).C)


rule "[Revive Player F]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[5]) <= 4
    @Condition eventPlayer != getPlayersInSlot(5, Team.1)
    @Condition eventPlayer.isAlive() == true
    
    eventPlayer.C = getPlayersInSlot(5, Team.1)
    chaseOverTime(getPlayersInSlot(5, Team.1).C, 4, 2 + P * 2)
    wait(2 + P * 2, Wait.ABORT_WHEN_FALSE)
    getPlayersInSlot(5, Team.1).teleport(eventPlayer)
    getPlayersInSlot(5, Team.1).resurrect()
    P += 1
    playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, S[5], 10)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(5, Team.1), 100)
    S[5] = vect(500, 0, 500)
    eventPlayer.money += 100 * eventPlayer.H
    smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
    getPlayers(Team.1).Q = 0
    R += 100 * eventPlayer.H
    heal(getPlayersInSlot(5, Team.1), null, 100000)
    getPlayersInSlot(5, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player F]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, S[5]) > 4
    @Condition eventPlayer != getPlayersInSlot(5, Team.1)
    
    getPlayersInSlot(5, Team.1).C = 0
    stopChasingVariable(getPlayersInSlot(5, Team.1).C)


rule "[Player Respawn & Move Revive]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isAlive() == true
    
    S[eventPlayer.getSlot()] = vect(500, 0, 500)


rule "[Points Orb Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[1]) <= 1.5
    @Condition getPlayers(Team.1).G[1] == false
    @Condition newLine >= 1
    
    M[1] = vect(500, 25, 500)
    getPlayers(Team.1).G[1] = true
    getPlayers(Team.1).S[1] = 1
    bigMessage(getAllPlayers(), "2x Points Earned -> 30 Sec")
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.YELLOW, eventPlayer, 5)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    getPlayers(Team.1).H = 2
    wait(30)
    getPlayers(Team.1).H = 1
    getPlayers(Team.1).G[1] = false
    getPlayers(Team.1).S[1] = 0


rule "[Speed Orb Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[2]) <= 1.5
    @Condition getPlayers(Team.1).G[2] == false
    @Condition newLine >= 1
    @Condition newLine < 40
    
    M[2] = vect(500, 25, 500)
    getPlayers(Team.1).G[2] = true
    getPlayers(Team.1).S[2] = 1
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Faster", l"Speed", l"-> {0}".format(l"{0} sec".format(60))))
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 5)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    getPlayers(Team.1).setMoveSpeed(200)
    wait(60)
    getPlayers(Team.1).G[2] = false
    getPlayers(Team.1).S[2] = 0
    getPlayers(Team.1).setMoveSpeed(100)


rule "[Honey, I Shrunk The Team Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[4]) <= 1.5
    @Condition getPlayers(Team.1).G[4] == false
    @Condition newLine >= 1
    
    M[4] = vect(500, 25, 500)
    getPlayers(Team.1).G[4] = true
    getPlayers(Team.1).S[4] = 1
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.HEART), "Honey, I Shrunk The Team! ", iconString(Icon.HEART)))
    getPlayers(Team.1).startModifyingVoicelinePitch(1.5, false)
    getPlayers(Team.1).startScalingSize(0.5, false)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ROSE, eventPlayer, 5)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    wait(0.15)
    getPlayers(Team.1).setJumpVerticalSpeed(300)
    wait(60)
    getPlayers(Team.1).G[4] = false
    getPlayers(Team.1).S[4] = 0
    getPlayers(Team.1).startModifyingVoicelinePitch(1, false)
    getPlayers(Team.1).startScalingSize(1, false)
    getPlayers(Team.1).setJumpVerticalSpeed(100)


rule "[Total Mayhem Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[0]) <= 1.5
    @Condition getPlayers(Team.1).G[0] == false
    @Condition newLine >= 1
    
    M[0] = vect(500, 25, 500)
    getPlayers(Team.1).G[0] = true
    getPlayers(Team.1).S[0] = 1
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.DIZZY), "Total Mayhem -> 30 Sec ", iconString(Icon.DIZZY)))
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 5)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    getPlayers(Team.1).setGravity(25)
    if newLine < 50:
        goto lbl_0
    eventPlayer.setMoveSpeed(200)
    lbl_0:
    wait(30)
    getPlayers(Team.1).G[0] = false
    getPlayers(Team.1).S[0] = 0
    getPlayers(Team.1).setGravity(100)
    if newLine < 50:
        goto lbl_1
    getPlayers(Team.1).setMoveSpeed(100)
    lbl_1:


rule "[Total Mayhem Effects]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.G[0] == true
    
    getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_1, 0)
    getPlayers(Team.1).setAbilityCooldown(Button.ABILITY_2, 0)
    getPlayers(Team.1).setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    wait(1, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START


rule "[Challenge Accepted Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[5]) <= 1.5
    @Condition getPlayers(Team.1).G[5] == false
    @Condition newLine >= 1
    
    M[5] = vect(500, 25, 500)
    getPlayers(Team.1).G[5] = true
    getPlayers(Team.1).S[5] = 1
    bigMessage(getAllPlayers(), "[Challenge? Accepted!] Invincible -> 30 Sec")
    smallMessage(getPlayers(Team.1), "Invincible -> 30 Sec")
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 5)
    getPlayers(Team.1).setStatusEffect(null, Status.UNKILLABLE, 30)
    wait(30)
    getPlayers(Team.1).G[5] = false
    getPlayers(Team.1).S[5] = 0


rule "[Freeze Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[3]) <= 1.5
    @Condition getPlayers(Team.1).G[3] == false
    @Condition newLine >= 1
    
    M[3] = vect(500, 25, 500)
    getPlayers(Team.1).G[3] = true
    getPlayers(Team.1).S[3] = 1
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(l"Freezing", l"Zone", l"-> {0}".format(l"{0} sec".format(30))))
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 100)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.SKY_BLUE, eventPlayer, 5)
    wait(30)
    getPlayers(Team.1).G[3] = false
    getPlayers(Team.1).S[3] = 0


rule "[Freeze Effects+]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.G[3] == true
    
    getPlayersInRadius(eventPlayer, 8, Team.2).setStatusEffect(null, Status.FROZEN, 3)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_EXPLOSION, Color.SKY_BLUE, eventPlayer, 5)
    wait(4)
    if RULE_CONDITION:
        goto RULE_START


rule "[Secret Room Effects]":
    @Condition D == 1
    
    createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vect(97.513, 16.972, -20.29), 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    N[0] = getLastCreatedEntity()
    createInWorldText(getAllPlayers(), l"{0} {1}".format(l"Connect", l"Power"), vect(97.513, 16.972, -20.29), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
    N[1] = getLastCreatedText()
    createInWorldText(getAllPlayers(), l"#{0}".format(iconString(Icon.ARROW_LEFT)), vect(90.42, 17.169, -17.775), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)


rule "[Power Switch ON]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(97.513, 16.972, -20.29)) <= 2
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition K == 0
    @Condition D == 1
    
    destroyEffect(N[0])
    destroyInWorldText(N[1])
    N = 1
    K = 1
    bigMessage(getAllPlayers(), l"{0} {1}".format(l"Power", l"On"))
    F = 0
    G = random.choice(H)


rule "[Teleporter A]":
    @Condition K == 1
    
    createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    J[0] = getLastCreatedEntity()
    createInWorldText(getAllPlayers(), iconString(Icon.NO), vect(123.312, 9.176, -27.364), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
    J[1] = getLastCreatedText()
    wait(1)
    J[2] = random.choice(I)
    createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, J[2], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    J[3] = getLastCreatedEntity()
    createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), J[2], 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
    J[4] = getLastCreatedText()


rule "[Teleporter B]":
    @Condition K == 2
    
    destroyEffect(J[0])
    destroyInWorldText(J[1])
    destroyEffect(J[3])
    destroyInWorldText(J[4])
    createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    J[5] = getLastCreatedEntity()
    createInWorldText(getAllPlayers(), "-> [Shop] <-", vect(123.312, 10.5, -27.364), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
    J[6] = getLastCreatedText()
    bigMessage(getAllPlayers(), "The secret shop has temporarily opened!")
    wait(60)
    K = 3


rule "[Teleporter C]":
    @Condition K == 3
    
    destroyEffect(J[5])
    destroyInWorldText(J[6])
    bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Offline]")
    wait(180)
    K = 1
    bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Online]")


rule "[Secret Shop Power ON]":
    @Condition newLine == 1
    
    I = []
    #I.append(vect(121.74, 12.034, -65.345))
    #I.append(vect(135.084, 16.051, -35.406))
    #I.append(vect(126.233, 12.035, -16.35))
    I.append(vect(112.572, 10.034, -30.484))
    #I.append(vect(87.192, 14.034, -40.809))
    #I.append(vect(99.11, 14.045, -61.446))
    #I.append(vect(128.287, 15.034, -8.08))
    #I.append(vect(107.671, 12.034, -31.942))
    J[2] = vect(500, 25, 500)


rule "[Teleporter Switch]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, J[2]) <= 1.5
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition K == 1
    
    K = 2


rule "[Teleport Players To Secret Shop]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(123.312, 9.176, -27.364)) <= 5
    @Condition K == 2
    @Condition eventPlayer.F == false
    @Condition eventPlayer.J == 0
    
    eventPlayer.J = 1
    eventPlayer.teleport(vect(-16.309, 8.115, -89.008))
    wait(30)
    if eventPlayer.J == 0:
        goto lbl_0
    smallMessage(eventPlayer, "Leaving in 5...")
    wait(1)
    smallMessage(eventPlayer, 4)
    wait(1)
    smallMessage(eventPlayer, 3)
    wait(1)
    smallMessage(eventPlayer, 2)
    wait(1)
    smallMessage(eventPlayer, 1)
    wait(1)
    lbl_0:
    if eventPlayer.J == 0:
        goto lbl_1
    eventPlayer.teleport(vect(113.354, 16.189, -29.761))
    lbl_1:
    eventPlayer.J = 0


rule "[Exit Secret Shop]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-8.2, 10.2, -76.2)) <= 2.5
    
    eventPlayer.teleport(vect(113.354, 16.189, -29.761))
    eventPlayer.J = 0


rule "[Shop Upgrades]":
    @Condition N == 1
    
    createEffect(getAllPlayers(), Effect.RING, Color.LIME_GREEN, vect(-31.204, 7.849, -87.474), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(-26.235, 7.812, -90.938), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.ORANGE, vect(-27.198, 7.849, -96.303), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText(getAllPlayers(), "HP (+25%) | 2500 ", vect(-31.204, 7.849, -87.474), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.LIME_GREEN)
    createInWorldText(getAllPlayers(), "Damage (+20%) | 2500", vect(-26.241, 7.819, -90.941), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
    createInWorldText(getAllPlayers(), "Healing Dealt (+15%) | 2500", vect(-27.198, 7.849, -96.303), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)


rule "[Buy] Damage Upgrade":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-26.235, 7.812, -90.938)) < 1.8
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.money >= 2500
    
    eventPlayer.money -= 2500
    eventPlayer.damage_stat += 15
    eventPlayer.setDamageDealt(eventPlayer.damage_stat)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)


rule "[Buy] Health Upgrade":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-31.204, 7.849, -87.474)) < 1.8
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.money >= 2500
    
    eventPlayer.money -= 2500
    eventPlayer.health_stat += 20
    eventPlayer.setMaxHealth(eventPlayer.health_stat)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
    wait(0.25)
    heal(eventPlayer, null, 99999)


rule "[Buy] Healing Upgrade":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-27.198, 7.849, -96.303)) < 1.8
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.money >= 2500
    
    eventPlayer.money -= 2500
    eventPlayer.healing_stat += 10
    eventPlayer.setHealingDealt(eventPlayer.healing_stat)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)


rule "[Player Death Message]":
    @Event playerDied
    @Team 1
    
    S[eventPlayer.getSlot()] = nearestWalkablePosition(eventPlayer)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, l"{0}!".format("is down and needs reviving")))
    E[eventPlayer.getSlot()] = true
    smallMessage(eventPlayer, "Please wait for a teammate to revive you or for all zombies to be slayed this round.")

rule "[Tips & Tricks]":
    @Event eachPlayer
    @Team 1
    
    wait(1)
    setObjectiveDescription(eventPlayer, "Welcome to Zombies Unleashed! | Objective: Survive as many waves of zombies as possible!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Unlock heroes, new locations and upgrade your stats with your points! Use Interact [{0}] when standing on the circle.".format(buttonString(Button.INTERACT)), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Earn points by defeating zombies, assisting, healing & reviving your teammates. Everyone wins!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Tanks have a permanent 15% Damage Reduction passive!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "You can enable 3P Camera by pressing and holding [{0}] [{1}] together. Hold [{0}] [{2}] together to turn it off.".format(buttonString(Button.INTERACT), buttonString(Button.RELOAD), buttonString(Button.JUMP)), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Struggling to find the secret room? It's somewhere in the castle! When the power is stable look on the floor...", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Staying together as a team is the best approach. A team that sticks together...revives together!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Supporters rejoice! Points are rewarded for healing your teammates. Paid to heal? Sign me up!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Try and save your points so you can use them to upgrade your stats in the secret shop!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Wondering why D.VA has no ultimate? She's so OP we had to even the playing field! Love, D.VA ;)", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Teleporting Torbs? Working as intended. Junkenstein done a real number on them. Oh the joy!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "If you hear \"Molten Core\" look for the red puddles. Stand in them to increase your damage! Honest..", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Revive a teammate by standing on the Yellow Circle where they died.", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Mercy's revive has been amplified to grant her temporary immunity. Your guardian angel has arrived!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Spare points? Give your whole team a buff with permanent Shields/Armor. Friendship is the best ship!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "All heroes are available to purchase! Can you spot where they are in the area?", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "Enraged Zombies gain Molten Core. Happy birthday!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    setObjectiveDescription(eventPlayer, "[OG Mode by]: Pug | [Remastered by]: Hannon | [Tweaks/Updates by]: SashayAsh", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    wait(15)
    goto RULE_START


rule "[Zombies Fly Faster]":
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


rule "[Auto Heal Secret Shop]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-20.695, 7.574, -86.552)) < 12
    
    wait(1)
    heal(eventPlayer, null, 99999)
    wait(2)


rule "[Zombies LoS Teleport]":
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


rule "[Exit In-World Text Secret Shop]":
    createInWorldText(getAllPlayers(), "[Exit]", vect(-8.216, 10.262, -76.205), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
    createInWorldText(getAllPlayers(), "[No Exit]", vect(-11.251, 6.5, -87.359), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)


rule "[TP Zombies - Unstuck]":
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


rule "[Anti-Fall Debug]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition distance(eventPlayer, vect(0, 0, 0)) < 2.5
    
    eventPlayer.applyImpulse(Vector.UP, 100, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[TP Dead Zombies]":
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


rule "[TP Zombies - Out Of Map Safety]":
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


rule "[Bot] Unstuck Impulse":
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


rule "[Bot - Anti Fall]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition distance(eventPlayer, vect(0, 0, 0)) < 2.5
    
    eventPlayer.applyImpulse(Vector.UP, 100, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    wait(1)
    if RULE_CONDITION:
        goto RULE_START


rule "[Buy Shields]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.money >= 7500
    @Condition eventPlayer.F == false
    @Condition distance(eventPlayer, vect(75.074, 12, -50.574)) <= 1.5
    @Condition C >= 3
    
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
    getPlayers(Team.1).addHealthPool(Health.SHIELDS, 40, true)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Shields!"))
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.BLUE, getPlayers(Team.1), 100)
    eventPlayer.money -= 7500
    wait(0.25)
    heal(getLivingPlayers(Team.1), null, 99999)
    team_shields += 40


rule "[Buy Armor]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition distance(eventPlayer, vect(74.394, 12, -52.812)) <= 1.5
    @Condition eventPlayer.money >= 7500
    @Condition eventPlayer.F == false
    @Condition C >= 3
    
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, getPlayers(Team.1), 100)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Armor!"))
    getPlayers(Team.1).addHealthPool(Health.ARMOR, 40, true)
    eventPlayer.money -= 7500
    wait(0.25)
    heal(getLivingPlayers(Team.1), null, 99999)
    team_armor += 40

#!include "3p camera.opy"

rule "Zombie Event [10]":
    @Condition newLine == 10
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies look rather angry... ", iconString(Icon.FIRE)))

rule "Enraged Zombies [50]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 49
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)
    eventPlayer.setDamageReceived(85)
    eventPlayer.startHealingOverTime(eventPlayer, 9999, 150)


rule "Enraged Zombies [50]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 49
    
    eventPlayer.startModifyingVoicelinePitch(0.5, false)
    eventPlayer.setUltCharge(random.randint(99, 100))
    wait(2)
    getPlayersOnHero(Hero.TORBJORN, Team.2).setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [30]":
    @Condition newLine == 30
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.WARNING), "All Zombies are now permanently Enraged! ", iconString(Icon.WARNING)))

#!include "hero abilities.opy"

rule "[Portal]":
    @Condition newLine == 15
    
    wait(6)
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.BLUE, vect(-9.799, 3.5, -27.229), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.BAD_AURA, Color.ORANGE, vect(126.434, 16.5, -15.81), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    bigMessage(getPlayers(Team.1), l"{0} {1} {2}".format(iconString(Icon.SPIRAL), "A portal has appeared nearby...", iconString(Icon.SPIRAL)))


rule "[Portal 1]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(-9.799, 3.147, -27.229)) <= 1.7
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition newLine > 14
    
    wait(0.15)
    eventPlayer.teleport(vect(126.4, 18, -15.8))
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.ORANGE, eventPlayer, 100)
    wait(2)


rule "[Portal 2]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(126.434, 16.084, -15.81)) <= 1.7
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition newLine > 14
    
    wait(0.15)
    eventPlayer.teleport(vect(-9.8, 6, -27.3))
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.ORANGE, eventPlayer, 100)
    wait(2)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 0
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 0
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [20]":
    @Condition newLine == 20
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are getting angrier! ", iconString(Icon.FIRE)))


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 1
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 2
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 1
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Enraged Zombies [20]":
    @Event eachPlayer
    @Team 2
    @Slot 2
    @Condition newLine > 19
    @Condition eventPlayer.isAlive() == true
    @Condition newLine < 30
    
    eventPlayer.setUltCharge(100)
    wait(2)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)


rule "Zombie Event [50]":
    @Condition newLine == 50
    
    wait(6)
    bigMessage(getAllPlayers(), l"{0} {1} {2}".format(iconString(Icon.FIRE), "The Zombies are furious! (...Is someone playing DPS Moira?) ", iconString(Icon.FIRE)))


rule "Enraged Zombies [30]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 29
    @Condition newLine < 40
    
    eventPlayer.startForcingName("Enraged Zombie")
    wait(1)
    eventPlayer.startScalingSize(1.5, false)


rule "Enraged Zombies [30]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isAlive() == true
    @Condition newLine > 29
    @Condition newLine < 40
    
    eventPlayer.setUltCharge(random.randint(99, 100))
    wait(2)
    getPlayersOnHero(Hero.TORBJORN, Team.2).setStatusEffect(null, Status.BURNING, 9999)


rule "[TP Spawn Room Debug]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(101.397, 14.21, -110.834)) < 14
    
    wait(0.5)
    if not RULE_CONDITION:
        return
    eventPlayer.teleport(vect(-27.412, 2, -12.564))
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), vect(-12.858, 3.32, -17.254)), 100000)
    wait(0.1)
    eventPlayer.stopFacing()


rule "[Starting Spawn Location]":
    @Event eachPlayer
    @Team 1
    @Hero dva
    @Condition eventPlayer.isInSpawnRoom() == true
    
    eventPlayer.startCamera(vect(-17.532, 3.356, -16.72), vect(-26.463, -0.316, -14.143))
    eventPlayer.teleport(vect(-27.412, 8.678, -12.564))
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableHeroHud()
    wait(0.3)
    eventPlayer.setStatusEffect(null, Status.ROOTED, 9999)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE + Button.SECONDARY_FIRE + Button.ABILITY_1 + Button.ABILITY_2 + Button.ULTIMATE + Button.INTERACT + Button.JUMP + Button.CROUCH + Button.MELEE)
    eventPlayer.startFacing(Vector.RIGHT, 100000, Relativity.TO_PLAYER)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.VIOLET, eventPlayer, 2)
    wait(0.8)
    eventPlayer.setUltCharge(0)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), vect(-12.858, 3.32, -17.254)), 100000)
    wait(0.1)
    eventPlayer.stopCamera()
    eventPlayer.stopFacing()
    eventPlayer.enableGamemodeHud()
    eventPlayer.enableHeroHud()
    getPlayers(Team.2).applyImpulse(Vector.UP, 2, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.5)
    eventPlayer.setMoveSpeed(100)
    eventPlayer.allowButton(Button.PRIMARY_FIRE + Button.SECONDARY_FIRE + Button.ABILITY_1 + Button.ABILITY_2 + Button.ULTIMATE + Button.INTERACT + Button.JUMP + Button.CROUCH + Button.MELEE + Button.RELOAD)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 5)
    eventPlayer.enablePlayerCollision()


rule "[Buffs]: Total Mayhem Ultimate":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.G[0] == true
    
    eventPlayer.setUltCharge(100)
    wait(5, Wait.ABORT_WHEN_FALSE)
    if RULE_CONDITION:
        goto RULE_START

rule "<3":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(131, 11.5, 3.8)) <= 5
    
    waitUntil(true, 99999)
    createIcon(getAllPlayers(), eventPlayer, Icon.HEART, IconReeval.NONE, Color.ROSE)


rule "[Time Distortion Effects]":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, M[6]) <= 1.5
    @Condition getPlayers(Team.1).G[6] == false
    @Condition newLine > 39
    
    M[6] = vect(500, 25, 500)
    getPlayers(Team.1).G[6] = true
    getPlayers(Team.1).S[6] = 1
    bigMessage(getPlayers(Team.1), l"{0} {1} {2}".format(iconString(Icon.SPIRAL), "[Time Distortion] Wibbly, Wobbly, Timey Wimey! -> 30 Sec ", iconString(Icon.SPIRAL)))
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 150)
    setSlowMotion(50)
    getPlayers(Team.2).setDamageReceived(150)
    getPlayers(Team.1).setMoveSpeed(400)
    getPlayers(Team.1).setJumpVerticalSpeed(200)
    wait(15)
    setSlowMotion(100)
    getPlayers(Team.1).G[6] = false
    getPlayers(Team.1).S[6] = 0
    getPlayers(Team.1).setJumpVerticalSpeed(100)
    getPlayers(Team.1).setMoveSpeed(100)
    getPlayers(Team.2).setDamageReceived(100)


rule "[Drop] Time Distortion Sphere":
    @Event playerDied
    @Team 2
    @Slot 2
    @Condition newLine > 39
    
    eventPlayer.healing_tracker = random.randint(1, 25)
    if eventPlayer.healing_tracker != 1:
        goto lbl_0
    M[6] = nearestWalkablePosition(eventPlayer) + vect(0, 1, 0)
    lbl_0:
    eventPlayer.setUltCharge(0)
    wait(0.2)
    B -= 1
    wait(0.25)
    if B < 6:
        goto lbl_1
    eventPlayer.respawn()
    lbl_1:

#!include "utils.opy"