-- Dungeon Heroes Script with Obsidian UI (Standalone, no Key System/Webhooks)
-- This script is designed to be fully standalone and executed directly by a Lua executor.
-- It now includes robust mini-boss detection (checking for 'BOSS' folder) for specific mini-bosses like Aldrazir.

-- Load the Obsidian UI Library
-- IMPORTANT: This line relies on the Obsidian UI Library (Library.lua) being
-- available and executable at this URL for your executor. If this fails, the
-- issue is with the Obsidian library itself, or your executor environment.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService") -- Keep for config saving
local UserInputService = game:GetService("UserInputService") -- Added for toggle keybind

local Combat = RS:WaitForChild("Systems", 9e9):WaitForChild("Combat", 9e9):WaitForChild("PlayerAttack", 9e9)
local Effects = RS:WaitForChild("Systems", 9e9):WaitForChild("Effects", 9e9):WaitForChild("DoEffect", 9e9)
local Skills = RS:WaitForChild("Systems", 9e9):WaitForChild("Skills", 9e9):WaitForChild("UseSkill", 9e9)
local SkillAttack = RS:WaitForChild("Systems", 9e9):WaitForChild("Combat", 9e9):WaitForChild("PlayerSkillAttack", 9e9)
local mobFolder = workspace:WaitForChild("Mobs", 9e9)
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = nil
local HRP = nil
local connections = {}

-- AntiAfkSystem
local AntiAfkSystem = {
    setup = function()
        local conn = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        table.insert(connections, conn)
    end,
    cleanup = function()
        for _, conn in ipairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}
    end
}
AntiAfkSystem.setup()

-- Try to get the skill system module
local skillSystem = nil
local profileSystem = nil
pcall(function()
    skillSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Skills", 9e9))
    profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
end)

-- Global variables for character references
local function updateCharacterReferences()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HRP = Character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(updateCharacterReferences)
if LocalPlayer.Character then
    updateCharacterReferences()
end

-- Auto skill configuration
local CONFIG = {
    SKILL_SLOTS = {1, 2, 3, 4}, -- Skill slots to use
    FALLBACK_COOLDOWN = 2, -- Fallback cooldown if skill data not found
    SKILL_CHECK_INTERVAL = 0.5, -- How often to check for skills (faster for better responsiveness)
    SKILL_RANGE = 500, -- Range to use skills
}

-- Runtime state for auto skill
local RuntimeState = {
    autoSkillEnabled = false,
    lastUsed = {}, -- Track last time each skill was used
    skillData = {}, -- Store skill data
    selectedSkills = {}, -- Store selected skills
    skillToggles = {}, -- Store enabled/disabled state for each skill
}


local configFolder = "SeisenHub"
local configFile = configFolder .. "/seisen_hub_dh.txt"

-- Ensure folder exists
if not isfolder(configFolder) then
    makefolder(configFolder)
end

-- Default config
local config = {
    killAuraEnabled = false,
    autoStartDungeon = false,
    autoReplyDungeon = false,
    autoNextDungeon = false,
    autoFarmEnabled = false,
    autoSkillEnabled = false,
    skillToggles = {}, -- [skillName] = true/false
    dungeonSequenceIndex = 1,
    normalDungeonName = "Shattered Forest lvl 1+",
    normalDungeonDifficulty = "Normal",
    normalDungeonPlayerLimit = 1,
    raidDungeonName = "Abyssal Depths",
    raidDungeonDifficulty = "RAID",
    raidDungeonPlayerLimit = 7,
    eventDungeonName = "Gauntlet",
    eventDungeonDifficulty = "Normal",
    eventDungeonPlayerLimit = 4,
    completedDungeons = {}, -- [dungeonName_difficulty] = true
    autoReplyDungeon = false,
    autoClaimDailyQuest = false,
    autoEquipHighestWeapon = false,
    fpsBoostEnabled = false,
    maxfpsBoostenabled = false,
    supermaxfpsBoostenabled = false,
    autoSellEnabled = false,
    autoSellRarity = "Common",
    -- NEW CONFIG ITEMS
    autoResetOnMiniBoss = false,
    miniBossRoomNumber = 6, -- Default mini-boss room (used by UI as a general setting, but not for specific mob name)
    uiToggleKey = "RightControl", -- Default key for UI toggle
}

-- Load config if file exists
if isfile(configFile) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do
            config[k] = v
        end
    end
end

-- Helper to save config
local function saveConfig()
    writefile(configFile, HttpService:JSONEncode(config))
end

-- Now, use config values as your defaults:
_G.killAuraEnabled = config.killAuraEnabled
local autoStartDungeon = config.autoStartDungeon
local autoReplyDungeon = config.autoReplyDungeon
local autoNextDungeon = config.autoNextDungeon
local autoFarmEnabled = config.autoFarmEnabled
RuntimeState.autoSkillEnabled = config.autoSkillEnabled
RuntimeState.skillToggles = config.skillToggles or {}
local dungeonSequenceIndex = config.dungeonSequenceIndex or 1
local normalDungeonName = config.normalDungeonName
local normalDungeonDifficulty = config.normalDungeonDifficulty
local normalDungeonPlayerLimit = config.normalDungeonPlayerLimit
local raidDungeonName = config.raidDungeonName
local raidDungeonDifficulty = config.raidDungeonDifficulty
local raidDungeonPlayerLimit = config.raidDungeonPlayerLimit
local eventDungeonName = config.eventDungeonName
local eventDungeonDifficulty = config.eventDungeonDifficulty
local eventDungeonPlayerLimit = config.eventDungeonPlayerLimit
local autoClaimDailyQuest = config.autoClaimDailyQuest
local autoEquipHighestWeapon = config.autoEquipHighestWeapon
local fpsBoostEnabled = config.fpsBoostEnabled
local supermaxfpsBoostenabled = config.supermaxfpsBoostenabled
local maxfpsBoostenabled = config.maxfpsBoostenabled
local autoSellEnabled = config.autoSellEnabled
local selectedRarity = config.autoSellRarity
local autoResetOnMiniBoss = config.autoResetOnMiniBoss
local miniBossRoomNumber = config.miniBossRoomNumber

