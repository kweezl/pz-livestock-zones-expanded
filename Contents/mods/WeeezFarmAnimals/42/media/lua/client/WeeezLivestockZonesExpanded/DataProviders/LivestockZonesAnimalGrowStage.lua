require("ISBaseObject");

local animalGrowStageType = require("WeeezLivestockZonesExpanded/Enums/AnimalGrowStageType");

--- @module livestockZonesAnimalGrowStage
local livestockZonesAnimalGrowStage = {};

--- @see AnimalMoodle
--- @class LivestockZonesAnimalGrowStage
--- @field private animalTypes LivestockZonesAnimalTypes
local LivestockZonesAnimalGrowStage = ISBaseObject:derive("LivestockZonesAnimalGrowStage");

--- @see AnimalMoodle
--- @param isoAnimal IsoAnimal
--- @return string
function LivestockZonesAnimalGrowStage:getGrowStage(isoAnimal)
    if isoAnimal:isBaby() then
        local stageDef = self.animalTypes:getAnimalDefinitionNextStage(isoAnimal:getAnimalType());
        local isJuvenile = false;

        if stageDef and stageDef.ageToGrow then
            isJuvenile = stageDef.ageToGrow / 2 < isoAnimal:getData():getDaysSurvived();
        end

        return isJuvenile and animalGrowStageType.juvenile or animalGrowStageType.baby;
    end

    if isoAnimal:isGeriatric() then
        return animalGrowStageType.geriatric
    end

    return animalGrowStageType.adult;
end

--- @see AnimalMoodle
--- @param isoAnimal IsoAnimal
--- @return string
function LivestockZonesAnimalGrowStage:getDaysToNextStage(isoAnimal)
    if isoAnimal:isBaby() then
        local stageDef = self.animalTypes:getAnimalDefinitionNextStage(isoAnimal:getAnimalType());

        return stageDef.ageToGrow
    end

    if isoAnimal:isGeriatric() then
        return -1;
    end

    return isoAnimal:getData():getMaxAgeGeriatric();
end

--- @param animalTypes LivestockZonesAnimalTypes
--- @return LivestockZonesAnimalGrowStage
function livestockZonesAnimalGrowStage.new(animalTypes)
    local self = {};
    setmetatable(self, { __index = LivestockZonesAnimalGrowStage });

    self.animalTypes = animalTypes;

    return self;
end

return livestockZonesAnimalGrowStage;
