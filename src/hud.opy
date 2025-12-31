#!mainFile "main.opy"

#!define ABILITI_TEXT_INTEND "\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000"
#!define ABILITI_CHARGES_INTEND "\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000\u3000"


# Hero Info:
playervar heroInfoText0
playervar heroInfoVertFix0
playervar heroInfoHorFix0
playervar heroInfoText1
playervar heroInfoVertFix1
playervar heroInfoHorFix1

macro setHeroInfoText0(text, vert = 3, horFix = 9):
  eventPlayer.heroInfoVertFix0 = vert
  eventPlayer.heroInfoHorFix0 = horFix
  eventPlayer.heroInfoText0 = text

macro setHeroInfoText1(text, vert = 3.5, horFix = 9):
  eventPlayer.heroInfoVertFix1 = vert
  eventPlayer.heroInfoHorFix1 = horFix
  eventPlayer.heroInfoText1 = text

def clearHeroInfo():
  @Name "Subroutine: Clear hero info"
  eventPlayer.heroInfoText0 = null
  eventPlayer.heroInfoText1 = null
  eventPlayer.heroInfoVertFix0 = 3
  eventPlayer.heroInfoHorFix0 = 9
  eventPlayer.heroInfoVertFix1 = 3.5
  eventPlayer.heroInfoHorFix1 = 11
  eventPlayer.abilPos0 = null
  eventPlayer.abilPos1 = null
  eventPlayer.abilPos2 = null
  eventPlayer.abilPos3 = null
  eventPlayer.abilPos4 = null
  eventPlayer.abilityCD = null

rule "Init huds":
  # zombies status hud (stats and remaining)
  hudText(
    localPlayer if not localPlayer.isHeroDescriptionOpened else null,
    heroIcon(Hero.TORBJORN),
    "<fgC80013FF>{0}{1}%</fg>, <fgA0E81BFF>{2}{3}%</fg>".format(
      iconString(Icon.FIRE),
      botsDamageBoostPercent,
      iconString(Icon.HEART),
      botsHealthBoostPercent
    ),
    "{}/{} Enemies".format(roundRemainingBots, roundMaxBots),
    HudPosition.RIGHT,
    -2,
    Color.WHITE,
    Color.WHITE,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )

  # Hero info
  createInWorldText(
    localPlayer if localPlayer.isHeroDescriptionOpened == true and localPlayer.heroInfoText0 else null,
    localPlayer.heroInfoText0,
    updateEveryFrame(
      localPlayer.getEyePosition() +
      localPlayer.getFacingDirection() * 12 +
      normalize(crossProduct(crossProduct(Vector.UP, localPlayer.getFacingDirection()), localPlayer.getFacingDirection())) * localPlayer.heroInfoVertFix0 + # vertical
      normalize(crossProduct(Vector.UP, localPlayer.getFacingDirection())) * localPlayer.heroInfoHorFix0 # horizontal
    ),
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    Color.WHITE,
    SpecVisibility.ALWAYS
  )
  # Hero info part 2
  createInWorldText(
    localPlayer if localPlayer.isHeroDescriptionOpened == true and localPlayer.heroInfoText1 else null,
    localPlayer.heroInfoText1,
    updateEveryFrame(
      localPlayer.getEyePosition() +
      localPlayer.getFacingDirection() * 12 +
      normalize(crossProduct(crossProduct(Vector.UP, localPlayer.getFacingDirection()), localPlayer.getFacingDirection())) * localPlayer.heroInfoVertFix1 + # vertical
      normalize(crossProduct(Vector.UP, localPlayer.getFacingDirection())) * localPlayer.heroInfoHorFix1 # horizontal
    ),
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    Color.WHITE,
    SpecVisibility.ALWAYS
  )

  # push down hud texts for abilities
  hudSubtext(
    localPlayer if isGameStarted else null,
    "
    \n\n\n\n\n\n\n\n\n\n\n\n\n\n
    \n\n\n\n\n\n\n
    ",
    HudPosition.TOP,
    1,
    Color.WHITE,
    HudReeval.VISIBILITY
  )

rule "Open hero talents info hud":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.CROUCH)
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition not eventPlayer.isHoldingButton(Button.MELEE)
  @Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
  @Condition not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
  @Condition not eventPlayer.isHoldingButton(Button.RELOAD)
  @Condition not eventPlayer.isHoldingButton(Button.JUMP)
  
  wait(HERO_INFO_HOLD_DURATION, Wait.ABORT_WHEN_FALSE)
  eventPlayer.disableHeroHud()
  eventPlayer.isHeroDescriptionOpened = true

rule "Close hero talents info hud":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT)
  @Condition not eventPlayer.isHoldingButton(Button.CROUCH)
  waitUntil(eventPlayer.isHoldingButton(Button.CROUCH), 0.1)
  if eventPlayer.isHoldingButton(Button.CROUCH):
    return

  eventPlayer.enableHeroHud()
  eventPlayer.isHeroDescriptionOpened = false


rule "Create players effects":
  @Event eachPlayer
  @Team 1

  setObjectiveDescription(eventPlayer, "Round: {}".format(roundNumber), HudReeval.SORT_ORDER_AND_STRING)

  if eventPlayer.isDummy() or eventPlayer.getSlot() > MAX_PLAYERS - 1:
    return

  clearHeroInfo()

  # Players list, upgrades and money
  hudText(
    [player for player in getPlayers(Team.1) if player != eventPlayer or not eventPlayer.isHeroDescriptionOpened],
    heroIcon(eventPlayer.getHeroOfDuplication()) if eventPlayer.isDuplicatingAHero() == true else heroIcon(eventPlayer.getHero()),
    "<fgC80013FF>{}{}%</fg>, <fgA0E81BFF>{}{}%</fg>, <fgece580FF>{}{}%</fg>, <fgEC9900FF><TX C00000000004120>{}%</fg>".format(
      iconString(Icon.FIRE),
      eventPlayer.damageBoostPercent,
      iconString(Icon.HEART),
      eventPlayer.healthBoostPercent,
      iconString(Icon.PLUS),
      eventPlayer.healingBoostPercent,
      eventPlayer.damageResistPercent
    ),
    "{0}{1}: {2}".format(
      eventPlayer,
      " <fg94a0a544>(host)</fg>" if eventPlayer == hostPlayer else "",
      "<fg94a0a544>${}(tot)</fg>".format(eventPlayer.moneyTotal) if localPlayer.isHoldingButton(Button.CROUCH) else "${}".format(eventPlayer.money)
    ),
    HudPosition.ACTUALLY_LEFT,
    1,
    Color.BLUE if eventPlayer.isAlive() else Color.RED, # if eventPlayer.getHealth() >= eventPlayer.getMaxHealth() / 2 else Color.RED,
    Color.WHITE,
    Color.WHITE if eventPlayer.isAlive() else Color.RED,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  eventPlayer.effectsIds[PLAYER_STATUS_HUD] = getLastCreatedText()
