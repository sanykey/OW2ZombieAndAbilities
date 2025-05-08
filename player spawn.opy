#!mainFile "main.opy"

rule "[TP Spawn Room Debug]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(101.397, 14.21, -110.834)) < 14
  
  wait(0.5)
  if not RULE_CONDITION:
      return
  eventPlayer.teleport(vect(-27.412, 2, -12.564))
  eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), vect(-12.858, 3.32, -17.254)), 100000)
  wait(0.1)
  eventPlayer.stopFacing()

rule "[Anti-Spawn Check B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3
  
  eventPlayer.teleport(vect(79.382, 13.147, -110.093))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START


rule "[Anti-Spawn Check C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2
  
  eventPlayer.teleport(vect(86.903, 14.219, -101.238))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START


rule "[Anti-Spawn Check D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(97.65, 11.233, -30.593)) < 3
  
  eventPlayer.teleport(vect(96.475, 12.392, -35.419))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START


rule "[Anti-Spawn Check E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(103.937, 11.178, -30.358)) < 2
  
  eventPlayer.teleport(vect(107.719, 11.178, -33.024))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START


rule "[Anti-Spawn Check F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(113.037, 12.696, -10.145)) < 3
  
  eventPlayer.teleport(vect(113.894, 11.178, -15.333))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START


rule "[Anti-Spawn Check G]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(140.251, 12.481, -17.63)) < 3
  
  eventPlayer.teleport(vect(133.957, 12.363, -18.225))
  wait(2, Wait.ABORT_WHEN_FALSE)
  goto RULE_START
