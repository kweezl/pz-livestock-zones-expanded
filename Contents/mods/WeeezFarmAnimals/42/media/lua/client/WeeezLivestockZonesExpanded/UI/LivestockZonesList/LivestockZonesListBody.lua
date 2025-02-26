require("ISUI/ISPanel")

-- todo: move to styles
local UI_BORDER_SPACING = 10
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_HEADING = getTextManager():getFontHeight(UIFont.Small)
local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19; -- normalize to 1080p
local ICON_SCALE = math.max(1, (FONT_SCALE - math.floor(FONT_SCALE)) < 0.5 and math.floor(FONT_SCALE) or math.ceil(FONT_SCALE));
local LIST_ICON_SIZE = math.max(1, 48 * FONT_SCALE)
local LIST_SUBICON_SIZE = 16 * ICON_SCALE
local LIST_SUBICON_SPACING = 2 * ICON_SCALE

--- @class LivestockZonesListBody: ISPanel
--- @field private player IsoPlayer
--- @field private zoneController LivestockZonesController
LivestockZonesListBody = ISPanel:derive("LivestockZonesListBody");

function LivestockZonesListBody:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesListBody")
end

function LivestockZonesListBody:createChildren()
    ISPanel.createChildren(self);

    self.zoneListBox = ISScrollingListBox:new(0, 0, 10, 10);
    self.zoneListBox:initialise();
    self.zoneListBox:instantiate();

    self.zoneListBox.padding = 0;
    self.zoneListBox.paddingTop = 0;
    self.zoneListBox.paddingLeft = 0;
    self.zoneListBox.margin = 0;
    self.zoneListBox.marginTop = 0;
    self.zoneListBox.marginLeft = 0;

    self.zoneListBox.itemheight = math.max(2 + FONT_HGT_HEADING + FONT_HGT_SMALL + UI_BORDER_SPACING, LIST_ICON_SIZE + UI_BORDER_SPACING);
    self.zoneListBox.doDrawItem = function(list, _y, _item, _alt)
        -- todo: clean
        ---@type LivestockZone | nil
        local livestockZone = _item and _item.item;

        if not livestockZone then
            return _y;
        end

        local yActual = list:getYScroll() + _y;

        if _item.cachedHeight and (yActual > list.height or (yActual + _item.cachedHeight) < 0) then
            -- we are outside stencil, dont draw, just return cachedHeight
            return _y + _item.cachedHeight;
        end

        -- compatibility
        if not _item.height then
            _item.height = list.itemheight
        end

        local color = {r=1.0, g=1.0, b=1.0, a=1.0};

        if list.selected == _item.index then
            list:drawRect(0, _y, list:getWidth(), _item.height-1, 0.3, 0.7, 0.35, 0.15);
        end

        list:drawRectBorder(0, _y, list:getWidth(), _item.height, 0.5, list.borderColor.r, list.borderColor.g, list.borderColor.b);

        local detailsLeft = UI_BORDER_SPACING + LIST_ICON_SIZE + UI_BORDER_SPACING;
        local detailsY = 4;

        local fileSize = ".png"
        if LIST_SUBICON_SIZE == 16 then
            fileSize = "_16.png"
        end

        local headerAdj = (LIST_SUBICON_SIZE - FONT_HGT_HEADING) / 2;
        detailsY = detailsY + headerAdj;
        local maxTitleWidth = 200; -- current gap, minus space for Favicon

        local livestockZoneName = livestockZone:getName();
        if not livestockZoneName then
            livestockZoneName = "livestock zone without name";
        end

        local titleStr = getTextManager():WrapText(UIFont.Small, livestockZoneName, maxTitleWidth, 2, "...");
        list:drawText(titleStr, detailsLeft, _y+detailsY, color.r, color.g, color.b, color.a, UIFont.Small);

        local headerTextHeight = getTextManager():MeasureStringY(UIFont.Small, titleStr);

        detailsY = detailsY + headerTextHeight;

        local animalsTotal = self.zoneController:getZoneStatsProvider():getAnimalsTotal(livestockZone);
        local animalsTotalStr = getText("IGUI_DesignationZone_Animals_Total", animalsTotal);
        list:drawText(animalsTotalStr, detailsLeft, _y+detailsY, color.r, color.g, color.b, color.a, UIFont.Small);
        detailsY = detailsY + FONT_HGT_SMALL;

        local usedHeight = math.max(list.itemheight, detailsY + UI_BORDER_SPACING)
        _item.height = usedHeight;
        _item.cachedHeight = usedHeight;

        -- draw icon mid-high
        local iconY = _y + (usedHeight/2)-(LIST_ICON_SIZE/2);
        local texture = livestockZone:getIconTexture()

        if texture then
            list:drawTextureScaledAspect2(texture, UI_BORDER_SPACING, iconY, LIST_ICON_SIZE, LIST_ICON_SIZE, color.a, color.r, color.g, color.b);
        end

        return _y + usedHeight;
    end

    self.zoneListBox.selected = 0;
    self.zoneListBox.drawBorder = true
    self.zoneListBox:setOnMouseDownFunction(self.zoneController, self.zoneController.setActiveZone);
    self.zoneListBox.drawDebugLines = self.drawDebugLines;

    self:addChild(self.zoneListBox);

    self:onLivestockZonesUpdate();
    self:subscribeEvents();
