ScriptName = "Easy Clue Solver"
Author = "Spectre011"
ScriptVersion = "2.0.1"
ReleaseDate = "09-02-2025"
DiscordHandle = "not_spectre011"
--PRESET: https://imgur.com/a/fAnUAng

--[[
Changelog:
v1.0 - 06-02-2025
    - Initial release.
v1.1 - 06-02-2025
    - Fixed Seed pod ID on ReqCheck() function.
v1.2 - 08-02-2025
    - Fixed step 2703, it was not checking for the correct Z coordinate to finish the step, causing the script to freeze.
v1.3 - 08-02-2025
    - Fixed step 3505, it was not checking for the correct Z coordinate to finish the step, causing the script to freeze.
v1.4 - 08-02-2025
    - Added the function OpenDrawer2 to specify coordinates.
    - Changed step 2700 to use OpenDrawer2 instead of OpenDrawer function to prevent the wrong drawer from being opened.
v1.5 - 09-02-2025
    - Fixed step 10186, it was not able to consistently reach the location of the step so a middle point was added to help with the pathing.
v1.6 - 12-02-2025
    - Fixed step 10198, it was not able to consistently enter or exit the wheat field so a gate check was added.
v1.7 - 06-03-2025
    - Fixed Dive function as it was crashing the script if the account did not have neither dive nor bladed dive.
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
v2.0.1 - 08-04-2025
    - Increase tolerace+1 to tolerance+3 due to step 10198 getting stuck constantly
]]

local API = require("api")
local UTILS = require("utils")
local LODESTONES = require("lodestones")

--------------------START GUI STUFF--------------------
local CurrentStatus = "Starting"
local ReasonForStopping = "Manual Stop."
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
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " - " .. Author, ImColor.new(238, 230, 0))
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

--------------------START METRICS STUFF--------------------
local MetricsTable = {
    {"-", "-"}
}

local startTime = os.time() 
local counter = 0
local lastUpdateTime = os.time()
local updateFrequency = 0

local function FormatRunTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function CalcIncreasesPerHour()
    local runTimeInHours = (os.time() - startTime) / 3600
    if runTimeInHours > 0 then
        return counter / runTimeInHours
    else
        return 0
    end
end

local function CalcAverageIncreaseTime()
    if counter > 0 then
        return (os.time() - startTime) / counter
    else
        return 0
    end
end

local function Tracking() -- This is what should be called at the end of every cycle
    counter = counter + 1 
    local runTime = os.time() - startTime
    local increasesPerHour = CalcIncreasesPerHour() 
    local avgIncreaseTime = CalcAverageIncreaseTime() 

    MetricsTable[1] = {"Thanks for using my script!"}
    MetricsTable[2] = {" "}
    MetricsTable[3] = {"Total Run Time", FormatRunTime(runTime)}
    MetricsTable[4] = {"Total Clue Scrolls", tostring(counter)}
    MetricsTable[5] = {"Clue Scrolls per Hour", string.format("%.2f", increasesPerHour)}
    MetricsTable[6] = {"Average Clue Scrolls Time (s)", string.format("%.2f", avgIncreaseTime)}
    MetricsTable[7] = {"-----", "-----"}
    MetricsTable[8] = {"Script's Name:", ScriptName}
    MetricsTable[9] = {"Author:", Author}
    MetricsTable[10] = {"Version:", ScriptVersion}
    MetricsTable[11] = {"Release Date:", ReleaseDate}
    MetricsTable[12] = {"Discord:", DiscordHandle}
end
--------------------END METRICS STUFF--------------------
local function Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
end

local function GetIdFromEquip(slot)
    --[[Equip Slots
    0  - Head
    1  - Cape
    2  - Neck
    3  - Main Hand
    4  - Chest
    5  - Off Hand
    6  - Legs
    7  - Hands
    8  - Boots
    9  - Ring
    10 - Ammo
    11 - Aura
    12 - Pocket]]
    return API.GetEquipSlot(slot).itemid1
end

local function SurgeIfFacing(Orientation)
    local Surge = API.GetABs_id(14233)
    local PlayerFacing = math.floor(API.calculatePlayerOrientation()) 

    local function NormalizeOrientation(value)
        return value == 360 and 0 or value
    end
    
    if NormalizeOrientation(Orientation) == NormalizeOrientation(PlayerFacing) then
        if (Surge.id ~= 0 and Surge.cooldown_timer < 1) then
            UTILS.surge()
        end
    end        
end

local function Dive(WPOINT)
    local bladedDive = API.GetABs_id(30331)
    local dive = API.GetABs_id(23714)

    if bladedDive and bladedDive.id ~= 0 and bladedDive.cooldown_timer < 1 and bladedDive.enabled then
        print("Using Bladed Dive")
        if not API.DoAction_BDive_Tile(WPOINT) then
            print("Failed to use Bladed Dive, attempting Dive instead.")
            if dive and dive.id ~= 0 and dive.cooldown_timer < 1 and dive.enabled then
                API.DoAction_Dive_Tile(WPOINT)
            else
                print("Dive is not available.")
            end
        end
    elseif dive and dive.id ~= 0 and dive.cooldown_timer < 1 and dive.enabled then
        print("Using Dive")
        API.DoAction_Dive_Tile(WPOINT)
    else
        print("Neither Bladed Dive nor Dive is available.")
    end
end

local function WaitForObjectToAppear(ObjID, ObjType)
    while API.Read_LoopyLoop() do
        local objects = API.GetAllObjArray1({ObjID}, 50, {ObjType})
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
        Sleep(0.2)
    end
end

local function WaitForObjectToAppear2(ObjID, ObjType, WPOINT)
    while API.Read_LoopyLoop() do
        local objects = API.GetAllObjArray2({ObjID}, 75, {ObjType}, WPOINT)
        if objects and #objects > 0 then
            for _, object in ipairs(objects) do
                local id = object.Id or 0
                local objType = object.Type or 0           
                if id == ObjID and objType == ObjType then
                    return
                end
            end
        else
            print("No objects found on this attempt.2")
        end
        Sleep(0.2)
    end
end

local function IsPlayerAtCoords(x, y, z)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y and z == coord.z then
        return true
    else
        return false
    end
end

local function IsPlayerAtZCoords(z)
    local coord = API.PlayerCoord()
    if z == coord.z then
        return true
    else
        return false
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

local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end

local function WaitForDialogThenPressSpacebar()
    local count = 0
    while API.Read_LoopyLoop() and not DialogBoxOpen() do
        if count > 10 then 
            break
        end
        UTILS.randomSleep(1000)
        count = count + 1
    end
    API.KeyboardPress31(32, 0, 0)
end

local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
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

local function EquipStuff(Item1, Item2, Item3)
    local ids = {Item1, Item2, Item3}
    while API.Read_LoopyLoop() and not Equipment:ContainsAll(ids) do
        for _, id in pairs(ids) do
            Inventory:Equip(id)
            UTILS.randomSleep(300)
        end
    end
    return true
end

local function MoveTo(X, Y, Z, Tolerance)
    API.DoAction_WalkerW(WPOINT.new(X + math.random(-Tolerance, Tolerance),Y + math.random(-Tolerance, Tolerance),Z))
    while API.Read_LoopyLoop() and not IsPlayerInArea(X, Y, Z, Tolerance + 3) do
        UTILS.randomSleep(300)
    end
    return true
end

local function OpenDrawer(Obj0ID, Obj12ID)
    local drawer = #API.GetAllObjArrayInteract({Obj0ID}, 50, {0})
    if drawer == 0 then
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{Obj12ID},50) -- Open drawers
    else
        API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{Obj0ID},50) -- Search drawers
    end
end

local function OpenDrawer2(Obj0ID, Obj12ID, X, Y, Z)
    local drawer = #API.GetAllObjArrayInteract({Obj0ID}, 50, {0})
    if drawer == 0 then
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{Obj12ID},50,WPOINT.new(X,Y,Z)) -- Open drawers
    else
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{Obj0ID},50,WPOINT.new(X,Y,Z)) --Search drawers
    end
end

