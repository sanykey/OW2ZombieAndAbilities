#!mainFile "../main.opy"

#abilState0 used in bots/zombie behavior.opy:rule "Bots attack near player"
 
rule "[Vendetta] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == newHero

  wait(1) # waiting for the previous hero to clear hero data
  # todo: find Vendetta color:
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fga0a9baFF>Vendetta</fg>:\n
  ".format(
    heroIcon(newHero)
    "<fga0a9baFF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != newHero, INFINITY)
  clearHeroInfo()
  