#!mainFile "main.opy"
#Global variables

globalvar roundNumber
globalvar zombiesflyIOnandOff
globalvar team_shields
globalvar team_armor
globalvar heroesShopData
globalvar matchIsOver
globalvar unlockedLocations
globalvar orbs_arr
globalvar hiddenVector
globalvar roundRemainingBots
globalvar orbs_vectors_arr
globalvar isRoundEnd
globalvar vips
globalvar isBotsDisabled
globalvar debugVectsArr
globalvar debugCurrentVectNum
globalvar debugCurrentVectEffectArr
globalvar vectList
globalvar lockedAreaEffectsArr
globalvar shopState
globalvar teamScore
globalvar temp1
globalvar temp2
globalvar zombieStats
globalvar heroesList
globalvar zombieRespawnI
globalvar isGameStarted
globalvar isDebugAutoRespawn # auto respawn for debug

#Player variables
playervar healthStat
playervar damageStat
playervar healingStat
playervar zombiesfly
playervar orb_roll # current orb drop chance when a bot dies
playervar isInSecretShop
playervar state # use with enum "SI"

playervar revivers
playervar reviveTimer
playervar downedStartTime

playervar isTargetInLos

playervar recentStackedHealingDealtToSlot
playervar healingTracker
playervar recentHealingDealtToSlot
playervar recentDamageDealtToSlot
playervar recentStackedDamageDealtToSlot
playervar damageAssitsToSlot

playervar deathCamTarget
playervar targetPlayer
playervar talents
playervar HUDs
playervar temp1
playervar temp2
playervar temp3
playervar temp4
playervar temp5
playervar revealed
playervar widowmakerChargeShot
playervar money
playervar raycast
playervar heroState
playervar abilTemp1 # temp var use for loops with "wait" per hero
playervar abilityProjectile
playervar abilityCD

playervar abilPos0
playervar abilPos1
playervar abilPos2
playervar abilPos3
playervar abilPos4

playervar abilDir0
playervar abilDir1
playervar abilDir2
playervar abilDir3
playervar list
playervar list2
playervar list3

#!define INFINITY 99999
#!define MONEY_FOR_REVIVE 300
#!define MONEY_FOR_ZOMBIE_KILL 200
#!define MONEY_FOR_ZOMBIE_CRITICAL 275
#!define MONEY_FOR_HEALING 100
#!define HEAL_AMOUNT_FOR_MONEY 200
#!define MAX_PLAYERS 5
#!define MAX_ZOMBIES 8
#!define ALLY_BOT_PLAYER_SLOT 7
#!define REVIVE_TIMER_TICK 5
#!define ZOMBIE_BASE_MOVE_SPEED 70
#!define ZOMBIE_BODY_HITBOX_RADIUS 0.65
#!define ZOMBIE_HEAD_HITBOX_RADIUS 0.15
#!define WALLHACK_SHOT_IN_VIEW_ANGLE 4
#!define ZOMBIE_FALL_DAMAGE 100
#!define AUTO_HEALING_OVERTIME_DURATION 20
#!define REVEAL_DURATION 10
#!define ZOMBIE_SPEED 80
#!define HERO_INFO_HOLD_DURATION 0.5
#!define LAST_CC_ATTACK_DURATION 5

# vanilla hero constants
#!define WINSTON_BARRIER_HP 650
#!define TORBJORN_HAMMER_BASE_DMG 70

# Sombra
#!define MONEY_FOR_KILL_HACKED 30
#!define MONEY_FOR_KILL_HACKED_TEAM 10
#!define SOMBRA_STEAL_MONEY 25

#!define ABILITI_TEXT_INTEND "                                                                                             "
enum SI:
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
  WIDOWMAKER_SHOT_CHARGE = 5
  IS_TALENTS_HUD_OPENNED = 6
  TALENTS_COUNT = 7
  LAST_CC_ATTACKER = 8
  LAST_CC_ATTACK_TIME = 9
  LAST_CC_WAS_IN_AIR = 10
  HACKED = 11 # hacked status to get money from killed hacked zombies
  MONEY_RECEIVED = 12 # money received
  HP_STAT = 13
  DAMAGE_STAT = 14
  HEALING_STAT = 15
  LAST_DAMAGE_TIME = 16
  START_AUTO_HEAL_TIME = 17
  IS_INVISIBLE = 18
  HERO_INFO_TEXT = 19
  HERO_INFO_VERTICAL_FIX = 20
  BARRIER_DAMAGE_FROM = 21
  BARRIER_DAMAGE_DIR = 22
  BARRIER_DAMAGE_STACK = 23
  BARRIER_ACTIVE = 24
  CHANGED_SPEED_TIME = 25
  CHANGED_SPEED_AMOUNT = 26
  CHANGED_SPEED_AMOUNT_PREV = 27

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
  REVEALED_ICON = 0
  WALLHACK_HEADSHOT_ZONE = 1
  WALLHACK_SHOT = 2
  PLAYER_LIST_STATUS_TEXT = 8
  WIDOWMAKER_PHANTOM_BULLET_HIT = 9
  WIDOWMAKER_PARTY_FAMOURS = 10
  WIDOWMAKER_PHANTOM_BULLET_CHARGE = 11
  DEBUG = 3
  DEBUG2 = 4
  DEBUG3 = 5
  DEBUG4 = 6
  DEBUG5 = 7

enum RI:
  A = 1
  B = 2
  C = 3
  DISC = 4
  XPXS = 5
  YPYS - 6
  ZPYS - 7
  RADIUS = 8
  SPHERE_POS = 9
  FACING_DIRECTION = 10
  RESULT = 11
  SQRT_RESULT = 12
  T1 = 13
  T2 = 14

enum ZI: # for globalvar zombieStats
  DAMAGE_STAT = 0
  HP_STAT = 1
  ZOMBIE_RESPAWN_I = 2