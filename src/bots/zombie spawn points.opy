#!mainFile "../main.opy"

rule "Bots spawn points array A":
  @Condition distance(vect(-6.965, 2.94, -7.146), getRealClosestPlayer(vect(-6.965, 2.94, -7.146), Team.1)) <= 48
  
  spawnPointsList.append(vect(14.282, 26.122, -19.096))
  spawnPointsList.append(vect(-25.084, 25.057, -28.765))
  spawnPointsList.append(vect(-2.267, 19.938, -41.17))
  spawnPointsList.append(vect(5.665, 17.621, 2.067))
  spawnPointsList.append(vect(16.374, 13.098, -40.81))


rule "Bots spawn points array A-":
  @Condition distance(vect(-6.965, 2.94, -7.146), getRealClosestPlayer(vect(-6.965, 2.294, -7.146), Team.1)) > 48
  
  spawnPointsList.remove(vect(14.282, 26.122, -19.096))
  spawnPointsList.remove(vect(-25.084, 25.057, -28.765))
  spawnPointsList.remove(vect(-2.267, 19.938, -41.17))
  spawnPointsList.remove(vect(5.665, 17.621, 2.067))
  spawnPointsList.remove(vect(16.374, 13.098, -40.81))


rule "Bots spawn points array B":
  @Condition distance(vect(13.044, 9.697, -73.344), getRealClosestPlayer(vect(13.044, 9.797, -73.344), Team.1)) <= 35
  
  spawnPointsList.append(vect(15.598, 30.551, -60.258))
  spawnPointsList.append(vect(-6.03, 18.558, -47.35))
  spawnPointsList.append(vect(11.556, 20.229, -87.682))
  spawnPointsList.append(vect(-5.797, 12.818, -90.005))
  spawnPointsList.append(vect(9.321, 17.186, -40.356))
  spawnPointsList.append(vect(29.662, 26.681, -74.951))
  spawnPointsList.append(vect(38.069, 13.312, -50.538))
  spawnPointsList.append(vect(19.593, 10.464, -98.064))


rule "Bots spawn points array B-":
  @Condition distance(vect(13.044, 9.697, -73.344), getRealClosestPlayer(vect(13.044, 9.697, -73.344), Team.1)) > 35
  
  spawnPointsList.remove(vect(15.598, 30.551, -60.258))
  spawnPointsList.remove(vect(-6.03, 18.558, -47.35))
  spawnPointsList.remove(vect(11.556, 20.229, -87.682))
  spawnPointsList.remove(vect(-5.797, 12.818, -90.005))
  spawnPointsList.remove(vect(9.321, 17.186, -40.356))
  spawnPointsList.remove(vect(29.662, 26.681, -74.951))
  spawnPointsList.remove(vect(38.069, 13.312, -50.538))
  spawnPointsList.remove(vect(19.593, 10.464, -98.064))


rule "Bots spawn points array C":
  @Condition distance(vect(-22.86, 8.08, -88.854), getRealClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) <= 15
  @Condition unlockedLocations == 4
  
  spawnPointsList.append(vect(74.194, 17.928, -49.807))


rule "Bots spawn points array C-":
  @Condition distance(vect(-22.86, 8.08, -88.854), getRealClosestPlayer(vect(-22.86, 8.08, -88.854), Team.1)) > 15
  @Condition unlockedLocations == 4
  
  spawnPointsList.remove(vect(74.194, 17.928, -49.807))


rule "Bots spawn points array D":
  @Condition distance(vect(59.416, 19.498, -77.513), getRealClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) <= 30
  
  spawnPointsList.append(vect(60.556, 9.729, -92.999))
  spawnPointsList.append(vect(57.692, 14.745, -78.916))
  spawnPointsList.append(vect(37.146, 27.607, -58.074))
  spawnPointsList.append(vect(94.023, 34.402, -65.749))
  spawnPointsList.append(vect(29.377, 19.108, -81.452))
  spawnPointsList.append(vect(36.546, 14.432, -106.335))
  spawnPointsList.append(vect(60.876, 8.672, -74.696))


