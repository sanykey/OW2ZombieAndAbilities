#!mainFile "main.opy"

rule "Init hud hero icons of players and how much money they have":
  @Condition roundNumber == 1
  
  # round
  hudHeader(getPlayers(Team.1), l"Round {0}".format(roundNumber), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
  hudHeader(getPlayers(Team.1), l"{0} {1}".format(roundRemainingBots, l"Enemies"), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

  # revive
  hudSubtext(
    [player for player in combatants if player.downedStartTime],
    "Waiting for revival. Press {0} to spectate the next player.".format(inputBindingString(Button.JUMP)),
    HudPosition.TOP,
    -70,
    Color.YELLOW,
    HudReeval.VISIBILITY_AND_STRING
  )
  progressBarHud(
    localPlayer if (localPlayer.reviveTimer if localPlayer.downedStartTime else any([localPlayer in player.revivers for player in combatants])) else [],
    localPlayer.reviveTimer if localPlayer.downedStartTime else ((sorted([player for player in combatants if localPlayer in player.revivers], lambda i: i.reviveTimer)).last()).reviveTimer,
    "You are being revived" if localPlayer.downedStartTime else "Reviving {0}".format("{0} Teammates".format(len([player for player in combatants if localPlayer in player.revivers])) if len([player for player in combatants if localPlayer in player.revivers]) > 1 else ([player for player in combatants if localPlayer in player.revivers])[0]),
    HudPosition.TOP,
    100,
    Color.SKY_BLUE
  )


rule "Players list, upgrades and money":
  @Event eachPlayer
  @Team 1

  if eventPlayer.getSlot() > 5:
    return

  hudText(
    getPlayers(Team.1) if eventPlayer else null,
    heroIcon(eventPlayer.getHeroOfDuplication()) if eventPlayer.isDuplicatingAHero() == true else heroIcon(eventPlayer.getHero()),
    "{0} {1}%, {2} {3}%, {4} {5}%".format(
      iconString(Icon.FIRE),
      eventPlayer.damageStat,
      iconString(Icon.HEART),
      eventPlayer.healthStat,
      iconString(Icon.PLUS),
      eventPlayer.healingStat
    ),
    "{0}: ${1}".format(eventPlayer, eventPlayer.money),
    HudPosition.LEFT,
    0,
    Color.BLUE if eventPlayer.getHealth() >= eventPlayer.getMaxHealth() / 2 else Color.RED,
    Color.WHITE,
    Color.WHITE,
    HudReeval.VISIBILITY_STRING_AND_COLOR
  )
  eventPlayer.HUDs[HI.PLAYER_LIST_STATUS_TEXT] = getLastCreatedText()
  

rule "[Tips & Tricks]":
  @Event eachPlayer
  @Team 1
  
  wait(1)
  setObjectiveDescription(eventPlayer, "Welcome to Zombies Unleashed! | Objective: Survive as many waves of zombies as possible!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Unlock heroes, new locations and upgrade your stats with your points! Use Interact [{0}] when standing on the circle.".format(buttonString(Button.INTERACT)), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Earn points by defeating zombies, assisting, healing & reviving your teammates. Everyone wins!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Tanks have a permanent 15% Damage Reduction passive!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "You can enable 3P Camera by pressing and holding [{0}] [{1}] together. Hold [{0}] [{2}] together to turn it off.".format(buttonString(Button.INTERACT), buttonString(Button.RELOAD), buttonString(Button.JUMP)), HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Struggling to find the secret room? It's somewhere in the castle! When the power is stable look on the floor...", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Staying together as a team is the best approach. A team that sticks together...revives together!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Supporters rejoice! Points are rewarded for healing your teammates. Paid to heal? Sign me up!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Try and save your points so you can use them to upgrade your stats in the secret shop!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Wondering why D.VA has no ultimate? She's so OP we had to even the playing field! Love, D.VA ;)", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Teleporting Torbs? Working as intended. Junkenstein done a real number on them. Oh the joy!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "If you hear \"Molten Core\" look for the red puddles. Stand in them to increase your damage! Honest..", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Revive a teammate by standing on the Yellow Circle where they died.", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Spare points? Give your whole team a buff with permanent Shields/Armor. Friendship is the best ship!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "All heroes are available to purchase! Can you spot where they are in the area?", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  setObjectiveDescription(eventPlayer, "Enraged Zombies gain Molten Core. Happy birthday!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
  wait(15)
  goto RULE_START

rule "Show player damage":
  @Event eachPlayer
  @Team 2
  
  createInWorldText(
    null if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == 0 or localPlayer == eventPlayer else localPlayer,

    "{0}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()])) if localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()] == localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()] else "{0} +{1}".format(round(localPlayer.recentStackedDamageDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()])),
    updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
    0.7,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING
  )

rule "Player took damage":
  @Event playerTookDamage
  @Team 2
  
  attacker.recentStackedDamageDealtToSlot[victim.getSlot()] += eventDamage
  attacker.recentDamageDealtToSlot[victim.getSlot()] = eventDamage
  wait(1.5, Wait.RESTART_WHEN_TRUE)

  # If one bot is attacked by multiple players, the damage indicator breaks, so we reset it to zero for all players
  getPlayers(Team.1).recentStackedDamageDealtToSlot[victim.getSlot()] = 0

rule "Show player healing":
  @Event eachPlayer
  @Team 1
  
  createInWorldText(
    null if localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()] == 0 else localPlayer,
    ("{0} +{1}").format(round(localPlayer.recentStackedHealingDealtToSlot[eventPlayer.getSlot()]), round(localPlayer.recentHealingDealtToSlot[eventPlayer.getSlot()])),
    updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
    0.7,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    Color.LIME_GREEN
  )

rule "Player received damage":
  @Event playerReceivedHealing
  @Team 1

  healer.recentStackedHealingDealtToSlot[healee.getSlot()] += eventHealing
  healer.recentHealingDealtToSlot[healee.getSlot()] = eventHealing
  wait(1.5, Wait.RESTART_WHEN_TRUE)

  # If one player is healed by multiple players, the healing indicator breaks, so we reset it to zero for all players
  getPlayers(Team.1).recentStackedHealingDealtToSlot[healee.getSlot()] = 0
