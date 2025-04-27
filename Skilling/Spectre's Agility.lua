ScriptName = "AIO Agility"
Author = "Spectre011"
ScriptVersion = "2.2.1"
ReleaseDate = "06-09-2024"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0 - 06-09-2024
    - Initial release.
v1.1 - 07-09-2024
    - Included support to silverhawk boots
    - Fixed an issue where teleporting from the Wilderness course would make so that the script can't stop
v1.2 - 12-09-2024
    - Fixed an issue where the character would get stuck on one side of the bridge in Circuit 1 (Nature Grotto)
    - Fixed an issue where the character would get stuck on one side of the rope swing in Circuit 4 (Wilderness)
    - Character will now eat food if HP is low before starting Circuit 4 (Wilderness)
    - Character will now load the last preset if the inventory is full after completing Circuit 6 (Hefin)
v1.3 - 29-09-2024
    - Added a UI to select the course, removing the need to modify the script
    - Added a console message that links to the starting position for the courses
v1.4 - 09-11-2024
    - Changed UI to standardize with my other scritps
    - Doubled the timeout for crossObstacle() function
    - Added a loop check for crossObstacle() and sleepUntilFacing() functions
    - Added debug prints to Southern Anachronia course
v1.5 - 09-11-2024
    - Added garbage collection every cycle
    - Changed initial state of fellIntoTheHole variable for wildy course
v1.6 - 04-01-2025
    - Fixed the dive function that broke with API update
    - Reduced sleep in crossObstacle() function from 1000ms to 500ms
v1.7 - 25-01-2025
    - Refactored Wildy circuit to work when multiple people are using the circuit, repeat failed obstacles and properly exit the hole
    - Added surges to Het's Oasis circuit
    - Fixed a bug in crossObstacle()
    - Added antecipation before 2 obstacles in Advanced Anachronia circuit where the player can get stunnned by dinossaurs, if in ability bar
    - Added advanced gnome stronghold circuit
    - Added advanced barbarian outpost circuit
    - Changes in UI to remove confusing checkbox and add obstacle ID label
v1.8 - 25-01-2025
    - The script now correctly updates the obstacle ID label when using the Hefin course
    - Changed the hefin banking function to deposit all items instead of loading last preset to prevent getting stuck when you get lamps and stars
v1.9 - 01-02-2025
    - Changed the anachronia CrossObstacle functino to CrossObstacleAnac with added debug prints
    - Added a 150ms sleep to dives and surges
    - Added WaitForObjectToAppear function before trying to interact with advanced anachronia obstacles
v1.10 - 05-02-2025
    - Fixed a bug with the Northern Anachronia circuit where the script would not sleep enough for the cave animation before proceeding to the next last_obstacle_id
    - Added a AnacResources() function to check for compacted resources
    - Added xp meter
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
v2.1.0 - 27-04-2025
    - Fixed typo in write fakemouse false function
    - Fixed Obstacle ID status in UI for wildy course
    - Added an extended anim check after each obstacle in wildy course
    - Removed print memory usage from main loop
v2.2.0 - 27-04-2025
    - Changed logic for wildy course
v2.2.1 - 27-04-2025
    - Decreased anim check interval for wildy course

Move to the starting location of the circuit and set the course]]

local API = require("api")
local UTILS = require("utils")

local courseID = 0
--------------------START GUI STUFF--------------------
local selectedOption = nil
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
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " - " .. Author, ImColor.new(238, 230, 0))
    AddLabel("CourseSelect", "Select a course:", ImColor.new(255, 255, 255))
    local options = {"- none -","1-30 Nature Grotto's bridge", "30-50 Northern Anachronia", "50-52 Southern Anachronia", "52-65 Wilderness","65-77 Het's Oasis", "77-85 Hefin", "85-99+ Advanced Anachronia", "Advanced Gnome Stronghold", "Advanced Barbarian Outpost"}
    AddComboBox("CourseToRun", " ", options)
    AddLabel("Status", "Obstacle ID: 0", ImColor.new(238, 230, 0))
end

local function UpdateStatus(newStatus)
    CurrentStatus = newStatus
    local statusLabel = GetComponentByName("Status")
    if statusLabel then
        statusLabel[2].string_value = "Obstacle ID: " .. CurrentStatus
    end
end

local function SetCourse()
    selectedOption = GetComponentValue("CourseToRun") or selectedOption
    if selectedOption == "- none -" then courseID = 0 end
    if selectedOption == "1-30 Nature Grotto's bridge" then courseID = 1 end
    if selectedOption == "30-50 Northern Anachronia" then courseID = 2 end
    if selectedOption == "50-52 Southern Anachronia" then courseID = 3 end
    if selectedOption == "52-65 Wilderness" then courseID = 4 end
    if selectedOption == "65-77 Het's Oasis" then courseID = 5 end
    if selectedOption == "77-85 Hefin" then courseID = 6 end
    if selectedOption == "85-99+ Advanced Anachronia" then courseID = 7 end
    if selectedOption == "Advanced Gnome Stronghold" then courseID = 8 end
    if selectedOption == "Advanced Barbarian Outpost" then courseID = 9 end
end

CreateGUI()
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

local courseDescriptions = {
    [1] = "1-30 Jumping the bridge outside the Nature Grotto", -- Starting location https://imgur.com/a/Lj06Ook
    [2] = "30-50 Northern Anachronia Agility Course", -- Starting location https://imgur.com/a/kq80Zi2
    [3] = "50-52 Southern Anachronia Agility Course", -- Starting location https://imgur.com/a/giFrpEL
    [4] = "52-65 Wilderness Agility Course", -- Starting location https://imgur.com/a/43kKbVV
    [5] = "65-77 Het's Oasis Agility Course", -- Starting location https://imgur.com/a/hf1tboY
    [6] = "77-85 Hefin Agility Course", -- Starting location https://imgur.com/a/17zAd9a
    [7] = "85-99+ Advanced Anachronia Agility Course", -- Starting location https://imgur.com/a/qfrsup3
    [8] = "Advanced Gnome Stronghold", -- Starting location https://imgur.com/a/lc6JMk5
    [9] = "Advanced Barbarian Outpost" --Starting location https://imgur.com/a/0tPR0Zf
}

