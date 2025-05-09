ScriptName = "Restless Ghost Quest"
Author = "Spectre011"
ScriptVersion = "1.0.1"
ReleaseDate = "03-05-2025"
DiscordHandle = "not_spectre011"

--[[
Changelog:
v1.0.0 - 03-05-2025
    - Initial release.
v1.0.1 - 09-05-2025
    - Fixed QUEST functions to use : instead of .
]]

local API = require("api")
local QUEST = require("quest")

local step = 0
--------------------START GUI STUFF--------------------
local UIComponents = {}
local CurrentStatus = "nil"
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
local DialogOptions = {
    "I'm looking for a quest!",
    "Father Aereck sent me to talk to you.",
    "A ghost is haunting his graveyard.",
    "Yep. Now, tell me what the problem is.",
    "Put the skull in the coffin."
}

API.Write_fake_mouse_do(false)
while (API.Read_LoopyLoop()) do    
    step = API.VB_FindPSettinOrder(2324).state
    print("Step: "..tostring(step))

    if not API.IsPlayerMoving_(API.GetLocalPlayerName()) then        

        if step == 0 then -- Starting quest
            print("Step 0/5")
            UpdateStatus("Step 0/5")
        
            QUEST:MoveTo(3239, 3209, 0, 0)
        
            if not QUEST:Bool1Check(37002) then -- Closed door check
                Interact:Object("Church door", "Open", 10)
            else
                print("Church door is already open.")
            end
        
            Interact:NPC("Father Aereck", "Talk-to", 20)
            QUEST:WaitForDialogBox(15)
        
            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end
        
            API.DoAction_Interface(0x24, 0xffffffff, 1, 1500, 409, -1, API.OFF_ACT_GeneralInterface_route) --Accepting quest
        
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end  

        elseif step == 1 then -- Go talk to priest in swamp
            print("Step 1/5")
            UpdateStatus("Step 1/5")

            QUEST:MoveTo(3240, 3209, 0, 0)
            if not QUEST:Bool1Check(37002) then -- Closed door check
                Interact:Object("Church door", "Open", 10)
            else
                print("Church door is already open.")
            end

            QUEST:MoveTo(3207, 3152, 0, 0)
            if not QUEST:Bool1Check(45539) then -- Closed door check
                Interact:Object("Door", "Open", 10)
            else
                print("House door is already open.")
            end

            Interact:NPC("Father Urhney", "Talk-to", 20)
        
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

        elseif step == 2 then -- Equip amulet and talk to ghost
            print("Step 2/5")
            UpdateStatus("Step 2/5")

            QUEST:MoveTo(3207, 3151, 0, 0)
            if not QUEST:Bool1Check(45539) then -- Closed door check
                Interact:Object("Door", "Open", 10)
            else
                print("House door is already open.")
            end

            Inventory:Equip(552)
            
            QUEST:MoveTo(3248, 3193, 0, 1)
            if not QUEST:Bool1Check(89481) then -- Closed coffin check
                Interact:Object("Coffin", "Open", 10)
                QUEST:Sleep(5)
            else
                print("Coffin is already open.")
            end

            Interact:NPC("Restless ghost", "Talk-to", 10)
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

        elseif step == 3 then -- Get skull from rocks
            print("Step 3/5")
            UpdateStatus("Step 3/5")

            QUEST:MoveTo(3237, 3147, 0, 1)

            --Interact:Object("Rocks", "Search", 20) Is Bugged
            API.DoAction_Object1(0x38,API.OFF_ACT_GeneralObject_route0,{47714},50) --Use untill Interact if fixed
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

        elseif step == 4 then -- Place skull in coffin
            print("Step 4/5")
            UpdateStatus("Step 4/5")

            QUEST:MoveTo(3248, 3193, 0, 1)
            if not QUEST:Bool1Check(89481) then -- Closed coffin check
                Interact:Object("Coffin", "Open", 10)
                QUEST:Sleep(5)
            else
                print("Coffin is already open.")
            end

            Interact:NPC("Restless ghost", "Talk-to", 10)
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

            Interact:Object("Coffin", "Search", 10)
            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end
            QUEST:Sleep(5)

            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

            QUEST:Sleep(5)

            QUEST:WaitForDialogBox(15)

            while API.Read_LoopyLoop() and QUEST:DialogBoxOpen() do
                if QUEST:HasOption() then
                    QUEST:OptionSelector(DialogOptions)
                else
                    QUEST:PressSpace()
                end
            end

        elseif step == 5 then -- Quest completed
            print("Step 5/5")
            UpdateStatus("Step 5/5")

            print("Quest completed!!!")
            API.Write_LoopyLoop(false)
        else
            print("Something went horribly wrong!!!")
            print("Step from VB: "..tostring(step)..".")
            API.Write_LoopyLoop(false)
        end

    end
    
    QUEST:Sleep(0.3)
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
