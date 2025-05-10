#!mainFile "main.opy"

# todo: WTF?
rule "Bots restricted areas":
  temp3 = getPlayers(Team.2)

  for K in range(len(temp3)):
    if temp3[K].isInSpawnRoom():
      temp3[K].teleport(random.choice(spawnPointsList))
    if distance(temp3[K], vect(83.1, 11.88, -111.642)) < 3:
      temp3[K].teleport(vect(79.382, 13.147, -110.093))
    if distance(temp3[K], vect(89.731, 13.228, -102.377)) < 2:
      temp3[K].teleport(vect(86.903, 14.219, -101.238))
    if distance(temp3[K], vect(97.65, 11.233, -30.593)) < 3:
      temp3[K].teleport(vect(96.475, 12.392, -35.419))
    if distance(temp3[K], vect(103.937, 11.178, -30.358)) < 2:
      temp3[K].teleport(vect(107.719, 11.178, -33.024))
    if distance(temp3[K], vect(113.037, 12.696, -10.145)) < 3:
      temp3[K].teleport(vect(113.894, 11.178, -15.333))
    if distance(temp3[K], vect(140.251, 12.481, -17.63)) < 3:
      temp3[K].teleport(vect(133.957, 12.363, -18.225))

  wait(0.5)
  loop()

