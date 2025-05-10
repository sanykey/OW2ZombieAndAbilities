#!mainFile "main.opy"

rule "Teleport from restricted areas":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() and eventPlayer.hasSpawned()
    if eventPlayer.isInSpawnRoom():
      eventPlayer.teleport(random.choice(spawnPointsList))
    if distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3:
      eventPlayer.teleport(vect(79.382, 13.147, -110.093))
    if distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2:
      eventPlayer.teleport(vect(86.903, 14.219, -101.238))
    if distance(eventPlayer, vect(97.65, 11.233, -30.593)) < 3:
      eventPlayer.teleport(vect(96.475, 12.392, -35.419))
    if distance(eventPlayer, vect(103.937, 11.178, -30.358)) < 2:
      eventPlayer.teleport(vect(107.719, 11.178, -33.024))
    if distance(eventPlayer, vect(113.037, 12.696, -10.145)) < 3:
      eventPlayer.teleport(vect(113.894, 11.178, -15.333))
    if distance(eventPlayer, vect(140.251, 12.481, -17.63)) < 3:
      eventPlayer.teleport(vect(133.957, 12.363, -18.225))
  wait(0.3)
  loop()