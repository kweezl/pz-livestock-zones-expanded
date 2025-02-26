require("ISUI/ISPanel");

local FONT_HGT_SEARCH = getTextManager():getFontHeight(UIFont.Medium);
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.NewMedium);
local UI_BORDER_SPACING = 5;
local BUTTON_HGT_SEARCH = FONT_HGT_SEARCH + 6;

--- @class LivestockZonesInfoTitle
--- @field private livestockZone LivestockZone
--- @field private modeDisplayTitle boolean
LivestockZonesInfoTitle = ISPanel:derive("LivestockZonesInfoTitle");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewSmall)
local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19; -- normalize to 1080p
local ICON_SCALE = math.max(1, (FONT_SCALE - math.floor(FONT_SCALE)) < 0.5 and math.floor(FONT_SCALE) or math.ceil(FONT_SCALE));
local ICON_SIZE = 48 * math.max(1, FONT_SCALE);

function LivestockZonesInfoTitle:initialise()
    ISPanel.initialise(self);
end

function LivestockZonesInfoTitle:createChildren()
    ISPanel.createChildren(self);

    self.icon = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISImage,
        0,
        0,
        ICON_SIZE,
        ICON_SIZE,
        self.livestockZone:getIconTexture()
    );
    self.icon.autoScale = true;
    self.icon:initialise();
    self.icon:instantiate();
    self:addChild(self.icon);

    local fontHeight = -1; -- <=0 sets label initial height to font
    self.titleLabel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISLabel,
        0,
        0,
        fontHeight,
        self.livestockZone:getName(),
        1,
        1,
        1,
        1,
        UIFont.NewMedium,
        true
    );
    self.titleLabel:initialise();
    self.titleLabel:instantiate();
    self.titleLabel:setHeightToName(0);
    self:addChild(self.titleLabel);
end

function LivestockZonesInfoTitle:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);

    -- calc width
    local requiredWidth = self.icon:getWidth() + self.spacing;
    local indent = self.paddingTop + self.paddingBottom + self.marginTop + self.marginBottom;

    requiredWidth = requiredWidth + self.titleLabel:getWidth() + self.spacing;
    width = math.max(width, requiredWidth + indent);

    -- calc height
    height = math.max(height, self.icon:getHeight() + indent);
    local labelsHeight = self.titleLabel:getHeight() + indent;

    height = math.max(height, labelsHeight);

    -- draw labels
    local halfHeight = height / 2;
    local iconY = halfHeight - self.icon:getHeight() / 2;
    self.icon:setX(15);
    self.icon:setY(iconY);

    local titleY = halfHeight - self.titleLabel:getHeight() / 2;
    self.titleLabel:setX(30 + self.icon:getWidth());
    self.titleLabel.originalX = self.titleLabel:getX();
    self.titleLabel:setY(titleY);

    self:setX(0);
    self:setY(0);
    self:setWidth(width);
    self:setHeight(height);
end

--- @return number
function LivestockZonesInfoTitle:getCoords()
    return self.titleLabel:getX(), self.titleLabel:getY(), self.icon:getX(), self.icon:getY();
end

function LivestockZonesInfoTitle:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesInfoTitle:prerender()
    ISPanel.prerender(self);
end

function LivestockZonesInfoTitle:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfoTitle:update()
    ISPanel.update(self);
end

function LivestockZonesInfoTitle:updateZone()
    self.icon.texture = self.livestockZone:getIconTexture();
    self.titleLabel:setName(self.livestockZone:getName());
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param livestockZone LivestockZone
function LivestockZonesInfoTitle:new(x, y, width, height, livestockZone)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, { __index = LivestockZonesInfoTitle })

    o.livestockZone = livestockZone;

    o.paddingTop = 2;
    o.paddingBottom = 2;
    o.paddingLeft = 2;
    o.paddingRight = 2;
    o.padding = 2;

    o.marginTop = 5;
    o.marginBottom = 5;
    o.marginLeft = 5;
    o.marginRight = 5;
    o.margin = 5;

    o.modeDisplayTitle = true;

    o.spacing = 15;
    o.minimumWidth = 0;
    o.minimumHeight = 0;

    return o
end
