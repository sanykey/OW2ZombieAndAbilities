#!mainFile "main.opy"
#Global variables

globalvar roundNumber 0
globalvar zombiesflyIOnandOff 26
globalvar team_shields 30
globalvar team_armor 31
globalvar heroes_shop_data 32
globalvar match_is_over 33
globalvar unlocked_locations 34
globalvar orbs_arr = 35
globalvar hidden_vector = 36
globalvar player_ressurect_time_mult = 37 # resurrect time multiplier, which increases after each resurrect, but resets to zero at the start of each round
globalvar players_ressurect_positions_arr = 38 # Array of vectors of places where you can resurrect a dead player
globalvar round_remaining_bots = 39
globalvar orbs_vectors_arr = 40
globalvar is_round_end = 41

#Player variables

playervar money 0
playervar healing_tracker 1
playervar health_stat 10
playervar damage_stat 11
playervar healing_stat 12
playervar zombiesfly 26
playervar orb_roll 27 # current orb drop chance when a bot dies

#Activated extensions
#!extension explosionSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots