--- @class LivestockZone
local LivestockZone = {};

--- @return boolean
function LivestockZone:exists()
    return (self.animalZone and self.animalZone:isStillStreamed());
end

--- @return DesignationZoneAnimal
function LivestockZone:getAnimalZone()
    return self.animalZone;
end

--- @return string
function LivestockZone:getName()
    return self.name;
end

--- @param name string
function LivestockZone:setName(name)
    self.name = name;
end

--- @return number
function LivestockZone:getSize()
    return self.size;
end

--- @return ArrayList
--function LivestockZone:getAnimals()
--    if self:exists() then
--        return self.animalZone:getAnimalsConnected();
--    end
--
--    return nil;
--end

--- @return string
function LivestockZone:getIcon()
    return self.data.icon;
end

--- @param icon string
function LivestockZone:setIcon(icon)
    self.data.icon = icon;
end

--- @return Texture | nil
function LivestockZone:getIconTexture()
    if not self.data.icon then
        return nil;
    end

    return getTexture(self.data.icon);
end

--- @return ArrayList<DesignationZoneAnimal>
function LivestockZone:getConnectedZones()
    return self.connectedZones;
end

local livestockZone = {};

--- @param animalZone DesignationZoneAnimal
--- @param connectedZones ArrayList<DesignationZoneAnimal>
--- @return LivestockZone
function livestockZone.new(animalZone, connectedZones, data)
    local self = {};
    setmetatable(self, { __index = LivestockZone });

    self.name = animalZone:getName();
    self.size = animalZone:getFullZoneSize();
    self.animalZone = animalZone;
    self.connectedZones = connectedZones;
    self.data = data;

    return self;
end

return livestockZone;
