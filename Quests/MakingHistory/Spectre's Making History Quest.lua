ScriptName = "Making History Quest"
Author = "Spectre011"
ScriptVersion = "2.0.0"
ReleaseDate = "23-01-2025"
DiscordHandle = "not_spectre011"
--Requirements: https://imgur.com/a/VofobpY

--[[
Changelog:
v1.0 - 23-01-2025
    - Initial release.
v2.0.0 - 31-03-2025
    - Adopted SemVer 
    - Changed Discord variable name to DiscordHandle
]]

local API = require("api")
local UTILS = require("utils")
local LODESTONES = require("lodestones")
local SpectreUtils = require("spectre")

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

local function Sleep(seconds)
    local endTime = os.clock() + seconds
    while os.clock() < endTime do
    end
end

local function WaitForObjectToAppear(ObjID, ObjType)
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
        Sleep(1)
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

local function IsTeleportInterfaceOpen()
    local interfaceCoords = {
        InterfaceComp5.new(720, 2, -1, -1),
        InterfaceComp5.new(720, 17, -1, 2)
    }
    local result = API.ScanForInterfaceTest2Get(true, interfaceCoords)
    if #result > 0 then
        return true
    else
        return false
    end
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
        "Tell me more.",
        "Ask about the outpost",
        "Okay",
        "I'm after important answers.",
        "Why, you're the famous warrior Dron!",
        "An iron mace.",
        "Breakfast.",
        "Lunch.",
        "Bunnies.",
        "Red.",
        "36.",
        "8.",
        "Fifth and Fourth",
        "Northeast side of town",
        "Blanin.",
        "Fluffy.",
        "12, but what does that have to do with anything?"
    }

    for i, optionText in ipairs(options) do
        local optionNumber = tonumber(API.Dialog_Option(optionText))
        if optionNumber and optionNumber > 0 then
            local keyCode = 0x30 + optionNumber
            API.KeyboardPress2(keyCode, 60, 100)
            return true
        end
    end

    API.KeyboardPress2(0x31, 60, 100)
    return false
end


local function HandleDialog()
    while API.Read_LoopyLoop() and not DialogBoxOpen() do
        Sleep(0.3)
    end
    while API.Read_LoopyLoop() and DialogBoxOpen() do
        if HasOption() then
            OptionSelector()
            Sleep(0.3)
        else
            PressSpace()
            Sleep(0.3)
        end
    end
end

local function GetQuestVB()
    return API.VB_FindPSettinOrder(2173).state >> 0 & 0x7
end

