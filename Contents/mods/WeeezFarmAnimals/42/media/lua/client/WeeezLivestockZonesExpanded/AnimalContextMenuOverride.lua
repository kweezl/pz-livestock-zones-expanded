local livestockZones = require("WeeezLivestockZonesExpanded/Module/LivestockZonesExpanded");

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
