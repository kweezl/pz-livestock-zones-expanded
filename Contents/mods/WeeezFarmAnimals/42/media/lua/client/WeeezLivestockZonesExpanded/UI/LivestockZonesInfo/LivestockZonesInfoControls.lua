require "ISUI/ISPanel"

local FONT_HGT_SEARCH = getTextManager():getFontHeight(UIFont.Medium);
local BUTTON_HGT_SEARCH = FONT_HGT_SEARCH + 6;

--- @class LivestockZonesInfoControls: ISPanel
--- @field private zoneController LivestockZonesController
LivestockZonesInfoControls = ISPanel:derive("LivestockZonesInfoControls");

function LivestockZonesInfoControls:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfoControls")
end

function LivestockZonesInfoControls:createChildren()
    ISPanel.createChildren(self);

    self.btnRenameZone = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        getText("ContextMenu_RenameBag"),
        self,
        self.onRenameZoneClick
    );
    self.btnRenameZone.enable = true;
    self.btnRenameZone:initialise();
    self.btnRenameZone:instantiate();
    self:addChild(self.btnRenameZone);

    self.btnChangeZoneIcon = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        getText("IGUI_DesignationZone_Change_Icon"),
        self,
        self.onChangeZoneIconClick
    );
    self.btnChangeZoneIcon.enable = true;
    self.btnChangeZoneIcon:initialise();
    self.btnChangeZoneIcon:instantiate();
    self:addChild(self.btnChangeZoneIcon);

    self.btnRemoveZone = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        getText("ContextMenu_Remove"),
        self,
        self.onRemoveZoneClick
    );
    self.btnRemoveZone.enable = true;
    self.btnRemoveZone:initialise();
    self.btnRemoveZone:instantiate();
    self:addChild(self.btnRemoveZone);
end

function LivestockZonesInfoControls:onRenameZoneClick()
    if (self.onClickRenameZoneTarget and self.onClickRenameZoneFn) then
        self.onClickRenameZoneFn(self.onClickRenameZoneTarget);
    end
end

function LivestockZonesInfoControls:onChangeZoneIconClick()
    if (self.onClickChangeZoneIconTarget and self.onClickChangeZoneIconFn) then
        self.onClickChangeZoneIconFn(self.onClickChangeZoneIconTarget);
    end
end

function LivestockZonesInfoControls:onRemoveZoneClick()
    if (self.onClickRemoveZoneTarget and self.onClickRemoveZoneFn) then
        self.onClickRemoveZoneFn(self.onClickRemoveZoneTarget);
    end
end

function LivestockZonesInfoControls:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesInfoControls:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfoControls:update()
    ISPanel.update(self);
end

function LivestockZonesInfoControls:close()
    print("LivestockZonesInfoControls:close")
    ISPanel.close(self);
end

function LivestockZonesInfoControls:calculateLayout(preferredWidth, preferredHeight)
    local height = math.max(self.minimumHeight, preferredHeight or 0);
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local measuredHeight = 10 + self.btnRenameZone:getHeight();
    height = math.max(height, measuredHeight);

    self.btnRenameZone:setX(5);
    self.btnRenameZone:setY(5);

    self.btnChangeZoneIcon:setX(10 + self.btnRenameZone:getWidth());
    self.btnChangeZoneIcon:setY(5);

    self.btnRemoveZone:setX(width - 5 - self.btnRemoveZone:getWidth());
    self.btnRemoveZone:setY(5);

    self:setWidth(width);
    self:setHeight(height);
end

--- @param target table
--- @param fn function
function LivestockZonesInfoControls:setOnClickRenameZone(target, fn)
    self.onClickRenameZoneTarget = target;
    self.onClickRenameZoneFn = fn;
end

--- @param target table
--- @param fn function
function LivestockZonesInfoControls:setOnClickChangeZoneIcon(target, fn)
    self.onClickChangeZoneIconTarget = target;
    self.onClickChangeZoneIconFn = fn;
end

--- @param target table
--- @param fn function
function LivestockZonesInfoControls:setOnClickRemoveZone(target, fn)
    self.onClickRemoveZoneTarget = target;
    self.onClickRemoveZoneFn = fn;
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param player IsoPlayer
--- @param zoneController LivestockZonesController
function LivestockZonesInfoControls:new(x, y, width, height, player, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    self.player = player;

    o.minimumHeight = 0;
    o.minimumWidth = 0;
    o.zoneController = zoneController;
    o.livestockZone = zoneController:getActiveOrFirstZone();

    o.onClickRenameZoneTarget = nil;
    o.onClickRenameZoneFn = nil;

    o.onClickChangeZoneIconTarget = nil;
    o.onClickChangeZoneIconFn = nil;

    o.onClickRemoveZoneTarget = nil;
    o.onClickRemoveZoneFn = nil;

    return o;
end
