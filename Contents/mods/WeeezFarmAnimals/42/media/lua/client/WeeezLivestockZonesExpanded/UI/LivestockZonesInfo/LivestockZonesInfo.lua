require("ISUI/ISPanel");

--- @class LivestockZonesInfo: ISPanel
--- @field private zoneController LivestockZonesController
--- @field private livestockZone LivestockZone | nil
--- @field private titlePanel LivestockZonesInfoTitle | nil
--- @field private controlsPanel LivestockZonesInfoControls | nil
--- @field private overlayPanel LivestockZonesInfoOverlay | nil
--- @field private detailsPanel LivestockZonesInfoDetails | nil
--- @field private animalsPanel LivestockZonesInfoAnimals | nil
LivestockZonesInfo = ISPanel:derive("LivestockZonesInfo");

function LivestockZonesInfo:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfo");

    local events = self.zoneController:getEvents();
    events.onActiveLivestockZoneChanged:addListener(self.onActiveLivestockZoneChangedListener);
    events.onPetAnimalAction:addListener(self.onPetAnimalListener);
    events.onPetZoneAnimalsStop:addListener(self.onPetAnimalsStopListener);
end

function LivestockZonesInfo:createChildren()
    ISPanel.createChildren(self);
    self:createDynamicChildren();
end

function LivestockZonesInfo:createDynamicChildren()
    if self.titlePanel then
        ISUIElement.removeChild(self, self.titlePanel);
        self.titlePanel = nil;
    end

    if self.controlsPanel then
        ISUIElement.removeChild(self, self.controlsPanel);
        self.controlsPanel = nil;
    end

    if self.overlayPanel then
        ISUIElement.removeChild(self, self.overlayPanel);
        self.overlayPanel = nil;
    end

    if self.detailsTable then
        self.detailsTable:clearTable();
        ISUIElement.removeChild(self, self.detailsTable);
        self.detailsTable = nil;
    end

    if self.detailsPanel then
        ISUIElement.removeChild(self, self.detailsPanel);
        self.detailsPanel = nil;
    end

    if self.animalsPanel then
        ISUIElement.removeChild(self, self.animalsPanel);
        self.animalsPanel = nil;
    end

    if not self.livestockZone then
        self:setWidth(0);
        self:setVisible(false);
        self:xuiRecalculateLayout();
        return;
    end

    ISPanel.setVisible(self, true);
    self:createTitlePanel();
    self:createControlsPanel();
    self:createOverlayPanel();
    self:createDetailsPanel();
    self:createAnimalsPanel();
    self:xuiRecalculateLayout();
end

function LivestockZonesInfo:createTitlePanel()
    ---@type LivestockZonesInfoTitle
    self.titlePanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_WidgetTitleHeader_Std",
        LivestockZonesInfoTitle,
        0,
        0,
        10,
        10,
        self.livestockZone
    );
    self.titlePanel:initialise();
    self.titlePanel:instantiate();
    self:addChild(self.titlePanel);
    self.titlePanel.drawDebugLines = self.drawDebugLines;
end

function LivestockZonesInfo:createControlsPanel()
    ---@type LivestockZonesInfoControls
    self.controlsPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesInfoControls,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );
    self.controlsPanel:setOnClickRenameZone(self, self.onClickRenameZone);
    self.controlsPanel:setOnClickChangeZoneIcon(self, self.onClickChangeZoneIcon);
    self.controlsPanel:setOnClickRemoveZone(self, self.onClickRemoveZone);
    self.controlsPanel:setOnClickPetZoneAnimals(self, self.onClickPetZoneAnimals);
    self.controlsPanel:initialise();
    self.controlsPanel:instantiate();
    self:addChild(self.controlsPanel);
    self.controlsPanel.drawDebugLines = self.drawDebugLines;
end

function LivestockZonesInfo:createOverlayPanel()
    ---@type LivestockZonesInfoOverlay
    self.overlayPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesInfoOverlay,
        0,
        0,
        10,
        10,
        self.zoneController:getZonesIcons(),
        self.livestockZone
    );
    self.overlayPanel:setOnRename(self, self.onActionRenameZone);
    self.overlayPanel:setOnChangeIcon(self, self.onActionChangeZoneIcon);
    self.overlayPanel:setOnRemove(self, self.onActionRemoveZone);
    self.overlayPanel:setOnCancelPetAnimals(self, self.onActionCancelPetAnimals);
    self.overlayPanel:initialise();
    self.overlayPanel:instantiate();
    self:addChild(self.overlayPanel);
    self.overlayPanel:setVisible(false);
    self.overlayPanel.drawDebugLines = self.drawDebugLines;

    self:onPetZoneAnimalsIsRunning(self.livestockZone);
