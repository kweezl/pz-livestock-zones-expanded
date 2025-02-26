local LivestockZone = require("WeeezLivestockZonesExpanded/Entity/LivestockZone")

--- @module livestockZonesProvider
local livestockZonesProvider = {}

--- @class LivestockZonesProvider
--- @field private animalTypes LivestockZonesAnimalTypes
--- @field private storage LivestockZonesStorage
--- @field private defaultIcon string
local LivestockZonesProvider = {};

--- @param animalZone DesignationZoneAnimal
--- @param filterText string
--- @return boolean
function LivestockZonesProvider:isAllowedByFilterText(animalZone, filterText)
    if filterText and filterText ~= "" then
        return string.find(string.lower(animalZone:getName()), string.lower(filterText),nil,true) ~= nil
    end

    return true;
end

--- @param animalZone DesignationZoneAnimal
--- @param filterAnimalGroup LivestockAnimalGroup
--- @return boolean
function LivestockZonesProvider:isAllowedByFilterAnimalGroup(animalZone, filterAnimalGroup)
    if filterAnimalGroup:isTypeAll() then
        return true;
    end

    local animalTypes = self.animalTypes:getTypes();
    local animals = animalZone:getAnimalsConnected();

    for i = 0, animals:size() - 1 do
        local animal = animals:get(i);
        local animalType = animal:getAnimalType();

        if filterAnimalGroup == animalTypes[animalType] then
            return true;
        end
    end

    local hutches =  animalZone:getHutchs();

    for i = 0, hutches:size() - 1 do
        local hutch = hutches:get(i);
        local animalsInside = transformIntoKahluaTable(hutch:getAnimalInside());

        for _, animal in pairs(animalsInside) do
            local animalType = animal:getAnimalType();
            if filterAnimalGroup == animalTypes[animalType] then
                return true;
            end
        end
    end

    return false;
end

--- @param animalZone DesignationZoneAnimal
--- @param filterText string
--- @param filterAnimalGroup LivestockAnimalGroup
--- @return boolean
function LivestockZonesProvider:isAllowedByFilter(animalZone, filterText, filterAnimalGroup)
    if self:isAllowedByFilterText(animalZone, filterText) then
        return self:isAllowedByFilterAnimalGroup(animalZone, filterAnimalGroup);
    end

    return false;
end

--- @param filterText string
--- @param filterAnimalGroup LivestockAnimalGroup
--- @return ArrayList<LivestockZone>
function LivestockZonesProvider:getAll(filterText, filterAnimalGroup)
    -- a zone could have multiple connected zone,
    -- but we display only the first connected, no need for the others
    local list = ArrayList.new();
    local collectedZones = {};
    local allZones = DesignationZoneAnimal.getAllZones();

    for i = 0, allZones:size() - 1 do
        local zone = allZones:get(i);
        local zoneId = zone:getId();

        if not collectedZones[zoneId] then
            local connectedZones = DesignationZoneAnimal.getAllDZones(nil, zone, nil);
            collectedZones[zoneId] = 1;

            -- don't show zone that's not streamed or filtered
            if zone:isStillStreamed() and self:isAllowedByFilter(zone, filterText, filterAnimalGroup) then
                local data = self.storage:get(zoneId);

                if not data.icon then
                    data.icon = self.defaultIcon;
                end

                local livestockZone = LivestockZone.new(
                    zone,
                    connectedZones,
                    data
                );
                list:add(livestockZone)
            end

            for j = 0, connectedZones:size() - 1 do
                local connectedZone = connectedZones:get(j);
                collectedZones[connectedZone:getId()] = 1;
            end
        end
    end

    return list;
end

--- @param livestockZone LivestockZone
function LivestockZonesProvider:removeZone(livestockZone)
    local zone = livestockZone:getAnimalZone();
    DesignationZoneAnimal.removeZone(zone);
    self.storage:remove(zone:getId());
end

--- @param livestockZone LivestockZone
--- @return boolean
function LivestockZonesProvider:updateZoneProperties(livestockZone)
    print("LivestockZonesProvider:updateZoneProperties " .. livestockZone:getName())

    local zone = livestockZone:getAnimalZone();

    if not zone:isStillStreamed() then
        return false;
    end

    zone:setName(livestockZone:getName());
    self.storage:update(zone:getId());

    print ("LivestockZonesProvider:updateZoneProperties" .. zone:getName())

    return true;
end

--- @param animalTypes LivestockZonesAnimalTypes
--- @param storage LivestockZonesStorage
--- @param defaultIcon string
function livestockZonesProvider.new(animalTypes, storage, defaultIcon)
    local self = {};
    setmetatable(self, { __index = LivestockZonesProvider });

    self.animalTypes = animalTypes;
    self.storage = storage;
    self.defaultIcon = defaultIcon;

    return self;
end

return livestockZonesProvider;
