--- @module livestockAnimalStat
local livestockAnimalStat = {};

--- @enum stat
local stat = {
    type = "type",
    breed = "breed",
    gender = "gender",
    grow_stage = "grow_stage",
    age_days = "age_days",
    next_stage_days = "next_stage_days",
    health = "health",
    stress = "stress",
    wild = "wild",
};

local list = ArrayList.new();
list:add(stat.type);
list:add(stat.breed);
list:add(stat.gender);
list:add(stat.grow_stage);
list:add(stat.age_days);
list:add(stat.next_stage_days);
list:add(stat.stress);
list:add(stat.wild);

livestockAnimalStat.stat = stat;
livestockAnimalStat.list = list;

return livestockAnimalStat;
