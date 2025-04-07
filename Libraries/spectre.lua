Author = "Spectre011"
DiscordHandle = "not_spectre011"

local API = require("api")

local SpectreUtils = {}

VERSION = "1.0"

--Simple sleep
---@param seconds number
---@return boolean
function SpectreUtils.Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
    return true
end

--Prints all the buffs
---@return boolean
function SpectreUtils.GetBuffs()
    local buffs = API.Buffbar_GetAllIDs()
    if buffs then
        for _, object in ipairs(buffs) do
            print("----------")
            print("id: ", object.id)
            print("found: ", object.found)
            print("text: ", object.text)
            print("conv_text: ", object.conv_text)
            print("----------")
        end
    end
    return true
end

--Prints all the debuffs
---@return boolean
function SpectreUtils.GetDebuffs()
    local debuffs = API.DeBuffbar_GetAllIDs()
    if debuffs then
        for _, object in ipairs(buffs) do
            print("----------")
            print("id: ", object.id)
            print("found: ", object.found)
            print("text: ", object.text)
            print("conv_text: ", object.conv_text)
            print("----------")
        end
    end
    return true
end

--Prints all the items in inventory
---@return boolean
function SpectreUtils.GetItemsInInventory()
    local items = API.ReadInvArrays33()
    if items and #items > 0 then
        for _, item in ipairs(items) do
            print("-----------------")
            print("item.x:", item.x)
            print("item.xs:", item.xs)
            print("item.y:", item.y)
            print("item.ys:", item.ys)
            print("item.box_x:", item.box_x)
            print("item.box_y:", item.box_y)
            print("item.scroll_y:", item.scroll_y)
            print("item.id1:", item.id1)
            print("item.id2:", item.id2)
            print("item.id3:", item.id3)
            print("item.id4:", item.id4)
            print("item.itemid1:", item.itemid1) -- Item ID
            print("item.itemid1_size:", item.itemid1_size) -- Item Quantity
            print("item.itemid2:", item.itemid2)
            print("item.hov:", item.hov)
            print("item.textids:", item.textids)
            print("item.textitem:", item.textitem) -- Item Name
            print("item.memloc:", item.memloc)
            print("item.memloctop:", item.memloctop)
            print("item.index:", item.index)
            print("item.fullpath:", item.fullpath)
            print("item.fullIDpath:", item.fullIDpath)
            print("item.notvisible:", item.notvisible)
            print("item.OP:", item.OP)
            print("item.xy:", item.xy)
            print("-----------------")            
        end
    end
    return true
end

--Prints all abitilies from specified ability bar
---@param BarID number
---@return boolean
function SpectreUtils.GetAbilitiesFromBar(BarID)
    local bar = API.GetABarInfo(BarID)
    for _, ability in ipairs(bar) do
        print("----------------------------")
        print("ability.slot: ", ability.slot)
        print("ability.id: ", ability.id)
        print("ability.name: ", ability.name)
        print("ability.hotkey: ", ability.hotkey)
        print("ability.cooldown_timer: ", ability.cooldown_timer)
        print("ability.info: ", ability.info)
        print("ability.action: ", ability.action)
        print("ability.enabled: ", ability.enabled)
        print("----------------------------")
    end
    return true
end

--Prints all objects with specified parameters
---@param Id table|number
---@param Range number
---@param Type table|number
---@return boolean
function SpectreUtils.GetAllObjects(Id, Range, Type)
    local objects = API.GetAllObjArray1({Id}, Range, {Type})
    if objects and #objects > 0 then
        for _, object in ipairs(objects) do
            print("---------------------------------")  
            print("object.Mem: ", object.Mem)
            print("object.MemE: ", object.MemE)
            print("object.TileX: ", object.TileX)
            print("object.TileY: ", object.TileY)
            print("object.TileZ: ", object.TileZ)
            print("object.Id: ", object.Id)
            print("object.Life: ", object.Life)
            print("object.Anim: ", object.Anim)
            print("object.Name: ", object.Name)
            print("object.Action: ", object.Action)
            print("object.Floor: ", object.Floor)
            print("object.Amount: ", object.Amount)
            print("object.Type: ", object.Type)
            print("object.Bool1: ", object.Bool1)
            print("object.ItemIndex: ", object.ItemIndex)
            print("object.ViewP: ", object.ViewP)
            print("object.ViewF: ", object.ViewF)
            print("object.Distance: ", object.Distance)
            print("object.Cmb_lv: ", object.Cmb_lv)
            print("object.Unique_Id: ", object.Unique_Id)
            print("object.CalcX: ", object.CalcX)
            print("object.CalcY: ", object.CalcY)
            print("object.Tile_XYZ: ", object.Tile_XYZ)
            print("object.Tile_XYZ.x: ", object.Tile_XYZ.x)
            print("object.Tile_XYZ.y: ", object.Tile_XYZ.y)
            print("object.Tile_XYZ.z: ", object.Tile_XYZ.z)
            print("object.Pixel_XYZ: ", object.Pixel_XYZ)            
            print("---------------------------------")          
        end
    end
    return true
