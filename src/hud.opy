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
  
  # round stats
  hudText(
    localPlayer if not localPlayer.isHeroDescriptionOpened and localPlayer.getTeam() == Team.1 else null,
    null,
    "" if showPlayerStatsTime < getTotalTimeElapsed() else "\n\nRound statistics:{}{}{}{}{}{}{}{}{}{}{}{}{}{}".format(
      "\nEliminations: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundEliminations, localPlayer.roundEliminations * MONEY_FOR_ELIMINATIONS
      ) if localPlayer.roundEliminations else "",
      "\nDamage dealt: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundDamageDealtStat, localPlayer.roundDamageDealtStat * MONEY_FOR_DAMAGE_DEALT
      ) if localPlayer.roundDamageDealtStat else "",
      "\nCritical final blows: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundCriticalFinalBlows, localPlayer.roundCriticalFinalBlows * MONEY_FOR_CRITICAL_FINAL_BLOW
      ) if localPlayer.roundCriticalFinalBlows else "",
      "\nMelee final blows: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundMeleeFinalBlows, localPlayer.roundMeleeFinalBlows * MONEY_FOR_MELEE_FINAL_BLOW
      ) if localPlayer.roundMeleeFinalBlows else "",
      "\nHacked eliminations: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundHackedElims, localPlayer.roundHackedElims * MONEY_FOR_HACKED_ELIMS
      ) if localPlayer.roundHackedElims else "",
      "\nOffensive assists: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundOffensiveAssistsStat, localPlayer.roundOffensiveAssistsStat * MONEY_FOR_OFFENSIVE_ASSISTS
      ) if localPlayer.roundOffensiveAssistsStat else "",
      "\nDefensive assists: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundDefensiveAssistsStat, localPlayer.roundDefensiveAssistsStat * MONEY_FOR_DEFENSIVE_ASSISTS
      ) if localPlayer.roundDefensiveAssistsStat else "",
      "\nDeaths: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundDeathsStat, MONEY_FOR_ZERO_DEATHS if localPlayer.roundDeathsStat == 0 else 0
      ),
      "\nRevives: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundRevivesStat, localPlayer.roundRevivesStat * MONEY_FOR_REVIVE
      ) if localPlayer.roundRevivesStat else "",
      "\nHealing: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundHealingStat, localPlayer.roundHealingStat * MONEY_FOR_HEALING
      ) if localPlayer.roundHealingStat else "",
      "\nSelf healing: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundSelfHealingStat, localPlayer.roundSelfHealingStat * MONEY_FOR_SELF_HEALING
      ) if localPlayer.roundSelfHealingStat else "",
      "\nDamage blocked: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundDamageBlockedStat, localPlayer.roundDamageBlockedStat * MONEY_FOR_DAMAGE_BLOCKED
      ) if localPlayer.roundDamageBlockedStat else "",
      "\nDamage taken: <fgecbe52FF>{}</fg>, <fg84c951FF>+${}</fg>".format(
        localPlayer.roundDamageTakenStat, localPlayer.roundDamageTakenStat * MONEY_FOR_DAMAGE_TAKEN
      ) if localPlayer.roundDamageTakenStat else "",
      "\nRound bonus: <fg84c951FF>+${}</fg>".format(
        localPlayer.roundTeamEliminatedBots * MONEY_FOR_ELIMINATIONS_TEAM
      )
    ),
    null,
    HudPosition.ACTUALLY_LEFT,
    10,
    null,
    Color.WHITE,
    null,
    HudReeval.VISIBILITY_AND_STRING
  )

  # revive hud
  hudSubtext(
    [player for player in getPlayers(Team.1) if player.downedStartTime],
    "Waiting for revival",
    HudPosition.TOP,
    -70,
    Color.YELLOW,
    HudReeval.VISIBILITY_AND_STRING
  )
  # revive progress bar
  progressBarHud(
    localPlayer if (localPlayer.reviveTimer if localPlayer.downedStartTime else any([localPlayer in player.revivers for player in getPlayers(Team.1)])) else [],
    localPlayer.reviveTimer if localPlayer.downedStartTime else ((sorted([player for player in getPlayers(Team.1) if localPlayer in player.revivers], lambda i: i.reviveTimer)).last()).reviveTimer,
    "You are being revived" if localPlayer.downedStartTime else "Reviving {0}".format("{0} Teammates".format(len([player for player in getPlayers(Team.1) if localPlayer in player.revivers])) if len([player for player in getPlayers(Team.1) if localPlayer in player.revivers]) > 1 else ([player for player in getPlayers(Team.1) if localPlayer in player.revivers])[0]),
    HudPosition.TOP,
    100,
    Color.SKY_BLUE
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

  # common tips
  createCasedProgressBarIwt(
    text="\n\n\n\n\n\n\n\n\n\n\n\n
    - Hold <fgdb9342FF>{} + {}</fg> to view hero info and help.

    - Press <fgdb9342FF>{} + {}</fg> to switch the camera.

    - To buy a hero, stand in the circle near them and press <fgdb9342FF>{}</fg>, if you can afford it.

    - Ultimate charge increases by {}% for participating in kills, defense assists, and offense assists. 
      It also increases by 1% for every {} seconds of playing emotes.

    - Damage resistance is increased by {}% for each hero you have purchased.

    - Hero prices and locations are randomized each match.

    - Barriers push zombies back but take damage while doing so.

    - Zombies don’t usually die from falling into pits, but if you force them in, they take {} base damage. 
      Use crowd control and barriers to your advantage.

    - Health packs gradually restore HP (scaling with HP/Healing upgrades) and boost movement speed by
      50% for 5 seconds.

    - The mod is still in development. Some heroes already have unique abilities:
      <fg6e89b1FF>Ana</fg> (5), <fg8b625eFF>Brigitte</fg> (5), <fg721fa3FF>Juno</fg> (4), <fgad5a5fFF>Cassidy</fg> (7)
      <fgdc847dFF>Mauga</fg> (2), <fg6dabebFF>Mei</fg> (2), <fg9d8cd0FF>Rammatra</fg> (1), <fg94a1a5FF>Reinhardt</fg> (2),
      <fg94a0a5FF>Sigma</fg> (2), <fg6d7995FF>Soldier 76</fg> (1), <fg765dbdFF>Sombra</fg> (4), <fg91bbd1FF>Symmetra</fg> (2), 
      <fgA686ABFF>Widowmaker</fg> (8), <fga0a9baFF>Winston</fg> (1).
    ".format(
      inputBindingString(Button.CROUCH),
      inputBindingString(Button.INTERACT),
      inputBindingString(Button.CROUCH),
      inputBindingString(Button.INTERACT),
      inputBindingString(Button.INTERACT),
      ULT_CHARGE_FOR_KILL,
      EMOTE_ULT_CHARE_PER_SECONDS,
      DAMAGE_RESISTANCE_BY_OWNED_HERO,
      ZOMBIE_FALL_DAMAGE
    ),
    visibleTo=(localPlayer if localPlayer.isHeroDescriptionOpened == true else null),
    position=updateEveryFrame(
      localPlayer.getEyePosition() +
      localPlayer.getFacingDirection() * 12 +
      normalize(crossProduct(crossProduct(Vector.UP, localPlayer.getFacingDirection()), localPlayer.getFacingDirection())) * 4 + # vertical
      normalize(crossProduct(Vector.UP, localPlayer.getFacingDirection())) * -7 # horizontal
    ),
    scale=1
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

  # delayed start
  hudHeader(
    localPlayer if not localPlayer.isHeroDescriptionOpened else null,
    "\n\u2001{0}\n\n\u2001Hold {1} to Start\u2001\n".format(
      "Zombie survival", inputBindingString(Button.INTERACT)
    ), 
    HudPosition.TOP,
    1,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )
  delayerStartHudId = getLastCreatedText()


  

  # hotkey tip: open hero talents description 
  # hudText(
  #   localPlayer,
  #   null,
  #   "Hold {0} + {1} to view hero info and help".format(inputBindingString(Button.INTERACT), inputBindingString(Button.CROUCH)) if localPlayer.isHeroDescriptionOpened == false else (
  #     "Press {0} to close hero info and help".format(inputBindingString(Button.INTERACT))
  #   ),
  #   null,
  #   HudPosition.ACTUALLY_LEFT,
  #   0,
  #   null,
  #   rgb(241, 134, 39),
  #   null,
  #   HudReeval.VISIBILITY_STRING_AND_COLOR
  # )


rule "Open hero talents info hud":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  @Condition eventPlayer.isHoldingButton(Button.MELEE) == false
  @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
  @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == false
  @Condition eventPlayer.isHoldingButton(Button.RELOAD) == false
  @Condition eventPlayer.isHoldingButton(Button.JUMP) == false
  
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

  # revive effects and icon
  createEffect(getPlayers(Team.1) if eventPlayer.downedStartTime else [], Effect.RING, Color.YELLOW, eventPlayer, 3, EffectReeval.VISIBILITY)
  eventPlayer.effectsIds[HI.REVIVE_EFFECT] = getLastCreatedEntity()

  createIcon(getPlayers(Team.1).exclude(eventPlayer) if eventPlayer.downedStartTime else [], eventPlayer, Icon.SKULL, IconReeval.VISIBILITY_AND_POSITION, Color.YELLOW)
  eventPlayer.effectsIds[HI.REVIVE_ICON] = getLastCreatedEntity()

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
    "{0}: ${1}".format(eventPlayer, eventPlayer.money),
    HudPosition.ACTUALLY_LEFT,
    1,
    Color.BLUE, # if eventPlayer.getHealth() >= eventPlayer.getMaxHealth() / 2 else Color.RED,
    Color.WHITE,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )
  eventPlayer.effectsIds[HI.PLAYER_STATUS] = getLastCreatedText()


