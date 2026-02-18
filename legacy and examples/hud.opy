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