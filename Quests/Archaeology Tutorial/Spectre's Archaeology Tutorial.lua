ScriptName = "Archaeology Tutorial"
Author = "Spectre011"
ScriptVersion = "2.0.1"
ReleaseDate = "22-10-2024"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 22-10-2024
    - Initial release.
v1.1 - 23-01-2025
    - Script was rewriten to use VBs instead of one code block.
v1.2 - 14-13-2025
    - Fixed step 85/100 that broke with the relic preset update.
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
v2.0.0.1 29-04-2025
    - Fixed step 96 where the soil box was not being claimed from Ezreal shop
]]

local API = require("api")
local UTILS = require("utils")

--------------------START GUI STUFF--------------------
local CurrentStatus = "Starting"
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
    AddBackground("Background", 0.85, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("Status", "Status: " .. CurrentStatus, ImColor.new(238, 230, 0))
end

local function UpdateStatus(newStatus)
    print("NewStatus: ", newStatus)
    CurrentStatus = newStatus
    local statusLabel = GetComponentByName("Status")
    if statusLabel then
        statusLabel[2].string_value = "Status: " .. CurrentStatus
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

local function Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
end

local function WaitForObjectToAppear(ObjID, ObjType)
    while API.Read_LoopyLoop() do
        local objects = API.GetAllObjArray1({ObjID}, 75, {ObjType})
        if objects and #objects > 0 then
            for _, object in ipairs(objects) do
                local id = object.Id or 0
                local objType = object.Type or 0           
                if id == ObjID and objType == ObjType then
                    return
                end
            end
        else
            print("No objects found on this attempt.")
        end
        Sleep(1)
    end
end

local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end

local function PressSpace()
    return API.KeyboardPress2(0x20, 40, 60), API.RandomSleep2(400,300,600)
end

local function HandleDialog()
    while API.Read_LoopyLoop() and not DialogBoxOpen() do
        Sleep(0.1)
    end
    while API.Read_LoopyLoop() and DialogBoxOpen() do
        PressSpace()
    end
end

local function IsPlayerInArea(x, y, z, radius)
    local coord = API.PlayerCoord()
    local dx = math.abs(coord.x - x)
    local dy = math.abs(coord.y - y)
    if dx <= radius and dy <= radius and coord.z == z then
        return true
    else
        return false
    end
end

IDS = {
    Guildmaster = 26927,
    BronzeMattock = 49534,
    UncoveredSoil = 116392,
    CenturionRemains = 116393,
    CenturionSword = 49741,
    Mesh = 115419,
    Soil = 49516,
    MaterialStorage = 116438,
    Workbech = 115421,
    Velucia = 26923,
    Monolith = 115415,
    Guildmaster2 = 26929,
    Ezreal = 26937
}
Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    questProgress = API.VB_FindPSettinOrder(9235, 0).state >> 0 & 0x7f
    print("Quest Progress: ", questProgress)
    
    if questProgress >= 0 and questProgress < 10 then
        print("Starting quest: 0-10 progress")
        UpdateStatus("0/100")
        API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
        WaitForObjectToAppear(IDS.Guildmaster, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster},50)
        HandleDialog()
    elseif questProgress == 10 then
        print("Progress: 10/100 - Handling inventory action")
        UpdateStatus("10/100")
        API.DoAction_Inventory2({IDS.BronzeMattock},0,1,API.OFF_ACT_GeneralInterface_route)
        Sleep(0.3)
    elseif questProgress == 15 then
        print("Progress: 15/100 - Handling dialog")
        UpdateStatus("15/100")
        HandleDialog()
    elseif questProgress == 20 then
        print("Progress: 20/100 - Interacting with uncovered soil")
        UpdateStatus("20/100")
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{IDS.UncoveredSoil},50)
        WaitForObjectToAppear(IDS.CenturionRemains, 0)
    elseif questProgress == 25 then
        print("Progress: 25/100 - Interacting with Centurion Remains")
        UpdateStatus("25/100")
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{IDS.CenturionRemains},50)
        HandleDialog()
        Sleep(3)
        HandleDialog()
        Sleep(3)
        HandleDialog()
        while API.Read_LoopyLoop() and not Inventory:Contains(IDS.CenturionSword) do
            Sleep(1)
        end
    elseif questProgress == 30 then
        print("Progress: 30/100 - Handling Centurion Sword and dialog")
        UpdateStatus("30/100")
        API.DoAction_Inventory1({IDS.CenturionSword},0,3,API.OFF_ACT_GeneralInterface_route)
        Sleep(1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,955,15,-1,API.OFF_ACT_GeneralInterface_route) --Clicking big yellow CONTINUE button
        Sleep(1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster},50)
        Sleep(3)
    elseif questProgress == 35 then
        print("Progress: 35/100 - Handling dialog")
        UpdateStatus("35/100")
        HandleDialog()
    elseif questProgress == 40 then
        print("Progress: 40/100 - Crafting interface and soil handling")
        UpdateStatus("40/100")
        API.DoAction_Object1(0x1,API.OFF_ACT_GeneralObject_route0,{IDS.Mesh},50)
        local IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
        while API.Read_LoopyLoop() and not IsCraftingInterfaceOpen do
            Sleep(1)
            IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
        end
        PressSpace()
        while API.Read_LoopyLoop() and Inventory:Contains(IDS.Soil) do
            Sleep(1)
        end
        Sleep(1)
        HandleDialog()
        Sleep(2)
        HandleDialog()
    elseif questProgress == 50 then
        print("Progress: 50/100 - Moving to Material Storage")
        UpdateStatus("50/100")
        API.DoAction_WalkerW(WPOINT.new(3356 + math.random(-1, 1), 3396 + math.random(-1, 1), 0))
        WaitForObjectToAppear(IDS.MaterialStorage, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{IDS.MaterialStorage},50)
        while API.Read_LoopyLoop() and not IsPlayerInArea(3358, 3395, 0, 2) do
            Sleep(1)
        end
        Sleep(2)
    elseif questProgress == 55 then
        print("Progress: 55/100 - Depositing materials and crafting")
        UpdateStatus("55/100")
        API.DoAction_Interface(0x24,0xffffffff,1,660,30,-1,API.OFF_ACT_GeneralInterface_route) -- Deposit all materials
        Sleep(1)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{IDS.Workbech},50) -- Click Arch Workbench
        local IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
        while not IsCraftingInterfaceOpen and API.Read_LoopyLoop() do
            Sleep(1)
            IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
        end
        PressSpace()
        while API.Read_LoopyLoop() and Inventory:Contains(IDS.CenturionSword) do
            Sleep(1)
        end
    elseif questProgress == 60 then
        print("Progress: 60/100 - Returning to Guildmaster")
        UpdateStatus("60/100")
        API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
        WaitForObjectToAppear(IDS.Guildmaster, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster},50)
        HandleDialog()
    elseif questProgress == 65 then
        print("Progress: 65/100 - Interacting with Velucia")
        UpdateStatus("65/100")
        API.DoAction_WalkerW(WPOINT.new(3343, 3385, 0))
        WaitForObjectToAppear(IDS.Velucia, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Velucia},50)
        HandleDialog()
        Sleep(1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,955,15,-1,API.OFF_ACT_GeneralInterface_route) -- Another big yellow CONTINUE button
        Sleep(1)
        API.DoAction_Interface(0x24,0xffffffff,1,656,25,0,API.OFF_ACT_GeneralInterface_route) -- Contribute all button
        HandleDialog()
    elseif questProgress == 75 then
        print("Progress: 75/100 - Returning to Guildmaster")
        UpdateStatus("75/100")
        API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
        WaitForObjectToAppear(IDS.Guildmaster, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster},50)
        HandleDialog()
    elseif questProgress == 80 then
        print("Progress: 80/100 - Interacting with Monolith")
        UpdateStatus("80/100")
        API.DoAction_WalkerW(WPOINT.new(3363, 3383, 0))
        WaitForObjectToAppear(IDS.Monolith, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{IDS.Monolith},50)
        HandleDialog()
    elseif questProgress == 85 then
        print("Progress: 85/100 - Handling interface actions")
        UpdateStatus("85/100")
        API.DoAction_Interface(0x2e,0xffffffff,1,691,86,-1,API.OFF_ACT_GeneralInterface_route) -- Another big yellow CONTINUE button
        Sleep(1.2)
        API.DoAction_Interface(0x24,0xffffffff,1,691,72,-1,API.OFF_ACT_GeneralInterface_route) -- Harness power
        Sleep(1.2)
        API.DoAction_Interface(0x24,0xffffffff,1,691,165,-1,API.OFF_ACT_GeneralInterface_route) -- Select slot 1
        Sleep(1.2)
        API.DoAction_Interface(0x24,0xffffffff,1,691,161,-1,API.OFF_ACT_GeneralInterface_route) -- Confirm
        HandleDialog()
    elseif questProgress == 95 then
        print("Progress: 95/100 - Final steps with Guildmaster2")
        UpdateStatus("95/100")
        Sleep(3)
        API.DoAction_WalkerW(WPOINT.new(3325 + math.random(-1, 1), 3376 + math.random(-1, 1), 0))
        WaitForObjectToAppear(IDS.Guildmaster2, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster2},50)
        HandleDialog()
        Sleep(1)
        HandleDialog()
        Sleep(1)
        HandleDialog()
        Sleep(1)
        HandleDialog()
        Sleep(1)
        HandleDialog()
        Sleep(1)
    elseif questProgress == 96 then
        print("Progress: 96/100 - Claiming soil box from Ezreal")
        UpdateStatus("96/100")
        API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2,{IDS.Ezreal},50) --Open Ezreal shop
        while API.Read_LoopyLoop() and not IsPlayerInArea(3321, 3382, 0, 1) do
            Sleep(1)
        end
        Sleep(1.2)
        API.DoAction_Interface(0x24,0xffffffff,1,1594,23,0,API.OFF_ACT_GeneralInterface_route)-- Claim soil box
        Sleep(1.2)
        API.DoAction_Interface(0x24,0xffffffff,1,1594,58,-1,API.OFF_ACT_GeneralInterface_route) --Confirm
        Sleep(1.2)
    elseif questProgress == 97 then
        print("Progress: 97/100 - Final dialog with Guildmaster2")
        UpdateStatus("97/100")
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{IDS.Guildmaster2},50)
        HandleDialog()
        Sleep(1)
        API.KeyboardPress2(0x1B, 100, 100) --Escape key
        HandleDialog()
    elseif questProgress == 100 then
        print("Progress: 100/100 - Quest completed!")
        UpdateStatus("100/100")
        Sleep(2)
        print("Quest Completed!!!")
        API.Write_LoopyLoop(false)
    end
    Sleep(1)
    collectgarbage("collect")
end

API.DrawTable(EndTable)
print("----------//----------")
print("Script Name: " .. ScriptName)
print("Author: " .. Author)
print("Version: " .. ScriptVersion)
print("Release Date: " .. ReleaseDate)
print("Discord: " .. DiscordHandle)
print("----------//----------")
