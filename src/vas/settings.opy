#!mainFile "../main.opy"

# settings.heroes.allTeams.general.passiveHealthRegen false is not working. You must manually enter this parameter = "Disabled"

#!define MODE_VERSION "0.2.3"
settings {
    "main": {
        "description": "Try to survive more than 100 rounds. Version 0.2.3",
        "modeName": "Zombie Survival & Talents"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": MAX_PLAYERS,
        "team2Slots": 0,
        "returnToLobby": "never",
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
            "enablePerks": true,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            # "respawnTime%": 0
            "perkEliminationCatchupLevelAmount%": 1
        }
    },
    "heroes": {
        "team1": {
            "general": {
                "ultGen%": 10,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "passiveHealthRegen": false
            },
            "dva": {
                "damageReceived%": 85,
                "projectileSpeed%": 500,
                "spawnWithoutMech": true
            },
            "juno": {
                "jumpVerticalSpeed%": 115,
                "ability1Duration%": 150
            },
            "moira": {
                "ability2MaxDamage%": 500,
                "ability2MaxHealing%": 500
            },
        },
        "team2": {
            "torbjorn": {
                "enableAbility1": false,
                "healingReceived%": 10,
                "jumpVerticalSpeed%": 150,
                "movementGravity%": 70,
                "movementSpeed%": ZOMBIE_SPEED,
                "enableAbility2": false,
                "projectileSpeed%": 0,
                "combatUltGen%": 50,
                "passiveUltGen%": 10,
                "ultGen%": 50,
                "weaponsEnabled": "hammer",
                "ultDuration%": 200,
            },
            "roadhog": {
                "healingReceived%": 10,
                "jumpVerticalSpeed%": 150,
                "movementGravity%": 70,
                "movementSpeed%": ZOMBIE_SPEED - 10,
                "ability1Cooldown%": 10
            },
            "mauga": {
                "healingReceived%": 10,
                "jumpVerticalSpeed%": 150,
                "movementGravity%": 70,
                "movementSpeed%": ZOMBIE_SPEED,
                "ability1Cooldown%": 50
            },
            "echo": {
                "healingReceived%": 10,
                "jumpVerticalSpeed%": 150,
                "movementGravity%": 40,
                "ability1Cooldown%": 50,
                "movementSpeed%": 150,
            }
        },
        "allTeams": {
            "general": {
                "passiveHealthRegen": false
            }
        }
    }
}