-- Skill table data (from your provided table)
local function initializeSkillData()
    RuntimeState.skillData = {
        ["Whirlwind"] = {
            ["DisplayName"] = "Whirlwind",
            ["Cooldown"] = 6,
            ["UseLength"] = 1.9,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 0.7},
                {["Type"] = "Normal", ["Damage"] = 0.7},
                {["Type"] = "Normal", ["Damage"] = 0.7},
                {["Type"] = "Normal", ["Damage"] = 0.7},
                {["Type"] = "Normal", ["Damage"] = 0.7},
                {["Type"] = "Normal", ["Damage"] = 0.7}
            }
        },
        ["FerociousRoar"] = {
            ["DisplayName"] = "Ferocious Roar",
            ["Cooldown"] = 9,
            ["UseLength"] = 1.5,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5},
                {["Type"] = "Normal", ["Damage"] = 0.5}
            }
        },
        ["Rumble"] = {
            ["DisplayName"] = "Rumble",
            ["Cooldown"] = 10,
            ["UseLength"] = 1.2,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 4},
                {["Type"] = "Normal", ["Damage"] = 4},
                {["Type"] = "Normal", ["Damage"] = 4},
                {["Type"] = "Normal", ["Damage"] = 4},
                {["Type"] = "Normal", ["Damage"] = 4}
            }
        },
        ["PiercingWave"] = {
            ["DisplayName"] = "Piercing Wave",
            ["Cooldown"] = 8,
            ["UseLength"] = 0.7,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2.8},
                {["Type"] = "Normal", ["Damage"] = 2.8},
                {["Type"] = "Normal", ["Damage"] = 2.8},
                {["Type"] = "Normal", ["Damage"] = 2.8},
                {["Type"] = "Normal", ["Damage"] = 2.8}
            }
        },
        ["Fireball"] = {
            ["DisplayName"] = "Fireball",
            ["Cooldown"] = 8,
            ["UseLength"] = 1.2,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 4}
            }
        },
        ["DrillStrike"] = {
            ["DisplayName"] = "Drill Strike",
            ["Cooldown"] = 9,
            ["UseLength"] = 1,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5},
                {["Type"] = "Normal", ["Damage"] = 3.5}
            }
        },
        ["FireBreath"] = {
            ["DisplayName"] = "Fire Breath",
            ["Cooldown"] = 13,
            ["UseLength"] = 3.5,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2},
                {["Type"] = "Normal", ["Damage"] = 2},
                {["Type"] = "Normal", ["Damage"] = 2},
                {["Type"] = "Normal", ["Damage"] = 2},
                {["Type"] = "Normal", ["Damage"] = 2}
            }
        },
        ["FrenziedStrike"] = {
            ["DisplayName"] = "Frenzied Strike",
            ["Cooldown"] = 14,
            ["UseLength"] = 2.6,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5}
            }
        },
        ["Eruption"] = {
            ["DisplayName"] = "Eruption",
            ["Cooldown"] = 16,
            ["UseLength"] = 4,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 8}
            }
        },
        ["SerpentStrike"] = {
            ["DisplayName"] = "Serpent Strike",
            ["Cooldown"] = 10,
            ["UseLength"] = 1.6,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5}
            }
        },
        ["Cannonball"] = {
            ["DisplayName"] = "Cannonball",
            ["Cooldown"] = 12,
            ["UseLength"] = 1.8,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 3}
            }
        },
        ["Skybreaker"] = {
            ["DisplayName"] = "Skybreaker",
            ["Cooldown"] = 8,
            ["UseLength"] = 1.6,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5}
            }
        },
        ["Eviscerate"] = {
            ["DisplayName"] = "Eviscerate",
            ["Cooldown"] = 16,
            ["UseLength"] = {1.7, 0.6, 0.6},
            ["CanMultiHit"] = true,
            ["NumCharges"] = 3,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2}
            }
        },
        ["Thunderclap"] = {
            ["DisplayName"] = "Thunderclap",
            ["Cooldown"] = 11,
            ["UseLength"] = 2.3,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 3}
            }
        },
        ["HammerStorm"] = {
            ["DisplayName"] = "Hammer Storm",
            ["Cooldown"] = 18,
            ["UseLength"] = 2.4,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 13},
                {["Type"] = "Normal", ["Damage"] = 7},
                {["Type"] = "Normal", ["Damage"] = 4},
                {["Type"] = "Normal", ["Damage"] = 2},
                {["Type"] = "Normal", ["Damage"] = 1}
            }
        },
        -- Added Frost Arc
        ["FrostArc"] = {
            ["DisplayName"] = "Frost Arc",
            ["Cooldown"] = 10,
            ["UseLength"] = 0.7,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {
                    ["Type"] = "Normal",
                    ["Damage"] = 2.5,
                    ["Status"] = "Chilled",
                    ["StatusDuration"] = 3
                }
            }
        },
        ["HolyLight"] = {
            ["DisplayName"] = "Holy Light",
            ["Cooldown"] = 25,
            ["UseLength"] = 1.5,
            ["CanMultiHit"] = false,
            ["Hits"] = {},
            ["DamagePerRarity"] = 0.5,
            ["PreloadAnimation"] = "HolyLight"
        },
        ["Whirlpool"] = {
            ["DisplayName"] = "Whirlpool",
            ["Cooldown"] = 22,
            ["UseLength"] = 1.5,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05},
                {["Type"] = "Normal", ["Damage"] = 0.75, ["Status"] = "Slow", ["StatusDuration"] = 1.05}
            },
            ["DamagePerRarity"] = 0.25,
            ["PreloadAnimation"] = "Whirlpool"
        },
        ["MeteorShower"] = {
            ["DisplayName"] = "Meteor Shower",
            ["Cooldown"] = 20,
            ["UseLength"] = 2.5,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Magic", ["Damage"] = 3.5},
                {["Type"] = "Magic", ["Damage"] = 3.5},
                {["Type"] = "Magic", ["Damage"] = 3.5},
                {["Type"] = "Magic", ["Damage"] = 3.5},
                {["Type"] = "Magic", ["Damage"] = 3.5}
            },
            ["PreloadAnimation"] = "MeteorShower"
        },
        ["ShadowStrike"] = {
            ["DisplayName"] = "Shadow Strike",
            ["Cooldown"] = 12,
            ["UseLength"] = 1.1,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Dark", ["Damage"] = 5, ["Status"] = "Blind", ["StatusDuration"] = 2}
            },
            ["PreloadAnimation"] = "ShadowStrike"
        },
        ["Berserk"] = {
            ["DisplayName"] = "Berserk",
            ["Cooldown"] = 18,
            ["UseLength"] = 2,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 6, ["Status"] = "Rage", ["StatusDuration"] = 5}
            },
            ["PreloadAnimation"] = "Berserk"
        },
        ["ChainHeal"] = {
            ["DisplayName"] = "Chain Heal",
            ["Cooldown"] = 20,
            ["UseLength"] = 1.5,
            ["CanMultiHit"] = true,
            ["Hits"] = {}, -- Healing skill, no damage
            ["PreloadAnimation"] = "ChainHeal"
        },
        ["ChainLightning"] = {
            ["DisplayName"] = "Chain Lightning",
            ["Cooldown"] = 14,
            ["UseLength"] = 1.7,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Magic", ["Damage"] = 2.8},
                {["Type"] = "Magic", ["Damage"] = 2.2},
                {["Type"] = "Magic", ["Damage"] = 1.6}
            },
            ["PreloadAnimation"] = "ChainLightning"
        },
        ["FlameRider"] = {
            ["DisplayName"] = "Flame Rider",
            ["Cooldown"] = 16,
            ["UseLength"] = 2.2,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Fire", ["Damage"] = 3.5},
                {["Type"] = "Fire", ["Damage"] = 3.5}
            },
            ["PreloadAnimation"] = "FlameRider"
        },
        ["MagicMissiles"] = {
            ["DisplayName"] = "Magic Missiles",
            ["Cooldown"] = 10,
            ["UseLength"] = 1.2,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Magic", ["Damage"] = 1.5},
                {["Type"] = "Magic", ["Damage"] = 1.5},
                {["Type"] = "Magic", ["Damage"] = 1.5}
            },
            ["PreloadAnimation"] = "MagicMissiles"
        },
        ["SelfHeal"] = {
            ["DisplayName"] = "Self Heal",
            ["Cooldown"] = 18,
            ["UseLength"] = 1.1,
            ["CanMultiHit"] = false,
            ["Hits"] = {}, -- Healing skill, no damage
            ["PreloadAnimation"] = "SelfHeal"
        },
        ["MeteorStorm"] = {
            ["DisplayName"] = "Meteor Storm",
            ["Cooldown"] = 26,
            ["UseLength"] = 1.6,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2.25},
                {["Type"] = "Normal", ["Damage"] = 2.25},
                {["Type"] = "Normal", ["Damage"] = 2.25},
                {["Type"] = "Normal", ["Damage"] = 2.25},
                {["Type"] = "Normal", ["Damage"] = 2.25},
                {["Type"] = "Normal", ["Damage"] = 2.25}
            },
            ["DamagePerRarity"] = 0.6,
            ["PreloadAnimation"] = "MeteorStorm"
        },
        ["PantherPounce"] = {
            ["DisplayName"] = "Panther Pounce",
            ["Cooldown"] = 8,
            ["UseLength"] = 1.5,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 4, ["Status"] = "Punctured", ["StatusDuration"] = 5}
            }
        },
        ["NaturesGrasp"] = {
            ["DisplayName"] = "Nature's Grasp",
            ["Cooldown"] = 10,
            ["UseLength"] = 1.1,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2, ["Status"] = "Snare", ["StatusDuration"] = 4}
            }
        },
        ["CallOfTheWild"] = {
            ["DisplayName"] = "Call of the Wild",
            ["Cooldown"] = 12,
            ["UseLength"] = 1.1,
            ["CanMultiHit"] = false,
            ["Hits"] = {}
        },
        ["PartyAnimal"] = {
            ["DisplayName"] = "Party Animal",
            ["Cooldown"] = 24,
            ["UseLength"] = 2,
            ["CanMultiHit"] = false,
            ["Hits"] = {}
        },
        ["MonkeyKing"] = {
            ["DisplayName"] = "Monkey King",
            ["Cooldown"] = 15,
            ["UseLength"] = 1.8,
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Heal", ["Damage"] = 2.5},
                {["Type"] = "Heal", ["Damage"] = 2.5},
                {["Type"] = "Heal", ["Damage"] = 2.5},
                {["Type"] = "Heal", ["Damage"] = 2.5},
                {["Type"] = "Heal", ["Damage"] = 2.5},
                {["Type"] = "Normal", ["Damage"] = 2.5} -- Changed from Heal to Normal based on context for some skills
            }
        },
        ["Skybreaker"] = {
            ["DisplayName"] = "Skybreaker",
            ["Cooldown"] = 8,
            ["UseLength"] = 1.6,
            ["CanMultiHit"] = false,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5},
                {["Type"] = "Normal", ["Damage"] = 5}
            }
        },
        ["ConsecutiveLightning"] = {
            ["DisplayName"] = "Consecutive Lightning",
            ["Cooldown"] = 21,
            ["UseLength"] = {0.3, 0.4, 0.25, 0.35, 0.5},
            ["CanMultiHit"] = true,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2.5, ["Status"] = "ElectricShock", ["StatusDuration"] = 8}
            }
        },
        ["Eviscerate"] = {
            ["DisplayName"] = "Eviscerate",
            ["Cooldown"] = 16,
            ["UseLength"] = {1.7, 0.6, 0.6},
            ["CanMultiHit"] = true,
            ["NumCharges"] = 3,
            ["Hits"] = {
                {["Type"] = "Normal", ["Damage"] = 2}
            }
        },
        ["Supercharge"] = {
            ["DisplayName"] = "Supercharge",
            ["Cooldown"] = 25,
            ["UseLength"] = 1.8,
            ["CanMultiHit"] = false,
            ["Hits"] = {}
        },
        ["MagicCircle"] = {
            ["DisplayName"] = "Magic Circle",
            ["Cooldown"] = 22,
            ["UseLength"] = 2.4,
            ["CanMultiHit"] = false,
            ["Hits"] = {}
        },
    }

    -- Initialize default selected skills
    RuntimeState.selectedSkills = {"Whirlwind", "FerociousRoar", "Rumble"}
end
initializeSkillData()

