#!mainFile "main.opy"

macro Player.earnMoney(self, amount=0):
  self.money__zomStuckPoints += amount
  self.moneyTotal__zomStuckPrevPosition += amount

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

rule "Version text":
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
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )

rule "Server anti-crash system":
  @Condition getServerLoad() > 240
  
  wait(0.5, Wait.ABORT_WHEN_FALSE)
  if not ruleCondition:
    return

  smallMessage(getAllPlayers(), "[Anti crash enabled]")
  setSlowMotion(75)
  waitUntil(getServerLoad() < 230, INFINITY)
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
