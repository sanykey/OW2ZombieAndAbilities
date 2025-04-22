#!mainFile "main.opy"
#Global variables

globalvar roundNumber 0
globalvar zombiesflyIOnandOff 26
globalvar team_shields 30
globalvar team_armor 31
globalvar heroes_shop_data 32
globalvar matchIsOver 33
globalvar unlockedLocations 34
globalvar orbs_arr 35
globalvar hiddenVector 36
globalvar roundRemainingBots 39
globalvar orbs_vectors_arr 40
globalvar isRoundEnd 41
globalvar vips 43
globalvar isBotsDisabled 45

globalvar debugVectsArr 46
globalvar debugCurrentVectNum 47
globalvar debugCurrentVectEffectArr 48
globalvar vectList 51
globalvar lockedAreaEffectsArr 52
globalvar shopState 53
globalvar teamScore 54
globalvar temp1 55
globalvar temp2 56
globalvar combatants 57
globalvar combatantsCount 58

#Player variables

playervar money 0
playervar healthStat 10
playervar damageStat 11
playervar healingStat 12
playervar zombiesfly 26
playervar orb_roll 27 # current orb drop chance when a bot dies
playervar isInSecretShop 28

playervar stateArr 30 # use with enum "stateI"
playervar reviveProgress 31
playervar isTargetInLos 32
playervar recentStackedHealingDealtToSlot 33
playervar healingTracker 34
playervar recentHealingDealtToSlot 35

playervar recentDamageDealtToSlot 29
playervar recentStackedDamageDealtToSlot 36

playervar downedStartTime 37
playervar reviveTimer 38
playervar deathCamTarget 39
playervar isCombatant 40
playervar revivers 41
playervar targetPlayer 42


#Activated extensions
#!extension explosionSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots

#!define INFINITE 99999
#!define MONEY_FOR_REVIVE 300
#!define MONEY_FOR_ZOMBIE_KILL 200
#!define MONEY_FOR_ZOMBIE_CRITICAL 275
#!define MONEY_FOR_HEALING 100
#!define HEAL_AMOUNT_FOR_MONEY 200
#!define MAX_PLAYERS 6
#!define MAX_ZOMBIES 12
#!define ALLY_BOT_PLAYER_SLOT 7
#!define REVIVE_TIMER_TICK 2

enum stateI:
  CAMERA_3P = 0 # number
  # 0: OFF
  # 1: Temporary OFF
  # 2: Temporary OFF higher angle
  # 3: ON
  # 4: ON higher angle
  CAMERA_3P_PREV = 1 # like as CAMERA_3P
  HEALING_TRACKER = 2
  HEALING_TRACKER_THRESHOLD = 3
  HEALING_RESULT = 4
