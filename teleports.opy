#!mainFile "main.opy"

rule "[Teleport Area A]":
  @Condition newLine == 1
  
  U = []
  U.append(vect(13.044, 9.697, -73.344))
  U.append(vect(52.662, 9.768, -31.962))
  U.append(vect(59.416, 19.498, -77.513))
  U.append(vect(95.991, 12.171, -38.315))
  U.append(vect(104.593, 16, -22.372))
  U.append(vect(89.614, 18, -19.296))


rule "[Teleport Area B]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[0]) < 35
  @Condition C == 0
  
  eventPlayer.teleport(vect(13.466, 4.35, -34.792))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "[Teleport Area C]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[1]) < 15
  @Condition C == 0
  
  eventPlayer.teleport(vect(27.294, 6.507, -25.489))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "[Teleport Area D]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[2]) < 30
  @Condition C == 1
  
  eventPlayer.teleport(vect(25.171, 6.554, -64.938))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "[Teleport Area E]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[3]) < 25
  @Condition C == 2
  
  eventPlayer.teleport(vect(76.454, 14.112, -65.339))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "[Teleport Area F]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[4]) < 4
  @Condition D == 0
  
  eventPlayer.teleport(vect(106.979, 12.171, -37.458))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START


rule "[Teleport Area G]":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, U[5]) < 4
  @Condition D == 0
  
  eventPlayer.teleport(vect(86.536, 14.171, -37.365))
  wait(1)
  if RULE_CONDITION:
      goto RULE_START