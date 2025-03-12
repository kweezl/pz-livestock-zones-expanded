local livestockZones = require("WeeezLivestockZonesExpanded/Module/LivestockZonesExpanded");
local animalContextMenuDoMenu = AnimalContextMenu.doMenu;


local function onSetAnimalHealthConfirm(_, button, animal, playerObj)
    if button.internal ~= "OK" then
        return;
    end

    local input = button.parent.entry:getText();

    if not input or input == "" then
        return;
    end

    if isClient() then
        sendClientCommandV(playerObj, "animal", "setHealth", "id", animal:getOnlineID(), "value", input);
    else
        animal:setHealth(tonumber(input));
    end
end

local function onSetAnimalHealth(animal, playerNum)
    local modal = ISTextBox:new(0, 0, 280, 180, "Set animal health", tostring(animal:getHealth()), nil, onSetAnimalHealthConfirm, playerNum, animal, getSpecificPlayer(playerNum));
    modal:initialise();
    modal:addToUIManager();
    modal:setOnlyNumbers(true);

    if getJoypadData(playerNum) then
        modal.prevFocus = getJoypadFocus(playerNum)
        setJoypadFocus(playerNum, modal)
    end
end

local function onContextMenuAnimalZone(livestockZone, player, zonesController)
    zonesController:setActiveZone(livestockZone);
    ISEntityUI.OpenLivestockZones(player, nil)
end

function AnimalContextMenu.doDesignationZoneMenu(context, zone, player)
    local zonesController = livestockZones.getZonesController(player);
    local livestockZone = zonesController:getZoneById(zone:getId())

    if not livestockZone then
        return;
    end

    context:addOption(
        getText("ContextMenu_Animal_CheckZone", zone:getName()),
        livestockZone,
        onContextMenuAnimalZone,
        player,
        zonesController
    );
end

function AnimalContextMenu.doMenu(player, context, animal, test)
    animalContextMenuDoMenu(player, context, animal, test);

    if AnimalContextMenu.cheat then
        local options = context:getMenuOptionNames();
        local animalName = animal:getFullName();
        local animalOption = options[animalName];

        if not animalOption then
            return;
        end

        local animalSubmenu = context:getSubMenu(animalOption.subOption);

        if not animalSubmenu then
            return;
        end

        local animalOptions = animalSubmenu:getMenuOptionNames();
        local debugOption = animalOptions["Debug"];

        if not debugOption then
            return;
        end

        local debugSubmenu = context:getSubMenu(debugOption.subOption);

        if not debugSubmenu then
            return;
        end

        debugSubmenu:addDebugOption("Set animal health", animal, onSetAnimalHealth, player);
    end
end
