local events = require("Starlit/Events");

---@module LivestockZonesEvents
local livestockZonesEvents = {}

livestockZonesEvents.onLivestockZoneDesignationBegin = events.new();
livestockZonesEvents.onLivestockZoneDesignationEnd = events.new();
livestockZonesEvents.onLivestockZoneRemoveBegin = events.new();
livestockZonesEvents.onLivestockZoneRemoveEnd = events.new();
livestockZonesEvents.onLivestockZonePropertyChangeBegin = events.new();
livestockZonesEvents.onLivestockZonePropertyChangeEnd = events.new();
livestockZonesEvents.onActiveLivestockZoneChanged = events.new();
livestockZonesEvents.onLivestockZonesUpdated = events.new();
livestockZonesEvents.onPetAnimalAction = events.new();
livestockZonesEvents.onPetZoneAnimalsStart = events.new();
livestockZonesEvents.onPetZoneAnimalsStop = events.new();

local tickEventDebugEnabled = false;
local tickNumThreshold = 300;
local tickNum = 0;

local function onTick()
    tickNum = tickNum + 1;

    if tickNum < tickNumThreshold then
        return;
    end

    tickNum = 0;
    print("------- event debug begin ---------");

    for name, events in pairs(livestockZonesEvents) do
        print(name .. ": " .. tostring(#events));
    end

    print("------- event debug end ---------");
end

if tickEventDebugEnabled then
    Events.OnTick.Add(onTick);
end

return livestockZonesEvents;
