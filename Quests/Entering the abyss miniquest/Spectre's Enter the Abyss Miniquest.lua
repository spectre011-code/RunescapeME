ScriptName = "Enter the Abyss Miniquest"
Author = "Spectre011"
ScriptVersion = "2.0.0"
ReleaseDate = "03-02-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 03-02-2025
    - Initial release.
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
]]
--Preset: https://imgur.com/a/BGUqXg5

local API = require("api")
local UTILS = require("utils")
local LODESTONES = require("lodestones")
local SpectreUtils = require("spectre")

--------------------START GUI STUFF--------------------
local SelectedOption = nil
local CurrentStatus = "Starting"
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

local function GetComponentValue(componentName)
    local componentArr = GetComponentByName(componentName)
    local componentKind = componentArr[3]
    local component = componentArr[2]

    if componentKind == "Label" then
        return component.string_value
    elseif componentKind == "CheckBox" then
        return component.return_click
    elseif componentKind == "ComboBox" and component.string_value ~= "None" then
        return component.string_value
    elseif componentKind == "ListBox" and component.string_value ~= "None" then
        return component.string_value
    end

    return nil
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
        elseif componentKind == "ListBox" then
            component.box_start = FFPOINT.new(40, 10 + ((i - 2) * 25), 0)
            API.DrawListBox(component, false)
        end
    end
end

local function CreateGUI()
    AddBackground("Background", 0.90, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("Status", "Status: " .. CurrentStatus, ImColor.new(238, 230, 0))
end

local function UpdateStatus(newStatus)
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
local interface = {
    questStart = { { 1500,0,-1,0 }, { 1500,329,-1,0 }, { 1500,399,-1,0 }, { 1500,407,-1,0 }, { 1500,408,-1,0 }, { 1500,408,3,0 } }
}

local function isInterfaceVisible(interface_components)
    return API.ScanForInterfaceTest2Get(false, interface_components)[1].x ~= nil 
        and API.ScanForInterfaceTest2Get(false, interface_components)[1].x ~= 0
end

local function MoveTo(X, Y, Z, Tolerance)
    API.DoAction_WalkerW(WPOINT.new(X + math.random(-Tolerance, Tolerance),Y + math.random(-Tolerance, Tolerance),Z))
    while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(X, Y, Z, Tolerance + 1) do
        UTILS.randomSleep(300)
    end
    return true
end


local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end

local function HasOption()
    local option = API.ScanForInterfaceTest2Get(false, { { 1188, 5, -1, -1}, { 1188, 3, -1, 5}, { 1188, 3, 14, 3} })

    if #option > 0 and #option[1].textids > 0 then
        return option[1].textids
    end

    return false
end

local function PressSpace()
    return API.KeyboardPress2(0x20, 40, 60), API.RandomSleep2(400,300,600)
end

local function OptionSelector()
    local options = { --Insert dialog options here
        "Where do you get your runes from?",
        "Yes",
        "No, nothing else, thanks."
    }

    for i, optionText in ipairs(options) do
        local optionNumber = tonumber(API.Dialog_Option(optionText))
        if optionNumber and optionNumber > 0 then
            local keyCode = 0x30 + optionNumber
            API.KeyboardPress2(keyCode, 60, 100)
            return true
        end
    end
    return false
end

local function HandleDialog()
    while API.Read_LoopyLoop() and not DialogBoxOpen() do
        SpectreUtils.Sleep(0.3)
    end
    while API.Read_LoopyLoop() and DialogBoxOpen() do
        if HasOption() then
            OptionSelector()
            SpectreUtils.Sleep(0.3)
        else
            PressSpace()
            SpectreUtils.Sleep(0.3)
        end
    end
end

--Opens doors that have a type 0 object when opened but are type 12
---@param Obj0ID number
---@param Obj0XCoord number
---@param Obj0ycoord number
---@param Obj12ID number
---@return boolean
local function OpenDoor(Obj0ID, Obj0XCoord, Obj0YCoord, Obj12ID)
    local door = #API.GetAllObjArray2({Obj0ID}, 50, {0}, WPOINT.new(Obj0XCoord, Obj0YCoord, 0))    
    if door == 0 then 
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{Obj12ID},50) --Open door
        while API.Read_LoopyLoop() and door == 0 do
            UTILS.randomSleep(100)
            door = #API.GetAllObjArray2({Obj0ID}, 50, {0}, WPOINT.new(Obj0XCoord, Obj0YCoord, 0))  
        end
        return true
    end
    return false
