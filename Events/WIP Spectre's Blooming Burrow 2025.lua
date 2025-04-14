ScriptName = "Blooming Burrow Activities"
Author = "Spectre011"
ScriptVersion = "1.0"
ReleaseDate = "14-04-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 14-04-2025
    - Initial release.
]]

local API = require("api")
local UTILS = require("utils")

local stageID = 0
--------------------START GUI STUFF--------------------
local SelectedOption = nil
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

local function AddComboBox(name, text, options)
    ComboBox = API.CreateIG_answer()
    ComboBox.box_name = text
    ComboBox.stringsArr = options
    ComboBox.box_size = FFPOINT.new(400, 0, 0)
    UIComponents[GetComponentAmount() + 1] = {name, ComboBox, "ComboBox"}
end

local function AddCheckbox(name, text)
    CheckBox = API.CreateIG_answer()
    CheckBox.box_name = text
    UIComponents[GetComponentAmount() + 1] = {name, CheckBox, "CheckBox"}
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
    AddBackground("Background", 0.90, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("ActivityComboBoxLabel", "Select an activity:", ImColor.new(255, 255, 255))
    local options = {"- none - ", "Beekeeping", "Carrot Boating", "Chocolate Mining", "Smith Shiny Foil", "Hunt Chocolate Bunnies", "Egg Plant Production Line"}
    AddComboBox("ActivityComboBox", " ", options)
    AddLabel("Status", "Status: " .. CurrentStatus, ImColor.new(238, 230, 0))
end

local function SetComboBoxOption()
    SelectedOption = GetComponentValue("ActivityComboBox") or SelectedOption
    if SelectedOption == "- none - " then stageID = 0 end
    if SelectedOption == "Beekeeping" then stageID = 1 end
    if SelectedOption == "Carrot Boating" then stageID = 2 end
    if SelectedOption == "Chocolate Mining" then stageID = 3 end
    if SelectedOption == "Smith Shiny Foil" then stageID = 4 end
    if SelectedOption == "Hunt Chocolate Bunnies" then stageID = 5 end
    if SelectedOption == "Egg Plant Production Line" then stageID = 6 end
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

local IDS = {
    ["Beekeeping"] = {
        ["WiltedDaffodil"] = {132742, 132743, 132744},
        ["FlowerFoodSack"] = {132747},
        ["EnragedWasp"] = {31785},
        ["WaspTraps"] = {132746},
        ["PileOfSmokers"] = {132748},
        
    }
}
--Simple sleep
---@param seconds number
---@return boolean
local function Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
    return true
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

local function MoveTo(X, Y, Z, Tolerance)    
    while API.Read_LoopyLoop() and not IsPlayerInArea(X, Y, Z, Tolerance + 2) do
        if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then
            print("Not moving. Walking...")
            API.DoAction_WalkerW(WPOINT.new(X + math.random(-Tolerance, Tolerance),Y + math.random(-Tolerance, Tolerance),Z))
        end
        UTILS.randomSleep(300)
    end
    return true
end

local function QtittyWiltedDaffodil()
    return #API.GetAllObjArray1(IDS["Beekeeping"]["WiltedDaffodil"], 50, {0})
end

local function QtittyWasps()
    return #API.GetAllObjArray1(IDS["Beekeeping"]["EnragedWasp"], 50, {1})
end

local StageDescriptions = {
    [1] = "Beekeeping",
    [2] = "Carrot Boating",
    [3] = "Chocolate Mining",
    [4] = "Smith Shiny Foil",
    [5] = "Hunt Chocolate Bunnies",
    [6] = "Egg Plant Production Line"
}

local stageFunctions = {
    [1] = function()
        print("Stage 1: Beekeeping")
        UpdateStatus("Beekeeping")

        --Checks if player is tending to bees by looking for anim 36708
        local function IsTendingToBees()
            local t = os.time()
            while os.time() - t < 3 do 
                if API.ReadPlayerAnim() == 36708 then 
                    print("Tending to bees")
                    return true 
                end
                Sleep(0.5)
            end
            print("Not tending to bees")
            return false
        end

        if not API.PInArea21(3799, 3821, 4888, 4904) then
            UpdateStatus("Moving to Beekeeping area")
            print("Moving to Beekeeping area")
            MoveTo(3809, 4893, 0, 1)
        else
            print("Already in Beekeeping area")
            --Makes sure the player always have a smoker in inventory
            while API.Read_LoopyLoop() and Inventory:GetItemAmount(58736) < 1 do
                print("Picking up smoker")
                API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,IDS.Beekeeping.PileOfSmokers,50)
                API.RandomSleep2(3000, 300, 300)
                API.WaitUntilMovingEnds(20, 2)
            end

            --Handles wasps
            if QtittyWasps() > 0 then
                print("Handling wasps")
                while API.Read_LoopyLoop() and Inventory:GetItemAmount(58734) < 5 do
                    API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,IDS.Beekeeping.WaspTraps,50)
                    API.RandomSleep2(3000, 300, 300)
                    API.WaitUntilMovingEnds(20, 2)
                end
                Interact:NPC("Enraged wasp", "Trap", 50)
                API.RandomSleep2(3000, 300, 300)
                API.WaitUntilMovingEnds(20, 2)
            end

            --Handles feeding flowers
            if QtittyWiltedDaffodil() > 0 then
                print("Wilted Daffodils found. Feeding flowers")
                while API.Read_LoopyLoop() and Inventory:GetItemAmount(58735) < 5 do
                    print("Getting flower food")
                    API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,IDS.Beekeeping.FlowerFoodSack,50)
                    API.RandomSleep2(3000, 300, 300)
                    API.WaitUntilMovingEnds(20, 2)
                end
                while API.Read_LoopyLoop() and QtittyWiltedDaffodil() > 0 and Inventory:GetItemAmount(58735) > 0 do
                    print("Flower food available. Feeding flowers")
                    Interact:Object("Wilted daffodils", "Feed", 50)
                    API.RandomSleep2(3000, 300, 300)
                    API.WaitUntilMovingEnds(20, 2)
                end
            end

            --Handles tending to bees
            if not IsTendingToBees() then
                print("Interacting with Beehive")
                Interact:Object("Beehive", "Tend to", 50)
                API.RandomSleep2(3000, 300, 300)
                API.WaitUntilMovingEnds(20, 2)
            end
        end
    end,

    [2] = function()
        print("Stage 2: Carrot Boating")
        UpdateStatus("Carrot Boating")
    end,

    [3] = function()
        print("Stage 3: Chocolate Mining")
        UpdateStatus("Chocolate Mining")
    end,

    [4] = function()
        print("Stage 4: Smith Shiny Foil")
        UpdateStatus("Smith Shiny Foil")
    end,

    [5] = function()
        print("Stage 5: Hunt Chocolate Bunnies")
        UpdateStatus("Hunt Chocolate Bunnies")
    end,

    [6] = function()
        print("Stage 6: Egg Plant Production Line")
        UpdateStatus("Egg Plant Production Line")
    end
}

local function executeStage(stageID)
    if stageFunctions[stageID] then
        stageFunctions[stageID]()
    else
        print("Invalid stage ID: " .. tostring(stageID))
    end
end

API.Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    if not API.CacheEnabled then
        print("Cache not enabled. Exiting script.")
        API.Write_LoopyLoop(false)
        return
    end

    UTILS:antiIdle()
    SetComboBoxOption()
    if stageID ~= 0 then
        executeStage(stageID)
    end
    Sleep(0.5)

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
