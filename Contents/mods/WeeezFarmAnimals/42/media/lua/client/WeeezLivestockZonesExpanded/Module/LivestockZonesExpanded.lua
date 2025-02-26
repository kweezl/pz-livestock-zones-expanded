local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local events = require("WeeezLivestockZonesExpanded/Module/LivestockZonesEvents");
local livestockZonesStorage = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesStorage");
local livestockZonesProvider = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesProvider");
local livestockZonesAnimals = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesAnimals");
local livestockZonesIcons = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesIcons");
local livestockZonesStatsProvider = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesStatsProvider");
local livestockZonesAnimalTypes = require("WeeezLivestockZonesExpanded/DataProviders/LivestockZonesAnimalTypes");
local livestockZonesController = require("WeeezLivestockZonesExpanded/Controllers/LivestockZonesController");

--- @type LivestockZonesIcons
local zonesIcons;
--- @type LivestockZonesProvider
local zonesProvider;
--- @type LivestockZonesAnimals
local animalsProvider;
--- @type LivestockZonesAnimalTypes
local zonesAnimalTypes;
--- @type LivestockZonesStatsProvider
local zoneStatsProvider;
--- @type LivestockZonesController
local zonesController;
--- @type LivestockZonesStorage
local zonesStorage;

---@module livestockZonesExpanded
local livestockZonesExpanded = {};

function livestockZonesExpanded.getZonesIcons()
    if not zonesIcons then
        zonesIcons = livestockZonesIcons.new();
    end

    return zonesIcons;
end

--- @return LivestockZonesProvider
function livestockZonesExpanded.getZonesProvider()
    if not zonesProvider then
        zonesProvider = livestockZonesProvider.new(
            livestockZonesExpanded.getAnimalTypes(),
            livestockZonesExpanded.getZonesStorage(),
            config.defaultZoneIcon
        );
    end

    return zonesProvider;
end

--- @param player IsoPlayer
--- @return LivestockZonesAnimals
function livestockZonesExpanded.getAnimalsProvider(player)
    assert(instanceof(player, "IsoPlayer"), "Player object required");

    if not animalsProvider then
        animalsProvider = livestockZonesAnimals.new(
            player,
            livestockZonesExpanded.getZonesIcons()
        );
    end

    return animalsProvider;
end

--- @param player IsoPlayer
--- @return LivestockZonesStatsProvider
function livestockZonesExpanded.getZoneStatsProvider(player)
    assert(instanceof(player, "IsoPlayer"), "Player object required");

    if not zoneStatsProvider then
        zoneStatsProvider = livestockZonesStatsProvider.new(player);
    end

    return zoneStatsProvider;
end

--- @return LivestockZonesAnimalTypes
function livestockZonesExpanded.getAnimalTypes()
    if not zonesAnimalTypes then
        zonesAnimalTypes = livestockZonesAnimalTypes.new();
    end

    return zonesAnimalTypes;
end

--- @return LivestockZonesStorage
function livestockZonesExpanded.getZonesStorage()
    if not zonesStorage then
        zonesStorage = livestockZonesStorage.new();
    end

    return zonesStorage;
end

--- @return LivestockZonesController
function livestockZonesExpanded.getZonesController(player)
    assert(instanceof(player, "IsoPlayer"), "Player object required");

    if not zonesController then
        zonesController = livestockZonesController.new(
            player,
            livestockZonesExpanded.getZonesProvider(),
            livestockZonesExpanded.getAnimalsProvider(player),
            livestockZonesExpanded.getZoneStatsProvider(player),
            livestockZonesExpanded.getZonesStorage(),
            livestockZonesExpanded.getAnimalTypes(),
            livestockZonesExpanded.getZonesIcons(),
            events,
            config.filterAllTextDefault
        );
    end

    return zonesController;
end

return livestockZonesExpanded;
