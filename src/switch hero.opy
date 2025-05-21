#!mainFile "main.opy"

def openSwitchHeroHud():
  @Name "Open Switch hero hud"

  eventPlayer.posBeforeChangeHero = eventPlayer.getPosition()
  eventPlayer.setRespawnTime(0)
  eventPlayer.stopForcingCurrentHero()
  eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getHero()))
  wait()
  eventPlayer.setAllowedHeroes(eventPlayer.purchasedHeroes)

  # eventPlayer.resetHeroAvailability()
  waitUntil(eventPlayer.hasSpawned(), INFINITY)
  eventPlayer.teleport(eventPlayer.posBeforeChangeHero)
  eventPlayer.setRespawnTime(INFINITY)
  eventPlayer.posBeforeChangeHero = false
