#!mainFile "../main.opy"

#####################################################
#################### Defines ########################
######################################################
# [shop]:
#!define UPGRADE_PRICE 2500
#!define TEAM_UPGRADE_PRICE 10000
#!define HEALTH_UPGRADE_AMOUNT 8
#!define DAMAGE_UPGRADE_AMOUNT 5
#!define HEALING_UPGRADE_AMOUNT 5
#!define TEAM_ARMOR_UPGRADE_AMOUNT 10
#!define BUNCH_BUY_MULTIPLY 20

# Dificultly settings
#!define PLAYER_RESPAWN_TIME 180
#!define ULT_CHARGE_FOR_KILL 5
#!define EMOTE_ULT_CHARE_PER_SECONDS  0.3
#!define DAMAGE_RESISTANCE_BY_OWNED_HERO 0.5
#!define AUTO_HEAL_DELAY 15
#!define HEALER_AUTO_HEAL_DELAY 7

# vanilla hero constants
#!define TORBJORN_HAMMER_BASE_DMG 70

# Zombie settings
#!define ZOMBIE_FALL_DAMAGE 250
#!define ZOMBIE_BASE_DAMAGE 20
#!define ZOMBIE_BASE_HP 50
#!define ZOMBIE_BASE_SPEED 75
#!define ZOMBIE_MAX_SPEED_PCT 100
#!define BOT_MAX_INACTIVITY_DURATION 60
#!define LAST_CC_ATTACK_DURATION 5

# [Bot fake death]
#!define BOT_FAKE_DIE_HP_THRESHOLD 10

# Player settings
#!define MAX_PLAYERS 5
#!define AUTO_HEALING_OVERTIME_DURATION 20
#!define REVEAL_DURATION 10


# [Sombra] Money:
#!define SOMBRA_STEAL_MONEY 25

# HUD
#!define HERO_INFO_HOLD_DURATION 0.5

# Other:
#!define INFINITY 99999

# Heroest talents
#!define ANA_NANO_SPEEDBOOST 135
#!define ANA_NANO_SPEEDBOOST_TIME 8
#!define ANA_AOE_SLEEP_RADIUS 4
#!define ANA_AOE_SLEEP_TIME 5
#!define ANA_NADE_SLOWDOWN 30
#!define ANA_NADE_SLOWDOWN_TIME 5
#!define ANA_DIRECT_HIT_SLOWDOWN 50
#!define ANA_PARALYZING_STRIKE_CD 12

#!define CASSIDY_LASSO_CD 12

#####################################################
################ Global constants ###################
#####################################################
# When checking isInLoS(), use a position slightly above the distant target to avoid false positives through the floor:
globalvar LosHeightCheckVectConst = vect(false, 1.2, false)


#####################################################
################ Global variables ###################
#####################################################
globalvar playersInShop
globalvar combatants = []
globalvar roundNumber = 0

globalvar spawnPointsList = []
globalvar roundMaxBots
# Buy hero
globalvar heroesShopData = [] # [hero, buy_place_vector, price, buy_text_vector]
#!define BUY_HERO_OFFSET_A 0
#!define BUY_HERO_OFFSET_B VL_BUY_HERO_SPOTS_A_LEN
#!define BUY_HERO_OFFSET_E BUY_HERO_OFFSET_B + VL_BUY_HERO_SPOTS_B_LEN
#!define BUY_HERO_OFFSET_I BUY_HERO_OFFSET_E + VL_BUY_HERO_SPOTS_E_LEN
#!define BUY_HERO_OFFSET_H BUY_HERO_OFFSET_I + VL_BUY_HERO_SPOTS_I_LEN

# [sectet shop]:
globalvar shopEffects = []
globalvar shopStatus
globalvar buyHeroUpgradesData
globalvar secretShopZoneEffects = []

# zombie bots vars:
globalvar zomMaxHealthPct
globalvar zomDamagePct
globalvar zomSpeedPct
globalvar zombieStats
enum ZI:
  DAMAGE_STAT
  HP_STAT
  ZOMBIE_RESPAWN_I

