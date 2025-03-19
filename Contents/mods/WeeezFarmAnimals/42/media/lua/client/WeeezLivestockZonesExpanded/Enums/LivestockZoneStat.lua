--- @module livestockZoneStat
local livestockZoneStat = {};

local list = ArrayList.new();

--- @enum stat
local stat = {}

stat.animal = "animal"
stat.connectedZone = "connected_zone"
stat.dung = "dung"
stat.feather = "feather"
stat.feedingTrough = "feeding_trough"
stat.food = "food"
stat.hutch = "hutch"
stat.roofedArea = "roofed_area"
stat.water = "water"
stat.zoneSize = "zone_size"

list:add(stat.animal);
list:add(stat.connectedZone);
list:add(stat.dung);
list:add(stat.feather);
list:add(stat.feedingTrough);
list:add(stat.food);
list:add(stat.hutch);
list:add(stat.roofedArea);
list:add(stat.water);
list:add(stat.zoneSize);

livestockZoneStat.stat = stat;
livestockZoneStat.list = list

return livestockZoneStat;
