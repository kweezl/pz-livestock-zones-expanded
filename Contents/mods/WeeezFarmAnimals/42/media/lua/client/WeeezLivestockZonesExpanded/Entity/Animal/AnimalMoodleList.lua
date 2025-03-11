require("ISBaseObject");

--- @module animalMoodleList
local animalMoodleList = {};

--- @class AnimalMoodleList
--- @field public list table<string, AnimalMoodle>
local AnimalMoodleList = ISBaseObject:derive("AnimalMoodleList");

--- @param ttl number
--- @return AnimalMoodleList
function animalMoodleList.new(ttl)
    local self = {};
    setmetatable(self, { __index = AnimalMoodleList });

    self.ttl = ttl or 10000;
    self.list = {};

    return self;
end

return animalMoodleList;
