#!mainFile "main.opy"

rule "Secret shop init":
  @Condition unlockedLocations == 4

  shopState = []
  enum shopStateI:
    STATUS = 0
    POWER_ON_EFFECT = 1
    POWER_ON_TEXT = 2
    ACTIVATOR_ICON = 3
    ACTIVATOR_RING = 4
    SHOP_RING = 5
    SHOP_ICON = 6

  # Create shop power on effects
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[vectListI.CONNECT_SHOP], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[shopStateI.POWER_ON_EFFECT] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), l"{0} {1}".format(l"Connect", l"Power"), vectList[vectListI.CONNECT_SHOP], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopState[shopStateI.POWER_ON_TEXT] = getLastCreatedText()
  createInWorldText(getAllPlayers(), l"#{0}".format(iconString(Icon.ARROW_LEFT)), vectList[vectListI.CONNECT_SHOP_ARROW], 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)

  # Create shop exit effects
  createInWorldText(getAllPlayers(), "[Exit]", vectList[vectListI.EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  createInWorldText(getAllPlayers(), "[No Exit]", vectList[vectListI.NO_EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)

rule "Power switch ON":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.CONNECT_SHOP]) <= 2
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopState[shopStateI.STATUS] == 0
  @Condition unlockedLocations == 4
  
  destroyEffect(shopState[shopStateI.POWER_ON_EFFECT])
  destroyInWorldText(shopState[shopStateI.POWER_ON_TEXT])
  shopState[shopStateI.STATUS] = 1
  bigMessage(getAllPlayers(), l"{0} {1}".format(l"Power", l"On"))

rule "Show shop activator":
  @Condition shopState[shopStateI.STATUS] == 1
  
  createEffect(getAllPlayers(), Effect.RING, Color.RED, vect(123.312, 9.176, -27.364), 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[shopStateI.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.NO), vect(123.312, 9.176, -27.364), 4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
  shopState[shopStateI.SHOP_ICON] = getLastCreatedText()
  wait(1)
  createEffect(getAllPlayers(), Effect.RING, Color.TURQUOISE, vectList[vectListI.SHOP_ACTIVATOR], 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[shopStateI.ACTIVATOR_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), vectList[vectListI.SHOP_ACTIVATOR], 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopState[shopStateI.ACTIVATOR_ICON] = getLastCreatedText()

rule "Use shop activator":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.SHOP_ACTIVATOR]) <= 1.5
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition shopState[shopStateI.STATUS] == 1
  
  shopState[shopStateI.STATUS] = 2


rule "Show opened shop teleport area":
  @Condition shopState[shopStateI.STATUS] == 2
  
  destroyEffect(shopState[shopStateI.SHOP_RING])
  destroyInWorldText(shopState[shopStateI.SHOP_ICON])
  destroyEffect(shopState[shopStateI.ACTIVATOR_RING])
  destroyInWorldText(shopState[shopStateI.ACTIVATOR_ICON])
  createEffect(getAllPlayers(), Effect.RING, Color.GREEN, vectList[vectListI.SHOP_TELEPORTER_RING], 5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
  shopState[shopStateI.SHOP_RING] = getLastCreatedEntity()
  createInWorldText(getAllPlayers(), "-> [Shop] <-", vectList[vectListI.SHOP_TELEPORTER_TEXT], 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN)
  shopState[shopStateI.SHOP_ICON] = getLastCreatedText()
  bigMessage(getAllPlayers(), "The secret shop has temporarily opened!")
  wait(60)
  shopState[shopStateI.STATUS] = 3


rule "Close shop":
  @Condition shopState[shopStateI.STATUS] == 3
  
  destroyEffect(shopState[shopStateI.SHOP_RING])
  destroyInWorldText(shopState[shopStateI.SHOP_ICON])
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Offline]")
  wait(180)
  shopState[shopStateI.STATUS] = 1
  bigMessage(getPlayers(Team.1), "Secret Shop Switch -> [Online]")

rule "Teleport players to secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.ENTER_SHOP_TELEPORT_FROM]) <= 5
  @Condition shopState[shopStateI.STATUS] == 2
  @Condition eventPlayer.F == false
  @Condition eventPlayer.isInSecretShop == false
  
  eventPlayer.isInSecretShop = true
  eventPlayer.teleport(vectList[vectListI.ENTER_SHOP_TELEPORT_TO])
  wait(30)
  if eventPlayer.isInSecretShop == false:
      goto lbl_0
  smallMessage(eventPlayer, "Leaving in 5...")
  wait(1)
  smallMessage(eventPlayer, 4)
  wait(1)
  smallMessage(eventPlayer, 3)
  wait(1)
  smallMessage(eventPlayer, 2)
  wait(1)
  smallMessage(eventPlayer, 1)
  wait(1)
  lbl_0:
  if eventPlayer.isInSecretShop == false:
      goto lbl_1
  eventPlayer.teleport(vectList[vectListI.EXIT_SHOP_TELEPORT_TO])
  lbl_1:
  eventPlayer.isInSecretShop = false


rule "Exit secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.EXIT_SHOP_TELEPORT_FROM]) <= 2.5
  
  eventPlayer.teleport(vectList[vectListI.EXIT_SHOP_TELEPORT_TO])
  eventPlayer.isInSecretShop = false

rule "Auto heal secret shop":
  @Event eachPlayer
  @Team 1
  @Condition distance(eventPlayer, vectList[vectListI.SHOP_HEAL_AREA]) < 12

  wait(1)
  heal(eventPlayer, null, INFINITY)
  wait(2)
