require("ISBaseObject");

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local moodleConfig = config.moodle;

local animalMoodleType = require("WeeezLivestockZonesExpanded/Enums/AnimalMoodleType");
local animalMoodle = require("WeeezLivestockZonesExpanded/Entity/Animal/AnimalMoodle");
local animalGenderType = require("WeeezLivestockZonesExpanded/Enums/AnimalGenderType");
local animalGrowStageType = require("WeeezLivestockZonesExpanded/Enums/AnimalGrowStageType");
local animalMoodleList = require("WeeezLivestockZonesExpanded/Entity/Animal/AnimalMoodleList");

local neutralColor = config.moodleColor.neutral;
local geriatricColor = config.moodleColor.geriatric;

local negativeColorMin = config.moodleColor.negative.min;
local negativeColorMax = config.moodleColor.negative.max;
local negativeColorAlpha = 1;

local positiveColorMin = config.moodleColor.positive.min;
local positiveColorMax = config.moodleColor.positive.max;
local positiveColorAlpha = 1;

--- @module livestockZonesAnimalMoodle
local livestockZonesAnimalMoodle = {};

--- @see AnimalMoodle
--- @class LivestockZonesAnimalMoodle
--- @field private growStage LivestockZonesAnimalGrowStage
local LivestockZonesAnimalMoodle = ISBaseObject:derive("LivestockZonesAnimalMoodle");

--- @param moodle string
--- @return Texture | nil
function LivestockZonesAnimalMoodle:getTexture(moodle)
    local moodleDef = moodleConfig[moodle];

    return moodleDef and moodleDef.texture or nil;
end

--- @param isoAnimal IsoAnimal
--- @param list AnimalMoodleList | nil
--- @return AnimalMoodleList
function LivestockZonesAnimalMoodle:getMoodleList(isoAnimal, list)
    if not list then
        list = animalMoodleList.new(isoAnimal)
    end

    --- @type AnimalMoodle | nil
    local moodle;
    --- @type table<string, AnimalMoodle>
    local moodleList = list.list;
    local moodleFnMap = self.moodleFnMap;
    local minutesStamp = GameTime.getInstance():getMinutesStamp();

    for moodleType, fn in pairs(moodleFnMap) do
        moodle = moodleList[moodleType];
        if not moodle or not moodle:isValid(minutesStamp) then
            moodleList[moodleType] = fn(self, isoAnimal, moodle, minutesStamp);
        end
    end

    return list;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle
function LivestockZonesAnimalMoodle:getGenderMoodle(isoAnimal, moodle, minutesStamp)
    local gender = isoAnimal:isFemale() and animalGenderType.female or animalGenderType.male;
    local texture = self:getTexture(gender);
    local ttl = minutesStamp + 1000; -- changed by cheat only
    local color = neutralColor;

    if not moodle then
        return animalMoodle.new(animalMoodleType.gender, texture, color, ttl);
    end

    moodle.texture = texture;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle
