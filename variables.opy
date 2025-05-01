#!mainFile "main.opy"
#Global variables

globalvar roundNumber 0
globalvar zombiesflyIOnandOff 26
globalvar team_shields 30
globalvar team_armor 31
globalvar heroesShopData 32
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
globalvar zombieStats 59
globalvar heroesList 60
globalvar zombieRespawnI 61

#Player variables


playervar healthStat 10
playervar damageStat 11
playervar healingStat 12
playervar zombiesfly 26
playervar orb_roll 27 # current orb drop chance when a bot dies
playervar isInSecretShop 28

playervar state 30 # use with enum "SI"
playervar reviveProgress 31
playervar isTargetInLos 32
playervar recentStackedHealingDealtToSlot 33
playervar healingTracker 34
playervar recentHealingDealtToSlot 35

playervar recentDamageDealtToSlot 29
playervar recentStackedDamageDealtToSlot 36
playervar damageAssitsToSlot 58

playervar downedStartTime 37
playervar reviveTimer 38
playervar deathCamTarget 39
playervar isCombatant 40
playervar revivers 41
playervar targetPlayer 42
playervar talents 43
playervar HUDs 46
playervar temp1 47
playervar temp2 52
playervar temp3 54
playervar revealed 49
playervar widowmakerChargeShot 50
playervar money 51
playervar raycast 53
playervar talentState 55
playervar talentText 56
playervar abilityTemp1 57 # temp var use for loops with "wait" per hero
playervar abilityCD 59

#Activated extensions
#!extension explosionSounds
#!extension kineticExplosionEffects
#!extension playMoreEffects
#!extension spawnMoreDummyBots
#!extension projectiles

# for DVA's Slide ability
#!extension buffStatusEffects
#!extension buffAndDebuffSounds

#!setupTags

#!define INFINITY 99999
#!define MONEY_FOR_REVIVE 300
#!define MONEY_FOR_ZOMBIE_KILL 200
#!define MONEY_FOR_ZOMBIE_CRITICAL 275
#!define MONEY_FOR_HEALING 100
#!define HEAL_AMOUNT_FOR_MONEY 200
#!define MAX_PLAYERS 6
#!define MAX_ZOMBIES 12
#!define ALLY_BOT_PLAYER_SLOT 7
#!define REVIVE_TIMER_TICK 5
#!define ZOMBIE_BASE_MOVE_SPEED 70
#!define ZOMBIE_BODY_HITBOX_RADIUS 0.65
#!define ZOMBIE_HEAD_HITBOX_RADIUS 0.15
#!define WALLHACK_SHOT_IN_VIEW_ANGLE 4
#!define ZOMBIE_FALL_DAMAGE 100
#!define AUTO_HEALING_OVERTIME_DURATION 20

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
  HACKED = 11 # status to get money from killed hacked zombies
  MONEY_RECEIVED = 12 # money received
  HP_STAT = 13
  DAMAGE_STAT = 14
  HEALING_STAT = 15
  LAST_DAMAGE_TIME = 16
  START_AUTO_HEAL_TIME = 17

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
  SPEED_STAT = 0
  DAMAGE_STAT = 1
  HP_STAT = 2
  ZOMBIE_RESPAWN_I = 3