end


local stageID = 1
local StageDescriptions = {
    [1] = "Stage 1: Starting the quest",
    [2] = "Stage 2: First teleport",
    [3] = "Stage 3: Second teleport",
    [4] = "Stage 4: Third teleport",
    [5] = "Stage 5: Finishing the quest"
}

local stageFunctions = {
    [1] = function()
        print("Stage 1: Starting the quest")
        UpdateStatus("Starting the quest")
        LODESTONES.EDGEVILLE.Teleport()
        while API.Read_LoopyLoop() and API.PlayerCoord().y ~= 3523 do
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{65081},50)
            SpectreUtils.Sleep(10)
        end
        MoveTo(3107, 3558, 0, 4)
        print("Finished moving")
        SpectreUtils.WaitForObjectToAppear(2257, 1)
        print("Finished Waiting for object to appear")
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{2257},50)
        while not isInterfaceVisible(interface['questStart']) do
            SpectreUtils.Sleep(1)
        end
        API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route)
        HandleDialog()
        LODESTONES.VARROCK.Teleport()
        MoveTo(3212, 3390, 0, 2)
        MoveTo(3253, 3388, 0, 0)
        OpenDoor(24383, 3256, 3388, 24384)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{2260},50)
        HandleDialog()
        stageID = 2
    end,

    [2] = function()
        print("Stage 2: First teleport")
        UpdateStatus("First teleport")
        MoveTo(3256, 3388, 0, 1)
        OpenDoor(24383, 3256, 3388, 24384)
        MoveTo(3253, 3398, 0, 1)
        OpenDoor(24383, 3253, 3399, 24384)
        API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route4,{5913},50)
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({5913}, 50, {1}) > 0 do
            SpectreUtils.Sleep(1)
        end
        stageID = 3
    end,

    [3] = function()
        print("Stage 3: Second teleport")
        UpdateStatus("Second teleport")
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({79776}, 50, {0}) < 1 do
            API.DoAction_Inventory2({22332},0,3,API.OFF_ACT_GeneralInterface_route) --RC guild wicked hood teleport
            SpectreUtils.Sleep(5)
        end        
        SpectreUtils.WaitForObjectToAppear(79776, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{79776},50)
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({16184}, 50, {1}) < 1 do
            SpectreUtils.Sleep(1)
        end
        API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2,{16184},50)
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({16184}, 50, {1}) > 0 do
            SpectreUtils.Sleep(1)
        end
        stageID = 4

    end,

    [4] = function()
        print("Stage 4: Third teleport")
        UpdateStatus("Third teleport")
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2677, 3324, 0, 1)
        OpenDoor(34823, 2679, 3324, 34822)
        API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2,{844},50)
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({844}, 50, {1}) > 0 do
            SpectreUtils.Sleep(1)
        end
        stageID = 5
    end,

    [5] = function()
        print("Stage 5: Finishing the quest")
        UpdateStatus("Finishing the quest")
        LODESTONES.VARROCK.Teleport()
        MoveTo(3212, 3390, 0, 2)
        MoveTo(3253, 3388, 0, 0)
        OpenDoor(24383, 3256, 3388, 24384)
        for i=1, 3 do
            API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{2260},50)
            HandleDialog()
            SpectreUtils.Sleep(1)
        end
        API.Write_LoopyLoop(false)
    end
}

local function executeStage(stageID)
    if stageFunctions[stageID] then
        stageFunctions[stageID]()
    else
        print("Invalid stage ID: " .. tostring(stageID))
    end
end

Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()
    print("State: ", API.VB_FindPSettinOrder(3149).state)
    executeStage(stageID)
    print("Memory usage: ", collectgarbage("count"), "KB")
    collectgarbage("collect")
    SpectreUtils.Sleep(1)
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
