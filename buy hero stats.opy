#!mainFile "main.opy"

rule "Inite shop upgrades effects and text":
  @Condition roundNumber == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.LIME_GREEN, vectList[vectListI.BUY_HP], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vectList[vectListI.BUY_DAMAGE], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.ORANGE, vectList[vectListI.BUY_HEALING], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "HP (+25%) | 2500 ", vectList[vectListI.BUY_HP], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.LIME_GREEN)
  createInWorldText(getAllPlayers(), "Damage (+20%) | 2500", vectList[vectListI.BUY_DAMAGE], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  createInWorldText(getAllPlayers(), "Healing Dealt (+15%) | 2500", vectList[vectListI.BUY_HEALING], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)

  createEffect(getPlayers(Team.1), Effect.RING, Color.ORANGE, vectList[vectListI.BUY_TEAM_ARMOR], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format("+50 Armor [Team]", 12500 + null)), vectList[vectListI.BUY_TEAM_ARMOR], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)
  createEffect(getPlayers(Team.1), Effect.RING, Color.BLUE, vectList[vectListI.BUY_TEAM_SHIELDS], 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getPlayers(Team.1), l"{0} {1}".format(l"Buy", l"{0}: {1}".format("+50 Shields [Team]", 12500 + null)), vectList[vectListI.BUY_TEAM_SHIELDS], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLUE)

rule "Buy damage upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.BUY_DAMAGE]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.damage_stat += 15
  eventPlayer.setDamageDealt(eventPlayer.damage_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)


rule "Buy health upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.BUY_HP]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.health_stat += 20
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
  wait(0.25)
  heal(eventPlayer, null, 99999)


rule "Buy healing upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.BUY_HEALING]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healing_stat += 10
  eventPlayer.setHealingDealt(eventPlayer.healing_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

rule "Buy team shields":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 7500
  @Condition eventPlayer.F == false
  @Condition distance(eventPlayer, vectList[vectListI.BUY_TEAM_SHIELDS]) <= 1.5
  @Condition unlockedLocations >= 3
  
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
  getPlayers(Team.1).addHealthPool(Health.SHIELDS, 40, true)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Shields!"))
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.BLUE, getPlayers(Team.1), 100)
  eventPlayer.money -= 7500
  wait(0.25)
  heal(getLivingPlayers(Team.1), null, 99999)
  team_shields += 40


rule "Buy team armor":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition distance(eventPlayer, vectList[vectListI.BUY_TEAM_ARMOR]) <= 1.5
    @Condition eventPlayer.money >= 7500
    @Condition eventPlayer.F == false
    @Condition unlockedLocations >= 3

    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, getPlayers(Team.1), 100)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Armor!"))
    getPlayers(Team.1).addHealthPool(Health.ARMOR, 40, true)
    eventPlayer.money -= 7500
    wait(0.25)
    heal(getLivingPlayers(Team.1), null, 99999)
    team_armor += 40