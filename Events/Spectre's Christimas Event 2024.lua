ScriptName = "Christmas Event 2024"
Author = "Spectre011"
ScriptVersion = "1.0"
ReleaseDate = "16-12-2024"
Discord = "not_spectre011"

--[[
Changelog:
v1.0 - 16-12-2024
    - Initial release.
]]

local API = require("api")
local UTILS = require("utils")

local stageID = 0
local importantObjects = {
    ["pileOfSnow"]      = 128785,
    ["snowball"]        = 33590,
    ["smokey"]          = 30756,
    ["icyFishSpot"]     = 30755,
    ["barrelOfFish"]    = 128783,
    ["frozenTrout"]     = 56165,
    ["frozenSalmon"]    = 56166,
    ["frozenBass"]      = 56167,
    ["decorBench"]      = 128793,
    ["crateOfUnfDecor"] = 128787,
    ["crateOfFinDecor"] = 128788,
    ["unfDecor"]        = 56168,
    ["WIPDecor"]        = 56169,
    ["finishedDecor"]   = 56170,
    ["fir"]             = 131808,
    ["splittingStump"]  = 131812,
    ["splitLogPile"]    = 131813,
    ["firLog"]          = 57922,
    ["splitFirLogs"]    = 57923,
    ["hotChocPot"]      = 131826,
    ["sugar"]           = 131822,
    ["milk"]            = 131824,
    ["firewood"]        = 131821,
    ["chocolate"]       = 131823,
    ["spices"]          = 131825,
    ["highlight"]       = 7164,
    ["dryFirWood"]      = 57924,
    ["dollRaw"]         = 57928,
    ["dollHandle"]      = 57930,
    ["dollPainted"]     = 57929,
    ["dollFinished"]    = 57931,
    ["crateOfWood"]     = 131814,
    ["carvingBench"]    = 131816,
    ["paintingBench"]   = 131818,
    ["finishingBench"]  = 131820,
    ["maeve"]           = 31459
}
--------------------START GUI STUFF--------------------
local SelectedOption = nil
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
    AddLabel("Author/Version", ScriptName .. " v" .. ScriptVersion .. " - " .. Author, ImColor.new(238, 230, 0))
    AddLabel("ComboBoxLabel", "Select an activity:", ImColor.new(255, 255, 255))
    local options = {"- none - ", "Fletching Snowballs", "Ice Fishing", "Decoration Making", "Fir Woodcutting", "Cooking Hot Chocolate", "Crafting Toys"}
    AddComboBox("ComboBox", " ", options)
    AddCheckbox("CoolSmokey", "Cool down Smokey (fletch spot)")
    AddCheckbox("AddIngredients", "Add ingredients (cook spot)")
end

local function SetComboBoxOption()
    SelectedOption = GetComponentValue("ComboBox") or SelectedOption
    if SelectedOption == "- none - "                then stageID = 0 end
    if SelectedOption == "Fletching Snowballs"      then stageID = 1 end
    if SelectedOption == "Ice Fishing"              then stageID = 2 end
    if SelectedOption == "Decoration Making"        then stageID = 3 end
    if SelectedOption == "Fir Woodcutting"          then stageID = 4 end
    if SelectedOption == "Cooking Hot Chocolate"    then stageID = 5 end
    if SelectedOption == "Crafting Toys"            then stageID = 6 end
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
EndTable[7] = {"Discord: ".. Discord}

--------------------END END TABLE STUFF--------------------

local function doesThingExists(id, type)
    local var = #API.GetAllObjArray1({id}, 50, {type})
    return var > 0
end

