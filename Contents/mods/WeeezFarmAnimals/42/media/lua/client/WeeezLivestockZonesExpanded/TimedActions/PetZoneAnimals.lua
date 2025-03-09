require("ISBaseObject")

local options = require("WeeezLivestockZonesExpanded/Options/LivestockZonesModOptions");
local events = require("WeeezLivestockZonesExpanded/Module/LivestockZonesEvents");

local actionState = require("WeeezLivestockZonesExpanded/Enums/TimedActionState");
local actionType = require("WeeezLivestockZonesExpanded/Enums/TimedActionType");
local actionWalkToAnimal = require("WeeezLivestockZonesExpanded/TimedActions/WalkToAnimal");
local actionWalkToAnimalHead = require("WeeezLivestockZonesExpanded/TimedActions/WalkToAnimalHead");
local actionPetAnimal = require("WeeezLivestockZonesExpanded/TimedActions/PetAnimal");

--- @module petZoneAnimals
local petZoneAnimals = {
    action = action,
};

--- @class PetZoneAnimals
--- @field animalsProvider LivestockZonesAnimals
--- @field player IsoPlayer | nil
--- @field animals ArrayList<LivestockZonesAnimal> | nil
--- @field animalIndex number
local PetZoneAnimals = ISBaseObject:derive("PetZoneAnimals");

--- @return LivestockZonesAnimal | nil
function PetZoneAnimals:getCurrentAnimal()
    if not self:isRunning() then
        return nil;
    end

    return self.animals:get(self.animalIndex);
end

--- @return boolean
function PetZoneAnimals:isRunning()
    return self.livestockZone ~= nil;
end

--- @param livestockZone LivestockZone | nil
--- @return boolean
function PetZoneAnimals:isRunningInZone(livestockZone)
    if not livestockZone then
        return false;
    end

    return self:isRunning() and self.livestockZone:getId() == livestockZone:getId();
end

--- @return LivestockZone
function PetZoneAnimals:getLivestockZone()
    return self.livestockZone;
end

--- @param player IsoPlayer
--- @param livestockZone LivestockZone
function PetZoneAnimals:start(player, livestockZone)
    local animals = self.animalsProvider:getAllForZone(livestockZone);

    if animals:size() == 0 then
        return false;
    end

    self.player = player;
    self.livestockZone = livestockZone;
    self.animals = animals;

    Events.OnKeyPressed.Add(self.onKeyPressedFn);
    events.onPetZoneAnimalsStart:trigger(self.livestockZone);

    return self:next();
end

function PetZoneAnimals:stop()
    Events.OnTick.Remove(self.onTickFn);
    Events.OnKeyPressed.Remove(self.onKeyPressedFn);
    ISTimedActionQueue.clear(self.player);
    events.onPetZoneAnimalsStop:trigger(self.livestockZone);

    self.player = nil;
    self.animals = nil;
    self.action = nil;
    self.actionEnum = actionType.unspecified;
    self.livestockZone = nil;
    self.animalIndex = -1;
end

function PetZoneAnimals:onKeyPressed(key)
    local optionsKey = options.getPetAnimalsStopKey();

    if optionsKey ~= Keyboard.KEY_NONE and key == optionsKey then
        self:stop();
    end
end

function PetZoneAnimals:onTick()
    local currentAction = self.action;
    local currentActionEnum = self.actionEnum;
    local currentActionState = currentAction:getState();

    -- check walk to head ts
    if currentActionEnum == actionType.walkToHead then
        if currentActionState == actionState.completed then
            Events.OnTick.Remove(self.onTickFn);
            self:enqueuePet(self.animals:get(self.animalIndex));
            return;
        end

        if currentActionState == actionState.stopped then
            Events.OnTick.Remove(self.onTickFn);
            self:enqueueWalkToBody(self.animals:get(self.animalIndex));
        end
        return;
    end

    -- check walk to body ts
    if currentActionEnum == actionType.walkToBody then
        if currentActionState == actionState.completed then
            Events.OnTick.Remove(self.onTickFn);
            self:enqueuePet(self.animals:get(self.animalIndex));
            return;
        end

        if currentActionState == actionState.stopped then
            Events.OnTick.Remove(self.onTickFn);
            self:next();
        end
        return;
    end

    -- check pet ts
    if currentActionEnum == actionType.pet then
        if currentActionState == actionState.completed or currentActionState == actionState.stopped then
            Events.OnTick.Remove(self.onTickFn);
            self:next();
        end
        return;
    end

    self:stop();
end

--- @return boolean
function PetZoneAnimals:next()
    local animalsTotal = self.animals:size();

    if animalsTotal == 0 or self.animalIndex >= animalsTotal then
        self:stop();

        return false;
    end

    for i = self.animalIndex + 1, animalsTotal - 1 do
        self.animalIndex = i;
        --- @type LivestockZonesAnimal
        local animal = self.animals:get(i);

        if animal and animal:isCanBePet() and animal:isOutsideHutch() and not animal:isInVehicle() then
            self:enqueueWalkToHead(animal);

            return true;
        end
    end

    -- no more animals to pet
    self:stop();

    return false;
end

--- @param animal LivestockZonesAnimal
function PetZoneAnimals:enqueueWalkToHead(animal)
    local isoAnimal = animal:getIsoAnimal();
    isoAnimal:getBehavior():setBlockMovement(true);
    self.action = actionWalkToAnimalHead.new(self.player, isoAnimal);
    self.actionEnum = actionType.walkToHead;
    ISTimedActionQueue.add(self.action);
    events.onPetAnimalAction:trigger(self.livestockZone, animal, self.actionEnum);
    Events.OnTick.Add(self.onTickFn);
end

--- @param animal LivestockZonesAnimal
function PetZoneAnimals:enqueueWalkToBody(animal)
    local isoAnimal = animal:getIsoAnimal();
    isoAnimal:getBehavior():setBlockMovement(true);
    self.action = actionWalkToAnimal.new(self.player, isoAnimal);
    self.actionEnum = actionType.walkToBody;
    ISTimedActionQueue.add(self.action);
    events.onPetAnimalAction:trigger(self.livestockZone, animal, self.actionEnum);
    Events.OnTick.Add(self.onTickFn);
end

--- @param animal LivestockZonesAnimal
function PetZoneAnimals:enqueuePet(animal)
    local isoAnimal = animal:getIsoAnimal();
    isoAnimal:getBehavior():setBlockMovement(true);
    self.action = actionPetAnimal.new(self.player, isoAnimal);
    self.actionEnum = actionType.pet;
    ISTimedActionQueue.add(self.action);
    events.onPetAnimalAction:trigger(self.livestockZone, animal, self.actionEnum);
    Events.OnTick.Add(self.onTickFn);
end

--- @param animalsProvider LivestockZonesAnimals
--- @return PetZoneAnimals
function petZoneAnimals.new(animalsProvider)
    local self = {};
    setmetatable(self, { __index = PetZoneAnimals });

    self.animalsProvider = animalsProvider;
    self.player = nil;
    self.animals = nil;
    self.livestockZone = nil;
    self.animalIndex = -1;
    self.action = nil;
    self.actionEnum = actionType.unspecified;

    self.onTickFn = function()
        self:onTick();
    end
    self.onKeyPressedFn = function(key)
        self:onKeyPressed(key);
    end

    return self;
end

return petZoneAnimals;
