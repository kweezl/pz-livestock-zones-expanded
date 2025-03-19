require("ISBaseObject");

--- @module "WeeezLivestockZonesExpanded/Entity/Animal/AnimalStat"
local animalStat = {};

--- @class AnimalStat
--- @field public title string
--- @field public tooltip string | nil
--- @field public value string | nil
--- @field public isVisible boolean
local AnimalStat = ISBaseObject:derive("AnimalStat");

function animalStat.new(title)
    local self = {};
    setmetatable(self, { __index = AnimalStat });

    self.title = title;
    self.tooltip = nil;
    self.value = nil;
    self.isVisible = false;

    return self;
end

return animalStat;
