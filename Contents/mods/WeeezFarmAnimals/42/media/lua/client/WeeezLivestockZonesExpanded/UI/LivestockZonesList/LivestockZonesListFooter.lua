require "ISUI/ISPanel"

local FONT_HGT_SEARCH = getTextManager():getFontHeight(UIFont.Medium);
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.NewMedium);
local UI_BORDER_SPACING = 5;
local BUTTON_HGT_SEARCH = FONT_HGT_SEARCH + 6;

--- @class LivestockZonesListFooter: ISPanel
--- @field private zoneController LivestockZonesController
LivestockZonesListFooter = ISPanel:derive("LivestockZonesListFooter");

function LivestockZonesListFooter:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesListFooter")
end

function LivestockZonesListFooter:createChildren()
    ISPanel.createChildren(self);

    self.btnReloadZones = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        getText("IGUI_DesignationZone_Reload_Zones"),
        self,
        self.onReloadZones
    );
    --self.btnReloadZones.image = getTexture("media/ui/craftingMenus/BuildProperty_Consume.png");
    self.btnReloadZones.enable = true;
    self.btnReloadZones:initialise();
    self.btnReloadZones:instantiate();
    --self.btnReloadZones:forceImageSize(16, 16);
    self:addChild(self.btnReloadZones);

    self.btnCreateZone = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        getText("IGUI_DesignationZone_Add_New_Zone"),
        self,
        self.onAddZone
    );
    --self.btnCreateZone.image = getTexture("media/ui/craftingMenus/BuildProperty_Consume.png");
    self.btnCreateZone.enable = true;
    self.btnCreateZone:initialise();
    self.btnCreateZone:instantiate();
    --self.btnCreateZone:forceImageSize(16, 16);
    self:addChild(self.btnCreateZone);
end

function LivestockZonesListFooter:onReloadZones()
    log(DebugType.Zone, "LivestockZonesListFooter:onReloadZones")

    self.zoneController:resetZones();
end

function LivestockZonesListFooter:onAddZone()
    log(DebugType.Zone, "LivestockZonesListFooter:onAddZone")

    local ui = ISAddDesignationAnimalZoneUI:new(10,10, 320, FONT_HGT_MEDIUM * 8, self.player);
    ui:initialise()
    ui:addToUIManager()
    ui.parentUI = self;

    self.zoneController:getEvents().onLivestockZoneDesignationBegin:trigger();
end

function LivestockZonesListFooter:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesListFooter:render()
    ISPanel.render(self);
end

function LivestockZonesListFooter:update()
    ISPanel.update(self);
end

function LivestockZonesListFooter:calculateLayout(preferredWidth, preferredHeight)
    local uiBorderSpacing = UI_BORDER_SPACING + 1;
    local height = math.max(self.minimumHeight, preferredHeight or 0);
    local width = math.max(self.minimumWidth, preferredWidth or 0);

    local measuredHeight;
    local btnReloadZonesWidth;

    measuredHeight = self.btnReloadZones:getHeight() + self.margin * 2;
    height = math.max(height, measuredHeight);

    btnReloadZonesWidth = getTextManager():MeasureStringX(self.btnReloadZones.font, self.btnReloadZones.title);

    self.btnReloadZones:setX(uiBorderSpacing);
    self.btnReloadZones:setY(uiBorderSpacing);

    self.btnCreateZone:setX((UI_BORDER_SPACING * 4) + btnReloadZonesWidth);
    self.btnCreateZone:setY(uiBorderSpacing);

    self:setWidth(width);
    self:setHeight(height);
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param player IsoPlayer
--- @param zoneController LivestockZonesController
function LivestockZonesListFooter:new(x, y, width, height, player, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    self.player = player;

    o.paddingTop = 2;
    o.paddingBottom = 2;
    o.paddingLeft = 2;
    o.paddingRight = 2;
    o.marginTop = 5;
    o.marginBottom = 5;
    o.marginLeft = 5;
    o.marginRight = 5;
    o.margin = UI_BORDER_SPACING;

    o.minimumHeight = height or 0;
    o.minimumWidth = width or 0;
    o.zoneController = zoneController;

    return o;
end
