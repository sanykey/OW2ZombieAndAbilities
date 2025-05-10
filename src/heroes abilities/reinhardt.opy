#!mainFile "../main.opy"

rule "[Reinhardt] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.REINHARDT

  wait(1) # waiting for the previous hero to clear hero data
  eventPlayer.state[SI.TALENTS_COUNT] = 1
  eventPlayer.state[SI.HERO_INFO_VERTICAL_FIX] = -3
  eventPlayer.state[SI.HERO_INFO_TEXT] = "{} <fg94a1a5FF>Reinhardt</fg>:\n
  {} {}Barrier field{}:
      - Pushes back enemies and takes damage on contact.
  ".format(
    heroIcon(Hero.REINHARDT),
    abilityIconString(Hero.REINHARDT, Button.SECONDARY_FIRE),
    "<fg94a1a5FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.REINHARDT, INFINITY)
  clearHeroInfo()
