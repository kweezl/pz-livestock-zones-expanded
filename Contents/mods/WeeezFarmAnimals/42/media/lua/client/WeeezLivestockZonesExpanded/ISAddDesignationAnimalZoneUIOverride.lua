local livestockZonesExpanded = require("WeeezLivestockZonesExpanded/Module/LivestockZonesExpanded")
local addZone = ISAddDesignationAnimalZoneUI.addZone;
local undisplay = ISAddDesignationAnimalZoneUI.undisplay;

-- hack to catch events
local fakeParentUi = {};
function fakeParentUi:populateList()
    -- do nothing
end

function fakeParentUi:setVisible(state)
    if state then
        local controller = livestockZonesExpanded.getZonesController(getPlayer());
        controller:resetZones();
        controller:getEvents().onLivestockZoneDesignationEnd:trigger();
    end
end

function ISAddDesignationAnimalZoneUI:undisplay()
    self.parentUI = fakeParentUi;
    undisplay(self);
end

function ISAddDesignationAnimalZoneUI:addZone()
    self.parentUI = fakeParentUi;
    addZone(self)
end