end

--Prints info about specified VB
---@param VB number
---@return boolean
function SpectreUtils.GetVB(VB)
    local var = API.VB_FindPSettinOrder(VB)
    print("--------------------------")
    print("state: " .. var.state)
    print("addr: " .. var.addr)
    print("indexaddr_orig: " .. var.indexaddr_orig)
    print("id: " .. var.id)
    print("--------------------------")
    return true
end

---Prints container contents of non empty slots. 93 = inventory and 94 = equipment
---@param containerId number The ID of the container to print contents from
---@return nil Prints to console but doesnt return a value
function SpectreUtils.PrintContainerContents(containerId)
    local items = API.Container_Get_all(containerId)
    if not items or #items == 0 then
        print("Container is empty")
        return
    end

    local validItemCount = 0
    for _, item in ipairs(items) do
        if item.item_id and item.item_id > 0 then
            validItemCount = validItemCount + 1
        end
    end
    
    print("=== Container Contents ===")
    print("Valid items: " .. validItemCount)
    print("--------------------------")

    for i, item in ipairs(items) do
        if item.item_id and item.item_id > 0 then
            print("Item #" .. i)
            print("  item_id: " .. tostring(item.item_id))
            print("  item_stack: " .. tostring(item.item_stack))
            print("  item_slot: " .. tostring(item.item_slot))

            print("  Extra_mem:")
            if item.Extra_mem then
                for k, v in pairs(item.Extra_mem) do
                    print("    " .. tostring(k) .. ": " .. tostring(v))
                end
            else
                print("    nil")
            end

            print("  Extra_ints:")
            if item.Extra_ints then
                for k, v in pairs(item.Extra_ints) do
                    print("    " .. tostring(k) .. ": " .. tostring(v))
                end
            else
                print("    nil")
            end
            
            print("--------------------------")
        end
    end
end


--Checks if the player is in a specified area
---@param x number
---@param y number
---@param z number
---@param radius number
---@return boolean
function SpectreUtils.IsPlayerInArea(x, y, z, radius)
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

--Checks if the player is a the specified coordinates
---@param x number
---@param y number
---@param z number
---@return boolean
function SpectreUtils.IsPlayerAtCoords(x, y, z)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y and z == coord.z then
        return true
    else
        return false
    end
end

--Walks to specified coordinates
---@param x number
---@param y number
---@param z number
---@return boolean
function SpectreUtils.WalkToCoordinates(x,y,z)
    if API.DoAction_Tile(WPOINT.new(x,y,z)) then
        return true
    else
        return false
    end
end

--Checks if the timer of an instance is at 00:00
---@return boolean
function SpectreUtils.TimerHitZero()
    local timer = {
        InterfaceComp5.new(861, 0, -1, 0),
        InterfaceComp5.new(861, 2, -1, 0),
        InterfaceComp5.new(861, 4, -1, 0),
        InterfaceComp5.new(861, 8, -1, 0)
    }
    local result = API.ScanForInterfaceTest2Get(false, timer)
    if result and #result > 0 and result[1].textids then
        local textids = result[1].textids
        local startIndex, endIndex = string.find(textids, "00:00")
        if startIndex then
            return true
        else
            return false
        end
    else
        print("No result or textids field not found.")
    end
end

--Use ability by name
---@param string string
---@return boolean
function SpectreUtils.UseAbilityByName(string)    
    local ability = UTILS.getSkillOnBar(string)
    if ability ~= nil then
        return API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
    end
    return false
end