# rule "[Tips & Tricks]":
#   @Event eachPlayer
#   @Team 1
#   wait(1)
#   setObjectiveDescription(eventPlayer, "Welcome to Zombies Unleashed! | Objective: Survive as many waves of zombies as possible!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Unlock heroes, new locations and upgrade your stats with your points! Use Interact [{0}] when standing on the circle.".format(buttonString(Button.INTERACT)), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Earn points by defeating zombies, assisting, healing & reviving your teammates. Everyone wins!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Tanks have a permanent 15% Damage Reduction passive!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(
#     eventPlayer,
#     "You can switch 3P Camera by pressing {0} + {1}.".format(
#       buttonString(Button.INTERACT),
#       buttonString(Button.CROUCH)
#     ),
#     HudReeval.VISIBILITY_SORT_ORDER_AND_STRING
#   )
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Struggling to find the secret room? It's somewhere in the castle! When the power is stable look on the floor...", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Staying together as a team is the best approach. A team that sticks together...revives together!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Supporters rejoice! Points are rewarded for healing your teammates. Paid to heal? Sign me up!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Try and save your points so you can use them to upgrade your stats in the secret shop!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Wondering why D.VA has no ultimate? She's so OP we had to even the playing field! Love, D.VA ;)", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Teleporting Torbs? Working as intended. Junkenstein done a real number on them. Oh the joy!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "If you hear \"Molten Core\" look for the red puddles. Stand in them to increase your damage! Honest..", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Revive a teammate by standing on the Yellow Circle where they died.", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Spare points? Give your whole team a buff with permanent Shields/Armor. Friendship is the best ship!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "All heroes are available to purchase! Can you spot where they are in the area?", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   setObjectiveDescription(eventPlayer, "Enraged Zombies gain Molten Core. Happy birthday!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
#   wait(15)
#   goto RULE_START

