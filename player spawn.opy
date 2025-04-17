#!mainFile "main.opy"

rule "[Upgrade Stats Setup]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.hasSpawned() == true
  @Condition eventPlayer.health_stat == 0
  
  eventPlayer.health_stat = 100
  eventPlayer.damage_stat = 100
  eventPlayer.healing_stat = 100

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


rule "[Spawn Points Array A]":
  @Condition distance(vect(-6.965, 2.94, -7.146), getClosestPlayer(vect(-6.965, 2.94, -7.146), Team.1)) <= 48
  
  Y.append(vect(14.282, 26.122, -19.096))
  Y.append(vect(-25.084, 25.057, -28.765))
  Y.append(vect(-2.267, 19.938, -41.17))
  Y.append(vect(5.665, 17.621, 2.067))
  Y.append(vect(16.374, 13.098, -40.81))


rule "[Spawn Points Array A-]":
  @Condition distance(vect(-6.965, 2.94, -7.146), getClosestPlayer(vect(-6.965, 2.294, -7.146), Team.1)) > 48
  
  Y.remove(vect(14.282, 26.122, -19.096))
  Y.remove(vect(-25.084, 25.057, -28.765))
  Y.remove(vect(-2.267, 19.938, -41.17))
  Y.remove(vect(5.665, 17.621, 2.067))
  Y.remove(vect(16.374, 13.098, -40.81))


rule "[Spawn Points Array B]":
  @Condition distance(vect(13.044, 9.697, -73.344), getClosestPlayer(vect(13.044, 9.797, -73.344), Team.1)) <= 35
  
  Y.append(vect(15.598, 30.551, -60.258))
  Y.append(vect(-6.03, 18.558, -47.35))
  Y.append(vect(11.556, 20.229, -87.682))
  Y.append(vect(-5.797, 12.818, -90.005))
  Y.append(vect(9.321, 17.186, -40.356))
  Y.append(vect(29.662, 26.681, -74.951))
  Y.append(vect(38.069, 13.312, -50.538))
  Y.append(vect(19.593, 10.464, -98.064))


rule "[Spawn Points Array B-]":
  @Condition distance(vect(13.044, 9.697, -73.344), getClosestPlayer(vect(13.044, 9.697, -73.344), Team.1)) > 35
  
  Y.remove(vect(15.598, 30.551, -60.258))
  Y.remove(vect(-6.03, 18.558, -47.35))
  Y.remove(vect(11.556, 20.229, -87.682))
  Y.remove(vect(-5.797, 12.818, -90.005))
  Y.remove(vect(9.321, 17.186, -40.356))
  Y.remove(vect(29.662, 26.681, -74.951))
  Y.remove(vect(38.069, 13.312, -50.538))
  Y.remove(vect(19.593, 10.464, -98.064))


rule "[Spawn Points Array C]":
  @Condition distance(vect(-22.86, 8.08, -88.854), getClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) <= 15
  @Condition D == 1
  
  Y.append(vect(74.194, 17.928, -49.807))


rule "[Spawn Points Array C-]":
  @Condition distance(vect(-22.86, 8.08, -88.854), getClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) > 15
  @Condition D == 1
  
  Y.remove(vect(74.194, 17.928, -49.807))


rule "[Spawn Points Array D]":
  @Condition distance(vect(59.416, 19.498, -77.513), getClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) <= 30
  
  Y.append(vect(60.556, 9.729, -92.999))
  Y.append(vect(57.692, 14.745, -78.916))
  Y.append(vect(37.146, 27.607, -58.074))
  Y.append(vect(94.023, 34.402, -65.749))
  Y.append(vect(29.377, 19.108, -81.452))
  Y.append(vect(36.546, 14.432, -106.335))
  Y.append(vect(60.876, 8.672, -74.696))


rule "[Spawn Points Array D-]":
  @Condition distance(vect(59.416, 19.498, -77.513), getClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) > 30
  
  Y.remove(vect(60.556, 9.729, -92.999))
  Y.remove(vect(57.692, 14.745, -78.916))
  Y.remove(vect(37.146, 27.607, -58.074))
  Y.remove(vect(94.023, 34.402, -65.749))
  Y.remove(vect(29.377, 19.108, -81.452))
  Y.remove(vect(36.546, 14.432, -106.335))
  Y.remove(vect(60.876, 8.672, -74.696))


rule "[Spawn Points Array E]":
  @Condition distance(vect(75.315, 22.594, -101.637), getClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) <= 50
  
  Y.append(vect(94.023, 34.402, -65.749))
  Y.append(vect(74.277, 14.12, -110.609))
  Y.append(vect(90.938, 30.988, -109.069))
  Y.append(vect(57.687, 21.96, -76.518))
  Y.append(vect(63.86, 16.823, -100.725))


rule "[Spawn Points Array E-]":
  @Condition distance(vect(75.315, 22.594, -101.637), getClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) > 50
  
  Y.remove(vect(94.023, 34.402, -65.749))
  Y.remove(vect(74.277, 14.12, -110.609))
  Y.remove(vect(90.938, 30.988, -109.069))
  Y.remove(vect(57.687, 21.96, -76.518))
  Y.remove(vect(63.86, 16.823, -100.725))


rule "[Spawn Points Array F]":
  @Condition distance(vect(108.196, 14.309, -22.096), getClosestPlayer(vect(108.196, 14.299, -22.094), Team.1)) <= 45
  
  Y.append(vect(74.194, 17.928, -49.807))
  Y.append(vect(124.358, 23.829, -26.451))
  Y.append(vect(97.865, 22.892, -42.244))
  Y.append(vect(128.632, 23.521, -7.378))
  Y.append(vect(122.998, 16.026, -66.952))
  Y.append(vect(142.909, 17.319, -45))


rule "[Spawn Points Array F-]":
  @Condition distance(vect(108.195, 14.3, -22.094), getClosestPlayer(vect(108.196, 14.309, -22.096), Team.1)) > 45
  
  Y.remove(vect(74.194, 17.928, -49.807))
  Y.remove(vect(124.358, 23.829, -26.451))
  Y.remove(vect(97.865, 22.892, -42.244))
  Y.remove(vect(128.632, 23.521, -7.378))
  Y.remove(vect(122.998, 16.026, -66.952))
  Y.remove(vect(142.909, 17.319, -45))


rule "[Spawn Points Array G]":
  @Condition distance(vect(140.011, 12.178, -61.257), getClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) <= 15
  
  Y.append(vect(74.194, 17, -49.807))
  Y.append(vect(124.358, 23, -26.451))
  Y.append(vect(97.865, 22, -42.244))
  Y.append(vect(128.632, 23, -7.378))
  Y.append(vect(122.998, 16, -66.952))
  Y.append(vect(142.909, 17, -45))


rule "[Spawn Points Array G-]":
  @Condition distance(vect(140.011, 12.178, -61.257), getClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) > 15
  
  Y.remove(vect(74.194, 17, -49.807))
  Y.remove(vect(124.358, 23, -26.451))
  Y.remove(vect(97.865, 22, -42.244))
  Y.remove(vect(128.632, 23, -7.378))
  Y.remove(vect(122.998, 16, -66.952))
  Y.remove(vect(142.909, 17, -45))