-- Auto Skill Helper Functions
local function getEnemiesInRange(range)
    local enemies = {}

    -- Check if we have valid character references
    if not LocalPlayer.Character then
        return enemies
    end

    local character = LocalPlayer.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return enemies
    end

    -- Check if mob folder exists
    if not mobFolder then
        return enemies
    end

    for _, mob in ipairs(mobFolder:GetChildren()) do
        if mob:IsA("Model") then
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")

            if mobHrp then
                -- Check for different health systems used in Dungeon Heroes
                local isAlive = false
                local health = 0

                -- Try Humanoid first (standard Roblox)
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                if mobHumanoid then
                    health = mobHumanoid.Health
                    isAlive = health > 0
                end

                -- If no Humanoid, try Healthbar system (Dungeon Heroes specific)
                if not isAlive then
                    local healthbar = mob:FindFirstChild("Healthbar")
                    if healthbar then
                        -- Look for health value in Healthbar
                        local healthValue = healthbar:FindFirstChild("Health") or healthbar:FindFirstChild("HP") or healthbar:FindFirstChild("CurrentHealth")
                        if healthValue and healthValue:IsA("NumberValue") then
                            health = healthValue.Value
                            isAlive = health > 0
                        end
                    end
                end

                -- Try direct health value on mob
                if not isAlive then
                    local healthValue = mob:FindFirstChild("Health") or mob:FindFirstChild("HP") or mob:FindFirstChild("CurrentHealth")
                    if healthValue and healthValue:IsA("NumberValue") then
                        health = healthValue.Value
                        isAlive = health > 0
                    end
                end

                -- Try MaxHealth value
                if not isAlive then
                    local maxHealthValue = mob:FindFirstChild("MaxHealth")
                    if maxHealthValue and maxHealthValue:IsA("NumberValue") then
                        health = maxHealthValue.Value
                        isAlive = health > 0
                    end
                end

                -- If still no health system found, assume it's alive (some games don't use standard health)
                if not isAlive then
                    isAlive = true
                    -- health = 100 -- Default assumption, but not needed if we just return true
                end

                if isAlive then
                    local distance = (mobHrp.Position - hrp.Position).Magnitude
                    if distance <= range then
                        table.insert(enemies, mob)
                    end
                end
            end
        end
    end

    -- Sort by distance (nearest first)
    table.sort(enemies, function(a, b)
        local distA = (a.HumanoidRootPart.Position - hrp.Position).Magnitude
        local distB = (b.HumanoidRootPart.Position - hrp.Position).Magnitude
        return distA < distB
    end)

    return enemies
end

-- Get nearest mob (for backward compatibility)
local function getNearestMob(maxDistance)
    local enemies = getEnemiesInRange(maxDistance or CONFIG.SKILL_RANGE)
    return enemies[1] -- Return the nearest enemy
end

local function faceTarget(target)
    if not Character or not HRP or not target then return end
    local dir = (target.Position - HRP.Position).Unit
    HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + Vector3.new(dir.X, 0, dir.Z))
end

local function getSkillCooldown(skillName)
    local skillData = RuntimeState.skillData[skillName]
    if skillData then
        return skillData.Cooldown
    end
    return CONFIG.FALLBACK_COOLDOWN
end

local function getEquippedSkills()
    local equippedSkills = {}

    -- Try to get skills from the skill system if available
    if skillSystem and skillSystem.GetSkillInActiveSlot then
        for _, slot in ipairs(CONFIG.SKILL_SLOTS) do
            local skill = skillSystem:GetSkillInActiveSlot(LocalPlayer, tostring(slot))
            if skill and skill ~= "" then
                table.insert(equippedSkills, skill)
            end
        end
    else
        -- Fallback to common skill names if skill system not available
        equippedSkills = {"Whirlwind", "FerociousRoar", "Rumble", "PiercingWave", "Fireball", "DrillStrike", "FireBreath", "FrenziedStrike", "Eruption", "SerpentStrike", "Cannonball", "Skybreaker", "Eviscerate", "Thunderclap", "HammerStorm"}
    end

    return equippedSkills
end

