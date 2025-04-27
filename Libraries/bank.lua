ScriptName = "Bank toolbox"
Author = "Spectre011"
ScriptVersion = "1.0.0"
ReleaseDate = "27-04-2025"
DiscordHandle = "not_spectre011"

local API = require("api")

local BANK = {}

--- Attempts to load the last bank preset using the listed options. Requires cache enabled https://imgur.com/5I9a46V
--- @return boolean 'true' if the Interact was successful, 'false' otherwise.
function BANK.LoadLastPreset()
    if Interact:NPC("Banker", "Load Last Preset from", 10) then
        print("[BANK] Banker succeded.")
        return true
    end

    if Interact:Object("Bank chest", "Load Last Preset from", 10) then
        print("[BANK] Bank chest succeded.")
        return true
    end

    if Interact:Object("Bank booth", "Load Last Preset from", 10) then
        print("[BANK] Bank booth succeded.")
        return true
    end

    if Interact:Object("Counter", "Load Last Preset from", 10) then
        print("[BANK] Counter succeded.")
        return true
    end

    return false
end

--- Check if Bank interface is open.
--- @return boolean
function BANK.IsBankInterfaceOpen()
    if API.VB_FindPSettinOrder(2874, 0).state == 24 then
        print("[BANK] Bank interface open.")
        return true
    else
        print("[BANK] Bank interface is not open.")
        return false
    end
end

--- Check if Collect interface is open.
--- @return boolean
function BANK.IsCollectInterfaceOpen()
    if API.VB_FindPSettinOrder(2874, 0).state == 18 then
        print("[BANK] Collect interface open.")
        return true
    else
        print("[BANK] Collect interface is not open.")
        return false
    end 
end

--- Collects all to inventory from Collect interface
--- @return boolean
function BANK.CollectAllToInventory()
    return API.DoAction_Interface(0x24,0xffffffff,1,109,55,-1,API.OFF_ACT_GeneralInterface_route) 
end

--- Collects all to bank from Collect interface
--- @return boolean
function BANK.CollectAllToBank()
    return API.DoAction_Interface(0x24,0xffffffff,1,109,47,-1,API.OFF_ACT_GeneralInterface_route)
end

--[[ TODO
InventoryHasItem(ItemID)

BankHasItem(ItemID)

DepositItem(ItemID, QtittyIndex)

WithdrawItem(ItemID, QtittyIndex)

GetQuantitySelected()

SetQuantitty(QtittyIndex) --1, 5, 10, X

GetIsNoteEnabled()

SetNote(boolean)

SavePreset(int)

RetrievePreset(int)

]]


return BANK