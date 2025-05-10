#!mainFile "main.opy"

rule "Init hud hero icons of players and how much money they have":
  # round
  hudHeader(
    localPlayer if not localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] else null,
    l"Round {0}".format(roundNumber),
    HudPosition.TOP,
    0,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING,
    SpecVisibility.ALWAYS
  )

  # zombies status
  hudText(
    localPlayer if not localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] else null,
    heroIcon(Hero.TORBJORN),
    "<fgC80013FF>{0}{1}</fg>, <fgA0E81BFF>{2}{3}</fg>".format(
      iconString(Icon.FIRE),
      zombieStats[ZI.DAMAGE_STAT],
      iconString(Icon.HEART),
      zombieStats[ZI.HP_STAT]
    ),
    "{0} Enemies".format(roundRemainingBots),
    HudPosition.RIGHT,
    -2,
    Color.WHITE,
    Color.WHITE,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
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
    localPlayer if localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] == true and localPlayer.state[SI.HERO_INFO_TEXT] else null,
    localPlayer.state[SI.HERO_INFO_TEXT],
    updateEveryFrame(
      localPlayer.getEyePosition() +
      localPlayer.getFacingDirection() * 12 +
      normalize(crossProduct(crossProduct(Vector.UP, localPlayer.getFacingDirection()), localPlayer.getFacingDirection())) * localPlayer.state[SI.HERO_INFO_VERTICAL_FIX] + # vertical
      normalize(crossProduct(Vector.UP, localPlayer.getFacingDirection())) * 9 # horizontal
    ),
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
    Color.WHITE,
    SpecVisibility.ALWAYS
  )

  createInWorldText(
    localPlayer if localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] == true and localPlayer.state[SI.HERO_INFO_TEXT2] else null,
    localPlayer.state[SI.HERO_INFO_TEXT2],
    updateEveryFrame(
      localPlayer.getEyePosition() +
      localPlayer.getFacingDirection() * 12 +
      normalize(crossProduct(crossProduct(Vector.UP, localPlayer.getFacingDirection()), localPlayer.getFacingDirection())) * localPlayer.state[SI.HERO_INFO_VERTICAL_FIX2] + # vertical
      normalize(crossProduct(Vector.UP, localPlayer.getFacingDirection())) * localPlayer.state[SI.HERO_INFO_HORIZONTAL_FIX2] # horizontal
    ),
    1,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
    Color.WHITE,
    SpecVisibility.ALWAYS
  )

  # common tips
  createCasedProgressBarIwt(
    text="\n\n\n\n\n\n\n\n\n\n\n\n
    - Press <fgdb9342FF>{}</fg> button to close this hint.

    - To switch the camera, press <fgdb9342FF>{} + {}</fg> buttons.

    - To buy a hero, find the location with the desired hero, enter the circle, and 
      press the <fgdb9342FF>{}</fg> button.

    - In each match, the prices and locations where heroes can be bought are 
      randomly generated.

    - Barriers push zombies back but take damage in the process.

    - Zombies usually don’t die when falling into a pit, but if you help them fall, they 
      take {} base damage. Therefore, controlling abilities and barriers can be useful.

    - Health packs also gradually restore health based on your HP or Healing upgrade level,
      and increase movement speed by 50% for 5 seconds.

    - The mod is still in development, but some heroes already have unique abilities:
      <fg6e89b1FF>Ana</fg> (5), <fg8b625eFF>Brigitte</fg> (2), <fg721fa3FF>Juno</fg> (4),
      <fgdc847dFF>Mauga</fg> (2), <fg9d8cd0FF>Rammatra</fg> (1), <fg94a1a5FF>Reinhardt</fg> (1), <fg94a0a5FF>Sigma</fg> (2), <fg765dbdFF>Sombra</fg> (4), <fg91bbd1FF>Symmetra</fg> (2), 
      <fgA686ABFF>Widowmaker</fg> (8), <fga0a9baFF>Winston</fg> (1).
    ".format(
      inputBindingString(Button.INTERACT),
      inputBindingString(Button.CROUCH),
      inputBindingString(Button.INTERACT),
      inputBindingString(Button.INTERACT),
      ZOMBIE_FALL_DAMAGE
    ),
    visibleTo=(localPlayer if localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] == true else null),
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
    \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
    ",
    HudPosition.TOP,
    1,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )
  # delayed start
  hudHeader(
    localPlayer if not isGameStarted else null,
    "\n\u2001{0}\n\n\u2001Hold {1} to Start\u2001\n".format(
      "Zombie survival", inputBindingString(Button.INTERACT)
    ), 
    HudPosition.TOP,
    1,
    Color.WHITE,
    HudReeval.VISIBILITY_AND_STRING
  )

  # hotkey tip: open hero talents description 
  hudText(
    localPlayer,
    null,
    "Hold {0} + {1} to view hero info and tips".format(inputBindingString(Button.INTERACT), inputBindingString(Button.CROUCH)) if localPlayer.state[SI.IS_TALENTS_HUD_OPENNED] == false else (
      "Press {0} to close hero info and tips".format(inputBindingString(Button.INTERACT))
    ),
    null,
    HudPosition.ACTUALLY_LEFT,
    0,
    null,
    rgb(241, 134, 39),
    null,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )


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
  eventPlayer.state[SI.IS_TALENTS_HUD_OPENNED] = true

