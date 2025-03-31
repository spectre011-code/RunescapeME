ScriptName = "Enchanted Key Lore Activity pt1"
Author = "Spectre011"
ScriptVersion = "2.0.0"
ReleaseDate = "27-01-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 27-01-2025
    - Initial release.
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
]]

local API = require("api")
local UTILS = require("utils")
local LODESTONES = require("lodestones")
local SpectreUtils = require("spectre")

--------------------START GUI STUFF--------------------
local SelectedOption = nil
local CurrentStatus = "Starting"
local Completed = 0
local SetOption = nil
local UIComponents = {}
local function GetComponentAmount()
    local amount = 0
    for i,v in pairs(UIComponents) do
        amount = amount + 1
    end
    return amount
end

local function GetComponentByName(componentName)
    for i,v in pairs(UIComponents) do
        if v[1] == componentName then
            return v;
        end
    end
end

local function AddBackground(name, widthMultiplier, heightMultiplier, colour)
    widthMultiplier = widthMultiplier or 1
    heightMultiplier = heightMultiplier or 1
    colour = colour or ImColor.new(15, 13, 18, 255)
    Background = API.CreateIG_answer();
    Background.box_name = "Background" .. GetComponentAmount();
    Background.box_start = FFPOINT.new(30, 0, 0)
    Background.box_size = FFPOINT.new(400 * widthMultiplier, 20 * heightMultiplier, 0)
    Background.colour = colour
    UIComponents[GetComponentAmount() + 1] = {name, Background, "Background"}
end

local function AddLabel(name, text, colour)
    colour = colour or ImColor.new(255, 255, 255)
    Label = API.CreateIG_answer()
    Label.box_name = "Label" .. GetComponentAmount()
    Label.colour = colour;
    Label.string_value = text
    UIComponents[GetComponentAmount() + 1] = {name, Label, "Label"}
end

local function GUIDraw()
    for i=1,GetComponentAmount() do
        local componentKind = UIComponents[i][3]
        local component = UIComponents[i][2]
        if componentKind == "Background" then
            component.box_size = FFPOINT.new(component.box_size.x, 25 * GetComponentAmount(), 0)
            API.DrawSquareFilled(component)
        elseif componentKind == "Label" then
            component.box_start = FFPOINT.new(40, 10 + ((i - 2) * 25), 0)
            API.DrawTextAt(component)
        elseif componentKind == "CheckBox" then
            component.box_start = FFPOINT.new(40, ((i - 2) * 25), 0)
            API.DrawCheckbox(component)
        elseif componentKind == "ComboBox" then
            component.box_start = FFPOINT.new(40, ((i - 2) * 25), 0)
            API.DrawComboBox(component, false)
        elseif componentKind == "ListBox" then
            component.box_start = FFPOINT.new(40, 10 + ((i - 2) * 25), 0)
            API.DrawListBox(component, false)
        end
    end
end

local function CreateGUI()
    AddBackground("Background", 1, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("Status", "Status: " .. CurrentStatus, ImColor.new(238, 230, 0))
    AddLabel("Completed", "Completed: " .. Completed .. "/11", ImColor.new(238, 230, 0))
end

local function UpdateStatus(newStatus)
    CurrentStatus = newStatus
    local statusLabel = GetComponentByName("Status")
    if statusLabel then
        statusLabel[2].string_value = "Status: " .. CurrentStatus
    end
end

local function UpdateCompleted()
    Completed = Completed + 1
    local statusLabel = GetComponentByName("Completed")
    if statusLabel then
        statusLabel[2].string_value = "Completed: " .. Completed .. "/11"
    end
end

CreateGUI()
GUIDraw()
--------------------END GUI STUFF--------------------

--------------------START END TABLE STUFF--------------------
local EndTable = {
    {"-"}
}
EndTable[1] = {"Thanks for using my script!"}
EndTable[2] = {" "}
EndTable[3] = {"Script Name: ".. ScriptName}
EndTable[4] = {"Author: ".. Author}
EndTable[5] = {"Version: ".. ScriptVersion}
EndTable[6] = {"Release Date: ".. ReleaseDate}
EndTable[7] = {"Discord: ".. DiscordHandle}
--------------------END END TABLE STUFF--------------------

local StepsCompleted = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false
}

