#!include "variables.opy"
#!include "settings.opy"
#!include "utils.opy"
#!include "compressed vectors.opy"

rule "Game init":
  roundNumber = 0
  hiddenVector = vect(500, 25, 500)
  roundRemainingBots = 0
  unlockedLocations = 0
  Y = [] # spawn points?
  matchIsOver = false
  zombiesflyIOnandOff = true

#!include "player joined.opy"
# #!include "ally bot.opy"
#!include "debug.opy"
#!include "rounds.opy"
#!include "3p camera.opy"
#!include "buy hero stats.opy"
#!include "buy hero.opy"
#!include "hero abilities.opy"
#!include "locked area.opy"
#!include "orbs.opy"
#!include "player spawn.opy"
#!include "player revive.opy"
#!include "secret shop.opy"
#!include "hud.opy"
#!include "damage and healing.opy"
#!include "zombie events.opy"
#!include "money.opy"
#!include "zombie behavior.opy"
#!include "portal.opy"
#!include "visuals.opy"
#!include "heroes abilities/all.opy"
#!include "heroes abilities/dva.opy"
#!include "heroes abilities/mercy.opy"
#!include "heroes abilities/widowmaker.opy"
#!include "heroes abilities/juno.opy"
#!include "heroes abilities/sombra.opy"
#!include "heroes abilities/reinhard.opy"
#!include "heroes abilities/winston.opy"
#!include "heroes abilities/ramattra.opy"
#!include "heroes abilities/sigma.opy"