end

function LivestockZonesInfo:createDetailsPanel()
    ---@type LivestockZonesInfoControls
    self.detailsPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesInfoDetails,
        0,
        0,
        10,
        10,
        self.livestockZone,
        self.zoneController:getZoneStats(self.livestockZone)
    );
    self.detailsPanel:initialise();
    self.detailsPanel:instantiate();
    self.detailsPanel.drawDebugLines = self.drawDebugLines;
    self:addChild(self.detailsPanel);
end

function LivestockZonesInfo:createAnimalsPanel()
    ---@type LivestockZonesInfoControls
    self.animalsPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesInfoAnimals,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController:getAnimalsProvider(),
        self.livestockZone
    );
    self.animalsPanel:initialise();
    self.animalsPanel:instantiate();
    self:addChild(self.animalsPanel);
    self.animalsPanel.drawDebugLines = self.drawDebugLines;
end

function LivestockZonesInfo:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);
    local panelPadding = 5;

    local titlePanelHeight = 0;
    local controlsPanelHeight = 0;

    if self.titlePanel then
        self.titlePanel:calculateLayout(width, 0);
        titlePanelHeight = self.titlePanel:getHeight();
        width = math.max(width, self.titlePanel:getWidth());
    end

    if self.controlsPanel then
        self.controlsPanel:calculateLayout(width, 0);
        self.controlsPanel:setY(titlePanelHeight + panelPadding);
        controlsPanelHeight = self.controlsPanel:getHeight() + titlePanelHeight + panelPadding;
        width = math.max(width, self.controlsPanel:getWidth());
    end

    if self.overlayPanel then
        local titleX = 0;
        local titleY = 0;
        local iconX = 0;
        local iconY = 0;

        if self.titlePanel then
            titleX, titleY, iconX, iconY = self.titlePanel:getCoords();
        end

        self.overlayPanel:calculateLayout(width, controlsPanelHeight, titleX, titleY, iconX, iconY);
    end

    local detailsPanelWidth = 0;
    local nextY = controlsPanelHeight + panelPadding;

    if self.detailsPanel then
        self.detailsPanel:calculateLayout(width, height - controlsPanelHeight - panelPadding);
        self.detailsPanel:setX(0);
        self.detailsPanel:setY(nextY);
        detailsPanelWidth = self.detailsPanel:getWidth();
    end

    if self.animalsPanel then
        self.animalsPanel:calculateLayout(width - detailsPanelWidth - 5, height - controlsPanelHeight - panelPadding);
        self.animalsPanel:setX(detailsPanelWidth + 5);
        self.animalsPanel:setY(nextY);
    end

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesInfo:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesInfo:prerender()
    ISPanel.prerender(self);
end

function LivestockZonesInfo:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfo:update()
    ISPanel.update(self);
end

function LivestockZonesInfo:close()
    ISPanel.close(self);

    local events = self.zoneController:getEvents();
    events.onActiveLivestockZoneChanged:removeListener(self.onActiveLivestockZoneChangedListener);
    events.onPetAnimalAction:removeListener(self.onPetAnimalListener);
    events.onPetZoneAnimalsStop:removeListener(self.onPetAnimalsStopListener);

    if self.titlePanel then
        self.titlePanel:close();
    end

    if self.controlsPanel then
        self.controlsPanel:close();
    end

    if self.controlsPanel then
        self.overlayPanel:close();
    end

    if self.detailsPanel then
        self.detailsPanel:close();
    end

    if self.overlayPanel then
        self.overlayPanel:close();
    end
end

-- events

function LivestockZonesInfo:onActiveLivestockZoneChanged(livestockZone)
    self.livestockZone = livestockZone;
    self:createDynamicChildren();
    self:onPetZoneAnimalsIsRunning(livestockZone);
end

function LivestockZonesInfo:onClickRenameZone()
    self.titlePanel:setVisible(false);
    self.controlsPanel:setVisible(false);
    self.overlayPanel:activate(self.overlayPanel.modeNameChange);
end

