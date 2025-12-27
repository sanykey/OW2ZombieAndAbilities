#!mainFile "./main.opy"

globalvar zonesI
globalvar zonesHeroBuyOffset
globalvar zonesHeroBuyLen
globalvar zonesEffectsIds = []
globalvar isZoneActiveD
globalvar isZoneActiveF
globalvar isZoneActiveG

#!define ZONE_A_SIZE 48
#!define ZONE_B_SIZE 35
#!define ZONE_C_SIZE 15
#!define ZONE_D_SIZE 30
#!define ZONE_E_SIZE 50
#!define ZONE_F_SIZE 45
#!define ZONE_G_SIZE 15
#!define ZONE_H_SIZE 50
#!define ZONE_I_SIZE 27

rule "Init buyHeroUpgradesData":
  buyHeroUpgradesData = [
    [f"HP (+{HEALTH_UPGRADE_AMOUNT}%): ${UPGRADE_PRICE}", Color.LIME_GREEN, vectList[VL_BUY_HP]],
    [f"Damage (+{DAMAGE_UPGRADE_AMOUNT}%): ${UPGRADE_PRICE}", Color.RED, vectList[VL_BUY_DAMAGE]],
    [f"Healing Dealt (+{HEALING_UPGRADE_AMOUNT}%): ${UPGRADE_PRICE}", Color.YELLOW, vectList[VL_BUY_HEALING]],
    [f"+{TEAM_ARMOR_UPGRADE_AMOUNT} Armor [Team]: ${TEAM_UPGRADE_PRICE}", Color.ORANGE, vectList[VL_BUY_TEAM_ARMOR]],
    ["Change to a purchased hero", Color.WHITE, vectList[VL_CHANGE_HERO]],
    ["Refund", Color.WHITE, vectList[VL_REFUND]],
  ]

def getHeroBuySpotsLen():
  @Name "Get hero buy spots len"
  zonesHeroBuyLen = (
    VL_BUY_HERO_SPOTS_A_LEN if zonesHeroBuyOffset == BUY_HERO_OFFSET_A else (
      VL_BUY_HERO_SPOTS_B_LEN if zonesHeroBuyOffset == BUY_HERO_OFFSET_B else (
        VL_BUY_HERO_SPOTS_E_LEN if zonesHeroBuyOffset == BUY_HERO_OFFSET_E else (
          VL_BUY_HERO_SPOTS_I_LEN if zonesHeroBuyOffset == BUY_HERO_OFFSET_I else (
            VL_BUY_HERO_SPOTS_H_LEN if zonesHeroBuyOffset == BUY_HERO_OFFSET_H else 0
          )
        )
      )
    )
  )

def createHeroBuySpotsTexts():
  @Name "Create hero buy spots"
  getHeroBuySpotsLen()

  if zonesEffectsIds[zonesHeroBuyOffset]:
    smallMessage(hostPlayer, "[Error]: There were problems when creating spots for buying heroes (offset: {} len:{})".format(zonesHeroBuyOffset, zonesHeroBuyLen))
    return

  for zonesI in range(zonesHeroBuyOffset, zonesHeroBuyOffset + zonesHeroBuyLen):
    createInWorldText(
      getPlayers(Team.1),
      "Buy {} ${}\n\n\u3000\u3000\u202f\u202f\u202f\u202f\u202f<TX C00000000021660>".format(
        (
          "<TX C00000000004EAB>{}".format(heroIcon(Hero.DVA)) if heroesShopData[zonesI][0] == Hero.DVA else heroIcon(heroesShopData[zonesI][0])
        ),
        heroesShopData[zonesI][2]
      ),
      heroesShopData[zonesI][true],
      true,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY
    )
    zonesEffectsIds[zonesI] = getLastCreatedText()

def destroyHeroBuySpotsTexts():
  getHeroBuySpotsLen()

  for zonesI in range(zonesHeroBuyOffset, zonesHeroBuyOffset + zonesHeroBuyLen):
    destroyInWorldText(zonesEffectsIds[zonesI])
    zonesEffectsIds[zonesI] = null