end

function LivestockZonesListBody:onLivestockZonesUpdate()
    local livestockZones = self.zoneController:getLivestockZones();
    local activeZone = self.zoneController:getActiveOrFirstZone();
    local zoneSize = livestockZones:size();
    local activeZoneFound = false;

    self.zoneListBox:clear();

    for i = 0, zoneSize - 1 do
        local livestockZone = livestockZones:get(i);
        local listItem = self.zoneListBox:addItem(livestockZone:getName(), livestockZone);

        if livestockZone == activeZone then
            self.zoneListBox.selected = listItem.itemindex;
            self.zoneController:setActiveZone(activeZone);
            activeZoneFound = true;
        end
    end

    if (zoneSize > 0 and activeZoneFound == false) then
        self.zoneListBox.selected = 1;
        self.zoneController:setActiveZone(livestockZones:get(0));
    end
end

function LivestockZonesListBody:subscribeEvents()
    local events = self.zoneController:getEvents();
    events.onLivestockZonesUpdated:addListener(self.onLivestockZonesUpdateListener)
end

function LivestockZonesListBody:calculateLayout(_preferredWidth, _preferredHeight)
    local width = math.max(self.minimumWidth, _preferredWidth or 0);
    local height = math.max(self.minimumHeight, _preferredHeight or 0);

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesListBody:onResize()
    ISUIElement.onResize(self)

    if self.zoneListBox and self.zoneListBox.selected then
        self.zoneListBox:ensureVisible(self.zoneListBox.selected);
    end
end

function LivestockZonesListBody:prerender()
    ISPanel.prerender(self);

    if self.zoneListBox and self.zoneListBox.vscroll then
        self.zoneListBox.vscroll:setHeight(self.zoneListBox:getHeight());
        self.zoneListBox.vscroll:setX(self.zoneListBox:getWidth()-self.zoneListBox.vscroll:getWidth());
    end
end

function LivestockZonesListBody:render()
    ISPanel.render(self);
end

function LivestockZonesListBody:update()
    ISPanel.update(self);
end

function LivestockZonesListBody:setInternalDimensions(x, y, width, height)
    if self.zoneListBox then
        self.zoneListBox:setHeight(height);
        self.zoneListBox:setWidth(width);
        self.zoneListBox:setX(x);
        self.zoneListBox:setY(y);
    end
end

function LivestockZonesListBody:close()
    ISPanel.close(self);

    local events = self.zoneController:getEvents();
    events.onLivestockZonesUpdated:removeListener(self.onLivestockZonesUpdateListener);
end

--- @return LivestockZonesListBody
function LivestockZonesListBody:new(x, y, width, height, player, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.player = player;
    o.zoneController = zoneController;
    o.enabledShowAllFilter = false;

    o.wrapTooltipText = false;

    o.expandToFitTooltip = false;
    o.largestTooltipWidth = 0;

    o.borderColor = { r=0, g=0, b=0, a=0 }
    o.padding = 0;
    o.paddingLeft = 0;
    o.paddingRight = 0;
    o.margin = 0;
    o.marginLeft = 0;
    o.marginRight = 0;
    o.background = false;

    o.onLivestockZonesUpdateListener = function()
        o:onLivestockZonesUpdate();
    end

    return o;
end
