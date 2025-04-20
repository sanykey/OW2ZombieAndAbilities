#!mainFile "main.opy"

rule "Init hud hero icons of players and how much money they have":
  @Condition roundNumber == 1
  
  # Rewriting code to loop causes errors
  # for I in range(6):
  #   hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(I, Team.1).getCurrentHero()), getPlayersInSlot(I, Team.1)), getPlayersInSlot(I, Team.1).money), HudPosition.LEFT, I, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

  hudHeader(getPlayers(Team.1), l"Round {0}".format(roundNumber), HudPosition.TOP, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
  hudHeader(getPlayers(Team.1), l"{0} {1}".format(round_remaining_bots, l"Enemies"), HudPosition.RIGHT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(0, Team.1).getCurrentHero()), getPlayersInSlot(0, Team.1)), getPlayersInSlot(0, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(1, Team.1).getCurrentHero()), getPlayersInSlot(1, Team.1)), getPlayersInSlot(1, Team.1).money), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(2, Team.1).getCurrentHero()), getPlayersInSlot(2, Team.1)), getPlayersInSlot(2, Team.1).money), HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(3, Team.1).getCurrentHero()), getPlayersInSlot(3, Team.1)), getPlayersInSlot(3, Team.1).money), HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  
  # todo: why = 0 here?
  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(4, Team.1).getCurrentHero()), getPlayersInSlot(4, Team.1)), getPlayersInSlot(4, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
  hudHeader(getPlayers(Team.1), l"{0}: {1}".format(l"{0} {1}".format(heroIcon(getPlayersInSlot(5, Team.1).getCurrentHero()), getPlayersInSlot(5, Team.1)), getPlayersInSlot(5, Team.1).money), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

rule "[Upgrade Stats HUD]":
  @Event eachPlayer
  @Team 1
  @Condition N == 1
  
  hudHeader(eventPlayer, l"{0} : {1} : {2}".format(l"{0} {1}".format("HP", eventPlayer.health_stat), l"{0} {1}".format(l"Damage", eventPlayer.damage_stat), l"{0} {1}".format(l"Healing", eventPlayer.healing_stat)), HudPosition.TOP, -1, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)

rule "[Player Death Message]":
  @Event playerDied
  @Team 1
  
  players_ressurect_positions_arr[eventPlayer.getSlot()] = nearestWalkablePosition(eventPlayer)
  bigMessage(getPlayers(Team.1), l"{0} {1}".format(eventPlayer, l"{0}!".format("is down and needs reviving")))
  E[eventPlayer.getSlot()] = true
  smallMessage(eventPlayer, "Please wait for a teammate to revive you or for all zombies to be slayed this round.")

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
  setObjectiveDescription(eventPlayer, "Mercy's revive has been amplified to grant her temporary immunity. Your guardian angel has arrived!", HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
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
    null if localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()] == 0 or localPlayer == eventPlayer else localPlayer,
    ceil(localPlayer.recentDamageDealtToSlot[eventPlayer.getSlot()]),
    # eventPlayer,
    updateEveryFrame(vect(eventPlayer.getEyePosition().x, eventPlayer.getEyePosition().y + 1.4, eventPlayer.getEyePosition().z)),
    0.7,
    Clip.NONE,
    WorldTextReeval.VISIBILITY_POSITION_AND_STRING
  )

rule "Player took damage":
    @Event playerTookDamage
    @Team 2
    
    attacker.recentDamageDealtToSlot[victim.getSlot()] += eventDamage
    wait(1.5, Wait.RESTART_WHEN_TRUE)
    attacker.recentDamageDealtToSlot[victim.getSlot()] = 0