local function useSkill(skillName, target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end

    local skillData = RuntimeState.skillData[skillName]
    if not skillData then
        return
    end

    -- Get multiple enemies in range for area-of-effect attacks
    local enemies = getEnemiesInRange(CONFIG.SKILL_RANGE)
    local maxEnemies = 10 -- Allow up to 10 enemies instead of skill hit count

    -- Limit enemies to max enemies
    local enemiesToHit = {}
    for i = 1, math.min(maxEnemies, #enemies) do
        table.insert(enemiesToHit, enemies[i])
    end

    -- Use the skill based on Dungeon Heroes format
    local skillArgs = {
        [1] = skillName,
        [2] = 1,
    }

    pcall(function()
        Skills:FireServer(unpack(skillArgs))
    end)

    -- Wait a bit before using skill attack
    task.wait(0.1)

    -- Handle all skills with multiple hits
    local numHits = #skillData.Hits
    if numHits > 1 then
        -- Use skill attack for each hit on multiple enemies
        for hitIndex = 1, numHits do
            local attackArgs = {
                [1] = enemiesToHit, -- Attack all enemies in range
                [2] = skillName,
                [3] = hitIndex,
            }

            pcall(function()
                SkillAttack:FireServer(unpack(attackArgs))
            end)

            -- Small delay between hits
            task.wait(0.05)
        end
    else
        -- Single hit skill on multiple enemies
        local attackArgs = {
            [1] = enemiesToHit, -- Attack all enemies in range
            [2] = skillName,
            [3] = 1,
        }

        pcall(function()
            SkillAttack:FireServer(unpack(attackArgs))
        end)
    end

    -- Wait a bit before creating effect
    task.wait(0.1)

    -- Create effect for each enemy hit
    for _, enemy in pairs(enemiesToHit) do
        local effectArgs = {
            [1] = "SlashHit",
            [2] = enemy.HumanoidRootPart.Position,
            [3] = {
                [1] = enemy.HumanoidRootPart.CFrame,
                [3] = Color3.new(0.866667, 0.603922, 0.364706),
                [4] = 30,
                [5] = 1.5,
            }
        }

        pcall(function()
            Effects:FireServer(unpack(effectArgs))
        end)

        -- Small delay between effects
        task.wait(0.02)
    end
end

-- Auto Skill loop
task.spawn(function()
    while true do
        if RuntimeState.autoSkillEnabled and Character and HRP then
            -- Check each skill that is enabled via checkboxes
            for skillName, enabled in pairs(RuntimeState.skillToggles) do
                if enabled then
                    local cooldown = getSkillCooldown(skillName)
                    local last = RuntimeState.lastUsed[skillName] or 0
                    local timeSinceLastUse = tick() - last

                    if timeSinceLastUse >= cooldown then
                        local target = getNearestMob()
                        if target then
                            faceTarget(target.HumanoidRootPart)
                            pcall(function()
                                useSkill(skillName, target)
                            end)
                            RuntimeState.lastUsed[skillName] = tick()
                        end
                    end
                end
            end
        end
        task.wait(CONFIG.SKILL_CHECK_INTERVAL)
    end
end)

--// Auto Farm Configuration
local autoFarmHeight = 50 -- studs above mob
local autoFarmSpeed = 80 -- higher = faster
local autoFarmCheckInterval = 0.2

-- Noclip state
local noclipConnection = nil

--// Auto Farm Loop
task.spawn(function()
    local bodyVelocity = nil
    local currentMob = nil

    while true do
        if autoFarmEnabled and Character and HRP then
            -- Find the next valid mob
            local found = false
            for _, mob in ipairs(mobFolder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                    -- Skip mobs that have PetHealthbar or PetIItemRef
                    if mob:FindFirstChild("PetHealthbar") or mob:FindFirstChild("PetIItemRef") then
                        continue
                    end
                    -- Skip TargetDummy mobs
                    if mob.Name == "TargetDummy" then
                        continue
                    end
                    local mobHRP = mob.HumanoidRootPart
                    local healthbar = mob:FindFirstChild("Healthbar")
                    if healthbar and mobHRP then
                        -- Check if mob is alive (healthbar exists)
                        currentMob = mob
                        found = true
                        break
                    end
                end
            end
            if found and currentMob then
                local mobHRP = currentMob:FindFirstChild("HumanoidRootPart")
                local healthbar = currentMob:FindFirstChild("Healthbar")
                if mobHRP and healthbar then
                    -- Create BodyVelocity if not exists
                    if not bodyVelocity or bodyVelocity.Parent ~= HRP then
                        if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) end
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bodyVelocity.P = 1e4
                        bodyVelocity.Parent = HRP
                    end

                    -- Calculate target position (above mob) using adjustable height
                    local targetPos = mobHRP.Position + Vector3.new(0, autoFarmHeight, 0)
                    local direction = (targetPos - HRP.Position)
                    local distance = direction.Magnitude

                    -- Smoothly move towards target
                    if distance > 1 then
                        bodyVelocity.Velocity = direction.Unit * math.min(distance * 4, autoFarmSpeed)
                    else
                        bodyVelocity.Velocity = Vector3.new(0,0,0)
                    end
                else
                    -- Mob died or healthbar gone, clear and move to next
                    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
                    currentMob = nil
                end
            else
                -- No mobs found, clear velocity
                if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
                currentMob = nil
            end
        else
            -- Not enabled, cleanup
            if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
            currentMob = nil
        end
        task.wait(autoFarmCheckInterval)
    end
end)

-- Kill Aura Configuration
local attackInterval = 0.35 -- Much slower (very safe)
local attackRange = 100 -- Increased range for better mob detection
local mobIndex = 1

-- Kill Aura Loop
task.spawn(function()
    while true do
        if _G.killAuraEnabled and Character and HRP then
            -- Find the nearest mob within range
            local nearestMob = nil
            local nearestDist = math.huge
            for _, mob in ipairs(mobFolder:GetChildren()) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    local mobHRP = mob.HumanoidRootPart
                    local dist = (HRP.Position - mobHRP.Position).Magnitude
                    if dist <= attackRange and dist < nearestDist then
                        nearestDist = dist
                        nearestMob = mob
                    end
                end
            end

            if nearestMob then
                local mobHRP = nearestMob:FindFirstChild("HumanoidRootPart")
                if mobHRP then
                    -- DoEffect
                    local effectArgs = {
                        [1] = "SlashHit",
                        [2] = mobHRP.Position,
                        [3] = { mobHRP.CFrame }
                    }
                    Effects:FireServer(unpack(effectArgs))

                    -- PlayerAttack
                    local attackArgs = {
                        [1] = { nearestMob }
                    }
                    Combat:FireServer(unpack(attackArgs))
                end
            end
        end

        task.wait(attackInterval)
    end
end)

-- Auto Start Dungeon Loop
task.spawn(function()
    while true do
        if autoStartDungeon then
            -- Try to start the dungeon using the correct remote event
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Dungeons", 9e9):WaitForChild("TriggerStartDungeon", 9e9):FireServer()
            end)
            if not success then
                warn("[Auto Start Dungeon] Error:", err)
            end
        end
        task.wait(0.5) -- Try every 2 seconds
    end
end)

-- Auto Reply Dungeon Loop
task.spawn(function()
    while true do
        if autoReplyDungeon then
            local args = {
                [1] = "GoAgain";
            }
            pcall(function()
                RS:WaitForChild("Systems", 9e9)
                    :WaitForChild("Dungeons", 9e9)
                    :WaitForChild("SetExitChoice", 9e9)
                    :FireServer(unpack(args))
            end)
        end
        task.wait(1.5) -- Check every 1.5 seconds
    end
end)

-- Dungeon Sequence and Mini-Boss / Final Boss Detection
local function getLastRoom()
    local DungeonRooms = workspace:FindFirstChild("DungeonRooms")
    if not DungeonRooms then return nil end
    local lastRoom = nil
    local maxNum = -math.huge
    for _, room in ipairs(DungeonRooms:GetChildren()) do
        local num = tonumber(room.Name)
        if num and num > maxNum then
            maxNum = num
            lastRoom = room
        end
    end
    return lastRoom
end

-- NEW: Hardcoded mini-boss names by dungeon code name (not display name)
local miniBossNamesByDungeon = {
    ["GoldDungeon"] = "Aldrazir", -- Golden Realm's mini-boss
    -- Add other dungeons and their specific mini-boss names here as needed
    -- E.g., ["ForestDungeon"] = "ForestMiniBossName",
}

-- MODIFIED FUNCTION: Get mini-boss name for the *current dungeon*
local function getMiniBossNameForDungeon(currentDungeonCodeName)
    -- Prioritize hardcoded mini-boss name if available for this dungeon
    if miniBossNamesByDungeon[currentDungeonCodeName] then
        return miniBossNamesByDungeon[currentDungeonCodeName]
    end

    -- Fallback: If no hardcoded name, try to get the mob from the configured room.
    -- This means the miniBossRoomNumber input is still relevant for *non-hardcoded* mini-bosses.
    local targetRoom = workspace:FindFirstChild("DungeonRooms"):FindFirstChild(tostring(miniBossRoomNumber))
    if not targetRoom then return nil end
    local mobSpawns = targetRoom:FindFirstChild("MobSpawns")
    if mobSpawns then
        local spawns = mobSpawns:FindFirstChild("Spawns")
        if spawns then
            for _, mob in ipairs(spawns:GetChildren()) do
                return mob.Name
            end
        end
    end
    return nil
end


local function getLastRoomBossName()
    local lastRoom = getLastRoom()
    if not lastRoom then return nil end
    local mobSpawns = lastRoom:FindFirstChild("MobSpawns")
    if mobSpawns then
        local spawns = mobSpawns:FindFirstChild("Spawns")
        if spawns then
            -- If there is only one child, it's likely the boss
            for _, boss in ipairs(spawns:GetChildren()) do
                return boss.Name
            end
        end
    end
    return nil
end

-- NEW: Robust function to check if a specific mob is alive and is a mini-boss/boss
local function isTargetMobAlive(mobName, isMiniBossCheck)
    local Mobs = workspace:FindFirstChild("Mobs")
    if not Mobs then return false end

    local mobModel = Mobs:FindFirstChild(mobName)
    if not mobModel then
        return false -- Mob model is not in Mobs folder, so it's defeated/despawned
    end

    -- If this is a mini-boss check, confirm the 'BOSS' folder exists
    if isMiniBossCheck and not mobModel:FindFirstChild("BOSS") then
        -- print("[Debug] Mob model found, but no 'BOSS' folder. Not considered target mini-boss.") -- Debug
        return false
    end

    -- Check for health to confirm it's truly alive
    local mobHumanoid = mobModel:FindFirstChild("Humanoid")
    if mobHumanoid then return mobHumanoid.Health > 0 end

    local healthbar = mobModel:FindFirstChild("Healthbar")
    if healthbar then
        local healthValue = healthbar:FindFirstChild("Health") or healthbar:FindFirstChild("HP") or healthbar:FindFirstChild("CurrentHealth")
        if healthValue and healthValue:IsA("NumberValue") then return healthValue.Value > 0 end
    end

    -- Fallback: if 'BOSS' folder exists (for mini-boss) or it's a general mob check, but no clear health indicator, assume it's alive if it's still there
    return true
end

-- Track completed dungeons (persistent)
local completedDungeons = config.completedDungeons or {}

local dungeonSequence = {
    {name = "ForestDungeon", difficulty = 1}, {name = "ForestDungeon", difficulty = 2}, {name = "ForestDungeon", difficulty = 3}, {name = "ForestDungeon", difficulty = 4},
    {name = "MountainDungeon", difficulty = 1}, {name = "MountainDungeon", difficulty = 2}, {name = "MountainDungeon", difficulty = 3}, {name = "MountainDungeon", difficulty = 4},
    {name = "CoveDungeon", difficulty = 1}, {name = "CoveDungeon", difficulty = 2}, {name = "CoveDungeon", difficulty = 3}, {name = "CoveDungeon", difficulty = 4},
    {name = "CastleDungeon", difficulty = 1}, {name = "CastleDungeon", difficulty = 2}, {name = "CastleDungeon", difficulty = 3}, {name = "CastleDungeon", difficulty = 4},
    {name = "JungleDungeon", difficulty = 1}, {name = "JungleDungeon", difficulty = 2}, {name = "JungleDungeon", difficulty = 3}, {name = "JungleDungeon", difficulty = 4},
    {name = "AstralDungeon", difficulty = 1}, {name = "AstralDungeon", difficulty = 2}, {name = "AstralDungeon", difficulty = 3}, {name = "AstralDungeon", difficulty = 4},
    {name = "DesertDungeon", difficulty = 1}, {name = "DesertDungeon", difficulty = 2}, {name = "DesertDungeon", difficulty = 3}, {name = "DesertDungeon", difficulty = 4},
    {name = "CaveDungeon", difficulty = 1}, {name = "CaveDungeon", difficulty = 2}, {name = "CaveDungeon", difficulty = 3}, {name = "CaveDungeon", difficulty = 4},
    {name = "MushroomDungeon", difficulty = 1}, {name = "MushroomDungeon", difficulty = 2}, {name = "MushroomDungeon", difficulty = 3}, {name = "MushroomDungeon", difficulty = 4},
    {name = "GoldDungeon", difficulty = 1}, {name = "GoldDungeon", difficulty = 2}, {name = "GoldDungeon", difficulty = 3}, {name = "GoldDungeon", difficulty = 4},
}

local function getDungeonKey(entry) return tostring(entry.name) .. "_" .. tostring(entry.difficulty) end

-- MODIFIED AUTO NEXT DUNGEON LOOP
task.spawn(function()
    while true do
        if autoNextDungeon then
            local nextIndex = nil
            local nextEntry = nil
            for i = 1, #dungeonSequence do
                local idx = ((dungeonSequenceIndex + i - 2) % #dungeonSequence) + 1
                local entry = dungeonSequence[idx]
                local key = getDungeonKey(entry)
                if not completedDungeons[key] then
                    nextIndex = idx
                    nextEntry = entry
                    break
                end
            end

            if not nextIndex then
                print("[AutoNextDungeon] All dungeons completed. Disabling auto next dungeon.")
                autoNextDungeon = false
                config.autoNextDungeon = false
                saveConfig()
                break
            end

            dungeonSequenceIndex = nextIndex
            local entry = dungeonSequence[dungeonSequenceIndex]
            local key = getDungeonKey(entry)

            local targetMobName = nil
            local targetMobDescription = ""
            local checkAsMiniBoss = false -- Flag to control 'BOSS' folder check

            if autoResetOnMiniBoss then
                -- Try to get the hardcoded mini-boss name for the current dungeon
                targetMobName = getMiniBossNameForDungeon(entry.name)
                targetMobDescription = "mini-boss '" .. (targetMobName or "Unknown Mini-Boss") .. "' in " .. entry.name
                checkAsMiniBoss = true -- We are specifically looking for a mini-boss here
            else
                targetMobName = getLastRoomBossName()
                targetMobDescription = "final boss in last room"
                checkAsMiniBoss = false -- Not specifically checking for 'BOSS' folder for final boss
            end

            if targetMobName then
                print("[AutoNextDungeon] Waiting for " .. targetMobDescription .. " to appear...")
                local appeared = false
                for i = 1, 300 do -- 5 minutes for target mob to appear
                    if isTargetMobAlive(targetMobName, checkAsMiniBoss) then -- Use new function here
                        appeared = true
                        print("[AutoNextDungeon] " .. targetMobDescription .. " appeared. Now waiting for defeat.")
                        break
                    end
                    task.wait(1)
                    -- print("[AutoNextDungeon] Still waiting for " .. targetMobDescription .. " to appear... (sec: " .. i .. ")") -- Debug
                end

                if appeared then
                    print("[AutoNextDungeon] Waiting for " .. targetMobDescription .. " to be defeated...")
                    for i = 1, 60 do -- 1 minute for target mob to be defeated
                        if not isTargetMobAlive(targetMobName, checkAsMiniBoss) then -- Use new function here
                            print("[AutoNextDungeon] " .. targetMobDescription .. " defeated.")
                            break
                        end
                        task.wait(1)
                        -- print("[AutoNextDungeon] Still waiting for " .. targetMobDescription .. " to be defeated... (sec: " .. i .. ")") -- Debug
                    end
                    task.wait(math.random(2,4))
                else
                    print("[AutoNextDungeon] " .. targetMobDescription .. " did not appear in mobs in time or was already defeated.")
                end
            else
                print("[AutoNextDungeon] No specific target mob (" .. targetMobDescription .. ") found to track. Proceeding without specific mob defeat check.")
            end


            -- Start next dungeon in sequence
            print("[AutoNextDungeon] Starting next dungeon:", entry.name, "Difficulty:", entry.difficulty)
            local args = {
                [1] = entry.name,
                [2] = entry.difficulty,
                [3] = 1,
                [4] = false,
                [5] = false
            }
            pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            task.wait(0.5)
            pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Dungeons", 9e9):WaitForChild("TriggerStartDungeon", 9e9):FireServer()
            end)

            -- Mark as completed and save
            print("[AutoNextDungeon] Marking dungeon as completed:", key)
            completedDungeons[key] = true
            config.completedDungeons = completedDungeons
            saveConfig()

            -- Move to next in sequence for next loop
            dungeonSequenceIndex = dungeonSequenceIndex + 1
            if dungeonSequenceIndex > #dungeonSequence then
                dungeonSequenceIndex = 1
            end
        end
        task.wait(2)
    end
end)


-- Auto Claim Daily Quest
task.spawn(function()
    while true do
        if autoClaimDailyQuest then
            local profile = nil
            pcall(function()
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.DailyQuests and profile.DailyQuests.QuestProgress then
                for _, quest in ipairs(profile.DailyQuests.QuestProgress:GetChildren()) do
                    local questId = tonumber(quest.Name)
                    if questId and not profile.DailyQuests.ClaimedRewards:FindFirstChild(quest.Name) then
                        -- Check if quest is complete
                        local goal = quest:GetAttribute("Goal") or 1
                        if quest.Value >= goal then
                            -- Try to claim
                            pcall(function()
                                RS:WaitForChild("Systems", 9e9)
                                    :WaitForChild("Quests", 9e9)
                                    :WaitForChild("ClaimDailyQuestReward", 9e9)
                                    :FireServer(questId)
                            end)
                            task.wait(0.5) -- Small delay between claims
                        end
                    end
                end
            end
        end
        task.wait(3)
    end
end)


-- Auto Equip Highest Weapon
task.spawn(function()
    while true do
        if autoEquipHighestWeapon then
            local profile = nil
            pcall(function()
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.Inventory and profile.Equipped then
                local itemsModule = nil
                pcall(function()
                    itemsModule = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Items", 9e9))
                end)

                -- Helper to get equipped item and its level for a slot
                local function getEquippedItemAndLevel(slot, typeName)
                    local equippedFolder = profile.Equipped:FindFirstChild(slot)
                    if equippedFolder then
                        for _, equippedItem in ipairs(equippedFolder:GetChildren()) do
                            local itemData = nil
                            pcall(function()
                                itemData = itemsModule:GetItemData(equippedItem.Name)
                            end)
                            if itemData and (not typeName or itemData.Type == typeName) then
                                return equippedItem, itemData.Level or 1
                            end
                        end
                    end
                    return nil, -math.huge
                end

                -- Helper to find highest level item in inventory for a slot
                local function findBestInInventory(category, typeName, equippedItem)
                    local bestItem = nil
                    local bestLevel = -math.huge
                    local bestRarity = -math.huge
                    for _, item in ipairs(profile.Inventory:GetChildren()) do
                        if not equippedItem or item ~= equippedItem then
                            local itemData = nil
                            pcall(function()
                                itemData = itemsModule:GetItemData(item.Name)
                            end)
                            if itemData and itemData.Category == category and (not typeName or itemData.Type == typeName) then
                                local lvl = itemData.Level or 1
                                local rarity = itemsModule:GetRarity(item)
                                if rarity > bestRarity or (rarity == bestRarity and lvl > bestLevel) then
                                    bestRarity = rarity
                                    bestLevel = lvl
                                    bestItem = item
                                end
                            end
                        end
                    end
                    return bestItem, bestLevel
                end

                -- Weapon (Right)
                local equippedWeapon, equippedWeaponLevel = getEquippedItemAndLevel("Right")
                local bestWeaponItem, bestWeaponLevel = findBestInInventory("Weapon", nil, equippedWeapon)
                if bestWeaponItem and bestWeaponLevel > equippedWeaponLevel then
                    pcall(function()
                        RS:WaitForChild("Systems", 9e9)
                            :WaitForChild("Equipment", 9e9)
                            :WaitForChild("Equip", 9e9)
                            :FireServer("Right", bestWeaponItem)
                    end)
                end

                -- Shirt
                local equippedShirt, equippedShirtLevel = getEquippedItemAndLevel("Shirt", "Shirt")
                local bestShirtItem, bestShirtLevel = findBestInInventory("Armor", "Shirt", equippedShirt)
                if bestShirtItem and bestShirtLevel > equippedShirtLevel then
                    pcall(function()
                        RS:WaitForChild("Systems", 9e9)
                            :WaitForChild("Equipment", 9e9)
                            :WaitForChild("EquipArmor", 9e9)
                            :FireServer(bestShirtItem)
                    end)
                end

                -- Pants
                local equippedPants, equippedPantsLevel = getEquippedItemAndLevel("Pants", "Pants")
                local bestPantsItem, bestPantsLevel = findBestInInventory("Armor", "Pants", equippedPants)
                if bestPantsItem and bestPantsLevel > equippedPantsLevel then
                    pcall(function()
                        RS:WaitForChild("Systems", 9e9)
                            :WaitForChild("Equipment", 9e9)
                            :WaitForChild("EquipArmor", 9e9)
                            :FireServer(bestPantsItem)
                    end)
                end
            end
        end
        task.wait(1)
    end
end)


local rarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}
local rarityIndexMap = {Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5}

local autoSellEnabled = false
local selectedRarity = "Common"

-- Auto Sell logic
task.spawn(function()
    while true do
        if autoSellEnabled then
            local profile = nil
            local itemsModule = nil
            pcall(function()
                itemsModule = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Items", 9e9))
                local profileSystem = require(RS:WaitForChild("Systems", 9e9):WaitForChild("Profile", 9e9))
                profile = profileSystem:GetProfile(LocalPlayer)
            end)
            if profile and profile.Inventory and itemsModule then
                local toSell = {}
                -- Always use the latest selectedRarity value
                local rarityLimit = rarityIndexMap[selectedRarity]
                for _, item in ipairs(profile.Inventory:GetChildren()) do
                    local itemData = nil
                    pcall(function()
                        itemData = itemsModule:GetItemData(item.Name)
                    end)
                    local rarity = itemsModule:GetRarity(item)
                    -- Only sell equipment (Weapon or Armor), not Skill, Chest, Animal, Monster, etc.
                    if itemData and (itemData.Category == "Weapon" or itemData.Category == "Armor") and rarity <= rarityLimit then
                        table.insert(toSell, item)
                    end
                end
                if #toSell > 0 then
                    local args = {
                        [1] = toSell,
                        [2] = {}
                    }
                    pcall(function()
                        RS:WaitForChild("Systems", 9e9):WaitForChild("ItemSelling", 9e9):WaitForChild("SellItem", 9e9):FireServer(unpack(args))
                    end)
                end
            end
        end
        task.wait(1)
    end
end)

-- Dungeon name display-to-code mapping
local normalDungeonNameMap = {
    ["Shattered Forest lvl 1+"] = "ForestDungeon",
    ["Orion's Peak lvl 15+"] = "MountainDungeon",
    ["Deadman's Cove lvl 30+"] = "CoveDungeon",
    ["Flaming Depths lvl 45+"] = "CastleDungeon",
    ["Mosscrown Jungle lvl 60+"] = "JungleDungeon",
    ["Astral Abyss lvl 75+"] = "AstralDungeon",
    ["Shifting Sands lvl 90+"] = "VolcanoDungeon",
    ["Shimmering Caves lvl 105+"] = "CaveDungeon",
    ["Mushroom Forest lvl 120+"] = "MushroomDungeon",
    ["Golden ream lvl 135+" ] = "GoldDungeon"
}
local raidDungeonNameMap = {
    ["Abyssal Depths"] = "AbyssDungeon",
    ["Sky Citadel"] = "SkyDungeon",
    ["Molten Volcano"] = "VolcanoDungeon"
}
local eventDungeonNameMap = {
    ["The Gauntlet"] = "Gauntlet",
    ["Halloween Dungeon"] = "HalloweenDungeon",
    ["Christmas Dungeon"] = "ChristmasDungeon"
}

-- Normal Dungeon variables and UI (initialize from config)
local normalDungeonName = config.normalDungeonName
local normalDungeonPlayerLimit = config.normalDungeonPlayerLimit
local normalDungeonDifficulty = config.normalDungeonDifficulty

-- Raid Dungeon variables and UI (initialize from config)
local raidDungeonName = config.raidDungeonName
local raidDungeonPlayerLimit = config.raidDungeonPlayerLimit
local raidDungeonDifficulty = config.raidDungeonDifficulty

-- Event Dungeon variables and UI (initialize from config)
local eventDungeonName = config.eventDungeonName
local eventDungeonPlayerLimit = config.eventDungeonPlayerLimit
local eventDungeonDifficulty = config.eventDungeonDifficulty

-- FPS Boost Utilities
local Services = {Workspace = game:GetService("Workspace")} -- Simplified Services table
local maxFpsBoostConn, superMaxFpsBoostConn
local originalFpsCastShadows = {}; local originalFpsTransparency = {}; local originalFpsParticleStates = {}; local originalFpsMaterial = {}

local function enableCustomFpsBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.TextureQuality = Enum.TextureQuality.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Low
        game:GetService("Lighting").GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 end end
    end)
end
local function disableCustomFpsBoost()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        settings().Rendering.TextureQuality = Enum.TextureQuality.Automatic
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Automatic
        game:GetService("Lighting").GlobalShadows = true
        for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 end end
    end)
