#!mainFile "../main.opy"

rule "[Ana] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.ANA

  eventPlayer.heroInfoVertFix0 = 2
  eventPlayer.heroInfoText0 = "{} <fg6e89b1FF>Ana</fg>:\n
  {} {}Sleep dart{}:
    - Hitting an enemy puts other enemies within a 3-meter radius to sleep.\n\n
  {} <fg6e89b1FF>Biotic gredane</fg>:
    - Slows enemies by 50%.\n\n
  {} {}Nano boost{}:
    - Can now be used on Ana herself.
    - Increases movement speed by 30%.\n\n
  Melee:
    - Has a 20% chance to put an enemy to sleep.
  ".format(
    heroIcon(Hero.ANA),
    abilityIconString(Hero.ANA, Button.ABILITY_1),
    "<fg6e89b1FF>",
    "</fg>",
    abilityIconString(Hero.ANA, Button.ABILITY_2),
    abilityIconString(Hero.ANA, Button.ULTIMATE),
    "<fg6e89b1FF>",
    "</fg>"
  )

  waitUntil(eventPlayer.getHero() != Hero.ANA, INFINITY)
  clearHeroInfo()

rule "[Ana] Nano'd target gains speed boost":
  @Event playerDealtHealing
  @Hero ana
  @Condition eventAbility == Button.ULTIMATE

  healee.setSpeedState(130, 8)

rule "[Ana] Nano damage for detect":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isUsingUltimate()
  
  damage(getPlayers(eventPlayer.getTeam()).exclude(eventPlayer), null, 0.01)
  wait(0.2)
  heal(getPlayers(eventPlayer.getTeam()).exclude(eventPlayer), null, 0.01)

rule "[Ana]: Mass sleep dart, slowdown nade, sleep melee":
  @Event playerDealtDamage
  @Team 1
  @Hero ana
  
  if eventAbility == Button.ABILITY_1:
    playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.BLACK, victim, 3)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.BLACK, victim, 6)
    getPlayersInRadius(victim.getEyePosition(), 3, Team.2, LosCheck.SURFACES).setStatusEffect(null, Status.ASLEEP, 5)
  if eventAbility == Button.ABILITY_2:
    victim.setSpeedState(50)
  elif eventAbility == Button.MELEE and random.randint(1, 100) <= 20:
    victim.setStatusEffect(null, Status.ASLEEP, 5)

rule "[Ana]: Self Nano":
  @Event eachPlayer
  @Hero ana
  @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
  @Condition eventPlayer.getUltCharge() == 100
  @Condition eventPlayer.isAlive()
  @Condition not eventPlayer.isDummy()
  @Condition not eventPlayer.abilPos0
  
  waitUntil(
    eventPlayer.isUsingUltimate(),
    3.5 if any([player.isAlive() and player != eventPlayer and eventPlayer.isInViewAngle(player, 10) for player in getPlayersInRadius(eventPlayer, 41, eventPlayer.getTeam(), LosCheck.SURFACES)]) else 0.13
  )

  if not eventPlayer.isUsingUltimate():
    eventPlayer.abilPos0 = true
    createDummy(
      Hero.ANA,
      eventPlayer.getTeam(),
      MAX_PLAYERS,
      raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition(),
      Vector.DOWN
    )
    eventPlayer.abilPos1 = getLastCreatedEntity()
    # eventPlayer.abilPos1 = eventPlayer.abilPos1[0]
    eventPlayer.abilPos1.startForcingPosition(updateEveryFrame(raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + eventPlayer.getFacingDirection() * 1, getAllPlayers(), eventPlayer, true).getHitPosition()))
    eventPlayer.abilPos1.startFacing(directionTowards(eventPlayer.abilPos1.getEyePosition(), eventPlayer.getPosition()), 4000)
    eventPlayer.abilPos1.startForcingName("■")
    eventPlayer.abilPos1.disableEnvironmentCollision(true)
    eventPlayer.abilPos1.setStatusEffect(eventPlayer, Status.PHASED_OUT, 9999)
    eventPlayer.abilPos1.setInvisibility(Invis.ALL)
    eventPlayer.abilPos1.setHealth(5)
    wait()
    eventPlayer.forceButtonPress(Button.ULTIMATE)
    eventPlayer.abilPos1.setUltCharge(100)
    waitUntil(eventPlayer.isUsingUltimate(), 1)
    if eventPlayer.isUsingUltimate():
      eventPlayer.abilPos1.stopForcingPosition()
      eventPlayer.abilPos1.startForcingPosition(updateEveryFrame(eventPlayer.getEyePosition()))
      wait(0.025)
      eventPlayer.abilPos1.forceButtonPress(Button.ULTIMATE)
      #wait(0.025)
      #eventPlayer.abilPos1.forceButtonPress(Button.PRIMARY_FIRE)
      waitUntil(eventPlayer.abilPos1.isUsingUltimate(), 0.25)
      if eventPlayer.abilPos1.isUsingUltimate():
        eventPlayer.abilPos1.stopForcingPosition()
        eventPlayer.abilPos1.startForcingPosition(vect(0, 1000, 0))
        waitUntil(not eventPlayer.isAlive(), 8)
        destroyDummy(eventPlayer.getTeam(), eventPlayer.abilPos1.getSlot())
        eventPlayer.abilPos0 = false
      elif not eventPlayer.abilPos1.isUsingUltimate():
        destroyDummy(eventPlayer.getTeam(), eventPlayer.abilPos1.getSlot())
        eventPlayer.abilPos0 = false
    elif not eventPlayer.isUsingUltimate():
      destroyDummy(eventPlayer.getTeam(), eventPlayer.abilPos1.getSlot())
      eventPlayer.abilPos0 = false