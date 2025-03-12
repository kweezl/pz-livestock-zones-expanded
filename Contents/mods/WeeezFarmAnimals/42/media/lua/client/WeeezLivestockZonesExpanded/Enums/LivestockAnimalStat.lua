--- @module livestockAnimalStat
local livestockAnimalStat = {};

local list = ArrayList:new();

--- @enum stat
local stat = {}

stat.age = "age"
stat.alerted = "alerted"
stat.health = "health"
stat.stress = "stress"
stat.wild = "wild"

list:add(stat.age);
list:add(stat.alerted);
list:add(stat.stress);
list:add(stat.wild);

livestockAnimalStat.stat = stat;
livestockAnimalStat.list = list

return livestockAnimalStat;
