require("ISBaseObject");

--- @module animalMoodleList
local animalMoodleList = {};

--- @class AnimalMoodleList
--- @field public list table<string, AnimalMoodle>
local AnimalMoodleList = ISBaseObject:derive("AnimalMoodleList");

function AnimalMoodleList:isValid(minutesStamp)
    return self.ttl > minutesStamp;
end

--- @return AnimalMoodleList
function animalMoodleList.new(minutesStamp)
    local self = {};
    setmetatable(self, { __index = AnimalMoodleList });

    self.list = {};
    self.ttl = minutesStamp

    return self;
end

return animalMoodleList;
