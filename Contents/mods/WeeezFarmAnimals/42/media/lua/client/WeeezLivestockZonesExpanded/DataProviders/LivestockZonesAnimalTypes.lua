local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local livestockAnimalGroup = require("WeeezLivestockZonesExpanded/Entity/LivestockAnimalGroup");

---@module livestockZonesAnimalTypes
local livestockZonesAnimalTypes = {};

local groups = {};
local types = {};

--- @class LivestockZonesAnimalTypes
--- @field private groups table<string, LivestockAnimalGroup> | nil
--- @field private types table<string, LivestockAnimalGroup> | nil
local LivestockZonesAnimalTypes = {};

--- @return LivestockAnimalGroup
function LivestockZonesAnimalTypes:getDefaultGroup()
    return self.defaultGroup
end

--- @return table<string, LivestockAnimalGroup>
function LivestockZonesAnimalTypes:getGroups()
    return groups;
end

--- @return table<string, LivestockAnimalGroup>
function LivestockZonesAnimalTypes:getTypes()
    return types;
end

--- @param animalType string
--- @param groupType string
--- @return boolean
function LivestockZonesAnimalTypes:typeOf(animalType, groupType)
    local group = types[animalType];

    return group and group:getType() == groupType or false;
end

--- @param animalType string
--- @return table | nil
function LivestockZonesAnimalTypes:getAnimalDefinitionNextStage(animalType)
    local group = types[animalType];

    if not group then
        return nil;
    end

    local animaGroupStagesDef = AnimalDefinitions.stages[group:getType()];

    if not animaGroupStagesDef then
        return nil;
    end

    return animaGroupStagesDef.stages[animalType];
end

function livestockZonesAnimalTypes.init()
    local animals = AnimalDefinitions.animals;

    for animalType, definition in pairs(animals) do
        local groupType = definition.group;

        if not groups[groupType] then
            local groupName = getText("IGUI_AnimalGroup_" .. groupType);
            groups[groupType] = livestockAnimalGroup.new(groupName, groupType, false);
        end

        local group = groups[groupType];
        types[animalType] = group;
        group:addAnimalType(animalType);
    end

    table.sort(groups, function(a, b)  return a:getName():upper() < b:getName():upper() end);
end

--- @return LivestockZonesAnimalTypes
function livestockZonesAnimalTypes.new()
    local self = {};
    setmetatable(self, { __index = LivestockZonesAnimalTypes });

    self.defaultGroup = livestockAnimalGroup.new(
        config.filterAllAnimalGroupText,
        config.filterAllAnimalGroupDefault,
        true
    );

    return self;
end

return livestockZonesAnimalTypes;
