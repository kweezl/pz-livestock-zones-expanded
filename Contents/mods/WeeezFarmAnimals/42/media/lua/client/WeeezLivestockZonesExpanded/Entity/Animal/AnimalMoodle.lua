require("ISBaseObject");

--- @module animalMoodle
local animalMoodle = {};

--- @class AnimalMoodle
--- @field public moodle string
--- @field public texture Texture
--- @field public color ColorInfo
--- @field public ttl number
local AnimalMoodle = ISBaseObject:derive("AnimalMoodle");

--- @param minutesStamp number
--- @return boolean
function AnimalMoodle:isValid(minutesStamp)
    return self.ttl > minutesStamp;
end

--- @param moodle string
--- @param texture Texture
--- @param color ColorInfo
--- @param ttl number
--- @return AnimalMoodle
function animalMoodle.new(moodle, texture, color, ttl)
    local self = {};
    setmetatable(self, { __index = AnimalMoodle })

    self.moodle = moodle;
    self.texture = texture;
    self.color = color;
    self.ttl = ttl;

    return self;
end

return animalMoodle;