# rule "Show player damage":
#   @Event eachPlayer
#   @Team 2
  
#   createInWorldText(
#     null if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == 0 or localPlayer == eventPlayer else localPlayer,

#     "{0}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()])) if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()] else "{0} +{1}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()])),
#     updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
#     0.7,
#     Clip.NONE,
#     WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
#     Color.ORANGE if eventPlayer.lastCcAttackTime > getTotalTimeElapsed() and eventPlayer.lastCcAttacker == localPlayer else Color.WHITE
#   )

# rule "Zombie received damage for hud":
#   @Event playerTookDamage
#   @Team 2
    
#   # save damage stats
#   attacker.recentStackedDamageDealtToSlot[victim.getSlot()] += eventDamage
#   attacker.recentDamageDealtToSlot[victim.getSlot()] = eventDamage
#   wait(1.5, Wait.RESTART_WHEN_TRUE)

#   # If one bot is attacked by multiple players, the damage indicator breaks, so we reset it to zero for all players
#   getPlayers(Team.1).recentStackedDamageDealtToSlot[victim.getSlot()] = 0

# rule "Show player healing":
#   @Event eachPlayer
#   @Team 1
  
#   createInWorldText(
#     null if localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()] == false else localPlayer,
#     ("{0} +{1}").format(round(localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentHealingDealtToSlot[eventPlayer.getSlot()])),
#     updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
#     0.7,
#     Clip.NONE,
#     WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
#     Color.LIME_GREEN
#   )

# rule "Player received healing":
#   @Event playerReceivedHealing
#   @Team 1

#   healer.recentStackedHealingDealtToSlot[healee.getSlot()] += eventHealing
#   healer.recentHealingDealtToSlot[healee.getSlot()] = eventHealing
#   wait(1.5, Wait.RESTART_WHEN_TRUE)

#   # If one player is healed by multiple players, the healing indicator breaks, so we reset it to zero for all players
#   getPlayers(Team.1).recentStackedHealingDealtToSlot[healee.getSlot()] = 0