local function CompletedCheck()
    for i = 1, #StepsCompleted do
        if StepsCompleted[i] == false then
            return false
        end
    end
    return true
end

local InventoryData = {}

local function StoreInventoryData()
    for slot = 0, 27 do
        local slotData = Inventory:GetSlotData(slot)
        InventoryData[slot] = {id = slotData.id, amount = slotData.amount}
    end

end

local function InventoryDataChanged(storedData)
    local changesDetected = false

    for slot = 0, 27 do
        local currentData = Inventory:GetSlotData(slot)
        local storedSlotData = storedData[slot]
        
        if currentData.id ~= storedSlotData.id or currentData.amount ~= storedSlotData.amount then
            return true
        end
    end
    return false
end

local function Dig()
    return API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route)
end

local function MoveTo(X, Y, Z)
    while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(X, Y, Z) do
        API.DoAction_WalkerW(WPOINT.new(X, Y, Z))
        UTILS.randomSleep(3000)
    end
end

local function IsTeleportInterfaceOpen()
    local interfaceCoords = {
        InterfaceComp5.new(720, 2, -1, -1),
        InterfaceComp5.new(720, 17, -1, 2)
    }
    local result = API.ScanForInterfaceTest2Get(true, interfaceCoords)
    if #result > 0 then
        return true
    else
        return false
    end
end

