#!mainFile "../main.opy"

rule "[Mei] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.MEI

  setHeroInfoText0(
    "
    {} <fg6dabebFF>Mei</fg>:\n
    {} <fg6dabebFF>Endothermic blaster</fg>
      - While in the air, slightly pushes Mei in the opposite direction of the shot.\n\n
    {} <fg6dabebFF>Cryo-freeze</fg>:
      - instantly freeze nearby enemies once cryo-freeze breaks.\n\n
    - All heroes deal double damage to frozen enemies.
    ".format(
      heroIcon(Hero.MEI),
      abilityIconString(Hero.MEI, Button.PRIMARY_FIRE),
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
  getPlayersInRadius(eventPlayer.getEyePosition(), 10, Team.2, LosCheck.SURFACES).setStatusEffect(eventPlayer, Status.FROZEN, 3)

rule "Mei frosty jet pack":
  @Event eachPlayer
  @Team 1
  @Hero mei
  @Condition eventPlayer.isFiringPrimaryFire() == true
  @Condition eventPlayer.isInAir() == true
  
  eventPlayer.applyImpulse(eventPlayer.getFacingDirection(), -1.6, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
  wait(0.1)
  if RULE_CONDITION:
    goto RULE_START

rule "[Mei] all team.1 heroes deal double damage to frozen enemies:":
  @Event eachPlayer
  @Team 2
  @Condition eventPlayer.hasStatus(Status.FROZEN)

  eventPlayer.setDamageReceived(200)
  waitUntil(not eventPlayer.hasStatus(Status.FROZEN), 5)
  eventPlayer.setDamageReceived(100)