local IDS = {
    Jorral = 2932,
    SilverMerchant = 569,
    TraderCrewmate = 4656,
    Droalak = 2936,
    Melina = 2933,
    Blanin = 2940,
    Dron = 2939,
    KingLathas = 364
}

Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do
    local questProgress = GetQuestVB()
    print("Quest Progress: ", questProgress)

    if questProgress == 0 then
        print("Debug: Starting quest step 1/3.")
        UpdateStatus("Step: 1/3")
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2446, 3346, 0, 5) do
            print("Debug: Player not in target area (2446, 3346, 0).")
            local rubCount = 0
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() and rubCount < 15 do
                print(string.format("Debug: Attempting to rub Traveller's Necklace (attempt %d).", rubCount + 1))
                API.DoAction_Interface(0xffffffff, 0x99ca, 3, 1430, 194, -1, API.OFF_ACT_GeneralInterface_route) -- Rub Traveller's Necklace
                SpectreUtils.Sleep(0.3)
                rubCount = rubCount + 1
            end
            print("Debug: Finished trying to rub Traveller's Necklace.")
            API.TypeOnkeyboard2(2)
            SpectreUtils.Sleep(4)
        end
    
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) do
            print("Debug: Player not at coords (2436, 3347, 0).")
            local doorWalkCount = 0
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2433, 3348, 0, 3) and doorWalkCount < 15 do
                print(string.format("Debug: Walking to door area (attempt %d).", doorWalkCount + 1))
                API.DoAction_Tile(WPOINT.new(2433 + math.random(-1, 1), 3348 + math.random(-1, 1), 0))
                SpectreUtils.Sleep(1)
                doorWalkCount = doorWalkCount + 1
            end
            doorWalkCount = 0
    
            local door = #API.GetAllObjArray1({10263}, 10, {0})
            print(string.format("Debug: Number of doors detected: %d.", door))
            local doorOpenCount = 0
            if door == 0 then
                while API.Read_LoopyLoop() and door == 0 and doorOpenCount < 15 do
                    print(string.format("Debug: Attempting to open door (attempt %d).", doorOpenCount + 1))
                    API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, {10262}, 50)
                    SpectreUtils.Sleep(1)
                    door = #API.GetAllObjArray1({10263}, 10, {0})
                    doorOpenCount = doorOpenCount + 1
                end
                print("Debug: Finished trying to open door.")
                doorOpenCount = 0
            end
    
            print("Debug: Walking to target coords (2436, 3347, 0).")
            API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
            local jorralWalkCount = 0
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) and jorralWalkCount < 15 do
                SpectreUtils.Sleep(1)
                if not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) then
                    print(string.format("Debug: Retrying walk to Jorral's location (attempt %d).", jorralWalkCount + 1))
                    API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
                    jorralWalkCount = jorralWalkCount + 1
                end
            end
            print("Debug: Finished walking to Jorral.")
            jorralWalkCount = 0
        end
    
        print("Debug: Interacting with Jorral.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Jorral}, 50)
        Sleep(0.3)
        
        print("Debug: Handling dialog.")
        for i = 1, 7 do
            HandleDialog()
            Sleep(1)
        end
    
        print("Debug: Accepting quest.")
        API.DoAction_Interface(0x24, 0xffffffff, 1, 1500, 409, -1, API.OFF_ACT_GeneralInterface_route) -- Accept quest
        for i= 1, 7 do
            PressSpace()
            Sleep(1)
        end
        Sleep(2)
    elseif questProgress == 1 then
        print("Debug: Starting step 2/3")
        UpdateStatus("Step: 2/3")

        print("Debug: Teleporting to Ardougne Lodestone")
        LODESTONES.ARDOUGNE.Teleport()

        print("Debug: Walking to Ardougne market coordinates")
        API.DoAction_WalkerW(WPOINT.new(2663 + math.random(-4, 4), 3311 + math.random(-4, 4), 0))

        print("Debug: Waiting for Silver Merchant object to appear")
        WaitForObjectToAppear(IDS.SilverMerchant, 1)

        print("Debug: Interacting with Silver Merchant NPC")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.SilverMerchant}, 50)

        print("Debug: Handling dialog with Silver Merchant")
        HandleDialog()

        print("Debug: Walking to coordinates (2440, 3138)")
        API.DoAction_WalkerW(WPOINT.new(2440, 3138, 0))

        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2440, 3138, 0) do
            print("Debug: Waiting to reach coordinates (2440, 3138)")
            Sleep(0.3)
        end

        print("Debug: Digging with spade")
        API.DoAction_Inventory1(952, 0, 1, API.OFF_ACT_GeneralInterface_route)
        HandleDialog()

        print("Debug: Performing inventory action for item 6754")
        API.DoAction_Inventory1(6754, 0, 0, API.OFF_ACT_Bladed_interface_route)
        Sleep(1)

        print("Debug: Performing inventory action for item 6759")
        API.DoAction_Inventory1(6759, 0, 0, API.OFF_ACT_GeneralInterface_route1)
        HandleDialog()
        Sleep(1)

        print("Debug: Performing inventory action for item 6755")
        API.DoAction_Inventory1(6755, 0, 1, API.OFF_ACT_GeneralInterface_route)
        Sleep(1)

        print("Debug: Interacting with interface at position (960, 79)")
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 960, 79, -1, API.OFF_ACT_GeneralInterface_route)

        print("Debug: Teleporting to Port Sarim Lodestone")
        LODESTONES.PORT_SARIM.Teleport()

        print("Debug: Walking to Port Sarim market coordinates")
        API.DoAction_WalkerW(WPOINT.new(3036, 3191, 0))

        print("Debug: Waiting for Trader Crewmate object to appear")
        WaitForObjectToAppear(IDS.TraderCrewmate, 1)

        print("Debug: Interacting with Trader Crewmate NPC")
        API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, {IDS.TraderCrewmate}, 50)
        Sleep(20)

        print("Debug: Interacting with interface at position (95, 24)")
        API.DoAction_Interface(0xffffffff,0xffffffff,1,95,24,-1,API.OFF_ACT_GeneralInterface_route)

        print("Debug: Handling dialog with Trader Crewmate")
        HandleDialog()

        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3702, 3503, 0) do
            print("Debug: Waiting to reach coordinates (3702, 3503)")
            Sleep(10)
        end

        print("Debug: Walking to coordinates (3659, 3468)")
        API.DoAction_WalkerW(WPOINT.new(3659, 3468, 0))

        print("Debug: Waiting for Droalak object to appear")
        WaitForObjectToAppear(IDS.Droalak, 1)

        print("Debug: Interacting with Droalak NPC")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Droalak}, 50)

        print("Debug: Handling dialog with Droalak")
        HandleDialog()

        print("Debug: Walking to coordinates (3676, 3476)")
        API.DoAction_Tile(WPOINT.new(3676, 3476, 0))

        while API.Read_LoopyLoop() and not IsPlayerAtCoords(3676, 3476, 0) do
            print("Debug: Waiting to reach coordinates (3676, 3476)")
            Sleep(1)
        end

        print("Debug: Checking for door object at coordinates (3676, 3477)")
        local door = #API.GetAllObjArray2({5245}, 50, {0}, WPOINT.new(3676, 3477, 0))
        if door == 0 then
            print("Debug: Door not found, interacting with object 5244 to open")
            API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {5244}, 50, WPOINT.new(3676, 3477, 0))
            while API.Read_LoopyLoop() and door == 0 do
                print("Debug: Waiting for door to appear after interacting with object 5244")
                Sleep(1)
                door = #API.GetAllObjArray2({5245}, 50, {0}, WPOINT.new(3676, 3477, 0))
                API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {5244}, 50, WPOINT.new(3676, 3477, 0))
            end
        end
        print("Debug: Step completed")

        print("Waiting for object: Melina to appear.")
        WaitForObjectToAppear(IDS.Melina, 1)
        print("Object Melina appeared. Interacting with NPC.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Melina}, 50)
        HandleDialog()

        print("Walking to coordinates: (3659, 3468, 0).")
        API.DoAction_WalkerW(WPOINT.new(3659, 3468, 0))
        print("Waiting for object: Droalak to appear.")
        WaitForObjectToAppear(IDS.Droalak, 1)
        print("Object Droalak appeared. Interacting with NPC.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Droalak}, 50)
        HandleDialog()

        print("Teleporting to Fremennik Province lodestone.")
        LODESTONES.FREMENNIK_PROVINCE.Teleport()
        print("Walking to tile: (2668, 3669, 0).")
        API.DoAction_Tile(WPOINT.new(2668, 3669, 0))
        print("Waiting for object: Blanin to appear.")
        WaitForObjectToAppear(IDS.Blanin, 1)
        print("Object Blanin appeared. Interacting with NPC.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Blanin}, 50)
        HandleDialog()

        print("Walking to tile: (2659, 3700, 0).")
        API.DoAction_Tile(WPOINT.new(2659, 3700, 0))
        print("Waiting for object: Dron to appear.")
        WaitForObjectToAppear(IDS.Dron, 1)
        print("Object Dron appeared. Interacting with NPC.")
        
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Dron}, 50)
        HandleDialog()

        print("Ensuring player is in area: (2446, 3346, 0) within 5 tiles.")
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2446, 3346, 0, 5) do
            local rubCount = 0
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() and rubCount < 15 do
                print("Rubbing Traveller's Necklace. Attempt:", rubCount + 1)
                API.DoAction_Interface(0xffffffff, 0x99ca, 3, 1430, 194, -1, API.OFF_ACT_GeneralInterface_route)
                SpectreUtils.Sleep(0.3)
                rubCount = rubCount + 1
            end
            print("Teleporting via interface.")
            API.TypeOnkeyboard2(2)
            SpectreUtils.Sleep(4)
        end

        print("Ensuring player reaches coordinates: (2436, 3347, 0).")
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) do
            local doorWalkCount = 0
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2433, 3348, 0, 3) and doorWalkCount < 15 do
                print("Walking to door area. Attempt:", doorWalkCount + 1)
                API.DoAction_Tile(WPOINT.new(2433 + math.random(-1, 1), 3348 + math.random(-1, 1), 0))
                SpectreUtils.Sleep(1)
                doorWalkCount = doorWalkCount + 1
            end
            local door = #API.GetAllObjArray1({10263}, 10, {0})
            local doorOpenCount = 0
            if door == 0 then
                print("Door closed. Attempting to open.")
                while API.Read_LoopyLoop() and door == 0 and doorOpenCount < 15 do
                    print("Opening door. Attempt:", doorOpenCount + 1)
                    API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, {10262}, 50)
                    SpectreUtils.Sleep(1)
                    door = #API.GetAllObjArray1({10263}, 10, {0})
                    doorOpenCount = doorOpenCount + 1
                end
            end
            print("Walking to Jorral's location: (2436, 3347, 0).")
            API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
            local jorralWalkCount = 0
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) and jorralWalkCount < 15 do
                SpectreUtils.Sleep(1)
                if not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) then
                    print("Approaching Jorral's location. Attempt:", jorralWalkCount + 1)
                    API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
                    jorralWalkCount = jorralWalkCount + 1
                end
            end
        end

        print("Interacting with NPC: Jorral.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Jorral}, 50)
        HandleDialog()
        print("Handling dialog after interacting with Jorral.")
        Sleep(1)
        HandleDialog()
        print("Process complete.")

    elseif questProgress == 2 then
        UpdateStatus("Step: 3/3")
        print("Debug: Starting Step 3/3")

        -- Teleport to Ardougne lodestone
        print("Debug: Teleporting to Ardougne lodestone")
        LODESTONES.ARDOUGNE.Teleport()

        -- Walk to the first waypoint
        print("Debug: Walking to (2580, 3297, 0)")
        API.DoAction_WalkerW(WPOINT.new(2580, 3297, 0))
        Sleep(1)
        API.DoAction_WalkerW(WPOINT.new(2580, 3297, 0))
        Sleep(1)
        API.DoAction_WalkerW(WPOINT.new(2580, 3297, 0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2580, 3297, 0) do
            Sleep(0.3)
        end

        -- Check for the first door
        local door = #API.GetAllObjArray2({2549}, 50, {0}, WPOINT.new(2579, 3297, 0))
        print("Debug: Initial door check. Door count:", door)
        if door == 0 then
            print("Debug: Door not found, interacting with object")
            API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {2548}, 50, WPOINT.new(2580, 3297, 0))
            while API.Read_LoopyLoop() and door == 0 do
                Sleep(1)
                door = #API.GetAllObjArray2({2549}, 50, {0}, WPOINT.new(2579, 3297, 0))
                print("Debug: Rechecking door count:", door)
                API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {5244}, 50, WPOINT.new(3676, 3477, 0))
            end
        end

        -- Walk to the second waypoint
        print("Debug: Walking to (2572, 3291, 0)")
        API.DoAction_WalkerW(WPOINT.new(2572, 3291, 0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2572, 3291, 0) do
            Sleep(0.3)
        end

        -- Check for the second door
        local door2 = #API.GetAllObjArray2({34808}, 50, {0}, WPOINT.new(2572, 3291, 0))
        print("Debug: Initial door2 check. Door count:", door2)
        if door2 == 0 then
            print("Debug: Door2 not found, interacting with object")
            API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {34807}, 50, WPOINT.new(2572, 3290, 0))
            while API.Read_LoopyLoop() and door2 == 0 do
                Sleep(1)
                door2 = #API.GetAllObjArray2({2549}, 50, {0}, WPOINT.new(2579, 3297, 0))
                print("Debug: Rechecking door2 count:", door2)
                API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {34807}, 50, WPOINT.new(2572, 3290, 0))
            end
        end

        -- Interact with King Lathas' room door
        print("Debug: Interacting with King Lathas' room door")
        API.DoAction_Object2(0x34, API.OFF_ACT_GeneralObject_route0, {34871}, 50, WPOINT.new(2571, 3285, 0))
        WaitForObjectToAppear(IDS.KingLathas, 1)

        -- Walk to the third waypoint
        print("Debug: Walking to (2572, 3296, 1)")
        API.DoAction_WalkerW(WPOINT.new(2572, 3296, 0))
        while API.Read_LoopyLoop() and not IsPlayerAtCoords(2572, 3296, 1) do
            Sleep(0.3)
        end

        -- Check for the third door
        local door3 = #API.GetAllObjArray2({34826}, 50, {0}, WPOINT.new(2572, 3296, 0))
        print("Debug: Initial door3 check. Door count:", door3)
        if door3 == 0 then
            print("Debug: Door3 not found, interacting with object")
            API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {34825}, 50, WPOINT.new(2573, 3296, 0))
            while API.Read_LoopyLoop() and door3 == 0 do
                Sleep(1)
                door3 = #API.GetAllObjArray2({34826}, 50, {0}, WPOINT.new(2572, 3296, 0))
                print("Debug: Rechecking door3 count:", door3)
                API.DoAction_Object2(0x31, API.OFF_ACT_GeneralObject_route0, {34825}, 50, WPOINT.new(2573, 3296, 0))
            end
        end

        -- Interact with King Lathas
        print("Debug: Interacting with King Lathas")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.KingLathas}, 50)
        HandleDialog()

        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2446, 3346, 0, 5) do
            local rubCount = 0
            print("Starting loop to teleport with Traveller's Necklace.")
            while API.Read_LoopyLoop() and not IsTeleportInterfaceOpen() and rubCount < 15 do
                print("Attempting to rub Traveller's Necklace. Attempt: " .. rubCount)
                API.DoAction_Interface(0xffffffff, 0x99ca, 3, 1430, 194, -1, API.OFF_ACT_GeneralInterface_route)
                SpectreUtils.Sleep(0.3)
                rubCount = rubCount + 1
            end
            print("Teleport interface status: " .. tostring(IsTeleportInterfaceOpen()))
            API.TypeOnkeyboard2(2)
            print("Sent keyboard input for teleport. Waiting for completion.")
            SpectreUtils.Sleep(4)
        end
        
        while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) do
            local doorWalkCount = 0
            print("Navigating towards door at (2433, 3348).")
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerInArea(2433, 3348, 0, 3) and doorWalkCount < 15 do
                print("Walking to door area. Attempt: " .. doorWalkCount)
                API.DoAction_Tile(WPOINT.new(2433 + math.random(-1, 1), 3348 + math.random(-1, 1), 0))
                SpectreUtils.Sleep(1)
                doorWalkCount = doorWalkCount + 1
            end
            print("Reached door area or max attempts.")
        
            local door = #API.GetAllObjArray1({10263}, 10, {0})
            print("Checking if the door is open. Objects found: " .. door)
            local doorOpenCount = 0
            if door == 0 then
                print("Door is closed. Attempting to open it.")
                while API.Read_LoopyLoop() and door == 0 and doorOpenCount < 15 do
                    print("Trying to open the door. Attempt: " .. doorOpenCount)
                    API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, {10262}, 50)
                    SpectreUtils.Sleep(1)
                    door = #API.GetAllObjArray1({10263}, 10, {0})
                    print("Door status after attempt: " .. door)
                    doorOpenCount = doorOpenCount + 1
                end
                print("Finished attempts to open the door.")
            end
        
            print("Walking to Jorral's location at (2436, 3347).")
            API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
            local jorralWalkCount = 0
            while API.Read_LoopyLoop() and not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) and jorralWalkCount < 15 do
                SpectreUtils.Sleep(1)
                if not SpectreUtils.IsPlayerAtCoords(2436, 3347, 0) then
                    print("Still not at Jorral's location. Re-attempting walk. Attempt: " .. jorralWalkCount)
                    API.DoAction_Tile(WPOINT.new(2436, 3347, 0))
                    jorralWalkCount = jorralWalkCount + 1
                end
            end
            print("Reached Jorral's location or max attempts.")
        end
        
        print("Interacting with Jorral.")
        API.DoAction_NPC(0x2c, API.OFF_ACT_InteractNPC_route, {IDS.Jorral}, 50)
        Sleep(0.3)
        print("Handling dialog with Jorral.")
        HandleDialog()
        Sleep(1)
        HandleDialog()

    else
        UpdateStatus("Quest Completed!!!")
        print("Quest Completed!!!")
        Sleep(5)
        API.Write_LoopyLoop(false)
    end

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
