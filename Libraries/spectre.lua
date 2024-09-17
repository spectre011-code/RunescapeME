local API = require("api")

local SpectreUtils = {}

--Simple sleep
function SpectreUtils.Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
end

--Prints all the buffs
function SpectreUtils.GetBuffs()
    local buffs = API.Buffbar_GetAllIDs()
    if buffs then
        for _, object in ipairs(buffs) do
            print("----------")
            print("id:", object.id)
            print("text:", object.text)
            print("conv_text:", object.conv_text)
            print("----------")
        end
    end
end

--Prints all the debuffs
function SpectreUtils.GetDebuffs()
    local debuffs = API.DeBuffbar_GetAllIDs()
    if debuffs then
        for _, object in ipairs(buffs) do
            print("----------")
            print("id:", object.id)
            print("text:", object.text)
            print("conv_text:", object.conv_text)
            print("----------")
        end
    end
end

--Prints all the items in inventory
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
end

--Prints all objects with specified parameters
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
            print("object.Pixel_XYZ: ", object.Pixel_XYZ)            
            print("---------------------------------")          
        end
    end 
end

--Checks if the player is a the specified coordinates and returns true or false
function SpectreUtils.IsPlayerAtCoords(x, y, z)
    local coord = API.PlayerCoord()
    if x == coord.x and y == coord.y and z == coord.z then
        return true
    else
        return false
    end
end

--Walks to specified coordinates
function SpectreUtils.WalkToCoordinates(x,y,z)
    API.DoAction_Tile(WPOINT.new(x,y,z))
end

--Checks if the timer of an instance is at 00:00 and returns true or false
function SpectreUtils.TimerHitZero()
    local timer = {
        InterfaceComp5.new(861, 0, -1, -1, 0),
        InterfaceComp5.new(861, 2, -1, 0, 0),
        InterfaceComp5.new(861, 4, -1, 2, 0),
        InterfaceComp5.new(861, 8, -1, 4, 0)
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
function SpectreUtils.UseAbilityByName(string)    
    local ability = UTILS.getSkillOnBar(string)
    if ability ~= nil then
        return API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
    end
    return false
end

-- Checks if a message from an NPC appeared on chat recently up to defined seconds. Can check from a list
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
function SpectreUtils.WaitForObjectToAppear(ObjIDList, ObjType)
    while API.Read_LoopyLoop() do
        local objects = API.GetAllObjArray1(ObjIDList, 75, {ObjType})
        if objects and #objects > 0 then
            for _, object in ipairs(objects) do
                local id = object.Id or 0
                local objType = object.Type or 0
                for _, ObjID in ipairs(ObjIDList) do
                    if id == ObjID and objType == ObjType then return end
                end
            end
        end
        SpectreUtils.Sleep(0.1)
    end
end

--Memory strand teleport from currency pouch
function SpectreUtils.MemStrandTele()
    API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 10, 4097, API.OFF_ACT_GeneralInterface_route) -- Open currency pouch
    SpectreUtils.Sleep(1)    
    while not API.PInArea21(2282, 2302, 3544, 3564) and API.Read_LoopyLoop() do
        API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 21, 10, API.OFF_ACT_GeneralInterface_route) -- Memory Strand teleport  
        SpectreUtils.Sleep(0.5)      
    end
    while API.ReadPlayerAnim() ~= 0 and API.Read_LoopyLoop() do
        SpectreUtils.Sleep(0.5)
    end
    API.DoAction_Interface(0x24, 0x9A3E, 1, 1473, 15, -1, API.OFF_ACT_GeneralInterface_route) -- Close currency pouch
end

local activationTick = 0
local delayTicks = 2
--Activates prayer
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
            API.DoAction_Ability(PrayerName, 1, API.OFF_ACT_GeneralInterface_route)
            activationTick = currentTick
        end
    end
end

--Uses incense sticks and keep them active
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
    end    
    if not found then
        API.DoAction_Inventory1(buffID, 0, 2, API.OFF_ACT_GeneralInterface_route) -- Overload
        for i = 1, 5 do
            API.DoAction_Inventory1(buffID, 0, 1, API.OFF_ACT_GeneralInterface_route) -- Extend
            SpectreUtils.Sleep(0.2)
        end
    end
end

--Recharges silverhawk boots when stored feathers are bellow minimum quantity
function SpectreUtils.RechargeSilverhawkBoots(minQuantity)
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

return SpectreUtils
