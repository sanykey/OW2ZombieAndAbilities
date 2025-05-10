#!mainFile "main.opy"

rule "Inite shop upgrades effects and text":
  createEffect(getAllPlayers(), Effect.RING, Color.LIME_GREEN, vectList[VI.BUY_HP], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vectList[VI.BUY_DAMAGE], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.ORANGE, vectList[VI.BUY_HEALING], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "HP (+7%) | 2500 ", vectList[VI.BUY_HP], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.LIME_GREEN)
  createInWorldText(getAllPlayers(), "Damage (+5%) | 2500", vectList[VI.BUY_DAMAGE], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  createInWorldText(getAllPlayers(), "Healing Dealt (+5%) | 2500", vectList[VI.BUY_HEALING], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)

  createEffect(getPlayers(Team.1), Effect.RING, Color.ORANGE, vectList[VI.BUY_TEAM_ARMOR], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format("+50 Armor [Team]", 7500 + null)), vectList[VI.BUY_TEAM_ARMOR], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)
  createEffect(getPlayers(Team.1), Effect.RING, Color.BLUE, vectList[VI.BUY_TEAM_SHIELDS], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format("+50 Shields [Team]", 7500 + null)), vectList[VI.BUY_TEAM_SHIELDS], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLUE)

rule "Buy damage upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.BUY_DAMAGE]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.damageStat += 5
  eventPlayer.setDamageDealt(eventPlayer.damageStat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)


rule "Buy health upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.BUY_HP]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healthStat += 7
  eventPlayer.setMaxHealth(eventPlayer.healthStat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
  wait(1, Wait.RESTART_WHEN_TRUE)
  heal(eventPlayer, null, INFINITY)


rule "Buy healing upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.BUY_HEALING]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healingStat += 5
  eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY + 0 if eventPlayer.healingStat < 100 else ceil(HEAL_AMOUNT_FOR_MONEY * (eventPlayer.healingStat / 500))

  eventPlayer.setHealingDealt(eventPlayer.healingStat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

rule "Buy team shields":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 7500
  @Condition distance(eventPlayer, vectList[VI.BUY_TEAM_SHIELDS]) <= 1.5
  @Condition unlockedLocations >= 3
  
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
  getPlayers(Team.1).addHealthPool(Health.SHIELDS, 40, true)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Shields!"))
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.BLUE, getPlayers(Team.1), 100)
  eventPlayer.money -= 7500
  wait(0.25)
  heal(getLivingPlayers(Team.1), null, INFINITY)
  teamShields += 40


rule "Buy team armor":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition distance(eventPlayer, vectList[VI.BUY_TEAM_ARMOR]) <= 1.5
    @Condition eventPlayer.money >= 7500
    @Condition unlockedLocations >= 3

    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, getPlayers(Team.1), 100)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Armor!"))
    getPlayers(Team.1).addHealthPool(Health.ARMOR, 40, true)
    eventPlayer.money -= 7500
    wait(0.25)
    heal(getLivingPlayers(Team.1), null, INFINITY)
    teamArmor += 40