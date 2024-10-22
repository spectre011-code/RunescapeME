ScriptName = "Archaeology Tutorial"
Author = "Spectre011"
ScriptVersion = "1.0"
ReleaseDate = "22-10-2024"
Discord = "not_spectre011"

--[[
Changelog:
v1.0 - 22-10-2024
    - Initial release.
]]

local API = require("api")
local UTILS = require("utils")

--------------------START GUI STUFF--------------------
local UIComponents = {}
local function GetComponentAmount()
    local amount = 0
    for i,v in pairs(UIComponents) do
        amount = amount + 1
    end
    return amount
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
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " - " .. Author, ImColor.new(238, 230, 0))
end

CreateGUI()
GUIDraw()
--------------------END GUI STUFF--------------------
local EndTable = {
    {"-"}
}
EndTable[1] = {"Thanks for using my script!"}
EndTable[2] = {"Script's Name: ".. ScriptName}
EndTable[3] = {"Script's Author: ".. Author}
EndTable[4] = {"Script's Version: ".. ScriptVersion}
EndTable[5] = {"Script's Release Date: ".. ReleaseDate}
EndTable[6] = {"Author's Discord: ".. Discord}   

--Simple sleep
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

local function WaitForDialogThenPressSpacebar(phrase, timeout, sleep_time)
    local start_time = os.time()
    while os.time() - start_time < timeout do
        local npc_dialog_text = API.Dialog_Read_NPC()
        local player_dialog_text = API.Dialog_Read_Player()
        if string.find(npc_dialog_text, phrase) or string.find(player_dialog_text, phrase) then
            print("Found dialog: ", phrase)
            API.KeyboardPress31(32, 0, 0)
            return
        end
        Sleep(sleep_time)
    end
    print("Timedout and did not found dialog: ", phrase)
    return
end

local function is_item_in_inventory(itemID)
    local var = UTILS.findItemInInventory(itemID)
    if var ~= nil then
        return true
    else
        return false
    end
