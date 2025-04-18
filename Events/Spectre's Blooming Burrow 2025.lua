ScriptName = "Blooming Burrow Activities"
Author = "Spectre011"
ScriptVersion = "1.1.1"
ReleaseDate = "14-04-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0.0 - 14-04-2025
    - Initial release.
v1.1.0 - 18-04-2025
    - Added the Production Line activities
    - Added Cocoamancy activity
    - Removed the memory usage print from main loop
v1.1.1 - 18-04-2025
    - Increased GUI background as text was leaking
]]

local API = require("api")
local UTILS = require("utils")

local stageID = 0
local NeededTask = nil
local LastTask = "None"
local chatTexts = API.GatherEvents_chat_check()
local currentBurrow = nil
local rabbitsFound = false
local direction = false
local nextBurrowIndex = 0

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
    AddBackground("Background", 0.95, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("ActivityComboBoxLabel", "Select an activity:", ImColor.new(255, 255, 255))
    local options = {
        "- none - ", 
        "Beekeeping", 
        "Carrot Boating", 
        "Chocolate Mining", 
        "Smith Shiny Foil", 
        "Cocoamancy", 
        "Production Line - Mix",
        "Production Line - Mould",
        "Production Line - Foil",
    }
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
    if SelectedOption == "Cocoamancy" then stageID = 5 end
    if SelectedOption == "Production Line - Mix" then stageID = 6 end
    if SelectedOption == "Production Line - Mould" then stageID = 7 end
    if SelectedOption == "Production Line - Foil" then stageID = 8 end
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
        ["PileOfSmokers"] = {132748}        
    },
    ["CarrotBoating"] = {
        ["Coordinates"] = {
            {x = 3805, y = 4937, z = 0}, --Starting
            {x = 3788, y = 4935, z = 0}, --After pole
            {x = 3812, y = 4923, z = 0}, --After hoop
            {x = 3812, y = 4925, z = 0} -- After ramp
        }
    },
    ["SmithShinyFoil"] = {
        ["SoftMetalIngot"] = {56551},
        ["SoftenedMetalIngot"] = {56552},
        ["Foil"] = {56553}
    },
    ["Cocoamancy"] = {
        ["ChocolateRabbit"] = {56550},
        ["ChocolateBurrow"] = {129765},
        ["BurrowCoordinates"] = {
                [1] = { x = 3780, y = 4915, edges = { { index = 5, direction = "NE" }, { index = 10, direction = "SE" }, { index = 2, direction = "SW" }, { index = 2, direction = "W" }, { index = 9, direction = "E" }, { index = 3, direction = "N" } } },
                [2] = { x = 3767, y = 4909, edges = { { index = 3, direction = "N" }, { index = 1, direction = "NE" },{ index = 1, direction = "E" }, { index = 10, direction = "SE" } } },
                [3] = { x = 3770, y = 4956, edges = { { index = 1, direction = "S" }, { index = 5, direction = "E" }, { index = 9, direction = "SE" }, { index = 4, direction = "NW" }, { index = 4, direction = "N" } } },
                [4] = { x = 3755, y = 4976, edges = { { index = 5, direction = "E" }, { index = 3, direction = "SE" }, { index = 1, direction = "S" } } },
                [5] = { x = 3806, y = 4951, edges = { { index = 9, direction = "SE" }, { index = 10, direction = "S" }, { index = 1, direction = "SW" }, { index = 6, direction = "E" }, { index = 3, direction = "W" }, { index = 4, direction = "NW" } } },
                [6] = { x = 3831, y = 4958, edges = { { index = 1, direction = "SW" }, { index = 9, direction = "S" }, { index = 7, direction = "SE" }, { index = 7, direction = "E" }, { index = 5, direction = "W" } } },
                [7] = { x = 3834, y = 4954, edges = { { index = 1, direction = "SW" }, { index = 9, direction = "S" }, { index = 6, direction = "NW" }, { index = 6, direction = "N" },{ index = 5, direction = "W" } } },
                [8] = { x = 3829, y = 4917, edges = { { index = 7, direction = "N" }, { index = 10, direction = "SW" }, { index = 1, direction = "W" }, { index = 9, direction = "NW" } } },
                [9] = { x = 3822, y = 4924, edges = { { index = 8, direction = "SE" }, { index = 7, direction = "N" }, { index = 10, direction = "SW" }, { index = 5, direction = "NW" }, { index = 1, direction = "W" } } },
                [10] = { x = 3805, y = 4892, edges = { { index = 5, direction = "N" }, { index = 8, direction = "NE" }, { index = 1, direction = "NW" }, { index = 1, direction = "W" } } }
        }
    }
}


