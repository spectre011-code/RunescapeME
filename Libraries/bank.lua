local ScriptName = "Bank Toolbox"
local Author = "Spectre011"
local ScriptVersion = "1.0.4"
local ReleaseDate = "02-05-2025"
local DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 02-05-2025
    - Initial release.
v1.0.1 - 02-05-2025
    - Forgot to add changelog.
v1.0.2 - 02-05-2025
    - Renamed some functions to be more similar to other ME functions
v1.0.3 - 02-05-2025
    - More renames
    - Removed empty lines
v1.0.4 - 04-05-2025
    - Edited credits variables to be local to prevent some funny interactions with my other scripts.
    - Added functions: 
        BANK.GetTransferTab()
        BANK.SetTransferTab()
        BANK.PresetSettingsIsOpen()
        BANK.PresetSettingsOpen()
        BANK.PresetSettingsReturnToBank()
        BANK.PresetSettingsGetSelectedPreset()
        BANK.PresetSettingsSelectPreset()
        BANK.PresetSettingsGetInventory()
        BANK.PresetSettingsGetEquipment()
        BANK.PrintInventory()
    - Edited relevant functions to check for transfer/preset tabs.
    - Edited some prints to be more descriptive.
]]

local API = require("api")

local BANK = {}

--This gets the ids of the items
local CollectionBoxSlots = { -- https://imgur.com/WN60RRo 
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,15,-1,0 }, { 109,14,-1,0 }, { 109,14,1,0 } }, -- Slot 1
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,15,-1,0 }, { 109,14,-1,0 }, { 109,14,3,0 } }, -- Slot 2

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,21,-1,0 }, { 109,12,-1,0 }, { 109,12,1,0 } }, -- Slot 3
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,21,-1,0 }, { 109,12,-1,0 }, { 109,12,3,0 } }, -- Slot 4

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,22,-1,0 }, { 109,10,-1,0 }, { 109,10,1,0 } }, -- Slot 5
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,22,-1,0 }, { 109,10,-1,0 }, { 109,10,3,0 } }, -- Slot 6

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,23,-1,0 }, { 109,7,-1,0 }, { 109,7,1,0 } }, -- Slot 7
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,23,-1,0 }, { 109,7,-1,0 }, { 109,7,3,0 } }, -- Slot 8

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,24,-1,0 }, { 109,4,-1,0 }, { 109,4,1,0 } }, -- Slot 9
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,24,-1,0 }, { 109,4,-1,0 }, { 109,4,3,0 } }, -- Slot 10

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,25,-1,0 }, { 109,1,-1,0 }, { 109,1,1,0 } }, -- Slot 11
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,25,-1,0 }, { 109,1,-1,0 }, { 109,1,3,0 } }, -- Slot 12

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,26,-1,0 }, { 109,62,-1,0 }, { 109,62,1,0 } }, -- Slot 13
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,26,-1,0 }, { 109,62,-1,0 }, { 109,62,3,0 } }, -- Slot 14

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,27,-1,0 }, { 109,67,-1,0 }, { 109,67,1,0 } }, -- Slot 15
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,27,-1,0 }, { 109,67,-1,0 }, { 109,67,3,0 } } -- Slot 16
}

--This gets the name of the items
--[[
local CollectionBoxSlots = { -- https://imgur.com/WN60RRo
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,15,-1,0 }, { 109,14,-1,0 }, { 109,14,0,0 } }, -- Slot 1
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,15,-1,0 }, { 109,14,-1,0 }, { 109,14,2,0 } }, -- Slot 2

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,21,-1,0 }, { 109,12,-1,0 }, { 109,12,0,0 } }, -- Slot 3
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,21,-1,0 }, { 109,12,-1,0 }, { 109,12,2,0 } }, -- Slot 4

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,22,-1,0 }, { 109,10,-1,0 }, { 109,10,0,0 } }, -- Slot 5
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,22,-1,0 }, { 109,10,-1,0 }, { 109,10,2,0 } }, -- Slot 6

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,23,-1,0 }, { 109,7,-1,0 }, { 109,7,0,0 } }, -- Slot 7
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,23,-1,0 }, { 109,7,-1,0 }, { 109,7,2,0 } }, -- Slot 8

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,24,-1,0 }, { 109,4,-1,0 }, { 109,4,0,0 } }, -- Slot 9
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,24,-1,0 }, { 109,4,-1,0 }, { 109,4,2,0 } }, -- Slot 10

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,25,-1,0 }, { 109,1,-1,0 }, { 109,1,0,0 } }, -- Slot 11
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,25,-1,0 }, { 109,1,-1,0 }, { 109,1,2,0 } }, -- Slot 12

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,26,-1,0 }, { 109,62,-1,0 }, { 109,62,0,0 } }, -- Slot 13
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,26,-1,0 }, { 109,62,-1,0 }, { 109,62,2,0 } }, -- Slot 14

    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,27,-1,0 }, { 109,67,-1,0 }, { 109,67,0,0 } }, -- Slot 15
    { { 109,37,-1,0 }, { 109,39,-1,0 }, { 109,27,-1,0 }, { 109,67,-1,0 }, { 109,67,2,0 } } -- Slot 16
}]]

