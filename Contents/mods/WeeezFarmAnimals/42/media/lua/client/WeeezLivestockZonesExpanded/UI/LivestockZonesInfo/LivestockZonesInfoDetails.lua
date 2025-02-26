require("ISUI/ISPanel");

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local styles = require("WeeezLivestockZonesExpanded/Defaults/Styles");
local statList = require("WeeezLivestockZonesExpanded/Enums/LivestockZoneStat").list;

local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19;
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MIN_LIST_BOX_WIDTH = 125 * FONT_SCALE;

--- @class LivestockZonesInfoDetails: ISPanel
--- @field private zoneController LivestockZonesController
--- @field private livestockZone LivestockZone
--- @field private livestockZoneStats LivestockZoneStats
--- @field private rootTable ISTableLayout
--- @field private detailsBox ISScrollingListBox
LivestockZonesInfoDetails = ISPanel:derive("LivestockZonesInfoDetails");

function LivestockZonesInfoDetails:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfoDetails")
end

function LivestockZonesInfoDetails:createChildren()
    ISPanel.createChildren(self);

    self.detailsBox = ISScrollingListBox:new(0, 0, MIN_LIST_BOX_WIDTH, 100);
    self.detailsBox:initialise();
    self.detailsBox:instantiate();
    self.detailsBox.itemheight = 16 + FONT_HGT_SMALL;
    self.detailsBox.selected = 0;
    self.detailsBox.font = UIFont.Small;
    self.detailsBox.doDrawItem = function (detailsBox, y, item, alt)
        return self:drawZoneDetail(detailsBox, y, item, alt)
    end
    self.detailsBox.drawBorder = true;
    self.detailsBox.background = false;
    self.detailsBox.drawDebugLines = self.drawDebugLines;
    self:addChild(self.detailsBox);

    local textManager = getTextManager();
    local valueHidden = config.detailsValueHiddenText;
    local details = config.livestockZoneDetails;
    local valueToString = function(value)
        if value ~= nil then
            return tostring(value);
        end
        return valueHidden;
    end

    self.detailsBoxPadding = 15;
    self.detailsBoxMaxValueSize = 0;
    self.detailsBoxMaxTitleSize = self.detailsBoxMaxTitleSize or 0;
    local isShouldMeasureTitleSize = self.detailsBoxMaxTitleSize == 0;

    local statValues = self.livestockZoneStats:getAll();
    local titleErrStr = "No tat config: ";

    for i = 0, statList:size() - 1 do
        local statName = statList:get(i);
        local statConfig = details[statName];
        local title;
        local value;

        if statConfig then
            title = statConfig["title"] or titleErrStr .. statName;
        else
            title = titleErrStr .. statName;
        end

        value = valueToString(statValues:get(i));
        self.detailsBox:addItem(title, value);

        self.detailsBoxMaxValueSize = math.max(
            self.detailsBoxMaxValueSize,
            textManager:MeasureStringX(UIFont.Small, value)
        );

        if isShouldMeasureTitleSize then
            self.detailsBoxMaxTitleSize = math.max(
                self.detailsBoxMaxTitleSize,
                textManager:MeasureStringX(UIFont.Small, title)
            );
        end
    end
end

function LivestockZonesInfoDetails:drawZoneDetail(detailsBox, y, item)
    if not item.height then
        item.height = detailsBox.itemheight
    end

    if detailsBox.selected == item.index then
        detailsBox:drawRect(0, (y), detailsBox:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15);
    end

    local titleWidth = self.detailsBoxMaxTitleSize + 30;

    detailsBox:drawRectBorder(0, (y), titleWidth, item.height, 0.5, detailsBox.borderColor.r, detailsBox.borderColor.g, detailsBox.borderColor.b);
    detailsBox:drawRectBorder(titleWidth, (y), detailsBox:getWidth(), item.height, 0.5, detailsBox.borderColor.r, detailsBox.borderColor.g, detailsBox.borderColor.b);

    local itemPadY = detailsBox.itemPadY or (item.height - detailsBox.fontHgt) / 2;
    detailsBox:drawText(item.text, 15, (y)+itemPadY, 0.9, 0.9, 0.9, 0.9, detailsBox.font);
    detailsBox:drawText(item.item, titleWidth + 15, (y)+itemPadY, 0.9, 0.9, 0.9, 0.9, detailsBox.font);

    return y + item.height;
