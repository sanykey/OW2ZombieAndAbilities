#!mainFile "main.opy"
#####################################################
################ Global variables ###################
#####################################################
globalvar botsHealthBoostPercent
globalvar botsDamageBoostPercent

# Loop vars for creating last zombies icons:
globalvar lastZombiesList
globalvar lastZombiesI

globalvar lastZombiesIcons # Save here the IDs of created icons, so that you can delete icons in case Dummy bots will be deleted.

globalvar createDummyI

globalvar botWidowmakerRespawnTime
globalvar botEchoRespawnTime
globalvar roundNumber = 0

globalvar zombiesflyIOnandOff
globalvar teamShields
globalvar teamArmor
globalvar heroesShopData
globalvar matchIsOver = false
globalvar unlockedLocations = 0
globalvar orbs_arr
globalvar hiddenVector = vect(500, 25, 500)
globalvar roundRemainingBots = 0
globalvar orbs_vectors_arr
globalvar vipPlayers # List of players who received special privileges
globalvar isBotsDisabled
globalvar vectList
globalvar lockedAreaEffectsArr
globalvar shopState
globalvar teamScore
globalvar temp1
globalvar temp2
globalvar temp3
globalvar zombieStats
globalvar heroesList
globalvar zombieRespawnI
globalvar isGameStarted = false
globalvar isDebugAutoRespawn # auto respawn for debug
globalvar highloadServerPause


globalvar spawnPointsList = []
globalvar spawnPI

globalvar botSniperPositions
globalvar delayerStartHudId

# [Bot fake death]:
globalvar botsDeathPlaceIcons

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

# detecting turrents and Bob damage for Bot fake death
globalvar turretsDamageOwners
globalvar turretsDamageOwnersTime
globalvar turretsVictimZombies
globalvar turretsI
globalvar turretsJ
globalvar turretsK

##################################################
############## Player variables: #################
##################################################
playervar healthBoostPercent
playervar damageBoostPercent
playervar healingBoostPercent

playervar interactZoneVect
playervar interactZoneText
playervar interactZoneEffect

playervar defensiveAssistsStat
playervar damageBlockedStat
playervar damageTakenStat
playervar damageDealtStat
playervar deathsStat
playervar zombiesfly
playervar orb_roll # current orb drop chance when a bot dies
playervar isInSecretShop
playervar state # use with enum "SI"

playervar revivers
playervar reviveTimer
playervar downedStartTime # die state for players and zombie bots

playervar recentStackedHealingDealtToSlot
playervar healingTracker
playervar recentHealingDealtToSlot
playervar recentDamageDealtToSlot
playervar recentStackedDamageDealtToSlot

playervar damageAssitsToSlot
playervar posBeforeChangeHero
playervar purchasedHeroes
playervar playerListHudId

# Hero Info:
playervar heroInfoText0
playervar heroInfoVertFix0
playervar heroInfoHorFix0
playervar heroInfoText1
playervar heroInfoVertFix1
playervar heroInfoHorFix1

# [Bot fake death]:
playervar kills # kills zombies stat for players 
playervar lastKillTime # for kill icon near scope
#   detecting turrents and Bob damage for Bot fake death
playervar lastDamageDealtAmount
playervar lastDamageDealtTime
playervar expectedHealth
playervar turretDamageTimeToSlot

# detecting crowd control abilities for bots fall damage
playervar lastCcAttacker
playervar lastCcAttackTime
playervar lastCcWasInAir

playervar HUDs
playervar hasBadStatus
playervar revealed
playervar widowmakerChargeShot
playervar money
playervar raycast
playervar heroState
playervar abilTemp1 # temp var use for loops with "wait" per hero
playervar isInvisible
playervar isReady

playervar isDvaUltBought
playervar lastZombieIcon

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



## for juno rift ability:
playervar juno_last_rift
playervar juno_rift2_placement
playervar juno_rift2_fx
playervar juno_rift2_destination
playervar juno_rift1_placement
playervar juno_rift1_fx
playervar juno_rift1_destination
playervar juno_rift2_active
playervar juno_rift1_active
playervar juno_rift
playervar juno_hyper_hud
playervar juno_rift_icon

