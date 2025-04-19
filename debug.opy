#!mainFile "main.opy"

rule "[debug] Add money and health":
  @Event playerJoined
  @Team 1
  
  waitUntil(eventPlayer.hasSpawned(), 99999)
  eventPlayer.money += 1000000
  eventPlayer.health_stat += 500
  eventPlayer.setMaxHealth(eventPlayer.health_stat)
  # wait(5)
  # eventPlayer.startForcingHero(Hero.JUNO)


# rule "Teleport to shop":
#   @Condition roundNumber == 1
#   # todo: debug
#   createEffect(getAllPlayers(), Effect.SPHERE, Color.GREEN, vect(74.955, 13.858, -52.677), 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
#   createEffect(getAllPlayers(), Effect.SPHERE, Color.YELLOW, vect(75.589, 13.865, -50.533), 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
#   # wait(15)
#   getPlayers(Team.1)[0].teleport(vect(80.335, 13.93, -72.643))