end

function enableMaxFpsBoost()
    enableCustomFpsBoost()
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent then
                if originalFpsCastShadows[obj] == nil then originalFpsCastShadows[obj] = obj.CastShadow end
                if originalFpsMaterial[obj] == nil then originalFpsMaterial[obj] = obj.Material end
                pcall(function() obj.CastShadow = false; obj.Material = Enum.Material.Slate; obj.Color = Color3.fromRGB(60, 60, 60) end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                if originalFpsParticleStates[obj] == nil then originalFpsParticleStates[obj] = obj.Enabled end
                pcall(function() obj.Enabled = false end)
            end
        end
    end
    if maxFpsBoostConn then maxFpsBoostConn:Disconnect() end
    maxFpsBoostConn = Services.Workspace.DescendantAdded:Connect(function(obj)
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent then
                if originalFpsCastShadows[obj] == nil then originalFpsCastShadows[obj] = obj.CastShadow end
                if originalFpsMaterial[obj] == nil then originalFpsMaterial[obj] = obj.Material end
                pcall(function() obj.CastShadow = false; obj.Material = Enum.Material.Slate; obj.Color = Color3.fromRGB(60, 60, 60) end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
                if originalFpsParticleStates[obj] == nil then originalFpsParticleStates[obj] = obj.Enabled end
                pcall(function() obj.Enabled = false end)
            end
        end
    end)
end

function disableMaxFpsBoost()
    disableCustomFpsBoost()
    for obj, val in pairs(originalFpsCastShadows) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.CastShadow = val end) end end; originalFpsCastShadows = {}
    for obj, val in pairs(originalFpsMaterial) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.Material = val end) end end; originalFpsMaterial = {}
    for obj, val in pairs(originalFpsParticleStates) do if obj and typeof(obj) == "Instance" and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")) then pcall(function() obj.Enabled = val end) end end; originalFpsParticleStates = {}
    if maxFpsBoostConn then maxFpsBoostConn:Disconnect(); maxFpsBoostConn = nil end
