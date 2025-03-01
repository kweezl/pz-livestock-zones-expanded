---@module livestockZonesController
local livestockZonesController = {};

--- @class LivestockZonesController
--- @field private player IsoPlayer
--- @field private zoneProvider LivestockZonesProvider
--- @field private animalsProvider LivestockZonesAnimals
--- @field private zoneStatsProvider LivestockZonesStatsProvider
--- @field private storage LivestockZonesStorage
--- @field private animalTypes LivestockZonesAnimalTypes
--- @field private zonesIcons LivestockZonesIcons
--- @field private events LivestockZonesEvents
--- @field private livestockZones ArrayList | nil
--- @field private activeLivestockZone LivestockZone | nil
--- @field private filterTextDefault string
--- @field private filterText string
--- @field private filterAnimalGroup LivestockAnimalGroup
local LivestockZonesController = {};

--- @return LivestockZonesIcons
function LivestockZonesController:getZonesIcons()
    return self.zonesIcons;
end
--- @return LivestockZonesIcons
function LivestockZonesController:getAnimalsProvider()
    return self.animalsProvider;
end

--- @return LivestockZonesAnimalTypes
function LivestockZonesController:getAnimalTypes()
    return self.animalTypes;
end

--- @return LivestockZonesStatsProvider
function LivestockZonesController:getZoneStatsProvider()
    return self.zoneStatsProvider;
end

--- @return LivestockZonesEvents
function LivestockZonesController:getEvents()
    return self.events;
end

--- @param livestockZone LivestockZone
--- @param name string
--- @return boolean
function LivestockZonesController:setZoneName(livestockZone, name)
    print("LivestockZonesController:setZoneName " .. livestockZone:getName() .. " : " .. name)

    if not livestockZone or not name then
        return;
    end

    -- todo: move to validator
    newZoneName = string.trim(name);

    if livestockZone:getName() == newZoneName then
        return;
    end

    local nameLen = string.len(newZoneName);

    if nameLen <= 0 or nameLen > 30 then
        return;
    end

    livestockZone:setName(newZoneName);

    if self.zoneProvider:updateZoneProperties(livestockZone) then
        return true;
    end

    return false;
end

--- @param livestockZone LivestockZone
--- @param icon string
--- @return boolean
function LivestockZonesController:setZoneIcon(livestockZone, icon)
    print("LivestockZonesController:setZoneIcon " .. livestockZone:getName() .. " : " .. icon)

    if not livestockZone or not icon then
        return;
    end

    -- todo: move to validator
    newZoneIcon = string.trim(icon);

    if livestockZone:getIcon() == newZoneIcon then
        return;
    end

    livestockZone:setIcon(newZoneIcon);

    if self.zoneProvider:updateZoneProperties(livestockZone) then
        return true;
    end

    return false;
end

--- @return LivestockZone | nil
function LivestockZonesController:getZoneStats(livestockZone)
    return self.zoneStatsProvider:getZoneStats(livestockZone);
end

--- @param zoneId number
--- @return LivestockZone | nil
function LivestockZonesController:getZoneById(zoneId)
    self:resetFilters();
    local livestockZones = self:getLivestockZones(false);

    for i = 0, livestockZones:size() - 1 do
        --- @type LivestockZone
        local livestockZone = livestockZones:get(i);

        if livestockZone:getAnimalZone():getId() == zoneId then
            return livestockZone;
        end
    end

    return nil;
end

--- @return LivestockZone | nil
function LivestockZonesController:getActiveZone()
    return self.activeLivestockZone;
end

--- @return LivestockZone | nil
function LivestockZonesController:getFirstZone()
    local livestockZones = self:getLivestockZones(false);

    if livestockZones:size() > 0 then
        return livestockZones:get(0);
    end

    return nil;
end

--- @return LivestockZone | nil
function LivestockZonesController:getActiveOrFirstZone()
    if self.activeLivestockZone then
        return self.activeLivestockZone;
    end

    return self:getFirstZone();
end

--- @param livestockZone LivestockZone | nil
--- @return boolean
function LivestockZonesController:setActiveZone(livestockZone)
    log(DebugType.Zone, "LivestockZonesController:setActiveZone")

    if self.activeLivestockZone == livestockZone then
        return;
    end

    if (livestockZone and livestockZone:exists() == true) then
        self.activeLivestockZone = livestockZone;
        self:highlightActiveAnimalZone();
        self.events.onActiveLivestockZoneChanged:trigger(livestockZone);

        return true;
    end

    self.activeLivestockZone = nil;
    self.events.onActiveLivestockZoneChanged:trigger(livestockZone);

    return false;
end

--- @return string
function LivestockZonesController:getFilterText()
    return self.filterText;
end

--- @return string
function LivestockZonesController:getFilterTextDefault()
    return self.filterTextDefault;
end