local StageDescriptions = {
    [1] = "Fletching Snowballs",
    [2] = "Ice Fishing",
    [3] = "Decoration Making",
    [4] = "Fir Woodcutting",
    [5] = "Cooking Hot Chocolate",
    [6] = "Crafting Toys",
}
local snowballQuantity = Inventory:GetItemAmount(importantObjects.snowball) or 0
local freeInvSpaces = Inventory:FreeSpaces() or 0
local constructionXP = API.GetSkillXP("CONSTRUCTION") or 0
local cookingXP = API.GetSkillXP("COOKING") or 0
local stageFunctions = {
    [1] = function()
        print("Fletching Snowballs")
        if not API.PInArea21(5195, 5210, 9772, 9780) then
            API.DoAction_WalkerW(WPOINT.new(5206 + math.random(-2, 2), 9775 + math.random(-2, 2), 0))
        end
        if Inventory:FreeSpaces() == 0 then
            if not Inventory:Contains(importantObjects.snowball) then
                print("No free spaces in inventory for snowballs!!")
                API.Write_LoopyLoop(false)
            end
        end
        API.Sleep_tick(3)
        if Inventory:GetItemAmount(importantObjects.snowball) == snowballQuantity then
            API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{importantObjects.pileOfSnow},50)
            API.Sleep_tick(5)
        end
        local checkboxValue = GetComponentValue("CoolSmokey")
        if checkboxValue ~= nil then isChecked = checkboxValue end
        if isChecked then
            if doesThingExists(importantObjects.smokey, 1) then
                UTILS.randomSleep(2000)
                Inventory:Equip(importantObjects.snowball)
                UTILS.randomSleep(1000)
                while API.Read_LoopyLoop() and doesThingExists(importantObjects.smokey, 1) do
                    API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route,{importantObjects.smokey},50)
                    UTILS.randomSleep(700)
                end
            end
        end
        snowballQuantity = Inventory:GetItemAmount(importantObjects.snowball)
    end,

    [2] = function()
        print("Ice Fishing")
        if not API.PInArea21(5194, 5205, 9776, 9794) then
            API.DoAction_WalkerW(WPOINT.new(5201 + math.random(-1, 1), 9783 + math.random(-1, 1), 0))
        end
        if Inventory:FreeSpaces() == 0 then
            if not Inventory:Contains(importantObjects.frozenTrout) and not Inventory:Contains(importantObjects.frozenSalmon) and not Inventory:Contains(importantObjects.frozenBass) then   
                print("No free spaces in inventory for fish!!")
                API.Write_LoopyLoop(false)
            else
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{importantObjects.barrelOfFish},50)
                while API.Read_LoopyLoop() and Inventory:FreeSpaces() == 0 do
                    UTILS.randomSleep(1000)
                end
            end
        end
        API.Sleep_tick(8)
        if Inventory:FreeSpaces() == freeInvSpaces then
            API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route,{importantObjects.icyFishSpot},50)
            API.Sleep_tick(10)
        end
        freeInvSpaces = Inventory:FreeSpaces()
    end,

    [3] = function()
        print("Decoration Making")
        if not API.PInArea21(5250, 5253, 9778, 9781) then
            API.DoAction_WalkerW(WPOINT.new(5252 + math.random(-1, 1), 9780 + math.random(-1, 1), 0))
        end
        if Inventory:FreeSpaces() == 0 then
            if not Inventory:Contains(importantObjects.unfDecor) and not Inventory:Contains(importantObjects.WIPDecor) and not Inventory:Contains(importantObjects.finishedDecor) then
                print("No free spaces in inventory for unfinished decoration!!")
                API.Write_LoopyLoop(false)
            end
            if Inventory:Contains(importantObjects.unfDecor) or Inventory:Contains(importantObjects.WIPDecor) then
                constructionXP = API.GetSkillXP("CONSTRUCTION")
                API.Sleep_tick(5)
                if API.GetSkillXP("CONSTRUCTION") == constructionXP then
                    API.DoAction_Object1(0xae,API.OFF_ACT_GeneralObject_route0,{importantObjects.decorBench},50)
                    API.Sleep_tick(10)
                else
                    UTILS.randomSleep(3000)
                end
            end
            if Inventory:Contains(importantObjects.finishedDecor) and not Inventory:Contains(importantObjects.unfDecor) and not Inventory:Contains(importantObjects.WIPDecor) then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{importantObjects.crateOfFinDecor},50)
                while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.finishedDecor) do
                    UTILS.randomSleep(3000)
                end
            end
        else
            while API.Read_LoopyLoop() and Inventory:FreeSpaces() ~= 0 do
                API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,{importantObjects.crateOfUnfDecor},50)
                UTILS.randomSleep(350)
            end
        end
    end,

    [4] = function()
        print("Fir Woodcutting")
        if not API.PInArea21(5223, 5243, 9770, 9790) then
            API.DoAction_WalkerW(WPOINT.new(5233 + math.random(-2, 2), 9780 + math.random(-2, 2), 0))
        end
        if Inventory:FreeSpaces() == 0 then
            if not Inventory:Contains(importantObjects.firLog) or Inventory:Contains(importantObjects.splitFirLogs) then
                print("No free spaces in inventory for logs!!")
                API.Write_LoopyLoop(false)
            end
            if Inventory:Contains(importantObjects.firLog) then
                API.DoAction_Object1(0x3b,API.OFF_ACT_GeneralObject_route0,{importantObjects.splittingStump},50)
                while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.firLog) do
                    UTILS.randomSleep(1000)
                end
            end
            if Inventory:Contains(importantObjects.splitFirLogs) then
                API.DoAction_Object1(0x29,API.OFF_ACT_GeneralObject_route0,{importantObjects.splitLogPile},50)
                while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.splitFirLogs) do
                    UTILS.randomSleep(1000)
                end
            end
        else
            freeInvSpaces = Inventory:FreeSpaces()
            UTILS.randomSleep(5000)
            if Inventory:FreeSpaces() == freeInvSpaces then
                API.DoAction_Object1(0x3b,API.OFF_ACT_GeneralObject_route0,{importantObjects.fir},50)
            end
        end
    end,

    [5] = function()
        print("Cooking Hot Chocolate")
        --This is needed as I couldnt find a way to get the ingredient from the chat due to a bug(I think), so it reads the coordinates of the highlight and compares
        --to the ingredients and find which one needs to be added to the pot
        local ingredients = {
            sugar       = {id = 131822, coordX = 5249, coordY = 9770},
            milk        = {id = 131824, coordX = 5245, coordY = 9767},
            firewood    = {id = 131821, coordX = 5244, coordY = 9766},
            chocolate   = {id = 131823, coordX = 5241, coordY = 9768},
            spices      = {id = 131825, coordX = 5241, coordY = 9770}
        }
        
        local function findIngredientId(objects, ingredientsTable)
            for _, object in ipairs(objects) do
                local objX = math.floor(object.TileX / 512)
                local objY = math.floor(object.TileY / 512)
        
                for name, ingredient in pairs(ingredientsTable) do
                    if ingredient.coordX == objX and ingredient.coordY == objY then
                        return ingredient.id 
                    end
                end
            end
        
            return nil
        end
        if not API.PInArea21(5242, 5247, 9769, 9774) then
            API.DoAction_WalkerW(WPOINT.new(5246 + math.random(-1, 1), 9771 + math.random(-1, 1), 0))
        end
        if Inventory:FreeSpaces() == 0 then
            print("No free spaces in inventory for the ingredients!!")
            API.Write_LoopyLoop(false)
        end
        cookingXP = API.GetSkillXP("COOKING")
        API.Sleep_tick(5)
        if API.GetSkillXP("COOKING") == cookingXP then
            API.DoAction_Object1(0x40,API.OFF_ACT_GeneralObject_route0,{importantObjects.hotChocPot},50)
        end
        local checkboxValue = GetComponentValue("AddIngredients")
        if checkboxValue ~= nil then isChecked = checkboxValue end
        if isChecked then
            local var = API.GetAllObjArray1({7164}, 10, {4}) -- Check for highlight
            local matchingId = findIngredientId(var, ingredients)
            if matchingId then
                freeInvSpaces = Inventory:FreeSpaces()
                API.DoAction_Object1(0x2d,API.OFF_ACT_GeneralObject_route0,{matchingId},50)            
                while API.Read_LoopyLoop() and Inventory:FreeSpaces() == freeInvSpaces do
                    UTILS.randomSleep(1000)
                end
                API.DoAction_Object1(0x40,API.OFF_ACT_GeneralObject_route0,{importantObjects.hotChocPot},50)
            end
        end
    end,
    
    [6] = function()
        print("Crafting Toys")
        local function enoughForDoll()
            if Inventory:Contains(importantObjects.dollPainted) and Inventory:Contains(importantObjects.dollHandle) then
                return true
            else
                return false
            end
        end
        if not API.PInArea21(5245, 5253, 9782, 9789) then
            API.DoAction_WalkerW(WPOINT.new(5248 + math.random(-1, 1), 9787 + math.random(-1, 1), 0))
        end
        freeInvSpaces = Inventory:FreeSpaces()
        if (freeInvSpaces + Inventory:GetItemAmount(importantObjects.dryFirWood)) < 5 then
            print("No free spaces in inventory for the dry wood!!")
            API.Write_LoopyLoop(false)
        end
        if Inventory:Contains(importantObjects.dollFinished) then
            API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{importantObjects.maeve},50)
            while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.dollFinished) do
                UTILS.randomSleep(500)
            end
        end
        if enoughForDoll() then
            API.DoAction_Object1(0x3e,API.OFF_ACT_GeneralObject_route0,{importantObjects.finishingBench},50)
            while API.Read_LoopyLoop() and enoughForDoll() do
                UTILS.randomSleep(500)
            end
        end
        if Inventory:Contains(importantObjects.dollRaw) then
            API.DoAction_Object1(0x3e,API.OFF_ACT_GeneralObject_route0,{importantObjects.paintingBench},50)
            while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.dollRaw) do
                UTILS.randomSleep(500)
            end
        end
        if Inventory:GetItemAmount(importantObjects.dryFirWood) > 4 then
            API.DoAction_Object1(0x3e,API.OFF_ACT_GeneralObject_route0,{importantObjects.carvingBench},50)
            while API.Read_LoopyLoop() and Inventory:Contains(importantObjects.dryFirWood) do
                UTILS.randomSleep(500)
            end
        end
        if (freeInvSpaces + Inventory:GetItemAmount(importantObjects.dryFirWood)) > 4 then
            API.DoAction_Object1(0x3e,API.OFF_ACT_GeneralObject_route0,{importantObjects.crateOfWood},50)
            while API.Read_LoopyLoop() and Inventory:FreeSpaces() ~= 0 do
                UTILS.randomSleep(500)
            end
        end
    end
}

local function executeStage(stageID)
    if stageFunctions[stageID] then
        stageFunctions[stageID]()
    else
        print("Select an activity")
    end
end

Write_fake_mouse_do(false)
API.SetDrawTrackedSkills(true)

while (API.Read_LoopyLoop()) do
    UTILS:antiIdle()   
    SetComboBoxOption()
    if stageID == 0 then
        print("Select an activity")
    end
    if stageID ~= nil and stageID ~= 0 then 
        executeStage(stageID)
        API.Sleep_tick(1)
    end
    collectgarbage("collect")
end

API.DrawTable(EndTable)
print("----------//----------")
print("Script Name: " .. ScriptName)
print("Author: " .. Author)
print("Version: " .. ScriptVersion)
print("Release Date: " .. ReleaseDate)
print("Discord: " .. Discord)
print("----------//----------")
