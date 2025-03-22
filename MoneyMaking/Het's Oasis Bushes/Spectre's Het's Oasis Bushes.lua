ScriptName = "Het's Oasis Bushes"
Author = "Spectre011"
ScriptVersion = "1.0"
ReleaseDate = "22-03-2025"
Discord = "not_spectre011"

--[[
Changelog:
v1.0 - 22-03-2025
    - Initial release.
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
local currentFlowers = 0
local lastUpdateTime = os.time()
local updateFrequency = 0

local function formatRunTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function calcIncreasesPerHour()
    local runTimeInHours = (os.time() - startTime) / 3600
    if runTimeInHours > 0 then
        return counter / runTimeInHours
    else
        return 0
    end
end

local function calcAverageIncreaseTime()
    if counter > 0 then
        return (os.time() - startTime) / counter
    else
        return 0
    end
end

local function Tracking() -- This is what should be called at the end of every cycle
    counter = counter + 1
    local runTime = os.time() - startTime
    local increasesPerHour = calcIncreasesPerHour() 
    local avgIncreaseTime = calcAverageIncreaseTime() 

    MetricsTable[1] = {"Thanks for using my script!"}
    MetricsTable[2] = {" "}
    MetricsTable[3] = {"Total Run Time", formatRunTime(runTime)}
    MetricsTable[4] = {"Total flowers", tostring(counter)}
    MetricsTable[5] = {"Flowers per Hour", string.format("%.2f", increasesPerHour)}
    MetricsTable[6] = {"Average Flowers Time (s)", string.format("%.2f", avgIncreaseTime)}
    MetricsTable[7] = {"-----", "-----"}
    MetricsTable[8] = {"Script's Name:", ScriptName}
    MetricsTable[9] = {"Author:", Author}
    MetricsTable[10] = {"Version:", ScriptVersion}
    MetricsTable[11] = {"Release Date:", ReleaseDate}
    MetricsTable[12] = {"Discord:", Discord}    
end

--------------------END METRICS STUFF--------------------
local ActionNeeded = "None"
local ReasonForStopping = "User Action"
local BushToInteract = 0
local tick = API.Get_tick()
local IDS = {
    ["Rose"] = {
        122504, --Bare
        122505, --Budding
        122506, --Blooming
        122507  --Harvestable        
    },
    ["Iris"] = {
        122508, --Bare
        122509, --Budding
        122510, --Blooming
        122511  --Harvestable
    },
    ["Hydrangea"] = {
        122512, --Bare
        122513, --Budding
        122514, --Blooming
        122515  --Harvestable
    },
    ["Hollyhock"] = {
        122516, --Bare
        122517, --Budding
        122518, --Blooming
        122519  --Harvestable
    },
    ["Anomalies"] = {
        28671, --Scarab TYPE 1
        7620   --Gas TYPE 4
    },
    ["Flowers"] = {
        52807,  --Roses
        52808,  --Irises
        52809,  --Hydrangeas
        52810,  --Hollyhocks
        52811   --Golden roses
    }
}

local function ReqCheck()
    --Checks for the presence of bushes nearby
    local found = false
    for flowerType, ids in pairs(IDS) do
        for _, id in ipairs(ids) do
            local objects = API.GetAllObjArray1({id}, 10, {0})
            if #objects > 0 then
                print(string.format("Found ID %d (%s).", id, flowerType))
                BushToInteract = id
                found = true
                break
            end
        end
        if found then
            break
        end
    end
    if not found then
        print("No bushes found, exiting...")
        ReasonForStopping = "No bushes found"
        API.Write_LoopyLoop(false)
        return
    end
end

local function StateCheck()
    print("Game tick occurred, checking for action")

    if API.IsPlayerMoving_(API.GetLocalPlayerName()) then
        print("Player is moving. No action needed. Waiting...")
        ActionNeeded = "None"
        return
    end

    local scarabObjects = API.GetAllObjArray1({IDS["Anomalies"][1]}, 10, {1})
    if #scarabObjects > 0 then
        print("Scarab anomaly detected. Action needed: HandleScarab")
        ActionNeeded = "HandleScarab"
        return
    end

    local gasCloudObjects = API.GetAllObjArray1({IDS["Anomalies"][2]}, 10, {4})
    if #gasCloudObjects > 0 then
        print("Gas Cloud anomaly detected. Action needed: HandleGasCloud")
        ActionNeeded = "HandleGasCloud"
        return
    end

    -- Check player animation for 2 seconds
    local initialAnim = API.ReadPlayerAnim()
    print(string.format("Initial player animation: %d", initialAnim))
 
    local startTime2 = os.time()
    local animationChanged = false
 
    while os.time() - startTime2 < 2 do
        local currentAnim = API.ReadPlayerAnim()
        if currentAnim ~= initialAnim then
            animationChanged = true
            break
        end
        UTILS.randomSleep(100)
    end
 
    if not animationChanged and initialAnim ~= 13756 then
        print(string.format("Player animation (%d) did not change and does not match harvesting state (13756). Action needed: HarvestBush", initialAnim))
        ActionNeeded = "HarvestBush"
    else
        print("Player animation is harvesting or changed during the 2-second check. No action needed.")
        UpdateStatus("Harvesting bush")
        ActionNeeded = "None"
    end

    --Goback to this when the game stops crashing
    --[[
    local playerAnim = API.ReadPlayerAnim()
    if playerAnim ~= 13756 then
        print(string.format("Player animation (%d) does not match idle state (13756). Action needed: HarvestBush", playerAnim))
        ActionNeeded = "HarvestBush"
        return
    end

    print("No anomalies detected and player is idle. No action needed.")
    ActionNeeded = "None"
    ]]

    return
end

local function PopulateCurrentFlowers()
    for _, id in ipairs(IDS["Flowers"]) do
        currentFlowers = currentFlowers + Inventory:GetItemAmount(id)
    end
end

local function CheckFlowers()
    local FlowerSum = 0
    for _, id in ipairs(IDS["Flowers"]) do
        FlowerSum = FlowerSum + Inventory:GetItemAmount(id)
    end
    if FlowerSum > currentFlowers then
        Tracking()
        currentFlowers = FlowerSum
        print("Flower amount changed")
    else
        print("Flower amount did not change")
    end
end

local function HandleGasCloud()
    print("Handling gas cloud")
    UpdateStatus("Handling gas cloud")
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{BushToInteract},50)
    ActionNeeded = "None"
    UTILS.randomSleep(5000)
end

local function HandleScarab()
    print("Trying to shoo the Scarab")
    UpdateStatus("Handling scarab")
    API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route,{IDS["Anomalies"][1]},50)
    ActionNeeded = "None"
    UTILS.randomSleep(1000)
