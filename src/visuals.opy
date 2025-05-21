#!mainFile "main.opy"

rule "World Effects":
  # "<3" room icons
  createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(139, 12, -18.3), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.HEART), vect(114, 12, -11.6), 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createEffect(getPlayers(Team.1), Effect.SPARKLES, Color.ROSE, vect(131, 12.6, 3.8), 5, EffectReeval.VISIBILITY)

  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(97.277, 12.025, -32.134), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)

rule "<3":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(131, 11.5, 3.8)) <= 5
  
  waitUntil(true, 99999)
  createIcon(getAllPlayers(), eventPlayer, Icon.HEART, IconReeval.NONE, Color.ROSE)
