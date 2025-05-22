#!mainFile "../main.opy"

#!define SPAWN_ZONE_A_SIZE 48
#!define SPAWN_ZONE_B_SIZE 35
#!define SPAWN_ZONE_C_SIZE 15
#!define SPAWN_ZONE_D_SIZE 30
#!define SPAWN_ZONE_E_SIZE 50
#!define SPAWN_ZONE_F_SIZE 45
#!define SPAWN_ZONE_G_SIZE 15

rule "Bots spawn points array A":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_A], SPAWN_ZONE_A_SIZE, Team.1)
  for spawnPI in range(5):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_A_OFFSET + spawnPI])


rule "Bots spawn points array A-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_A], SPAWN_ZONE_A_SIZE, Team.1)
  for spawnPI in range(5):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_A_OFFSET + spawnPI])


rule "Bots spawn points array B":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_B], SPAWN_ZONE_B_SIZE, Team.1)
  for spawnPI in range(8):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_B_OFFSET + spawnPI])


rule "Bots spawn points array B-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_B], SPAWN_ZONE_B_SIZE, Team.1)
  for spawnPI in range(8):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_B_OFFSET + spawnPI])


rule "Bots spawn points array C":
  @Condition unlockedLocations == 4
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_C], SPAWN_ZONE_C_SIZE, Team.1)
  spawnPointsList.append(vectList[VI.SPAWN_POINTS_C_OFFSET])


rule "Bots spawn points array C-":
  @Condition unlockedLocations == 4
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_C], SPAWN_ZONE_C_SIZE, Team.1)
  spawnPointsList.remove(vectList[VI.SPAWN_POINTS_C_OFFSET])


rule "Bots spawn points array D":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_D], SPAWN_ZONE_D_SIZE, Team.1)
  for spawnPI in range(7):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_D_OFFSET + spawnPI])


rule "Bots spawn points array D-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_D], SPAWN_ZONE_D_SIZE, Team.1)
  for spawnPI in range(7):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_D_OFFSET + spawnPI])


rule "Bots spawn points array E":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_E], SPAWN_ZONE_E_SIZE, Team.1)
  for spawnPI in range(5):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_E_OFFSET + spawnPI])


rule "Bots spawn points array E-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_E], SPAWN_ZONE_E_SIZE, Team.1)
  for spawnPI in range(5):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_E_OFFSET + spawnPI])


rule "Bots spawn points array F":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_F], SPAWN_ZONE_F_SIZE, Team.1)
  for spawnPI in range(6):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_F_OFFSET + spawnPI])


rule "Bots spawn points array F-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_F], SPAWN_ZONE_F_SIZE, Team.1)
  for spawnPI in range(6):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_F_OFFSET + spawnPI])


rule "Bots spawn points array G":
  @Condition getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_G], SPAWN_ZONE_G_SIZE, Team.1)
  for spawnPI in range(6):
    spawnPointsList.append(vectList[VI.SPAWN_POINTS_G_OFFSET + spawnPI])


rule "Bots spawn points array G-":
  @Condition not getRealPlayersInRadius(vectList[VI.SPAWN_POINTS_DETECTOR_G], SPAWN_ZONE_G_SIZE, Team.1)
  for spawnPI in range(6):
    spawnPointsList.remove(vectList[VI.SPAWN_POINTS_G_OFFSET + spawnPI])


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
    "Spawn Zone A\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_A]),
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
    "Spawn Zone B\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_B]),
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
    "Spawn Zone C\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_C]),
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
    "Spawn Zone D\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_D]),
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
    "Spawn Zone E\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_E]),
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
    "Spawn Zone F\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_F]),
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
    "Spawn Zone G\n{}".format(vectList[VI.SPAWN_POINTS_DETECTOR_G]),
    vectList[VI.SPAWN_POINTS_DETECTOR_G],
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY,
    Color.ORANGE
  )