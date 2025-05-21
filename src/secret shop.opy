#!mainFile "main.opy"

rule "Secret shop init":
  @Condition unlockedLocations == 4

  shopState = []
  enum SHOP_I:
    STATUS
    POWER_ON_EFFECT
    POWER_ON_TEXT
    ACTIVATOR_ICON
    ACTIVATOR_RING
    SHOP_RING
    SHOP_ICON
    ARROW_LEFT_TEXT

  # Create shop power on effects
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[VI.CONNECT_SHOP], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[SHOP_I.POWER_ON_EFFECT] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), l"{0} {1}".format(l"Connect", l"Power"), vectList[VI.CONNECT_SHOP], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopState[SHOP_I.POWER_ON_TEXT] = getLastCreatedText()
  createInWorldText(getAllPlayers(), l"#{0}".format(iconString(Icon.ARROW_LEFT)), vectList[VI.CONNECT_SHOP_ARROW], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopState[SHOP_I.ARROW_LEFT_TEXT] = getLastCreatedText()

  # Create shop exit effects
  createInWorldText(getAllPlayers(), "[Exit]", vectList[VI.EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  createInWorldText(getAllPlayers(), "[No Exit]", vectList[VI.NO_EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)

rule "Power switch ON":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.CONNECT_SHOP]) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopState[SHOP_I.STATUS] == 0
  @Condition unlockedLocations == 4
  
  destroyEffect(shopState[SHOP_I.POWER_ON_EFFECT])
  destroyInWorldText(shopState[SHOP_I.ARROW_LEFT_TEXT])
  destroyInWorldText(shopState[SHOP_I.POWER_ON_TEXT])
  shopState[SHOP_I.STATUS] = 1
  bigMessage(getAllPlayers(), l"{0} {1}".format(l"Power", l"On"))

rule "Show shop activator":
  @Condition shopState[SHOP_I.STATUS] == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[SHOP_I.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.NO), vect(123.312, 9.176, -27.364), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  shopState[SHOP_I.SHOP_ICON] = getLastCreatedText()
  wait(1)
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[VI.SHOP_ACTIVATOR], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[SHOP_I.ACTIVATOR_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), vectList[VI.SHOP_ACTIVATOR], 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopState[SHOP_I.ACTIVATOR_ICON] = getLastCreatedText()

rule "Use shop activator":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.SHOP_ACTIVATOR]) <= 1.5
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopState[SHOP_I.STATUS] == 1
  
  shopState[SHOP_I.STATUS] = 2


rule "Show opened shop teleport area":
  @Condition shopState[SHOP_I.STATUS] == 2
  
  destroyEffect(shopState[SHOP_I.SHOP_RING])
  destroyInWorldText(shopState[SHOP_I.SHOP_ICON])
  destroyEffect(shopState[SHOP_I.ACTIVATOR_RING])
  destroyInWorldText(shopState[SHOP_I.ACTIVATOR_ICON])
  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vectList[VI.SHOP_TELEPORTER_RING], 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[SHOP_I.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), "-> [Shop] <-", vectList[VI.SHOP_TELEPORTER_TEXT], 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  shopState[SHOP_I.SHOP_ICON] = getLastCreatedText()
  bigMessage(getAllPlayers(), "The secret shop has temporarily opened!")
  wait(60)
  shopState[SHOP_I.STATUS] = 3


rule "Close shop":
  @Condition shopState[SHOP_I.STATUS] == 3
  
  destroyEffect(shopState[SHOP_I.SHOP_RING])
  destroyInWorldText(shopState[SHOP_I.SHOP_ICON])
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Offline]")
  wait(180)
  shopState[SHOP_I.STATUS] = 1
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Online]")

rule "Teleport players to secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.ENTER_SHOP_TELEPORT_FROM]) <= 5
  @Condition shopState[SHOP_I.STATUS] == 2
  @Condition eventPlayer.isInSecretShop == false
  
  eventPlayer.isInSecretShop = true
  eventPlayer.teleport(vectList[VI.ENTER_SHOP_TELEPORT_TO])
  wait(30)
  if eventPlayer.isInSecretShop == false or isBotsDisabled:
    return
      
  smallMessage(eventPlayer, "Leaving in 5...")
  wait(true)
  smallMessage(eventPlayer, 4)
  wait(true)
  smallMessage(eventPlayer, 3)
  wait(true)
  smallMessage(eventPlayer, 2)
  wait(true)
  smallMessage(eventPlayer, true)
  wait(true)
  if eventPlayer.isInSecretShop == false:
    return

  eventPlayer.teleport(vectList[VI.EXIT_SHOP_TELEPORT_TO])
  eventPlayer.isInSecretShop = false


rule "Exit secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.EXIT_SHOP_TELEPORT_FROM]) <= 2.5
  
  eventPlayer.teleport(vectList[VI.EXIT_SHOP_TELEPORT_TO])
  eventPlayer.isInSecretShop = false

rule "Auto heal secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[VI.SHOP_HEAL_AREA]) < 12

  wait(true)
  heal(eventPlayer, null, INFINITY)
  wait(2)
