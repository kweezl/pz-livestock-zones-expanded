require("TimedActions/Animals/ISPetAnimal");
local state = require("WeeezLivestockZonesExpanded/Enums/TimedActionState");

--- @module petAnimal
local petAnimal = {};

--- @class PetAnimal: ISPetAnimal
--- @field private state state
local PetAnimal = ISPetAnimal:derive("PetAnimal");

--- @return number
function PetAnimal:getState()
    return self.state;
end

--- @return boolean
function PetAnimal:isValid()
    local playerSquare = self.character:getSquare();
    local animalSquare = self.animal:getSquare();
    local result = playerSquare and animalSquare and playerSquare:DistTo(animalSquare) < 3;

    if result == false then
        self.state = state.stopped;
    end

    return result;
end

function PetAnimal:start()
    ISPetAnimal.start(self);
    self.state = state.started;
end

function PetAnimal:stop()
    ISPetAnimal.stop(self);
    self.state = state.stopped;
end

function PetAnimal:animEvent(event)
    if event == "pettingFinished" then
        self.animal:petAnimal(self.character);
        self:forceComplete();
        self.state = state.completed;
    end
end

--- @param player IsoPlayer
--- @param animal IsoAnimal
--- @return PetAnimal | ISPetAnimal
function petAnimal.new(player, animal)
    local o = PetAnimal:new(player, animal);
    o.maxTime = -1;
    o.useProgressBar = true;
    o.state = state.unspecified;

    return o;
end

return petAnimal;