-- Checks if a message from an NPC appeared on chat recently up to defined seconds. Can check from a list
---@param search_strings table|string
---@param max_seconds number
---@return string
function SpectreUtils.CheckNPCMessagesRecent(search_strings, max_seconds)
    local chat = API.ChatGetMessages()
    local current_time = os.date("*t")
    local current_seconds = current_time.hour * 3600 + current_time.min * 60 + current_time.sec
    if type(search_strings) ~= "table" then
        search_strings = {search_strings}
    end
    for _, msg in ipairs(chat) do
        local time_text = string.match(msg.text, "<col=7fa9ff>(%d%d:%d%d:%d%d)")
        local message_text = string.match(msg.text, "<col=99ff99>(.-)</col>")
        if time_text then
            local hours, minutes, seconds = string.match(time_text, "(%d%d):(%d%d):(%d%d)")
            if hours and minutes and seconds then
                local message_time_seconds = tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
                local time_difference = current_seconds - message_time_seconds
                if time_difference <= max_seconds and message_text then
                    for _, search_string in ipairs(search_strings) do
                        if string.find(message_text, search_string) then
                            return search_strings[_] -- or return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Wait until the object appears
---@return boolean
function SpectreUtils.WaitForObjectToAppear(ObjID, ObjType)
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
        SpectreUtils.Sleep(0.2)
    end
    return true
end

--Memory strand teleport from currency pouch
---@return boolean
function SpectreUtils.MemStrandTele()
    API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 10, 4097, API.OFF_ACT_GeneralInterface_route) -- Open currency pouch
    SpectreUtils.Sleep(0.2)
    while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2293, 3554, 0, 5) do
        API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 21, 10, API.OFF_ACT_GeneralInterface_route) -- Memory Strand teleport  
        SpectreUtils.Sleep(6)
    end
    API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 15, -1, API.OFF_ACT_GeneralInterface_route) -- Close currency pouch
    return true
end

local activationTick = 0
local delayTicks = 2
--Activates prayer
---@param PrayerBuffID number
---@return boolean
function SpectreUtils.ActivatePrayer(PrayerBuffID)
    local prayerMapping = {
        [26033] = "Soul Split",
        [26041] = "Deflect Magic",
        [26044] = "Deflect Ranged",
        [26040] = "Deflect Melee",
        [30745] = "Deflect Necromancy",
        [25959] = "Protect from Magic",
        [25960] = "Protect from Ranged",
        [25961] = "Protect from Melee",
        [30831] = "Protect from Necromancy"        
    }
    local PrayerName = prayerMapping[PrayerBuffID]
    if not PrayerName then
        print("Invalid PrayerBuffID: " .. PrayerBuffID)
        return
    end
    local currentTick = API.Get_tick()
    if not API.Buffbar_GetIDstatus(PrayerBuffID).found then
        if activationTick == 0 or currentTick > activationTick + delayTicks then
            if API.DoAction_Ability(PrayerName, 1, API.OFF_ACT_GeneralInterface_route) then
                activationTick = currentTick
                return true
            else 
                return false
            end            
        end
    end
end

--Deactivates prayer
---@param PrayerBuffID number
---@return boolean
function SpectreUtils.DeactivatePrayer(PrayerBuffID)
    local prayerMapping = {
        [26033] = "Soul Split",
        [26041] = "Deflect Magic",
        [26044] = "Deflect Ranged",
        [26040] = "Deflect Melee",
        [30745] = "Deflect Necromancy",
        [25959] = "Protect from Magic",
        [25960] = "Protect from Ranged",
        [25961] = "Protect from Melee",
        [30831] = "Protect from Necromancy"        
    }
    local PrayerName = prayerMapping[PrayerBuffID]
    if not PrayerName then
        print("Invalid PrayerBuffID: " .. PrayerBuffID)
        return
    end
    local currentTick = API.Get_tick()
    if API.Buffbar_GetIDstatus(PrayerBuffID).found then
        if activationTick == 0 or currentTick > activationTick + delayTicks then
            if API.DoAction_Ability(PrayerName, 1, API.OFF_ACT_GeneralInterface_route) then
                activationTick = currentTick
                return true
            else
                return false
            end
        end
    end
end

