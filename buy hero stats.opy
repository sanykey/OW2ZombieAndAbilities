#!mainFile "main.opy"

rule "[Shop Upgrades]":
  @Condition N == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.LIME_GREEN, vect(-31.204, 7.849, -87.474), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(-26.235, 7.812, -90.938), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createEffect(getAllPlayers(), Effect.RING, Color.ORANGE, vect(-27.198, 7.849, -96.303), 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  createInWorldText(getAllPlayers(), "HP (+25%) | 2500 ", vect(-31.204, 7.849, -87.474), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.LIME_GREEN)
  createInWorldText(getAllPlayers(), "Damage (+20%) | 2500", vect(-26.241, 7.819, -90.941), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  createInWorldText(getAllPlayers(), "Healing Dealt (+15%) | 2500", vect(-27.198, 7.849, -96.303), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.ORANGE)


rule "[Buy] Damage Upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(-26.235, 7.812, -90.938)) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.damage_stat += 15
  eventPlayer.setDamageDealt(eventPlayer.damage_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)


rule "[Buy] Health Upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(-31.204, 7.849, -87.474)) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.health_stat += 20
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
  wait(0.25)
  heal(eventPlayer, null, 99999)


rule "[Buy] Healing Upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vect(-27.198, 7.849, -96.303)) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healing_stat += 10
  eventPlayer.setHealingDealt(eventPlayer.healing_stat)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

rule "[Buy Shields]":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 7500
  @Condition eventPlayer.F == false
  @Condition distance(eventPlayer, vect(75.074, 12, -50.574)) <= 1.5
  @Condition C >= 3
  
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
  getPlayers(Team.1).addHealthPool(Health.SHIELDS, 40, true)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Shields!"))
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.BLUE, getPlayers(Team.1), 100)
  eventPlayer.money -= 7500
  wait(0.25)
  heal(getLivingPlayers(Team.1), null, 99999)
  team_shields += 40


rule "[Buy Armor]":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition distance(eventPlayer, vect(74.394, 12, -52.812)) <= 1.5
    @Condition eventPlayer.money >= 7500
    @Condition eventPlayer.F == false
    @Condition C >= 3
    
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, getPlayers(Team.1), 100)
    bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, "has awarded the team +40 Armor!"))
    getPlayers(Team.1).addHealthPool(Health.ARMOR, 40, true)
    eventPlayer.money -= 7500
    wait(0.25)
    heal(getLivingPlayers(Team.1), null, 99999)
    team_armor += 40