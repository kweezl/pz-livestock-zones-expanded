require("ISBaseObject");

--- @module animalMoodle
local animalMoodle = {};

--- @class AnimalMoodle
--- @field public moodleType string
--- @field public tooltip string
--- @field public value any
--- @field public texture Texture
--- @field public color ColorInfo
--- @field public ttl number
local AnimalMoodle = ISBaseObject:derive("AnimalMoodle");

--- @param minutesStamp number
--- @return boolean
function AnimalMoodle:isValid(minutesStamp)
    return self.ttl > minutesStamp;
end

--- @param moodleType string
--- @param value any
--- @param texture Texture
--- @param color ColorInfo
--- @param minutesStamp number
--- @return AnimalMoodle
function animalMoodle.new(moodleType, value, tooltip, texture, color, minutesStamp)
    local self = {};
    setmetatable(self, { __index = AnimalMoodle })

    self.moodleType = moodleType;
    self.value = value;
    self.tooltip = tooltip;
    self.texture = texture;
    self.color = color;
    self.ttl = minutesStamp;

    return self;
end

return animalMoodle;
