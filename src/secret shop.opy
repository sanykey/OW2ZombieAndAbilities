#!mainFile "main.opy"

rule "[Secret shop] init":
  @Condition unlockedLocations == 4

  shopEffects = []
  enum SHOP_I:
    POWER_ON_EFFECT
    POWER_ON_TEXT
    ACTIVATOR_ICON
    ACTIVATOR_RING
    SHOP_RING
    SHOP_ICON
    ARROW_LEFT_TEXT

  # Create shop power on effects
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[VL_CONNECT_SHOP], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopEffects[SHOP_I.POWER_ON_EFFECT] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), "Connect Power", vectList[VL_CONNECT_SHOP], true/*=1*/, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.POWER_ON_TEXT] = getLastCreatedText()
  createInWorldText(getAllPlayers(), "#{}".format(iconString(Icon.ARROW_LEFT)), vectList[VL_CONNECT_SHOP_ARROW], true/*=1*/, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.ARROW_LEFT_TEXT] = getLastCreatedText()


rule "[Secret shop] Power switch ON":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_CONNECT_SHOP]) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopStatus == 0
  @Condition unlockedLocations == 4
  
  destroyEffect(shopEffects[SHOP_I.POWER_ON_EFFECT])
  destroyInWorldText(shopEffects[SHOP_I.ARROW_LEFT_TEXT])
  destroyInWorldText(shopEffects[SHOP_I.POWER_ON_TEXT])
  shopStatus = 1
  bigMessage(getAllPlayers(), "Power On")

rule "[Secret shop] Show shop activator":
  @Condition shopStatus == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopEffects[SHOP_I.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.NO), vect(123.312, 9.176, -27.364), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  shopEffects[SHOP_I.SHOP_ICON] = getLastCreatedText()
  wait(1)
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[VL_SHOP_ACTIVATOR], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopEffects[SHOP_I.ACTIVATOR_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), vectList[VL_SHOP_ACTIVATOR], 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.ACTIVATOR_ICON] = getLastCreatedText()

rule "[Secret shop] Use shop activator":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_SHOP_ACTIVATOR]) <= 1.5
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopStatus == 1
  
  shopStatus = 2


rule "[Secret shop] Show opened shop teleport area":
  @Condition shopStatus == 2
  
  destroyEffect(shopEffects[SHOP_I.SHOP_RING])
  destroyInWorldText(shopEffects[SHOP_I.SHOP_ICON])
  destroyEffect(shopEffects[SHOP_I.ACTIVATOR_RING])
  destroyInWorldText(shopEffects[SHOP_I.ACTIVATOR_ICON])
  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vectList[VL_SHOP_TELEPORTER_RING], 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopEffects[SHOP_I.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), "-> [Shop] <-", vectList[VL_SHOP_TELEPORTER_TEXT], 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  shopEffects[SHOP_I.SHOP_ICON] = getLastCreatedText()
  bigMessage(getAllPlayers(), "The secret shop has temporarily opened!")
  wait(60)
  shopStatus = 3


rule "[Secret shop] Close shop":
  @Condition shopStatus == 3
  
  destroyEffect(shopEffects[SHOP_I.SHOP_RING])
  destroyInWorldText(shopEffects[SHOP_I.SHOP_ICON])
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Offline]")
  wait(180)
  shopStatus = 1
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Online]")

rule "[Secret shop] Teleport players to secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_ENTER_SHOP_TELEPORT_FROM]) <= 5
  @Condition shopStatus == 2
  @Condition eventPlayer.isInSecretShop == false
  
  eventPlayer.isInSecretShop = true
  eventPlayer.teleport(vectList[VL_ENTER_SHOP_TELEPORT_TO])
  wait(30)
  if eventPlayer.isInSecretShop == false or isBotsDisabled:
    return
      
  smallMessage(eventPlayer, "Leaving in 5...")
  wait(true/*=1*/)
  smallMessage(eventPlayer, 4)
  wait(true/*=1*/)
  smallMessage(eventPlayer, 3)
  wait(true/*=1*/)
  smallMessage(eventPlayer, 2)
  wait(true/*=1*/)
  smallMessage(eventPlayer, 1)
  wait(true/*=1*/)
  if eventPlayer.isInSecretShop == false:
    return

  eventPlayer.teleport(vectList[VL_EXIT_SHOP_TELEPORT_TO])
  eventPlayer.isInSecretShop = false


rule "[Secret shop] Exit secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_EXIT_SHOP_TELEPORT_FROM]) <= 2.5
  
  eventPlayer.teleport(vectList[VL_EXIT_SHOP_TELEPORT_TO])
  eventPlayer.isInSecretShop = false

rule "[Secret shop] Auto heal secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VL_SHOP_HEAL_AREA]) < 12

  wait(true)
  heal(eventPlayer, null, INFINITY)
  wait(2)