rule "Activate or Deactivate zones":
  # Activate zone A:
  zonesHeroBuyOffset = BUY_HERO_OFFSET_A
  if not zonesEffectsIds[zonesHeroBuyOffset] and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_A], ZONE_A_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_A_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_A_OFFSET + zonesI])
    createHeroBuySpotsTexts()
  # Deactivate zone A:
  elif zonesEffectsIds[zonesHeroBuyOffset] and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_A], ZONE_A_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_A_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_A_OFFSET + zonesI])
    destroyHeroBuySpotsTexts()

  # Activate zone B:
  zonesHeroBuyOffset = BUY_HERO_OFFSET_B
  if not zonesEffectsIds[zonesHeroBuyOffset] and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_B], ZONE_B_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_B_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_B_OFFSET + zonesI])
    createHeroBuySpotsTexts()
  # Deactivate zone B:
  elif zonesEffectsIds[zonesHeroBuyOffset] and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_B], ZONE_B_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_B_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_B_OFFSET + zonesI])
    destroyHeroBuySpotsTexts()

  # Activate zone C (Shop):
  if not secretShopZoneEffects and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_C], ZONE_C_SIZE, Team.1):
    # create effects for Secret shop upgrades spots:
    for zonesI in range(len(buyHeroUpgradesData)):
      createEffect(
        getPlayers(Team.1),
        Effect.RING,
        buyHeroUpgradesData[zonesI][true],
        buyHeroUpgradesData[zonesI][2],
        1.5,
        EffectReeval.VISIBILITY
      )
      secretShopZoneEffects.append(getLastCreatedEntity())
      createInWorldText(
        getPlayers(Team.1),
        buyHeroUpgradesData[zonesI][0],
        buyHeroUpgradesData[zonesI][2],
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY,
        buyHeroUpgradesData[zonesI][true]
      )
      secretShopZoneEffects.append(getLastCreatedText())

    # Create shop exit and tips effects
    createInWorldText(
      getAllPlayers(), "[Exit]", vectList[VL_EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN
    )
    secretShopZoneEffects.append(getLastCreatedText())
    createInWorldText(
      getAllPlayers(), "[No Exit]", vectList[VL_NO_EXIT_SHOP_TEXT], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED
    )
    secretShopZoneEffects.append(getLastCreatedText())

    createInWorldText(
      getAllPlayers(), f"[Interact] to buy\n[Interact] + [Crouch] to buy x{BUNCH_BUY_MULTIPLY}", vectList[VL_SHOP_TIP], 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE
    )
    secretShopZoneEffects.append(getLastCreatedText())

  # [shop] Deactivate zone C:
  elif secretShopZoneEffects and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_C], ZONE_C_SIZE, Team.1):
    # destroy effects for Secret shop upgrades spots:
    for zonesI in range(0, len(secretShopZoneEffects), 2):
      # destroy shop exit and tip text effects
      if zonesI > (len(secretShopZoneEffects) - 4):
        destroyInWorldText(secretShopZoneEffects[zonesI])
        destroyInWorldText(secretShopZoneEffects[zonesI + 1])
        destroyInWorldText(secretShopZoneEffects[zonesI + 2])
        break

      destroyEffect(secretShopZoneEffects[zonesI])
      destroyInWorldText(secretShopZoneEffects[zonesI + 1])

    secretShopZoneEffects = []

  # Activate zone D:
  if not isZoneActiveD and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_D], ZONE_D_SIZE, Team.1):
    isZoneActiveD = true
    for zonesI in range(VL_SPAWN_POINTS_D_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_D_OFFSET + zonesI])
  # Deactivate zone D:
  elif isZoneActiveD and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_D], ZONE_D_SIZE, Team.1):
    isZoneActiveD = false
    for zonesI in range(VL_SPAWN_POINTS_D_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_D_OFFSET + zonesI])
  
  # Activate zone E:
  zonesHeroBuyOffset = BUY_HERO_OFFSET_E
  if not zonesEffectsIds[zonesHeroBuyOffset] and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_E], ZONE_E_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_E_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_E_OFFSET + zonesI])
    createHeroBuySpotsTexts()
  # Deactivate zone E:
  elif zonesEffectsIds[zonesHeroBuyOffset] and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_E], ZONE_E_SIZE, Team.1):
    for zonesI in range(VL_SPAWN_POINTS_E_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_E_OFFSET + zonesI])
    destroyHeroBuySpotsTexts()

  # Activate zone F:
  if not isZoneActiveF and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_F], ZONE_F_SIZE, Team.1):
    isZoneActiveF = true
    for zonesI in range(VL_SPAWN_POINTS_F_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_F_OFFSET + zonesI])
  # Deactivate zone F:
  elif isZoneActiveF and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_F], ZONE_F_SIZE, Team.1):
    isZoneActiveF = false
    for zonesI in range(VL_SPAWN_POINTS_F_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_F_OFFSET + zonesI])

  # Activate zone G:
  if not isZoneActiveG and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_G], ZONE_G_SIZE, Team.1):
    isZoneActiveG = true
    for zonesI in range(VL_SPAWN_POINTS_G_LEN):
      spawnPointsList.append(vectList[VL_SPAWN_POINTS_G_OFFSET + zonesI])
  # Deactivate zone G:
  elif isZoneActiveG and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_G], ZONE_G_SIZE, Team.1):
    isZoneActiveG = false
    for zonesI in range(VL_SPAWN_POINTS_G_LEN):
      spawnPointsList.remove(vectList[VL_SPAWN_POINTS_G_OFFSET + zonesI])


  # Activate zone H:
  zonesHeroBuyOffset = BUY_HERO_OFFSET_H
  if not zonesEffectsIds[zonesHeroBuyOffset] and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_H], ZONE_H_SIZE, Team.1):
    createHeroBuySpotsTexts()
  # Deactivate zone H:
  elif zonesEffectsIds[zonesHeroBuyOffset] and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_H], ZONE_H_SIZE, Team.1):
    destroyHeroBuySpotsTexts()

  # Activate zone I:
  zonesHeroBuyOffset = BUY_HERO_OFFSET_I
  if not zonesEffectsIds[zonesHeroBuyOffset] and getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_I], ZONE_I_SIZE, Team.1):
    createHeroBuySpotsTexts()
  # Deactivate zone I:
  elif zonesEffectsIds[zonesHeroBuyOffset] and not getPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_I], ZONE_I_SIZE, Team.1):
    destroyHeroBuySpotsTexts()

  wait(1)
  loop()


rule "Teleport from restricted areas":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isAlive() and eventPlayer.hasSpawned()
    if not eventPlayer.posBeforeChangeHero and distance(eventPlayer, vect(101.397, 14.21, -110.834)) < 14: # vanilla Team.1 spawn room 
      eventPlayer.teleport(vect(-27.412, 2, -12.564))
    if zonesEffectsIds[BUY_HERO_OFFSET_E]:
      if distance(eventPlayer, vect(83.1, 11.88, -111.642)) < 3: # vanilla Team.1 spawn room entrance
        eventPlayer.teleport(vect(79.382, 13.147, -110.093))
      if distance(eventPlayer, vect(89.731, 13.228, -102.377)) < 2: # vanilla Team.1 spawn room second entrance
        eventPlayer.teleport(vect(86.903, 14.219, -101.238))
  wait(0.3)
  if ruleCondition:
    loop()

rule "Restricted areas affects":
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(89.62, 13.973, -102.524), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY)
  createInWorldText(getPlayers(Team.1), iconString(Icon.NO), vect(81.612, 12.094, -110.819), 1.7, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.ROSE)
