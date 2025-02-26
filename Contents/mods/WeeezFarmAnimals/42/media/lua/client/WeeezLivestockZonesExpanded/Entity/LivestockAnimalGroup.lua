--- @class LivestockAnimalGroup
--- @field private name string
--- @field private type string
--- @field private typeAll boolean
--- @field private animalTypes ArrayList<string>
local LivestockAnimalGroup = {};

function LivestockAnimalGroup:getName()
    return self.name;
end

function LivestockAnimalGroup:getType()
    return self.type;
end

function LivestockAnimalGroup:isTypeAll()
    return self.typeAll;
end

--- @param animalType string
function LivestockAnimalGroup:addAnimalType(animalType)
    self.animalTypes:add(animalType)
end

--- @return ArrayList<string>
function LivestockAnimalGroup:getAnimalTypes()
    return self.animalTypes;
end

local livestockAnimalGroup = {};

--- @param name string
--- @param groupType string
--- @param isTypeAll boolean
--- @return LivestockAnimalGroup
function livestockAnimalGroup.new(name, groupType, isTypeAll)
    local self = {};
    setmetatable(self, { __index = LivestockAnimalGroup });

    self.name = name;
    self.type = groupType;
    self.typeAll = isTypeAll;
    self.animalTypes = ArrayList:new();

    return self;
end

return livestockAnimalGroup;
