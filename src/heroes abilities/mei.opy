#!mainFile "../main.opy"

rule "[Mei] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.MEI

  setHeroInfoText0("
    {} <fg6dabebFF>Mei</fg>:\n
    {} <fg6dabebFF>Cryo-freeze</fg>:
      - instantly freeze nearby enemies once cryo-freeze breaks.\n\n
    - All heroes deal double damage to frozen enemies.
    ".format(
      heroIcon(Hero.MEI),
      abilityIconString(Hero.MEI, Button.ABILITY_1)
    )
  )
  
  waitUntil(eventPlayer.getHero() != Hero.MEI, INFINITY)
  clearHeroInfo()

rule "[Mei] Freeze nearby opponents after Cryo-freeze":
  @Event eachPlayer
  @Team 1
  @Hero mei
  @Condition eventPlayer.isUsingAbility1()
  
  pause3PCamera()
  waitUntil(not eventPlayer.isUsingAbility1(), 5)
  unpause3PCamera()
  getPlayersInRadius(eventPlayer.getEyePosition(), 10, Team.ZOMBIES, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.FROZEN, 3)

rule "[Mei] all team.1 heroes deal double damage to frozen enemies:":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatus(Status.FROZEN)

  eventPlayer.setDamageReceived(200)
  waitUntil(not eventPlayer.hasStatus(Status.FROZEN), 5)
  eventPlayer.setDamageReceived(100)