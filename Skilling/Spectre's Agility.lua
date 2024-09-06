--[[

Spectre's Agility
Author: Spectre
Version 1.0
Date: 06-09-2024
Discord: spectre011.code_34000

Move to the starting location of the circuit and set the courseID to the method you want to use acording to the courseDescriptions table ]]

local courseID = 1 --CHANGE THIS #########################################################################################

----------------------------------------------------------------------------------------------------------------------------
local courseDescriptions = {
    [1] = "1-30 Jumping the bridge outside the Nature Grotto", -- Starting location https://imgur.com/a/Lj06Ook
    [2] = "30-50 Northern Anachronia Agility Course", -- Starting location https://imgur.com/a/kq80Zi2
    [3] = "50-52 Southern Anachronia Agility Course", -- Starting location https://imgur.com/a/giFrpEL
    [4] = "52-65 Wilderness Agility Course", -- Starting location https://imgur.com/a/43kKbVV
    [5] = "65-77 Het's Oasis Agility Course", -- Starting location https://imgur.com/a/hf1tboY
    [6] = "77-80 Hefin Agility Course", -- Starting location https://imgur.com/a/17zAd9a
    [7] = "80-99+ Advanced Anachronia Agility Course" -- Starting location https://imgur.com/a/qfrsup3
}

local API = require("api")
local UTILS = require("utils")

local function isPlayerAtCoords(x, y)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y then
        return true
    else
        return false
    end
end

local function crossObstacle(id, destX, destY)
    print("ID: ", id)
    API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{id},50)
    while API.Read_LoopyLoop() and not isPlayerAtCoords(destX, destY) and API.ReadPlayerAnim() ~= "-1" and API.ReadPlayerAnim() ~= "0" do
        UTILS.randomSleep(500)
    end
    UTILS.randomSleep(1000)
end