local PresetSettingsInventory = { 
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,0,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,1,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,2,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,3,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,4,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,5,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,6,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,7,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,8,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,9,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,10,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,11,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,12,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,13,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,14,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,15,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,16,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,17,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,18,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,19,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,20,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,21,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,22,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,23,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,24,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,25,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,26,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,277,-1,0 }, { 517,280,-1,0 }, { 517,280,27,0 } }
}

local PresetSettingsEquipment = {
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,0,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,1,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,2,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,3,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,4,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,5,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,7,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,9,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,10,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,12,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,13,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,14,0 } },
    { { 517,0,-1,0 }, { 517,2,-1,0 }, { 517,153,-1,0 }, { 517,261,-1,0 }, { 517,262,-1,0 }, { 517,281,-1,0 }, { 517,283,-1,0 }, { 517,284,-1,0 }, { 517,286,-1,0 }, { 517,290,-1,0 }, { 517,290,17,0 } }
}

-- Attempts to open your bank using the listed options. Requires cache enabled https://imgur.com/5I9a46V
---@return boolean
function BANK.Open()
    print("[BANK] Opening bank.")
    if Interact:NPC("Banker", "Bank", 50) then
        print("[BANK] Banker succeded.")
        return true
    end

    if Interact:Object("Bank chest", "Use", 50) then
        print("[BANK] Bank chest succeded.")
        return true
    end

    if Interact:Object("Bank booth", "Bank", 50) then
        print("[BANK] Bank booth succeded.")
        return true
    end

    if Interact:Object("Counter", "Bank", 50) then
        print("[BANK] Counter succeded.")
        return true
    end

    print("[BANK] Could not interact with any of the following: Banker, Bank chest, Bank booth and Counter.")
    return false
end

-- Attempts to open your collection box using the listed options. Requires cache enabled https://imgur.com/5I9a46V
---@return boolean
function BANK.OpenCollectionBox()
    print("[BANK] Opening colection box.")
    if Interact:NPC("Banker", "Collect", 50) then
        print("[BANK] Banker succeded.")
        return true
    end

    if Interact:Object("Bank chest", "Collect", 50) then
        print("[BANK] Bank chest succeded.")
        return true
    end

    if Interact:Object("Bank booth", "Collect", 50) then
        print("[BANK] Bank booth succeded.")
        return true
    end

    if Interact:Object("Counter", "Collect", 50) then
        print("[BANK] Counter succeded.")
        return true
    end

    print("[BANK] Could not interact with any of the following: Banker, Bank chest, Bank booth and Counter.")
    return false
end

-- Attempts to open a deposit box. Requires cache enabled https://imgur.com/5I9a46V
---@return boolean
function BANK.OpenDepositBox()
    print("[BANK] Opening Deposit box.")
    if Interact:Object("Deposit box", "Deposit", 50) then
        return true
    end

    print("[BANK] Could not interact with any Deposit box.")
    return false
end

