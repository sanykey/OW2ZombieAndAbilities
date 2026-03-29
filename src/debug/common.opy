#!mainFile "../main.opy"

globalvar enabledInspector
globalvar debugTeleportPoint = vect(80.11, 12.68, -98.09)

rule "[debug] add BotStateView debug mode":
  debugModesArr.append("Common")

rule "[debug] init Common debug mode":
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Common"

  wait(0.1)

  debugSelectedAction = 0
  debugMaxAction = 13

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    f"{debugMenuTitle(\"Common\")}
    {debugSelectedActionText(1)}Disable bots:</fg> <fg84c951FF>{isBotsDisabled}</fg>
    {debugSelectedActionText(2)}Open switch hero menu</fg> 
    {debugSelectedActionText(3)}Invincible</fg> <fg84c951FF>{localPlayer.hasStatus(Status.INVINCIBLE)}</fg>
    {debugSelectedActionText(4)}Teleport to shop</fg> 
    {debugSelectedActionText(5)}Teleport to debug point</fg> <fg84c951FF>{debugTeleportPoint}</fg>
    {debugSelectedActionText(6)}Noclip:</fg> <fg84c951FF>{debugIsNoclip}</fg>
    {debugSelectedActionText(7)}Add $100000</fg> 
    {debugSelectedActionText(8)}Add upgrades</fg> 
    {debugSelectedActionText(9)}Unlimit ultimates:</fg> <fg84c951FF>{debugUnlimitUltimates}</fg>
    {debugSelectedActionText(10)}No CD:</fg> <fg84c951FF>{debugNoCD}</fg>
    {debugSelectedActionText(11)}Kill me</fg>
    {debugSelectedActionText(12)}Inspector: <fg84c951FF>{enabledInspector}</fg></fg>
    {debugSelectedActionText(13)}Ressurect all</fg>
    ----------
    Entities: {getNumberOfEntityIds()}
    Texts: {getNumberOfTextIds()}
    Failed Respawn Points: {debugFailedRespawnPoints}
    <fg94a0a544>Open/Close: [INTERACT] + [ABILITY_1] + [ABILITY_2]
    Navigate: [INTERACT] + [↑/↓/←/→]
    Change x10/x100: [←/→] + [Crouch/Space]
    Interact with menu item: [INTERACT] + [MELEE]
    Ressurect me: [INTERACT] + [RELOAD]</fg>
    ",
    HudPosition.ACTUALLY_LEFT,
    5,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  debugModeHud = getLastCreatedText()
  waitUntil(not ruleCondition, INFINITY)
  destroyHudText(debugModeHud)


rule "[debug] Activate selected action for Common mode":
  ConditionForActivateSelectedAction("Common")

  if debugSelectedAction == 1: # Disable bots
    if isBotsDisabled == false:
      RemoveBotsSub()
    else:
      AddBotsSub()

  elif debugSelectedAction == 2: # Open switch hero menu
    eventPlayer.purchasedHeroes = getAllHeroes()
    OpenSwitchHeroMenuSub()

  elif debugSelectedAction == 3: # Invincible
    if eventPlayer.hasStatus(Status.INVINCIBLE):
      eventPlayer.clearStatusEffect(Status.INVINCIBLE)
    else:
      eventPlayer.setStatusEffect(eventPlayer, Status.INVINCIBLE, INFINITY)

  elif debugSelectedAction == 4: # Teleport to shop
    eventPlayer.teleport(vect(-20.63, 6.50, -88.95))

  elif debugSelectedAction == 5: # Teleport to debug point
    eventPlayer.teleport(debugTeleportPoint)

  elif debugSelectedAction == 6: # Noclip
    debugIsNoclip = not debugIsNoclip
    if not debugIsNoclip:
      eventPlayer.clearStatusEffect(Status.INVINCIBLE)
      eventPlayer.enableEnvironmentCollision()
      eventPlayer.setUltCharge(0)
      eventPlayer.startForcingHero(debugNoclipPrevHero)
      eventPlayer.setGravity(100)
    else:
      debugNoclipPrevHero = eventPlayer.getHero()
      eventPlayer.startForcingHero(Hero.MERCY)
      wait()
      eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INFINITY)
      eventPlayer.setUltCharge(100)
      eventPlayer.forceButtonPress(Button.ULTIMATE)
      eventPlayer.disableEnvironmentCollision(true)
      eventPlayer.setGravity(0)

  elif debugSelectedAction == 7: # Add $100000
    eventPlayer.earnMoney(100000)

  elif debugSelectedAction == 8: # Add upgrades
    eventPlayer.healthBoostPercent = 100000
    eventPlayer.setMaxHealth(eventPlayer.healthBoostPercent)
    eventPlayer.damageBoostPercent = 100000
    eventPlayer.setDamageDealt(eventPlayer.damageBoostPercent)
    eventPlayer.healingBoostPercent += 100000
    eventPlayer.setHealingDealt(eventPlayer.healingBoostPercent)
    wait()
    heal(eventPlayer, null, INFINITY)

  elif debugSelectedAction == 9: # Unlimit ultimates
    debugUnlimitUltimates = not debugUnlimitUltimates

  elif debugSelectedAction == 10: # No CD
    debugNoCD = not debugNoCD

  elif debugSelectedAction == 11: # Kill me
    damage(eventPlayer, null, INFINITY)

  elif debugSelectedAction == 12: # Inspector
    if enabledInspector:
      enabledInspector = false
      disableInspector()
    else:
      enabledInspector = true
      enableInspector()

  elif debugSelectedAction == 13: # Ressurect all
    ReviveAllPlayersSub()
  
rule "[debug] Unlimit ultimates":
  @Event eachPlayer
  @Condition debugUnlimitUltimates
  @Condition eventPlayer.getUltCharge() < 100

  if eventPlayer.getUltCharge() < 100:
    eventPlayer.setUltCharge(100)
  wait(0.3, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] no cooldowns":
  @Event eachPlayer
  @Condition debugNoCD

  eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
  eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
  wait(0.3, Wait.ABORT_WHEN_FALSE)
  loop()


rule "[debug] refresh noclip":
  @Event eachPlayer
  @Condition debugIsNoclip
  @Condition eventPlayer == hostPlayer or eventPlayer.developer
  @Condition not eventPlayer.isUsingUltimate()
  
  eventPlayer.setUltCharge(100)
  wait()
  eventPlayer.forceButtonPress(Button.ULTIMATE)
  wait(0.4)
  eventPlayer.setStatusEffect(null, Status.HACKED, 0.05)



  