local function WaitForObjectToAppear(ObjID, ObjType)
    print("Starting WaitForObjectToAppear with ObjID:", ObjID, "ObjType:", ObjType)    
    while API.Read_LoopyLoop() do
        print("Checking for objects with ID:", ObjID, "Type:", ObjType)
        local objects = API.GetAllObjArray1({ObjID}, 75, {ObjType})
        if objects then
            print("Found", #objects, "objects in the area.")
            if #objects > 0 then
                for _, object in ipairs(objects) do
                    local id = object.Id or 0
                    local objType = object.Type or 0
                    print("Checking object - ID:", id, "Type:", objType)
                    
                    if id == ObjID and objType == ObjType then
                        print("Target object found! Returning from function.")
                        return
                    end
                end
            else
                print("Objects table is empty.")
            end
        else
            print("No objects found (nil result).")
        end        
        print("Waiting for object to appear...")
        UTILS.randomSleep(100)
    end    
    print("Exiting WaitForObjectToAppear (Loop ended)")
    return true
end


local function isPlayerAtCoords(x, y)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y then
        return true
    else
        return false
    end
end

local function crossObstacle(id, destX, destY)
    UpdateStatus(id)
    if API.Read_LoopyLoop() then  

        print("ID: ", id)
        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {id}, 50)    
        local maxRetries = 40
        local retries = 0
        while API.Read_LoopyLoop() and not isPlayerAtCoords(destX, destY) and 
            API.ReadPlayerAnim() ~= "-1" and API.ReadPlayerAnim() ~= "0" and retries < maxRetries do
            UTILS.randomSleep(500)
            retries = retries + 1
        end
        if retries >= maxRetries then
            print("Timeout. Passing through.")
        end
        UTILS.randomSleep(500)
    end
end

local function RechargeSilverhawkBoots(minQuantity)
    local item = API.Container_Get_s(94,30924)
    if item.item_id == 30924 then
        if item.Extra_ints[2] < minQuantity then
            local silverhawkFeather = API.CheckInvStuff0(30915)
            local silverhawkDown = API.CheckInvStuff0(34823)
            if silverhawkFeather ~= false then
                API.DoAction_Inventory1(30915,0,1,API.OFF_ACT_GeneralInterface_route)
                return
            elseif silverhawkDown ~= false then
                API.DoAction_Inventory1(34823,0,1,API.OFF_ACT_GeneralInterface_route)
                return
            end
        end
    end
end

local function Surge()
    if API.Read_LoopyLoop() then
        local surgeAB = UTILS.getSkillOnBar("Surge")
        if surgeAB ~= nil then
            API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
            UTILS.randomSleep(150)
        end
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

local function AnacResources()
    if API.Read_LoopyLoop() then
        print("Checking for Anac Resources...")
        if Inventory:ContainsAny({47932, 47933, 47934, 47935, 47936, 47937}) then
            print("Anac Resources found.")
        end    
        while API.Read_LoopyLoop() and Inventory:ContainsAny({47932, 47933, 47934, 47935, 47936, 47937}) do
            API.DoAction_Inventory2({47932, 47933, 47934, 47935, 47936, 47937}, 0, 1, API.OFF_ACT_GeneralInterface_route)
            UTILS.randomSleep(500)
        end
    end
end

