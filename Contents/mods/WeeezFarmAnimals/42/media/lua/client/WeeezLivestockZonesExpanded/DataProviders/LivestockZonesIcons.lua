local config = require("WeeezLivestockZonesExpanded/Defaults/Config");

--- @module livestockZoneIcons
local livestockZonesIcons = {};

--- @class LivestockZonesIcons
local LivestockZonesIcons = {};

--- cached
local zoneIconsCached;

--- @param icons ArrayList<table>
function LivestockZonesIcons:addAnimalDefinitionsIcons(icons)
    local duplicates = {};

    for _, animalBreeds in pairs(AnimalDefinitions.breeds) do
        for breedDef, typeBreeds in pairs(animalBreeds.breeds) do
            breedTypeTitle = getText("IGUI_Breed_" .. breedDef);

            for type, text in pairs(config.iconTypes) do
                local icon = typeBreeds[type];

                if icon and not not duplicates[icon] then
                    icons:add({
                        title = breedTypeTitle .. " " .. text,
                        icon = icon,
                    });
                    duplicates[icon] = 1;
                end
            end
        end
    end
end

function LivestockZonesIcons:init()
    if zoneIconsCached then
        return;
    end

    icons = ArrayList:new();

    for _, definition in pairs(config.zoneIcons) do
        icons:add(definition);
    end

    self:addAnimalDefinitionsIcons(icons)
end

function LivestockZonesIcons:getAll(isWithItemIcons, refresh)
    self:init();

    if not isWithItemIcons then
        return zoneIconsCached;
    end

    local zoneIconsWithItems = zoneIconsCached:clone();
    local items = getAllItems();

    -- not cached, will be slow
    for i = 0, items:size() - 1 do
        local item = items:get(i)

        if not item:getObsolete() and not item:isHidden() then
            --if icon and icon:getName() ~= "Question_On" then
            zoneIconsWithItems:add({
                title = item:getDisplayName(),
                icon = item.ItemName,
            });
            --end
        end
    end

    return icons;
end

--- @param animal IsoAnimal
--- @return string
function LivestockZonesIcons:getAnimalIcon(animal)
    local breed = animal:getBreed();
    local icon;

    if animal:isBaby() then
        icon = breed.invIconBaby
    elseif animal:isFemale() then
        icon = breed.invIconFemale
    else
        icon = breed.invIconMale
    end

    if not icon then
        icon = config.iconTypesDefault;
    end

    return icon;
end

--- @return LivestockZonesIcons
function livestockZonesIcons.new()
    local self = {};
    setmetatable(self, { __index = LivestockZonesIcons })

    return self;
end

return livestockZonesIcons;
