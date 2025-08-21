require("ISUI/ISPanel");

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local styles = require("WeeezLivestockZonesExpanded/Defaults/Styles");
local statList = require("WeeezLivestockZonesExpanded/Enums/LivestockAnimalStat").list;

local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19;
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MIN_LIST_BOX_WIDTH = 125 * FONT_SCALE;

--- @class LivestockZonesInfoAnimalDetails: ISPanel
--- @field private statsProvider AnimalStatsProvider
LivestockZonesInfoAnimalDetails = ISPanel:derive("LivestockZonesInfoAnimalDetails");

function LivestockZonesInfoAnimalDetails:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfoAnimalDetails")
end

function LivestockZonesInfoAnimalDetails:createChildren()
    ISPanel.createChildren(self);

    self.detailsBox = ISScrollingListBox:new(0, 0, MIN_LIST_BOX_WIDTH, 100);
    self.detailsBox:initialise();
    self.detailsBox:instantiate();
    self.detailsBox.itemheight = 16 + FONT_HGT_SMALL;
    self.detailsBox.selected = 0;
    self.detailsBox.font = UIFont.Small;
    self.detailsBox.doDrawItem = function(detailsBox, y, item, alt)
        return self:drawAnimalDetail(detailsBox, y, item, alt)
    end
    self.detailsBox.drawBorder = true;
    self.detailsBox.background = false;
    self.detailsBox.drawDebugLines = self.drawDebugLines;
    self:addChild(self.detailsBox);
end

function LivestockZonesInfoAnimalDetails:drawAnimalDetail(list, y, item)
    local yScroll = list:getYScroll();
    local height = list:getHeight();
    local itemHeight = list.itemheight;

    if y + yScroll + itemHeight < 0 or y + yScroll >= height then
        return y + itemHeight;
    end

    if not item.height then
        item.height = list.itemheight
    end

    --- @type AnimalStat
    local stat = item.item;
    local titleWidth = self.detailsBoxMaxTitleSize + 30;

    list:drawRectBorder(0, (y), titleWidth, item.height, 0.5, list.borderColor.r, list.borderColor.g, list.borderColor.b);
    list:drawRectBorder(titleWidth, (y), list:getWidth(), item.height, 0.5, list.borderColor.r, list.borderColor.g, list.borderColor.b);

    local itemPadY = list.itemPadY or (item.height - list.fontHgt) / 2;
    list:drawText(stat.title, 15, (y)+itemPadY, 0.9, 0.9, 0.9, 0.9, list.font);
    list:drawText(stat.value, titleWidth + 15, (y)+itemPadY, 0.9, 0.9, 0.9, 0.9, list.font);

    return y + item.height;
end

function LivestockZonesInfoAnimalDetails:calculateLayout(preferredWith, preferredHeight)
    local height = preferredHeight or 0;

    self.detailsBox:setWidth(preferredWith);
    self.detailsBox:setHeight(height);

    self:setWidth(preferredWith);
    self:setHeight(height);
end

function LivestockZonesInfoAnimalDetails:prerender()
    if self.stats then
        self.statsProvider:update(self.stats);
    end

    ISPanel.prerender(self);

    if self.detailsBox and self.detailsBox.vscroll then
        self.detailsBox.vscroll:setHeight(self.detailsBox:getHeight());
        self.detailsBox.vscroll:setX(self.detailsBox:getWidth() - self.detailsBox.vscroll:getWidth());
    end
end

function LivestockZonesInfoAnimalDetails:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfoAnimalDetails:update()
    ISPanel.update(self);
end

function LivestockZonesInfoAnimalDetails:close()
    ISPanel.close(self);
end

--- @param animal LivestockZonesAnimal
function LivestockZonesInfoAnimalDetails:setAnimal(animal)
    local max = math.max;
    local textManager = getTextManager();
    local stats = self.statsProvider:create(animal);

    self.detailsBoxMaxTitleSize = 0;
    self.detailsBox:clear();

    for i = 0, statList:size() - 1 do
        local stat = stats.list[statList:get(i)];

        if stat then
            self.detailsBoxMaxTitleSize = max(
                self.detailsBoxMaxTitleSize,
                textManager:MeasureStringX(UIFont.Small, stat.title)
            );
            self.detailsBox:addItem(stat.title, stat);
        end
    end

    self.stats = stats;
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
function LivestockZonesInfoAnimalDetails:new(x, y, width, height, statsProvider)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.livestockZone = livestockZone;
    o.livestockZoneStats = livestockZoneStats;
    o.minimumWidth = 0
    o.minimumHeight = 0
    o.background = false;

    o.statsProvider = statsProvider;
    o.stats = nil;

    return o;
end
