#!mainFile "../main.opy"

rule "[Doomfist] init":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.getHero() == Hero.DOOMFIST

  setHeroInfoText0("
    {} <fg83534cFF>Doomfist</fg>:\n
    {} <fg83534cFF>Seismic slam</fg>:
      - Slows enemies who have taken damage.\n\n
    {} <fg83534cFF>Power block</fg>:
      - While using this ability, press Jump to perform an uppercut 
        that launches enemies and deals damage.\n\n
    {} <fg83534cFF>Meteor strike</fg>:
      - Knocks down players who have taken damage.\n\n
    ".format(
      heroIcon(Hero.DOOMFIST),
      abilityIconString(Hero.DOOMFIST, Button.ABILITY_1),
      abilityIconString(Hero.DOOMFIST, Button.ABILITY_2),
      abilityIconString(Hero.DOOMFIST, Button.ULTIMATE)
    )
  )

  waitUntil(eventPlayer.getHero() != Hero.DOOMFIST, INFINITY)
  clearHeroInfo()

rule "[Doomfist] Uppercut":
  @Event eachPlayer
  @Hero doomfist
  @Condition eventPlayer.isUsingAbility2()
  @Condition not eventPlayer.isHoldingButton(Button.JUMP)

  waitUntil(eventPlayer.isHoldingButton(Button.JUMP), 2.45)
  if not eventPlayer.isHoldingButton(Button.JUMP) or not eventPlayer.isUsingAbility2():
    return

  eventPlayer.cancelPrimaryAction()

  playEffect(getPlayers(Team.1), DynamicEffect.EXPLOSION_SOUND, eventPlayer.getTeam(), eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.DEBUFF_IMPACT_SOUND, eventPlayer.getTeam(), eventPlayer, 100)
  playEffect(getPlayers(Team.1), DynamicEffect.RING_EXPLOSION_SOUND, eventPlayer.getTeam(), eventPlayer, 100)
  # playEffect(getPlayers(Team.1), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP_SOUND, eventPlayer.getTeam(), eventPlayer, 100)
  # playEffect(getPlayers(Team.1), DynamicEffect.DOOMFIST_RISING_UPPERCUT_LEAP, eventPlayer.getTeam(), eventPlayer, 100)

  eventPlayer.disablePlayerCollision()
  eventPlayer.setGravity(0)
  # eventPlayer.list0.setGravity(0)
  
  eventPlayer.list0 = getPlayersInRadius(
    worldVector(vect(0, 0, 1), eventPlayer, Transform.ROTATION_AND_TRANSLATION),
    3,
    Team.ZOMBIES,
    LosCheck.SURFACES
  )
  eventPlayer.list0.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  eventPlayer.applyImpulse(Vector.UP, 15, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
  damage(eventPlayer.list0, eventPlayer, 50)
  eventPlayer.list0.setCrowdControlAttack(eventPlayer)
  eventPlayer.list0.setStatusEffect(eventPlayer, Status.STUNNED, 0.5)
  wait(0.25)
  eventPlayer.enablePlayerCollision()
  wait(0.55)
  eventPlayer.setGravity(100)
  # eventPlayer.list0.setGravity(100)

rule "[Doomfist]: Calculate slam damage based on air time":
  @Event eachPlayer
  @Hero doomfist
  @Condition eventPlayer.isUsingAbility1()
  
  eventPlayer.abilState0 = 0
  # showSlamDamageGui()
  waitUntil(eventPlayer.isInAir(), INFINITY)

  chaseAtRate(eventPlayer.abilState0, 500, 100, ChaseRateReeval.NONE)
  waitUntil(eventPlayer.isOnGround() or not eventPlayer.isUsingAbility1(), INFINITY)
  stopChasingVariable(eventPlayer.abilState0)
  wait(1, Wait.RESTART_WHEN_TRUE)
  # hideSlamDamageGui()

# rule "[debug]: Calculate slam damage based on air time":
#   @Event eachPlayer
#   @Hero doomfist

#   debug(eventPlayer.abilState0)

# def showSlamDamageGui():
#   @Name "[Doomfist]: showSlamDamageGui()"
  
#   if eventPlayer.slam_damage_text_entity != null:
#       return
#   createInWorldText(eventPlayer, "[ {0} ]".format(floor(eventPlayer.slam_damage)), updateEveryFrame(eventPlayer.getEyePosition() + (100 * (-0.2 * (directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90)) + 3 * eventPlayer.getFacingDirection()))), 2)
#   eventPlayer.slam_damage_text_entity = getLastCreatedText()


# def hideSlamDamageGui():
#   @Name "[Doomfist]: hideSlamDamageGui()"
  
#   destroyInWorldText(eventPlayer.slam_damage_text_entity)
#   eventPlayer.slam_damage_text_entity = null