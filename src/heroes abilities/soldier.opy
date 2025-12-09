#!mainFile "../main.opy"

rule "[Soldier] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.SOLDIER

  eventPlayer.heroInfoVertFix0 = -3
  eventPlayer.heroInfoText0 = "{} <fg6d7995FF>Soldier 76</fg>:\n
  {} {}Helix rockets{}:
    - During ultimate, cooldown is reduced to 1 second.
  ".format(
    heroIcon(Hero.SOLDIER),
    abilityIconString(Hero.SOLDIER, Button.SECONDARY_FIRE),
    "<fg6d7995FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.SOLDIER, INFINITY)
  clearHeroInfo()

rule "[Soldier] Helix rockets with ultimate":
  @Event eachPlayer
  @Hero soldier
  @Condition eventPlayer.isUsingUltimate()

  eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
  wait(1)
  if ruleCondition:
    loop()