rule "Close hero talents info hud":
  @Event eachPlayer
  @Team 1
  @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
  eventPlayer.enableHeroHud()
  eventPlayer.state[SI.IS_TALENTS_HUD_OPENNED] = false


rule "Players list, upgrades and money":
  @Event eachPlayer
  @Team 1

  if eventPlayer.isDummy() or eventPlayer.getSlot() > MAX_PLAYERS - 1:
    return

  hudText(
    getPlayers(Team.1) if not eventPlayer.state[SI.IS_TALENTS_HUD_OPENNED] else null,
    heroIcon(eventPlayer.getHeroOfDuplication()) if eventPlayer.isDuplicatingAHero() == true else heroIcon(eventPlayer.getHero()),
    "<fgC80013FF>{0}{1}</fg>, <fgA0E81BFF>{2}{3}</fg>, <fgEC9900FF>{4}{5}</fg>,{6}{7}".format(
      iconString(Icon.FIRE),
      eventPlayer.damageStat,
      iconString(Icon.HEART),
      eventPlayer.healthStat,
      iconString(Icon.PLUS),
      eventPlayer.healingStat,
      iconString(Icon.DIAMOND),
      eventPlayer.state[SI.TALENTS_COUNT]
    ),
    "{0}: ${1}".format(eventPlayer, eventPlayer.money),
    HudPosition.ACTUALLY_LEFT,
    1,
    Color.BLUE if eventPlayer.getHealth() >= eventPlayer.getMaxHealth() / 2 else Color.RED,
    Color.WHITE,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  eventPlayer.HUDs[HI.PLAYER_LIST_STATUS_TEXT] = getLastCreatedText()

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

rule "Show player damage":
  @Event eachPlayer
  @Team 2
  
  createInWorldText(
    null if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == 0 or localPlayer == eventPlayer else localPlayer,

    "{0}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()])) if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()] else "{0} +{1}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()])),
    updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
    0.7,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    Color.ORANGE if eventPlayer.state[SI.LAST_CC_ATTACK_TIME] > getTotalTimeElapsed() and eventPlayer.state[SI.LAST_CC_ATTACKER] == localPlayer else Color.WHITE
  )

rule "Zombie received damage for hud":
  @Event playerTookDamage
  @Team 2
    
  # save damage stats
  attacker.recentStackedDamageDealtToSlot[victim.getSlot()] += eventDamage
  attacker.recentDamageDealtToSlot[victim.getSlot()] = eventDamage
  wait(1.5, Wait.RESTART_WHEN_TRUE)

  # If one bot is attacked by multiple players, the damage indicator breaks, so we reset it to zero for all players
  getPlayers(Team.1).recentStackedDamageDealtToSlot[victim.getSlot()] = 0

rule "Show player healing":
  @Event eachPlayer
  @Team 1
  
  createInWorldText(
    null if localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()] == false else localPlayer,
    ("{0} +{1}").format(round(localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentHealingDealtToSlot[eventPlayer.getSlot()])),
    updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
    0.7,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    Color.LIME_GREEN
  )

rule "Player received healing":
  @Event playerReceivedHealing
  @Team 1

  healer.recentStackedHealingDealtToSlot[healee.getSlot()] += eventHealing
  healer.recentHealingDealtToSlot[healee.getSlot()] = eventHealing
  wait(1.5, Wait.RESTART_WHEN_TRUE)

  # If one player is healed by multiple players, the healing indicator breaks, so we reset it to zero for all players
  getPlayers(Team.1).recentStackedHealingDealtToSlot[healee.getSlot()] = 0
