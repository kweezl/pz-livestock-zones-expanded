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

return livestockZonesEvents;
