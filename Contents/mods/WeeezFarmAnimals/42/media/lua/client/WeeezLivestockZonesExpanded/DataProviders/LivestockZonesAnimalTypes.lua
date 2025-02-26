local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local livestockAnimalGroup = require("WeeezLivestockZonesExpanded/Entity/LivestockAnimalGroup");

---@module livestockZonesAnimalTypes
local livestockZonesAnimalTypes = {};

--- @class LivestockZonesAnimalTypes
--- @field private groups table<string, LivestockAnimalGroup> | nil
--- @field private types table<string, LivestockAnimalGroup> | nil
local LivestockZonesAnimalTypes = {};

function LivestockZonesAnimalTypes:init()
    print("LivestockZonesAnimalTypes:init")

    local animals = AnimalDefinitions.animals;
    self.groups = {};
    self.types = {};

    for animalType, definition in pairs(animals) do
        local groupType = definition.group;

        if not self.groups[groupType] then
            local groupName = getText("IGUI_AnimalGroup_" .. groupType);
            self.groups[groupType] = livestockAnimalGroup.new(groupName, groupType, false);
        end

        local group = self.groups[groupType];
        self.types[animalType] = group;
        group:addAnimalType(animalType);
    end

    table.sort(self.groups, function(a, b)  return a:getName():upper() < b:getName():upper() end);
end

--- @return LivestockAnimalGroup
function LivestockZonesAnimalTypes:getDefaultGroup()
    return self.defaultGroup
end

--- @param reset boolean
--- @return table<string, LivestockAnimalGroup>
function LivestockZonesAnimalTypes:getGroups(reset)
    if (reset == true or self.groups == nil) then
        self:init();
    end

    return self.groups;
end

--- @param reset boolean
--- @return table<string, LivestockAnimalGroup>
function LivestockZonesAnimalTypes:getTypes(reset)
    if (reset == true or self.types == nil) then
        self:init();
    end

    return self.types;
end

--- @param animalType string
--- @param groupType string
--- @return boolean
function LivestockZonesAnimalTypes:typeOf(animalType, groupType)
    local types = self:getTypes(false);
    local group = types[animalType];

    return group and group:getType() == groupType or false;
end

--- @return LivestockZonesAnimalTypes
function livestockZonesAnimalTypes.new()
    local self = {};
    setmetatable(self, { __index = LivestockZonesAnimalTypes });

    self.groups = nil;
    self.types = nil;
    self.defaultGroup = livestockAnimalGroup.new(
        config.filterAllAnimalGroupText,
        config.filterAllAnimalGroupDefault,
        true
    );

    return self;
end

return livestockZonesAnimalTypes;
