local options = {
    stopPetAnimalsKey = nil,
}

local initOptions = function()
    local pzOptions = PZAPI.ModOptions:create(
        "WeeezLivestockZonesExpanded",
        getText("IGUI_WeeezLivestockZonesExpanded_Title")
    );

    options.stopPetAnimalsKey = pzOptions:addKeyBind(
        "ContextCraftToggle",
        getText("IGUI_Stop_Pet_Zone_Animals"),
        Keyboard.KEY_ESCAPE,
        getText("IGUI_Stop_Pet_Zone_Animals_Tooltip")
    );
end

local function getStopPetAnimalsKey()
    if options.stopPetAnimalsKey then
        return options.stopPetAnimalsKey:getValue();
    end

    return Keyboard.KEY_NONE;
end

initOptions();

return {
    getPetAnimalsStopKey = getStopPetAnimalsKey,
};
