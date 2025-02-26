local stats = require("WeeezLivestockZonesExpanded/Enums/LivestockZoneStat");
local statEnum = stats.stat;
local statList = stats.list;

--- @module livestockZoneStats
local livestockZoneStats = {};

--- @class LivestockZoneStats
--- @field private zoneId number
--- @field private animals
--- @field private connectedZones
--- @field private dung
--- @field private feathers
--- @field private feedingTroughs
--- @field private food
--- @field private hutches
--- @field private size
--- @field private water
local LivestockZoneStats = {};

--- @return number | nil
function LivestockZoneStats:getAnimals()
    return self.animals;
end

--- @param animals number | nil
function LivestockZoneStats:setAnimals(animals)
    self.animals = animals;
end

--- @return number | nil
function LivestockZoneStats:getConnectedZones()
    return self.connectedZones;
end

--- @param connectedZones number
function LivestockZoneStats:setConnectedZones(connectedZones)
    self.connectedZones = connectedZones;
end

--- @return number | nil
function LivestockZoneStats:getDung()
    return self.dung;
end

--- @param dung number | nil
function LivestockZoneStats:setDung(dung)
    self.dung = dung;
end

--- @return number | nil
function LivestockZoneStats:getFeathers()
    return self.feathers;
end

--- @param feathers number | nil
function LivestockZoneStats:setFeathers(feathers)
    self.feathers = feathers;
end

--- @return number | nil
function LivestockZoneStats:getFeedingTroughs()
    return self.feedingTroughs;
end

--- @param feedingTrough number | nil
function LivestockZoneStats:setFeedingTroughs(feedingTroughs)
    self.feedingTroughs = feedingTroughs;
end

--- @return number | nil
function LivestockZoneStats:getFood()
    return self.food;
end

--- @param food number | nil
function LivestockZoneStats:setFood(food)
    self.food = food;
end

--- @return number | nil
function LivestockZoneStats:getHutches()
    return self.hutches;
end

--- @param hutches number | nil
function LivestockZoneStats:setHutches(hutches)
    self.hutches = hutches;
end

--- @return number | nil
function LivestockZoneStats:getRoofedArea()
    return self.roofedArea;
end

--- @param roofedArea number | nil
function LivestockZoneStats:setRoofedArea(roofedArea)
    self.roofedArea = roofedArea;
end

--- @return number | nil
function LivestockZoneStats:getSize()
    return self.size;
end

--- @param size number | nil
function LivestockZoneStats:setSize(size)
    self.size = size;
end

--- @return number | nil
function LivestockZoneStats:getWater()
    return self.water;
end

--- @param water number | nil
function LivestockZoneStats:setWater(water)
    self.water = water;
end

--- @return number | nil
function LivestockZoneStats:getZoneId()
    return self.zoneId;
end

function LivestockZoneStats:statMap()
    return {
        [statEnum.animal] = self.getAnimals,
        [statEnum.connectedZone] = self.getConnectedZones,
        [statEnum.dung] = self.getDung,
        [statEnum.feather] = self.getFeathers,
        [statEnum.feedingTrough] = self.getFeedingTroughs,
        [statEnum.food] = self.getFood,
        [statEnum.hutch] = self.getHutches,
        [statEnum.roofedArea] = self.getRoofedArea,
        [statEnum.water] = self.getWater,
        [statEnum.zoneSize] = self.getSize,
    };
end

function LivestockZoneStats:getAll()
    local result = ArrayList:new();
    local statMap = self:statMap();

    for i = 0, statList:size() - 1 do
        local stat = statList:get(i);
        local fn = statMap[stat];

        if fn then
            result:add(fn(self));
            --print (stat, fn(self));
            print("LivestockZoneStats:getAll", stat, fn(self))
        else
            result:add(nil);
            print("LivestockZoneStats:getAll", stat, "not found")
        end
    end

    return result;
end

--- @param zoneId number
--- @return LivestockZoneStats
function livestockZoneStats.new(zoneId)
    local self = {};
    setmetatable(self, { __index = LivestockZoneStats })

    self.animals = nil;
    self.connectedZones = nil;
    self.dung = nil;
    self.feathers = nil;
    self.feedingTroughs = nil;
    self.food = nil;
    self.hutches = nil;
    self.roofedArea = nil;
    self.size = nil;
    self.water = nil;
    self.zoneId = zoneId;

    return self;
end

return livestockZoneStats;
