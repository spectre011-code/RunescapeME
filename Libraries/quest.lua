local API = require("api")

local QUEST = {}

-- Simple sleep
---@param seconds number
---@return boolean
function QUEST.Sleep(seconds)
    local endTime = os.clock() + seconds
    while API.Read_LoopyLoop() and os.clock() < endTime do
    end
    return true
end

-- Is the option dialog box open
---@return boolean
function QUEST.HasOption()
    local option = API.ScanForInterfaceTest2Get(false, { { 1188, 5, -1, -1}, { 1188, 3, -1, 5}, { 1188, 3, 14, 3} })

    if #option > 0 and #option[1].textids > 0 then
        return option[1].textids
    end

    return false
end

-- Select the first option found in the given table. 
--[[Table example:
local options = {
    "Could I have the key back?",
    "6,000? Seems fair!",
    "Teleport to the clan camp south of Falador.",
    "I wish to drop it."
}
]]
---@param options table
---@return boolean
function QUEST.OptionSelector(options)
    for i, optionText in ipairs(options) do
        local optionNumber = tonumber(API.Dialog_Option(optionText))
        if optionNumber and optionNumber > 0 then
            local keyCode = 0x30 + optionNumber
            API.KeyboardPress2(keyCode, 60, 100)
            API.RandomSleep2(400,300,600)
            return true
        end
    end
    return false
end

-- Is a Dialogue Window open
---@return boolean
function QUEST.DialogBoxOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 12
end

-- Presses space bar with sleep added after
---@return boolean
function QUEST.PressSpace()
    return API.KeyboardPress2(0x20, 40, 60), API.RandomSleep2(400,300,600)
end

---@param timeout number
---@return boolean
function QUEST.WaitForDialogBox(timeout)
    local startTime = os.clock()
    while API.Read_LoopyLoop() and not QUEST.DialogBoxOpen() do
        if os.clock() - startTime > timeout then
            return false
        end
        QUEST.Sleep(0.6)
    end
    return true
end


--Checks if the player is in a specified area
---@param x number
---@param y number
---@param z number
---@param radius number
---@return boolean
function QUEST.IsPlayerInArea(x, y, z, radius)
    local coord = API.PlayerCoord()
    local dx = math.abs(coord.x - x)
    local dy = math.abs(coord.y - y)
    local distance = math.sqrt(dx^2 + dy^2)
    if distance <= radius and coord.z == z then
        return true
    else
        return false
    end
end

--Moves to a certain location within a specified distance tolerance
---@param x number
---@param y number
---@param z number
---@param Tolerance number
---@return boolean
function QUEST.MoveTo(X, Y, Z, Tolerance)
    while API.Read_LoopyLoop() and not QUEST.IsPlayerInArea(X, Y, Z, Tolerance + 2) do
        if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then
            print("Not moving. Walking...")
            API.DoAction_WalkerW(WPOINT.new(X + math.random(-Tolerance, Tolerance),Y + math.random(-Tolerance, Tolerance),Z))
        end
        QUEST.Sleep(0.6)
    end
    return true
end

-- Wait until the object appears
---@return boolean
function QUEST.WaitForObjectToAppear(ObjID, ObjType)    
    local objects = API.GetAllObjArray1({ObjID}, 75, {ObjType})
    if objects and #objects > 0 then
        for _, object in ipairs(objects) do
            local id = object.Id or 0
            local objType = object.Type or 0           
            if id == ObjID and objType == ObjType then
                return true
            end
        end
    else
        print("No objects found on this attempt.")
    end
    QUEST.Sleep(0.6)
    return true
end

-- Check if an object exists
---@param ObjID number
---@param Range number
---@param ObjType number
---@return boolean
function QUEST.DoesObjectExist(ObjID, Range, ObjType)
    local objects = API.GetAllObjArray1({ObjID}, Range, {ObjType})
    if objects and #objects > 0 then
        for _, object in ipairs(objects) do
            if object.Id == ObjID and ObjType == object.Type then
                return true
            end
        end
    end
    return false
end


-- Checks the bool1 field of a given object(12) is equal to 1
---@param ObjID number
---@return boolean
function QUEST.Bool1Check(ObjID)
    local objects = API.GetAllObjArray1({ObjID}, 75, {12})
    if objects and #objects > 0 then
        for _, object in ipairs(objects) do
            if object.Bool1 == 1 then 
                return true
            end
        end
    end
    return false
end

return QUEST