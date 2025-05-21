#!mainFile "main.opy"

rule "Teleport from restricted areas":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() and eventPlayer.hasSpawned()
    if not eventPlayer.posBeforeChangeHero and distance(eventPlayer, vect(101.397, 14.21, -110.834)) < 14: # vanilla spawn room
      eventPlayer.teleport(vect(-27.412, 2, -12.564))
    if distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3:
      eventPlayer.teleport(vect(79.382, 13.147, -110.093))
    if distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2:
      eventPlayer.teleport(vect(86.903, 14.219, -101.238))
    if distance(eventPlayer, vect(97.65, 11.233, -30.593)) < 3:
      eventPlayer.teleport(vect(96.475, 12.392, -35.419))
    if distance(eventPlayer, vect(103.937, 11.178, -30.358)) < 2:
      eventPlayer.teleport(vect(107.719, 11.178, -33.024))
  wait(0.3)
  loop()

rule "Restricted areas affects":
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(97.277, 12.025, -32.134), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)