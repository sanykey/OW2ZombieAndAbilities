#!mainFile "main.opy"

playervar facingBeforeChangeHero
playervar beforeChangeHero
#!define CHANGE_HERO_MENU_TIMEOUT 30

def openSwitchHeroHud():
  @Name "Open Switch hero hud"

  pause3PCamera()
  wait()
  eventPlayer.posBeforeChangeHero = eventPlayer.getPosition()
  eventPlayer.facingBeforeChangeHero = eventPlayer.getFacingDirection()
  eventPlayer.beforeChangeHero = eventPlayer.getHero()
  eventPlayer.setRespawnTime(0)
  eventPlayer.stopForcingCurrentHero()
  eventPlayer.setAllowedHeroes(eventPlayer.purchasedHeroes.exclude(eventPlayer.getHero()))
  wait()
  eventPlayer.setAllowedHeroes(eventPlayer.purchasedHeroes)

  waitUntil(eventPlayer.hasSpawned(), CHANGE_HERO_MENU_TIMEOUT)
  if not eventPlayer.hasSpawned():
    eventPlayer.startForcingHero(eventPlayer.beforeChangeHero)
    heal(getPlayers(Team.1), null, INFINITY)
  eventPlayer.teleport(eventPlayer.posBeforeChangeHero)
  eventPlayer.setFacing(eventPlayer.facingBeforeChangeHero, Relativity.TO_WORLD)
  eventPlayer.setRespawnTime(PLAYER_RESPAWN_TIME)
  eventPlayer.posBeforeChangeHero = false
  wait(0.1)
  unpause3PCamera()
  setHeroType()
