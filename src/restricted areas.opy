#!mainFile "main.opy"

rule "Teleport from restricted areas":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() and eventPlayer.hasSpawned()
    if not eventPlayer.posBeforeChangeHero and distance(eventPlayer, vect(101.397, 14.21, -110.834)) < 14: # vanilla Team.1 spawn room 
      eventPlayer.teleport(vect(-27.412, 2, -12.564))
    if zonesEffectsIds[BUY_HERO_OFFSET_E]:
      if distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3: # vanilla Team.1 spawn room entrance
        eventPlayer.teleport(vect(79.382, 13.147, -110.093))
      if distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2: # vanilla Team.1 spawn room second entrance
        eventPlayer.teleport(vect(86.903, 14.219, -101.238))
  wait(0.3)
  if ruleCondition:
    loop()

rule "Restricted areas affects":
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
