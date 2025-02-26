local config = require("WeeezLivestockZonesExpanded/Defaults/Config")

--- @module livestockZonesStorage
local livestockZonesStorage = {};

--- @class LivestockZonesStorage
local LivestockZonesStorage = {};

--- @param zoneId number
function LivestockZonesStorage:getModDataKey(zoneId)
    return config.modDataZoneTag .. tostring(zoneId);
end

--- @param zoneId number
function LivestockZonesStorage:update(zoneId)
    return ModData.transmit(self:getModDataKey(zoneId));
end

--- @param zoneId number
function LivestockZonesStorage:remove(zoneId)
    return ModData.remove(self:getModDataKey(zoneId));
end

--- @param zoneId number
--- @return table
function LivestockZonesStorage:get(zoneId)
    return ModData.getOrCreate(self:getModDataKey(zoneId));
end

--- @return LivestockZonesStorage
function livestockZonesStorage.new()
    local self = {};
    setmetatable(self, { __index = LivestockZonesStorage });

    return self;
end

return livestockZonesStorage;