local function Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
    return true
end

local function IsPlayerAtCoords(x, y, z)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y and z == coord.z then
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

local function DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end

local StageDescriptions = {
    [1] = "Beekeeping",
    [2] = "Carrot Boating",
    [3] = "Chocolate Mining",
    [4] = "Smith Shiny Foil",
    [5] = "Cocoamancy",
    [6] = "Production Line - Mix",
    [7] = "Production Line - Mould",
    [8] = "Production Line - Foil"
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

        local function QtittyWiltedDaffodil()
            return #API.GetAllObjArray1(IDS["Beekeeping"]["WiltedDaffodil"], 50, {0})
        end
        
        local function QtittyWasps()
            return #API.GetAllObjArray1(IDS["Beekeeping"]["EnragedWasp"], 50, {1})
        end

        if not API.PInArea21(3799, 3821, 4888, 4904) then
            UpdateStatus("Moving to Beekeeping area")
            print("Moving to Beekeeping area")
            MoveTo(3809, 4893, 0, 1)
        else
            print("Already in Beekeeping area")
            --Makes sure the player always have a smoker in inventory
            while API.Read_LoopyLoop() and Inventory:GetItemAmount(58736) < 1 do
                UpdateStatus("Picking up smoker")
                print("Picking up smoker")
                API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,IDS.Beekeeping.PileOfSmokers,50)
                API.RandomSleep2(3000, 300, 300)
                API.WaitUntilMovingEnds(20, 2)
            end

            --Handles wasps
            if QtittyWasps() > 0 then
                print("Handling wasps")
                UpdateStatus("Handling wasps")
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
                UpdateStatus("Feeding flowers")
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
                UpdateStatus("Beekeeping")
                Interact:Object("Beehive", "Tend to", 50)
                API.RandomSleep2(3000, 300, 300)
                API.WaitUntilMovingEnds(20, 2)
            end
        end
    end,

    [2] = function()
        print("Stage 2: Carrot Boating")
        UpdateStatus("Carrot Boating")

        local function WhereAmI()
            if IsPlayerInArea(3802, 4945, 0, 2) then
                return "Not in boat"
            end
        
            if IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[1].x, IDS["CarrotBoating"].Coordinates[1].y, IDS["CarrotBoating"].Coordinates[1].z) then
                return "Starting"
            end
        
            if IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[2].x, IDS["CarrotBoating"].Coordinates[2].y, IDS["CarrotBoating"].Coordinates[2].z) then
                return "After pole"
            end
        
            if IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[3].x, IDS["CarrotBoating"].Coordinates[3].y, IDS["CarrotBoating"].Coordinates[3].z) then
                return "After hoop"
            end
        
            if IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[4].x, IDS["CarrotBoating"].Coordinates[4].y, IDS["CarrotBoating"].Coordinates[4].z) then
                return "After ramp"
            end

            return "idk"
        end

        if WhereAmI() == "idk" then
            UpdateStatus("Moving to Carrot Boating area")
            print("Moving to Carrot Boating area")
            MoveTo(3802, 4945, 0, 1)
        elseif WhereAmI() == "Not in boat" then
            UpdateStatus("Renting boat")
            print("Renting boat")
            Interact:Object("Boat rental", "Rent boat", 10)
            UTILS.randomSleep(1000)
            if DialogBoxOpen() then
                API.KeyboardPress2(0x31, 40, 60)
                UTILS.randomSleep(5000)
            end
        elseif WhereAmI() == "Starting" then
            UpdateStatus("Crossing slalom poles")
            print("Crossing slalom poles")
            Interact:Object("Slalom poles", "Navigate", 10)
            while API.Read_LoopyLoop() and not IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[2].x, IDS["CarrotBoating"].Coordinates[2].y, IDS["CarrotBoating"].Coordinates[2].z) do
                UTILS.randomSleep(100)
            end
        elseif WhereAmI() == "After pole" then
            UpdateStatus("Jumping hoop")
            print("Jumping hoop")
            Interact:Object("Hoop", "Jump through", 30)
            while API.Read_LoopyLoop() and not IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[3].x, IDS["CarrotBoating"].Coordinates[3].y, IDS["CarrotBoating"].Coordinates[3].z) do
                UTILS.randomSleep(100)
            end
        elseif WhereAmI() == "After hoop" then
            UpdateStatus("Drifting ramp")
            print("Drifting ramp")
            Interact:Object("Ramp", "Drift in", 30)
            while API.Read_LoopyLoop() and not IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[4].x, IDS["CarrotBoating"].Coordinates[4].y, IDS["CarrotBoating"].Coordinates[4].z) do
                UTILS.randomSleep(100)
            end
        elseif WhereAmI() == "After ramp" then
            UpdateStatus("Crossing slalom poles")
            print("Crossing slalom poles")
            Interact:Object("Slalom poles", "Navigate", 40)
            while API.Read_LoopyLoop() and not IsPlayerAtCoords(IDS["CarrotBoating"].Coordinates[2].x, IDS["CarrotBoating"].Coordinates[2].y, IDS["CarrotBoating"].Coordinates[2].z) do
                UTILS.randomSleep(100)
            end
        else
            print("Something went wrong#########################")
            API.Write_LoopyLoop(false)
        end
    end,

    [3] = function()
        print("Stage 3: Chocolate Mining")
        UpdateStatus("Chocolate Mining")

        if not API.PInArea21(3755, 3766, 4914, 4923) then
            UpdateStatus("Moving to Chocolate Mining area")
            print("Moving to Chocolate Mining area")
            MoveTo(3762, 4917, 0, 1)
        else
            print("Already in Chocolate Mining area")
            if Inventory:IsFull() then
                print("Inventory is full. Depositing...")
                UpdateStatus("Depositing chocolate")
                Interact:Object("Chocolate mine shaft", "Deposit", 20)
                while API.Read_LoopyLoop() and Inventory:IsFull() do
                    UTILS.randomSleep(100)
                end
            else
                print("Mining chocolate...")
                UpdateStatus("Mining chocolate")
                if not API.IsPlayerAnimating_(API.GetLocalPlayerName(), 3) then
                    Interact:Object("Chocolate rock", "Mine", 20)
                    API.RandomSleep2(3000, 300, 300)
                    API.WaitUntilMovingEnds(20, 2)
                end
            end
        end
    end,

    [4] = function()
        print("Stage 4: Smith Shiny Foil")
        UpdateStatus("Smith Shiny Foil")

        if not API.PInArea21(3738, 3742, 4940, 4945) then
            UpdateStatus("Moving to Smith Shiny Foil area")
            print("Moving to Smith Shiny Foil area")
            MoveTo(3740, 4943, 0, 1)
        else
            print("Already in Smith Shiny Foil area")
            if not Inventory:IsFull() then
                print("Taking soft metal ingots")
                UpdateStatus("Taking soft metal ingots")
                Interact:Object("Soft metal forge", "Take all from", 20)
                while API.Read_LoopyLoop() and not Inventory:IsFull() do
                    UTILS.randomSleep(100)
                end
            end
            if Inventory:Contains(IDS.SmithShinyFoil.SoftMetalIngot) or Inventory:Contains(IDS.SmithShinyFoil.SoftenedMetalIngot) then
                print("Smithing shiny foil...")
                UpdateStatus("Smithing shiny foil")
                if not API.IsPlayerAnimating_(API.GetLocalPlayerName(), 30) then
                    print("Interacting with anvil")
                    Interact:Object("Soft metal anvil", "Flatten", 20)
                    API.RandomSleep2(3000, 300, 300)
                end
            elseif Inventory:Contains(IDS.SmithShinyFoil.Foil) then
                print("Depositing foil")
                UpdateStatus("Depositing foil")
                Interact:Object("Foil storage", "Deposit", 20)
                while API.Read_LoopyLoop() and Inventory:Contains(IDS.SmithShinyFoil.Foil) do
                    UTILS.randomSleep(100)
                end
            else
                print("Something went wrong@@@@@@@@@@@@@@@@@@@@@")
                API.Write_LoopyLoop(false)
            end
        end

    end,

    [5] = function()
        print("Stage 5: Cocoamancy")
        UpdateStatus("Cocoamancy")
    
        local function CheckBurrowAndGetDirection(target)
            print(string.format("[CheckBurrowAndGetDirection] Checking burrow at (%d, %d)", target.x, target.y))
            API.DoAction_Object2(0x29, API.OFF_ACT_GeneralObject_route1, IDS.Cocoamancy.ChocolateBurrow, 50, WPOINT.new(target.x, target.y, 0))
            UTILS.randomSleep(2000)
            local messages = API.GatherEvents_chat_check()
            local direction = nil
            for i, message in ipairs(messages) do
                print(string.format("[Chat Message] %s", message.text))
                if string.find(message.text, "some activity in this burrow") then
                    print("[CheckBurrowAndGetDirection] Rabbits found in burrow!")
                    return true
                elseif string.find(message.text, " north%.") then
                    direction = "N"
                elseif string.find(message.text, " east%.") then
                    direction = "E"
                elseif string.find(message.text, " south%.") then
                    direction = "S"
                elseif string.find(message.text, " west%.") then
                    direction = "W"
                elseif string.find(message.text, " north%-east%.") then
                    direction = "NE"
                elseif string.find(message.text, " south%-east%.") then
                    direction = "SE"
                elseif string.find(message.text, " south%-west%.") then
                    direction = "SW"
                elseif string.find(message.text, " north%-west.") then
                    direction = "NW"
                end
            end
            print(string.format("[CheckBurrowAndGetDirection] No rabbits found. Direction: %s", direction or "nil"))
            return false, direction
        end
    
        local function findNextBurrowIndex(edges, direction)
            print(string.format("[findNextBurrowIndex] Looking for direction: %s", direction))
            for _, edge in ipairs(edges) do
                print(string.format(" - Checking edge: index=%d, direction=%s", edge.index, edge.direction))
                if edge.direction == direction then
                    print(string.format("[findNextBurrowIndex] Found index: %d", edge.index))
                    return edge.index
                end
            end
            print("[findNextBurrowIndex] Direction not found in edges.")
            return nil
        end
    
        if currentBurrow == nil then
            print("[Main] currentBurrow is nil, defaulting to first coordinate")
            currentBurrow = IDS.Cocoamancy.BurrowCoordinates[1]
        end      
    
        if API.IsPlayerAnimating_(API.GetLocalPlayerName(), 3) or API.IsPlayerMoving_(API.GetLocalPlayerName()) then
            print("[Main] Player is animating or moving. Sleeping...")
            UTILS.randomSleep(1000)
        else
            if Inventory:IsFull() then
                print("[Main] Inventory is full. Handing in to Fizzy Bunny...")
                MoveTo(3784, 4905, 0, 1)
                Interact:NPC("Fizzy Bunny", "Hand in", 10)
                API.WaitUntilMovingEnds(20, 2)
            end
    
            print(string.format("[Main] Moving to burrow at (%d, %d)", currentBurrow.x, currentBurrow.y))
            MoveTo(currentBurrow.x, currentBurrow.y, 0, 1)
            rabbitsFound, direction = CheckBurrowAndGetDirection(currentBurrow)
    
            if rabbitsFound then
                print("[Main] Digging burrow...")
                API.DoAction_Object2(0x38, API.OFF_ACT_GeneralObject_route0, IDS.Cocoamancy.ChocolateBurrow, 50, WPOINT.new(currentBurrow.x, currentBurrow.y, 0))
                API.RandomSleep2(3000, 1000, 1000)
                API.WaitUntilMovingEnds(20, 2)
                while API.Read_LoopyLoop() and API.IsPlayerAnimating_(API.GetLocalPlayerName(), 30) do
                    print("[Main] Player is digging. Waiting...")
                    API.RandomSleep2(1500, 1000, 1000)
                    API.WaitUntilMovingEnds(20, 2)
                end
                print("[Main] Finished digging.")
            end
    
            if direction then
                print(string.format("[Main] Direction to next burrow: %s", direction))
                nextBurrowIndex = findNextBurrowIndex(currentBurrow.edges, direction)
                if nextBurrowIndex then
                    print(string.format("[Main] Moving to next burrow at index %d", nextBurrowIndex))
                    MoveTo(IDS.Cocoamancy.BurrowCoordinates[nextBurrowIndex].x, IDS.Cocoamancy.BurrowCoordinates[nextBurrowIndex].y, 0, 1)
                    currentBurrow = IDS.Cocoamancy.BurrowCoordinates[nextBurrowIndex]
                else
                    print("[Main] Could not find valid next burrow index.")
                end
            else
                print("[Main] No direction received from burrow.")
                local randomIndex = math.random(1, 10)
                currentBurrow = IDS.Cocoamancy.BurrowCoordinates[randomIndex]                
            end
        end
    end,    

    [6] = function()
        print("Stage 6: Production Line - Mix")
        UpdateStatus("Production Line - Mix")

        local function checkChatMixing()
            chatTexts = API.GatherEvents_chat_check()
            if chatTexts then 
                for _, message in pairs(chatTexts) do
                    if string.find(message.text, "Stewy") then
                        if string.find(message.text, "fruit") then
                            print("Found Message: Fruiting and nutting")
                            NeededTask = "Fruiting and Nutting"
                        elseif string.find(message.text, "banoffee") then
                            print("Found Message: Banoffee")
                            NeededTask = "Banoffee"
                        elseif string.find(message.text, "rocky") then
                            print("Found Message: Rocky road")
                            NeededTask = "Rocky Road"
                        else 
                            NeededTask = "None"
                        end
                    end
                end
            else
                NeededTask = "None"
            end
        end        

        if not IsPlayerAtCoords(3751, 4942, 0) then
            UpdateStatus("Moving to Mixing Station")
            print("Moving to Mixing Station")
            if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then
                API.DoAction_WalkerW(WPOINT.new(3751, 4942, 0))
                UTILS.randomSleep(1000)
            end
        else
            if NeededTask == nil then
                Interact:Object("Mixing station", "Mix fruit & nut", 2)
                LastTask = "Fruiting and Nutting"
                NeededTask = "None"
            elseif NeededTask == "Fruiting and Nutting" and LastTask ~= "Fruiting and Nutting" then
                Interact:Object("Mixing station", "Mix fruit & nut", 2)
                LastTask = "Fruiting and Nutting"
                NeededTask = "None"
            elseif NeededTask == "Banoffee" and LastTask ~= "Banoffee" then
                Interact:Object("Mixing station", "Mix banoffee", 2)
                LastTask = "Banoffee"
                NeededTask = "None"
            elseif NeededTask == "Rocky Road" and LastTask ~= "Rocky Road" then
                Interact:Object("Mixing station", "Mix rocky road", 2)
                LastTask = "Rocky Road"
                NeededTask = "None"
            elseif NeededTask == "None" then
                print("No task found")
            end
            checkChatMixing()
        end 
    end,

    [7] = function()
        print("Stage 6: Production Line - Mould")
        UpdateStatus("Production Line - Mould")

        local function checkChatMoulding()
            chatTexts = API.GatherEvents_chat_check()
            if chatTexts then 
                for _, message in pairs(chatTexts) do
                    if string.find(message.text, "Gooey") then
                        if string.find(message.text, "eggs") then
                            print("Found Message: Eggs")
                            NeededTask = "Eggs"
                        elseif string.find(message.text, "bars") then
                            print("Found Message: Bars")
                            NeededTask = "Bars"
                        elseif string.find(message.text, "bunnies") then
                            print("Found Message: Bunnies")
                            NeededTask = "Bunnies"
                        else 
                            NeededTask = "None"
                        end
                    end
                end
            else
                NeededTask = "None"
            end
        end        

        if not IsPlayerAtCoords(3751, 4946, 0) then
            UpdateStatus("Moving to Moulding Station")
            print("Moving to Moulding Station")
            if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then
                API.DoAction_WalkerW(WPOINT.new(3751, 4946, 0))
                UTILS.randomSleep(1000)
            end
        else
            if NeededTask == nil then
                Interact:Object("Moulding station", "Mould egg", 2)
                LastTask = "Eggs"
                NeededTask = "None"
            elseif NeededTask == "Eggs" and LastTask ~= "Eggs" then
                Interact:Object("Moulding station", "Mould egg", 2)
                LastTask = "Eggs"
                NeededTask = "None"
            elseif NeededTask == "Bars" and LastTask ~= "Bars" then
                Interact:Object("Moulding station", "Mould bar", 2)
                LastTask = "Bars"
                NeededTask = "None"
            elseif NeededTask == "Bunnies" and LastTask ~= "Bunnies" then
                Interact:Object("Moulding station", "Mould bunny", 2)
                LastTask = "Bunnies"
                NeededTask = "None"
            elseif NeededTask == "None" then
                print("No task found")
            end
            checkChatMoulding()
        end 
    end,

    [8] = function()
        print("Stage 6: Production Line - Foil")
        UpdateStatus("Production Line - Foil")

        local function checkChatFoiling()
            chatTexts = API.GatherEvents_chat_check()
            if chatTexts then 
                for _, message in pairs(chatTexts) do
                    if string.find(message.text, "Chewy") then
                        if string.find(message.text, "pink") then
                            print("Found Message: Pink")
                            NeededTask = "Pink"
                        elseif string.find(message.text, "blue") then
                            print("Found Message: Blue")
                            NeededTask = "Blue"
                        elseif string.find(message.text, "yellow") then
                            print("Found Message: Yellow")
                            NeededTask = "Yellow"
                        else 
                            NeededTask = "None"
                        end
                    end
                end
            else
                NeededTask = "None"
            end
        end        

        if not IsPlayerAtCoords(3751, 4950, 0) then
            UpdateStatus("Moving to Foiling Station")
            print("Moving to Foiling Station")
            if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then
                API.DoAction_WalkerW(WPOINT.new(3751, 4950, 0))
                UTILS.randomSleep(1000)
            end
        else
            if NeededTask == nil then
                Interact:Object("Foiling station", "Foil pink", 2)
                LastTask = "Pink"
                NeededTask = "None"
            elseif NeededTask == "Pink" and LastTask ~= "Pink" then
                Interact:Object("Foiling station", "Foil pink", 2)
                LastTask = "Pink"
                NeededTask = "None"
            elseif NeededTask == "Blue" and LastTask ~= "Blue" then
                Interact:Object("Foiling station", "Foil blue", 2)
                LastTask = "Blue"
                NeededTask = "None"
            elseif NeededTask == "Yellow" and LastTask ~= "Yellow" then
                Interact:Object("Foiling station", "Foil yellow", 2)
                LastTask = "Yellow"
                NeededTask = "None"
            elseif NeededTask == "None" then
                print("No task found")
            end
            checkChatFoiling()
        end 
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
