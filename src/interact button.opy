#!mainFile "main.opy"

#!define UPGRADE_PRICE 2500
#!define TEAM_UPGRADE_PRICE 10000

#!define HEALTH_UPGRADE_AMOUNT 7
#!define DAMAGE_UPGRADE_AMOUNT 5
#!define HEALING_UPGRADE_AMOUNT 5
#!define TEAM_ARMOR_UPGRADE_AMOUNT 25
#!define TEAM_SHIELDS_UPGRADE_AMOUNT 25

#!define BUNCH_BUY_MULTIPLY 20

rule "Interact button":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

  # [shop] switch hero:
  if distance(eventPlayer, vectList[VL_CHANGE_HERO]) < 1.8:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    openSwitchHeroHud()

  # [shop] upgrade damage:
  elif distance(eventPlayer, vectList[VL_BUY_DAMAGE]) < 1.8 :
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.damageBoostPercent += 5 * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE:
      eventPlayer.money -= UPGRADE_PRICE
      eventPlayer.damageBoostPercent += 5
    else:
      return
    eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)

  # [shop] upgrade health:
  elif distance(eventPlayer, vectList[VL_BUY_HP]) < 1.8:
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.healthBoostPercent += 8 * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE:
      eventPlayer.money -= UPGRADE_PRICE
      eventPlayer.healthBoostPercent += 8
    else:
      return
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
    wait(1, Wait.RESTART_WHEN_TRUE)
    heal(eventPlayer, null, INFINITY)

  # [shop] upgrade healing:
  elif distance(eventPlayer, vectList[VL_BUY_HEALING]) < 1.8:
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.healingBoostPercent += 5 * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money >= UPGRADE_PRICE:
      eventPlayer.money -= UPGRADE_PRICE
      eventPlayer.healingBoostPercent += 5
    else:
      return

    eventPlayer.healingTrackerThreshold = HEAL_AMOUNT_FOR_MONEY + 0 if eventPlayer.healingBoostPercent < 100 else ceil(HEAL_AMOUNT_FOR_MONEY * (eventPlayer.healingBoostPercent / 500))
    eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

  # [shop] upgrade team shields:
  elif distance(eventPlayer, vectList[VL_BUY_TEAM_SHIELDS]) <= 1.5 and eventPlayer.money >= TEAM_UPGRADE_PRICE:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.BLUE, eventPlayer, 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.BLUE, getPlayers(Team.1), 100)
    eventPlayer.money -= TEAM_UPGRADE_PRICE
    teamShields += TEAM_SHIELDS_UPGRADE_AMOUNT
    eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM] += TEAM_SHIELDS_UPGRADE_AMOUNT

    wait(1, Wait.RESTART_WHEN_TRUE)
    bigMessage(getPlayers(Team.1), "{} has awarded the team +{} Shields! ".format(eventPlayer, eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM]))
    heal(getLivingPlayers(Team.1), null, INFINITY)

  # [shop] upgrade team armor:
  elif distance(eventPlayer, vectList[VL_BUY_TEAM_ARMOR]) <= 1.5 and eventPlayer.money >= TEAM_UPGRADE_PRICE:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, getPlayers(Team.1), 100)
    eventPlayer.money -= TEAM_UPGRADE_PRICE
    teamArmor += TEAM_ARMOR_UPGRADE_AMOUNT
    eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] += TEAM_ARMOR_UPGRADE_AMOUNT

    wait(1, Wait.RESTART_WHEN_TRUE)
    bigMessage(getPlayers(Team.1), "{} has awarded the team +{} Armor!".format(eventPlayer, eventPlayer.boostStats[PV_ARMOR_FOR_TEAM]))
    heal(getLivingPlayers(Team.1), null, INFINITY)

  # [shop] refund upgrades
  elif distance(eventPlayer, vectList[VL_REFUND]) <= 1.5:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, getPlayers(Team.1), 100)
    
    eventPlayer.money += (eventPlayer.damageBoostPercent - 100) / DAMAGE_UPGRADE_AMOUNT * UPGRADE_PRICE
    eventPlayer.money += (eventPlayer.healthBoostPercent - 100) / HEALTH_UPGRADE_AMOUNT * UPGRADE_PRICE
    eventPlayer.money += (eventPlayer.healingBoostPercent - 100) / HEALING_UPGRADE_AMOUNT * UPGRADE_PRICE

    if (eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] or eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM]):
      eventPlayer.money += eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] / TEAM_ARMOR_UPGRADE_AMOUNT * TEAM_UPGRADE_PRICE
      eventPlayer.money += eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM] / TEAM_SHIELDS_UPGRADE_AMOUNT * TEAM_UPGRADE_PRICE
      teamArmor -= eventPlayer.boostStats[PV_ARMOR_FOR_TEAM]
      teamShields -= eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM]

    eventPlayer.damageBoostPercent = 100
    eventPlayer.healthBoostPercent = 100
    eventPlayer.healingBoostPercent = 100
    eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] = 0
    eventPlayer.boostStats[PV_SHIELDS_FOR_TEAM] = 0

    eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)

    if eventPlayer.money < (wSettingsStartMoney + (2500 * roundNumber)):
      eventPlayer.money = wSettingsStartMoney + (2500 * roundNumber)
    
  # Switch 3P Camera (INTERACT + CROUCH)
  elif eventPlayer.isHoldingButton(Button.CROUCH):
    waitUntil(
      (
        not (eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.INTERACT)) or 
        eventPlayer.isHoldingButton(Button.MELEE)
      ),
      HERO_INFO_HOLD_DURATION
    )

    # The player has called up the hero information window, the camera does not need to be changed
    if (eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.INTERACT) or eventPlayer.isHoldingButton(Button.MELEE)): 
      return

    if eventPlayer.cameraState == 0:
      eventPlayer.cameraState = 3
      smallMessage(eventPlayer, "3P Camera [ON]")
    elif eventPlayer.cameraState == 3:
      eventPlayer.cameraState = 4
      smallMessage(eventPlayer, "3P Camera Higher Angle [ON]")
    else:
      eventPlayer.cameraState = 0
      smallMessage(eventPlayer, "3P Camera [OFF]")
    playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)