end

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
    WaitForObjectToAppear(26927, 1)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26927},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("Are you here", 50, 0.1)
    WaitForDialogThenPressSpacebar("Maybe. Why would I want", 60, 0.1)
    WaitForDialogThenPressSpacebar("You want the sales pitch", 60, 0.1)
    WaitForDialogThenPressSpacebar("Well, I'm sure one of these", 60, 0.1)
    WaitForDialogThenPressSpacebar("Wealth is the easy one", 60, 0.1)
    WaitForDialogThenPressSpacebar("Power comes in the form", 60, 0.1)
    WaitForDialogThenPressSpacebar("Fame comes in the form", 60, 0.1)
    WaitForDialogThenPressSpacebar("And finally, the stories", 60, 0.1)
    WaitForDialogThenPressSpacebar("Well, I'm sure at least one", 60, 0.1)
    WaitForDialogThenPressSpacebar("Those can come later", 60, 0.1)
    WaitForDialogThenPressSpacebar("Great. So, er,", 60, 0.1)
    WaitForDialogThenPressSpacebar("First off,", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("Those tools I just handed", 60, 0.1)
    WaitForDialogThenPressSpacebar("However, we've been developing", 60, 0.1)
    WaitForDialogThenPressSpacebar("Take this bronze mattock", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    local inv = Inventory:IsOpen()
    if inv == false then
        API.DoAction_Interface(0xc2,0xffffffff,1,1432,5,1,API.OFF_ACT_GeneralInterface_route) -- Opens inventory
    end
    local IsMattockInInventory = is_item_in_inventory(49534)
    while not IsMattockInInventory and API.Read_LoopyLoop() do
        Sleep(1)
        IsMattockInInventory = is_item_in_inventory(49534)
    end    
    API.DoAction_Inventory1(49534,0,1,API.OFF_ACT_GeneralInterface_route) -- Adds mattock to tool belt
    WaitForDialogThenPressSpacebar("Now, excavation is one", 60, 0.1)
    WaitForDialogThenPressSpacebar("them, like that Senntisten", 60, 0.1)
    WaitForDialogThenPressSpacebar("Your main goal will be", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    Sleep(1.2)
    --116392 virgin Senntisten soil ID
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{116392},50)
    WaitForObjectToAppear(116393, 0)
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{116393},50)
    WaitForDialogThenPressSpacebar("Yes, I've found some soil", 50, 0.1)
    WaitForDialogThenPressSpacebar("Ah, a material", 50, 0.1)
    local IsCenturionSwordInInventory = is_item_in_inventory(49741)
    while not IsCenturionSwordInInventory and API.Read_LoopyLoop() do
        Sleep(1)
        IsCenturionSwordInInventory = is_item_in_inventory(49741)
    end
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    API.DoAction_Inventory1(49741,0,3,API.OFF_ACT_GeneralInterface_route) -- Inspect Centurion's Sword
    Sleep(1.2)
    API.DoAction_Interface(0xffffffff,0xffffffff,1,955,15,-1,API.OFF_ACT_GeneralInterface_route) --Clicking big yellow CONTINUE button
    Sleep(1.2)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26927},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("So, I found some soil", 60, 0.1)
    WaitForDialogThenPressSpacebar("Upon inspection", 60, 0.1)
    WaitForDialogThenPressSpacebar("Well, one way to find", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    API.DoAction_Object1(0x1,API.OFF_ACT_GeneralObject_route0,{115419},50) -- Click Screen Mesh
    local IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
    while not IsCraftingInterfaceOpen and API.Read_LoopyLoop() do
        Sleep(1)
        IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
    end
    Sleep(0.5)
    API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option) --Click Screen button
    local HasSoilInInventory = is_item_in_inventory(49516)
    while not HasSoilInInventory and API.Read_LoopyLoop() do
        Sleep(1)
        HasSoilInInventory = is_item_in_inventory(49516)
    end
    WaitForDialogThenPressSpacebar("Right, that should be enough", 60, 0.1)
    WaitForDialogThenPressSpacebar("Screening is a good way", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("Damaged artefacts require", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("See if you can restore", 60, 0.1)
    API.DoAction_WalkerW(WPOINT.new(3358 + math.random(-1, 1), 3396 + math.random(-1, 1), 0))
    WaitForObjectToAppear(116438, 0)
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{116438},50) -- Open material storage
    Sleep(15)
    API.DoAction_Interface(0x24,0xffffffff,1,660,30,-1,API.OFF_ACT_GeneralInterface_route) -- Deposit all materials
    Sleep(1.2)
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{115421},50) -- Click Arch Workbench
    local IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
    while not IsCraftingInterfaceOpen and API.Read_LoopyLoop() do
        Sleep(1)
        IsCraftingInterfaceOpen = UTILS.isCraftingInterfaceOpen()
    end
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    local HasRestoredSword = is_item_in_inventory(49742)
    while not HasRestoredSword and API.Read_LoopyLoop() do
        Sleep(1)
        HasRestoredSword = is_item_in_inventory(49742)
    end
    API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
    WaitForObjectToAppear(26927, 1)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26927},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("Congratulations!", 60, 0.1)
    WaitForDialogThenPressSpacebar("There are collectors", 60, 0.1)
    WaitForDialogThenPressSpacebar("Velucia is a collector", 60, 0.1)
    API.DoAction_WalkerW(WPOINT.new(3343, 3385, 0))
    --26923 Velucia ID
    WaitForObjectToAppear(26923, 1)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26923},50)
    WaitForDialogThenPressSpacebar("Is that a", 60, 0.1)
    Sleep(1.2)
    API.DoAction_Interface(0xffffffff,0xffffffff,1,955,15,-1,API.OFF_ACT_GeneralInterface_route) -- Another big yellow CONTINUE button
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,656,25,0,API.OFF_ACT_GeneralInterface_route) -- Contribute all button
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("Thanks for", 60, 0.1)
    WaitForDialogThenPressSpacebar("There are many collectors", 60, 0.1)
    WaitForDialogThenPressSpacebar("The museum is also", 60, 0.1)
    WaitForDialogThenPressSpacebar("I'd best report back", 60, 0.1)
    API.DoAction_WalkerW(WPOINT.new(3385 + math.random(-4, 4), 3392 + math.random(-4, 4), 0))
    WaitForObjectToAppear(26927, 1)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26927},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("Velucia handed me", 60, 0.1)
    WaitForDialogThenPressSpacebar("that is unusual", 60, 0.1)
    WaitForDialogThenPressSpacebar("Everyone has been too", 60, 0.1)
    WaitForDialogThenPressSpacebar("Hmm, we should see", 60, 0.1)
    API.DoAction_WalkerW(WPOINT.new(3363, 3383, 0))
    --115415 mysterious monolyth ID
    WaitForObjectToAppear(115415, 0)
    API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route1,{115415},50)
    WaitForDialogThenPressSpacebar("Amazing!", 60, 0.1)
    WaitForDialogThenPressSpacebar("Wait! That was", 60, 0.1)
    WaitForDialogThenPressSpacebar("Guildmaster Tony", 60, 0.1)
    WaitForDialogThenPressSpacebar("We've made it off limits", 60, 0.1)
    WaitForDialogThenPressSpacebar("I just had a feeling", 60, 0.1)
    WaitForDialogThenPressSpacebar("Wow. How many interns", 60, 0.1)
    WaitForDialogThenPressSpacebar("I'm sorry", 60, 0.1)
    Sleep(1.2)
    API.DoAction_Interface(0x2e,0xffffffff,1,691,71,-1,API.OFF_ACT_GeneralInterface_route) -- Another big yellow CONTINUE button
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,691,57,-1,API.OFF_ACT_GeneralInterface_route) -- Harness power
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,691,150,-1,API.OFF_ACT_GeneralInterface_route) -- Select slot 1
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,691,146,-1,API.OFF_ACT_GeneralInterface_route) -- Confirm
    WaitForDialogThenPressSpacebar("You managed to access", 60, 0.1)
    WaitForDialogThenPressSpacebar("Here I was thinking", 60, 0.1)
    WaitForDialogThenPressSpacebar("I've only assumed", 60, 0.1)
    WaitForDialogThenPressSpacebar("Speaking of which", 60, 0.1)
    Sleep(7)
    API.DoAction_Tile(WPOINT.new(3325,3376,0))
    WaitForObjectToAppear(26929, 1)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26929},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("I believe you have", 60, 0.1)
    WaitForDialogThenPressSpacebar("More than that", 60, 0.1)
    WaitForDialogThenPressSpacebar("Feel free to make", 60, 0.1)
    WaitForDialogThenPressSpacebar("Before you go", 60, 0.1)
    WaitForDialogThenPressSpacebar("This table contains", 60, 0.1)
    Sleep(3)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("Matty Ock sells", 60, 0.1)
    Sleep(3)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("When you get new", 60, 0.1)
    Sleep(3)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("You'll need to get your", 60, 0.1)
    Sleep(3)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("For now, they are stocking", 60, 0.1)
    Sleep(3)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("Go and grab yourself", 60, 0.1)
    API.DoAction_Tile(WPOINT.new(3321,3382,0))
    Sleep(3)
    --26937 Ezreal ID
    API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2,{26937},50) --Open Ezreal shop
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,1594,19,0,API.OFF_ACT_GeneralInterface_route) -- Claim soil box
    Sleep(1.2)
    API.DoAction_Interface(0x24,0xffffffff,1,1594,54,-1,API.OFF_ACT_GeneralInterface_route) --Confirm
    Sleep(1.2)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{26929},50) -- Click Acting Guildmaster Reiniger bruh
    WaitForDialogThenPressSpacebar("Excellent!", 60, 0.1)
    WaitForDialogThenPressSpacebar("Now you have nearly", 60, 0.1)
    WaitForDialogThenPressSpacebar("The final thing", 60, 0.1)
    Sleep(1.2)
    API.KeyboardPress31(32, 0, 0)
    WaitForDialogThenPressSpacebar("All archaeologists", 60, 0.1)
    WaitForDialogThenPressSpacebar("Checking in on", 60, 0.1)
    WaitForDialogThenPressSpacebar("Feel free to stick it in", 60, 0.1)
    WaitForDialogThenPressSpacebar("And without further ado", 60, 0.1)

    Sleep(5)
    API.Write_LoopyLoop(false)
end

local EndTable = {
    {"-"}
}
EndTable[1] = {"Thanks for using my script!"}
EndTable[2] = {"Script's Name: ".. ScriptName}
EndTable[3] = {"Script's Author: ".. Author}
EndTable[4] = {"Script's Version: ".. ScriptVersion}
EndTable[5] = {"Script's Release Date: ".. ReleaseDate}
EndTable[6] = {"Author's Discord: ".. Discord}   

API.DrawTable(EndTable)

print("----------//----------")
print("Script Name: " .. ScriptName)
print("Script Author: " .. Author)
print("Script Version: " .. ScriptVersion)
print("Script Release Date: " .. ReleaseDate)
print("Author Discord: " .. Discord)
print("----------//----------")

