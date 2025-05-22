#!mainFile "./main.opy"

#!define SPAWN_ZONE_A_SIZE 48
#!define SPAWN_ZONE_B_SIZE 35
#!define SPAWN_ZONE_C_SIZE 15
#!define SPAWN_ZONE_D_SIZE 30
#!define SPAWN_ZONE_E_SIZE 50
#!define SPAWN_ZONE_F_SIZE 45
#!define SPAWN_ZONE_G_SIZE 15

def getHeroBuySpotsLen():
  @Name "Get hero buy spots len"
  zonesHeroBuyLen = (
    BUY_HERO_LEN_A if zonesHeroBuyOffset == BUY_HERO_OFFSET_A or zonesHeroBuyOffset == BUY_HERO_OFFSET_B else (
      BUY_HERO_LEN_C if zonesHeroBuyOffset == BUY_HERO_OFFSET_C else (
        BUY_HERO_LEN_D if zonesHeroBuyOffset == BUY_HERO_OFFSET_D else 0
      )
    )
  )

def createHeroBuySpotsTexts():
  @Name "Create hero buy spots"
  getHeroBuySpotsLen()

  smallMessage(getAllPlayers(), "Create hero spots offset: {} len:{}".format(zonesHeroBuyOffset, zonesHeroBuyLen))

  if zonesEffectsIds[zonesHeroBuyOffset]:
    smallMessage(hostPlayer, "[Error]: There were problems when creating spots for buying heroes (offset: {} len:{})".format(zonesHeroBuyOffset, zonesHeroBuyLen))

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

  smallMessage(getAllPlayers(), "Destroy hero spots {} {}".format(zonesHeroBuyOffset, zonesHeroBuyLen))

  for zonesI in range(zonesHeroBuyOffset, zonesHeroBuyOffset + zonesHeroBuyLen):
    destroyInWorldText(zonesEffectsIds[zonesI])
    zonesEffectsIds[zonesI] = null

rule "Activate or Deactivate zone A":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_A], SPAWN_ZONE_A_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_A_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_A
  createHeroBuySpotsTexts()

rule "Activate or Deactivate zone A-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_A], SPAWN_ZONE_A_SIZE, Team.1)
  for zonesI in range(5):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_A_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_A
  destroyHeroBuySpotsTexts()

rule "Activate or Deactivate zone B":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_B], SPAWN_ZONE_B_SIZE, Team.1)

  for zonesI in range(8):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_B_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_B
  createHeroBuySpotsTexts()


rule "Activate or Deactivate zone B-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_B], SPAWN_ZONE_B_SIZE, Team.1)

  for zonesI in range(8):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_B_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_B
  destroyHeroBuySpotsTexts()


rule "Activate or Deactivate zone C":
  @Condition unlockedLocations == 4
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_C], SPAWN_ZONE_C_SIZE, Team.1)
  spawnPointsList.append(vectList[VI.SPAWN_POINTS_C_OFFSET])


rule "Activate or Deactivate zone C-":
  @Condition unlockedLocations == 4
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_C], SPAWN_ZONE_C_SIZE, Team.1)
  spawnPointsList.remove(vectList[VI.SPAWN_POINTS_C_OFFSET])


rule "Activate or Deactivate zone D":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_D], SPAWN_ZONE_D_SIZE, Team.1)
  for zonesI in range(7):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_D_OFFSET + zonesI])


rule "Activate or Deactivate zone D-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_D], SPAWN_ZONE_D_SIZE, Team.1)

  for zonesI in range(7):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_D_OFFSET + zonesI])


rule "Activate or Deactivate zone E":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_E], SPAWN_ZONE_E_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_E_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_C
  createHeroBuySpotsTexts()


rule "Activate or Deactivate zone E-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_E], SPAWN_ZONE_E_SIZE, Team.1)

  for zonesI in range(5):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_E_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_C
  destroyHeroBuySpotsTexts()


rule "Activate or Deactivate zone F":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_F], SPAWN_ZONE_F_SIZE, Team.1)

  for zonesI in range(6):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_F_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_D
  createHeroBuySpotsTexts()

rule "Activate or Deactivate zone F-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_F], SPAWN_ZONE_F_SIZE, Team.1)

  for zonesI in range(6):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_F_OFFSET + zonesI])

  zonesHeroBuyOffset = BUY_HERO_OFFSET_D
  destroyHeroBuySpotsTexts()


rule "Activate or Deactivate zone G":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_G], SPAWN_ZONE_G_SIZE, Team.1)
  for zonesI in range(6):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_G_OFFSET + zonesI])


rule "Activate or Deactivate zone G-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_G], SPAWN_ZONE_G_SIZE, Team.1)
  for zonesI in range(6):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_G_OFFSET + zonesI])


rule "[debug]: Show spawn zones":

  # Zone A
  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.AQUA,
    vectList[VI.SPAWN_POINTS_DETECTOR_A],
    SPAWN_ZONE_A_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone A\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_A]),
    vectList[VI.SPAWN_POINTS_DETECTOR_A],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.AQUA
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GREEN,
    vectList[VI.SPAWN_POINTS_DETECTOR_B],
    SPAWN_ZONE_B_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone B\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_B]),
    vectList[VI.SPAWN_POINTS_DETECTOR_B],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GREEN
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.LIGHT_RED,
    vectList[VI.SPAWN_POINTS_DETECTOR_C],
    SPAWN_ZONE_C_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone C\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_C]),
    vectList[VI.SPAWN_POINTS_DETECTOR_C],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.LIGHT_RED
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.YELLOW,
    vectList[VI.SPAWN_POINTS_DETECTOR_D],
    SPAWN_ZONE_D_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone D\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_D]),
    vectList[VI.SPAWN_POINTS_DETECTOR_D],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.YELLOW
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.GRAY,
    vectList[VI.SPAWN_POINTS_DETECTOR_E],
    SPAWN_ZONE_E_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone E\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_E]),
    vectList[VI.SPAWN_POINTS_DETECTOR_E],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.GRAY
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.PURPLE,
    vectList[VI.SPAWN_POINTS_DETECTOR_F],
    SPAWN_ZONE_F_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone F\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_F]),
    vectList[VI.SPAWN_POINTS_DETECTOR_F],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.PURPLE
  )

  createEffect(
    getAllPlayers(),
    Effect.SPHERE,
    Color.ORANGE,
    vectList[VI.SPAWN_POINTS_DETECTOR_G],
    SPAWN_ZONE_G_SIZE,
    EffectReeval.VISIBILITY_AND_COLOR
  )
  createInWorldText(
    getPlayers(Team.1),
    "Zone G\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_G]),
    vectList[VI.SPAWN_POINTS_DETECTOR_G],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.ORANGE
  )