--- @param text string
function LivestockZonesController:setFilterText(text)
    log(DebugType.Zone, "LivestockZonesController:setFilterText: " .. text);

    if not type(value) == "string" then
        text = self.filterTextDefault;
    end

    if self.filterText == text then
        return;
    end

    self.filterText = text;
    self.livestockZones = nil;
    self.events.onLivestockZonesUpdated:trigger(self);
end

--- @return string
function LivestockZonesController:getFilterAnimalGroup()
    return self.filterAnimalGroup;
end

--- @param animalGroup LivestockAnimalGroup
function LivestockZonesController:setFilterAnimalGroup(animalGroup)
    log(DebugType.Zone, "LivestockZonesController:setFilterAnimalGroup: " .. animalGroup:getType());

    if not animalGroup then
        animalGroup = self.animalTypes:getDefaultGroup();
    end

    if self.filterAnimalGroup == animalGroup then
        return
    end

    self.filterAnimalGroup = animalGroup;
    self.livestockZones = nil;
    self.events.onLivestockZonesUpdated:trigger(self);
end

--- @return boolean
function LivestockZonesController:resetFilters()
    log(DebugType.Zone, "LivestockZonesController:resetFilters");

    local needsReset = false;

    if self.filterText ~= self.filterTextDefault then
        self.filterText = self.filterTextDefault;
        needsReset = true;
    end

    if self.filterAnimalGroup ~= self.animalTypes:getDefaultGroup() then
        self.filterAnimalGroup = self.animalTypes:getDefaultGroup();
        needsReset = true;
    end

    if needsReset then
        self:resetZones();
    end

    return needsReset;
end

--- @return void
function LivestockZonesController:resetZones()
    log(DebugType.Zone, "LivestockZonesController:resetZones");

    self.activeLivestockZone = nil;
    self.livestockZones = nil;
    self.events.onLivestockZonesUpdated:trigger(self);
end

--- @param forceUpdate boolean
--- @return ArrayList<LivestockZone>
function LivestockZonesController:getLivestockZones(forceUpdate)
    if self.livestockZones ~= nil and (not forceUpdate) then
        return self.livestockZones;
    end

    self.player:resetSelectedZonesForHighlight();
    self.livestockZones = self.zoneProvider:getAll(self.filterText, self.filterAnimalGroup);

    if self.livestockZones:size() == 0 then
        self.activeLivestockZone = nil;
        self.events.onActiveLivestockZoneChanged:trigger(nil);
    end

    return self.livestockZones;
end

--- @return boolean
function LivestockZonesController:isShowDesignationZones()
    return self.player:isSeeDesignationZone();
end

--- @param state boolean
function LivestockZonesController:setShowDesignationZones(state)
    self.player:setSeeDesignationZone(state);
    self:highlightActiveAnimalZone();
end

function LivestockZonesController:highlightActiveAnimalZone()
    self.player:resetSelectedZonesForHighlight();

    if ((not self.activeLivestockZone) or (not self:isShowDesignationZones())) then
        return;
    end

    local connectedZones = self.activeLivestockZone:getConnectedZones();

    for i = 0, connectedZones:size() - 1 do
        self.player:addSelectedZoneForHighlight(connectedZones:get(i):getId());
    end
end

--- @param livestockZone LivestockZone
function LivestockZonesController:removeZone(livestockZone)
    if not livestockZone then
        return;
    end

    self.zoneProvider:removeZone(livestockZone);
    self:resetZones();

    if self.activeLivestockZone then
        self:setActiveZone(self:getFirstZone());
    end
end

--- @param player IsoPlayer
--- @param zoneProvider LivestockZonesProvider
--- @param animalsProvider LivestockZonesAnimals
--- @param zoneStatsProvider LivestockZonesStatsProvider
--- @param storage LivestockZonesStorage
--- @param animalTypes LivestockZonesAnimalTypes
--- @param zonesIcons LivestockZonesIcons
--- @param events LivestockZonesEvents
--- @param filterTextDefault string
--- @return LivestockZonesController
function livestockZonesController.new(
    player,
    zoneProvider,
    animalsProvider,
    zoneStatsProvider,
    storage,
    animalTypes,
    zonesIcons,
    events,
    filterTextDefault
)
    local self = {}
    setmetatable(self, { __index = LivestockZonesController });

    self.player = player;
    self.zoneProvider = zoneProvider;
    self.animalsProvider = animalsProvider;
    self.zoneStatsProvider = zoneStatsProvider;
    self.storage = storage;
    self.animalTypes = animalTypes;
    self.zonesIcons = zonesIcons;
    self.events = events;

    self.filterTextDefault = filterTextDefault;
    self.filterText = filterTextDefault;
    self.filterAnimalGroup = animalTypes:getDefaultGroup();

    self.livestockZones = nil;
    self.activeLivestockZone = nil;

    return self;
end

-- todo: listen events
--Events.LevelPerk.Add(...);

return livestockZonesController;