end

local function HarvestBush()
    print("Trying to harvest bush")
    UpdateStatus("Harvesting bush")
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{BushToInteract},50)
    ActionNeeded = "None"
    UTILS.randomSleep(5000)
end

Write_fake_mouse_do(false)
--TickEvent.Register(ReqCheck)
--TickEvent.Register(StateCheck)
--TickEvent.Register(CheckFlowers)
PopulateCurrentFlowers() --Populates currentFlowers with the amount that the playes has in inventory at the start of the script

while (API.Read_LoopyLoop()) do
    if tick ~= API.Get_tick() then
        print("Tick: "..tick)
        ReqCheck()
        StateCheck()
        CheckFlowers()
        if ActionNeeded == "HandleScarab" then
            HandleScarab()
        elseif ActionNeeded == "HandleGasCloud" then
            HandleGasCloud()
        elseif ActionNeeded == "HarvestBush" then
            HarvestBush()
        elseif ActionNeeded == "None" then
            print("Action needed is None. Skipping...") 
        else
            print("Something went wrong. Action needed: " .. ActionNeeded)        
        end
        tick = API.Get_tick()
        print("Memory usage: ", collectgarbage("count"), "KB")
        collectgarbage("collect")
        print("--------------------------------")
    end
    UTILS.randomSleep(100)
end

API.Write_LoopyLoop(false)

API.DrawTable(MetricsTable)
print("----------//----------")
print("Script Name: " .. ScriptName)
print("Author: " .. Author)
print("Version: " .. ScriptVersion)
print("Release Date: " .. ReleaseDate)
print("Discord: " .. Discord)
print("----------//----------")
print("Reason for stopping: " .. ReasonForStopping)
