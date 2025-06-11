#!mainFile "main.opy"

playervar facingBeforeChangeHero

def openSwitchHeroHud():
  @Name "Open Switch hero hud"

  pause3PCamera()
  wait()
  eventPlayer.posBeforeChangeHero = eventPlayer.getPosition()
  eventPlayer.facingBeforeChangeHero = eventPlayer.getFacingDirection()
  eventPlayer.setRespawnTime(0)
  eventPlayer.stopForcingCurrentHero()
  eventPlayer.setAllowedHeroes(getAllHeroes().exclude(eventPlayer.getHero()))
  wait()
  eventPlayer.setAllowedHeroes(eventPlayer.purchasedHeroes)

  # eventPlayer.resetHeroAvailability()
  waitUntil(eventPlayer.hasSpawned(), INFINITY)
  eventPlayer.teleport(eventPlayer.posBeforeChangeHero)
  eventPlayer.setFacing(eventPlayer.facingBeforeChangeHero, Relativity.TO_WORLD)
  eventPlayer.setRespawnTime(INFINITY)
  eventPlayer.posBeforeChangeHero = false
  wait(0.1)
  unpause3PCamera()
