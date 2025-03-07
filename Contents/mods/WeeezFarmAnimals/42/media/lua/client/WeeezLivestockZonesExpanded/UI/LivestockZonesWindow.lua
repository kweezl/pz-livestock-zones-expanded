require("ISUI/ISCollapsableWindow")
local styles = require ("WeeezLivestockZonesExpanded/Defaults/Styles")

--- @class LivestockZonesWindow : ISCollapsableWindow
--- @field private player IsoPlayer
--- @field private zoneController LivestockZonesController
--- @field private windowHeader LivestockZonesWindowHeader
--- @field private windowBody LivestockZonesWindowBody
LivestockZonesWindow = ISCollapsableWindow:derive("LivestockZonesWindow");

function LivestockZonesWindow:initialise()
    ISCollapsableWindow.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesWindow")

    if self.maximumHeightPercent>0 then
        local maxPercent = math.min(self.maximumHeightPercent, 1);
        self.maximumHeight = getCore():getScreenHeight() * maxPercent;
    end

    self.zoneController:setShowDesignationZones(true);
end

function LivestockZonesWindow:createChildren()
    ISCollapsableWindow.createChildren(self);

    self:createHeader();
    self:createBody();

    if self.pinButton then
        self.pinButton:setAnchorRight(false);
    end

    if self.collapseButton then
        self.collapseButton:setAnchorRight(false);
    end

    -- due to onResize -> calculateLayout anchors causing issues we set custom resize function to widgets.
    self.resizeWidget.resizeFunction = LivestockZonesWindow.calculateLayout;
    self.resizeWidget2.resizeFunction = LivestockZonesWindow.calculateLayout;

    local events = self.zoneController:getEvents();
    events.onLivestockZoneDesignationBegin:addListener(self.onLivestockZoneDesignationBeginListener);
    events.onLivestockZoneDesignationEnd:addListener(self.onLivestockZoneDesignationEndListener);

    self:xuiRecalculateLayout();
end

function LivestockZonesWindow:createHeader()
    self.windowHeader = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesWindowHeader,
        0,
        0,
        10,
        10
    );
    self.windowHeader:initialise();
    self.windowHeader:instantiate();
    self:addChild(self.windowHeader);
end

function LivestockZonesWindow:createBody()
    self.windowBody = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesWindowBody,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );
    self.windowBody:initialise();
    self.windowBody:instantiate();
    self:addChild(self.windowBody);
end

function LivestockZonesWindow:xuiRecalculateLayout(preferredWidth, preferredHeight, force, anchorRight)
    if self.calculateLayout and ((not self.dirtyLayout) or force) then
        self.xuiPreferredResizeWidth = self.width;
        self.xuiPreferredResizeHeight = self.height;
        self.xuiResizeAnchorRight = anchorRight;

        if preferredWidth then
            self.xuiPreferredResizeWidth = preferredWidth < 0 and self.width + preferredWidth or preferredWidth;
        end

        if preferredHeight then
            self.xuiPreferredResizeHeight = preferredHeight < 0 and self.height + preferredHeight or preferredHeight;
        end

        self.dirtyLayout = true;
    end
end

function LivestockZonesWindow:calculateLayout(preferredWidth, preferredHeight)
    self:validateSizeBounds();

    local tbHeight = self:titleBarHeight();
    local rwHeight = self.resizable and self:resizeWidgetHeight() or 0;

    local width = math.max(preferredWidth or 0, self.minimumWidth);
    local height = math.max(preferredHeight or 0, self.minimumHeight);

    -- limit the preferred sizes to maximum bounds (can be overruled by children sizes)
    if self.maximumWidth > 0 then width = math.min(width, self.maximumWidth); end
    if self.maximumHeight > 0 then height = math.min(height, self.maximumHeight); end

    self.windowHeader:calculateLayout(0, 0);
    self.windowBody:calculateLayout(0, 0);

    width = math.max(width, self.windowHeader:getWidth());
    width = math.max(width, self.windowBody:getWidth());

    self.windowHeader:setX(0);
    self.windowHeader:setY(tbHeight);
    self.windowHeader:calculateLayout(width, 0);

    local whHeight = self.windowHeader:getHeight();

    self.windowBody:setX(0);
    self.windowBody:setY(tbHeight + whHeight);
    self.windowBody:calculateLayout(
        width,
        math.max(0, height - tbHeight - rwHeight - whHeight)
    );

    width = math.max(width, self.windowBody:getWidth());
    height = math.max(height, self.windowBody:getHeight() + tbHeight + rwHeight + whHeight);

    self:setWidth(width);
    self:setHeight(height);

    self.dirtyLayout = false;

    if self.pinButton then
        self.pinButton:setX(width - 3 - self.pinButton:getWidth())
    end

    if self.collapseButton then
        self.collapseButton:setX(width - 3 - self.collapseButton:getWidth())
    end
end

