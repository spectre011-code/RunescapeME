ScriptName = "The Blood Pact Quest"
Author = "Spectre011"
ScriptVersion = "1.0.0"
ReleaseDate = "08-05-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0.0 - 08-05-2025
    - Initial release.
]]

local API = require("api")
local QUEST = require("quest") -- https://github.com/spectre011-code/RunescapeME/blob/main/Libraries/quest.lua

--------------------START GUI STUFF--------------------
local CurrentStatus = "Starting"
local QuestProgress = 0
local IdleTicks = 0
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
    AddBackground("Background", 0.85, 1, ImColor.new(15, 13, 18, 255))
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " by " .. Author, ImColor.new(238, 230, 0))
    AddLabel("Status", "Status: " .. CurrentStatus, ImColor.new(238, 230, 0))
end

local function UpdateStatus(newStatus)
    CurrentStatus = newStatus
    local statusLabel = GetComponentByName("Status")
    if statusLabel then
        statusLabel[2].string_value = "Quest progress: " .. CurrentStatus
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
local AdventureInterface = { { 1500,0,-1,0 }, { 1500,1,-1,0 }, { 1500,22,-1,0 } }

local ChatOptions = {
    "What help do you need?",
    "I'll help you.",
    "I can handle this.",
    "Yes. Now die!",
    "Time for you to die!",
    "I'm your worst nightmare, Zamorakian scum!",
    "Yes, rescue Ilona.",
    "I'm ready for my reward."
}

local Weapons = {
    15596, --MH
    30053, --OH
    15597, --Bow
    15598, --Staff
}

-- Handles the quest dialog interaction loop.
---@return boolean
local function HandleDialog()
    if not QUEST:DialogBoxOpen() then
        return false
    end

    while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
        if QUEST:HasOption() then
            QUEST:OptionSelector(ChatOptions)
        else
            QUEST:PressSpace()
        end
        QUEST:Sleep(0.2)
    end

    return true
end

-- Checks if the accept quest interface is open
---@return boolean
local function IsAcceptQuestInterfaceOpen()
    if #API.ScanForInterfaceTest2Get(true, AdventureInterface) > 0 then
        return true
    else 
        return false 
    end
end

-- Checks if a specific item is present on the ground nearby.
---@param itemID number
---@return boolean
local function IsItemOnGround(itemID)
    return #API.GetAllObjArray1({itemID}, 15, {3}) > 0
end

API.Write_fake_mouse_do(false)
API.SetMaxIdleTime(5)
while API.Read_LoopyLoop() do
    QuestProgress = Quest:Get("The Blood Pact"):getProgress()
    print("Quest Progress: "..tonumber(QuestProgress))
    UpdateStatus(tonumber(QuestProgress).."/60")

     -- Idle ticks check
     if IdleTicks > 0 then
        print("Idle ticks greater than 0: "..tonumber(IdleTicks)..". Skipping cycle.")
        goto continue
    end

    -- Handles dialog
    if QUEST:DialogBoxOpen() then
        print("Handling dialogs.")
        HandleDialog()
    end

    -- Player in combat check
    if API.LocalPlayer_IsInCombat_() then
        print("Player in combat. Skipping cycle.")
        goto continue
    end

    -- Player animating check
    if API.IsPlayerAnimating_(API.GetLocalPlayerName(), 15) then
        print("Player animating. Skipping cycle.")
        goto continue
    end

    -- Player moving check
    if API.IsPlayerMoving_(API.GetLocalPlayerName()) then
        print("Player moving. Skipping cycle.")
        goto continue
    end    

    -- Collect items from the ground
    for i = 1, #Weapons do
        if IsItemOnGround(Weapons[i]) then
            print("Collecting items from the ground")
            API.DoAction_G_Items1(0x2d,{Weapons[i]},50)
            goto continue
        end
    end

    -- Accept quest interface check
    if IsAcceptQuestInterfaceOpen() then
        print("Accepting quest.")
        API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route)
        goto continue
    end

    -- Checks if player is in cutscene
    if QUEST:IsInCutscene() then
        print("Player in cutscene. Skipping cycle.")
        goto continue
    end

    if QuestProgress == 0 then -- Quest not started
        
        --[[
        This interact is not working currently

        if not Interact:NPC("Xenia", "Talk to", 10) then
            QUEST:MoveTo(3244, 3197, 0, 1)
        else
            IdleTicks = 2
            goto continue
        end
        ]]

        if not API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{9633},15) then --Talk to Xenia
            QUEST:MoveTo(3244, 3197, 0, 1)
        else
            IdleTicks = 2
            goto continue
        end

    elseif QuestProgress == 10 then -- Started quest
        API.DoAction_Interface(0xffffffff,0xffffffff,1,955,15,-1,API.OFF_ACT_GeneralInterface_route) --Ok Big yellow Button
        Interact:Object("Catacombs", "Enter", 10)
        QUEST:WaitForDialogBox(10)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 12 then -- After cutscene
        API.DoAction_Tile(WPOINT.new(API.PlayerCoord().x,API.PlayerCoord().y + 10,0))
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 15 then -- After walking north
        Inventory:Equip("Bronze dagger")
        QUEST:Sleep(1)
        API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{9636},15)
        QUEST:WaitForDialogBox(10)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 20 then -- After Equiping bronze dagger and talking to Xenia
        Interact:NPC("Kayle", "Attack", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 25 then -- After defeating Kayle
        --No action needed here.
        IdleTicks = 6
        goto continue

    elseif QuestProgress == 30 then -- After killing Kayle
        Inventory:Equip("Kayle's chargebow")
        QUEST:Sleep(1)
        Interact:Object("Tomb door", "Open", 20)
        QUEST:Sleep(5)
        Interact:NPC("Caitlin", "Attack", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 35 then -- After defeating Caitlin
        Interact:Object("Winch", "Operate", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 36 then -- After operating Winch
        Interact:NPC("Caitlin", "Talk to", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 40 then -- After killing Caitlin
        Inventory:Equip("Caitlin's staff")
        QUEST:Sleep(1)
        Interact:Object("Stairs", "Climb down", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 41 then -- After answering Reese
        Interact:NPC("Reese", "Attack", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 45 then -- After defeating Reese
        --No action needed here.
        IdleTicks = 6
        goto continue

    elseif QuestProgress == 50 then -- After killing Reese
        Interact:NPC("Ilona", "Untie", 50)
        IdleTicks = 2
        goto continue

    elseif QuestProgress == 55 then -- After Untying Ilona
        --No action needed here.
        IdleTicks = 6
        goto continue

    elseif QuestProgress == 60 then -- Quest Complete
        print("Quest Completed!")
        API.Write_LoopyLoop(false)
        break
    else
        print("Unkown Quest Progress: "..tonumber(QuestProgress)..".")
        API.Write_LoopyLoop(false)
        break
    end

    ::continue::
    QUEST:Sleep(0.6)
    IdleTicks = IdleTicks - 1
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
