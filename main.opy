#!include "settings.opy"
#!include "variables.opy"
#!include "debug.opy"

#!include "3p camera.opy"
#!include "buy hero stats.opy"
#!include "buy hero.opy"
#!include "hero abilities.opy"
#!include "locked area.opy"
#!include "orbs.opy"
#!include "player joined.opy"
#!include "player spawn.opy"
#!include "player revive.opy"
#!include "secret shop.opy"
#!include "zombie events.opy"
#!include "zombie money.opy"
#!include "zombie behavior.opy"
#!include "teleports.opy"
#!include "portal.opy"
#!include "utils.opy"

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


rule "[Bot Anti-Spawn Check A]":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isInSpawnRoom() == true
    
    eventPlayer.teleport(random.choice(Y))

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


rule "Starting Spawn Location for players":
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

rule "<3":
    @Event eachPlayer
    @Team 1
    @Condition distance(eventPlayer, vect(131, 11.5, 3.8)) <= 5
    
    waitUntil(true, 99999)
    createIcon(getAllPlayers(), eventPlayer, Icon.HEART, IconReeval.NONE, Color.ROSE)
