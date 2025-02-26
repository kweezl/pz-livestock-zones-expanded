require("ISUI/ISEquippedItem")

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local initialise = ISEquippedItem.initialise;
local onOptionMouseDown = ISEquippedItem.onOptionMouseDown;
local prerender = ISEquippedItem.prerender;

function ISEquippedItem:initialise()
    initialise(self);

    -- reuse the same ui button
    -- overrides switch name
    self.zoneBtn.internal = config.zoneBtnInternal;
end

function ISEquippedItem:prerender()
    prerender(self);

    if self.zoneBtn == nil then
        return;
    end

    local livestockZoneWindowStyle = config.livestockZoneWindowStyle;
    local ui = ISEntityUI.players[self.chr:getPlayerNum()];

    if ui and ui.windows[livestockZoneWindowStyle] and ui.windows[livestockZoneWindowStyle].instance then
        self.zoneBtn:setImage(self.zoneIconOn);
    else
        self.zoneBtn:setImage(self.zoneIcon);
    end
end

function ISEquippedItem:onOptionMouseDown(button, x, y)
    onOptionMouseDown(self, button, x, y);

    if button.internal ~= config.zoneBtnInternal then
        return;
    end

    local windowInstance;
    local livestockZoneWindowStyle = config.livestockZoneWindowStyle;
    local ui = ISEntityUI.players[self.chr:getPlayerNum()];

    if ui and ui.windows[livestockZoneWindowStyle] then
        windowInstance = ui.windows[livestockZoneWindowStyle].instance;
    end

    if windowInstance then
        windowInstance:close();
    else
        ISEntityUI.OpenLivestockZones(self.chr, nil);
    end
end
