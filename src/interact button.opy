#!mainFile "main.opy"

rule "Interact button":
  @Event eachPlayer
  @Condition not eventPlayer.isDummy()
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)

  # [Ana][Orisa][attach p2p]
  if eventPlayer.attach2p[Attach2P.IS_ATTACHED]:
    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), INFINITY) # Prevent re-attach immediately after detach
    DetachP2PSub()

  # [shop] switch hero:
  if secretShopZoneEffects and distance(eventPlayer, vectList[VL_CHANGE_HERO]) < 1.8:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)
    OpenSwitchHeroMenuSub()

  # [shop] upgrade damage:
  elif secretShopZoneEffects and distance(eventPlayer, vectList[VL_BUY_DAMAGE]) < 1.8 :
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.damageBoostPercent += DAMAGE_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE
      eventPlayer.damageBoostPercent += DAMAGE_UPGRADE_AMOUNT
    else:
      return
    eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.RED, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.RED, eventPlayer, 100)

  # [shop] upgrade health:
  elif secretShopZoneEffects and distance(eventPlayer, vectList[VL_BUY_HP]) < 1.8:
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.healthBoostPercent += HEALTH_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE
      eventPlayer.healthBoostPercent += HEALTH_UPGRADE_AMOUNT
    else:
      return
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.LIME_GREEN, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.LIME_GREEN, eventPlayer, 100)
    wait(1, Wait.RESTART_WHEN_TRUE)
    heal(eventPlayer, null, INFINITY)

  # [shop] upgrade healing:
  elif secretShopZoneEffects and distance(eventPlayer, vectList[VL_BUY_HEALING]) < 1.8:
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.healingBoostPercent += HEALING_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= UPGRADE_PRICE:
      eventPlayer.money__botStuckTimes -= UPGRADE_PRICE
      eventPlayer.healingBoostPercent += HEALING_UPGRADE_AMOUNT
    else:
      return

    eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)

  # [shop] upgrade team armor:
  elif secretShopZoneEffects and distance(eventPlayer, vectList[VL_BUY_TEAM_ARMOR]) <= 1.5:
    if eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= TEAM_UPGRADE_PRICE * BUNCH_BUY_MULTIPLY:
      eventPlayer.money__botStuckTimes -= TEAM_UPGRADE_PRICE * BUNCH_BUY_MULTIPLY
      eventPlayer.healingBoostPercent += HEALING_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
      teamArmor += TEAM_ARMOR_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
      eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] += TEAM_ARMOR_UPGRADE_AMOUNT * BUNCH_BUY_MULTIPLY
    elif not eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.money__botStuckTimes >= TEAM_UPGRADE_PRICE:
      eventPlayer.money__botStuckTimes -= TEAM_UPGRADE_PRICE
      teamArmor += TEAM_ARMOR_UPGRADE_AMOUNT
      eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] += TEAM_ARMOR_UPGRADE_AMOUNT
    else:
      return

    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.ORANGE, eventPlayer, 1)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.ORANGE, eventPlayer, 100)
    
    wait(1, Wait.RESTART_WHEN_TRUE)
    heal(playersInShop, null, INFINITY)
    bigMessage(getPlayers(Team.1), "{} has awarded the team +{} Armor!".format(eventPlayer, eventPlayer.boostStats[PV_ARMOR_FOR_TEAM]))

  # [shop] refund upgrades
  elif secretShopZoneEffects and distance(eventPlayer, vectList[VL_REFUND]) <= 1.5:
    playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, getPlayers(Team.1), 2)
    playEffect(getPlayers(Team.1), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, getPlayers(Team.1), 100)
    
    eventPlayer.money__botStuckTimes += (eventPlayer.damageBoostPercent - 100) / DAMAGE_UPGRADE_AMOUNT * UPGRADE_PRICE
    eventPlayer.money__botStuckTimes += (eventPlayer.healthBoostPercent - 100) / HEALTH_UPGRADE_AMOUNT * UPGRADE_PRICE
    eventPlayer.money__botStuckTimes += (eventPlayer.healingBoostPercent - 100) / HEALING_UPGRADE_AMOUNT * UPGRADE_PRICE

    if (eventPlayer.boostStats[PV_ARMOR_FOR_TEAM]):
      eventPlayer.money__botStuckTimes += eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] / TEAM_ARMOR_UPGRADE_AMOUNT * TEAM_UPGRADE_PRICE
      teamArmor -= eventPlayer.boostStats[PV_ARMOR_FOR_TEAM]

    eventPlayer.damageBoostPercent = 100
    eventPlayer.healthBoostPercent = 100
    eventPlayer.healingBoostPercent = 100
    eventPlayer.boostStats[PV_ARMOR_FOR_TEAM] = 0
    eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)

    # if eventPlayer.moneyTotal__botOldPosition < (wSettingsStartMoney + (2500 * roundNumber)):
    #   eventPlayer.moneyTotal__botOldPosition = wSettingsStartMoney + (2500 * roundNumber)
    #   eventPlayer.money__botStuckTimes = eventPlayer.moneyTotal__botOldPosition

  # [Ana][Orisa][attach p2p]
  # elif not eventPlayer.attach2p[Attach2P.IS_ATTACHED]: 
  #   AttachP2PSub()