local function ReqCheck()
    UpdateStatus("Checking requirements")
    --Emotes tab open check
    if API.VB_FindPSettinOrder(3158, 1).state ~= 1 then
        print("REASON FOR STOPPING: Emotes tab not visible.")
        ReasonForStopping = "Emotes tab not visible."
        API.Write_LoopyLoop(false)
        return
    end

    --Equipment tab open check
    if not Equipment:IsOpen() then
        print("REASON FOR STOPPING: Equipment tab not visible.")
        ReasonForStopping = "Equipment tab not visible."
        API.Write_LoopyLoop(false)
        return
    end

    --Inventory tab open check
    if not Inventory:IsOpen() then
        print("REASON FOR STOPPING: Inventory tab not visible.")
        ReasonForStopping = "Inventory tab not visible."
        API.Write_LoopyLoop(false)
        return
    end

    --Clue Scroll on firt slot check
    local slotData = Inventory:GetSlotData(0).name
    if not string.find(slotData, "%(easy%)") then
        print("REASON FOR STOPPING: Clue scroll (easy) not found in the first slot of inventory.")
        ReasonForStopping = "Clue scroll (easy) not found in the first slot of inventory."
        API.Write_LoopyLoop(false)
        return
    end

    --Khazard teleport check
    if not Inventory:Contains(50558) then
        print("REASON FOR STOPPING: Khazard teleport not found in inventory.")
        ReasonForStopping = "Khazard teleport not found in inventory."
        API.Write_LoopyLoop(false)
        return
    end

    --Grand seed pod check
    if not Inventory:Contains(9469) then
        print("REASON FOR STOPPING: Grand seed pod not found in inventory.")
        ReasonForStopping = "Grand seed pod not found in inventory."
        API.Write_LoopyLoop(false)
        return
    end

    --Wicked hood check
    if not Inventory:Contains(22332) then
        print("REASON FOR STOPPING: Wicked hood not found in inventory.")
        ReasonForStopping = "Wicked hood not found in inventory."
        API.Write_LoopyLoop(false)
        return
    end

    --Spade check
    if not Inventory:Contains(952) then
        print("REASON FOR STOPPING: Spade not found in inventory.")
        ReasonForStopping = "Spade not found in inventory."
        API.Write_LoopyLoop(false)
        return
    end
end

