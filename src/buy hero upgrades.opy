#!mainFile "main.opy"

rule "Init buyHeroUpgradesData":
  buyHeroUpgradesData = [
    ["HP (+7%): $2500", Color.LIME_GREEN, vectList[VL_BUY_HP]],
    ["Damage (+5%): $2500", Color.RED, vectList[VL_BUY_DAMAGE]],
    ["Healing Dealt (+5%): $2500", Color.YELLOW, vectList[VL_BUY_HEALING]],
    ["+50 Armor [Team]: $7500", Color.ORANGE, vectList[VL_BUY_TEAM_ARMOR]],
    ["+50 Shields [Team]: $7500", Color.BLUE, vectList[VL_BUY_TEAM_SHIELDS]],
    ["Change to a purchased hero", Color.WHITE, vectList[VL_CHANGE_HERO]]
  ]

rule "Change hero from shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_CHANGE_HERO]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
  openSwitchHeroHud()


rule "Buy damage upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_BUY_DAMAGE]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.damageBoostPercent += 5
  eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)


rule "Buy health upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_BUY_HP]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healthBoostPercent += 7
  eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
  wait(1, Wait.RESTART_WHEN_TRUE)
  heal(eventPlayer, null, INFINITY)


rule "Buy healing upgrade":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_BUY_HEALING]) < 1.8
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 2500
  
  eventPlayer.money -= 2500
  eventPlayer.healingBoostPercent += 5
  eventPlayer.state[SI.HEALING_TRACKER_THRESHOLD] = HEAL_AMOUNT_FOR_MONEY + 0 if eventPlayer.healingBoostPercent < 100 else ceil(HEAL_AMOUNT_FOR_MONEY * (eventPlayer.healingBoostPercent / 500))

  eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)
  playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
  playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

rule "Buy team shields":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.money >= 7500
  @Condition distance(eventPlayer, vectList[VL_BUY_TEAM_SHIELDS]) <= 1.5
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
  @Condition distance(eventPlayer, vectList[VL_BUY_TEAM_ARMOR]) <= 1.5
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