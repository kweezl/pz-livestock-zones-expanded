require("TimedActions/WalkToTimedAction");
local state = require("WeeezLivestockZonesExpanded/Enums/TimedActionState");

--- @module walkToAnimal
local walkToAnimal = {};

--- @class WalkToAnimal
--- @field private state TimedActionState
--- @field private result BehaviorResult
local WalkToAnimal = ISWalkToTimedAction:derive("WalkToAnimal");

--- @return number
function WalkToAnimal:getState()
    return self.state;
end

--- @return boolean
function WalkToAnimal:isValid()
    local result = ISWalkToTimedAction.isValid(self);

    if result == false then
        self.state = state.stopped;
    end

    return result;
end

--- @return boolean
function WalkToAnimal:isSucceeded()
    return self.result == BehaviorResult.Succeeded;
end

function WalkToAnimal:start()
    ISWalkToTimedAction.start(self);
    self.state = state.started;
end

function WalkToAnimal:stop()
    ISWalkToTimedAction.stop(self);
    self.state = state.stopped;
end

function WalkToAnimal:perform()
    ISWalkToTimedAction.perform(self);
    self.state = state.completed;
end

--- @param player IsoPlayer
--- @param animal IsoAnimal
--- @return WalkToAnimal
function walkToAnimal.new(player, animal)
    animal:getBehavior():setBlockMovement(true);
    local action = WalkToAnimal:new(player, animal:getCurrentSquare());
    action.state = state.unspecified;

    return action;
end

return walkToAnimal;