globalvar teamArmor
globalvar matchIsOver = false
globalvar unlockedLocations = 0
globalvar roundRemainingBots = 0

globalvar isBotsDisabled

globalvar lockedAreaEffectsArr

globalvar teamScore
globalvar tmp0
globalvar tmp1
globalvar tmp2
globalvar tmp3
globalvar list

globalvar isGameStarted = false
globalvar highloadServerPause

globalvar botSniperPositions
globalvar botSniperPositionsPlayerisInLoS
globalvar delayerStartHudId

# workshop settings 
globalvar wSettingsStartMoney
globalvar wSettingsMaxZombieBots

## only for debug
globalvar debugVectsArr
globalvar debugCurrentVectNum
globalvar debugCurrentVectEffectArr

# debug
globalvar debugMenuIsOpened
globalvar debugBotsSpawnPoint

##################################################
############## Player variables: #################
##################################################
playervar zomDistancesToPlayersArr  # distances to players for current zombie (Cache)
playervar zomIsInLoSPlayersArr      # players visibility for current zombie (Cache)
playervar zomDownedTime             # zombie death timestamp (to preserve respawn order)
playervar zomIsHacked
playervar zomForceHeroOnRespawn
playervar zomMeleeAttackTargets
playervar zomFlyThroughWalls
playervar zomLastMeleeAttackTimeArr
playervar zomFlyThroughWallsPoints
playervar zomTarget
playervar zomAIstep
globalvar botWidowmakerAvaliableSpawnSpots
# detecting crowd control abilities for bots fall damage
playervar lastCcAttacker
playervar lastCcAttackTime
playervar lastCcWasInAir
playervar lastCcVanilaKnockback

enum HeroType:
  TANK
  DAMAGE
  SUPPORT
playervar heroType                  # player’s selected hero type - used for target prioritization by zombie bots
playervar isInSecretShop
playervar state # use with enum "SI"
playervar developer
playervar revivers
playervar reviveTimer
playervar posBeforeChangeHero
playervar isDvaUltBought
playervar purchasedHeroes
playervar healthBoostPercent
playervar damageBoostPercent
playervar healingBoostPercent

#!define PV_ARMOR_FOR_TEAM 1
#!define PV_TEAM_ARMOR_POOL 3
playervar boostStats # [shieldsForTeam, armorForTeam, teamShieldsPool, teamArmorPool]

playervar damageResistPercent

# effects ids
playervar effectsIds
#!define PLAYER_STATUS_HUD 0
#!define REVIVE_CIRCLE_EFFECT 1
#!define REVIVE_TEXT 2
#!define REVEALED_ICON 3
#!define ZOMBIE_FLY_ICON 4
#!define ZOMBIE_LAST_ICON 5

playervar heroEffectsIds

playervar revealed
playervar money__zomStuckPoints
playervar moneyTotal__zomStuckPrevPosition

playervar abilTemp1 # tmp var use for loops with "wait" per hero
playervar isInvisible
playervar isReady

playervar isHeroDescriptionOpened

# new barriers damage took and push logic
globalvar barrierPushVectUpFix = vect(0, 0.2679, 0) # When pushing characters horizontally, we add a bit of upward displacement so that the pushing is not hindered by the floor
playervar barrierDamageFrom
playervar barrierDamageDir
playervar barrierDamageStack
playervar isActiveBarrier

playervar tmp0
playervar tmp1
playervar tmp2
playervar tmp3
playervar tmp4
playervar tmp5
playervar list0
playervar list1
playervar list2

## hero state vars:
playervar abilPos0
playervar abilPos1
playervar abilPos2
playervar abilPos3
playervar abilPos4
playervar abilState0 # also zombie bots antifall state
playervar abilState1
playervar abilState2
playervar abilState3
playervar abilState4
playervar abilDir0
playervar abilDir1
playervar abilDir2
playervar abilDir3
playervar target0
playervar targetPlayer1
playervar abilityCD