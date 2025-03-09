require("TimedActions/WalkToTimedActionF");
local state = require("WeeezLivestockZonesExpanded/Enums/TimedActionState");

local walkToAnimalHead = {};

--- @class WalkToAnimalHead
--- @field private state TimedActionState
--- @field private result BehaviorResult
local WalkToAnimalHead = ISWalkToTimedActionF:derive("WalkToAnimalHead");

--- @return number
function WalkToAnimalHead:getState()
    return self.state;
end

--- @return boolean
function WalkToAnimalHead:isValid()
    local result = ISWalkToTimedActionF.isValid(self);

    if result == false then
        self.state = state.stopped;
    end

    return result;
end

function WalkToAnimalHead:isSucceeded()
    return self.result == BehaviorResult.Succeeded;
end

function WalkToAnimalHead:start()
    ISWalkToTimedActionF.start(self);
    self.state = state.started;
end

function WalkToAnimalHead:stop()
    ISWalkToTimedActionF.stop(self);
    self.state = state.stopped;
end

function WalkToAnimalHead:perform()
    ISWalkToTimedActionF.perform(self);
    self.state = state.completed;
end

--- @param player IsoPlayer
--- @param animal IsoAnimal
--- @return WalkToAnimalHead
function walkToAnimalHead.new(player, animal)
    animal:getBehavior():setBlockMovement(true);
    local action = WalkToAnimalHead:new(player, animal:getAttachmentWorldPos("head"));
    action.state = state.unspecified;

    return action;
end

return walkToAnimalHead;