function LivestockZonesWindow:prerender()
    self:stayOnSplitScreen();

    if self.dirtyLayout then
        local currentX = self:getX();
        local currenWidth = self:getWidth();

        self:calculateLayout(self.xuiPreferredResizeWidth, self.xuiPreferredResizeHeight);

        if self.xuiResizeAnchorRight then
            self:setX(currentX - (self:getWidth() - currenWidth))
            self.xuiResizeAnchorRight = false;
        end
    end

    ISCollapsableWindow.prerender(self);
end

function LivestockZonesWindow:stayOnSplitScreen()
    ISUIElement.stayOnSplitScreen(self, self.playerNum)
end

function LivestockZonesWindow:render()
    self:stayOnSplitScreen();
    ISCollapsableWindow.render(self);
end

function LivestockZonesWindow:update()
    ISCollapsableWindow.update(self);

    --to prevent occasional double calling of close due to a call in self.update.
    if self.hasClosedWindowInstance then
        return false;
    end

    if not self.player then
        self:close();

        return false;
    end

    return true;
end

function LivestockZonesWindow:close()
    if self.hasClosedWindowInstance then --to prevent occasional double calling of close due to a call in self.update.
        return;
    end

    self.hasClosedWindowInstance = true;

    if self.windowHeader then
        self.windowHeader:close();
    end

    if self.windowBody then
        self.windowBody:close();
    end

    ISCollapsableWindow.close(self);
    ISEntityUI.OnCloseWindow(self);

    if JoypadState.players[self.playerNum+1] then
        if self.unfocusRecursive then
            self:unfocusRecursive(getFocusForPlayer(self.playerNum), self.playerNum);
        elseif getFocusForPlayer(self.playerNum)==self then
            setJoypadFocus(self.playerNum, nil);
        end
    end

    if self.entity then
        self.entity:setUsingPlayer(nil);
    end

    self:removeFromUIManager();
    self.zoneController:setShowDesignationZones(false);
    local events = self.zoneController:getEvents();
    events.onLivestockZoneDesignationBegin:removeListener(self.onLivestockZoneDesignationBeginListener);
    events.onLivestockZoneDesignationEnd:removeListener(self.onLivestockZoneDesignationEndListener);
end

function LivestockZonesWindow:validateSizeBounds()
    if (not self.minimumWidth) or self.minimumWidth < 0 then self.minimumWidth = 0; end
    if (not self.minimumHeight) or self.minimumHeight < 0 then self.minimumHeight = 0; end

    if (not self.maximumWidth) or self.maximumWidth < 0 then self.maximumWidth = 0; end
    if (not self.maximumHeight) or self.maximumHeight < 0 then self.maximumHeight = 0; end

    if self.maximumWidth > 0 and self.maximumWidth < self.minimumWidth then
        self.maximumWidth = self.minimumWidth;
    end

    if self.maximumHeight > 0 and self.maximumHeight < self.minimumHeight then
        self.maximumHeight = self.minimumHeight;
    end
end

function LivestockZonesWindow:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE or getCore():isKey("Livestock Zones UI", key)
end

function LivestockZonesWindow:onKeyRelease(key)
    if not self:isVisible() then
        return;
    end

    if self:isKeyConsumed(key) then
        self:close()
        self:removeFromUIManager();
    end
end

function LivestockZonesWindow:onLivestockZoneDesignationBegin()
    self:setVisible(false);
end

function LivestockZonesWindow:onLivestockZoneDesignationEnd()
    self:setVisible(true);
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param player IsoPlayer
--- @param zoneController LivestockZonesController
function LivestockZonesWindow:new(x, y, width, height, player, zoneController)
    local style = styles.livestockZonesWindow;
    local o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, { __index = self })
    --self.__index = self

    o.x = x;
    o.y = y;
    o.player = player;
    o.zoneController = zoneController;
    o.playerNum = player:getPlayerNum();
    o.borderColor = style.borderColor;
    o.backgroundColor = style.backgroundColor;
    o.width = math.max(width, style.minimumWidth);
    o.height = math.max(height, style.minimumHeight);

    o.anchorLeft = style.anchorLeft;
    o.anchorRight = style.anchorRight;
    o.anchorTop = style.anchorTop;
    o.anchorBottom = style.anchorBottom;
    o.pin = style.pin;
    o.isCollapsed = style.isCollapsed;
    o.drawFrame = style.drawFrame;

    o.isCollapsed = false;
    o.collapseCounter = 0;
    o.title = nil;

    o.resizable = style.resizeable;
    o.enableHeader = style.enableHeader;

    o.minimumWidth = style.minimumWidth;
    o.minimumHeight = style.minimumHeight;

    o.maximumWidth = style.maximumWidth;
    o.maximumHeight =  style.maximumHeight;

    o.maximumHeightPercent = style.maximumHeightPercent;

    o.overrideBPrompt = true;
    o:setWantKeyEvents(true);

    o.onLivestockZoneDesignationBeginListener = function()
        o:onLivestockZoneDesignationBegin();
    end

    o.onLivestockZoneDesignationEndListener = function()
        o:onLivestockZoneDesignationEnd();
    end

    return o
end
