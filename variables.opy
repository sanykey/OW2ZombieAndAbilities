#!mainFile "main.opy"
#Global variables

globalvar roundNumber 0
globalvar zombiesflyIOnandOff 26
globalvar team_shields 30
globalvar team_armor 31
globalvar heroes_shop_data 32
globalvar match_is_over 33
globalvar unlockedLocations 34
globalvar orbs_arr = 35
globalvar hidden_vector = 36
globalvar player_ressurect_time_mult = 37 # resurrect time multiplier, which increases after each resurrect, but resets to zero at the start of each round
globalvar players_ressurect_positions_arr = 38 # Array of vectors of places where you can resurrect a dead player
globalvar round_remaining_bots = 39
globalvar orbs_vectors_arr = 40
globalvar is_round_end = 41
globalvar vips = 43
globalvar isBotsDisabled = 45

globalvar debugVectsArr = 46
globalvar debugCurrentVectNum = 47
globalvar debugCurrentVectEffectArr = 48
globalvar vectList = 51
globalvar lockedAreaEffectsArr = 52
globalvar shopState = 53

#Player variables

playervar money 0
playervar healing_tracker 1
playervar health_stat 10
playervar damage_stat 11
playervar healing_stat 12
playervar zombiesfly 26
playervar orb_roll 27 # current orb drop chance when a bot dies
playervar isInSecretShop 28

# todo: use enum?
# 0: 3p camera status, number
#   0: OFF
#   1: Temporary OFF
#   2: Temporary OFF higher angle
#   3: ON
#   4: ON higher angle
# 1: 3p prev status, number
playervar state_arr 29
playervar recentDamageDealtToSlot 30

#Activated extensions
#!extension explosionSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots