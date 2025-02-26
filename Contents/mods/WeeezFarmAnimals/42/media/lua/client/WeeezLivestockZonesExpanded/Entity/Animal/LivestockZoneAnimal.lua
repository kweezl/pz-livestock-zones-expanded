--- @module livestockZonesAnimal
local livestockZonesAnimal = {};

-- todo: class by animal type
--- @class LivestockZonesAnimal
local LivestockZonesAnimal = {};

--- @return AnimalData
function LivestockZonesAnimal:getData()
    return self.animal:getData();
end

--- @return IsoAnimal
function LivestockZonesAnimal:getIsoAnimal()
    return self.animal;
end

--- @return Texture
function LivestockZonesAnimal:getTexture()
    return self.texture;
end

--- @return string
function LivestockZonesAnimal:getName()
    return self.animal:getFullName();
end

--- @return number
function LivestockZonesAnimal:getAge()
    return self.animal:getAge();
end

--- @return boolean
function LivestockZonesAnimal:isBaby()
    return self.animal:isBaby();
end

--- @return boolean
function LivestockZonesAnimal:isCanBePet()
    return self.animal:canBePet();
end

--- @return boolean
function LivestockZonesAnimal:isOutsideHutch()
    return not self.animal:getHutch();
end

--- @return boolean
function LivestockZonesAnimal:isThirsty()
    return self.animal:getThirst() >= 0.1;
end

--- @return boolean
function LivestockZonesAnimal:isHungry()
    return self.animal:getHunger() >= 0.1;
end

--- @return boolean
function LivestockZonesAnimal:isCanBeMilked()
    return self.animal:canBeMilked() and animal:getData():getMilkQuantity() > 0.1;
end

--- @return boolean
function LivestockZonesAnimal:isCanBeSheared()
    return self.animal:canBeSheared();
end
--- @return boolean
function LivestockZonesAnimal:isCanBeAttachedToPlayer()
    return self.animal:getBehavior():canBeAttached() and not animal:getData():getAttachedPlayer();
end

--- @param animal IsoAnimal
--- @param texture Texture
--- @return LivestockZonesAnimal
function livestockZonesAnimal.new(animal, texture)
    local self = {};
    setmetatable(self, { __index = LivestockZonesAnimal })

    self.animal = animal;
    self.texture = texture;

    return self;
end

return livestockZonesAnimal;
