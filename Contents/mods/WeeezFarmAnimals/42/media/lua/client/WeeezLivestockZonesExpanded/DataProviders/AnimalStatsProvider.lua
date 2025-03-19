require("ISBaseObject");
local moodleConfig = require("WeeezLivestockZonesExpanded/Defaults/Config").moodle;
local animalStatType = require("WeeezLivestockZonesExpanded/Enums/LivestockAnimalStat").stat;
local animalStat = require("WeeezLivestockZonesExpanded/Entity/Animal/AnimalStat");
local animalStats = require("WeeezLivestockZonesExpanded/Entity/Animal/AnimalStats");

--- @module "WeeezLivestockZonesExpanded/DataProviders/AnimalStatsProvider"
local animalStatsProvider = {};

--- @class AnimalStatsProvider
--- @field private growStage LivestockZonesAnimalGrowStage
local AnimalStatsProvider = ISBaseObject:derive("AnimalStatsProvider");

--- @param animal LivestockZonesAnimal
--- @return AnimalStats
function AnimalStatsProvider:create(animal)
    local stats = animalStats.new(animal);
    self:update(stats);

    return stats;
end

--- @param stats AnimalStats
function AnimalStatsProvider:update(stats)
    local minutesStamp = getGameTime():getMinutesStamp();

    if stats.minutesStamp >= minutesStamp then
        return;
    end

    local statMapFn = self:getStatMapFn();
    local statsList = stats.list;
    local animal = stats.animal;

    for statType, fn in pairs(statMapFn) do
        local stat = statsList[statType];
        statsList[statType] = fn(self, animal, stat);
    end

    stats.minutesStamp = minutesStamp + 2;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateType(animal, stat)
    if not stat then
        stat = animalStat.new(getText("IGUI_AnimalType"));
    end

    stat.value = getText("IGUI_AnimalType_" .. animal:getIsoAnimal():getAnimalType());
    stat.isVisible = true;

    return stat;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateBreed(animal, stat)
    if not stat then
        stat = animalStat.new(getText("IGUI_AnimalBreed"));
    end

    stat.value = getText("IGUI_Breed_" .. animal:getIsoAnimal():getData():getBreed():getName());
    stat.isVisible = true;

    return stat;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateGender(animal, stat)
    if not stat then
        stat = animalStat.new(getText("UI_characreation_gender"));
    end

    stat.value = animal:getIsoAnimal():isFemale() and getText("IGUI_Animal_Female") or getText("IGUI_Animal_Male");
    stat.isVisible = true;

    return stat;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateGrowStage(animal, stat)
    if not stat then
        stat = animalStat.new(getText("IGUI_Animal_Stat_GrowStage"));
    end

    local growStage = self.growStage:getGrowStage(animal:getIsoAnimal());
    stat.value = moodleConfig[growStage].tooltip;
    stat.isVisible = true;

    return stat;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateAgeDays(animal, stat)
    if not stat then
        stat = animalStat.new(getText("IGUI_Animal_Stat_AgeDays"));
    end

    stat.value = tostring(animal:getIsoAnimal():getData():getDaysSurvived());
    stat.isVisible = true;

    return stat;
end

--- @param animal LivestockZonesAnimal
--- @param stat AnimalStat | nil
--- @return AnimalStat
function AnimalStatsProvider:updateNextStageDays(animal, stat)
    if not stat then
        stat = animalStat.new(getText("IGUI_Animal_Stat_NextGrowStageDays"));
    end

    local value = self.growStage:getDaysToNextStage(animal:getIsoAnimal());
    stat.value = value == -1 and "-" or tostring(value);
    stat.isVisible = true;

    return stat;
end

--- @return table<string, function>
function AnimalStatsProvider:getStatMapFn()
    return {
        [animalStatType.type] = self.updateType,
        [animalStatType.breed] = self.updateBreed,
        [animalStatType.gender] = self.updateGender,
        [animalStatType.grow_stage] = self.updateGrowStage,
        [animalStatType.age_days] = self.updateAgeDays,
        [animalStatType.next_stage_days] = self.updateNextStageDays,
    };
end

--- @param growStage LivestockZonesAnimalGrowStage
function animalStatsProvider.new(growStage)
    local self = {};
    setmetatable(self, { __index = AnimalStatsProvider });
    self.growStage = growStage;

    return self;
end

return animalStatsProvider;
