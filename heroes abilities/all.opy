#!mainFile "../main.opy"

rule "Revealed zombies":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.revealed >= getTotalTimeElapsed()
  
  if eventPlayer.HUDs[HI.REVEALED_ICON] == false:
    createInWorldText(
      getAllPlayers(),
      "X",
      eventPlayer + vect(0, 0.5, 0),
      0.5,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
      Color.LIGHT_RED
    )
    eventPlayer.HUDs[HI.REVEALED_ICON] = getLastCreatedText()
  eventPlayer.startForcingOutlineFor(getAllPlayers(), true, Color.VIOLET, OutlineVisibility.OCCLUDED)

  waitUntil(eventPlayer.revealed < getTotalTimeElapsed() or eventPlayer.isAlive() == false, INFINITY)

  eventPlayer.revealed = false
  destroyInWorldText(eventPlayer.HUDs[HI.REVEALED_ICON])
  eventPlayer.HUDs[HI.REVEALED_ICON] = false
  eventPlayer.stopForcingOutlineFor(getAllPlayers())
