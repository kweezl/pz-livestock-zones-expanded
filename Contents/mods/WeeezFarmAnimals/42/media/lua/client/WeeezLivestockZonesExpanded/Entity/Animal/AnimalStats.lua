require("ISBaseObject");

--- @module "WeeezLivestockZonesExpanded/Entity/Animal/AnimalStats"
local animalStats = {};

--- @class AnimalStats : ISBaseObject
--- @field public animal livestockZonesAnimal
--- @field public list table<string, AnimalStat>
--- @field public minutesStamp number
local AnimalStats = ISBaseObject:derive("AnimalStats");

--- @param animal livestockZonesAnimal
--- @return AnimalStats
function animalStats.new(animal)
    local self = {};
    setmetatable(self, { __index = AnimalStats });
    self.animal = animal;
    self.list = {};
    self.minutesStamp = 0;

    return self;
end

return animalStats;
