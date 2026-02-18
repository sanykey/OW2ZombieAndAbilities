#!mainFile "main.opy"

def UpdateCombatantsSub():
  @Name "Sub: Update combatants"
  combatants = [player for player in getPlayers(Team.1) if player.isAlive() and player.hasSpawned() and not player.isInSecretShop]

# from [attach p2p.opy]
def DetachP2PSub():
  @Name "Sub: [Ana][Orisa][attach p2p] Detach P2P"
  if eventPlayer.attach2p[Attach2P.CHILD]:
    eventPlayer.tmp0 = eventPlayer.attach2p[Attach2P.CHILD]
    eventPlayer.tmp1 = eventPlayer
  else:
    eventPlayer.tmp0 = eventPlayer
    eventPlayer.tmp1 = eventPlayer.attach2p[Attach2P.PARENT]

  # clear child
  eventPlayer.tmp0.detach()
  eventPlayer.tmp0.clearStatusEffect(Status.INVINCIBLE)
  smallMessage(eventPlayer.tmp0, "You have detached")
  eventPlayer.tmp0.attach2p = []

  # clear parent
  eventPlayer.tmp1.attach2p[Attach2P.CHILD] = null

macro Player.resetBotStuckTimes(self):
  self.money__botStuckTimes = false
  self.botWantsWallPhasePoints = false

def SetHeroTypeSub():
  @Name "Sub: setHeroType"
  if eventPlayer.getCurrentHero() in getTankHeroes():
    eventPlayer.heroType = HeroType.TANK
  elif eventPlayer.getCurrentHero() in getSupportHeroes():
    eventPlayer.heroType = HeroType.SUPPORT
  else:
    eventPlayer.heroType = HeroType.DAMAGE


macro Player.earnMoney(self, amount=0):
  self.money__botStuckTimes += amount
  self.moneyTotal__botOldPosition += amount

macro Player.abilityCDHud(self, text, effectVar):
  hudText(
    self if not self.isHeroDescriptionOpened else null,
    null,
    text,
    null,
    HudPosition.TOP,
    2.5,
    null,
    Color.WHITE,
    null
  )
  effectVar = getLastCreatedText()

rule "Version and ServerLoad info":
  # Disable inspector recording
  disableInspector()

  hudSubheader(
    localPlayer if localPlayer == hostPlayer or localPlayer.developer else null,
    "Server load: {} | Max: {} | Cur: {}
    ".format(
      getAverageServerLoad(),
      getPeakServerLoad(),
      getServerLoad()
    ),
    HudPosition.RIGHT,
    -5,
    rgb(255, 280 - getAverageServerLoad(), 0),
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

  hudText(
    localPlayer,
    null,
    "<fgecbe52FF>8X63K</fg>. {}\nHold [{}] to switch camera\nPress [{}] to interact/buy".format(MODE_VERSION, inputBindingString(Button.MELEE), inputBindingString(Button.INTERACT)),
    null,
    HudPosition.RIGHT,
    -10,
    null,
    Color.WHITE,
    null,
    HudReeval.NONE
  )

rule "Server anti-crash system":
  @Condition getServerLoad() > 240
  
  wait(0.5, Wait.ABORT_WHEN_FALSE)
  if not ruleCondition:
    return

  smallMessage(getAllPlayers(), "Anti crash enabled")
  setSlowMotion(60)
  waitUntil(getServerLoad() < 200, INFINITY)
  setSlowMotion(100)

# globalvar newHero
# rule "Get new hero":
#   newHero = getAllHeroes().exclude([
#     Hero.ANA,
#     Hero.ASHE,
#     Hero.BAPTISTE,
#     Hero.BASTION,
#     Hero.BRIGITTE,
#     Hero.CASSIDY,
#     Hero.DOOMFIST,
#     Hero.DVA,
#     Hero.ECHO,
#     Hero.FREJA,
#     Hero.GENJI,
#     Hero.HANZO,
#     Hero.HAZARD,
#     Hero.ILLARI,
#     Hero.JUNKER_QUEEN,
#     Hero.JUNKRAT,
#     Hero.JUNO,
#     Hero.KIRIKO,
#     Hero.LIFEWEAVER,
#     Hero.LUCIO,
#     Hero.MAUGA,
#     Hero.MEI,
#     Hero.MERCY,
#     Hero.MOIRA,
#     Hero.ORISA,
#     Hero.PHARAH,
#     Hero.RAMATTRA,
#     Hero.REAPER,
#     Hero.REINHARDT,
#     Hero.ROADHOG,
#     Hero.SIGMA,
#     Hero.SOJOURN,
#     Hero.SOLDIER,
#     Hero.SOMBRA,
#     Hero.SYMMETRA,
#     Hero.TORBJORN,
#     Hero.TRACER,
#     Hero.VENTURE,
#     Hero.WIDOWMAKER,
#     Hero.WINSTON,
#     Hero.WRECKING_BALL,
#     Hero.WUYANG,
#     Hero.ZARYA,
#     Hero.ZENYATTA
#   ])[0]
