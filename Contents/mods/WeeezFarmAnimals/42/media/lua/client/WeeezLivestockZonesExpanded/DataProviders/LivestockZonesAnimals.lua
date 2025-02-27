local livestockZonesAnimal = require("WeeezLivestockZonesExpanded/Entity/Animal/LivestockZoneAnimal")


--- @module livestockZonesAnimals
local livestockZonesAnimals = {};

--- @class LivestockZonesAnimals
--- @field private player IsoPlayer
--- @field private animalIcons LivestockZonesIcons
local LivestockZonesAnimals = {};

--- @param livestockZone LivestockZone
--- @return ArrayList<LivestockZonesAnimal>
function LivestockZonesAnimals:getAllForZone(livestockZone)
    local animalZone = livestockZone:getAnimalZone();
    local animals = animalZone:getAnimalsConnected();
    local hutches =  animalZone:getHutchs();
    local animalList = ArrayList:new();

    for i = 0, animals:size() - 1 do
        local animal = animals:get(i);
        local texture = getTexture(self.animalIcons:getAnimalIcon(animal));
        animalList:add(livestockZonesAnimal.new(animal, texture));
    end

    -- todo: restrict animals inside to perk level
    for i = 0, hutches:size() - 1 do
        local hutch = hutches:get(i);
        local animalsInside = transformIntoKahluaTable(hutch:getAnimalInside());

        for _, animal in pairs(animalsInside) do
            local texture = getTexture(self.animalIcons:getAnimalIcon(animal));
            animalList:add(livestockZonesAnimal.new(animal, texture));
        end
    end

    return animalList;
end

--- @param player IsoPlayer
--- @param animalIcons LivestockZonesIcons
--- @return LivestockZonesAnimals
function livestockZonesAnimals.new(player, animalIcons)
    self = {};
    setmetatable(self, { __index = LivestockZonesAnimals });

    self.player = player;
    self.animalIcons = animalIcons;

    return self;
end

return livestockZonesAnimals;