function LivestockZonesAnimalMoodle:getGrowStageMoodle(isoAnimal, moodle, minutesStamp)
    -- todo: causes flickering
    local growStage = self.growStage:getGrowStage(isoAnimal);
    local texture = self:getTexture(growStage);
    local ttl = minutesStamp + 100;
    local color;

    if growStage == animalGrowStageType.geriatric then
        color = geriatricColor;
    else
        color = neutralColor;
    end

    if not moodle then
        return animalMoodle.new(animalMoodleType.growStage, texture, color, ttl);
    end

    moodle.texture = texture;
    moodle.color = color;
    moodle.ttl = ttl;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getHealthMoodle(isoAnimal, moodle, minutesStamp)
    local value = isoAnimal:getHealth();
    if value > 0.9 then
        return nil;
    end

    local color = self:getMoodleColor(value, negativeColorMax, negativeColorMin, negativeColorAlpha);
    local ttl = minutesStamp + 1;

    if not moodle then
        return animalMoodle.new(animalMoodleType.health, self:getTexture(animalMoodleType.health), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getHungryMoodle(isoAnimal, moodle, minutesStamp)
    local value = isoAnimal:getHunger();
    if value < 0.3 then
        return nil;
    end

    local color = self:getMoodleColor(value, negativeColorMax, negativeColorMin, negativeColorAlpha);
    local ttl = minutesStamp + 1;

    if not moodle then
        return animalMoodle.new(animalMoodleType.hungry, self:getTexture(animalMoodleType.hungry), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getThirstyMoodle(isoAnimal, moodle, minutesStamp)
    local value = isoAnimal:getThirst();
    if value < 0.3 then
        return nil;
    end

    local color = self:getMoodleColor(value, negativeColorMax, negativeColorMin, negativeColorAlpha);
    local ttl = minutesStamp + 1;

    if not moodle then
        return animalMoodle.new(animalMoodleType.thirsty, self:getTexture(animalMoodleType.thirsty), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getAnxietyMoodle(isoAnimal, moodle, minutesStamp)
    local value = isoAnimal:getStress();
    if value < 40.0 then
        return nil;
    end

    local ratio = math.min(value, 100) / 100;
    local color = self:getMoodleColor(ratio, negativeColorMax, negativeColorMin, negativeColorAlpha);
    local ttl = minutesStamp + 3;

    if not moodle then
        return animalMoodle.new(animalMoodleType.anxiety, self:getTexture(animalMoodleType.anxiety), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getMilkMoodle(isoAnimal, moodle, minutesStamp)
    if not isoAnimal:canBeMilked() then
        return nil;
    end

    local animalData = isoAnimal:getData();

    if animalData:getMilkQuantity() < 0.1 then
        return;
    end

    local milk = animalData:getMilkQuantity();
    local milkMax = animalData:getMaxMilk();
    local ratio = milk / milkMax;

    local color = self:getMoodleColor(ratio, positiveColorMin, positiveColorMax, positiveColorAlpha);
    local ttl = minutesStamp + 10;

    if not moodle then
        return animalMoodle.new(animalMoodleType.milk, self:getTexture(animalMoodleType.milk), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getShearMoodle(isoAnimal, moodle, minutesStamp)
    if not isoAnimal:readyToBeSheared() then
        return nil;
    end

    local animalData = isoAnimal:getData();
    local wool = animalData:getWoolQuantity();
    local woolMax = animalData:getMaxWool();
    local ratio = wool / woolMax;

    local color = self:getMoodleColor(ratio, positiveColorMax, positiveColorMin, positiveColorAlpha);
    local ttl = minutesStamp + 10;

    if not moodle then
        return animalMoodle.new(animalMoodleType.shear, self:getTexture(animalMoodleType.shear), color, ttl);
    end

    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param value number from 0 to 1
--- @param colorA ColorInfo
--- @param colorB ColorInfo
--- @param alpha number
--- @return ColorInfo
function LivestockZonesAnimalMoodle:getMoodleColor(value, colorA, colorB, alpha)
    local revertVal = 1 - value;

    return ColorInfo.new(
        colorA:getR() * value + colorB:getR() * revertVal,
        colorA:getG() * value + colorB:getG() * revertVal,
        colorA:getB() * value + colorB:getB() * revertVal,
        alpha
    );
end

--- @param growStage LivestockZonesAnimalGrowStage
function livestockZonesAnimalMoodle.new(growStage)
    local self = {};
    setmetatable(self, { __index = LivestockZonesAnimalMoodle });

    self.growStage = growStage;
    self.moodleFnMap = {
        [animalMoodleType.gender] = self.getGenderMoodle;
        [animalMoodleType.growStage] = self.getGrowStageMoodle;
        [animalMoodleType.health] = self.getHealthMoodle;
        [animalMoodleType.hungry] = self.getHungryMoodle;
        [animalMoodleType.thirsty] = self.getThirstyMoodle;
        [animalMoodleType.anxiety] = self.getAnxietyMoodle;
        [animalMoodleType.milk] = self.getMilkMoodle;
        [animalMoodleType.shear] = self.getShearMoodle;
    };

    return self;
end

return livestockZonesAnimalMoodle;
