#!mainFile "main.opy"

# settings.heroes.allTeams.general.passiveHealthRegen false is not working. You must manually enter this parameter = "Disabled"

settings {
    "main": {
        "description": "Under development",
        "modeName": "Zombies"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": MAX_PLAYERS,
        "team2Slots": 0,
        "returnToLobby": "afterGame",
        "swapTeamsAfterMatch": false,
        "useExperimentalUpdate": true
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                "eichenwaldeHalloween"
            ],
            "enablePerks": true
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            # "respawnTime%": 0
        }
    },
    "heroes": {
        "team1": {
            # "ramattra": {
            #     "secondaryFireCooldown%": 0
            # },
            "dva": {
                "damageReceived%": 85,
                "projectileSpeed%": 500,
                "spawnWithoutMech": true,
                "enableUlt": false
            }
        },
        "team2": {
            "torbjorn": {
                "enableAbility1": false,
                "healingReceived%": 10,
                "jumpVerticalSpeed%": 150,
                "movementGravity%": 80,
                "movementSpeed%": ZOMBIE_SPEED,
                "enableAbility2": false,
                "projectileSpeed%": 0,
                "combatUltGen%": 10,
                "passiveUltGen%": 10,
                "ultGen%": 10,
                "weaponsEnabled": "hammer"
            }
        },
        "allTeams": {
            "enabledHeroes": [
                "dva"
            ],
            "general": {
                "passiveHealthRegen": false,
                "ultGen%": 30,
                "combatUltGen%": 30,
                "passiveUltGen%": 30
            }
        }
    }
}