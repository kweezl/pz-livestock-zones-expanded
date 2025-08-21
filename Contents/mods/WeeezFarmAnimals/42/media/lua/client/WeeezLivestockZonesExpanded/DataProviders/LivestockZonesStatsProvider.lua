local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local livestockZoneStats = require("WeeezLivestockZonesExpanded/Entity/LivestockZoneStats");
local livestockZoneStat = require("WeeezLivestockZonesExpanded/Enums/LivestockZoneStat");
local stat = livestockZoneStat.stat;

--- @module livestockZonesDetails
local livestockZonesDetailsProvider = {};


--- @class LivestockZonesStatsProvider
local LivestockZonesStatsProvider = {};

--- @param type LivestockZoneStats
--- @return boolean
function LivestockZonesStatsProvider:isAvailableToSee(type)
    local details = config.livestockZoneDetails[type];

    if not details or not details.perk or not details.level then
        return true;
    end

    return self.player:getPerkLevel(details.perk) >= details.level;
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getAnimalsTotal(livestockZone)
    if not self:isAvailableToSee(stat.animal) then
        return nil;
    end

    local zone = livestockZone:getAnimalZone();
    local hutches = zone:getHutchsConnected();
    local result = 0;

    for i = 0, hutches:size() - 1 do
        local hutch = hutches:get(i);
        result = result + hutch:getAnimalInside():size();
    end

    return result + livestockZone:getAnimalZone():getAnimalsConnected():size();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getConnectedZonesTotal(livestockZone)
    if not self:isAvailableToSee(stat.connectedZone) then
        return nil;
    end

    return livestockZone:getConnectedZones():size();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getFoodTotal(livestockZone)
    if not self:isAvailableToSee(stat.food) then
        return nil;
    end

    local result = 0;
    local zone = livestockZone:getAnimalZone();

    for i=0, zone:getFoodOnGroundConnected():size()-1 do
        local food = zone:getFoodOnGroundConnected():get(i):getItem();

        if instanceof(food, "Food") then
            result = result + (math.abs(food:getHungChange()));
        end

        if instanceof(food, "DrainableComboItem") then
            -- 1 use of a drainable = 0.1 food reduction;
            result = result + (food:getCurrentUsesFloat() / food:getUseDelta()) * 0.1;
        end
    end

    for i=0, zone:getTroughsConnected():size()-1 do
        result = result + zone:getTroughsConnected():get(i):getCurrentFeedAmount();
    end

    return round(result, 2);
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getDungTotal(livestockZone)
    if not self:isAvailableToSee(stat.dung) then
        return nil;
    end

    return livestockZone:getAnimalZone():getNbOfDung();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getFeatherTotal(livestockZone)
    if not self:isAvailableToSee(stat.feather) then
        return nil;
    end

    return livestockZone:getAnimalZone():getNbOfFeather();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getFeedingTroughTotal(livestockZone)
    if not self:isAvailableToSee(stat.feedingTrough) then
        return nil;
    end

    return livestockZone:getAnimalZone():getTroughsConnected():size();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getHutchesTotal(livestockZone)
    if not self:isAvailableToSee(stat.hutch) then
        return nil;
    end

    return livestockZone:getAnimalZone():getHutchsConnected():size();
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getRoofedAreaTotal(livestockZone)
    if not self:isAvailableToSee(stat.roofedArea) then
        return nil;
    end

    return livestockZone:getAnimalZone():getRoofAreasConnected():size();
end

--- @param livestockZone LivestockZone
--- @return number | nil
function LivestockZonesStatsProvider:getWaterTotal(livestockZone)
    if not self:isAvailableToSee(stat.water) then
        return nil;
    end

    local result = 0;
    local zone = livestockZone:getAnimalZone()

    for i=0, zone:getTroughsConnected():size()-1 do
        result = result + zone:getTroughsConnected():get(i):getWater() * 1000;
    end

    for i=0, zone:getFoodOnGroundConnected():size()-1 do
        local food = zone:getFoodOnGroundConnected():get(i):getItem();

        if food:isPureWater(true) then
            local fluidContainer = food:getFluidContainer();

            if not fluidContainer and food:getWorldItem() ~= nil then
                fluidContainer = food:getWorldItem():getFluidContainer()
            end

            if fluidContainer then
                local millilitres = fluidContainer:getAmount() * 1000
                result = result + millilitres;
            end
        end
    end

    return round(result, 0);
end

--- @param livestockZone LivestockZone
--- @return number
function LivestockZonesStatsProvider:getZoneSizeTotal(livestockZone)
    if not self:isAvailableToSee(stat.zoneSize) then
        return nil;
    end

    return livestockZone:getAnimalZone():getFullZoneSize();
end

--- @param livestockZone LivestockZone
--- @return LivestockZoneStats
function LivestockZonesStatsProvider:getZoneStats(livestockZone)
    local stats = livestockZoneStats.new(livestockZone:getAnimalZone():getId());

    stats:setAnimals(self:getAnimalsTotal(livestockZone));
    stats:setConnectedZones(self:getConnectedZonesTotal(livestockZone));
    stats:setDung(self:getDungTotal(livestockZone));
    stats:setFeathers(self:getFeatherTotal(livestockZone));
    stats:setFeedingTroughs(self:getFeedingTroughTotal(livestockZone));
    stats:setFood(self:getFoodTotal(livestockZone));
    stats:setHutches(self:getHutchesTotal(livestockZone));
    stats:setRoofedArea(self:getRoofedAreaTotal(livestockZone));
    stats:setSize(self:getZoneSizeTotal(livestockZone));
    stats:setWater(self:getWaterTotal(livestockZone));

    return stats;
end

--- @param player IsoPlayer
function livestockZonesDetailsProvider.new(player)
    local self = {};
    setmetatable(self, { __index = LivestockZonesStatsProvider })

    self.player = player;

    return self;
end

return livestockZonesDetailsProvider;
