#!mainFile "../main.opy"

#####################################################
#################### Defines ########################
######################################################
enum Team:
  PLAYERS = Team.1
	ZOMBIES = Team.2

#!define MODE_VERSION "v0.11.0 beta (29.03.2026)"

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
#!define BOT_MAX_TARGET_DISTANCE 40
#!define ZOMBIE_FALL_DAMAGE 250
#!define ZOMBIE_BASE_DAMAGE 20
#!define ZOMBIE_BASE_HP 50
#!define ZOMBIE_BASE_SPEED 75
#!define ZOMBIE_MAX_SPEED_PCT 100
#!define BOT_MAX_INACTIVITY_DURATION 60
#!define LAST_CC_ATTACK_DURATION 5
#!define BOT_FACING_SPEED 150

# [Bot fake death]
#!define BOT_FAKE_DIE_HP_THRESHOLD 10

# Player settings
#!define MAX_PLAYERS 6
#!define AUTO_HEALING_OVERTIME_DURATION 20
#!define REVEAL_DURATION 10


# [Sombra] Money:
#!define SOMBRA_STEAL_MONEY 25

# HUD
#!define HERO_INFO_HOLD_DURATION 0.5

# Other:
#!define INFINITY 99999

# Heroest talents
#!define REINHARDT_ULT_KNOCKED_DOWN_TIME_SEC 5

#!define ANA_NANO_SPEEDBOOST 135
#!define ANA_NANO_SPEEDBOOST_TIME 8
#!define ANA_AOE_SLEEP_RADIUS 4
#!define ANA_AOE_SLEEP_TIME 5
#!define ANA_NADE_SLOWDOWN 30
#!define ANA_NADE_SLOWDOWN_TIME 5
#!define ANA_DIRECT_HIT_SLOWDOWN 50
#!define ANA_PARALYZING_STRIKE_CD 12

#!define CASSIDY_LASSO_CD 12

#!define DVA_BOOSTERS_KNOCK_DOWN_TIME 1.5

#####################################################
################ Global constants ###################
#####################################################
# When checking isInLoS(), use a position slightly above the distant target to avoid false positives through the floor:
globalvar LosHeightCheckVectConst = vect(false, 1.2, false)
globalvar OffmapPositionConst = vect(false, 500, false)
globalvar BarrierPushVectUpFixConst = vect(false, 0.2679, false) # When pushing characters horizontally, we add a bit of upward displacement so that the pushing is not hindered by the floor

#####################################################
################ Global variables ###################
#####################################################
globalvar playersInShop
globalvar combatants = []
globalvar roundNumber = 0

globalvar roundMaxBots
# Buy hero
globalvar heroesShopData = [] # [hero, buy_place_vector, price, buy_text_vector]

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
globalvar roundMaxBotsSlots

globalvar isBotsDisabled

globalvar lockedAreaEffectsArr

globalvar teamScore

# temp vars
globalvar tmp0
globalvar tmp1
globalvar tmp2
globalvar tmp3
globalvar tmp4
globalvar tmp5
globalvar list0
globalvar list1
globalvar list2

## common subroutine params/result vars
globalvar param1
globalvar param2
globalvar param3
globalvar subroutineResult

globalvar isGameStarted
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
globalvar debugFailedRespawnPoints
globalvar debugMenuIsOpened
globalvar debugZombieBotsSpawnPoint
globalvar debugDisableBotMoverment


##################################################
############## Player variables: #################
##################################################
playervar zomIsInLoSPlayersArr      # players visibility for current zombie (Cache)
playervar zomIsHacked
playervar zomForceHeroOnRespawn
playervar botMeleeAttackTargets
playervar botWallPhase
playervar botWantsWallPhasePoints
playervar botTarget
playervar borFarDistancePoints
playervar zomAIstep
globalvar botWidowmakerAvaliableSpawnSpots
playervar botTargetLastPosition

# detecting crowd control abilities for bots fall damage and unstuck (or wall phase) mechanics
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

playervar attach2p
enum Attach2P:
  IS_ATTACHED
  PARENT
  POSITION
  HEALTH_POOL
  CHILD

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
#!define ZOMBIE_LAST_ICON 5

playervar heroEffectsIds

playervar revealed
playervar money__botStuckTimes
playervar moneyTotal__botOldPosition

playervar isInvisible
playervar isReady__isBotRespawning

playervar isHeroDescriptionOpened

# new barriers damage took and push logic
playervar barrierCheckVectA
playervar barrierCheckVectB
playervar barrierDamageStack
playervar isActiveBarrier

## hero state vars:
playervar I0
playervar heroState0
playervar heroState1
playervar heroState2
playervar heroState3
playervar heroState4
playervar heroState5
playervar heroState6
playervar abilityCD