local playerInCorrectArea = nil
local currentWildernessObstacle = 1
local advancedGnomeObstacle = 1
local advancedBarbarianObstacle = 1
local stageFunctions = {
    [1] = function()
        local playerInCorrectArea = nil
        local jumped = nil
        local obstaclesIdsAndCoords = {
            {3522, 3441, 3329},
            {3522, 3440, 3331},
        }
        if API.PInArea21(3440, 3441, 3327, 3329) then
            playerInCorrectArea = true
            jumped = false
        elseif API.PInArea21(3440, 3441, 3331, 3332) then
            playerInCorrectArea = true
            jumped = true
        else
            print("Player is not in the starting area. Move to the front of the bridge.")
            print("Starting location https://imgur.com/a/Lj06Ook")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea and not jumped then
            crossObstacle(obstaclesIdsAndCoords[1][1], obstaclesIdsAndCoords[2][2], obstaclesIdsAndCoords[2][3])
            return
        end
        if playerInCorrectArea and jumped then
            crossObstacle(obstaclesIdsAndCoords[2][1], obstaclesIdsAndCoords[1][2], obstaclesIdsAndCoords[1][3])
            return
        end
    end,

    [2] = function()
        local playerInCorrectArea = nil
        local going = true
        local obstacles = {
            {id = 113738, obstacleCoords = {5428, 2384}, finalGoingCoords = {5428, 2386}, finalBackingCoords = {5428, 2383}}, -- cliff face
            {id = 113737, obstacleCoords = {5426, 2388}, finalGoingCoords = {5426, 2390}, finalBackingCoords = {5426, 2387}}, -- cliff face
            {id = 113736, obstacleCoords = {5425, 2398}, finalGoingCoords = {5425, 2403}, finalBackingCoords = {5425, 2397}}, -- ruined temple
            {id = 113735, obstacleCoords = {5431, 2408}, finalGoingCoords = {5431, 2413}, finalBackingCoords = {5431, 2407}}, -- ruined temple
            {id = 113734, obstacleCoords = {5431, 2418}, finalGoingCoords = {5482, 2456}, finalBackingCoords = {5431, 2417}}, -- cave entrance
            {id = 113733, obstacleCoords = {5485, 2456}, finalGoingCoords = {5491, 2456}, finalBackingCoords = {5484, 2456}}  -- roots
        }
        if API.PInArea21(5427, 5428, 2379, 2383) then
            playerInCorrectArea = true
        else
            print("Player is not in the starting area. Move to the top of the first cliff face.")
            print("Starting location https://imgur.com/a/kq80Zi2")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea and going then
            crossObstacle(obstacles[1].id, obstacles[1].finalGoingCoords[1], obstacles[1].finalGoingCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalGoingCoords[1], obstacles[2].finalGoingCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalGoingCoords[1], obstacles[3].finalGoingCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalGoingCoords[1], obstacles[4].finalGoingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalGoingCoords[1], obstacles[5].finalGoingCoords[2])
            UTILS.randomSleep(1000) --Necessary because of fade animation
            crossObstacle(obstacles[6].id, obstacles[6].finalGoingCoords[1], obstacles[6].finalGoingCoords[2])
            going = false
        end
        if playerInCorrectArea and not going then
            crossObstacle(obstacles[6].id, obstacles[6].finalBackingCoords[1], obstacles[6].finalBackingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalBackingCoords[1], obstacles[5].finalBackingCoords[2])
            UTILS.randomSleep(1000) --Necessary because of fade animation
            crossObstacle(obstacles[4].id, obstacles[4].finalBackingCoords[1], obstacles[4].finalBackingCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalBackingCoords[1], obstacles[3].finalBackingCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalBackingCoords[1], obstacles[2].finalBackingCoords[2])
            crossObstacle(obstacles[1].id, obstacles[1].finalBackingCoords[1], obstacles[1].finalBackingCoords[2])
        end
    end,

    [3] = function()
        local playerInCorrectArea = nil
        local going = true
        local obstacles = {
            {id = 113695, obstacleCoords = {5437, 2217}, finalGoingCoords = {5439, 2217}, finalBackingCoords = {5436, 2217}}, -- cliff face
            {id = 113696, obstacleCoords = {5456, 2180}, finalGoingCoords = {5456, 2179}, finalBackingCoords = {5456, 2183}}, -- ruined column, might get stunned here
            {id = 113697, obstacleCoords = {5474, 2171}, finalGoingCoords = {5475, 2171}, finalBackingCoords = {5473, 2171}}, -- ruined temple
            {id = 113698, obstacleCoords = {5483, 2171}, finalGoingCoords = {5489, 2171}, finalBackingCoords = {5482, 2171}}, -- plank
            {id = 113699, obstacleCoords = {5495, 2171}, finalGoingCoords = {5502, 2171}, finalBackingCoords = {5494, 2171}}, -- ruins
            {id = 113700, obstacleCoords = {5524, 2182}, finalGoingCoords = {5527, 2182}, finalBackingCoords = {5523, 2182}}  -- ruins
        }
    
        print("Checking if player is in the starting area...")
        if API.PInArea21(5434, 5436, 2216, 2218) then
            playerInCorrectArea = true
            print("Player is in the starting area.")
        else
            print("Player is not in the starting area. Move to the top of the first cliff face.")
            print("Starting location: https://imgur.com/a/giFrpEL")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
    
        if playerInCorrectArea and going then
            print("Crossing obstacle 1 (cliff face)...")
            crossObstacle(obstacles[1].id, obstacles[1].finalGoingCoords[1], obstacles[1].finalGoingCoords[2])
    
            local x1, y1 = (5451 + math.random(-4, 4)), (2205 + math.random(-4, 4))
            print(string.format("Moving to random intermediate point (%d, %d)...", x1, y1))
            API.DoAction_Tile(WPOINT.new(x1, y1, 0))
    
            while API.Read_LoopyLoop() and not API.PInArea21((x1 - 3), (x1 + 3), (y1 - 3), (y1 + 3)) do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stunned by 'Stompy'. Waiting to recover...")
                    UTILS.randomSleep(4000)
                    print("Attempting to overcome obstacle 2 again (ruined column)...")
                    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[2].id}, 50)
                end
                UTILS.randomSleep(500)
            end
    
            print("Crossing obstacle 2 (ruined column)...")
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[2].id}, 50)
    
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[2].finalGoingCoords[1], obstacles[2].finalGoingCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stunned by 'Stompy'. Waiting to recover...")
                    UTILS.randomSleep(4000)
                    print("Attempting to overcome obstacle 2 again (ruined column)...")
                    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[2].id}, 50)
                end
                UTILS.randomSleep(500)
            end
    
            for i = 3, 6 do
                print(string.format("Crossing obstacle %d...", i))
                crossObstacle(obstacles[i].id, obstacles[i].finalGoingCoords[1], obstacles[i].finalGoingCoords[2])
            end
    
            going = false
            print("All obstacles crossed in the forward direction.")
        end
    
        if playerInCorrectArea and not going then
            print("Returning over obstacles in reverse order...")
    
            for i = 6, 2, -1 do
                print(string.format("Crossing obstacle %d in reverse...", i))
                crossObstacle(obstacles[i].id, obstacles[i].finalBackingCoords[1], obstacles[i].finalBackingCoords[2])
            end
    
            local x2, y2 = (5454 + math.random(-4, 4)), (2206 + math.random(-4, 4))
            print(string.format("Moving to random intermediate point (%d, %d)...", x2, y2))
            API.DoAction_Tile(WPOINT.new(x2, y2, 0))
    
            while API.Read_LoopyLoop() and not API.PInArea21((x2 - 3), (x2 + 3), (y2 - 3), (y2 + 3)) do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stunned by 'Stompy'. Waiting to recover...")
                    UTILS.randomSleep(4000)
                    print("Attempting to overcome obstacle 1 again (cliff face)...")
                    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[1].id}, 50)
                end
                UTILS.randomSleep(500)
            end
    
            print("Crossing obstacle 1 in reverse (cliff face)...")
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[1].id}, 50)
    
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[1].finalBackingCoords[1], obstacles[1].finalBackingCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stunned by 'Stompy'. Waiting to recover...")
                    UTILS.randomSleep(4000)
                    print("Attempting to overcome obstacle 1 again (cliff face)...")
                    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[1].id}, 50)
                end
                UTILS.randomSleep(500)
            end
        end
    end,   

    [4] = function()
        local obstacles = {
            {id = 65362, obstacleCoords = {3004, 3938}, finalCoords = {3004, 3950}}, -- obstacle pipe
            {id = 64696, obstacleCoords = {3005, 3952}, finalCoords = {3005, 3958}}, -- ropeswing
            {id = 64699, obstacleCoords = {3001, 3960}, finalCoords = {2996, 3960}}, -- stepping stone
            {id = 64698, obstacleCoords = {3001, 3945}, finalCoords = {2994, 3945}}, -- log balance
            {id = 65734, obstacleCoords = {2993, 3936}, finalCoords = {2995, 3935}}, -- cliff side
        }

        local function UseAbilityByName(string)    
            local ability = UTILS.getSkillOnBar(string)
            if ability ~= nil then
                return API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
            end
            return false
        end

        local function CheckHealth()
            local health = API.GetHPrecent()
            local canEat = UTILS.canUseSkill("Eat Food")
            if health < 50 and canEat == true then
                while API.Read_LoopyLoop() and health < 80 do
                    UseAbilityByName("Eat Food")
                    UTILS.randomSleep(1000)
                    health = API.GetHPrecent()
                end
            elseif health < 50 and canEat == false then
                print("Low HP and no food or Eat Food not found in ability bar. Exiting script.")
                API.Write_LoopyLoop(false)
                return
            end
        end

        local function FellInHole()
            if API.PlayerCoord().y > 10000 then
                return true
            else
                return false
            end
        end

        local function ExitHole()
            while API.Read_LoopyLoop() and FellInHole() do
                API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{32015},50) --Climb ladder
                UTILS.randomSleep(1000)
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
        
        local function SetCurrentObstacle()
            if IsPlayerAtCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2], 0) then
                currentWildernessObstacle = 2
            end
            if IsPlayerAtCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2], 0) then
                currentWildernessObstacle = 3
            end
            if IsPlayerAtCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2], 0) then
                currentWildernessObstacle = 4
            end
            if IsPlayerAtCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2], 0) then
                currentWildernessObstacle = 5
            end
            if IsPlayerAtCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2], 0) or IsPlayerAtCoords(2994, 3935, 0) then
                currentWildernessObstacle = 1
            end
        end

        if playerInCorrectArea == nil then
            if API.PInArea21(2991, 3006, 3931, 3937) then
                playerInCorrectArea = true          
            else
                print("Player is not in the starting area. Move closer to the entrance of the pipe.")
                print("Starting location https://imgur.com/a/43kKbVV")
                playerInCorrectArea = false
                API.Write_LoopyLoop(false)
            end
        end
        if playerInCorrectArea then
            if API.IsPlayerMoving_(API.GetLocalPlayerName()) then
                return
            end

            if FellInHole() then
                ExitHole()
            end

            if API.IsPlayerAnimating_(API.GetLocalPlayerName(), 3) then
                return
            end

            SetCurrentObstacle()
            if currentWildernessObstacle == 1 then
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[1].id},50)
                UTILS.randomSleep(1000)
                API.WaitUntilMovingEnds()
            elseif currentWildernessObstacle == 2 then
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
                UTILS.randomSleep(1000)
                API.WaitUntilMovingEnds()
            elseif currentWildernessObstacle == 3 then
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[3].id},50)
                UTILS.randomSleep(1000)
                API.WaitUntilMovingEnds()
            elseif currentWildernessObstacle == 4 then
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[4].id},50)
                UTILS.randomSleep(1000)
                API.WaitUntilMovingEnds()
            elseif currentWildernessObstacle == 5 then
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[5].id},50)
                UTILS.randomSleep(1000)
                API.WaitUntilMovingEnds()
            end
            CheckHealth()
        end
    end,

    [5] = function()
        local playerInCorrectArea = nil
        local obstacles = {
            {id = 122444, obstacleCoords = {3339, 3242}, finalCoords = {3344, 3242}}, -- fallen palm tree
            {id = 122450, obstacleCoords = {3364, 3241}, finalCoords = {3364, 3236}}, -- fallen palm tree
            {id = 122453, obstacleCoords = {3367, 3236}, finalCoords = {3367, 3236}}, -- rope ladder
            {id = 122454, obstacleCoords = {3368, 3236}, finalCoords = {3370, 3236}}, -- gap
            {id = 122456, obstacleCoords = {3376, 3236}, finalCoords = {3376, 3236}}, -- stone pillar
            {id = 122457, obstacleCoords = {3385, 3242}, finalCoords = {3390, 3242}}, -- rock wall
            {id = 122458, obstacleCoords = {3391, 3239}, finalCoords = {3391, 3233}}, -- fallen palm tree
            {id = 122460, obstacleCoords = {3390, 3226}, finalCoords = {3390, 3225}}, -- small gap
            {id = 122461, obstacleCoords = {3381, 3223}, finalCoords = {3379, 3223}}, -- medium gap
            {id = 122462, obstacleCoords = {3369, 3223}, finalCoords = {3368, 3223}}, -- fallen palm tree
            {id = 122464, obstacleCoords = {3349, 3223}, finalCoords = {3342, 3223}}, -- collapsed walls
            {id = 122465, obstacleCoords = {3329, 3223}, finalCoords = {3329, 3225}}, -- large rocks
            {id = 122466, obstacleCoords = {3329, 3226}, finalCoords = {3329, 3227}}, -- ledge
            {id = 122467, obstacleCoords = {3327, 3232}, finalCoords = {3327, 3234}}, -- gap
            {id = 122468, obstacleCoords = {3329, 3240}, finalCoords = {3329, 3241}}, -- ledge
            {id = 122469, obstacleCoords = {3330, 3242}, finalCoords = {3330, 3243}}, -- large rock
        }
        if API.PInArea21(3330, 3339, 3239, 3245) then
            playerInCorrectArea = true        
        else
            print("Player is not in the starting area. Move closer to the fallen palm tree.")
            print("Starting location https://imgur.com/a/hf1tboY")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end

        local function canSurge()
            local dive = API.GetABs_name("Surge")
            if dive.cooldown_timer < 1 and dive.enabled == true then return true
            else return false end
        end

        if playerInCorrectArea then
            crossObstacle(obstacles[1].id, obstacles[1].finalCoords[1], obstacles[1].finalCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[5].id, obstacles[5].finalCoords[1], obstacles[5].finalCoords[2])
            crossObstacle(obstacles[6].id, obstacles[6].finalCoords[1], obstacles[6].finalCoords[2])
            crossObstacle(obstacles[7].id, obstacles[7].finalCoords[1], obstacles[7].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[8].id, obstacles[8].finalCoords[1], obstacles[8].finalCoords[2])
            crossObstacle(obstacles[9].id, obstacles[9].finalCoords[1], obstacles[9].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[11].id, obstacles[11].finalCoords[1], obstacles[11].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[12].id, obstacles[12].finalCoords[1], obstacles[12].finalCoords[2])
            crossObstacle(obstacles[13].id, obstacles[13].finalCoords[1], obstacles[13].finalCoords[2])
            crossObstacle(obstacles[14].id, obstacles[14].finalCoords[1], obstacles[14].finalCoords[2])
            if canSurge() then Surge() end
            UTILS.randomSleep(100)
            crossObstacle(obstacles[15].id, obstacles[15].finalCoords[1], obstacles[15].finalCoords[2])
            crossObstacle(obstacles[16].id, obstacles[16].finalCoords[1], obstacles[16].finalCoords[2])
        end
        
    end,

    [6] = function()
        local playerInCorrectArea = nil
        local midCourse = false
        local obstacles = {
            {id = 94050, finalCoords = {2180, 3419}}, -- walkway
            {id = 94051, finalCoords = {2171, 3437}}, -- cliff     
            {id = 94055, finalCoords = {2177, 3448}}, -- cathedral
            {id = 94056, finalCoords = {2187, 3443}}, -- roof  
            {id = 94057, finalCoords = {2187, 3415}}, -- zip line
            {id = 20274, finalCoords = {2176, 3400}}, -- light creature
            {id = 94053, finalCoords = {2187, 3443}}, -- window (Shortcut)
            {id = 20273, finalCoords = {2176, 3400}}, -- light creature (Shortcut)
        }
        local function waitForCoords(destX1, destY1, destX2, desty2)
            local coord = API.PlayerCoord()
            while API.Read_LoopyLoop() and not ((coord.x == destX1 and coord.y == destY1) or (coord.x == destX2 and coord.y == desty2)) and (API.ReadPlayerAnim() ~= "-1" or API.ReadPlayerAnim() ~= "0") do
                UTILS.randomSleep(500)
                coord = API.PlayerCoord()
            end
            UTILS.randomSleep(1000)
        end
        local function FullInvCheck()
            if API.InvFull_() then
                while API.Read_LoopyLoop() and not API.CheckBankVarp() do
                    API.DoAction_Object1(0x2e,API.OFF_ACT_GeneralObject_route1,{92692},50)
                    UTILS.randomSleep(2000)
                end
                while API.Read_LoopyLoop() and API.InvFull_()do
                    API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,API.OFF_ACT_GeneralInterface_route)
                    UTILS.randomSleep(2000)
                    API.KeyboardPress2(0x33, 60, 100)
                end
            end
        end
        if API.PInArea21(2174, 2182, 3393, 3403) then
            playerInCorrectArea = true
        else
            print("Player is not in the starting area. Move closer to the walkway.")
            print("Starting location https://imgur.com/a/17zAd9a")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea then
            FullInvCheck()
            UpdateStatus(obstacles[1].id)
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[1].id}, 50)         
            waitForCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2], obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            midCourse = true            
            while API.Read_LoopyLoop() and midCourse do
                if API.ReadPlayerAnim() == 0 then
                    if isPlayerAtCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2]) then
                        UpdateStatus(obstacles[2].id)
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[2].id}, 50)
                        waitForCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2], obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])

                    elseif isPlayerAtCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2]) then
                        local window = #API.GetAllObjArray1({94053}, 10, {0})                        
                        if window and window > 0 then
                            UpdateStatus(obstacles[7].id)
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[7].id}, 50)
                            waitForCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2], 99999, 99999)
                        else
                            UpdateStatus(obstacles[3].id)
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[3].id}, 50)
                            waitForCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2], obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
                        end

                    elseif isPlayerAtCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2]) then
                        UpdateStatus(obstacles[4].id)
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[4].id}, 50)
                        waitForCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2], obstacles[5].finalCoords[5], obstacles[4].finalCoords[2])

                    elseif isPlayerAtCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2]) then
                        local lightCreature = #API.GetAllObjArrayInteract({20273}, 5, {1})                        
                        if lightCreature and lightCreature > 0 then
                            UpdateStatus(20273)
                            API.DoAction_NPC(0xb5, API.OFF_ACT_InteractNPC_route, {20273}, 50)
                            waitForCoords(obstacles[6].finalCoords[1], obstacles[6].finalCoords[2], 99999, 99999)
                        else
                            UpdateStatus(obstacles[5].id)
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[5].id}, 50)
                            waitForCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2], obstacles[6].finalCoords[5], obstacles[6].finalCoords[2])
                        end

                    elseif isPlayerAtCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2]) then
                        UpdateStatus(20274)
                        API.DoAction_NPC(0xb5, API.OFF_ACT_InteractNPC_route, {20274}, 50)
                        waitForCoords(obstacles[6].finalCoords[1], obstacles[6].finalCoords[2], 99999, 99999)
                        midCourse = false
                        UTILS.randomSleep(2000)
                        break
                        
                    elseif isPlayerAtCoords(obstacles[6].finalCoords[1], obstacles[6].finalCoords[2]) then
                        midCourse = false
                        UTILS.randomSleep(2000)
                        break
                        
                    else
                        UTILS.randomSleep(1000)
                    end
                else
                    UTILS.randomSleep(1000)
                end
            end
            FullInvCheck()
        end        
    end,

    [7] = function()
        local playerInCorrectArea = nil
        local obstacles ={
            {id = 113687, finalCoords = {5414,2324}}, -- 1
            {id = 113688, finalCoords = {5410,2325}}, -- 2
            {id = 113689, finalCoords = {5408,2323}}, -- 3
            {id = 113690, finalCoords = {5393,2320}}, -- 4
            {id = 113691, finalCoords = {5367,2304}}, -- 5
            {id = 113692, finalCoords = {5369,2282}}, -- 6
            {id = 113693, finalCoords = {5376,2247}}, -- 7
            {id = 113694, finalCoords = {5397,2240}}, -- 8
            {id = 113695, finalCoords = {5439,2217}}, -- 9
            {id = 113696, finalCoords = {5456,2179}}, -- 10
            {id = 113697, finalCoords = {5475,2171}}, -- 11
            {id = 113698, finalCoords = {5489,2171}}, -- 12
            {id = 113699, finalCoords = {5502,2171}}, -- 13
            {id = 113700, finalCoords = {5527,2182}}, -- 14
            {id = 113701, finalCoords = {5548,2220}}, -- 15
            {id = 113702, finalCoords = {5548,2244}}, -- 16
            {id = 113703, finalCoords = {5553,2249}}, -- 17
            {id = 113704, finalCoords = {5565,2272}}, -- 18
            {id = 113705, finalCoords = {5578,2289}}, -- 19
            {id = 113706, finalCoords = {5587,2295}}, -- 20
            {id = 113707, finalCoords = {5596,2295}}, -- 21
            {id = 113708, finalCoords = {5629,2287}}, -- 22
            {id = 113709, finalCoords = {5669,2288}}, -- 23
            {id = 113710, finalCoords = {5680,2290}}, -- 24
            {id = 113711, finalCoords = {5684,2293}}, -- 25
            {id = 113712, finalCoords = {5686,2310}}, -- 26
            {id = 113713, finalCoords = {5695,2317}}, -- 27
            {id = 113714, finalCoords = {5696,2346}}, -- 28
            {id = 113715, finalCoords = {5675,2363}}, -- 29
            {id = 113716, finalCoords = {5655,2377}}, -- 30
            {id = 113717, finalCoords = {5653,2405}}, -- 31
            {id = 113718, finalCoords = {5643,2420}}, -- 32
            {id = 113719, finalCoords = {5642,2431}}, -- 33
            {id = 113720, finalCoords = {5626,2433}}, -- 34
            {id = 113721, finalCoords = {5616,2433}}, -- 35
            {id = 113722, finalCoords = {5608,2433}}, -- 36
            {id = 113723, finalCoords = {5601,2433}}, -- 37
            {id = 113724, finalCoords = {5591,2450}}, -- 38
            {id = 113725, finalCoords = {5584,2452}}, -- 39
            {id = 113726, finalCoords = {5574,2453}}, -- 40
            {id = 113727, finalCoords = {5564,2452}}, -- 41
            {id = 113728, finalCoords = {5536,2492}}, -- 42
            {id = 113729, finalCoords = {5528,2492}}, -- 43
            {id = 113730, finalCoords = {5505,2478}}, -- 44
            {id = 113731, finalCoords = {5505,2468}}, -- 45
            {id = 113732, finalCoords = {5505,2462}}, -- 46
            {id = 113733, finalCoords = {5484,2456}}, -- 47
            {id = 113734, finalCoords = {5431,2417}}, -- 48
            {id = 113735, finalCoords = {5431,2407}}, -- 49
            {id = 113736, finalCoords = {5425,2397}}, -- 50
            {id = 113737, finalCoords = {5426,2387}}, -- 51
            {id = 113738, finalCoords = {5428,2383}}  -- 52
        }

        local function anticipation()
            local surgeAB = UTILS.getSkillOnBar("Anticipation")
            if surgeAB ~= nil then
              return API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
            end
            return false
        end

        local function canDive()
            local dive = API.GetABs_name("Dive")
            if dive.cooldown_timer < 1 and dive.enabled == true then return true
            else return false end
        end

        local function canSurge()
            local dive = API.GetABs_name("Surge")
            if dive.cooldown_timer < 1 and dive.enabled == true then return true
            else return false end
        end

        local function dive(X, Y)
            if API.Read_LoopyLoop() then                
                local Z = API.PlayerCoord().z
                local Bdive = API.GetABs_id(30331)
                local Dive = API.GetABs_id(23714)
                if (Bdive.id ~= 0 and Bdive.cooldown_timer < 1) or (Dive.id ~= 0 and Dive.cooldown_timer < 1) then
                    if not API.DoAction_BDive_Tile(WPOINT.new(X, Y, Z)) then
                        API.DoAction_Dive_Tile(WPOINT.new(X, Y, Z))
                    end
                end
                UTILS.randomSleep(150)
            end
        end

        local function sleepUntilFacing(targetOrientation)
            if not API.Read_LoopyLoop() then
                return 
            end
            local tolerance = 0.01
            local maxWaitTime = 5
            local elapsedTime = 0        
            targetOrientation = targetOrientation % 360        
            local function normalizeOrientation(orientation)
                return orientation % 360
            end        
            local facing = normalizeOrientation(API.calculatePlayerOrientation())            
            while API.Read_LoopyLoop() and math.abs(facing - targetOrientation) > tolerance and elapsedTime < maxWaitTime do
                UTILS.randomSleep(300)
                facing = normalizeOrientation(API.calculatePlayerOrientation())
                elapsedTime = elapsedTime + 0.3
            end            
            return
        end

        local function crossObstacleAnac(id, destX, destY)
            print("Starting crossObstacleAnac with ID:", id, "Destination:", destX, destY)            
            UpdateStatus(id)            
            if API.Read_LoopyLoop() then  
                print("Waiting for object to appear...")
                WaitForObjectToAppear(id, 12)
                print("Object appeared. Proceeding with action.")
        
                print("Interacting with object. ID:", id)
                API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {id}, 50)    
        
                local maxRetries = 40
                local retries = 0
        
                print("Checking if player reaches destination:", destX, destY)
                while API.Read_LoopyLoop() and not isPlayerAtCoords(destX, destY) and 
                    API.ReadPlayerAnim() ~= "-1" and API.ReadPlayerAnim() ~= "0" and retries < maxRetries do
                    print("Player not at destination. Retry:", retries + 1, "/", maxRetries)
                    UTILS.randomSleep(500)
                    retries = retries + 1
                    if retries == 25 then
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {id}, 50)
                    end
                end
        
                if retries >= maxRetries then
                    print("Timeout reached! Player might be stuck.")
                else
                    print("Player reached destination or stopped moving.")
                end
        
                print("Sleeping before continuing...")
                UTILS.randomSleep(500)
            else
                print("Loop condition failed, skipping obstacle.")
            end
        
            print("Exiting crossObstacleAnac.")
        end        

        if API.PInArea21(5417, 5419, 2324, 2331) then
            playerInCorrectArea = true        
        else
            print("Player is not in the starting area. Move closer to the start of the course southwest of the lodestone.")
            print("Starting location https://imgur.com/a/qfrsup3")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end

        if playerInCorrectArea then
            ----------------------------------------01 to 10----------------------------------------
            crossObstacleAnac(obstacles[1].id, obstacles[1].finalCoords[1], obstacles[1].finalCoords[2])
            crossObstacleAnac(obstacles[2].id, obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            crossObstacleAnac(obstacles[3].id, obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])
            if canDive() then dive(5400,2320) end
            crossObstacleAnac(obstacles[4].id, obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5377, 2311,0))
            sleepUntilFacing(225)
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[5].id, obstacles[5].finalCoords[1], obstacles[5].finalCoords[2])
            if canDive() then 
                dive(5359 + math.random(-1, 1), 2296 + math.random(-1, 1)) 
            else
                API.DoAction_Tile(WPOINT.new(5359 + math.random(-1, 1), 2296 + math.random(-1, 1),0))
                UTILS.randomSleep(1500)
            end
            crossObstacleAnac(obstacles[6].id, obstacles[6].finalCoords[1], obstacles[6].finalCoords[2])
            if canDive() then
                dive(5376, 2272)                                
            else
                API.DoAction_Tile(WPOINT.new(5378, 2311,0))
                UTILS.randomSleep(1000)
            end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[7].id},50)
            sleepUntilFacing(180)
            if canSurge() then Surge() end            
            crossObstacleAnac(obstacles[7].id, obstacles[7].finalCoords[1], obstacles[7].finalCoords[2])
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[8].id},50)
            UTILS.randomSleep(1500)
            if canDive() then dive(5388, 2241) end
            crossObstacleAnac(obstacles[8].id, obstacles[8].finalCoords[1], obstacles[8].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5418, 2231,0))
            sleepUntilFacing(135)
            if canSurge() then Surge() end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[9].id},50)
            UTILS.randomSleep(2000)
            if canDive() then dive(2433 + math.random(-1, 1), 2216 + math.random(-1, 1)) end
            crossObstacleAnac(obstacles[9].id, obstacles[9].finalCoords[1], obstacles[9].finalCoords[2])
            anticipation()
            local x1, y1 = (5451 + math.random(-4, 4)), (2205 + math.random(-4, 4))
            API.DoAction_Tile(WPOINT.new(x1, y1, 0))
            UTILS.randomSleep(1500)
            sleepUntilFacing(135)
            if canSurge() then
                Surge()
            else
                while API.Read_LoopyLoop() and not API.PInArea21((x1 - 4), (x1 + 4), (y1 - 4), (y1 + 4))  do
                    UTILS.randomSleep(300) 
                end
            end
            crossObstacleAnac(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[10].finalCoords[1], obstacles[10].finalCoords[2]) do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    crossObstacleAnac(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
                end
                UTILS.randomSleep(500)            
            end
            ----------------------------------------11 to 20----------------------------------------
            if canDive() then dive(5466, 2171) end
            crossObstacleAnac(obstacles[11].id, obstacles[11].finalCoords[1], obstacles[11].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[12].id, obstacles[12].finalCoords[1], obstacles[12].finalCoords[2])
            crossObstacleAnac(obstacles[13].id, obstacles[13].finalCoords[1], obstacles[13].finalCoords[2])
            if canDive() then dive(5510, 2177) end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{14},50)
            sleepUntilFacing(90)
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[14].id, obstacles[14].finalCoords[1], obstacles[14].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5542 + math.random(-2, 2), 2193 + math.random(-2, 2), 0))
            sleepUntilFacing(45)
            if canSurge() then Surge() end
            if canDive() then dive(5548, 2213) end
            crossObstacleAnac(obstacles[15].id, obstacles[15].finalCoords[1], obstacles[15].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[16].id, obstacles[16].finalCoords[1], obstacles[16].finalCoords[2])
            crossObstacleAnac(obstacles[17].id, obstacles[17].finalCoords[1], obstacles[17].finalCoords[2])
            if canSurge() then Surge() end
            if canDive() then dive(5562, 2268) end
            crossObstacleAnac(obstacles[18].id, obstacles[18].finalCoords[1], obstacles[18].finalCoords[2])
            crossObstacleAnac(obstacles[19].id, obstacles[19].finalCoords[1], obstacles[19].finalCoords[2])
            if canDive() then dive(5580, 2295) end
            crossObstacleAnac(obstacles[20].id, obstacles[20].finalCoords[1], obstacles[20].finalCoords[2])
            ----------------------------------------21 to 30----------------------------------------
            crossObstacleAnac(obstacles[21].id, obstacles[21].finalCoords[1], obstacles[21].finalCoords[2])
            anticipation()
            if canDive() then dive(5605, 2287) end
            API.DoAction_Tile(WPOINT.new(5615 + math.random(-1, 1), 2287 + math.random(-1, 1), 0))
            if API.DeBuffbar_GetIDstatus(14392).found then
                print("Stompy")
                UTILS.randomSleep(4000)
                API.DoAction_Tile(WPOINT.new(5615 + math.random(-1, 1), 2287 + math.random(-1, 1), 0))
            end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{22},50)
            sleepUntilFacing(90)
            UTILS.randomSleep(1500)            
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[22].id, obstacles[22].finalCoords[1], obstacles[22].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5648 + math.random(-1, 1), 2287 + math.random(-1, 1), 0))
            UTILS.randomSleep(1500)
            if canSurge() then Surge() end
            if canDive() then dive(5662, 2288) end
            crossObstacleAnac(obstacles[23].id, obstacles[23].finalCoords[1], obstacles[23].finalCoords[2])
            crossObstacleAnac(obstacles[24].id, obstacles[24].finalCoords[1], obstacles[24].finalCoords[2])
            crossObstacleAnac(obstacles[25].id, obstacles[25].finalCoords[1], obstacles[25].finalCoords[2])
            if canDive() then dive(5686, 2302) end
            crossObstacleAnac(obstacles[26].id, obstacles[26].finalCoords[1], obstacles[26].finalCoords[2])
            crossObstacleAnac(obstacles[27].id, obstacles[27].finalCoords[1], obstacles[27].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5698 + math.random(-1, 1), 2331 + math.random(-1, 1), 0))
            sleepUntilFacing(0)
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[28].id, obstacles[28].finalCoords[1], obstacles[28].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5696 + math.random(-1, 1), 2356 + math.random(-1, 1), 0))
            UTILS.randomSleep(3000)
            if canDive() then dive(5688, 2361) end
            crossObstacleAnac(obstacles[29].id, obstacles[29].finalCoords[1], obstacles[29].finalCoords[2])
            crossObstacleAnac(obstacles[30].id, obstacles[30].finalCoords[1], obstacles[30].finalCoords[2])
            ----------------------------------------31 to 40----------------------------------------
            if canDive() then dive(5645 + math.random(-1, 1), 2387 + math.random(-1, 1)) end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[31].id},50)
            UTILS.randomSleep(2000)
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[31].id, obstacles[31].finalCoords[1], obstacles[31].finalCoords[2])
            crossObstacleAnac(obstacles[32].id, obstacles[32].finalCoords[1], obstacles[32].finalCoords[2])
            crossObstacleAnac(obstacles[33].id, obstacles[33].finalCoords[1], obstacles[33].finalCoords[2])
            if canDive() then dive(5632, 2433) end
            if canSurge() then Surge() end
            UTILS.randomSleep(300)
            crossObstacleAnac(obstacles[34].id, obstacles[34].finalCoords[1], obstacles[34].finalCoords[2])
            crossObstacleAnac(obstacles[35].id, obstacles[35].finalCoords[1], obstacles[35].finalCoords[2])
            crossObstacleAnac(obstacles[36].id, obstacles[36].finalCoords[1], obstacles[36].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[37].id, obstacles[37].finalCoords[1], obstacles[37].finalCoords[2])
            if canDive() then dive(5592 + math.random(-1, 1), 2444 + math.random(-1, 1)) end
            crossObstacleAnac(obstacles[38].id, obstacles[38].finalCoords[1], obstacles[38].finalCoords[2])
            if canDive() then dive(5582, 2453) end
            crossObstacleAnac(obstacles[39].id, obstacles[39].finalCoords[1], obstacles[39].finalCoords[2])
            crossObstacleAnac(obstacles[40].id, obstacles[40].finalCoords[1], obstacles[40].finalCoords[2])
            ----------------------------------------41 to 50----------------------------------------
            crossObstacleAnac(obstacles[41].id, obstacles[41].finalCoords[1], obstacles[41].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5564 + math.random(-1, 1), 2467 + math.random(-1, 1), 0))
            sleepUntilFacing(0)
            if canSurge() then Surge() end
            API.DoAction_Tile(WPOINT.new(5558 + math.random(-1, 1), 2480 + math.random(-1, 1), 0))
            UTILS.randomSleep(2000)
            if canDive() then dive(5557 + math.random(-1, 1), 2482 + math.random(-1, 1)) end
            crossObstacleAnac(obstacles[42].id, obstacles[42].finalCoords[1], obstacles[42].finalCoords[2])
            crossObstacleAnac(obstacles[43].id, obstacles[43].finalCoords[1], obstacles[43].finalCoords[2])
            if canSurge() then Surge() end
            API.DoAction_Tile(WPOINT.new(5511 + math.random(-1, 1), 2485 + math.random(-1, 1), 0))
            UTILS.randomSleep(2000)
            if canDive() then dive(5505, 2481) end
            crossObstacleAnac(obstacles[44].id, obstacles[44].finalCoords[1], obstacles[44].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[45].id, obstacles[45].finalCoords[1], obstacles[45].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[46].id, obstacles[46].finalCoords[1], obstacles[46].finalCoords[2])
            if canDive() then dive(5495, 2456) end
            crossObstacleAnac(obstacles[47].id, obstacles[47].finalCoords[1], obstacles[47].finalCoords[2])
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[48].id, obstacles[48].finalCoords[1], obstacles[48].finalCoords[2])
            UTILS.randomSleep(1000)
            crossObstacleAnac(obstacles[49].id, obstacles[49].finalCoords[1], obstacles[49].finalCoords[2])
            if canDive() then dive(5425, 2403) end
            crossObstacleAnac(obstacles[50].id, obstacles[50].finalCoords[1], obstacles[50].finalCoords[2])
            ----------------------------------------51 to 52----------------------------------------
            if canSurge() then Surge() end
            crossObstacleAnac(obstacles[51].id, obstacles[51].finalCoords[1], obstacles[51].finalCoords[2])
            crossObstacleAnac(obstacles[52].id, obstacles[52].finalCoords[1], obstacles[52].finalCoords[2])
            ----------------------------------------WalkBack----------------------------------------
            API.DoAction_WalkerW(WPOINT.new(5417, 2325, 0))            
            while API.Read_LoopyLoop() and not IsPlayerInArea(5417, 2325, 0, 2) do
                UTILS.randomSleep(500)
            end
            ----------------------------------------------------------------------------------------
        end

    end,

    [8] = function()
        local obstacles = {
            {id = 69526, finalCoords = {2474, 3429}}, -- Log balance
            {id = 69383, finalCoords = {9999, 9999}}, -- Obstacle net
            {id = 69508, finalCoords = {2473, 3420}}, -- Tree branch
            {id = 69506, finalCoords = {2472, 3420}}, -- Tree
            {id = 69514, finalCoords = {2484, 3418}}, -- Signpost
            {id = 43529, finalCoords = {9999, 9999}}, -- Pole
            {id = 69389, finalCoords = {2485, 3436}}, -- Barrier
        }
        if playerInCorrectArea == nil then
            if API.PInArea21(2471, 2478, 3436, 3440) then
                playerInCorrectArea = true
            else
                print("Player is not in the starting area. Move to the start of the couse.")
                print("Starting location https://imgur.com/a/lc6JMk5")
                playerInCorrectArea = false
                API.Write_LoopyLoop(false)
            end
        end
        if playerInCorrectArea then
            if advancedGnomeObstacle == 1 then
                UTILS.randomSleep(1500)
                crossObstacle(obstacles[1].id, obstacles[1].finalCoords[1], obstacles[1].finalCoords[2])
                advancedGnomeObstacle = 2
            elseif advancedGnomeObstacle == 2 then
                UpdateStatus(obstacles[2].id)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 1 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                count = 0
                advancedGnomeObstacle = 3
            elseif advancedGnomeObstacle == 3 then
                UpdateStatus(obstacles[3].id)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[3].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 2 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                count = 0
                advancedGnomeObstacle = 4
            elseif advancedGnomeObstacle == 4 then
                UpdateStatus(obstacles[4].id)
                API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{ obstacles[4].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 3 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                count = 0
                advancedGnomeObstacle = 5
            elseif advancedGnomeObstacle == 5 then
                crossObstacle(obstacles[5].id, obstacles[5].finalCoords[1], obstacles[5].finalCoords[2])
                advancedGnomeObstacle = 6
            elseif advancedGnomeObstacle == 6 then
                UpdateStatus(obstacles[6].id)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[6].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().y ~= 3432 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                count = 0
                advancedGnomeObstacle = 7
            elseif advancedGnomeObstacle == 7 then
                UTILS.randomSleep(1500)
                crossObstacle(obstacles[7].id, obstacles[7].finalCoords[1], obstacles[7].finalCoords[2])
                advancedGnomeObstacle = 1
            end
        end
    end,

    [9] = function()
        local obstacles = {
            {id = 43526, finalCoords = {9999, 9999}}, -- Rope swing
            {id = 43595, finalCoords = {2541, 3546}}, -- Log balance
            {id = 43533, finalCoords = {2538, 3545}}, -- Wall
            {id = 43597, finalCoords = {2536, 3546}}, -- Wall
            {id = 43587, finalCoords = {2532, 3553}}, -- Spring device
            {id = 43527, finalCoords = {2536, 3553}}, -- Balance beam
            {id = 43531, finalCoords = {2538, 3553}}, -- Gap
            {id = 43532, finalCoords = {9999, 9999}}, -- Log balance
            
        }

        local function FellInHole()
            if API.PlayerCoord().y > 9000 then
                return true
            else
                return false
            end
        end

        local function ExitHole()
            while API.Read_LoopyLoop() and FellInHole() do
                API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{ 32015 },50)
                UTILS.randomSleep(500)
            end
        end

        if playerInCorrectArea == nil then
            if API.PInArea21(2549, 2553, 3554, 3559) then
                playerInCorrectArea = true
            else
                print("Player is not in the starting area. Move to the start of the couse.")
                print("Starting location https://imgur.com/a/0tPR0Zf")
                playerInCorrectArea = false
                API.Write_LoopyLoop(false)
            end
        end
        if playerInCorrectArea then
            if advancedBarbarianObstacle == 1 then
                UpdateStatus(obstacles[1].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[1].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().y ~= 3549 do
                    if FellInHole() then 
                        break
                    end
                    if count > 10 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                if FellInHole() then
                    ExitHole()
                    return
                end
                count = 0
                advancedBarbarianObstacle = 2
            elseif advancedBarbarianObstacle == 2 then
                UpdateStatus(obstacles[2].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[2].id },50)
                local count = 0
                while API.Read_LoopyLoop() and (not isPlayerAtCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2]) or API.PlayerCoord().y ~= 3546) do
                    if count > 30 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                if API.PlayerCoord().y ~= 3546 then
                    return
                end
                advancedBarbarianObstacle = 3
            elseif advancedBarbarianObstacle == 3 then
                UpdateStatus(obstacles[3].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[3].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 2 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                advancedBarbarianObstacle = 4
            elseif advancedBarbarianObstacle == 4 then
                UpdateStatus(obstacles[4].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[4].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 3 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                advancedBarbarianObstacle = 5
            elseif advancedBarbarianObstacle == 5 then
                UpdateStatus(obstacles[5].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0x9b,API.OFF_ACT_GeneralObject_route0,{ obstacles[5].id },50)
                local count = 0
                while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2]) do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end

                advancedBarbarianObstacle = 6
            elseif advancedBarbarianObstacle == 6 then
                UpdateStatus(obstacles[6].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[6].id },50)
                local count = 0
                while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[6].finalCoords[1], obstacles[6].finalCoords[2]) do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                advancedBarbarianObstacle = 7
            elseif advancedBarbarianObstacle == 7 then
                UpdateStatus(obstacles[7].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{ obstacles[7].id },50)
                local count = 0
                while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[7].finalCoords[1], obstacles[7].finalCoords[2]) do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end

                advancedBarbarianObstacle = 8
            elseif advancedBarbarianObstacle == 8 then
                UpdateStatus(obstacles[8].id)
                UTILS.randomSleep(1000)
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{ obstacles[8].id },50)
                local count = 0
                while API.Read_LoopyLoop() and API.PlayerCoord().z ~= 0 do
                    if count > 15 then 
                        return
                    end
                    UTILS.randomSleep(500)
                    count = count + 1
                end
                advancedBarbarianObstacle = 1        
            end
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

API.SetDrawTrackedSkills(true)
API.ScriptRuntimeString()
API.GetTrackedSkills()

API.Write_LoopyLoop(true)
API.Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()
    GUIDraw()
    SetCourse()
    
    if selectedOption ~= nil and selectedOption ~= "- none -" then
        RechargeSilverhawkBoots(100)
        executeStage(courseID)
        UTILS.randomSleep(500)
        AnacResources()
    end

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

