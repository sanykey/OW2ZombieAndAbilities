#!mainFile "main.opy"

rule "Create revive effects":
  for I in range(6):
    createEffect(getAllPlayers(), Effect.RING, Color.YELLOW, players_ressurect_positions_arr[I], 4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.RING, Color.WHITE, players_ressurect_positions_arr[I], getPlayersInSlot(0, Team.1).C, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "[Player Death Message]":
  @Event playerDied
  @Team 1
  
  players_ressurect_positions_arr[eventPlayer.getSlot()] = nearestWalkablePosition(eventPlayer)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, l"{0}!".format("is down and needs reviving")))
  E[eventPlayer.getSlot()] = true
  smallMessage(eventPlayer, "Please wait for a teammate to revive you or for all zombies to be slayed this round.")


rule "[Revive Player A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[0]) <= 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(0, Team.1)
  chaseOverTime(getPlayersInSlot(0, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(0, Team.1).teleport(eventPlayer)
  getPlayersInSlot(0, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.YELLOW, players_ressurect_positions_arr[0], 100)
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, getPlayersInSlot(0, Team.1), 10)
  players_ressurect_positions_arr[0] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(0, Team.1), null, 100000)
  getPlayersInSlot(0, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player A]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[0]) > 4
  @Condition eventPlayer != getPlayersInSlot(0, Team.1)
  
  getPlayersInSlot(0, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(0, Team.1).C)


rule "[Revive Player B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[1]) <= 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(1, Team.1)
  chaseOverTime(getPlayersInSlot(1, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(1, Team.1).teleport(eventPlayer)
  getPlayersInSlot(1, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, players_ressurect_positions_arr[1], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(1, Team.1), 100)
  players_ressurect_positions_arr[1] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(1, Team.1), null, 100000)
  getPlayersInSlot(1, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[1]) > 4
  @Condition eventPlayer != getPlayersInSlot(1, Team.1)
  
  getPlayersInSlot(1, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(1, Team.1).C)


rule "[Revive Player C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[2]) <= 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(2, Team.1)
  chaseOverTime(getPlayersInSlot(2, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(2, Team.1).teleport(eventPlayer)
  getPlayersInSlot(2, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, players_ressurect_positions_arr[2], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(2, Team.1), 100)
  players_ressurect_positions_arr[2] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(2, Team.1), null, 100000)
  getPlayersInSlot(2, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[2]) > 4
  @Condition eventPlayer != getPlayersInSlot(2, Team.1)
  
  getPlayersInSlot(2, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(2, Team.1).C)


rule "[Revive Player D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[3]) <= 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(3, Team.1)
  chaseOverTime(getPlayersInSlot(3, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(3, Team.1).teleport(eventPlayer)
  getPlayersInSlot(3, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.YELLOW, players_ressurect_positions_arr[3], 10)
  playEffect(getAllPlayers(), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(3, Team.1), 100)
  players_ressurect_positions_arr[3] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  getPlayers(Team.1).R = 0
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(3, Team.1), null, 100000)
  getPlayersInSlot(3, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[3]) > 4
  @Condition eventPlayer != getPlayersInSlot(3, Team.1)
  
  getPlayersInSlot(3, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(3, Team.1).C)


rule "[Revive Player E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[4]) <= 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(4, Team.1)
  chaseOverTime(getPlayersInSlot(4, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(4, Team.1).teleport(eventPlayer)
  getPlayersInSlot(4, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, players_ressurect_positions_arr[4], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(4, Team.1), 100)
  players_ressurect_positions_arr[4] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(4, Team.1), null, 100000)
  getPlayersInSlot(4, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[4]) > 4
  @Condition eventPlayer != getPlayersInSlot(4, Team.1)
  
  getPlayersInSlot(4, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(4, Team.1).C)


rule "[Revive Player F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[5]) <= 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  @Condition eventPlayer.isAlive() == true
  
  eventPlayer.C = getPlayersInSlot(5, Team.1)
  chaseOverTime(getPlayersInSlot(5, Team.1).C, 4, 2 + player_ressurect_time_mult * 2)
  wait(2 + player_ressurect_time_mult * 2, Wait.ABORT_WHEN_FALSE)
  getPlayersInSlot(5, Team.1).teleport(eventPlayer)
  getPlayersInSlot(5, Team.1).resurrect()
  player_ressurect_time_mult += 1
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION, Color.YELLOW, players_ressurect_positions_arr[5], 10)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_EXPLOSION_SOUND, Color.WHITE, getPlayersInSlot(5, Team.1), 100)
  players_ressurect_positions_arr[5] = hidden_vector
  eventPlayer.money += 100 * eventPlayer.H
  smallMessage(eventPlayer, l"{0} + {1}".format(l"", l"{0} {1}".format(100 * eventPlayer.H, l"Points")))
  R += 100 * eventPlayer.H
  heal(getPlayersInSlot(5, Team.1), null, 100000)
  getPlayersInSlot(5, Team.1).startHealingOverTime(eventPlayer, 30, 150)


rule "[Cancel Revive Player F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, players_ressurect_positions_arr[5]) > 4
  @Condition eventPlayer != getPlayersInSlot(5, Team.1)
  
  getPlayersInSlot(5, Team.1).C = 0
  stopChasingVariable(getPlayersInSlot(5, Team.1).C)


rule "[Player Respawn & Move Revive]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() == true
  
  players_ressurect_positions_arr[eventPlayer.getSlot()] = hidden_vector