local Steps = {
    [1] = function()
        print("Step 1")
        if not API.Read_LoopyLoop() then
            return
        end
        LODESTONES.FREMENNIK_PROVINCE.Teleport()
        MoveTo(2711, 3612, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[1] = true
            UpdateCompleted()
        end
        return
    end,
    [2] = function()
        if not API.Read_LoopyLoop() then
            return
        end
        print("Step 2")
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2618, 3242, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[2] = true
            UpdateCompleted()
        end
        return
    end,
    [3] = function()
        print("Step 3")
        if not API.Read_LoopyLoop() then
            return
        end
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3018, 3164, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[3] = true
            UpdateCompleted()
        end
        return
    end,
    [4] = function()
        print("Step 4")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2446, 3346, 0, 5) do
            local rubCount = 0
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() and rubCount < 15 do
                API.DoAction_Interface(0xffffffff, 0x99ca, 3, 1430, 194, -1, API.OFF_ACT_GeneralInterface_route) -- Rub Traveller's Necklace
                SpectreUtils.Sleep(0.3)
                rubCount = rubCount + 1
            end
            API.TypeOnkeyboard2(2)
            SpectreUtils.Sleep(4)
        end
        MoveTo(2416, 3380, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[4] = true
            UpdateCompleted()
        end
        return
    end,
    [5] = function()
        print("Step 5")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2446, 3346, 0, 5) do
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() do
                API.DoAction_Interface(0xffffffff, 0x99ca, 3, 1430, 194, -1, API.OFF_ACT_GeneralInterface_route) -- Rub Traveller's Necklace
                SpectreUtils.Sleep(0.3)
            end
            API.TypeOnkeyboard2(2)
            SpectreUtils.Sleep(4)
        end
        MoveTo(2461, 3382, 0)
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{68983},50)
        UTILS.randomSleep(100)
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{68983},50)
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2461, 3385, 0) do
            UTILS.randomSleep(300)
        end
        MoveTo(2448, 3443, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[5] = true
            UpdateCompleted()
        end
        return
    end,
    [6] = function()
        print("Step 6")
        if not API.Read_LoopyLoop() then
            return
        end
        LODESTONES.FALADOR.Teleport()
        MoveTo(3033, 3435, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[6] = true
            UpdateCompleted()
        end
        return
    end,
    [7] = function()
        print("Step 7")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2967, 3285, 0, 5) do
            API.DoAction_Inventory1(20709,0,3,API.OFF_ACT_GeneralInterface_route) --Clan vexillum teleport
            SpectreUtils.Sleep(4)
        end
        MoveTo(2970, 3297, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[7] = true
            UpdateCompleted()
        end
        return
    end,
    [8] = function()
        print("Step 8")
        if not API.Read_LoopyLoop() then
            return
        end
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3165, 3158, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[8] = true
            UpdateCompleted()
        end
        return
    end,
    [9] = function()
        print("Step 9")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(3313, 3236, 0, 5) do
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() do
                API.DoAction_Interface(0xffffffff,0x9f8,7,1430,207,-1,API.OFF_ACT_GeneralInterface_route2) --Rub ring of duelling
                SpectreUtils.Sleep(0.3)
            end
            API.TypeOnkeyboard2(1)
            SpectreUtils.Sleep(4)
        end
        MoveTo(3304, 3245, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[9] = true
            UpdateCompleted()
        end
        return
    end,
    [10] = function()
        print("Step 10")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(3336, 3378, 0, 5) do
            API.DoAction_Interface(0x2e,0xc115,1,1430,220,-1,API.OFF_ACT_GeneralInterface_route) --Archaeology Journal Teleport
            SpectreUtils.Sleep(3)     
        end
        MoveTo(3306, 3346, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[10] = true
            UpdateCompleted()
        end
        return
    end,
    [11] = function()
        print("Step 11")
        if not API.Read_LoopyLoop() then
            return
        end
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(3163, 3466, 0, 5) do
            API.DoAction_Interface(0xffffffff,0x9b80,2,1430,181,-1,API.OFF_ACT_GeneralInterface_route) --Ring of fortune teleport
            SpectreUtils.Sleep(5)     
        end
        MoveTo(3157, 3490, 0)
        StoreInventoryData()
        UTILS.randomSleep(300)
        Dig()
        UTILS.randomSleep(1000)
        if InventoryDataChanged(InventoryData) then
            StepsCompleted[11] = true
            UpdateCompleted()
        end
        return
    end
}

Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()
    API.DoAction_Inventory1(6754,0,1,API.OFF_ACT_GeneralInterface_route)
    UTILS.randomSleep(1000)

    if CompletedCheck() then
        print("No steps left. Exiting.")
        API.Write_LoopyLoop(false)
        break
    end

    if not Inventory:Contains(6754) then
        print("Key not found. Exiting.")
        API.Write_LoopyLoop(false)
        break
    end

    if StepsCompleted[1] == false then UpdateStatus("Going for location 1") Steps[1]() end
    if StepsCompleted[2] == false then UpdateStatus("Going for location 2") Steps[2]() end        
    if StepsCompleted[3] == false then UpdateStatus("Going for location 3") Steps[3]() end
    if StepsCompleted[4] == false then UpdateStatus("Going for location 4") Steps[4]() end
    if StepsCompleted[5] == false then UpdateStatus("Going for location 5") Steps[5]() end
    if StepsCompleted[6] == false then UpdateStatus("Going for location 6") Steps[6]() end
    if StepsCompleted[7] == false then UpdateStatus("Going for location 7") Steps[7]() end
    if StepsCompleted[8] == false then UpdateStatus("Going for location 8") Steps[8]() end
    if StepsCompleted[9] == false then UpdateStatus("Going for location 9") Steps[9]() end
    if StepsCompleted[10] == false then UpdateStatus("Going for location 10") Steps[10]() end
    if StepsCompleted[11] == false then UpdateStatus("Going for location 11") Steps[11]() end      

    print("Memory usage: ", collectgarbage("count"), "KB")
    collectgarbage("collect")
end

API.Write_LoopyLoop(false)
API.DrawTable(EndTable)
print("----------//----------")
print("Script Name: " .. ScriptName)
print("Author: " .. Author)
print("Version: " .. ScriptVersion)
print("Release Date: " .. ReleaseDate)
print("Discord: " .. DiscordHandle)
print("----------//----------")