local currentStageDescription = courseDescriptions[courseID]
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
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea and going then
            crossObstacle(obstacles[1].id, obstacles[1].finalGoingCoords[1], obstacles[1].finalGoingCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalGoingCoords[1], obstacles[2].finalGoingCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalGoingCoords[1], obstacles[3].finalGoingCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalGoingCoords[1], obstacles[4].finalGoingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalGoingCoords[1], obstacles[5].finalGoingCoords[2])
            crossObstacle(obstacles[6].id, obstacles[6].finalGoingCoords[1], obstacles[6].finalGoingCoords[2])
            going = false
        end
        if playerInCorrectArea and not going then
            crossObstacle(obstacles[6].id, obstacles[6].finalBackingCoords[1], obstacles[6].finalBackingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalBackingCoords[1], obstacles[5].finalBackingCoords[2])
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
            {id = 113696, obstacleCoords = {5456, 2180}, finalGoingCoords = {5456, 2179}, finalBackingCoords = {5456, 2183}}, -- ruined collumn, might get stunned here
            {id = 113697, obstacleCoords = {5474, 2171}, finalGoingCoords = {5475, 2171}, finalBackingCoords = {5473, 2171}}, -- ruined temple
            {id = 113698, obstacleCoords = {5483, 2171}, finalGoingCoords = {5489, 2171}, finalBackingCoords = {5482, 2171}}, -- plank
            {id = 113699, obstacleCoords = {5495, 2171}, finalGoingCoords = {5502, 2171}, finalBackingCoords = {5494, 2171}}, -- ruins
            {id = 113700, obstacleCoords = {5524, 2182}, finalGoingCoords = {5527, 2182}, finalBackingCoords = {5523, 2182}}  -- ruins
        }
        if API.PInArea21(5434, 5436, 2216, 2218) then
            playerInCorrectArea = true
        else
            print("Player is not in the starting area. Move to the top of the first cliff face.")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea and going then
            crossObstacle(obstacles[1].id, obstacles[1].finalGoingCoords[1], obstacles[1].finalGoingCoords[2])
            local x1, y1 = (5451 + math.random(-4, 4)), (2205 + math.random(-4, 4))
            API.DoAction_Tile(WPOINT.new(x1, y1, 0))
            while API.Read_LoopyLoop() and not API.PInArea21((x1 - 3), (x1 + 3), (y1 - 3), (y1 + 3))  do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
                end
                UTILS.randomSleep(500)            
            end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[2].finalGoingCoords[1], obstacles[2].finalGoingCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
                end
                UTILS.randomSleep(500)
            end
            crossObstacle(obstacles[3].id, obstacles[3].finalGoingCoords[1], obstacles[3].finalGoingCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalGoingCoords[1], obstacles[4].finalGoingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalGoingCoords[1], obstacles[5].finalGoingCoords[2])
            crossObstacle(obstacles[6].id, obstacles[6].finalGoingCoords[1], obstacles[6].finalGoingCoords[2])
            going = false
        end
        if playerInCorrectArea and not going then
            crossObstacle(obstacles[6].id, obstacles[6].finalBackingCoords[1], obstacles[6].finalBackingCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalBackingCoords[1], obstacles[5].finalBackingCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalBackingCoords[1], obstacles[4].finalBackingCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalBackingCoords[1], obstacles[3].finalBackingCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalBackingCoords[1], obstacles[2].finalBackingCoords[2])
            local x2, y2 = (5454 + math.random(-4, 4)), (2206 + math.random(-4, 4))
            API.DoAction_Tile(WPOINT.new(x2, y2, 0))
            while API.Read_LoopyLoop() and not API.PInArea21((x2 - 3), (x2 + 3), (y2 - 3), (y2 + 3))  do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[1].id},50)
                end
                UTILS.randomSleep(500)            
            end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[1].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[1].finalBackingCoords[1], obstacles[1].finalBackingCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[1].id},50)
                end
                UTILS.randomSleep(500)
            end
        end
    end,

    [4] = function()
        local playerInCorrectArea = nil
        local fellIntoTheHole = false
        local obstacles = {
            {id = 65362, obstacleCoords = {3004, 3938}, finalCoords = {3004, 3950}}, -- obstacle pipe
            {id = 64696, obstacleCoords = {3005, 3952}, finalCoords = {3005, 3958}}, -- ropeswing
            {id = 64699, obstacleCoords = {3001, 3960}, finalCoords = {2996, 3960}}, -- stepping stone
            {id = 64698, obstacleCoords = {3001, 3945}, finalCoords = {2994, 3945}}, -- log balance
            {id = 65734, obstacleCoords = {2993, 3936}, finalCoords = {2994, 3935}}, -- cliff side
        }
        if API.PInArea21(2991, 3006, 3931, 3937) then
            playerInCorrectArea = true          
        else
            print("Player is not in the starting area. Move closer to the entrance of the pipe.")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea then
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[1].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                UTILS.randomSleep(500)
            end
            UTILS.randomSleep(2000)
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[2].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.PInArea21(2900, 3100, 10250, 10450) then
                    UTILS.randomSleep(1000)
                    API.DoAction_Object1(0x34,API.OFF_ACT_GeneralObject_route0,{32015},50)
                    while API.Read_LoopyLoop() and not isPlayerAtCoords(3005, 3962) do
                        UTILS.randomSleep(10000)
                    end
                    break
                end
                UTILS.randomSleep(500)
            end
            UTILS.randomSleep(2000)
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[3].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                UTILS.randomSleep(4000)
                if not API.PInArea21(2996, 3960, 3002, 3960) then
                    break
                end
            end
            UTILS.randomSleep(2000)
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[4].id}, 50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                if API.PInArea21(2900, 3100, 10250, 10450) then
                    fellIntoTheHole = true
                    UTILS.randomSleep(1000)                    
                    API.DoAction_Object1(0x34, API.OFF_ACT_GeneralObject_route0, {32015}, 50)
                    while API.Read_LoopyLoop() and not isPlayerAtCoords(3005, 3962) do
                        UTILS.randomSleep(10000)
                    end                    
                    while fellIntoTheHole do
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[4].id}, 50)
                        while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                            if API.PInArea21(2900, 3100, 10250, 10450) then
                                UTILS.randomSleep(1000)
                                API.DoAction_Object1(0x34, API.OFF_ACT_GeneralObject_route0, {32015}, 50)
                                while API.Read_LoopyLoop() and not isPlayerAtCoords(3005, 3962) do
                                    UTILS.randomSleep(1000)
                                end
                                API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[4].id}, 50)
                            else
                                fellIntoTheHole = false
                            end
                        end
                    end
                end
                UTILS.randomSleep(500)
            end

            UTILS.randomSleep(2000)
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[5].id},50)
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2]) and API.ReadPlayerAnim() ~= "-1" do
                UTILS.randomSleep(500)
            end
            UTILS.randomSleep(2000)
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
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea then
            crossObstacle(obstacles[1].id, obstacles[1].finalCoords[1], obstacles[1].finalCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])
            crossObstacle(obstacles[4].id, obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
            crossObstacle(obstacles[5].id, obstacles[5].finalCoords[1], obstacles[5].finalCoords[2])
            crossObstacle(obstacles[6].id, obstacles[6].finalCoords[1], obstacles[6].finalCoords[2])
            crossObstacle(obstacles[7].id, obstacles[7].finalCoords[1], obstacles[7].finalCoords[2])
            crossObstacle(obstacles[8].id, obstacles[8].finalCoords[1], obstacles[8].finalCoords[2])
            crossObstacle(obstacles[9].id, obstacles[9].finalCoords[1], obstacles[9].finalCoords[2])
            crossObstacle(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
            crossObstacle(obstacles[11].id, obstacles[11].finalCoords[1], obstacles[11].finalCoords[2])
            crossObstacle(obstacles[12].id, obstacles[12].finalCoords[1], obstacles[12].finalCoords[2])
            crossObstacle(obstacles[13].id, obstacles[13].finalCoords[1], obstacles[13].finalCoords[2])
            crossObstacle(obstacles[14].id, obstacles[14].finalCoords[1], obstacles[14].finalCoords[2])
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
        if API.PInArea21(2174, 2182, 3393, 3403) then
            playerInCorrectArea = true
        else
            print("Player is not in the starting area. Move closer to the walkway.")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end
        if playerInCorrectArea then
            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[1].id}, 50)         
            waitForCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2], obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            midCourse = true            
            while API.Read_LoopyLoop() and midCourse do
                if API.ReadPlayerAnim() == 0 then
                    if isPlayerAtCoords(obstacles[1].finalCoords[1], obstacles[1].finalCoords[2]) then
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[2].id}, 50)
                        waitForCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2], obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])

                    elseif isPlayerAtCoords(obstacles[2].finalCoords[1], obstacles[2].finalCoords[2]) then
                        local window = #API.GetAllObjArray1({94053}, 10, {0})                        
                        if window and window > 0 then
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[7].id}, 50)
                            waitForCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2], 99999, 99999)
                        else
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[3].id}, 50)
                            waitForCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2], obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
                        end

                    elseif isPlayerAtCoords(obstacles[3].finalCoords[1], obstacles[3].finalCoords[2]) then
                        API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[4].id}, 50)
                        waitForCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2], obstacles[5].finalCoords[5], obstacles[4].finalCoords[2])

                    elseif isPlayerAtCoords(obstacles[4].finalCoords[1], obstacles[4].finalCoords[2]) then
                        local lightCreature = #API.GetAllObjArrayInteract({20273}, 5, {1})                        
                        if lightCreature and lightCreature > 0 then
                            API.DoAction_NPC(0xb5, API.OFF_ACT_InteractNPC_route, {20273}, 50)
                            waitForCoords(obstacles[6].finalCoords[1], obstacles[6].finalCoords[2], 99999, 99999)
                        else
                            API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, {obstacles[5].id}, 50)
                            waitForCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2], obstacles[6].finalCoords[5], obstacles[6].finalCoords[2])
                        end

                    elseif isPlayerAtCoords(obstacles[5].finalCoords[1], obstacles[5].finalCoords[2]) then
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

        local function dive(x, y)
            API.DoAction_Dive_Tile(WPOINT.new(x,y,0))
            UTILS.randomSleep(300)
        end

        local function sleepUntilFacing(targetOrientation)
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

        if API.PInArea21(5417, 5419, 2324, 2331) then
            playerInCorrectArea = true        
        else
            print("Player is not in the starting area. Move closer to the start of the course southwest of the lodestone.")
            playerInCorrectArea = false
            API.Write_LoopyLoop(false)
        end

        if playerInCorrectArea then
            ----------------------------------------01 to 10----------------------------------------
            crossObstacle(obstacles[1].id, obstacles[1].finalCoords[1], obstacles[1].finalCoords[2])
            crossObstacle(obstacles[2].id, obstacles[2].finalCoords[1], obstacles[2].finalCoords[2])
            crossObstacle(obstacles[3].id, obstacles[3].finalCoords[1], obstacles[3].finalCoords[2])
            if canDive() then dive(5400,2320) end
            crossObstacle(obstacles[4].id, obstacles[4].finalCoords[1], obstacles[4].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5377, 2311,0))
            sleepUntilFacing(225)
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[5].id, obstacles[5].finalCoords[1], obstacles[5].finalCoords[2])
            if canDive() then 
                dive(5359 + math.random(-1, 1), 2296 + math.random(-1, 1)) 
            else
                API.DoAction_Tile(WPOINT.new(5359 + math.random(-1, 1), 2296 + math.random(-1, 1),0))
                UTILS.randomSleep(1500)
            end
            crossObstacle(obstacles[6].id, obstacles[6].finalCoords[1], obstacles[6].finalCoords[2])
            if canDive() then
                dive(5376, 2272)                                
            else
                API.DoAction_Tile(WPOINT.new(5378, 2311,0))
                UTILS.randomSleep(1000)
            end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[7].id},50)
            sleepUntilFacing(180)
            if canSurge() then UTILS.surge() end            
            crossObstacle(obstacles[7].id, obstacles[7].finalCoords[1], obstacles[7].finalCoords[2])
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[8].id},50)
            UTILS.randomSleep(1500)
            if canDive() then dive(5388, 2241) end
            crossObstacle(obstacles[8].id, obstacles[8].finalCoords[1], obstacles[8].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5418, 2231,0))
            sleepUntilFacing(135)
            if canSurge() then UTILS.surge() end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[9].id},50)
            UTILS.randomSleep(2000)
            if canDive() then dive(2433 + math.random(-1, 1), 2216 + math.random(-1, 1)) end
            crossObstacle(obstacles[9].id, obstacles[9].finalCoords[1], obstacles[9].finalCoords[2])
            local x1, y1 = (5451 + math.random(-4, 4)), (2205 + math.random(-4, 4))
            API.DoAction_Tile(WPOINT.new(x1, y1, 0))
            UTILS.randomSleep(1500)
            sleepUntilFacing(135)
            if canSurge() then
                UTILS.surge()
            else
                while API.Read_LoopyLoop() and not API.PInArea21((x1 - 4), (x1 + 4), (y1 - 4), (y1 + 4))  do
                    UTILS.randomSleep(300) 
                end
            end
            crossObstacle(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
            while API.Read_LoopyLoop() and not isPlayerAtCoords(obstacles[10].finalCoords[1], obstacles[10].finalCoords[2]) do
                if API.DeBuffbar_GetIDstatus(14392).found then
                    print("Stompy")
                    UTILS.randomSleep(4000)
                    crossObstacle(obstacles[10].id, obstacles[10].finalCoords[1], obstacles[10].finalCoords[2])
                end
                UTILS.randomSleep(500)            
            end
            ----------------------------------------11 to 20----------------------------------------
            if canDive() then dive(5466, 2171) end
            crossObstacle(obstacles[11].id, obstacles[11].finalCoords[1], obstacles[11].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[12].id, obstacles[12].finalCoords[1], obstacles[12].finalCoords[2])
            crossObstacle(obstacles[13].id, obstacles[13].finalCoords[1], obstacles[13].finalCoords[2])
            if canDive() then dive(5510, 2177) end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{14},50)
            sleepUntilFacing(90)
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[14].id, obstacles[14].finalCoords[1], obstacles[14].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5542 + math.random(-2, 2), 2193 + math.random(-2, 2), 0))
            sleepUntilFacing(45)
            if canSurge() then UTILS.surge() end
            if canDive() then dive(5548, 2213) end
            crossObstacle(obstacles[15].id, obstacles[15].finalCoords[1], obstacles[15].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[16].id, obstacles[16].finalCoords[1], obstacles[16].finalCoords[2])
            crossObstacle(obstacles[17].id, obstacles[17].finalCoords[1], obstacles[17].finalCoords[2])
            if canSurge() then UTILS.surge() end
            if canDive() then dive(5562, 2268) end
            crossObstacle(obstacles[18].id, obstacles[18].finalCoords[1], obstacles[18].finalCoords[2])
            crossObstacle(obstacles[19].id, obstacles[19].finalCoords[1], obstacles[19].finalCoords[2])
            if canDive() then dive(5580, 2295) end
            crossObstacle(obstacles[20].id, obstacles[20].finalCoords[1], obstacles[20].finalCoords[2])
            ----------------------------------------21 to 30----------------------------------------
            crossObstacle(obstacles[21].id, obstacles[21].finalCoords[1], obstacles[21].finalCoords[2])
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
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[22].id, obstacles[22].finalCoords[1], obstacles[22].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5648 + math.random(-1, 1), 2287 + math.random(-1, 1), 0))
            UTILS.randomSleep(1500)
            if canSurge() then UTILS.surge() end
            if canDive() then dive(5662, 2288) end
            crossObstacle(obstacles[23].id, obstacles[23].finalCoords[1], obstacles[23].finalCoords[2])
            crossObstacle(obstacles[24].id, obstacles[24].finalCoords[1], obstacles[24].finalCoords[2])
            crossObstacle(obstacles[25].id, obstacles[25].finalCoords[1], obstacles[25].finalCoords[2])
            if canDive() then dive(5686, 2302) end
            crossObstacle(obstacles[26].id, obstacles[26].finalCoords[1], obstacles[26].finalCoords[2])
            crossObstacle(obstacles[27].id, obstacles[27].finalCoords[1], obstacles[27].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5698 + math.random(-1, 1), 2331 + math.random(-1, 1), 0))
            sleepUntilFacing(0)
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[28].id, obstacles[28].finalCoords[1], obstacles[28].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5696 + math.random(-1, 1), 2356 + math.random(-1, 1), 0))
            UTILS.randomSleep(3000)
            if canDive() then dive(5688, 2361) end
            crossObstacle(obstacles[29].id, obstacles[29].finalCoords[1], obstacles[29].finalCoords[2])
            crossObstacle(obstacles[30].id, obstacles[30].finalCoords[1], obstacles[30].finalCoords[2])
            ----------------------------------------31 to 40----------------------------------------
            if canDive() then dive(5645 + math.random(-1, 1), 2387 + math.random(-1, 1)) end
            API.DoAction_Object1(0xb5,API.OFF_ACT_GeneralObject_route0,{obstacles[31].id},50)
            UTILS.randomSleep(2000)
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[31].id, obstacles[31].finalCoords[1], obstacles[31].finalCoords[2])
            crossObstacle(obstacles[32].id, obstacles[32].finalCoords[1], obstacles[32].finalCoords[2])
            crossObstacle(obstacles[33].id, obstacles[33].finalCoords[1], obstacles[33].finalCoords[2])
            if canDive() then dive(5632, 2433) end
            if canSurge() then UTILS.surge() end
            UTILS.randomSleep(300)
            crossObstacle(obstacles[34].id, obstacles[34].finalCoords[1], obstacles[34].finalCoords[2])
            crossObstacle(obstacles[35].id, obstacles[35].finalCoords[1], obstacles[35].finalCoords[2])
            crossObstacle(obstacles[36].id, obstacles[36].finalCoords[1], obstacles[36].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[37].id, obstacles[37].finalCoords[1], obstacles[37].finalCoords[2])
            if canDive() then dive(5592 + math.random(-1, 1), 2444 + math.random(-1, 1)) end
            crossObstacle(obstacles[38].id, obstacles[38].finalCoords[1], obstacles[38].finalCoords[2])
            if canDive() then dive(5582, 2453) end
            crossObstacle(obstacles[39].id, obstacles[39].finalCoords[1], obstacles[39].finalCoords[2])
            crossObstacle(obstacles[40].id, obstacles[40].finalCoords[1], obstacles[40].finalCoords[2])
            ----------------------------------------41 to 50----------------------------------------
            crossObstacle(obstacles[41].id, obstacles[41].finalCoords[1], obstacles[41].finalCoords[2])
            API.DoAction_Tile(WPOINT.new(5564 + math.random(-1, 1), 2467 + math.random(-1, 1), 0))
            sleepUntilFacing(0)
            if canSurge() then UTILS.surge() end
            API.DoAction_Tile(WPOINT.new(5558 + math.random(-1, 1), 2480 + math.random(-1, 1), 0))
            UTILS.randomSleep(2000)
            if canDive() then dive(5557 + math.random(-1, 1), 2482 + math.random(-1, 1)) end
            crossObstacle(obstacles[42].id, obstacles[42].finalCoords[1], obstacles[42].finalCoords[2])
            crossObstacle(obstacles[43].id, obstacles[43].finalCoords[1], obstacles[43].finalCoords[2])
            if canSurge() then UTILS.surge() end
            API.DoAction_Tile(WPOINT.new(5511 + math.random(-1, 1), 2485 + math.random(-1, 1), 0))
            UTILS.randomSleep(2000)
            if canDive() then dive(5505, 2481) end
            crossObstacle(obstacles[44].id, obstacles[44].finalCoords[1], obstacles[44].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[45].id, obstacles[45].finalCoords[1], obstacles[45].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[46].id, obstacles[46].finalCoords[1], obstacles[46].finalCoords[2])
            if canDive() then dive(5495, 2456) end
            crossObstacle(obstacles[47].id, obstacles[47].finalCoords[1], obstacles[47].finalCoords[2])
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[48].id, obstacles[48].finalCoords[1], obstacles[48].finalCoords[2])
            UTILS.randomSleep(1000)
            crossObstacle(obstacles[49].id, obstacles[49].finalCoords[1], obstacles[49].finalCoords[2])
            if canDive() then dive(5425, 2403) end
            crossObstacle(obstacles[50].id, obstacles[50].finalCoords[1], obstacles[50].finalCoords[2])
            ----------------------------------------51 to 52----------------------------------------
            if canSurge() then UTILS.surge() end
            crossObstacle(obstacles[51].id, obstacles[51].finalCoords[1], obstacles[51].finalCoords[2])
            crossObstacle(obstacles[52].id, obstacles[52].finalCoords[1], obstacles[52].finalCoords[2])
            ----------------------------------------WalkBack----------------------------------------
            API.DoAction_Tile(WPOINT.new(5428 + math.random(-1, 1), 2369 + math.random(-1, 1), 0))
            UTILS.randomSleep(5000)
            API.DoAction_Tile(WPOINT.new(5418 + math.random(-1, 1), 2355 + math.random(-1, 1), 0))
            UTILS.randomSleep(7000)
            API.DoAction_Tile(WPOINT.new(5417, 2325, 0))
            while not isPlayerAtCoords(5417, 2325) do
                UTILS.randomSleep(500)
            end
            ----------------------------------------------------------------------------------------
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

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()
    executeStage(courseID)
end

