#!mainFile "../main.opy"
#####################################################
################ Global variables ###################
#####################################################

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
globalvar lastZombiesIcons # Save here the IDs of created icons, so that you can delete icons in case Dummy bots will be deleted.
globalvar createDummyI
globalvar botWidowmakerRespawnTime
globalvar botEchoRespawnTime
globalvar botsHealthBoostPercent
globalvar botsDamageBoostPercent

globalvar zombieRespI
globalvar zombieRespawnList

globalvar zombiesflyIOnandOff
globalvar zombieStats
enum ZI:
  DAMAGE_STAT
  HP_STAT
  ZOMBIE_RESPAWN_I

## Loop vars for creating last zombies icons:
globalvar lastZombiesList
globalvar lastZombiesI

globalvar teamShields
globalvar teamArmor
globalvar matchIsOver = false
globalvar unlockedLocations = 0
globalvar roundRemainingBots = 0

globalvar isBotsDisabled

globalvar lockedAreaEffectsArr

globalvar teamScore
globalvar temp1
globalvar temp2
globalvar temp3

globalvar isGameStarted = false
globalvar isDebugAutoRespawn # auto respawn for debug
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
globalvar debugIsNoclip
globalvar debugPos1
globalvar debugPos2
globalvar debugPos3
globalvar debugSize3 = 1

##################################################
############## Player variables: #################
##################################################
playervar interactZoneVect
playervar interactZoneText
playervar interactZoneEffect

playervar zombiesfly

playervar isInSecretShop
playervar state # use with enum "SI"

playervar developer
playervar revivers
playervar reviveTimer
playervar downedStartTime # die state for players and zombie bots
playervar isZombieReadyToRespawn
playervar isHacked

playervar recentStackedHealingDealtToSlot
playervar recentHealingDealtToSlot
playervar recentDamageDealtToSlot
playervar recentStackedDamageDealtToSlot

playervar posBeforeChangeHero

# detecting crowd control abilities for bots fall damage
playervar lastCcAttacker
playervar lastCcAttackTime
playervar lastCcWasInAir

playervar isDvaUltBought
playervar purchasedHeroes
playervar healthBoostPercent
playervar damageBoostPercent
playervar healingBoostPercent
playervar damageResistPercent

#!define HEAL_AMOUNT_FOR_MONEY 200
playervar healingTrackerThreshold = HEAL_AMOUNT_FOR_MONEY

# effects ids
playervar effectsIds
enum HI:
  REVEALED_ICON
  PLAYER_STATUS
  REVIVE_EFFECT
  REVIVE_ICON
  DEBUG
  DEBUG2
  DEBUG3
  DEBUG4
  DEBUG5

playervar heroEffectsIds

playervar hasBadStatus
playervar revealed
playervar money
playervar raycast

playervar abilTemp1 # temp var use for loops with "wait" per hero
playervar isInvisible
playervar isReady

playervar lastZombieIcon

playervar isHeroDescriptionOpened

# new barriers damage took and push logic
globalvar barrierPushVectUpFix = vect(0, 0.2679, 0) # When pushing characters horizontally, we add a bit of upward displacement so that the pushing is not hindered by the floor
playervar barrierDamageFrom
playervar barrierDamageDir
playervar barrierDamageStack
playervar isActiveBarrier

## Temporal variables used for calculations. Should be used briefly, without Wait and other asynchronous code
playervar temp0
playervar temp1
playervar temp2
playervar temp3
playervar temp4
playervar temp5
playervar list0
playervar list1
playervar list2

## hero state vars:
playervar abilPos0
playervar abilPos1
playervar abilPos2
playervar abilPos3
playervar abilPos4
playervar abilState0
playervar abilState1
playervar abilState2
playervar abilState3
playervar abilDir0
playervar abilDir1
playervar abilDir2
playervar abilDir3
playervar targetPlayer0
playervar targetPlayer1
playervar abilityCD

#!define ULT_CHARGE_FOR_KILL 5
#!define EMOTE_ULT_CHARE_PER_SECONDS 1
#!define DAMAGE_RESISTANCE_BY_OWNED_HERO 0.349

# vanilla hero constants
#!define TORBJORN_HAMMER_BASE_DMG 70

# Zombie settings
#!define ZOMBIE_SPEED 80
#!define ZOMBIE_FALL_DAMAGE 250
#!define ZOMBIE_BASE_DAMAGE 20
#!define ZOMBIE_BASE_HP 50
#!define ZOMBIE_BASE_MOVE_SPEED 70
#!define BOT_MAX_INACTIVITY_DURATION 60
#!define LAST_CC_ATTACK_DURATION 5

# [Bot fake death]
#!define BOT_FAKE_DIE_HP_THRESHOLD 10

# Player settings
#!define MAX_PLAYERS 5
#!define REVIVE_TIMER_TICK 5
#!define AUTO_HEALING_OVERTIME_DURATION 20
#!define REVEAL_DURATION 10
#!define PLAYER_SPEED 100

# [Widowmaker] hitbox position for wallhack shots
#!define ZOMBIE_BODY_HITBOX_RADIUS 0.65
#!define ZOMBIE_HEAD_HITBOX_RADIUS 0.15
#!define WALLHACK_SHOT_IN_VIEW_ANGLE 4

# [Sombra] Money:
#!define SOMBRA_STEAL_MONEY 25

# HUD
#!define HERO_INFO_HOLD_DURATION 0.5

# Other:
#!define INFINITY 99999
#!define ALLY_BOT_PLAYER_SLOT 7

enum SI:
  HACKED # hacked status to get money from killed hacked zombies
  LAST_DAMAGE_TIME
  START_AUTO_HEAL_TIME
  IS_INVISIBLE
  CHANGED_SPEED_TIME
  CHANGED_SPEED_AMOUNT
  CHANGED_SPEED_AMOUNT_PREV
  LOW_GRAVITY

# for [Widowmaker] wallhack calculation
enum RI:
  A
  B
  C
  DISC
  XPXS
  YPYS
  ZPYS
  RADIUS
  SPHERE_POS
  FACING_DIRECTION
  RESULT
  SQRT_RESULT
  T1
  T2