rule "Bots spawn points array D-":
  @Condition distance(vect(59.416, 19.498, -77.513), getRealClosestPlayer(vect(59.416, 19.498, -77.513), Team.1)) > 30
  
  spawnPointsList.remove(vect(60.556, 9.729, -92.999))
  spawnPointsList.remove(vect(57.692, 14.745, -78.916))
  spawnPointsList.remove(vect(37.146, 27.607, -58.074))
  spawnPointsList.remove(vect(94.023, 34.402, -65.749))
  spawnPointsList.remove(vect(29.377, 19.108, -81.452))
  spawnPointsList.remove(vect(36.546, 14.432, -106.335))
  spawnPointsList.remove(vect(60.876, 8.672, -74.696))


rule "Bots spawn points array E":
  @Condition distance(vect(75.315, 22.594, -101.637), getRealClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) <= 50
  
  spawnPointsList.append(vect(94.023, 34.402, -65.749))
  spawnPointsList.append(vect(74.277, 14.12, -110.609))
  spawnPointsList.append(vect(90.938, 30.988, -109.069))
  spawnPointsList.append(vect(57.687, 21.96, -76.518))
  spawnPointsList.append(vect(63.86, 16.823, -100.725))


rule "Bots spawn points array E-":
  @Condition distance(vect(75.315, 22.594, -101.637), getRealClosestPlayer(vect(75.315, 22.594, -101.637), Team.1)) > 50
  
  spawnPointsList.remove(vect(94.023, 34.402, -65.749))
  spawnPointsList.remove(vect(74.277, 14.12, -110.609))
  spawnPointsList.remove(vect(90.938, 30.988, -109.069))
  spawnPointsList.remove(vect(57.687, 21.96, -76.518))
  spawnPointsList.remove(vect(63.86, 16.823, -100.725))


rule "Bots spawn points array F":
  @Condition distance(vect(108.196, 14.309, -22.096), getRealClosestPlayer(vect(108.196, 14.299, -22.094), Team.1)) <= 45
  
  spawnPointsList.append(vect(74.194, 17.928, -49.807))
  spawnPointsList.append(vect(124.358, 23.829, -26.451))
  spawnPointsList.append(vect(97.865, 22.892, -42.244))
  spawnPointsList.append(vect(128.632, 23.521, -7.378))
  spawnPointsList.append(vect(122.998, 16.026, -66.952))
  spawnPointsList.append(vect(142.909, 17.319, -45))


rule "Bots spawn points array F-":
  @Condition distance(vect(108.195, 14.3, -22.094), getRealClosestPlayer(vect(108.196, 14.309, -22.096), Team.1)) > 45
  
  spawnPointsList.remove(vect(74.194, 17.928, -49.807))
  spawnPointsList.remove(vect(124.358, 23.829, -26.451))
  spawnPointsList.remove(vect(97.865, 22.892, -42.244))
  spawnPointsList.remove(vect(128.632, 23.521, -7.378))
  spawnPointsList.remove(vect(122.998, 16.026, -66.952))
  spawnPointsList.remove(vect(142.909, 17.319, -45))


rule "Bots spawn points array G":
  @Condition distance(vect(140.011, 12.178, -61.257), getRealClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) <= 15
  
  spawnPointsList.append(vect(74.194, 17, -49.807))
  spawnPointsList.append(vect(124.358, 23, -26.451))
  spawnPointsList.append(vect(97.865, 22, -42.244))
  spawnPointsList.append(vect(128.632, 23, -7.378))
  spawnPointsList.append(vect(122.998, 16, -66.952))
  spawnPointsList.append(vect(142.909, 17, -45))


rule "Bots spawn points array G-":
  @Condition distance(vect(140.011, 12.178, -61.257), getRealClosestPlayer(vect(140.011, 12.178, -61.257), Team.1)) > 15
  
  spawnPointsList.remove(vect(74.194, 17, -49.807))
  spawnPointsList.remove(vect(124.358, 23, -26.451))
  spawnPointsList.remove(vect(97.865, 22, -42.244))
  spawnPointsList.remove(vect(128.632, 23, -7.378))
  spawnPointsList.remove(vect(122.998, 16, -66.952))
  spawnPointsList.remove(vect(142.909, 17, -45))