-- Empty your backpack into a deposit box
---@return boolean
function BANK.DepositInventoryDepositBox()
    print("[BANK] Depositing inventory in deposit box.")
    return API.DoAction_Interface(0x24,0xffffffff,1,11,5,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty the items you are wearing into a deposit box
---@return boolean
function BANK.DepositEquipmentDepositBox()
    print("[BANK] Depositing equipment in deposit box.")
    return API.DoAction_Interface(0x24,0xffffffff,1,11,11,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty your beast of burden's inventory into a deposit box
---@return boolean
function BANK.DepositSummonDepositBox()
    print("[BANK] Depositing beast of burden's inventory into a deposit box.")
    return API.DoAction_Interface(0x24,0xffffffff,1,11,11,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty your money pouch into a deposit box
---@return boolean
function BANK.DepositMoneyPouchDepositBox()
    print("[BANK] Depositing all your money into a deposit box.")
    return API.DoAction_Interface(0x24,0xffffffff,1,11,14,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Attempts to deposit-all in a deposit box. Requires cache enabled https://imgur.com/5I9a46V
---@return boolean
function BANK.DepositAllDepositBox()
    print("[BANK] Depositing-All in a deposit box.")
    if Interact:Object("Deposit box", "Deposit-All", 50) then
        return true
    end

    print("[BANK] Could not interact with any Deposit box.")
    return false
end

-- Attempts to load the last bank preset using the listed options. Requires cache enabled https://imgur.com/5I9a46V
---@return boolean
function BANK.LoadLastPreset()
    print("[BANK] Loading last preset.")
    if Interact:NPC("Banker", "Load Last Preset from", 50) then
        print("[BANK] Banker succeded.")
        return true
    end

    if Interact:Object("Bank chest", "Load Last Preset from", 50) then
        print("[BANK] Bank chest succeded.")
        return true
    end

    if Interact:Object("Bank booth", "Load Last Preset from", 50) then
        print("[BANK] Bank booth succeded.")
        return true
    end

    if Interact:Object("Counter", "Load Last Preset from", 50) then
        print("[BANK] Counter succeded.")
        return true
    end

    print("[BANK] Could not interact with any of the following: Banker, Bank chest, Bank booth and Counter.")
    return false
end

-- Check if Bank interface is open.
---@return boolean
function BANK.IsOpen()
    if API.VB_FindPSettinOrder(2874, 0).state == 24 then
        print("[BANK] Bank interface open.")
        return true
    else
        print("[BANK] Bank interface is not open.")
        return false
    end
end

-- Check if Deposit box interface is open.
---@return boolean
function BANK.IsDepositBoxOpen()
    if API.VB_FindPSettinOrder(2874, 0).state == 69 then
        print("[BANK] Deposit box interface open.")
        return true
    else
        print("[BANK] Deposit box interface is not open.")
        return false
    end
end

-- Check if Collect interface is open.
---@return boolean
function BANK.IsCollectInterfaceOpen()
    if API.VB_FindPSettinOrder(2874, 0).state == 18 then
        print("[BANK] Collect interface open.")
        return true
    else
        print("[BANK] Collect interface is not open.")
        return false
    end 
end

-- Check if there are items to collect.
---@return boolean
function BANK.HasItemsToCollect()
    local FoundItem = false

    for i = 1, 16 do
        local slot = API.ScanForInterfaceTest2Get(false, CollectionBoxSlots[i])[1]
        if slot.itemid1 and slot.itemid1 ~= -1 then
            FoundItem = true
        end
    end

    if FoundItem then
        print("[BANK] There is at least one item to collect.")
    else
        print("[BANK] There are no items to collect.")
    end

    return FoundItem
end

-- Check if there is a specific item to collect.
---@param itemID number
---@return boolean
function BANK.CollectContains(itemID)
    local FoundItem = false

    for i = 1, 16 do
        local slot = API.ScanForInterfaceTest2Get(false, CollectionBoxSlots[i])[1]
        if slot.itemid1 and slot.itemid1 == itemID then
            FoundItem = true
        end
    end

    if FoundItem then
        print("[BANK] Item ID: "..itemID.." found.")
    else
        print("[BANK] Item ID: "..itemID.." not found.")
    end

    return FoundItem
end

-- Collects all to inventory from Collect interface
---@return boolean
function BANK.CollectAllToInventory()
    if BANK.HasItemsToCollect() then
        print("[BANK] Collecting all to inventory.")
        API.DoAction_Interface(0x24,0xffffffff,1,109,55,-1,API.OFF_ACT_GeneralInterface_route) 
        return true
    else
        print("[BANK] There are no items to collect.")
        return false        
    end    
end

-- Collects all to bank from Collect interface
---@return boolean
function BANK.CollectAllToBank()
    if BANK.HasItemsToCollect() then
        print("[BANK] Collecting all to bank.")
        API.DoAction_Interface(0x24,0xffffffff,1,109,47,-1,API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("[BANK] There are no items to collect.")
        return false        
    end
end

-- Checks if inventory has item
---@param ItemID number
---@return boolean
function BANK.InventoryContains(ItemID)
    if type(ItemID) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(ItemID).." ("..type(ItemID)..")")
        return false
    end
    local Items = API.Container_Get_all(93)
    local FoundItem = false

    if not Items or #Items == 0 then
        print("[BANK] Could not read inventory items or there are none.")
        return false
    end

    for _, item in ipairs(Items) do
        if item.item_id and item.item_id == ItemID and item.item_stack > 0 then
            FoundItem = true
        end
    end

    if FoundItem then
        print("[BANK] Item ID: "..ItemID.." found in inventory.")
    else
        print("[BANK] Item ID: "..ItemID.." not found in inventory.")
    end

    return FoundItem
end

-- Checks if item is equipped
---@param ItemID number
---@return boolean
function BANK.IsEquipped(ItemID)
    if type(ItemID) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(ItemID).." ("..type(ItemID)..")")
        return false
    end
    local Items = API.Container_Get_all(94)
    local FoundItem = false

    if not Items or #Items == 0 then
        print("[BANK] Could not read inventory items or there are none.")
        return false
    end

    for _, item in ipairs(Items) do
        if item.item_id and item.item_id == ItemID and item.item_stack > 0 then
            FoundItem = true
        end
    end

    if FoundItem then
        print("[BANK] Item ID: "..ItemID.." found in equipment.")
    else
        print("[BANK] Item ID: "..ItemID.." not found in equipment.")
    end

    return FoundItem
end

-- Checks if bank has item
---@param ItemID number
---@return boolean
function BANK.Contains(ItemID)
    if type(ItemID) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(ItemID).." ("..type(ItemID)..")")
        return false
    end
    local Items = API.Container_Get_all(95)
    local FoundItem = false

    if not Items or #Items == 0 then
        print("[BANK] Could not read bank items or there are none.")
        return false
    end

    for _, item in ipairs(Items) do
        if item.item_id and item.item_id == ItemID and item.item_stack > 0 then
            FoundItem = true
        end
    end

    if FoundItem then
        print("[BANK] Item ID: "..ItemID.." found in bank.")
    else
        print("[BANK] Item ID: "..ItemID.." not found in bank.")
    end

    return FoundItem
end

-- Get the player tab opened in the bank(Inventory, Equipment or Beast of burden)
---@return number|boolean
function BANK.GetOpenedTab()
    local VB = API.VB_FindPSettinOrder(6680).state
    if VB == 5120 then
        print("[BANK] Inventory tab is opened.")
        return 1
    elseif VB == 5121 then
        print("[BANK] Beast of burden tab is opened.")
        return 2
    elseif VB == 5122 then
        print("[BANK] Equipment tab is opened.")
        return 3
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.GetOpenedTab()")
        local var = API.VB_FindPSettinOrder(6680)
        print("--------------------------")
        print("state: " .. var.state)
        print("addr: " .. var.addr)
        print("indexaddr_orig: " .. var.indexaddr_orig)
        print("id: " .. var.id)
        print("--------------------------")
        return false
    end
end

--Open the specified player tab inside the bank(1 = Inventory, 2 = Beast of burden and 3 = Equipment)
---@param tabID number
---@return boolean
function BANK.OpenTab(tabID)
    print("[BANK] Opening tab: "..tostring(tabID)..".")
    if type(tabID) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(tabID).." ("..type(tabID)..")")
        return false
    end
    
    if tabID < 1 or tabID > 3 then
        print("[BANK] Error: Can only accept numbers 1 to 3, you passed: "..tostring(tabID))
        return false
    end

    if tabID == 1 then
        if BANK.GetOpenedTab() == 1 then
            print("[BANK] Inventory tab already open. No action needed.")
            return true
        else
            print("[BANK] Opening inventory tab.")
            API.DoAction_Interface(0x24,0xffffffff,1,517,56,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    elseif tabID == 2 then
        if BANK.GetOpenedTab() == 2 then
            print("[BANK] Beast of burden tab already open. No action needed.")
            return true
        else
            print("[BANK] Opening Beast of burden tab.")
            API.DoAction_Interface(0x24,0xffffffff,1,517,64,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    elseif tabID == 3 then
        if BANK.GetOpenedTab() == 3 then
            print("[BANK] Equipment tab open. No action needed.")
            return true
        else
            print("[BANK] Opening Equipment tab.")
            API.DoAction_Interface(0x24,0xffffffff,1,517,60,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.OpenTab()")
        print("--------------------------")
        print("Value passed: "..tostring(tabID))
        print("Return GetOpenedTab(): "..tostring(BANK.GetOpenedTab()))
        print("--------------------------")
        return false
    end
end

-- Get transfer or preset tab. 0 = transfer and 1 = preset
---@return number|false
function BANK.GetTransferTab()
    local VB = API.VB_FindPSettinOrder(6680).state >> 12
    if VB == 0 then
        print("[BANK] Bank is showing transfer.")
        return 0
    elseif VB == 1 then
        print("[BANK] Bank is showing preset.")
        return 1
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.GetTransferTab()")
        print("--------------------------")
        print("VB Value: "..tostring(VB))
        print("--------------------------")
        return false
    end
end

-- Set transfer or preset tab. 0 = transfer and 1 = preset
---@param number number
---@return boolean
function BANK.SetTransferTab(number)
    if tonumber(number) == 0 then
        if BANK.GetTransferTab() ~= 0 then
            print("[BANK] Opening transfer tab.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,151,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            return true
        end
    elseif tonumber(number) == 1 then
        if BANK.GetTransferTab() ~= 1 then
            print("[BANK] Opening preset tab.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,152,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            return true
        end
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.SetTransferTab()")
        print("--------------------------")
        print("VB Value: "..tostring(number))
        print("--------------------------")
        return false
    end
end

-- Retrieves the currently selected quantity option from the interface.
---@return number|string|boolean
function BANK.GetQuantitySelected()
    local VB = API.VB_FindPSettinOrder(8958).state

    if VB == 50 then
        print("[BANK] Current quantity selected: 1")
        return 1
    elseif VB == 51 then
        print("[BANK] Current quantity selected: 5")
        return 5
    elseif VB == 52 then
        print("[BANK] Current quantity selected: 10")
        return 10
    elseif VB == 53 then
        local XValue = API.VB_FindPSettinOrder(111).state
        print("[BANK] Current quantity selected: X (Custom Value: " .. tostring(XValue) .. ")")
        return "X"
    elseif VB == 55 then
        print("[BANK] Current quantity selected: All")
        return "All"
    elseif VB == 0 then
        print("[BANK] Could not read selected quantity.")
        return false
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.GetQuantitySelected()")
        local var = API.VB_FindPSettinOrder(8958)
        print("--------------------------")
        print("state: " .. var.state)
        print("addr: " .. var.addr)
        print("indexaddr_orig: " .. var.indexaddr_orig)
        print("id: " .. var.id)
        print("--------------------------")
        return false
    end
    
    return false
end

-- Set the quantity to transfer. Valid inputs are: 1, 5, 10, "All", or "X".
---@param Qtitty number|string
---@return boolean
function BANK.SetQuantity(Qtitty)
    if type(Qtitty) ~= "number" and type(Qtitty) ~= "string" then
        print("[BANK] Error: Invalid input type. Expected number or string, got: "..type(Qtitty))
        return false
    end

    if type(Qtitty) == "number" then
        if Qtitty ~= 1 and Qtitty ~= 5 and Qtitty ~= 10 then
            print("[BANK] Error: Number quantity must be 1, 5, or 10. Got: "..tostring(Qtitty))
            return false
        end
    end
    
    if type(Qtitty) == "string" then
        local lowerQtitty = Qtitty:lower()
        if lowerQtitty ~= "all" and lowerQtitty ~= "x" then
            print("[BANK] Error: String quantity must be 'All' or 'X'. Got: "..Qtitty)
            return false
        end
    end

    BANK.SetTransferTab(0)

    if Qtitty == 1 then
        if BANK.GetQuantitySelected() ~= 1 then
            print("[BANK] Transfer quantity set to 1.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,93,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Transfer quantity already set to 1. No action needed.")
            return true
        end
    elseif Qtitty == 5 then
        if BANK.GetQuantitySelected() ~= 5 then
            print("[BANK] Transfer quantity set to 5.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,96,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Transfer quantity already set to 5. No action needed.")
            return true
        end
    elseif Qtitty == 10 then        
        if BANK.GetQuantitySelected() ~= 10 then
            print("[BANK] Transfer quantity set to 10.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,99,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Transfer quantity already set to 10. No action needed.")
            return true
        end
    elseif Qtitty == "All" then
        if BANK.GetQuantitySelected() ~= "All" then
            print("[BANK] Transfer quantity set to All.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,103,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Transfer quantity already set to All. No action needed.")
            return true
        end
    elseif Qtitty == "X" then
        if BANK.GetQuantitySelected() ~= "X" then
            print("[BANK] Transfer quantity set to X.")
            API.DoAction_Interface(0x2e,0xffffffff,1,517,106,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Transfer quantity already set to X. No action needed.")
            return true
        end
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.SetQuantity()")
        print("--------------------------")
        print("Value passed: "..tostring(Qtitty))
        print("Type passed: "..type(Qtitty))
        print("Return GetQuantitySelected(): "..tostring(BANK.GetQuantitySelected()))
        print("Return GetXQuantity(): "..tostring(BANK.GetXQuantity()))
        print("--------------------------")
        return false
    end    
end

-- Retrieves the currently X quantity value from the interface.
---@return number
function BANK.GetXQuantity()
    local XValue = API.VB_FindPSettinOrder(111).state
    print("[BANK] X value: "..tostring(XValue))
    return XValue
end

-- Set the X quantity to transfer. 
---@param Qtitty number
---@return boolean
function BANK.SetXQuantity(Qtitty)
    print("[BANK] Setting X quantitty to: "..tostring(Qtitty))
    if type(Qtitty) ~= "number" then
        print("[BANK] Error: Expect number, received: "..tostring(type(Qtitty)))
        return false
    end

    if Qtitty <= 0 then
        print("[BANK] Error: Quantity must be positive, received: "..tostring(Qtitty))
        return false
    end

    if BANK.GetXQuantity() == Qtitty then
        print("[BANK] X quantity already set to "..tostring(Qtitty)..".")
        return true
    end
    
    BANK.SetTransferTab(0)

    API.DoAction_Interface(0xffffffff,0xffffffff,1,517,114,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1000, 1000, 1000)

    local digits = tostring(Qtitty)
    for i = 1, #digits do
        local char = digits:sub(i, i)
        API.KeyboardPress2(string.byte(char), 40, 60)
        API.RandomSleep2(200,200,200)
    end
    
    API.KeyboardPress2(0x0D, 50, 80)
    API.RandomSleep2(500, 600, 700)
    
    return true
end

-- Checks if bank is set to note mode
---@return boolean
function BANK.IsNoteModeEnabled()
    local VB = API.VB_FindPSettinOrder(160).state

    if VB == 0 then
        print("[BANK] Withdraw as note is disabled.")
        return false
    elseif VB == 1 then
        print("[BANK] Withdraw as note is enabled.")
        return true
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: IsNoteModeEnabled()")
        local var = API.VB_FindPSettinOrder(160)
        print("--------------------------")
        print("state: " .. var.state)
        print("addr: " .. var.addr)
        print("indexaddr_orig: " .. var.indexaddr_orig)
        print("id: " .. var.id)
        print("--------------------------")
        return false
    end
end

-- Set withdraw mode. True = note and false = item
---@param boolean boolean
---@return boolean
function BANK.SetNoteMode(boolean)
    if type(boolean) ~= "boolean" then
        print("[BANK] Error: Expected a boolean, got "..tostring(boolean).." ("..type(boolean)..")")
        return false
    end

    if boolean == true then
        if BANK.IsNoteModeEnabled() then
            print("[BANK] Note mode already enabled. No action needed.")
            return true
        else
            print("[BANK] Enabling note mode.")
            API.DoAction_Interface(0xffffffff,0xffffffff,1,517,127,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    elseif boolean == false then
        if not BANK.IsNoteModeEnabled() then
            print("[BANK] Note mode already disabled. No action needed.")
            return true
        else
            print("[BANK] Disabling note mode.")
            API.DoAction_Interface(0xffffffff,0xffffffff,1,517,127,-1,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.SetNoteMode()")
        print("--------------------------")
        print("Value passed: "..tostring(boolean))
        print("Return IsNoteModeEnabled(): "..tostring(BANK.IsNoteModeEnabled()))
        print("--------------------------")
        return false
    end
end

-- Get preset page. Page 1 = (1 -> 9), page 2 = (10 -> 18)
---@return number|false
function BANK.GetPresetPage()
    local VB = API.VB_FindPSettinOrder(9932).state >> 15
    if VB == 0 then
        print("[BANK] Bank is showing page 1, presets 1 to 9.")
        return 1
    elseif VB == 1 then
        print("[BANK] Bank is showing page 2, presets 10 to 18.")
        return 2
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.GetPresetPage()")
        print("--------------------------")
        print("VB Value: "..tostring(VB))
        print("--------------------------")
        return false
    end
end

-- Sets the bank preset page to the specified number (1 or 2).
---@param number
---@return boolean
function BANK.SetPresetPage(number)
    if type(number) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(number).." ("..type(number)..")")
        return false
    end

    BANK.SetTransferTab(1)

    if number == 1 then
        if BANK.GetPresetPage() == 1 then
            print("[BANK] Preset page already 1. No action needed.")
            return true
        else
            print("[BANK] Changing preset page to 1.")
            API.DoAction_Interface(0x24,0xffffffff,1,517,119,100,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    elseif number == 2 then
        if BANK.GetPresetPage() == 2 then
            print("[BANK] Preset page already 2. No action needed.")
            return true
        else
            print("[BANK] Changing preset page to 2.")
            API.DoAction_Interface(0x24,0xffffffff,1,517,119,100,API.OFF_ACT_GeneralInterface_route)
            return true
        end
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.SetPresetPage()")
        print("--------------------------")
        print("Value passed: "..tostring(number))
        print("Return GetPresetPage(): "..tostring(BANK.GetPresetPage()))
        print("--------------------------")
        return false
    end
end

-- Saves the current bank preset to the specified preset slot (1-18).
---@param number
---@return boolean
function BANK.SavePreset(number)
    if type(number) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(number).." ("..type(number)..")")
        return false
    end
    
    if number < 1 or number > 18 then
        print("[BANK] Error: Can only save to presets 1 to 18, you passed: "..tostring(number))
        return false
    end

    BANK.SetTransferTab(1)

    local slot = number
    if slot < 10 then
        BANK.SetPresetPage(1)
        API.RandomSleep2(200, 200, 200)
        print("[BANK] Saving preset number: "..tostring(number))
        API.DoAction_Interface(0xffffffff,0xffffffff,2,517,119,slot,API.OFF_ACT_GeneralInterface_route)
        return true
    else
        slot = slot - 9
        BANK.SetPresetPage(2)
        API.Sleep_tick(1)
        API.RandomSleep2(200, 200, 200)
        print("[BANK] Saving preset number: "..tostring(number))
        API.DoAction_Interface(0xffffffff,0xffffffff,2,517,119,slot,API.OFF_ACT_GeneralInterface_route)
        return true
    end

    return false
end

-- Saves the current beast of burden's preset
---@return boolean
function BANK.SaveSummonPreset()
    print("[BANK] Saving beast of burden preset")
    BANK.SetTransferTab(1)
    return API.DoAction_Interface(0xffffffff,0xffffffff,2,517,119,10,API.OFF_ACT_GeneralInterface_route)
end

-- Loads the specified preset (1-18).
---@param number
---@return boolean
function BANK.LoadPreset(number)
    if type(number) ~= "number" then
        print("[BANK] Error: Expected a number, got "..tostring(number).." ("..type(number)..")")
        return false
    end
    
    if number < 1 or number > 18 then
        print("[BANK] Error: Can only load to presets 1 to 18, you passed: "..tostring(number))
        return false
    end

    local slot = number
    if slot < 10 then
        BANK.SetPresetPage(1)
        API.RandomSleep2(200, 200, 200)
        print("[BANK] Loading preset number: "..tostring(number))
        API.DoAction_Interface(0x24,0xffffffff,1,517,119,slot,API.OFF_ACT_GeneralInterface_route)
        return true
    else
        slot = slot - 9
        BANK.SetPresetPage(2)
        API.Sleep_tick(1)
        API.RandomSleep2(200, 200, 200)
        print("[BANK] Loading preset number: "..tostring(number))
        API.DoAction_Interface(0x24,0xffffffff,1,517,119,slot,API.OFF_ACT_GeneralInterface_route)
        return true
    end

    return false
end

-- Loads the beast of burden's preset
---@return boolean
function BANK.LoadSummonPreset()
    print("[BANK] Loading beast of burden preset")
    BANK.SetTransferTab(1)
    return API.DoAction_Interface(0x24,0xffffffff,1,517,119,10,API.OFF_ACT_GeneralInterface_route)
end

-- Empty your backpack into your bank
---@return boolean
function BANK.DepositInventory()
    print("[BANK] Depositing inventory.")
    return API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty the items you are wearing into the bank
---@return boolean
function BANK.DepositEquipment()
    print("[BANK] Depositing equipment.")
    return API.DoAction_Interface(0xffffffff,0xffffffff,1,517,42,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty your beast of burden's inventory into your bank
---@return boolean
function BANK.DepositSummon()
    print("[BANK] Depositing beast of burden's inventory.")
    return API.DoAction_Interface(0xffffffff,0xffffffff,1,517,45,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Empty your money pouch into MY bank
---@return boolean
function BANK.DepositMoneyPouch()
    print("[BANK] Depositing all your money.")
    return API.DoAction_Interface(0xffffffff,0xffffffff,1,517,48,-1,API.OFF_ACT_GeneralInterface_route)
end

-- Withdraws item(s) from your bank. The amount is set with BANK.SetQuantity(Qtitty)
---@param ItemID number|table
---@return boolean
function BANK.Withdraw(ItemID)
    BANK.OpenTab(1)
    local Items = API.Container_Get_all(95)
    local success = true
    
    -- Handle single item case
    if type(ItemID) == "number" then
        local ItemIDHex = string.format("0x%X", ItemID)
        local slot = nil

        if not BANK.Contains(ItemID) then
            return false
        end

        for i, item in ipairs(Items) do
            if item.item_id and item.item_id == ItemID then
                slot = item.item_slot
                break
            end
        end

        if slot then
            print("[BANK] Withdrawing item: "..tostring(ItemID)..".")
            API.DoAction_Interface(0xffffffff, ItemIDHex, 1, 517, 202, slot, API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Could not find slot for item: "..tostring(ItemID)..".")
            return false
        end
        
    -- Handle table of items case
    elseif type(ItemID) == "table" then
        for _, id in ipairs(ItemID) do
            local currentSuccess = BANK.Withdraw(id)
            if not currentSuccess then
                success = false
            end
        end
        return success
    else
        print("[BANK] Invalid input type for WithdrawItem. Expected number or table, got "..type(ItemID))
        return false
    end
end

-- Deposits item(s) into your bank. The amount is set with BANK.SetQuantity(Qtitty)
---@param ItemID number|table
---@return boolean
function BANK.Deposit(ItemID)
    BANK.OpenTab(1)
    local Items = API.Container_Get_all(93)
    local success = true
    
    -- Handle single item case
    if type(ItemID) == "number" then
        local ItemIDHex = string.format("0x%X", ItemID)
        local slot = nil

        if not BANK.InventoryContains(ItemID) then
            return false
        end

        for i, item in ipairs(Items) do
            if item.item_id and item.item_id == ItemID then
                slot = item.item_slot
                break
            end
        end

        if slot then
            print("[BANK] Depositing item: "..tostring(ItemID)..".")
            API.DoAction_Interface(0xffffffff, ItemIDHex, 1, 517, 15, slot, API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Could not find slot for item: "..tostring(ItemID)..".")
            return false
        end
        
    -- Handle table of items case
    elseif type(ItemID) == "table" then
        for _, id in ipairs(ItemID) do
            local currentSuccess = BANK.Deposit(id)
            if not currentSuccess then
                success = false
            end
        end
        return success
    else
        print("[BANK] Invalid input type for DepositItem. Expected number or table, got "..type(ItemID))
        return false
    end
end

-- Equips an item from your bank.
---@param ItemID number
---@return boolean
function BANK.Equip(ItemID)
    local Items = API.Container_Get_all(95)
    BANK.OpenTab(3)

    local ItemIDHex = string.format("0x%X", ItemID)
    local slot = nil

    if not BANK.Contains(ItemID) then
        return false
    end

    for i, item in ipairs(Items) do
        if item.item_id and item.item_id == ItemID then
            slot = item.item_slot
            break
        end
    end

    if slot then
        print("[BANK] Equipping item: "..tostring(ItemID)..".")
        API.DoAction_Interface(0xffffffff, ItemIDHex, 1, 517, 202, slot, API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("[BANK] Could not find slot for item: "..tostring(ItemID)..".")
        return false
    end
end

-- Withdraws item(s) from your bank to your beast of burden. The amount is set with BANK.SetQuantity(Qtitty)
---@param ItemID number|table
---@return boolean
function BANK.WithdrawToBoB(ItemID)
    BANK.OpenTab(2)
    local Items = API.Container_Get_all(95)
    local success = true
    
    -- Handle single item case
    if type(ItemID) == "number" then
        local ItemIDHex = string.format("0x%X", ItemID)
        local slot = nil

        if not BANK.Contains(ItemID) then
            return false
        end

        for i, item in ipairs(Items) do
            if item.item_id and item.item_id == ItemID then
                slot = item.item_slot
                break
            end
        end

        if slot then
            print("[BANK] Withdrawing item: "..tostring(ItemID).." to beast of burden.")
            API.DoAction_Interface(0xffffffff, ItemIDHex, 1, 517, 202, slot, API.OFF_ACT_GeneralInterface_route)
            return true
        else
            print("[BANK] Could not find slot for item: "..tostring(ItemID)..".")
            return false
        end
        
    -- Handle table of items case
    elseif type(ItemID) == "table" then
        for _, id in ipairs(ItemID) do
            local currentSuccess = BANK.Withdraw(id)
            if not currentSuccess then
                success = false
            end
        end
        return success
    else
        print("[BANK] Invalid input type for WithdrawItem. Expected number or table, got "..type(ItemID))
        return false
    end
end

-- Check if preset settings interface is open.
---@return boolean
function BANK.PresetSettingsIsOpen()
    local VB = API.VB_FindPSettinOrder(6680).state >> 20

    if VB == 0 then
        print("[BANK] Preset settings interface is not open.")
        return false
        
    elseif VB == 1 then
        print("[BANK] Preset settings interface is open.")
        return true
    else
        print("[BANK] Something went horribly wrong here. Send me a screenshot of the console on Discord: not_spectre011.")
        print("Function: BANK.PresetSettingsIsOpen()")
        local var = API.VB_FindPSettinOrder(6680)
        print("--------------------------")
        print("state: " .. var.state)
        print("addr: " .. var.addr)
        print("indexaddr_orig: " .. var.indexaddr_orig)
        print("id: " .. var.id)
        print("--------------------------")
        return false
    end
end

-- Open preset settings interface.
---@return boolean
function BANK.PresetSettingsOpen()
    if not BANK.PresetSettingsIsOpen() then
        print("[BANK] Opening preset settings.")
        API.DoAction_Interface(0x24,0xffffffff,1,517,119,0,API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("[BANK] Preset settings interface is already open.")
        return true
    end
    return false
end

-- Returns to bank.
---@return boolean
function BANK.PresetSettingsReturnToBank()
    if BANK.PresetSettingsIsOpen() then
        print("[BANK] Return to bank.")
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,86,-1,API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("[BANK] Bank interface already open.")
        return true
    end
    return false
end

-- Returns selected preset from the preset settings interface.
---@return number|false
function BANK.PresetSettingsGetSelectedPreset()
    if not BANK.PresetSettingsIsOpen() then
        print("[BANK] Preset settings interface is not open. Open it first with BANK.PresetSettingsOpen()")
        return false
    end

    local VB = API.VB_FindPSettinOrder(9932).state
    print("[BANK] Selected preset: "..VB)
    return tonumber(VB)
end

-- Select a preset (1-19). 19 is beast of burden
---@param preset number
---@return boolean
function BANK.PresetSettingsSelectPreset(preset)
    if type(preset) ~= "number" then
        print("[BANK] Invalid preset type. Expected a number, got " .. type(preset))
        return false
    end

    local slot = tonumber(preset)
    if not slot or slot < 1 or slot > 19 then
        print("[BANK] Invalid preset number. Must be between 1 and 19, got " .. tostring(preset))
        return false
    end

    if BANK.PresetSettingsIsOpen() then
        print("[BANK] Selecting preset " .. slot .. ".")
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 268, slot, API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("[BANK] Preset settings interface is not open. Open it first with BANK.PresetSettingsOpen().")
        return false
    end
end

---Get the itemID of all inventory slots inside the preset settings interface.
---@return table|false
function BANK.PresetSettingsGetInventory()
    local inventory = {}

    for i = 1, 28 do
        local slot = API.ScanForInterfaceTest2Get(false, PresetSettingsInventory[i])[1]
        if slot and slot.itemid1 then
            table.insert(inventory, { index = i, itemid1 = slot.itemid1 })
        end
    end

    if #inventory == 0 then
        return false
    end

    return inventory
end

---Get the itemID of all equipment slots inside the preset settings interface.
---@return table|false
function BANK.PresetSettingsGetEquipment()
    local equipment = {}

    for i = 1, 13 do
        local slot = API.ScanForInterfaceTest2Get(false, PresetSettingsEquipment[i])[1]
        if slot and slot.itemid1 then
            table.insert(equipment, { index = i, itemid1 = slot.itemid1 })
        end
    end

    if #equipment == 0 then
        return false
    end

    return equipment
end

---Prints the data from BANK.PresetSettingsGetInventory() and BANK.PresetSettingsGetEquipment().
---@param inventory table
function BANK.PrintInventory(inventory)
    print("Contents:")
    for _, item in ipairs(inventory) do
        print(string.format("Slot %02d: Item ID = %d", item.index, item.itemid1))
    end
end

return BANK
