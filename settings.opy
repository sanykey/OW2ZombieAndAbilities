#!mainFile "main.opy"
settings {
    "main": {
        "description": "Under development",
        "modeName": "Zombies"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": 6,
        "team2Slots": 0,
        "returnToLobby": "afterGame", # todo: "returnToLobby": "never",
        "swapTeamsAfterMatch": false,
        "useExperimentalUpdate": true
    },
    "gamemodes": {
        "ctf": {
            "enabled": false,
            "flagDroppedLockTime": 8,
            "flagPickupTime": 5,
            "flagReturnTime": 1,
            "gameLengthInMn": 15,
            "scoreToWin": 9
        },
        "skirmish": {
            "enabledMaps": [
                "eichenwaldeHalloween"
            ],
            "enablePerks": true
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
        }
    },
    "heroes": {
        "team1": {
            "dva": {
                "damageReceived%": 85,
                "movementSpeed%": 150,
                "projectileSpeed%": 500,
                "spawnWithoutMech": true,
                "enableUlt": false
            }
        },
        "team2": {
            "torbjorn": {
                "ammoClipSize%": 150,
                "damageDealt%": 180,
                "damageReceived%": 90,
                "enableAbility1": false,
                "healingReceived%": 40,
                "health%": 200,
                "jumpVerticalSpeed%": 120,
                "movementSpeed%": 70,
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
                "ultGen%": 50,
                "combatUltGen%": 50,
                "passiveUltGen%": 50
            }
        }
    }
}