--Uses incense sticks and keep them active
---@param buffID number
---@return boolean
function SpectreUtils.CheckIncenseStick(buffID)
    local buffs = API.Buffbar_GetAllIDs()
    local found = false
    if buffs then
        for _, object in ipairs(buffs) do
            if object.id == buffID then
                found = true
                local time, level = string.match(object.text, "(%d+)%a* %((%d+)%)")
                time = tonumber(time)
                level = tonumber(level)
                if level < 4 then
                    API.DoAction_Inventory1(buffID, 0, 2, API.OFF_ACT_GeneralInterface_route) -- Overload
                end
                if time < 50 then
                    local randomCount = math.random(1, 5)
                    for i = 1, randomCount do
                        API.DoAction_Inventory1(buffID, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Extend
                        SpectreUtils.Sleep(0.2)
                    end
                end
                break
            end
        end
        return true
    end    
    if not found then
        API.DoAction_Inventory1(buffID, 0, 2, API.OFF_ACT_GeneralInterface_route) -- Overload
        for i = 1, 5 do
            API.DoAction_Inventory1(buffID, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Extend
            SpectreUtils.Sleep(0.2)
        end
        return true
    end
    return false
end

--Recharges silverhawk boots when stored feathers are bellow minimum quantity
---@param minQuantity number
---@return boolean
function SpectreUtils.RechargeSilverhawkBoots(minQuantity)
    local item = API.Container_Get_s(94,30924)
    if item.item_id == 30924 then
        if item.Extra_ints[2] < minQuantity then
            local silverhawkFeather = API.CheckInvStuff0(30915)
            local silverhawkDown = API.CheckInvStuff0(34823)
            if silverhawkFeather ~= false then
                API.DoAction_Inventory1(30915,0,1,API.OFF_ACT_GeneralInterface_route)
                return true
            elseif silverhawkDown ~= false then
                API.DoAction_Inventory1(34823,0,1,API.OFF_ACT_GeneralInterface_route)
                return true
            end
        end
        return false
    end
    return false
end

--Checks if from a list of IDS if the items are in players Inventory
---@param ids number
---@return boolean
function SpectreUtils.inventoryContainsAny(ids)
    for _, id in ipairs(ids) do
        if Inventory:Contains(id) then
            return true
        end
    end
    return false
end

--Surges if the player is facing the specified orientation
---@param Orientation number
---@return boolean
function SpectreUtils.SurgeIfFacing(Orientation)
    local Surge = API.GetABs_id(14233)
    local PlayerFacing = math.floor(API.calculatePlayerOrientation())
    if PlayerFacing == 0 then PlayerFacing = 360 end
    if Orientation == 0 then Orientation = 360 end
    
    if Orientation == PlayerFacing then
        if (Surge.id ~= 0 and Surge.enabled and Surge.cooldown_timer < 1) then
            if API.DoAction_Ability_Direct(Surge, 1, API.OFF_ACT_GeneralInterface_route) then
                return true
            else
                return false
            end
        end
    end
end

--Dives to the specified coordinates
---@param X number
---@param Y number
---@param Z number
---@return boolean
function SpectreUtils.Dive(X, Y, Z)
    local Bdive = API.GetABs_id(30331)
    local Dive = API.GetABs_id(23714)
    if (Bdive.id ~= 0 and Bdive.enabled and Bdive.cooldown_timer < 1) or (Dive.id ~= 0 and Bdive.enabled and Dive.cooldown_timer < 1) then
        if not API.DoAction_BDive_Tile(WPOINT.new(X, Y, Z)) then
            if API.DoAction_Dive_Tile(WPOINT.new(X, Y, Z)) then
                return true
            else
                return false
            end
        end
    end
end

--Retrieves the kill counts GWD 2 followers
---@return table<string, number>
function SpectreUtils.GetGWD2KillCounts()
    local baseAddresses = {
        { { 1746,0,-1,0 }, { 1746,38,-1,0 }, { 1746,41,-1,0 }, { 1746,43,-1,0 }, { 1746,47,-1,0 } },
        { { 1746,0,-1,0 }, { 1746,38,-1,0 }, { 1746,41,-1,0 }, { 1746,49,-1,0 }, { 1746,54,-1,0 } },
        { { 1746,0,-1,0 }, { 1746,38,-1,0 }, { 1746,41,-1,0 }, { 1746,55,-1,0 }, { 1746,60,-1,0 } },
        { { 1746,0,-1,0 }, { 1746,38,-1,0 }, { 1746,41,-1,0 }, { 1746,61,-1,0 }, { 1746,66,-1,0 } },
    }

    local keyNames = { "Seren", "Sliske", "Zamorak", "Zaros" }
    local results = {}

    for i, baseAddress in ipairs(baseAddresses) do
        local data = API.ScanForInterfaceTest2Get(false, baseAddress)
        if #data >= 0 then
            local amount = API.ReadCharsLimit(data[1].memloc + API.I_itemids3, 255)
            results[keyNames[i]] = tonumber(amount)
        end
    end

    print("Kill Counts:")
    print("Seren:", results.Seren)
    print("Sliske:", results.Sliske)
    print("Zamorak:", results.Zamorak)
    print("Zaros:", results.Zaros)
    
    return results
end

return SpectreUtils
