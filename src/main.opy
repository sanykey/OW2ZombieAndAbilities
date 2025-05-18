#!include "variables.opy"
#!include "extensions.opy"
#!include "settings.opy"
#!include "utils.opy"
#!include "compressed vectors.opy"

rule "Game init":
  roundNumber = 0
  hiddenVector = vect(500, 25, 500)
  roundRemainingBots = 0
  unlockedLocations = 0
  spawnPointsList = [] # spawn points?
  matchIsOver = false
  isGameStarted = false

#!include "player joined.opy"
# #!include "ally bot.opy"
#!include "debug utils.opy"
#!include "debug.opy"
#!include "workshop settings.opy"

#!include "3p camera.opy"
#!include "buy hero stats.opy"
#!include "buy hero.opy"
#!include "hero abilities.opy"
#!include "locked area.opy"
#!include "restricted areas.opy"

#!include "player revive.opy"
#!include "secret shop.opy"
#!include "hud.opy"
#!include "damage and healing.opy"
#!include "money.opy"
#!include "orbs.opy"

#!include "match.opy"

#!include "bots/zombie events.opy"
#!include "bots/zombie behavior.opy"
#!include "bots/zombie spawn points.opy"
#!include "bots/widowmaker.opy"
#!include "bots/roadhog.opy"
#!include "bots/mauga.opy"
#!include "bots/echo.opy"
#!include "bots/rounds.opy"

#!include "portal.opy"
#!include "visuals.opy"
#!include "heroes abilities/all.opy"
#!include "heroes abilities/dva.opy"
#!include "heroes abilities/mercy.opy"
#!include "heroes abilities/widowmaker.opy"
#!include "heroes abilities/juno.opy"
#!include "heroes abilities/sombra.opy"
#!include "heroes abilities/reinhardt.opy"
#!include "heroes abilities/winston.opy"
#!include "heroes abilities/ramattra.opy"
#!include "heroes abilities/sigma.opy"
#!include "heroes abilities/symmetra.opy"
#!include "heroes abilities/mauga.opy"
#!include "heroes abilities/brigitte.opy"
#!include "heroes abilities/ana.opy"
#!include "heroes abilities/mccree.opy"
#!include "heroes abilities/kiriko.opy"