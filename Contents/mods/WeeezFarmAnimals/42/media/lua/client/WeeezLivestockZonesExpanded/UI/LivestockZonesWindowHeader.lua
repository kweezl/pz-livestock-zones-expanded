require("ISUI/ISPanel");
local styles = require ("WeeezLivestockZonesExpanded/Defaults/Styles");

--- @class LivestockZonesWindowHeader: ISPanel
LivestockZonesWindowHeader = ISPanel:derive("LivestockZonesWindowHeader");

function LivestockZonesWindowHeader:initialise()
	ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesWindowHeader")
end

function LivestockZonesWindowHeader:createChildren()
    ISPanel.createChildren(self);

    if self.enableIcon then
        --local iconTex = self.entityStyle and self.entityStyle:getIcon();
        self.icon = ISXuiSkin.build(self.xuiSkin, self.styleIcon, ISImage, 0, 0, 32, 32, iconTex);
        --self.icon.scaledWidth = self.iconSize;
        --self.icon.scaledHeight = self.iconSize;
        --self.icon.texture = self.entityStyle:getIcon();
        self.icon:initialise();
        self.icon:instantiate();
        self:addChild(self.icon);

        self.iconSize = self.icon:getHeight();
    else
        self.iconSize = 32;
    end

    local fontHeight = -1; -- <=0 sets label initial height to font
    self.title = ISXuiSkin.build(self.xuiSkin, self.styleLabel, ISLabel, 0, 0, fontHeight, self.titleStr, 1, 1, 1, 1, UIFont.Medium, true);
    --self.title.origTitleStr = titleStr;
    self.title:initialise();
    self.title:instantiate();
    self:addChild(self.title);

    if self.enableInfoButton then --todo: and self.entityStyle and self.entityStyle:getDescription() then
        self.buttonInfo = ISXuiSkin.build(self.xuiSkin, self.styleButton, ISButton, 0, 0, 24, 24, "");
        --self.buttonInfo.image = self.iconInfo;
        self.buttonInfo.target = self;
        self.buttonInfo.onclick = LivestockZonesWindowHeader.onButtonClick;
        self.buttonInfo.enable = true;
        self.buttonInfo:initialise();
        self.buttonInfo:instantiate();
        self:addChild(self.buttonInfo);
    end
end

function LivestockZonesWindowHeader:calculateLayout(_preferredWidth, _preferredHeight)
    local width = math.max(self.minimumWidth, _preferredWidth or 0);
    local height = math.max(self.minimumHeight, _preferredHeight or 0);

    local spacing = 15;

    local requiredWidth = spacing;
    if self.icon then
        requiredWidth = self.icon:getWidth() + spacing;
    end

    requiredWidth = requiredWidth + self.title:getWidth();

    if self.buttonInfo then
        requiredWidth = requiredWidth + spacing + self.buttonInfo:getWidth();
    end

    width = math.max(width, requiredWidth + (self.paddingLeft + self.paddingRight) + (self.marginLeft+self.marginRight));

    if self.icon then
        height = math.max(height, self.icon:getHeight() + (self.paddingTop + self.paddingBottom) + (self.marginTop+self.marginBottom));
    end

    height = math.max(height, self.title:getHeight() + (self.paddingTop + self.paddingBottom) + (self.marginTop+self.marginBottom));

    if self.buttonInfo then
        height = math.max(height, self.buttonInfo:getHeight() + (self.paddingTop + self.paddingBottom) + (self.marginTop+self.marginBottom));
    end

    local x = spacing + self.paddingLeft + self.marginLeft;

    if self.icon then
        self.icon:setX(x);
        self.icon:setY((height/2)-(self.icon:getHeight()/2));

        x = self.icon:getX() + self.icon:getWidth() + spacing;
    end

    self.title:setX(x);
    self.title:setY((height/2) - (self.title:getHeight()/2));

    if self.buttonInfo then
        self.buttonInfo:setX(width - self.buttonInfo:getWidth() - self.paddingRight - self.marginRight - (spacing*0.5));
        self.buttonInfo:setY((height/2)-(self.buttonInfo:getHeight()/2))
    end

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesWindowHeader:onButtonClick(button)
    if button == self.buttonInfo then
        -- default build in info
        if self.infoPopup then
            self:onClickOkInfoPopup();
        else
            self.infoPopup = ISAnimalZoneFirstInfo:new(0,0);
            self.infoPopup:initialise();
            self.infoPopup.okBtn.target = self;
            self.infoPopup.okBtn.onclick = self.onClickOkInfoPopup;
            self.infoPopup:addToUIManager();
        end
    end
end

function LivestockZonesWindowHeader:onClickOkInfoPopup()
    if self.infoPopup then
        self.infoPopup:onClickOk();
        self.infoPopup = nil;
    end
end

function LivestockZonesWindowHeader:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesWindowHeader:prerender()
	if self.background then
		self:drawRectStatic(
            self.marginLeft,
            self.marginTop,
            self.width - self.marginLeft - self.marginRight,
            self.height - self.marginTop - self.marginBottom,
            self.backgroundColor.a,
            self.backgroundColor.r,
            self.backgroundColor.g,
            self.backgroundColor.b
        );
		self:drawRectBorderStatic(
            self.marginLeft,
            self.marginTop,
            self.width - self.marginLeft - self.marginRight,
            self.height - self.marginTop - self.marginBottom,
            self.borderColor.a,
            self.borderColor.r,
            self.borderColor.g,
            self.borderColor.b
        );
	end
end

function LivestockZonesWindowHeader:render()
    ISPanel.render(self);
end

function LivestockZonesWindowHeader:update()
    ISPanel.update(self);
end

function LivestockZonesWindowHeader:close()
    ISPanel.close(self);

    if self.infoPopup then
        self.infoPopup:onClickOk();
    end
end

--- @param x integer
--- @param y integer
--- @param width integer
--- @param height integer
--- @param styleIcon string | nil
--- @param styleLabel string | nil
--- @param styleButton string | nil
function LivestockZonesWindowHeader:new(x, y, width, height, styleIcon, styleLabel, styleButton)
	local style = styles.livestockZonesWindowHeader;
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o.styleIcon = styleIcon or "S_Image_LivestockZonesWindowHeaderIcon";
    o.styleLabel = styleLabel or "S_Label_EntityHeaderTitle";
    o.styleButton = styleButton or "S_Button_EntityHeaderInfo";

    o.paddingTop = style.paddingTop;
    o.paddingBottom = style.paddingBottom;
    o.paddingLeft = style.paddingLeft;
    o.paddingRight = style.paddingRight;
    o.marginTop = style.marginTop;
    o.marginBottom = style.marginBottom;
    o.marginLeft = style.marginLeft;
    o.marginRight = style.marginRight;

    o.titleStr = getText("IGUI_Zone_Name");
    o.enableIcon = style.enableIcon;
    o.enableInfoButton = style.enableInfoButton;

    o.infoPopup = nil;

    return o;
end
