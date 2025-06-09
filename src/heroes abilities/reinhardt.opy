#!mainFile "../main.opy"

rule "[Reinhardt] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg94a1a5FF>Reinhardt</fg>:\n
  {} {}Barrier field{}:
      - Pushes back enemies and takes damage on contact.\n\n
  Perk <TX C0000000005E4B2> <fg94a1a5FF>Shield Slam</fg>:
      - Stuns enemies for 2 seconds.
  ".format(
    heroIcon(Hero.REINHARDT),
    abilityIconString(Hero.REINHARDT, Button.SECONDARY_FIRE),
    "<fg94a1a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.REINHARDT, INFINITY)
  clearHeroInfo()