end

function enableSuperMaxFpsBoost()
    enableMaxFpsBoost()
    local playerChar = LocalPlayer.Character
    local whitelist = {"Mobs", "QuestNPCs", "Ores", "MobPortals", "FishingSpots", "Dungeon", "Drops", "CraftingStations", "Characters", "BossRoom", "BossArenas"}
    local whitelistFolders = {}
    for _, name in ipairs(whitelist) do local folder = Services.Workspace:FindFirstChild(name) if folder then table.insert(whitelistFolders, folder) end end
    local function isWhitelisted(obj) for _, folder in ipairs(whitelistFolders) do if obj:IsDescendantOf(folder) then return true end end return false end
    for _, obj in ipairs(Services.Workspace:GetDescendants()) do
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent and (not playerChar or not obj:IsDescendantOf(playerChar)) then
                if not isWhitelisted(obj) then if originalFpsTransparency[obj] == nil then originalFpsTransparency[obj] = obj.Transparency end pcall(function() obj.Transparency = 1 end) else pcall(function() obj.CanCollide = false end) end
            elseif (obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Adornment")) and not isWhitelisted(obj) then pcall(function() obj.Enabled = false end) end
        end
    end
    if superMaxFpsBoostConn then superMaxFpsBoostConn:Disconnect() end
    superMaxFpsBoostConn = Services.Workspace.DescendantAdded:Connect(function(obj)
        if obj and typeof(obj) == "Instance" then
            if obj:IsA("BasePart") and obj.Parent and (not playerChar or not obj:IsDescendantOf(playerChar)) then
                if not isWhitelisted(obj) then if originalFpsTransparency[obj] == nil then originalFpsTransparency[obj] = obj.Transparency end pcall(function() obj.Transparency = 1 end) else pcall(function() obj.CanCollide = false end) end
            elseif (obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Adornment")) and not isWhitelisted(obj) then pcall(function() obj.Enabled = false end) end
        end
    end)
end

function disableSuperMaxFpsBoost()
    disableMaxFpsBoost()
    for obj, val in pairs(originalFpsTransparency) do if obj and typeof(obj) == "Instance" and obj:IsA("BasePart") and obj.Parent then pcall(function() obj.Transparency = val end) end end; originalFpsTransparency = {}
    if superMaxFpsBoostConn then superMaxFpsBoostConn:Disconnect(); superMaxFpsBoostConn = nil end
end

-- Apply FPS boost settings from config on script load
if config.supermaxfpsBoostenabled then enableSuperMaxFpsBoost()
elseif config.maxfpsBoostenabled then enableMaxFpsBoost()
elseif config.fpsBoostEnabled then enableCustomFpsBoost()
else disableSuperMaxFpsBoost(); disableMaxFpsBoost(); disableCustomFpsBoost() end

-- UI Creation (using Obsidian Library)
local Window = Library:CreateWindow({
    Title = "Seisen Hub",
    Footer = "Dungeon Heroes",
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode[config.uiToggleKey], -- Use configured key
    MobileButtonsSide = "Right"
})

-- Add tabs
local MainTab = Window:AddTab("Main", "box")
local DungeonTab = Window:AddTab("Dungeon", "swords")
local SettingsTab = Window:AddTab("UI Settings", "settings")

-- Add groupboxes
local FeaturesBox = MainTab:AddLeftGroupbox("Features")
local AutoSkillBox = MainTab:AddRightGroupbox("Auto Skill")
local NormalDungeonBox = DungeonTab:AddLeftGroupbox("Normal Dungeon")
local RaidDungeonBox = DungeonTab:AddRightGroupbox("Raid Dungeon")
local EventDungeonBox = DungeonTab:AddLeftGroupbox("Event Dungeon")
local SettingsTabbox = SettingsTab:AddLeftTabbox("Settings") -- Obsidian uses Tabbox for nested tabs
local ThemeTab = SettingsTabbox:AddTab("Theme") -- Tab inside Tabbox

-- Function to set up UI elements and load their states from config
local function setupUI()
    -- Features Tab
    local autoFarmToggleUI = FeaturesBox:AddToggle("AutoFarm", {
        Text = "Auto Farm",
        Default = config.autoFarmEnabled,
        Tooltip = "Automatically moves above mobs and attacks them",
        Callback = function(Value)
            autoFarmEnabled = Value
            config.autoFarmEnabled = Value
            saveConfig()
            if Value then
                if not noclipConnection then
                    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                        if Character then
                            for _, part in ipairs(Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            else
                if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
                if Character then for _, part in ipairs(Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
            end
            print("Auto Farm: " .. (Value and "Enabled" or "Disabled"))
        end
    })
    autoFarmToggleUI:SetValue(config.autoFarmEnabled)

    local autoFarmHeightSliderUI = FeaturesBox:AddSlider("AutoFarmHeight", {
        Text = "Auto Farm Height", Min = 10, Max = 80, Default = config.autoFarmHeight, Suffix = " studs", Rounding = 0,
        Tooltip = "How high above the mob to farm",
        Callback = function(Value) autoFarmHeight = Value; config.autoFarmHeight = Value; saveConfig() end
    })
    autoFarmHeightSliderUI:SetValue(config.autoFarmHeight)

    local killAuraToggleUI = FeaturesBox:AddToggle("KillAura", {
        Text = "Kill Aura", Default = config.killAuraEnabled,
        Tooltip = "Automatically attacks nearby mobs",
        Callback = function(Value) _G.killAuraEnabled = Value; config.killAuraEnabled = Value; saveConfig(); print("Kill Aura: " .. (Value and "Enabled" or "Disabled")) end
    })
    killAuraToggleUI:SetValue(config.killAuraEnabled)

    local autoReplyDungeonToggleUI = FeaturesBox:AddToggle("AutoReplyDungeon", {
        Text = "Auto Replay Dungeon", Default = config.autoReplyDungeon,
        Tooltip = "Automatically replies 'GoAgain' to dungeon exit prompt",
        Callback = function(Value) autoReplyDungeon = Value; config.autoReplyDungeon = Value; saveConfig(); print("Auto Replay Dungeon: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoReplyDungeonToggleUI:SetValue(config.autoReplyDungeon)

    local autoClaimDailyQuestToggleUI = FeaturesBox:AddToggle("AutoClaimDailyQuest", {
        Text = "Auto Claim Daily Quest", Default = config.autoClaimDailyQuest,
        Tooltip = "Automatically claims all available daily quest rewards",
        Callback = function(Value) autoClaimDailyQuest = Value; config.autoClaimDailyQuest = Value; saveConfig(); print("Auto Claim Daily Quest: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoClaimDailyQuestToggleUI:SetValue(config.autoClaimDailyQuest)

    local autoEquipHighestWeaponToggleUI = FeaturesBox:AddToggle("AutoEquipHighestWeapon", {
        Text = "Auto Equip Highest Equipment", Default = config.autoEquipHighestWeapon,
        Tooltip = "Automatically equips your highest attack weapon",
        Callback = function(Value) autoEquipHighestWeapon = Value; config.autoEquipHighestWeapon = Value; saveConfig(); print("Auto Equip Highest Equipment: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoEquipHighestWeaponToggleUI:SetValue(config.autoEquipHighestWeapon)

    local autoSellToggleUI = FeaturesBox:AddToggle("AutoSell", {
        Text = "Auto Sell", Default = config.autoSellEnabled,
        Tooltip = "Automatically sells items of selected rarity and below (except skills)",
        Callback = function(Value) autoSellEnabled = Value; config.autoSellEnabled = Value; saveConfig(); print("Auto Sell: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoSellToggleUI:SetValue(config.autoSellEnabled)

    local autoSellRarityDropdownUI = FeaturesBox:AddDropdown("AutoSellRarity", {
        Text = "Auto Sell Rarity", Values = rarityList, Default = config.autoSellRarity,
        Tooltip = "Sell items of this rarity and below",
        Callback = function(Value) selectedRarity = Value; config.autoSellRarity = Value; saveConfig(); print("Auto Sell Rarity: " .. Value) end
    })
    autoSellRarityDropdownUI:SetValue(config.autoSellRarity)

    -- Auto Skill Box
    local autoSkillToggleUI = AutoSkillBox:AddToggle("AutoSkill", {
        Text = "Enable Auto Skill", Default = config.autoSkillEnabled,
        Tooltip = "Automatically uses selected skills on nearby mobs",
        Callback = function(Value) RuntimeState.autoSkillEnabled = Value; config.autoSkillEnabled = Value; saveConfig(); print("Auto Skill: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoSkillToggleUI:SetValue(config.autoSkillEnabled)

    local skillNames = {}
    for skillName in pairs(RuntimeState.skillData) do table.insert(skillNames, skillName) end
    table.sort(skillNames, function(a, b) return RuntimeState.skillData[a].DisplayName:lower() < RuntimeState.skillData[b].DisplayName:lower() end)

    for _, skillName in ipairs(skillNames) do
        local skillData = RuntimeState.skillData[skillName]
        local skillToggleUI = AutoSkillBox:AddToggle(skillName, {
            Text = skillData.DisplayName, Default = config.skillToggles[skillName] or false,
            Tooltip = "Use " .. skillData.DisplayName .. " (Cooldown: " .. (skillData.Cooldown or "?") .. "s)",
            Callback = function(Value) RuntimeState.skillToggles[skillName] = Value; config.skillToggles[skillName] = Value; saveConfig() end
        })
        skillToggleUI:SetValue(config.skillToggles[skillName] or false)
    end

    -- Normal Dungeon Box
    local autoNextDungeonToggleUI = NormalDungeonBox:AddToggle("AutoNextDungeon", {
        Text = "Auto Next Dungeon Sequence", Default = config.autoNextDungeon,
        Tooltip = "Automatically cycles through a dungeon/difficulty list",
        Callback = function(Value) autoNextDungeon = Value; config.autoNextDungeon = Value; saveConfig(); print("Auto Next Dungeon: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoNextDungeonToggleUI:SetValue(config.autoNextDungeon)

    local autoResetOnMiniBossToggleUI = NormalDungeonBox:AddToggle("AutoResetOnMiniBoss", {
        Text = "Auto Reset on Mini-Boss Defeat", Default = config.autoResetOnMiniBoss,
        Tooltip = "Resets dungeon after the mob in the specified room is defeated instead of the final boss. Prioritizes specific mini-boss names like Aldrazir.",
        Callback = function(Value) autoResetOnMiniBoss = Value; config.autoResetOnMiniBoss = Value; saveConfig(); print("Auto Reset on Mini-Boss: " .. (Value and "Enabled" or "Disabled")) end
    })
    autoResetOnMiniBossToggleUI:SetValue(config.autoResetOnMiniBoss)

    local miniBossRoomNumberInputUI = NormalDungeonBox:AddInput("MiniBossRoomNumber", {
        Text = "Fallback Mini-Boss Room", Default = tostring(config.miniBossRoomNumber), Placeholder = "e.g., 6",
        Tooltip = "Fallback room number for mini-boss detection if no specific mini-boss name is hardcoded for the dungeon. Default is 6.",
        Callback = function(Value)
            local num = tonumber(Value)
            if num and num > 0 then miniBossRoomNumber = num; config.miniBossRoomNumber = num; saveConfig(); print("Fallback Mini-Boss Room Number set to: " .. num)
            else print("Invalid input for Fallback Mini-Boss Room Number. Please enter a valid number.") end
        end
    })
    miniBossRoomNumberInputUI:SetValue(tostring(config.miniBossRoomNumber))

    local normalDungeonNameDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonName", {
        Text = "Dungeon Name", Values = {"Shattered Forest lvl 1+", "Orion's Peak lvl 15+", "Deadman's Cove lvl 30+", "Flaming Depths lvl 45+", "Mosscrown Jungle lvl 60+", "Astral Abyss lvl 75+", "Shifting Sands lvl 90+", "Shimmering Caves lvl 105+", "Mushroom Forest lvl 120+", "Golden ream lvl 135+"},
        Default = config.normalDungeonName,
        Callback = function(Value) normalDungeonName = Value; config.normalDungeonName = Value; saveConfig(); print("Normal Dungeon Name: " .. Value) end
    })
    normalDungeonNameDropdownUI:SetValue(config.normalDungeonName)

    local normalDungeonDifficultyDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonDifficulty", {
        Text = "Difficulty", Values = {"Normal", "Medium", "Hard", "Insane", "Extreme"}, Default = config.normalDungeonDifficulty,
        Callback = function(Value) normalDungeonDifficulty = Value; config.normalDungeonDifficulty = Value; saveConfig(); print("Normal Dungeon Difficulty: " .. Value) end
    })
    normalDungeonDifficultyDropdownUI:SetValue(config.normalDungeonDifficulty)

    local normalDungeonPlayerLimitDropdownUI = NormalDungeonBox:AddDropdown("NormalDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"1","2","3","4","5","6","7"}, Default = tostring(config.normalDungeonPlayerLimit),
        Callback = function(Value) normalDungeonPlayerLimit = tonumber(Value); config.normalDungeonPlayerLimit = normalDungeonPlayerLimit; saveConfig(); print("Normal Dungeon Player Limit: " .. Value) end
    })
    normalDungeonPlayerLimitDropdownUI:SetValue(tostring(config.normalDungeonPlayerLimit))

    NormalDungeonBox:AddButton("StartNormalDungeon", {
        Text = "Start Dungeon",
        Func = function()
            local difficultyIndexMap = {Normal=1, Medium=2, Hard=3, Insane=4, Extreme=5}
            local args = {
                [1] = normalDungeonNameMap[normalDungeonName] or "ForestDungeon",
                [2] = difficultyIndexMap[normalDungeonDifficulty] or 1,
                [3] = normalDungeonPlayerLimit,
                [4] = false,
                [5] = false
            }
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            if success then print("Attempted to start Normal Dungeon: " .. normalDungeonName .. " (" .. normalDungeonDifficulty .. ")")
            else warn("[Start Normal Dungeon] Error:", err) end
        end
    })

    -- Raid Dungeon Box
    local raidDungeonNameDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonName", {
        Text = "Dungeon Name", Values = {"Abyssal Depths", "Sky Citadel", "Molten Volcano"}, Default = config.raidDungeonName,
        Callback = function(Value) raidDungeonName = Value; config.raidDungeonName = Value; saveConfig(); print("Raid Dungeon Name: " .. Value) end
    })
    raidDungeonNameDropdownUI:SetValue(config.raidDungeonName)

    local raidDungeonDifficultyDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonDifficulty", {
        Text = "Difficulty", Values = {"RAID"}, Default = config.raidDungeonDifficulty,
        Callback = function(Value) raidDungeonDifficulty = Value; config.raidDungeonDifficulty = Value; saveConfig(); print("Raid Dungeon Difficulty: " .. Value) end
    })
    raidDungeonDifficultyDropdownUI:SetValue(config.raidDungeonDifficulty)

    local raidDungeonPlayerLimitDropdownUI = RaidDungeonBox:AddDropdown("RaidDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"5","6","7"}, Default = tostring(config.raidDungeonPlayerLimit),
        Callback = function(Value) raidDungeonPlayerLimit = tonumber(Value); config.raidDungeonPlayerLimit = raidDungeonPlayerLimit; saveConfig(); print("Raid Dungeon Player Limit: " .. Value) end
    })
    raidDungeonPlayerLimitDropdownUI:SetValue(tostring(config.raidDungeonPlayerLimit))

    RaidDungeonBox:AddButton("StartRaidDungeon", {
        Text = "Start Raid Dungeon",
        Func = function()
            local difficultyIndex = {RAID=7}
            local args = {
                [1] = raidDungeonNameMap[raidDungeonName] or "AbyssDungeon",
                [2] = raidDungeonPlayerLimit,
                [3] = difficultyIndex[raidDungeonDifficulty] or 7,
                [4] = false,
                [5] = false
            }
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            if success then print("Attempted to start Raid Dungeon: " .. raidDungeonName .. " (" .. raidDungeonDifficulty .. ")")
            else warn("[Start Raid Dungeon] Error:", err) end
        end
    })

    -- Event Dungeon Box
    local eventDungeonNameDropdownUI = EventDungeonBox:AddDropdown("EventDungeonName", {
        Text = "Dungeon Name", Values = {"Gauntlet", "Halloween Dungeon", "Christmas Dungeon"}, Default = config.eventDungeonName,
        Callback = function(Value) eventDungeonName = Value; config.eventDungeonName = Value; saveConfig(); print("Event Dungeon Name: " .. Value) end
    })
    eventDungeonNameDropdownUI:SetValue(config.eventDungeonName)

    local eventDungeonDifficultyDropdownUI = EventDungeonBox:AddDropdown("EventDungeonDifficulty", {
        Text = "Difficulty", Values = {"Normal", "Hard", "Insane"}, Default = config.eventDungeonDifficulty,
        Callback = function(Value) eventDungeonDifficulty = Value; config.eventDungeonDifficulty = Value; saveConfig(); print("Event Dungeon Difficulty: " .. Value) end
    })
    eventDungeonDifficultyDropdownUI:SetValue(config.eventDungeonDifficulty)

    local eventDungeonPlayerLimitDropdownUI = EventDungeonBox:AddDropdown("EventDungeonPlayerLimit", {
        Text = "Player Limit", Values = {"1","2","3","4","5"}, Default = tostring(config.eventDungeonPlayerLimit),
        Callback = function(Value) eventDungeonPlayerLimit = tonumber(Value); config.eventDungeonPlayerLimit = eventDungeonPlayerLimit; saveConfig(); print("Event Dungeon Player Limit: " .. Value) end
    })
    eventDungeonPlayerLimitDropdownUI:SetValue(tostring(config.eventDungeonPlayerLimit))

    EventDungeonBox:AddButton("StartEventDungeon", {
        Text = "Start Event Dungeon",
        Func = function()
            local difficultyIndexMap = {Normal=1, Hard=3, Insane=4}
            local args = {
                [1] = eventDungeonNameMap[eventDungeonName] or "Gauntlet",
                [2] = eventDungeonPlayerLimit,
                [3] = difficultyIndexMap[eventDungeonDifficulty] or 1,
                [4] = false
            }
            local success, err = pcall(function()
                RS:WaitForChild("Systems", 9e9):WaitForChild("Parties", 9e9):WaitForChild("SetSettings", 9e9):FireServer(unpack(args))
            end)
            if success then print("Attempted to start Event Dungeon: " .. eventDungeonName .. " (" .. eventDungeonDifficulty .. ")")
            else warn("[Start Event Dungeon] Error:", err) end
        end
    })

    -- Settings Tab (Graphics & UI)
    local fpsBoostToggleUI = ThemeTab:AddToggle("FpsBoost", {
        Text = "FPS Boost", Default = config.fpsBoostEnabled,
        Tooltip = "Reduces graphics for better performance",
        Callback = function(Value)
            fpsBoostEnabled = Value; config.fpsBoostEnabled = Value; saveConfig()
            if Value then enableCustomFpsBoost() else disableCustomFpsBoost() end
            print("FPS Boost: " .. (Value and "Enabled" or "Disabled"))
        end
    })
    fpsBoostToggleUI:SetValue(config.fpsBoostEnabled)

    local maxFpsBoostToggleUI = ThemeTab:AddToggle("MaxFpsBoost", {
        Text = "Max FPS Boost", Default = config.maxfpsBoostenabled,
        Tooltip = "Disables most effects for maximum FPS (also sets all parts to SmoothPlastic)",
        Callback = function(Value)
            maxfpsBoostenabled = Value; config.maxfpsBoostenabled = Value; saveConfig()
            if Value then enableMaxFpsBoost() else disableMaxFpsBoost() end
            print("Max FPS Boost: " .. (Value and "Enabled" or "Disabled"))
        end
    })
    maxFpsBoostToggleUI:SetValue(config.maxfpsBoostenabled)

    local superMaxFpsBoostToggleUI = ThemeTab:AddToggle("SuperMaxFpsBoost", {
        Text = "Super Max FPS Boost", Default = config.supermaxfpsBoostenabled,
        Tooltip = "Hides almost everything except mobs and some objects for ultimate FPS",
        Callback = function(Value)
            supermaxfpsBoostenabled = Value; config.supermaxfpsBoostenabled = Value; saveConfig()
            if Value then enableSuperMaxFpsBoost() else disableSuperMaxFpsBoost() end
            print("Super Max FPS Boost: " .. (Value and "Enabled" or "Disabled"))
        end
    })
    superMaxFpsBoostToggleUI:SetValue(config.supermaxfpsBoostenabled)

    -- UI Toggle Key Input
    -- IMPORTANT: Obsidian UI's ToggleKeybind is set at CreateWindow. If you change it here,
    -- you would need to re-create the window or modify Obsidian's internal keybind logic directly.
    -- For simplicity, this input will just update the config, but won't change the active keybind until script re-execution.
    local uiToggleKeyInput = ThemeTab:AddInput("UIToggleKey", {
        Text = "UI Toggle Key", Default = config.uiToggleKey, Placeholder = "e.g., RightControl",
        Tooltip = "Change the key to toggle the UI. Requires script re-execution to apply.",
        Callback = function(Value)
            -- Validate if it's a valid Enum.KeyCode string before saving
            local success, _ = pcall(function() return Enum.KeyCode[Value] end)
            if success then
                config.uiToggleKey = Value; saveConfig(); print("UI Toggle Key set to: " .. Value .. ". Restart script to apply.")
            else
                print("Invalid KeyCode string: " .. Value .. ". Please use a valid Enum.KeyCode name (e.g., RightControl, Home).")
            end
        end
    })
    uiToggleKeyInput:SetValue(config.uiToggleKey)


    ThemeTab:AddButton({
        Text = "Unload UI",
        Func = function()
            -- Destroy all UI created by this script (Obsidian/Library UI)
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and (
                        gui.Name:lower():find("obsidian") or
                        gui.Name:lower():find("seisen") or -- Add Seisen to help clean up
                        gui.Name:lower():find("dungeonheroes") or
                        gui.Name:lower():find("dungeon_heroes") or
                        gui.Name:lower():find("dhui")
                    ) then
                        pcall(function() gui:Destroy() end)
                    end
                end
            end

            -- Attempt to call Library.Unload if it exists
            -- This is Obsidian's internal cleanup, which is crucial for it
            if Library and Library.Unload then pcall(function() Library:Unload() end) end

            -- Disconnect all running connections and tasks (clean up anti-afk, noclip, etc.)
            if noclipConnection then pcall(function() noclipConnection:Disconnect() end); noclipConnection = nil end
            AntiAfkSystem.cleanup()

            -- Stop all task.spawn loops by setting flags to false
            _G.killAuraEnabled = false; RuntimeState.autoSkillEnabled = false; RuntimeState.skillToggles = {};
            autoFarmEnabled = false; autoStartDungeon = false; autoReplyDungeon = false; autoNextDungeon = false;
            autoClaimDailyQuest = false; autoEquipHighestWeapon = false; autoResetOnMiniBoss = false; autoSellEnabled = false;

            -- Attempt to destroy any leftover BodyVelocity
            pcall(function()
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    for _, obj in ipairs(Character.HumanoidRootPart:GetChildren()) do
                        if obj:IsA("BodyVelocity") then
                            obj:Destroy()
                        end
                    end
                end
            end)

            -- Disconnect FPS boost connections and restore settings
            if maxFpsBoostConn then pcall(function() maxFpsBoostConn:Disconnect() end); maxFpsBoostConn = nil end
            if superMaxFpsBoostConn then pcall(function() superMaxFpsBoostConn:Disconnect() end); superMaxFpsBoostConn = nil end
            disableCustomFpsBoost(); disableMaxFpsBoost(); disableSuperMaxFpsBoost();
            
            -- Re-enable MouseIcon (Obsidian disables it by default when UI is open)
            game:GetService("UserInputService").MouseIconEnabled = true

            print("Dungeon Heroes Script Unloaded.")
        end
    })
end

-- Initialize UI elements and connect them to logic
setupUI()

print("Dungeon Heroes Script Loaded Successfully with Obsidian UI!")