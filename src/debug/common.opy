#!mainFile "../main.opy"

globalvar enabledInspector

rule "[debug] add BotStateView debug mode":
  debugModesArr.append("Common")

rule "[debug] init Common debug mode":
  @Condition debugMenuIsOpened and debugModesArr[debugMode] == "Common"

  wait(0.1)

  debugSelectedAction = 0
  debugMaxAction = 12

  hudSubheader(
    localPlayer if localPlayer.developer or localPlayer == hostPlayer else null,
    "{}
    {}Disable bots:</fg> <fg84c951FF>{}</fg>
    {}Ressurect all</fg>
    {}Open switch hero menu</fg> 
    {}Invincible</fg> <fg84c951FF>{}</fg>
    {}Teleport to shop</fg> 
    {}Noclip:</fg> <fg84c951FF>{}</fg>
    {}Add $100000</fg> 
    {}Add upgrades</fg> 
    {}Unlimit ultimates:</fg> <fg84c951FF>{}</fg>
    {}No CD:</fg> <fg84c951FF>{}</fg>
    {}Kill me</fg>
    {}Inspector: <fg84c951FF>{}</fg></fg>
    ----------
    Entities: {}, Texts: {}
    <fg94a0a544>Open/Close: [INTERACT] + [ABILITY_1] + [ABILITY_2]
    Navigate: [INTERACT] + [↑/↓/←/→]
    Interact with menu item: [INTERACT] + [MELEE]
    Ressurect me: [INTERACT] + [RELOAD]</fg>
    ".format(
      debugMenuTitle("Common"),
      debugSelectedActionText(1),
      isBotsDisabled,
      debugSelectedActionText(2),
      debugSelectedActionText(3),
      debugSelectedActionText(4),
      localPlayer.hasStatus(Status.INVINCIBLE),
      debugSelectedActionText(5),
      debugSelectedActionText(6),
      debugIsNoclip,
      debugSelectedActionText(7),
      debugSelectedActionText(8),
      debugSelectedActionText(9),
      debugUnlimitUltimates,
      debugSelectedActionText(10),
      debugNoCD,
      debugSelectedActionText(11),
      debugSelectedActionText(12),
      enabledInspector,
      getNumberOfEntityIds(),
      getNumberOfTextIds()
    ),
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

  if debugSelectedAction == 1: # "[debug] disable/enable bots"
    if isBotsDisabled == false:
      RemoveBotsSub()
    else:
      AddBotsSub()
  elif debugSelectedAction == 2: # resurrect all
    reviveAllPlayersSR()
  elif debugSelectedAction == 3: # Open switch hero hud
    eventPlayer.purchasedHeroes = getAllHeroes()
    openSwitchHeroHud()
  elif debugSelectedAction == 4: # Invincible
    if eventPlayer.hasStatus(Status.INVINCIBLE):
      eventPlayer.clearStatusEffect(Status.INVINCIBLE)
    else:
      eventPlayer.setStatusEffect(eventPlayer, Status.INVINCIBLE, INFINITY)
  elif debugSelectedAction == 5: # Teleport to shop
    eventPlayer.teleport(vect(-20.63, 6.50, -88.95))
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
  elif debugSelectedAction == 7: # Add money
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
  elif debugSelectedAction == 9: # Switch unlimit ultimates
    debugUnlimitUltimates = not debugUnlimitUltimates
  elif debugSelectedAction == 10:
    debugNoCD = not debugNoCD
  elif debugSelectedAction == 11: # Kill me
    damage(eventPlayer, null, INFINITY)
  elif debugSelectedAction == 12: # Enable/Disable Inspector
    if enabledInspector:
      enabledInspector = false
      disableInspector()
    else:
      enabledInspector = true
      enableInspector()
  
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


rule "[debug] effect for debugBotsSpawnPoint":
  @Condition debugBotsSpawnPoint

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    debugBotsSpawnPoint,
    1,
    EffectReeval.POSITION_AND_RADIUS
  )

  debugBotsSpawnPointEffect = getLastCreatedEntity()
  waitUntil(not ruleCondition, INFINITY)
  destroyEffect(debugBotsSpawnPointEffect)
  