end

function LivestockZonesInfoDetails:populateTable()
    local row;
    local borderColor = { r = 1, g = 1, b = 1, a = 0.7 };
    local animalZone = self.livestockZone:getAnimalZone();

    self.rootTable.borderColor = borderColor;

    -- label column
    local labelColumn = self.rootTable:addColumnFill(nil);
    labelColumn.borderColor = borderColor;
    -- value column
    local valueColumn = self.rootTable:addColumnFill(nil);
    valueColumn.borderColor = borderColor;

    row = self.rootTable:addRowFill(nil);
    row.borderColor = borderColor;
    self:createCellElement(self.rootTable, labelColumn:index(), row:index(), getText("IGUI_DesignationZone_Animals"), borderColor);
    self:createCellElement(self.rootTable, valueColumn:index(), row:index(), tostring(animalZone:getAnimalsConnected():size()), borderColor);

    row = self.rootTable:addRowFill(nil);
    row.borderColor = borderColor;
    self:createCellElement(self.rootTable, labelColumn:index(), row:index(), getText("IGUI_FeedingTroughUI_Enclosure"), borderColor);
    self:createCellElement(self.rootTable, valueColumn:index(), row:index(), tostring(animalZone:getFullZoneSize()), borderColor);
end

--- @param parentTable ISTableLayout
--- @param columnIndex number
--- @param rowIndex number
--- @param text string
function LivestockZonesInfoDetails:createCellElement(parentTable, columnIndex, rowIndex, text, borderColor)
    local fontHeight = -1; -- <=0 sets label initial height to font
    local label = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISLabel,
        0,
        0,
        fontHeight,
        text,
        1,
        1,
        1,
        1,
        UIFont.Small,
        true
    );
    label.origTitleStr = text;
    label:initialise();
    label:instantiate();
    label:setHeightToName(0);
    parentTable:setElement(columnIndex, rowIndex, label);
    parentTable:cell(columnIndex, rowIndex).drawBorder = true;
    parentTable:cell(columnIndex, rowIndex).borderColor = borderColor;
    parentTable:cell(columnIndex, rowIndex).anchorLeft = anchorLeft;
end

function LivestockZonesInfoDetails:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(
        self.minimumWidth,
        self.detailsBoxMaxTitleSize + self.detailsBoxMaxValueSize + self.detailsBoxPadding * 4
    )
    --local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);

    if self.detailsBox then
        self.detailsBox:setWidth(width);
        self.detailsBox:setHeight(height);

        if self.detailsBox.vscroll then
            width = width + self.detailsBox.vscroll:getWidth();
            self.detailsBox:setWidth(width);
            self.detailsBox.vscroll:setHeight(self.detailsBox:getHeight());
            self.detailsBox.vscroll:setX(self.detailsBox:getWidth() - self.detailsBox.vscroll:getWidth());
        end
    end

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesInfoDetails:prerender()
    ISPanel.prerender(self);

    if self.detailsBox and self.detailsBox.vscroll then
        self.detailsBox.vscroll:setHeight(self.detailsBox:getHeight());
        self.detailsBox.vscroll:setX(self.detailsBox:getWidth() - self.detailsBox.vscroll:getWidth());
    end
end

function LivestockZonesInfoDetails:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfoDetails:update()
    ISPanel.update(self);
end

function LivestockZonesInfoDetails:close()
    ISPanel.close(self);
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param livestockZone LivestockZone
--- @param livestockZone LivestockZoneStats
function LivestockZonesInfoDetails:new(x, y, width, height, livestockZone, livestockZoneStats)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.livestockZone = livestockZone;
    o.livestockZoneStats = livestockZoneStats;
    o.minimumWidth = 0
    o.minimumHeight = 0
    o.background = false;

    return o;
end
