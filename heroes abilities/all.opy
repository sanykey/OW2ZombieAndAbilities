#!mainFile "../main.opy"



rule "Revealed zombies":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.revealed >= getTotalTimeElapsed()
  
  if eventPlayer.HUDs[HI.REVEALED_ICON] == false:
    createInWorldText(
      getAllPlayers(),
      "o",
      eventPlayer.getEyePosition() + (eventPlayer.getFacingDirection() + vect(0, 0, -0.5)) * 0.25,
      0.6,
      Clip.NONE,
      WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
      Color.TEAM_2
    )
    eventPlayer.HUDs[HI.REVEALED_ICON] = getLastCreatedText()
  eventPlayer.startForcingOutlineFor(getAllPlayers(), true, Color.VIOLET, OutlineVisibility.OCCLUDED)

  waitUntil(eventPlayer.revealed < getTotalTimeElapsed() or eventPlayer.isAlive() == false, INFINITY)

  eventPlayer.revealed = false
  destroyInWorldText(eventPlayer.HUDs[HI.REVEALED_ICON])
  eventPlayer.HUDs[HI.REVEALED_ICON] = false
  eventPlayer.stopForcingOutlineFor(getAllPlayers())
