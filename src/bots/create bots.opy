#!mainFile "../main.opy"

#!define LAST_ZOMBIES_ICONS_AMOUNT 5

# rule "Create bots":
#   @Condition not isBotsDisabled
#   @Condition isGameStarted == true
#   @Condition getNumberOfPlayers(Team.2) < wSettingsMaxZombieBots
  
#   wait(3, Wait.ABORT_WHEN_FALSE)
#   if isBotsDisabled:
#     return

#   smallMessage(hostPlayer, "Server: Create new zombie bots")
#   for createDummyI in range(wSettingsMaxZombieBots):
#     if not getPlayersInSlot(createDummyI, Team.2):
#       createDummy(Hero.TORBJORN, Team.2, createDummyI, random.choice(spawnPointsList))
#       wait(0.4)


  # # [debug]:
  # createIcon(getPlayers(Team.1) if not eventPlayer.downedStartTime else null, eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)
  # wait()
  # createIcon(getPlayers(Team.1) if eventPlayer.downedStartTime else null, eventPlayer, Icon.NO, IconReeval.VISIBILITY_AND_POSITION, Color.WHITE)