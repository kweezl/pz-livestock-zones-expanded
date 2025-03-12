require("ISBaseObject");

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local moodleConfig = config.moodle;
local moodleThreshold = config.moodleThreshold;

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
function LivestockZonesAnimalMoodle:getMoodleConfig(moodle)
    local moodleDef = moodleConfig[moodle];

    return moodleDef and moodleDef or nil;
end

--- @param isoAnimal IsoAnimal
--- @param list AnimalMoodleList | nil
--- @return AnimalMoodleList
function LivestockZonesAnimalMoodle:getMoodleList(isoAnimal, list)
    -- min update interval
    -- once per game minute
    local minutesStamp = getGameTime():getMinutesStamp();

    if not list then
        list = animalMoodleList.new(minutesStamp)
        print("create animalMoodleList " .. isoAnimal:getFullName())
    end

    if list:isValid(minutesStamp) then
        return list;
    end

    --- @type table<string, AnimalMoodle>
    local moodleList = list.list;

    for moodleType, fn in pairs(self.moodleFnMap) do
        --- @type AnimalMoodle | nil
        local moodle = moodleList[moodleType];
        if not moodle or not moodle:isValid(minutesStamp) then
            moodleList[moodleType] = fn(self, isoAnimal, moodle, minutesStamp);
        end
    end

    list.ttl = minutesStamp + 1;

    return list;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle
function LivestockZonesAnimalMoodle:getGenderMoodle(isoAnimal, moodle, minutesStamp)
    -- gender could only be changed by cheat
    local gender = isoAnimal:isFemale() and animalGenderType.female or animalGenderType.male;
    local ttl = minutesStamp + 10000000;

    if moodle and moodle.value == gender then
        moodle.ttl = ttl;

        return moodle;
    end

    local mc = self:getMoodleConfig(gender);
    -- changed by cheat only
    local color = neutralColor;

    if not moodle then
        return animalMoodle.new(animalMoodleType.gender, gender, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = gender;
    moodle.tooltip = mc.tooltip;
    moodle.texture = mc.texture;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle
function LivestockZonesAnimalMoodle:getGrowStageMoodle(isoAnimal, moodle, minutesStamp)
    local growStage = self.growStage:getGrowStage(isoAnimal);
    -- not confirmed, but
    -- growth stage can occur once a day
    local minutesToNextDay = (24 - math.floor(getGameTime():getTimeOfDay())) * 60 - getGameTime():getMinutes();

    if minutesToNextDay == 0 then
        minutesToNextDay = 24 * 60;
    end

    local ttl = minutesStamp + minutesToNextDay;

    if moodle and moodle.value == growStage then
        moodle.ttl = ttl;

        return moodle;
    end

    local mc = self:getMoodleConfig(growStage);
    local color;

    if growStage == animalGrowStageType.geriatric then
        color = geriatricColor;
    else
        color = neutralColor;
    end

    if not moodle then
        return animalMoodle.new(animalMoodleType.growStage, growStage, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = growStage;
    moodle.tooltip = mc.tooltip;
    moodle.texture = mc.texture;
    moodle.color = color;
    moodle.ttl = ttl;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getHealthMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.health;
    local value = isoAnimal:getHealth();
    if value > moodleThreshold[moodleType] then
        return nil;
    end

    local ttl = minutesStamp + 1;

    if moodle and moodle.value == value then
        moodle.ttl = ttl;

        return moodle;
    end

    local color = self:getMoodleColor(value, negativeColorMin, negativeColorMax, negativeColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType)

        return animalMoodle.new(moodleType, value, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = value;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getHungryMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.hungry;
    local value = isoAnimal:getHunger();
    if value < moodleThreshold[moodleType] then
        return nil;
    end

    local ttl = minutesStamp + 2;

    if moodle and moodle.value == value then
        moodle.ttl = ttl;

        return moodle;
    end

    local color = self:getMoodleColor(value, negativeColorMax, negativeColorMin, negativeColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType)

        return animalMoodle.new(moodleType, value, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = value;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getThirstyMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.thirsty;
    local value = isoAnimal:getThirst();
    if value < moodleThreshold[moodleType] then
        return nil;
    end

    local ttl = minutesStamp + 2;

    if moodle and moodle.value == value then
        moodle.ttl = ttl;

        return moodle;
    end

    local color = self:getMoodleColor(value, negativeColorMax, negativeColorMin, negativeColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType)

        return animalMoodle.new(moodleType, value, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = value;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getAnxietyMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.anxiety;
    local value = isoAnimal:getStress();
    if value < moodleThreshold[moodleType] then
        return nil;
    end

    local ttl = minutesStamp + 5;

    if moodle and moodle.value == value then
        moodle.ttl = ttl;

        return moodle;
    end

    local ratio = math.min(value, 100) / 100;
    local color = self:getMoodleColor(ratio, negativeColorMax, negativeColorMin, negativeColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType);

        return animalMoodle.new(moodleType, value, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = value;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getMilkMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.milk;
    if not isoAnimal:canBeMilked() then
        return nil;
    end

    local animalData = isoAnimal:getData();
    local milk = animalData:getMilkQuantity();

    if milk < moodleThreshold[moodleType] then
        return;
    end

    local ttl = minutesStamp + 5;

    if moodle and moodle.value == milk then
        moodle.ttl = ttl;

        return moodle;
    end

    local milkMax = animalData:getMaxMilk();
    local ratio = milk / milkMax;
    local color = self:getMoodleColor(ratio, positiveColorMin, positiveColorMax, positiveColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType);

        return animalMoodle.new(moodleType, milk, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = milk;
    moodle.color = color;
    moodle.ttl = ttl;

    return moodle;
end

--- @param isoAnimal IsoAnimal
--- @param moodle AnimalMoodle | nil
--- @return AnimalMoodle | nil
function LivestockZonesAnimalMoodle:getShearMoodle(isoAnimal, moodle, minutesStamp)
    local moodleType = animalMoodleType.shear;
    if not isoAnimal:canBeSheared() then
        return nil;
    end

    local animalData = isoAnimal:getData();
    local wool = animalData:getWoolQuantity();

    if wool < moodleThreshold[moodleType] then
        return nil;
    end

    local ttl = minutesStamp + 5;

    if moodle and moodle.value == wool then
        moodle.ttl = ttl;

        return moodle;
    end

    local woolMax = animalData:getMaxWool();
    local ratio = wool / woolMax;
    local color = self:getMoodleColor(ratio, positiveColorMax, positiveColorMin, positiveColorAlpha);

    if not moodle then
        local mc = self:getMoodleConfig(moodleType)

        return animalMoodle.new(moodleType, wool, mc.tooltip, mc.texture, color, ttl);
    end

    moodle.value = wool;
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