local clueSteps = {
    [2677] = function()
        API.DoAction_Inventory1(2677,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        API.DoAction_Tile(WPOINT.new(3216 + math.random(-1, 1),3210 + math.random(-1, 1),0))
        UTILS.randomSleep(3000)
        SurgeIfFacing(270)
        WaitForObjectToAppear(36773, 12)
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{36773},50) -- Climb staircase
        WaitForObjectToAppear(741, 1)
        local door = #API.GetAllObjArrayInteract({36845}, 50, {0})
        if door == 0 then
            API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{36844},50) -- Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(300)
                door = #API.GetAllObjArrayInteract({36845}, 50, {0})
            end
        end
        local chest = #API.GetAllObjArrayInteract({37010}, 50, {0})
        if chest == 0 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{37009},50) -- Open chest
        else
            API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route1,{37010},50) -- Search chest
        end        
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3209, 3219, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2678] = function()
        API.DoAction_Inventory1(2678,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3225, 3214, 0, 2)
        WaitForObjectToAppear(36768, 12)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{36768},50,WPOINT.new(3229,3213,0)) --Climb-up ladder
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(21806, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{21806},50,WPOINT.new(3228,3212,0)) --Search crate
        while API.Read_LoopyLoop() and not IsPlayerInArea(3228, 3213, 1, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2679] = function()
        API.DoAction_Inventory1(2679,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3246, 3243, 0, 2)
        WaitForObjectToAppear(46237, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{46237},50,WPOINT.new(3247,3244,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3246, 3244, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2680] = function()
        API.DoAction_Inventory1(2680,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3301, 3166, 0, 1)
        WaitForObjectToAppear(76216, 12)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{76216},50,WPOINT.new(3301,3164,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3301, 3165, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2681] = function()
        API.DoAction_Inventory1(2681,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3222, 3220, 0, 3)
        local hans = API.ReadAllObjectsArray({1}, {0}, "Hans")
        while API.Read_LoopyLoop() and hans[1].Distance > 10 do
            hans = API.ReadAllObjectsArray({1}, {0}, "Hans")
            if #hans > 0 then
                print("Waiting for Hans: ", hans[1].Distance)
            end
            UTILS.randomSleep(100)
        end
        API.DoAction_NPC__Direct(0x2c, API.OFF_ACT_InteractNPC_route, hans[1])
        print("Clicking Hans")
        WaitForDialogThenPressSpacebar()
    end,
    [2682] = function()
        API.DoAction_Inventory1(2682,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3291, 3203, 0, 1)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{76811},50,WPOINT.new(3289,3202,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3289, 3203, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2683] = function()
        API.DoAction_Inventory1(2683,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        WaitForObjectToAppear(541, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{541},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2684] = function()
        API.DoAction_Inventory1(2684,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3273,3195,0, 1)
        WaitForObjectToAppear(2824, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route2,{2824},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2685] = function()
        API.DoAction_Inventory1(2685,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        MoveTo(3208, 3385, 0, 1)
        OpenDoor(24375, 3207, 3385, 24376)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{46236},50,WPOINT.new(3203,3384,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3204, 3384, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2686] = function()
        API.DoAction_Inventory1(2686,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        MoveTo(3222, 3398, 0, 2)
        WaitForObjectToAppear(733, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{733},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2687] = function()
        API.DoAction_Inventory1(2687,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        MoveTo(3253, 3421, 0, 2)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{24349},50,WPOINT.new(3256,3422,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        local drawer = #API.GetAllObjArrayInteract({24295}, 50, {0})
        if drawer == 0 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{24294},50) -- Open drawers
        else
            API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{24295},50) -- Search drawers
        end
        while API.Read_LoopyLoop() and not IsPlayerInArea(3251, 3420, 1, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2688] = function()
        API.DoAction_Inventory1(2688,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_Tile(WPOINT.new(3211 + math.random(-1, 1),3390 + math.random(-1, 1),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(360)
        UTILS.randomSleep(300)
        API.DoAction_Tile(WPOINT.new(3211 + math.random(-1, 1),3414 + math.random(-1, 1),0))
        UTILS.randomSleep(7000)
        API.DoAction_Tile(WPOINT.new(3210 + math.random(-1, 1),3435 + math.random(-1, 1),0))
        UTILS.randomSleep(1000)
        SurgeIfFacing(360)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3213 + math.random(-1, 1),3454 + math.random(-1, 1),0))
        API.DoAction_WalkerW(WPOINT.new(3228 + math.random(-1, 1),3430 + math.random(-1, 1),0))
        WaitForObjectToAppear2(46269, 12, WPOINT.new(3228, 3433, 0))
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{ 46269 },50,WPOINT.new(3228,3433,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3228, 3433, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2689] = function()
        API.DoAction_Inventory1(2689,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        MoveTo(3152, 3403, 0, 1)
        OpenDoor(24375, 3152, 3404, 24376)
        API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{24379},50,WPOINT.new(3152,3405,0))
        UTILS.randomSleep(2000)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{24381},50,WPOINT.new(3154,3405,0))
        UTILS.randomSleep(2000)
        local drawer = #API.GetAllObjArrayInteract({24295}, 50, {0})
        if drawer == 0 then
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{24294},50,WPOINT.new(3156,3406,0)) -- Open drawers
        else
            API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{24295},50,WPOINT.new(3156,3406,0)) -- Search drawers
        end
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3155, 3406, 0) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2690] = function()
        API.DoAction_Inventory1(2690,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        MoveTo(3077, 3425, 0, 1)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{11600},50,WPOINT.new(3073,3430,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3074, 3430, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2691] = function()
        API.DoAction_Inventory1(2692,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        MoveTo(2975, 3383, 0, 1)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{11732},50,WPOINT.new(2973,3384,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(25034, 12)
        OpenDrawer(25035, 25034)
        UTILS.randomSleep(2000)
    end,
    [2692] = function()
        API.DoAction_Inventory1(2692,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_Tile(WPOINT.new(2959 + math.random(-2, 2),3387 + math.random(-2, 2),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(180)
        UTILS.randomSleep(200)
        API.DoAction_Tile(WPOINT.new(2959 + math.random(-1, 1),3387 + math.random(-1, 1),0))
        WaitForObjectToAppear2(11745, 12, WPOINT.new(2955,3390,0))
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{11745},50,WPOINT.new(2955,3390,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2955, 3390, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2693] = function()
        API.DoAction_Inventory1(2693,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_WalkerW(WPOINT.new(2972 + math.random(-1, 1),3343 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2972, 3343, 0, 3) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(606, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{606},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2694] = function()
        API.DoAction_Inventory1(2694,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        MoveTo(2971, 3312, 0, 2)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25034},50,WPOINT.new(2969,3311,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2970, 3311, 0) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2695] = function()
        API.DoAction_Inventory1(2695,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3014, 3223, 0, 1)
        WaitForObjectToAppear(40021, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{40021},50,WPOINT.new(3012,3222,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3013, 3222, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2696] = function()
        API.DoAction_Inventory1(2696,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3049, 3257, 0, 2)
        WaitForObjectToAppear(734, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{734},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2697] = function()
        API.DoAction_Inventory1(2697,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3104, 3257, 0, 1)
        OpenDoor(1240, 3102, 3257, 1239)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{918},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2698] = function()
        API.DoAction_Inventory1(2698,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        MoveTo(2959, 3439, 0, 2)
        WaitForObjectToAppear(284, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{284},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2699] = function()
        API.DoAction_Inventory1(2699,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.BURTHOPE.Teleport()
        MoveTo(2929, 3547, 0, 0)
        OpenDoor(67139, 2929, 3548, 67138)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{586},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2700] = function()
        API.DoAction_Inventory1(2700,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.CATHERBY.Teleport()
        MoveTo(2827, 3455, 0, 1)
        OpenDrawer2(25035, 25034, 2828,3457,0)
        while API.Read_LoopyLoop() and not IsPlayerInArea(2828, 3456, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2701] = function()
        API.DoAction_Inventory1(2701,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.CATHERBY.Teleport()
        API.DoAction_Tile(WPOINT.new(2801 + math.random(-2, 2),3433 + math.random(-2, 2),0))
        WaitForObjectToAppear(563, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{563},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2702] = function()
        API.DoAction_Inventory1(2702,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2752, 3478, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{26081},50,WPOINT.new(2757,3482,0))
        while API.Read_LoopyLoop() and API.PlayerCoord().y ~= 3483 do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
        MoveTo(2760, 3498, 0, 2)
        WaitForObjectToAppear(241, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{241},50)
        WaitForDialogThenPressSpacebar()
    end,
    [2703] = function()
        API.DoAction_Inventory1(2703,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        API.DoAction_WalkerW(WPOINT.new(2757 + math.random(-1, 1),3479 + math.random(-1, 1),0))
        WaitForObjectToAppear(26081, 12)
        API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{26081},50) --Open gate
        while API.Read_LoopyLoop() and not IsPlayerInArea(2757, 3484, 0, 1) do
            UTILS.randomSleep(300)
        end
        API.DoAction_WalkerW(WPOINT.new(2757 + math.random(-1, 1),3501 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2757, 3501, 0, 1) do
            UTILS.randomSleep(300)
        end

        local door = #API.GetAllObjArray2({25639}, 50, {0}, WPOINT.new(2757, 3504, 0))    
        if door == 0 then 
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{25638},50) --Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(100)
                door = #API.GetAllObjArray2({25639}, 50, {0}, WPOINT.new(2757, 3504, 0))  
            end
        end
        API.DoAction_WalkerW(WPOINT.new(2750 + math.random(-1, 1),3505 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2750, 3505, 0, 1) do
            UTILS.randomSleep(300)
        end

        local door2 = #API.GetAllObjArray2({25643}, 50, {0}, WPOINT.new(2750, 3504, 0))    
        if door2 == 0 then 
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25642},50,WPOINT.new(2750,3503,0)) --Open door
            while API.Read_LoopyLoop() and door2 == 0 do
                UTILS.randomSleep(100)
                door2 = #API.GetAllObjArray2({25643}, 50, {0}, WPOINT.new(2750, 3504, 0))  
            end
        end
        API.DoAction_WalkerW(WPOINT.new(2750 + math.random(-1, 1),3497 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2750, 3497, 0, 1) do
            UTILS.randomSleep(300)
        end

        local door3 = #API.GetAllObjArray2({25643}, 50, {0}, WPOINT.new(2750, 3495, 0))    
        if door3 == 0 then 
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25642},50,WPOINT.new(2750,3496,0)) --Open door
            while API.Read_LoopyLoop() and door3 == 0 do
                UTILS.randomSleep(100)
                door3 = #API.GetAllObjArray2({25643}, 50, {0}, WPOINT.new(2750, 3495, 0))   
            end
        end

        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{26107},50,WPOINT.new(2747,3493,0)) --Climb-up ladder
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end

        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{26107},50,WPOINT.new(2749,3491,0)) --Climb-up ladder
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(2) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(25592, 12)
        if not API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25592},50,WPOINT.new(2748,3495,0)) then  --Open closed Chest
            API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route1,{25593},50,WPOINT.new(2748,3495,0)) --Search opened chest
        end
        while API.Read_LoopyLoop() and not IsPlayerInArea(2748, 3494, 2, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2704] = function()
        API.DoAction_Inventory1(2704,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        API.DoAction_WalkerW(WPOINT.new(2659 + math.random(-1, 1),3318 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2659, 3318, 0, 1) do
            UTILS.randomSleep(300)
        end
        local door = #API.GetAllObjArray2({34808}, 50, {0}, WPOINT.new(2659, 3320, 0))    
        if door == 0 then 
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{34807},50,WPOINT.new(2659,3319,0)) --Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(100)
                door = #API.GetAllObjArray2({34808}, 50, {0}, WPOINT.new(2659, 3320, 0)) 
            end
        end
        WaitForObjectToAppear(34585, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{34585},50,WPOINT.new(2658,3323,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2658, 3322, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2705] = function()
        API.DoAction_Inventory1(2705,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2653, 3299, 0, 3)
        WaitForObjectToAppear(34586, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{34586},50,WPOINT.new(2654,3299,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2653, 3299, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)

    end,
    [2706] = function()
        API.DoAction_Inventory1(2706,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2614, 3292, 0, 1)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{34585},50,WPOINT.new(2615,3291,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2615, 3292, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [2707] = function()
        API.DoAction_Inventory1(2707,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2616, 3338, 0, 2)
        WaitForObjectToAppear(34586, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{34586},50,WPOINT.new(2620,3336,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2620, 3337, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [2708] = function()
        API.DoAction_Inventory1(2708,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_Tile(WPOINT.new(3211 + math.random(-1, 1),3390 + math.random(-1, 1),0))
        UTILS.randomSleep(1000)
        SurgeIfFacing(360)
        UTILS.randomSleep(200)
        API.DoAction_Tile(WPOINT.new(3206 + math.random(-1, 1),3416 + math.random(-1, 1),0))
        UTILS.randomSleep(1000)
        SurgeIfFacing(360)
        UTILS.randomSleep(200)
        API.DoAction_Tile(WPOINT.new(3206 + math.random(-1, 1),3416 + math.random(-1, 1),0))
        WaitForObjectToAppear(24354, 12)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{24354},50,WPOINT.new(3202,3416,0)) -- Climb Thessalia
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3202, 3417, 1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(24294, 12)
        local drawer = #API.GetAllObjArrayInteract({24295}, 50, {0})
        if drawer == 0 then
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{24294},50) -- Open drawers
        else
            API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{24295},50) -- Search drawers
        end
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3206, 3418, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2709] = function()
        API.DoAction_Inventory1(2709,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_WalkerW(WPOINT.new(3223 + math.random(-1, 1),3452 + math.random(-1, 1),0))
        WaitForObjectToAppear2(46269, 12, WPOINT.new(3226, 3452, 0))
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{46269},50,WPOINT.new(3226,3452,0)) --Search crate
        while API.Read_LoopyLoop() and not IsPlayerInArea(3225, 3452, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [2710] = function()
        API.DoAction_Inventory1(2710,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2578, 3320, 0, 2)
        OpenDoor(34810, 2577, 3320, 34809)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{34548},50,WPOINT.new(2573,3325,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            print(API.PlayerCoord().z)
            UTILS.randomSleep(300)
        end
        print(API.PlayerCoord().z)
        WaitForObjectToAppear(34482, 12)
        OpenDrawer(34483, 34482)
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2575, 3325, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)

    end,
    [2711] = function()
        API.DoAction_Inventory1(2711,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2615,3301, 0, 1)
        OpenDoor(34820, 2615, 3304, 34819)
        MoveTo(2613, 3309, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{34811},50,WPOINT.new(2613,3309,0))
        UTILS.randomSleep(1500)
        MoveTo(2611, 3308, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{34811},50,WPOINT.new(2611,3307,0))
        UTILS.randomSleep(1500)
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{34548},50)
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(34585, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{34585},50,WPOINT.new(2612,3306,0))
        UTILS.randomSleep(2000)
    end,
    [2712] = function()
        API.DoAction_Inventory1(2712,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_Tile(WPOINT.new(2974 + math.random(-2, 2),3372 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2974, 3372, 0, 4) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Tile(WPOINT.new(3007 + math.random(-2, 2),3361 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3007, 3361, 0, 4) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Tile(WPOINT.new(3028, 3356,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3028, 3356, 0) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear2(11707, 12, WPOINT.new(3028, 3356, 0))
        local door = #API.GetAllObjArray2({11708}, 50, {0}, WPOINT.new(3028, 3355, 0))    
        if door == 0 then 
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{11707},50) -- Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(100)
                door = #API.GetAllObjArray2({11708}, 50, {0}, WPOINT.new(3028, 3355, 0)) 
            end
        end
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{11745},50,WPOINT.new(3029,3355,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3029, 3355, 0, 1) do
            UTILS.randomSleep(300)
        end  
    end,
    [2713] = function()
        API.DoAction_Inventory1(2713,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_Tile(WPOINT.new(3188 + math.random(-2, 2),3372 + math.random(-2, 2),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(270)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3173,3360,0))
        UTILS.randomSleep(200)
        API.DoAction_WalkerW(WPOINT.new(3166, 3360, 0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3166, 3360, 0) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) -- Dig spade
    end,
    [2716] = function()
        API.DoAction_Inventory1(2716,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_Tile(WPOINT.new(3248 + math.random(-2, 2),3369 + math.random(-2, 2),0))
        UTILS.randomSleep(4000)
        SurgeIfFacing(90)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3272,3366,0))
        UTILS.randomSleep(200)
        API.DoAction_WalkerW(WPOINT.new(3290, 3374, 0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3290, 3374, 0) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) -- Dig spade
    end,
    [2719] = function()
        API.DoAction_Inventory1(2719,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_Tile(WPOINT.new(2991 + math.random(-3, 3),3406 + math.random(-3, 3),0))
        UTILS.randomSleep(3500)
        SurgeIfFacing(90)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3034 + math.random(-2, 2),3400 + math.random(-2, 2),0))
        API.DoAction_Tile(WPOINT.new(3042 + math.random(-1, 1),3406 + math.random(-1, 1),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(90)
        API.DoAction_WalkerW(WPOINT.new(3043,3398,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3043, 3398, 0) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) -- Dig spade
    end,
    [3490] = function()
        API.DoAction_Inventory1(3490,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.BURTHOPE.Teleport()
        MoveTo(2918,3524,0,1)
        OpenDoor(67139, 2916, 3524, 67138)

        if #API.GetAllObjArray2({67305}, 50, {0}, WPOINT.new(2914, 3521, 0)) > 0 then
            API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route1,{67305},50,WPOINT.new(2914,3521,0)) --Search drawer
        else
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{67304},50,WPOINT.new(2914,3521,0)) --Open drawer
        end
        while API.Read_LoopyLoop() and not IsPlayerInArea(2914, 3522, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)        
    end,
    [3491] = function()
        API.DoAction_Inventory1(3491,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.YANILLE.Teleport()
        MoveTo(2594, 3101, 0, 1)
        OpenDoor(17090, 2594, 3103, 17089)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{24202},50,WPOINT.new(2598,3105,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2597, 3105, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3492] = function()
        API.DoAction_Inventory1(3491,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.YANILLE.Teleport()
        MoveTo(2563, 3082, 0, 0)
        OpenDoor(1534, 2564, 3082, 1533)
        MoveTo(2569, 3085, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{350},50,WPOINT.new(2570,3085,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2569, 3085, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3493] = function()
        API.DoAction_Inventory1(3493,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_WalkerW(WPOINT.new(3015 + math.random(-2, 2),3447 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3015, 3447, 0, 5) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(30942, 12)
        API.DoAction_Object1(0x35,API.OFF_ACT_GeneralObject_route0,{30942},50)
        while API.Read_LoopyLoop() and not IsPlayerInArea(3018, 9850, 0, 3) do
            UTILS.randomSleep(300)
        end
        API.DoAction_WalkerW(WPOINT.new(3003 + math.random(-2, 2),9798 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3003, 9798, 0, 5) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear2(30928, 12, WPOINT.new(3000,9798,0))
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{30928},50,WPOINT.new(3000,9798,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3001, 9798, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [3494] = function()
        API.DoAction_Inventory1(3494,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(2961, 3216, 0, 1)
        if #API.GetAllObjArray2({72004}, 50, {0}, WPOINT.new(2962, 3216, 0)) > 0 then
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{72004},50,WPOINT.new(2962,3216,0)) --Open door
            UTILS.randomSleep(1000)
        end 
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{71902},50,WPOINT.new(2966,3219,0)) --Climb-up starircase
        while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 1 do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(71943,12)
        if #API.GetAllObjArray2({71944}, 50, {0}, WPOINT.new(2970, 3214, 0)) > 0 then
            API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route1,{71944},50,WPOINT.new(2970,3214,0)) --Search drawer
        else
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{71943},50,WPOINT.new(2970,3214,0)) --Open drawer
        end
        while API.Read_LoopyLoop() and not IsPlayerInArea(2969, 3214, 1, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000) 
    end,
    [3495] = function()
        API.DoAction_Inventory1(3495,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3018, 3206, 0, 1)
        WaitForObjectToAppear(40108, 12)
        OpenDoor(40109, 3016, 3206, 40108)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{40026},50,WPOINT.new(3013,3203,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{40093},50,WPOINT.new(3016,3205,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3015, 3205, 1, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [3496] = function()
        API.DoAction_Inventory1(3494,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        WaitForObjectToAppear(376, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route2,{376},50)
        WaitForDialogThenPressSpacebar()
    end,
    [3497] = function()
        API.DoAction_Inventory1(3497,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_WalkerW(WPOINT.new(2967 + math.random(-1, 1),3382 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2967, 3382, 0, 3) do
            UTILS.randomSleep(300)
        end
        API.DoAction_WalkerW(WPOINT.new(3038 + math.random(-1, 1),3360 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3038, 3360, 0, 2) do
            UTILS.randomSleep(300)
        end

        local door = #API.GetAllObjArray2({11708}, 50, {0}, WPOINT.new(3038, 3362, 2))    
        if door == 0 then 
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{11707},50,WPOINT.new(3038,3361,0)) --Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(100)
                door = #API.GetAllObjArray2({11708}, 50, {0}, WPOINT.new(3038, 3362, 2))
                API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{11707},50,WPOINT.new(3038,3361,0)) --Open door
            end
        end       
        WaitForObjectToAppear(35781, 12)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{35781},50,WPOINT.new(3034,3363,0)) --Climb-up staircase
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear2(99819, 12, WPOINT.new(3041, 3364, 1))
        if not API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{99819},50,WPOINT.new(3041,3364,1)) then --Open closed chest
            API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route1,{99820},50,WPOINT.new(3041,3364,0)) --Search opened chest
        end
        while API.Read_LoopyLoop() and not IsPlayerInArea(3040, 3364, 1, 2) do
            UTILS.randomSleep(300)
        end
    end,
    [3498] = function()
        API.DoAction_Inventory1(3498,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        MoveTo(3059, 3336, 0, 1)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{11745},50,WPOINT.new(3060,3334,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3059, 3334, 0, 1) do
            UTILS.randomSleep(300)
        end

    end,
    [3499] = function()
        API.DoAction_Inventory1(3499,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.TAVERLEY.Teleport()
        API.DoAction_Tile(WPOINT.new(2886,3450,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2886, 3450, 0) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear2(66875, 12, WPOINT.new(2886,3449,0))
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{66875},2,WPOINT.new(2886,3449,0))
    end,
    [3500] = function()
        API.DoAction_Inventory1(3500,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.TAVERLEY.Teleport()
        MoveTo(2894, 3415, 0, 2)
        WaitForObjectToAppear(66875, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{66875},50,WPOINT.new(2894,3418,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2894, 3417, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3501] = function()
        API.DoAction_Inventory1(3501,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3306, 3206, 0, 2)
        WaitForObjectToAppear(76811, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{76811},50,WPOINT.new(3308,3206,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3307, 3206, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)

    end,
    [3502] = function()
        API.DoAction_Inventory1(3502,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3108, 3350, 0, 1)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{47421},50,WPOINT.new(3108,3353,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3108, 3355, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
        API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{47364},50)
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(47574, 12)
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{47574},50,WPOINT.new(3105,3363,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(2) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(47560, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{47560},50,WPOINT.new(3106,3369,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3106, 3368, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3503] = function()
        API.DoAction_Inventory1(3503,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.BURTHOPE.Teleport()
        MoveTo(2911, 3530, 0, 0)
        WaitForObjectToAppear(66875, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{66875},50,WPOINT.new(2912,3530,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2911, 3530, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3504] = function()
        API.DoAction_Inventory1(3504,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory2({50558},0,1,API.OFF_ACT_GeneralInterface_route)
        while API.Read_LoopyLoop() and not IsPlayerInArea(2637, 3167, 0, 20) do
            UTILS.randomSleep(300)
        end
        MoveTo(2661, 3152, 0, 2)
        WaitForObjectToAppear(46270, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{46270},50,WPOINT.new(2660,3149,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2660, 3150, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [3505] = function()
        API.DoAction_Inventory1(3505,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2659, 3317, 0, 1)
        OpenDoor(34808, 2659, 3320, 34807)        
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{34498},50,WPOINT.new(2663,3321,0))
            UTILS.randomSleep(1000)
        end
        UTILS.randomSleep(1000)
        OpenDoor(34813, 2660, 3320, 34811)
        OpenDrawer(34483, 34482)
        while API.Read_LoopyLoop() and not IsPlayerInArea(2655, 3322, 1, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3506] = function()
        API.DoAction_Inventory1(3506,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2641, 3452, 0, 1)
        OpenDoor(48962, 2639, 3452, 48961)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{48998},50,WPOINT.new(2636,3453,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2637, 3453, 0) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [3507] = function()
        API.DoAction_Inventory1(3507,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.CATHERBY.Teleport()
        MoveTo(2827, 3447, 0, 2)
        if #API.GetAllObjArrayInteract({85010}, 50, {0}) > 0 then
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{85010},50,WPOINT.new(2829,3447,0)) -- Open door
            UTILS.randomSleep(3000)
        end
        OpenDrawer(25035, 25034)
        while API.Read_LoopyLoop() and IsPlayerInArea(2830, 3447, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [3508] = function()
        API.DoAction_Inventory1(3508,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2717, 3472, 0, 1)
        while API.Read_LoopyLoop() and #API.GetAllObjArray2({25819}, 50, {0}, WPOINT.new(2716, 3472, 0)) > 0 do
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25819},50,WPOINT.new(2716,3472,0))
            UTILS.randomSleep(1000)
        end
        API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{25938},50,WPOINT.new(2715,3470,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(1) do
            UTILS.randomSleep(300)            
        end
        WaitForObjectToAppear(25766, 12)
        OpenDrawer(25767, 25766)
        UTILS.randomSleep(2000)
    end,
    [3509] = function()
        API.DoAction_Inventory1(3509,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2701, 3477, 0, 0)
        OpenDoor(25820, 2701, 3476, 25819)
        API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{25775},50)
        while API.Read_LoopyLoop() and not IsPlayerInArea(2700, 3470, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [3510] = function()
        API.DoAction_Inventory1(3510,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(9469,0,3,API.OFF_ACT_GeneralInterface_route) -- Grand Seed Pod teleport
        WaitForObjectToAppear(69197, 12)
        UTILS.randomSleep(3000)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{69197},50,WPOINT.new(2465,3492,0))
        while API.Read_LoopyLoop() and API.PlayerCoord().y ~= 3491 do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
        MoveTo(2460, 3505, 0, 0)
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) --Dig spade
        UTILS.randomSleep(1000)
    end,
    [3512] = function()
        API.DoAction_Inventory1(3512,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3100, 3275, 0, 1)
        OpenDoor(1240, 3100, 3277, 1239)
        OpenDrawer(2651, 2631)
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3098, 3277, 0) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [3513] = function()
        API.DoAction_Inventory1(3513,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2741, 3554, 0, 1)
        OpenDoor(26132, 2741, 3556, 26130)
        MoveTo(2741, 3571, 0, 1)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25750},50,WPOINT.new(2741,3572,0))
        UTILS.randomSleep(4000)
        MoveTo(2736, 3580, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{25718},50,WPOINT.new(2735,3580,0))
        UTILS.randomSleep(2000)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{809},50)
        WaitForDialogThenPressSpacebar()
    end,
    [3514] = function()
        API.DoAction_Inventory1(3514,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        API.DoAction_WalkerW(WPOINT.new(3372 + math.random(-1, 1),3269 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3372, 3269, 0, 3) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(969, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{969},50)
        WaitForDialogThenPressSpacebar()
    end,
    [3515] = function()
        API.DoAction_Inventory1(3515,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        MoveTo(3217, 3492, 0, 0)
        OpenDoor(15535, 3218, 3492, 15536)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{46266},50,WPOINT.new(3224,3492,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3223, 3492, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)        
    end,
    [3516] = function()
        API.DoAction_Inventory1(3516,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        API.DoAction_Tile(WPOINT.new(2686 + math.random(-2, 2),3503 + math.random(-2, 2),0))
        UTILS.randomSleep(4000)
        SurgeIfFacing(360)
        API.DoAction_Tile(WPOINT.new(2663 + math.random(-5, 5),3515,0))
        UTILS.randomSleep(5000)
        SurgeIfFacing(270)
        UTILS.randomSleep(300)
        Dive(WPOINT.new(2633 + math.random(-5, 5),3511,0))
        API.DoAction_WalkerW(WPOINT.new(2612,3482,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2612,3482,0) do
            UTILS.randomSleep(1000)
        end
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) -- Dig spade
    end,
    [3518] = function()
        API.DoAction_Inventory1(3518,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(22332,0,3,API.OFF_ACT_GeneralInterface_route)
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(3) do
            UTILS.randomSleep(1000)
        end
        WaitForObjectToAppear(79776, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{79776},50)   
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(0) do
            UTILS.randomSleep(1000)
        end
        UTILS.randomSleep(1000)
        math.randomseed(os.time())
        local iterations = math.random(1, 5)
        for i = 1, iterations do
            API.DoAction_Tile(WPOINT.new(3104 + math.random(-2, 2),3130 + math.random(-2, 2),0))
            UTILS.randomSleep(750)
        end   
        while API.Read_LoopyLoop() and not API.PInArea21(3087, 3117, 3119, 3149) do
            UTILS.randomSleep(300)
        end     
        API.DoAction_Tile(WPOINT.new(3102,3134,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3102,3134,0) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Inventory1(952,0,1,API.OFF_ACT_GeneralInterface_route) -- Dig spade
    end,
    [7236] = function()
        API.DoAction_Inventory1(7236,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2970, 3414, 0) do
            API.DoAction_WalkerW(WPOINT.new(2970, 3414, 0))
            UTILS.randomSleep(3000)
        end
        API.DoAction_Inventory2({952},0,1,API.OFF_ACT_GeneralInterface_route) --Dig spade
    end,
    [7238] = function()
        API.DoAction_Inventory1(7238,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.CANIFIS.Teleport()
        MoveTo(3508, 3497, 0, 0)
        UTILS.randomSleep(1000)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{24911},50,WPOINT.new(3509,3497,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3508, 3498, 0, 1) do
            UTILS.randomSleep(300)
        end
    end,
    [10180] = function()
        API.DoAction_Inventory1(10180,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3200, 3169, 0, 1)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{118020},50,WPOINT.new(3201,3169,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3202, 3169, 0) do
            if DialogBoxOpen() then
                API.TypeOnkeyboard("2")
            end
            UTILS.randomSleep(1000)
        end
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110455},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1205) and not Inventory:Contains(1153) and not Inventory:Contains(1635) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1205, 1153, 1635)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,12,API.OFF_ACT_GeneralInterface_route) --Dance
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110454},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1205) and Equipment:Contains(1153) and Equipment:Contains(1635) do
            UTILS.randomSleep(300)
        end        
    end,
    [10182] = function()
        API.DoAction_Inventory1(10182,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(22332,0,3,API.OFF_ACT_GeneralInterface_route)
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(3) do
            UTILS.randomSleep(1000)
        end
        WaitForObjectToAppear(79776, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{79776},50)   
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(0) do
            UTILS.randomSleep(1000)
        end
        UTILS.randomSleep(1000)
        API.DoAction_WalkerW(WPOINT.new(3098,3189,0))
        WaitForObjectToAppear(110419, 0)
        UTILS.randomSleep(3000)
        SurgeIfFacing(360)
        API.DoAction_WalkerW(WPOINT.new(3098,3189,0))
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110419},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1059) and not Inventory:Contains(1137) and not Inventory:Contains(1639) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1059, 1137, 1639)
        API.DoAction_Tile(WPOINT.new(3103 + math.random(-1, 1),3193 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not API.PInArea21(3102, 3104, 3192, 3194) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,20,API.OFF_ACT_GeneralInterface_route) -- Clap emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110418},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1137) and Equipment:Contains(1059) and Equipment:Contains(163) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [10184] = function()
        API.DoAction_Inventory1(10184,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3078, 3247, 0, 0)
        WaitForObjectToAppear(110543, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110543},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1097) and not Inventory:Contains(1191) and not Inventory:Contains(45449) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1097, 1191, 45449)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,11,API.OFF_ACT_GeneralInterface_route) --Yawn emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110542},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1097) and Equipment:Contains(1191) and Equipment:Contains(45449) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [10186] = function()
        API.DoAction_Inventory1(10186,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(49429,0,7,API.OFF_ACT_GeneralInterface_route2)
        while API.Read_LoopyLoop() and not IsPlayerInArea(3336, 3378, 0, 3) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
        MoveTo(3324, 3467, 0, 2)
        MoveTo(3371, 3500, 0, 1)
        WaitForObjectToAppear(110487, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110487},50) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(45467) and not Inventory:Contains(1075) and not Inventory:Contains(45459) do
            UTILS.randomSleep(300)
        end
        EquipStuff(45467, 1075, 45459)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,18,API.OFF_ACT_GeneralInterface_route) --Panic emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110486},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(45467) and Equipment:Contains(1075) and Equipment:Contains(45459) do
            UTILS.randomSleep(300)
        end        
        UTILS.randomSleep(2000)
    end,
    [10188] = function()
        API.DoAction_Inventory1(10188,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        API.DoAction_WalkerW(WPOINT.new(2734 + math.random(-2, 2),3348 + math.random(-2, 2), 0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2734, 3348, 0, 5) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(110391, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110391},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(845) and not Inventory:Contains(1067) and not Inventory:Contains(1696) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(845)
        UTILS.randomSleep(300)
        Inventory:Equip(1067)
        UTILS.randomSleep(300)
        Inventory:Equip(1696)
        UTILS.randomSleep(300)

        while API.Read_LoopyLoop() and GetIdFromEquip(3) ~= 845 and GetIdFromEquip(6) ~= 1067 and GetIdFromEquip(2) ~= 1696 do
            UTILS.randomSleep(300)
        end

        API.DoAction_WalkerW(WPOINT.new(2728 + math.random(-1, 1),3348 + math.random(-1, 1), 0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2728, 3348, 0, 1) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,2,API.OFF_ACT_GeneralInterface_route) -- Bow emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()

        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110390},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(3) == 845 and GetIdFromEquip(6) == 1067 and GetIdFromEquip(2) == 1696 do
            UTILS.randomSleep(300)
        end
    end,
    [10190] = function()
        API.DoAction_Inventory1(10190,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3000, 3123, 0, 3)
        WaitForObjectToAppear(110527, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110527},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1635) and not Inventory:Contains(1095) and not Inventory:Contains(45443) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1635, 1095, 45443)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,5,API.OFF_ACT_GeneralInterface_route) --Wave Emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110526},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1635) and Equipment:Contains(1095) and Equipment:Contains(45443) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [10192] = function()
        LODESTONES.PORT_SARIM.Teleport()
        API.DoAction_WalkerW(WPOINT.new(3044 + math.random(-1, 1),3235 + math.random(-1, 1),0))
        WaitForObjectToAppear(110403, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110403},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1169) and not Inventory:Contains(45461) and not Inventory:Contains(1656) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(1169)
        UTILS.randomSleep(300)
        Inventory:Equip(45461)
        UTILS.randomSleep(300)
        Inventory:Equip(1656)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(0) ~= 1169 and GetIdFromEquip(6) ~= 45461 and GetIdFromEquip(2) ~= 1656 do
            UTILS.randomSleep(300)
        end
        API.DoAction_WalkerW(WPOINT.new(3046 + math.random(-1, 1),3235 + math.random(-1, 1),0))
        UTILS.randomSleep(2000)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,7,API.OFF_ACT_GeneralInterface_route) --Cheer emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110402},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(0) == 1169 and GetIdFromEquip(6) == 45461 and GetIdFromEquip(2) == 1656 do
            UTILS.randomSleep(300)
        end
    end,
    [10194] = function()
        LODESTONES.AL_KHARID.Teleport()
        API.DoAction_WalkerW(WPOINT.new(3301 + math.random(-4, 4),3277 + math.random(-4, 4),0))
        WaitForObjectToAppear(110459, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110459},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1059) and not Inventory:Contains(1061) and not Inventory:Contains(10065) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(1059)
        UTILS.randomSleep(300)
        Inventory:Equip(1061)
        UTILS.randomSleep(300)
        Inventory:Equip(10065)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(7) ~= 1059 and GetIdFromEquip(8) ~= 1061 and GetIdFromEquip(4) ~= 10065 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Tile(WPOINT.new(3298 + math.random(-1, 1),3282 + math.random(-1, 1),0))
        UTILS.randomSleep(1500)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,15,API.OFF_ACT_GeneralInterface_route) --Headbang
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110458},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(7) == 1059 and GetIdFromEquip(8) == 1061 and GetIdFromEquip(4) == 10065 do
            UTILS.randomSleep(300)
        end
    end,
    [10196] = function()
        API.DoAction_Inventory1(10196,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3091, 3336, 0, 0)
        WaitForObjectToAppear(110507, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110507},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1155) and not Inventory:Contains(1097) and not Inventory:Contains(1115) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1155, 1097, 1115)
        MoveTo(3090, 3335, 0, 0)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,14,API.OFF_ACT_GeneralInterface_route) --Twirl
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110506},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1155) and Equipment:Contains(1097) and Equipment:Contains(1115) do
            UTILS.randomSleep(300)
        end
    end,
    [10198] = function()
        API.DoAction_Inventory1(10198,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        MoveTo(3166, 3300, 0, 2)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110519},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1656) and not Inventory:Contains(10067) and not Inventory:Contains(843) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1656, 10067, 843)
        MoveTo(3165, 3295, 0, 0)
        while API.Read_LoopyLoop() and #API.GetAllObjArray2({45211}, 50, {0}, WPOINT.new(3165, 3295, 0)) < 1 do
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{45212},50,WPOINT.new(3164,3294,0))
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000) 
        MoveTo(3158, 3298, 0, 0)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,4,API.OFF_ACT_GeneralInterface_route) --Think Emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        MoveTo(3163, 3295, 0, 0)
        while API.Read_LoopyLoop() and #API.GetAllObjArray2({45211}, 50, {0}, WPOINT.new(3165, 3295, 0)) < 1 do
            API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{45212},50,WPOINT.new(3164,3294,0))
            UTILS.randomSleep(300)
        end
        MoveTo(3166, 3301, 0, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110518},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1656) and Equipment:Contains(10067) and Equipment:Contains(843) do
            UTILS.randomSleep(300)
        end
    end,
    [10200] = function()
        API.DoAction_Inventory1(10200,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.DRAYNOR_VILLAGE.Teleport()
        WaitForObjectToAppear(110443, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110443},50) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1101) and not Inventory:Contains(1637) and not Inventory:Contains(839) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1101, 1637, 839)
        MoveTo(3109, 3295, 0, 1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,12,API.OFF_ACT_GeneralInterface_route) --Dance emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110442},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1101) and Equipment:Contains(1637) and Equipment:Contains(839) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [10202] = function()
        API.DoAction_Inventory1(10202,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(2972, 3239, 0, 2)
        WaitForObjectToAppear(110495, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110495},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1654) and not Inventory:Contains(1635) and not Inventory:Contains(1237) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1654, 1635, 1237)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,6,API.OFF_ACT_GeneralInterface_route) --Shrug emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110494},50)
        while API.Read_LoopyLoop() and Equipment:Contains(1654) and Equipment:Contains(1635) and Equipment:Contains(1237) do
            UTILS.randomSleep(300)
        end
    end,
    [10204] = function()
        API.DoAction_Inventory1(10204,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.VARROCK.Teleport()
        API.DoAction_Tile(WPOINT.new(3211 + math.random(-1, 1),3390 + math.random(-1, 1),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(360)
        UTILS.randomSleep(300)
        API.DoAction_Tile(WPOINT.new(3211 + math.random(-1, 1),3414 + math.random(-1, 1),0))
        UTILS.randomSleep(7000)
        API.DoAction_Tile(WPOINT.new(3210 + math.random(-1, 1),3435 + math.random(-1, 1),0))
        UTILS.randomSleep(1000)
        SurgeIfFacing(360)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3213 + math.random(-1, 1),3454 + math.random(-1, 1),0))
        API.DoAction_WalkerW(WPOINT.new(3213 + math.random(-1, 1),3463 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3213, 3463, 0, 3) do
            UTILS.randomSleep(300)
        end
        SurgeIfFacing(360)
        UTILS.randomSleep(200)
        API.DoAction_WalkerW(WPOINT.new(3210, 3489, 0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3210, 3489, 0, 2) do
            UTILS.randomSleep(100)
        end    
        WaitForObjectToAppear2(15536, 12, WPOINT.new(3210, 3490, 0))
        local door = #API.GetAllObjArray2({15535}, 50, {0}, WPOINT.new(3210, 3489, 0))    
        if door == 0 then 
            API.DoAction_Object1(0x31,API.OFF_ACT_GeneralObject_route0,{15536},50) -- Open door
            while API.Read_LoopyLoop() and door == 0 do
                UTILS.randomSleep(100)
                door = #API.GetAllObjArray2({15535}, 50, {0}, WPOINT.new(3210, 3489, 0))
            end
        end    
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110531},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1718) and not Inventory:Contains(1063) and not Inventory:Contains(1335) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(1718)
        UTILS.randomSleep(300)
        Inventory:Equip(1063)
        UTILS.randomSleep(300)
        Inventory:Equip(1335)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(2) ~= 1718 and GetIdFromEquip(7) ~= 1063 and GetIdFromEquip(3) ~= 1335 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Tile(WPOINT.new(3213,3495,0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3213,3495,0) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,11,API.OFF_ACT_GeneralInterface_route) -- Yawn emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110530},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(2) == 1718 and GetIdFromEquip(7) == 1063 and GetIdFromEquip(3) == 1335 do
            UTILS.randomSleep(300)
        end
    end,
    [10206] = function()
        API.DoAction_Inventory1(10206,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2627, 3383, 0, 1)
        OpenDoor(45967, 2628, 3383, 45966)
        API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route1,{112414},50,WPOINT.new(2633,3386,0))
        while API.Read_LoopyLoop() and not IsPlayerAtZCoords(2) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(110415, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110415},50) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(5525) and not Inventory:Contains(10053) and not Inventory:Contains(1639) do
            UTILS.randomSleep(300)
        end
        EquipStuff(5525, 10053, 1639)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,20,API.OFF_ACT_GeneralInterface_route) --Clap emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110414},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(5525) and Equipment:Contains(10053) and Equipment:Contains(1639) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [10208] = function()
        API.DoAction_Inventory1(10208,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FALADOR.Teleport()
        API.DoAction_Tile(WPOINT.new(2982 + math.random(-2, 2),3375 + math.random(-2, 2),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(180)
        UTILS.randomSleep(200)
        Dive(WPOINT.new(3005, 3362, 0))
        API.DoAction_WalkerW(WPOINT.new(3022 + math.random(-1, 1),3362 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3022, 3362, 0, 5) do
            UTILS.randomSleep(300)
        end
        API.DoAction_WalkerW(WPOINT.new(3044 + math.random(-1, 1),3375 + math.random(-1, 1),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(90)
        UTILS.randomSleep(200)
        API.DoAction_WalkerW(WPOINT.new(3044 + math.random(-1, 1),3375 + math.random(-1, 1),0))
        WaitForObjectToAppear(110451, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110451},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(45485) and not Inventory:Contains(45462) and not Inventory:Contains(1081) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(45458)
        UTILS.randomSleep(300)
        Inventory:Equip(45462)
        UTILS.randomSleep(300)
        Inventory:Equip(1081)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(0) ~= 45458 and GetIdFromEquip(4) ~= 45462 and GetIdFromEquip(6) ~= 1081 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,12,API.OFF_ACT_GeneralInterface_route) --Dance emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110450},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(0) == 45458 and GetIdFromEquip(4) == 45462 and GetIdFromEquip(6) == 1081 do
            UTILS.randomSleep(300)
        end
    end,
    [10210] = function()
        API.DoAction_Inventory1(10210,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.TAVERLEY.Teleport()
        MoveTo(2921, 3476, 0, 3)
        WaitForObjectToAppear(110395, 0)
        API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{110395},50,WPOINT.new(2922,3476,0)) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(5527) and not Inventory:Contains(1307) and not Inventory:Contains(1692) do
            UTILS.randomSleep(300)
        end
        EquipStuff(5527, 1307, 1692)
        MoveTo(2921, 3479, 0, 1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,7,API.OFF_ACT_GeneralInterface_route) --Cheer emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110394},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(5527) and Equipment:Contains(1307) and Equipment:Contains(1692) do
            UTILS.randomSleep(300)
        end
    end,
    [10212] = function()
        API.DoAction_Inventory1(10212,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.BURTHOPE.Teleport()
        MoveTo(2896, 3566, 0, 1)
        API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{66973},50,WPOINT.new(2893,3570,0))
        while API.Read_LoopyLoop() and #API.GetAllObjArray1({66973}, 50, {12}) > 0 do
            if DialogBoxOpen() then
                API.TypeOnkeyboard("1")
            end
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(4629, 12)
        OpenDoor(4630, 2207, 4943, 4629)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{4629},50,WPOINT.new(2208,4946,0))
        UTILS.randomSleep(3000)
        MoveTo(2208, 4950, 0, 1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,7,API.OFF_ACT_GeneralInterface_route) --Cheer
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()

    end,
    [10214] = function()
        API.DoAction_Inventory1(10214,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.CATHERBY.Teleport()
        Dive(WPOINT.new(2798,3432,0))
        API.DoAction_Tile(WPOINT.new(2798 + math.random(-2, 2),3432 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2798, 3432, 0, 4) do
            UTILS.randomSleep(300)
        end
        API.DoAction_Tile(WPOINT.new(2764 + math.random(-2, 2),3443 + math.random(-2, 2),0))
        UTILS.randomSleep(2500)
        SurgeIfFacing(270)
        API.DoAction_Tile(WPOINT.new(2764 + math.random(-2, 2),3443 + math.random(-2, 2),0))
        UTILS.randomSleep(2500)
        SurgeIfFacing(270)
        API.DoAction_Tile(WPOINT.new(2764 + math.random(-1, 1),3445 + math.random(-1, 1),0))
        WaitForObjectToAppear(110463, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110463},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(4121) and not Inventory:Contains(1724) and not Inventory:Contains(1353) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(4121)
        UTILS.randomSleep(300)
        Inventory:Equip(1724)
        UTILS.randomSleep(300)
        Inventory:Equip(1353)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(8) ~= 4121 and GetIdFromEquip(2) ~= 1724 and GetIdFromEquip(3) ~= 1353 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,10,API.OFF_ACT_GeneralInterface_route) -- Jump for joy
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110462},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(8) == 4121 and GetIdFromEquip(2) == 1724 and GetIdFromEquip(3) == 1353 do
            UTILS.randomSleep(300)
        end
    end,
    [10216] = function()
        API.DoAction_Inventory1(10216,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        API.DoAction_Tile(WPOINT.new(2620 + math.random(-2, 2),3317 + math.random(-2, 2),0))
        UTILS.randomSleep(2000)
        SurgeIfFacing(180)
        UTILS.randomSleep(200)
        API.DoAction_Tile(WPOINT.new(2620 + math.random(-2, 2),3317 + math.random(-2, 2),0))
        UTILS.randomSleep(3000)
        SurgeIfFacing(270)
        API.DoAction_Tile(WPOINT.new(2597 + math.random(-2, 2),3280 + math.random(-2, 2),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(2597, 3280, 0, 5) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(110371, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110371},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1133) and not Inventory:Contains(1075) and not Inventory:Contains(7170) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(1133)
        UTILS.randomSleep(300)
        Inventory:Equip(1075)
        UTILS.randomSleep(300)
        Inventory:Equip(7170)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(4) ~= 1133 and GetIdFromEquip(6) ~= 1075 and GetIdFromEquip(3) ~= 7170 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,19,API.OFF_ACT_GeneralInterface_route) -- Raspberry emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110370},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(4) == 1133 and GetIdFromEquip(6) == 1075 and GetIdFromEquip(3) == 7170 do
            UTILS.randomSleep(300)
        end
    end,
    [10218] = function()
        API.DoAction_Inventory1(10218,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(2958, 3242, 0, 1)
        WaitForObjectToAppear(110503, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110503},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1637) and not Inventory:Contains(1095) and not Inventory:Contains(2466) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1637, 1095, 2466)
        MoveTo(2953, 3241, 0, 0)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,14,API.OFF_ACT_GeneralInterface_route) --Twirl emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110502},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1637) and Equipment:Contains(1095) and Equipment:Contains(2466) do
            UTILS.randomSleep(300)
        end        
    end,
    [10220] = function()
        API.DoAction_Inventory1(10220,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2619, 3385, 0, 2)
        WaitForObjectToAppear(110431, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110431},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1103) and not Inventory:Contains(1694) and not Inventory:Contains(1639) do
            UTILS.randomSleep(300)
        end
        MoveTo(2614, 3385, 0, 0)
        EquipStuff(1103, 1694, 1639)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,13,API.OFF_ACT_GeneralInterface_route) --Jig emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110430},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1103) and Equipment:Contains(1694) and Equipment:Contains(1639) do
            UTILS.randomSleep(300)
        end
    end,
    [10222] = function()
        API.DoAction_Inventory1(10222,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.ARDOUGNE.Teleport()
        MoveTo(2753,3403,0, 3)
        WaitForObjectToAppear(110379, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110379},50)
        while API.Read_LoopyLoop() and not Inventory:Contains(1115) and not Inventory:Contains(1169) and not Inventory:Contains(1059) do
            UTILS.randomSleep(300)
        end
        MoveTo(2761, 3401, 0, 1)
        EquipStuff(1115, 1169, 1059)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,19,API.OFF_ACT_GeneralInterface_route) -- Raspberry emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110378},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(4) == 1115 and GetIdFromEquip(0) == 1169 and GetIdFromEquip(7) == 1059 do
            UTILS.randomSleep(300)
        end
    end,
    [10224] = function()
        API.DoAction_Inventory1(10224,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(50558,0,1,API.OFF_ACT_GeneralInterface_route) --Khazard teleport
        while API.Read_LoopyLoop() and not IsPlayerInArea(2637, 3167, 0, 20) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(300)
        MoveTo(2676, 3166, 0, 1)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,18,API.OFF_ACT_GeneralInterface_route) --Panic emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
    end,
    [10226] = function()
        API.DoAction_Inventory1(10226,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.SEERS_VILLAGE.Teleport()
        MoveTo(2732, 3536, 0, 1)
        WaitForObjectToAppear(110475, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110475},50) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1167) and not Inventory:Contains(1725) and not Inventory:Contains(1323) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1167, 1725, 1323)
        MoveTo(2741, 3536, 0, 0)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,9,API.OFF_ACT_GeneralInterface_route) --Laugh emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110474},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1167) and Equipment:Contains(1725) and Equipment:Contains(1323) do
            UTILS.randomSleep(300)
        end
    end,
    [10228] = function()
        API.DoAction_Inventory1(10228,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        API.DoAction_Inventory1(49429,0,7,API.OFF_ACT_GeneralInterface_route2) --Archaeology journal teleport
        while API.Read_LoopyLoop() and not IsPlayerInArea(3336, 3378, 0, 3) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(3000)
        API.DoAction_WalkerW(WPOINT.new(3353 + math.random(-1, 1),3348 + math.random(-1, 1),0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3353, 3348, 0, 5) do
            UTILS.randomSleep(300)
        end
        WaitForObjectToAppear(110411, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110411},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1698) and not Inventory:Contains(2464) and not Inventory:Contains(1059) do
            UTILS.randomSleep(300)
        end
        Inventory:Equip(1698)
        UTILS.randomSleep(300)
        Inventory:Equip(2464)
        UTILS.randomSleep(300)
        Inventory:Equip(1059)
        UTILS.randomSleep(300)
        while API.Read_LoopyLoop() and GetIdFromEquip(2) ~= 1698 and GetIdFromEquip(3) ~= 2464 and GetIdFromEquip(7) ~= 1059 do
            UTILS.randomSleep(300)
        end
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,20,API.OFF_ACT_GeneralInterface_route) -- Clap emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110410},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(2) == 1698 and GetIdFromEquip(3) == 2464 and GetIdFromEquip(7) == 1059 do
            UTILS.randomSleep(300)
        end
    end,
    [10230] = function()
        API.DoAction_Inventory1(10230,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.FORT_FORINTHRY.Teleport()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110523},50) -- Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1351) and not Inventory:Contains(1095) and not Inventory:Contains(1131) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1351, 1095, 1131)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,16,API.OFF_ACT_GeneralInterface_route) -- Cry emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110522},50) -- Deposit items in hidey hole
        while API.Read_LoopyLoop() and GetIdFromEquip(3) == 1351 and GetIdFromEquip(6) == 1095 and GetIdFromEquip(4) == 1131 do
            UTILS.randomSleep(300)
        end
    end,
    [10232] = function()
        API.DoAction_Inventory1(10232,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3321, 3234, 0, 1)
        WaitForObjectToAppear(110387, 0)
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110387},50) --Take items from hidey hole
        while API.Read_LoopyLoop() and not Inventory:Contains(1169) and not Inventory:Contains(1095) and not Inventory:Contains(1101) do
            UTILS.randomSleep(300)
        end
        EquipStuff(1169, 1095, 1101)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,590,11,2,API.OFF_ACT_GeneralInterface_route) --Bow emote
        WaitForObjectToAppear(5141, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{5141},50) -- Talk to Uri
        WaitForDialogThenPressSpacebar()
        API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{110386},50) --Deposit items in hidey hole
        while API.Read_LoopyLoop() and Equipment:Contains(1169) and Equipment:Contains(1095) and Equipment:Contains(1101) do
            UTILS.randomSleep(300)
        end
    end,
    [33264] = function()
        API.DoAction_Inventory1(33264,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.PORT_SARIM.Teleport()
        MoveTo(3027, 3284, 0, 0)
        API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{85076},50,WPOINT.new(3024,3285,0))
        UTILS.randomSleep(2000)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{85101},50,WPOINT.new(3018,3287,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3019, 3287, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [33265] = function()
        API.DoAction_Inventory1(33265,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.LUMBRIDGE.Teleport()
        MoveTo(3192, 3260, 0, 2)
        WaitForObjectToAppear(79065, 12)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{79065},50,WPOINT.new(3191,3257,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3191, 3258, 0, 2) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
    [33266] = function()
        API.DoAction_Inventory1(33266,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.TAVERLEY.Teleport()
        MoveTo(2916, 3449, 0, 2)
        OpenDrawer(66623, 66624)
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2915, 3448, 0) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(1000)
    end,
    [33267] = function()
        API.DoAction_Inventory1(33267,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.BURTHOPE.Teleport()
        MoveTo(2893, 3530, 0, 3)
        WaitForObjectToAppear(15780, 1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{15780},50)
        WaitForDialogThenPressSpacebar()
    end,
    [33268] = function()
        API.DoAction_Inventory1(33268,0,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1000)
        LODESTONES.AL_KHARID.Teleport()
        MoveTo(3418, 3160, 0, 1)
        API.DoAction_Object2(0x38,API.OFF_ACT_GeneralObject_route0,{63760},50,WPOINT.new(3415,3158,0))
        while API.Read_LoopyLoop() and not IsPlayerInArea(3416, 3158, 0, 1) do
            UTILS.randomSleep(300)
        end
        UTILS.randomSleep(2000)
    end,
}

local function getClueStepId()
    local SlotData = Inventory:GetSlotData(0)
    if not SlotData then
        UpdateStatus("No item found in slot 0.")
        return nil
    end
    print("ItemID: ".. SlotData.id)
    -- Check if it's an unopened clue
    if (SlotData.id >= 19005 and SlotData.id <= 19038) or SlotData.id == 42006 then
        Tracking()
        local UnopenedClue = SlotData.id
        API.DoAction_Inventory1(UnopenedClue, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Open clue
        while API.Read_LoopyLoop() and SlotData.id == UnopenedClue do
            UTILS.randomSleep(300)
            SlotData = Inventory:GetSlotData(0)
            if not SlotData then
                print("SlotData became nil while waiting. Exiting.")
                API.Write_LoopyLoop(false)
                return nil
            end
        end
    end

    UpdateStatus("Solving step " .. SlotData.id)
    return SlotData.id
end

local clueStepId = 0

Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()
    ReqCheck()
    clueStepId = getClueStepId()
    if clueStepId == nil then
        ReasonForStopping = "No item found in first slot."
        API.Write_LoopyLoop(false)
        break
    end
    clueSteps[clueStepId]()
    UTILS.randomSleep(3000)
    collectgarbage("collect")
end

API.Write_LoopyLoop(false)
API.DrawTable(MetricsTable)
print("----------//----------")
print("Script Name: " .. ScriptName)
print("Author: " .. Author)
print("Version: " .. ScriptVersion)
print("Release Date: " .. ReleaseDate)
print("Discord: " .. DiscordHandle)
print("----------//----------")
print("Reason for Stopping: " .. ReasonForStopping)
