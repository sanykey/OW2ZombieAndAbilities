#!include "settings.opy"
#!include "variables.opy"
#!include "debug.opy"
#!include "rounds.opy"
#!include "3p camera.opy"
#!include "buy hero stats.opy"
#!include "buy hero.opy"
#!include "hero abilities.opy"
#!include "locked area.opy"
#!include "orbs.opy"
#!include "player joined.opy"
#!include "player spawn.opy"
#!include "player revive.opy"
#!include "player hud.opy"
#!include "secret shop.opy"
#!include "zombie events.opy"
#!include "money.opy"
#!include "zombie behavior.opy"
#!include "portal.opy"
#!include "visuals.opy"
#!include "utils.opy"

rule "Game init":
  roundNumber = 0
  hidden_vector = vect(500, 25, 500)
  round_remaining_bots = 0
  unlocked_locations = 0
  T = [] # ??
  Y = [] # spawn points?
  match_is_over = false
  zombiesflyIOnandOff = true
