#!mainFile "./main.opy"

#!define ZONE_A_SIZE 48
#!define ZONE_B_SIZE 35
#!define ZONE_C_SIZE 15
#!define ZONE_D_SIZE 30
#!define ZONE_E_SIZE 50
#!define ZONE_F_SIZE 45
#!define ZONE_G_SIZE 15
#!define ZONE_H_SIZE 50
#!define ZONE_I_SIZE 27

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

rule "Activate or Deactivate zone A":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_A], ZONE_A_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_A_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_A
  createHeroBuySpotsTexts()

rule "Activate or Deactivate zone A-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_A], ZONE_A_SIZE, Team.1)
  for zonesI in range(5):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_A_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_A
  destroyHeroBuySpotsTexts()

rule "Activate or Deactivate zone B":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_B], ZONE_B_SIZE, Team.1)

  for zonesI in range(8):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_B_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_B
  createHeroBuySpotsTexts()


rule "Activate or Deactivate zone B-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_B], ZONE_B_SIZE, Team.1)

  for zonesI in range(8):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_B_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_B
  destroyHeroBuySpotsTexts()


rule "[Secret shop] Activate or Deactivate zone C":
  @Condition unlockedLocations == 4
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_C], ZONE_C_SIZE, Team.1)
  
  spawnPointsList.append(vectList[VL_SPAWN_POINTS_C_OFFSET])

  # create effects for Secret shop upgrades spots:
  if buyHeroUpgradesEffectsIds:
    smallMessage(hostPlayer, "[Error]: There were problems when creating spots for buying upgrades")
    return

  for zonesI in range(len(buyHeroUpgradesData)):
    createEffect(
      getPlayers(Team.1),
      Effect.RING,
      buyHeroUpgradesData[zonesI][true],
      buyHeroUpgradesData[zonesI][2],
      1.5,
      EffectReeval.VISIBILITY
    )
    buyHeroUpgradesEffectsIds.append(getLastCreatedEntity())
    createInWorldText(
      getPlayers(Team.1),
      buyHeroUpgradesData[zonesI][0],
      buyHeroUpgradesData[zonesI][2],
      1,
      Clip.SURFACES,
      WorldTextReeval.VISIBILITY,
      buyHeroUpgradesData[zonesI][true]
    )
    buyHeroUpgradesEffectsIds.append(getLastCreatedText())


rule "[Secret shop] Activate or Deactivate zone C-":
  @Condition unlockedLocations == 4
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_C], ZONE_C_SIZE, Team.1)

  spawnPointsList.remove(vectList[VL_SPAWN_POINTS_C_OFFSET])

  # destroy effects for Secret shop upgrades spots:
  for zonesI in range(0, len(buyHeroUpgradesEffectsIds), 2):
    destroyEffect(buyHeroUpgradesEffectsIds[zonesI])
    destroyInWorldText(buyHeroUpgradesEffectsIds[zonesI + 1])
  buyHeroUpgradesEffectsIds = []


rule "Activate or Deactivate zone D":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_D], ZONE_D_SIZE, Team.1)
  for zonesI in range(7):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_D_OFFSET + zonesI])


rule "Activate or Deactivate zone D-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_D], ZONE_D_SIZE, Team.1)

  for zonesI in range(7):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_D_OFFSET + zonesI])


rule "Activate or Deactivate zone E":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_E], ZONE_E_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_E_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_E
  createHeroBuySpotsTexts()


rule "Activate or Deactivate zone E-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_E], ZONE_E_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_E_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_E
  destroyHeroBuySpotsTexts()


rule "Activate or Deactivate zone F":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_F], ZONE_F_SIZE, Team.1)

  for zonesI in range(6):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_F_OFFSET + zonesI])


rule "Activate or Deactivate zone F-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_F], ZONE_F_SIZE, Team.1)

  for zonesI in range(6):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_F_OFFSET + zonesI])


rule "Activate or Deactivate zone G":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_G], ZONE_G_SIZE, Team.1)
  for zonesI in range(6):
    spawnPointsList.append(vectList[VL_SPAWN_POINTS_G_OFFSET + zonesI])


rule "Activate or Deactivate zone G-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_G], ZONE_G_SIZE, Team.1)
  for zonesI in range(6):
    spawnPointsList.remove(vectList[VL_SPAWN_POINTS_G_OFFSET + zonesI])

rule "Activate or Deactivate zone H":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_H], ZONE_H_SIZE, Team.1)

  zonesHeroBuyOffset = BUY_HERO_OFFSET_H
  createHeroBuySpotsTexts()

rule "Activate or Deactivate zone H-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_H], ZONE_H_SIZE, Team.1)

  zonesHeroBuyOffset = BUY_HERO_OFFSET_H
  destroyHeroBuySpotsTexts()

rule "Activate or Deactivate zone I":
  @Condition getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_I], ZONE_I_SIZE, Team.1)

  zonesHeroBuyOffset = BUY_HERO_OFFSET_I
  createHeroBuySpotsTexts()

rule "Activate or Deactivate zone I-":
  @Condition not getRealPlayersInRadius(vectList[VL_ACTIVATE_ZONE_DETECTOR_I], ZONE_I_SIZE, Team.1)

  zonesHeroBuyOffset = BUY_HERO_OFFSET_I
  destroyHeroBuySpotsTexts()


/*
rule "[debug]: Show spawn zones":
  # Zone A
  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.AQUA,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_A],
    ZONE_A_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone A\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_A]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_A],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.AQUA
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_B],
    ZONE_B_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone B\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_B]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_B],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GREEN
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.LIGHT_RED,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_C],
    ZONE_C_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone C\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_C]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_C],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.LIGHT_RED
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.YELLOW,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_D],
    ZONE_D_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone D\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_D]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_D],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.YELLOW
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GRAY,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_E],
    ZONE_E_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone E\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_E]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_E],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GRAY
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.PURPLE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_F],
    ZONE_F_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone F\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_F]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_F],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.PURPLE
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.ORANGE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_G],
    ZONE_G_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone G\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_G]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_G],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.ORANGE
  )
  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.BLUE,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_H],
    ZONE_H_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone H\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_H]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_H],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.BLUE
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.RED,
    vectList[VL_ACTIVATE_ZONE_DETECTOR_I],
    ZONE_I_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone I\n{}".format(vectList[VL_ACTIVATE_ZONE_DETECTOR_I]),
    vectList[VL_ACTIVATE_ZONE_DETECTOR_I],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.RED
  )
#*/