## for juno rift ability:
playervar juno_transfer_pos
playervar juno_transfer_from
playervar juno_transfer_to
playervar juno_transfer_fx
playervar juno_transfer_started

# vanilla hero constants
#!define TORBJORN_HAMMER_BASE_DMG 70

# Zombie settings
#!define ZOMBIE_SPEED 80
#!define ZOMBIE_FALL_DAMAGE 200
#!define ZOMBIE_BASE_DAMAGE 20
#!define ZOMBIE_BASE_HP 100
#!define ZOMBIE_BASE_MOVE_SPEED 70
#!define BOT_MAX_INACTIVITY_DURATION 60
#!define LAST_CC_ATTACK_DURATION 5

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

# Money:
#!define MONEY_FOR_REVIVE 400
#!define MONEY_FOR_ZOMBIE_KILL 300
#!define MONEY_FOR_ZOMBIE_CRITICAL 375
#!define MONEY_FOR_HEALING 100
#!define HEAL_AMOUNT_FOR_MONEY 200
# [Sombra] Money:
#!define MONEY_FOR_KILL_HACKED 30
#!define MONEY_FOR_KILL_HACKED_TEAM 10
#!define SOMBRA_STEAL_MONEY 25

# Hud:
#!define HERO_INFO_HOLD_DURATION 0.5
#!define ABILITI_TEXT_INTEND "\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000"
#!define ABILITI_CHARGES_INTEND "\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000"

# Other:
#!define INFINITY 99999
#!define ALLY_BOT_PLAYER_SLOT 7


enum SI:
  CAMERA_3P = 0 # number
  # 0: OFF
  # 1: Temporary OFF
  # 2: Temporary OFF higher angle
  # 3: ON
  # 4: ON higher angle
  CAMERA_3P_PREV # like as CAMERA_3P
  HEALING_TRACKER
  HEALING_TRACKER_THRESHOLD
  HEALING_RESULT
  WIDOWMAKER_SHOT_CHARGE
  IS_TALENTS_HUD_OPENNED
  HACKED # hacked status to get money from killed hacked zombies
  MONEY_RECEIVED # money received
  HP_STAT
  DAMAGE_STAT
  HEALING_STAT
  LAST_DAMAGE_TIME
  START_AUTO_HEAL_TIME
  IS_INVISIBLE

  BARRIER_DAMAGE_FROM
  BARRIER_DAMAGE_DIR
  BARRIER_DAMAGE_STACK
  BARRIER_ACTIVE
  CHANGED_SPEED_TIME
  CHANGED_SPEED_AMOUNT
  CHANGED_SPEED_AMOUNT_PREV
  LOW_GRAVITY

  HERO_INFO_TEXT
  HERO_INFO_VERTICAL_FIX
  HERO_INFO_HORIZONTAL_FIX
  
  HERO_INFO_TEXT2
  HERO_INFO_VERTICAL_FIX2
  HERO_INFO_HORIZONTAL_FIX2

# for playervar talents
enum TI:
  WIDOWMAKER_PARTY_FAMOURS = 0
  WIDOWMAKER_FALLING_STARS = 1
  WIDOWMAKER_SILK_WEB = 2
  WIDOWMAKER_FELT_MORE_ALIVE = 3
  WIDOWMAKER_BRAISER_DE_SOIE = 4
  WIDOWMAKER_PHANTOM_BULLETS = 5
  WIDOWMAKER_TRACKER_VENOM = 6

# for playervar HUDs
enum HI:
  REVEALED_ICON
  WALLHACK_HEADSHOT_ZONE
  WALLHACK_SHOT
  WIDOWMAKER_PHANTOM_BULLET_HIT
  WIDOWMAKER_PARTY_FAMOURS
  WIDOWMAKER_PHANTOM_BULLET_CHARGE
  DEBUG
  DEBUG2
  DEBUG3
  DEBUG4
  DEBUG5

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

enum ZI: # for globalvar zombieStats
  DAMAGE_STAT
  HP_STAT
  ZOMBIE_RESPAWN_I