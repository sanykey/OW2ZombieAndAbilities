#!mainFile "main.opy"

globalvar playerEjectFromShop

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
  createInWorldText(getAllPlayers(), "Connect Power", vectList[VL_CONNECT_SHOP], true/*=1*/, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.POWER_ON_TEXT] = getLastCreatedText()
  createInWorldText(getAllPlayers(), "#{}".format(iconString(Icon.ARROW_LEFT)), vectList[VL_CONNECT_SHOP_ARROW], true/*=1*/, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.ARROW_LEFT_TEXT] = getLastCreatedText()


rule "[Secret shop] Power switch ON":
  @Event eachPlayer
  @Team 1
  @Condition shopStatus == 0
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition distance(eventPlayer, vectList[VL_CONNECT_SHOP]) <= 2
  
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
  createInWorldText(getAllPlayers(), iconString(Icon.SPIRAL), vectList[VL_SHOP_ACTIVATOR], 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.TURQUOISE)
  shopEffects[SHOP_I.ACTIVATOR_ICON] = getLastCreatedText()

rule "[Secret shop] Use shop activator":
  @Event eachPlayer
  @Team 1
  @Condition shopStatus == 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition distance(eventPlayer, vectList[VL_SHOP_ACTIVATOR]) <= 1.5
  
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
  @Condition shopStatus == 2
  @Condition distance(eventPlayer, vectList[VL_ENTER_SHOP_TELEPORT_FROM]) <= 5
  
  eventPlayer.teleport(vectList[VL_ENTER_SHOP_TELEPORT_TO])

rule "[Secret shop] Exit secret shop":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isInSecretShop
  @Condition distance(eventPlayer, vectList[VL_EXIT_SHOP_TELEPORT_FROM]) <= 2.5
  
  # teleport and prevent a player from falling into the shop teleport zone immediately after exiting the shop:
  eventPlayer.teleport(vectList[VL_EXIT_SHOP_TELEPORT_TO])
  eventPlayer.setStatusEffect(eventPlayer, Status.STUNNED, 0.05)
  wait()
  eventPlayer.setFacing(vect(0.85, false, -0.53), Relativity.TO_WORLD)

rule "[Secret shop] shop players management":
  playersInShop = [player for player in getPlayers(Team.1) if player.isInSecretShop]

  # Rule only works if the shop is closed or there is more than one player in Team 1
  if shopStatus != 3 or getNumberOfPlayers(Team.1) < 2 or not playersInShop or not getDeadPlayers(Team.1):
    goto lbl_0

  if len(getLivingPlayers(Team.1)) == len(playersInShop):
    playerEjectFromShop = random.choice([player for player in playersInShop if player.isInSecretShop < getTotalTimeElapsed()])
    if playerEjectFromShop:
      if playerEjectFromShop.posBeforeChangeHero:
        playerEjectFromShop.respawn()
        wait()
      playerEjectFromShop.teleport(vectList[VL_EXIT_SHOP_TELEPORT_TO])
      bigMessage(getAllPlayers(), "A random player was ejected from the closed shop to revive a fallen teammate")

  lbl_0:
  wait(1)
  loop()


rule "[Secret shop] Enter/Leave shop zone":
  @Event eachPlayer
  @Team 1

  if eventPlayer.posBeforeChangeHero or (eventPlayer.isAlive() and (distance(eventPlayer, vectList[VL_ACTIVATE_ZONE_DETECTOR_C]) < ZONE_C_SIZE or distance(eventPlayer, vectList[VL_SHOP_ZONE2]) < 5)):
    if not eventPlayer.isInSecretShop:
      eventPlayer.isInSecretShop = getTotalTimeElapsed() + 30
      heal(eventPlayer, null, INFINITY)
      UpdateCombatantsSub()
  elif eventPlayer.isInSecretShop:
    eventPlayer.isInSecretShop = false
    UpdateCombatantsSub()

  wait(1)
  loop()
