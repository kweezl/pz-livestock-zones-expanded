require "ISUI/ISPanel"
local styles = require "WeeezLivestockZonesExpanded/Defaults/Styles"

local UI_BORDER_SPACING = 10
local LIST_FAVICON_SIZE = 16

--- @class LivestockZonesList: ISPanel
--- @field private zoneController LivestockZonesController
--- @field private filterPanel LivestockZonesListFilter
--- @field private bodyPanel LivestockZonesListBody
--- @field private footerPanel LivestockZonesListFooter
LivestockZonesList = ISPanel:derive("LivestockZonesList");

function LivestockZonesList:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesList")
end

-- contains filter and list
function LivestockZonesList:createChildren()
    ISPanel.createChildren(self);

    -- main table
    local styleName = "S_TableLayout_Main";
    local styleCell = "ISTableLayoutCell";

    self.rootTable = ISXuiSkin.build(self.xuiSkin, styleName, ISTableLayout, 0, 0, 10, 10, nil, nil, styleCell);
    self.rootTable.drawDebugLines = self.drawDebugLines;
    self.rootTable:addColumnFill(nil);
    self.rootTable:initialise();
    self.rootTable:instantiate();
    self.rootTable.borderColor = { r=0, g=0, b=0, a=0 }
    self:addChild(self.rootTable);

    self:createFilterPanel(self.rootTable);
    self:createBodyPanel(self.rootTable);
    self:createFooterPanel(self.rootTable);
end

function LivestockZonesList:createFilterPanel(parentTable)
    self.filterPanel = ISXuiSkin.build(
        self.xuiSkin,
        "ISPanel_LivestockZones",
        LivestockZonesListFilter,
        0,
        0,
        10,
        10,
        self.zoneController
    );

    self.filterPanel.searchInfoText = getText("IGUI_DesignationZone_Search_Zones");
    self.filterPanel.needFilterCombo = false;
    self.filterPanel.drawDebugLines = self.drawDebugLines;

    self.filterPanel:initialise();
    self.filterPanel:instantiate();

    self.filterPanelRow = parentTable:addRow(nil);
    self.filterPanelRow.borderColor = { r=0, g=0, b=0, a=0 }
    parentTable:setElement(0, self.filterPanelRow:index(), self.filterPanel);
    parentTable:cell(0, self.filterPanelRow:index()).borderColor = { r=0, g=0, b=0, a=0 }
end

function LivestockZonesList:createBodyPanel(parentTable)
    self.bodyPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesListBody,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );
    self.bodyPanel:initialise();
    self.bodyPanel:initialise();

    local row = parentTable:addRowFill(nil);
    parentTable:setElement(0, row:index(), self.bodyPanel);
    parentTable:cell(0, row:index()).padding = 0;
    parentTable:cell(0, row:index()).paddingLeft = 0;
    parentTable:cell(0, row:index()).paddingRight = 0;
    parentTable:cell(0, row:index()).borderColor = { r=0, g=0, b=0, a=0 }
end

function LivestockZonesList:createFooterPanel(parentTable)
    self.footerPanel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesListFooter,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );
    self.footerPanel.drawDebugLines = self.drawDebugLines;
    self.footerPanel:initialise();
    self.footerPanel:instantiate();

    parentTable:setElement(0, parentTable:addRow(nil):index(), self.footerPanel);
end

function LivestockZonesList:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);

    self.rootTable:calculateLayout(width, height);

    width = math.max(width, self.rootTable:getWidth());
    height = math.max(height, self.rootTable:getHeight());

    self.bodyPanel:calculateLayout(width, height);

    local cell = self.rootTable:cellFor(self.bodyPanel);
    self.bodyPanel:setInternalDimensions(0, 5, cell:getWidth(), cell:getHeight() - 10);

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesList:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesList:prerender()
    ISPanel.prerender(self);
end

function LivestockZonesList:close()
    ISPanel.close(self);

    if self.filterPanel then
        self.filterPanel:close();
    end

    if self.bodyPanel then
        self.bodyPanel:close();
    end

    if self.footerPanel then
        self.footerPanel:close();
    end
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param player IsoPlayer
--- @param zoneController LivestockZonesController
function LivestockZonesList:new(x, y, width, height, player, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, { __index = self })

    o.player = player;
    o.zoneController = zoneController;

    o.borderColor = { r=0, g=0, b=0, a=0 }
    o.padding = 0;
    o.paddingLeft = 0;
    o.paddingRight = 0;
    o.margin = 0;
    o.marginLeft = 0;
    o.marginRight = 0;
    o.background = false;

    return o;
end