function LivestockZonesInfo:onActionRenameZone(isChanged, newZoneName)
    self.titlePanel:setVisible(true);
    self.controlsPanel:setVisible(true);
    self.overlayPanel:deactivate();

    if not isChanged or not newZoneName then
        return;
    end

    if not  self.zoneController:setZoneName(self.livestockZone, newZoneName) then
        return;
    end

    self.titlePanel:updateZone();
end

function LivestockZonesInfo:onClickChangeZoneIcon()
    self.titlePanel:setVisible(false);
    self.controlsPanel:setVisible(false);
    self.overlayPanel:activate(self.overlayPanel.modeIconChange);
end

function LivestockZonesInfo:onActionChangeZoneIcon(isChanged, newZoneIcon)
    self.titlePanel:setVisible(true);
    self.controlsPanel:setVisible(true);
    self.overlayPanel:deactivate();

    if not isChanged or not newZoneIcon then
        return;
    end

    if not self.zoneController:setZoneIcon(self.livestockZone, newZoneIcon) then
        return;
    end

    self.titlePanel:updateZone();
end

function LivestockZonesInfo:onClickRemoveZone()
    self.titlePanel:setVisible(false);
    self.controlsPanel:setVisible(false);
    self.overlayPanel:activate(self.overlayPanel.modeRemove);
end

--- @param isConfirmed boolean
function LivestockZonesInfo:onActionRemoveZone(isConfirmed)
    self.titlePanel:setVisible(true);
    self.controlsPanel:setVisible(true);
    self.overlayPanel:deactivate();

    if not isConfirmed then
        return;
    end

    self.zoneController:removeZone(self.livestockZone);
end

--- @param livestockZone LivestockZone
function LivestockZonesInfo:onPetZoneAnimalsIsRunning(livestockZone)
    local petAnimals = self.zoneController:getPetZoneAnimals();

    if not petAnimals:isRunningInZone(livestockZone) then
        return;
    end

    self.titlePanel:setVisible(false);
    self.controlsPanel:setVisible(false);
    self.overlayPanel:setPetAnimal(petAnimals:getCurrentAnimal());
    self.overlayPanel:activate(self.overlayPanel.modePetAnimals);
end

--- @param livestockZone LivestockZone
function LivestockZonesInfo:onClickPetZoneAnimals(livestockZone)
    if self.zoneController:startPetZoneAnimals(livestockZone) then
        self.titlePanel:setVisible(false);
        self.controlsPanel:setVisible(false);
        self.overlayPanel:activate(self.overlayPanel.modePetAnimals);
    end
end

--- @param livestockZone LivestockZone
--- @param animal LivestockZonesAnimal
function LivestockZonesInfo:onPetAnimal(livestockZone, animal)
    if not self.livestockZone then
        return;
    end

    if livestockZone:getId() == self.livestockZone:getId() then
        self.overlayPanel:setPetAnimal(animal);
        self.animalsPanel:setAnimalSelected(animal);
    end
end

function LivestockZonesInfo:onActionCancelPetAnimals()
    self.zoneController:stopPetZoneAnimals();
end

--- @param livestockZone LivestockZone
function LivestockZonesInfo:onPetAnimalsStop(livestockZone)
    if not self.livestockZone then
        return;
    end

    if livestockZone:getId() ~= self.livestockZone:getId() then
        return;
    end

    self.overlayPanel:deactivate();
    self.titlePanel:setVisible(true);
    self.controlsPanel:setVisible(true);
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param zoneController LivestockZonesController
function LivestockZonesInfo:new(x, y, width, height, player, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.player = player;
    o.zoneController = zoneController;
    o.livestockZone = zoneController:getActiveOrFirstZone()

    o.borderColor = { r=0, g=0, b=0, a=0 }
    o.padding = 0;
    o.paddingTop = 0;
    o.paddingLeft = 0;
    o.paddingBottom = 0;
    o.paddingRight = 0;
    o.margin = 0;
    o.marginLeft = 0;
    o.marginRight = 0;
    o.background = false;

    o.minimumWidth = 600;
    o.minimumHeight = 0;

    o.titleAndControlsCachedHeight = 0;

    o.onActiveLivestockZoneChangedListener = function(livestockZone)
        o:onActiveLivestockZoneChanged(livestockZone);
    end

    o.onPetAnimalListener = function(livestockZone, animal)
        o:onPetAnimal(livestockZone, animal);
    end

    o.onPetAnimalsStopListener = function(livestockZone)
        o:onPetAnimalsStop(livestockZone);
    end

    o.petZoneAnimals = nil;

    return o;
end
