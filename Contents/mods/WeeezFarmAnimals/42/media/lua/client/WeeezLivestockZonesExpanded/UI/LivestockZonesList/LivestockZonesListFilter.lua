require "ISUI/ISPanel"

local FONT_HGT_SEARCH = getTextManager():getFontHeight(UIFont.Medium);
local UI_BORDER_SPACING = 5
local BUTTON_HGT_SEARCH = FONT_HGT_SEARCH + 6

--- @class LivestockZonesListFilter: ISPanel
--- @field private zoneController LivestockZonesController
LivestockZonesListFilter = ISPanel:derive("LivestockZonesListFilter");

function LivestockZonesListFilter:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesListFilter")
end

function LivestockZonesListFilter:createChildren()
    ISPanel.createChildren(self);

    local fontHeight = -1; -- <=0 sets label initial height to font

    self.filterZoneName = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISTextEntryBox,
        "",
        0,
        0,
        10,
        BUTTON_HGT_SEARCH
    );
    self.filterZoneName.font = UIFont.NewSmall;
    self.filterZoneName:initialise();
    self.filterZoneName:instantiate();
    self.filterZoneName.onTextChange = self.onFilterZoneNameChange;
    self.filterZoneName.target = self;
    self.filterZoneName:setClearButton(true);
    self.filterZoneName.javaObject:setCentreVertically(true);
    self.filterZoneName.javaObject:SetText(self.zoneController:getFilterTextDefault());
    --self.filterZoneName:focus();
    self:addChild(self.filterZoneName);

    self.searchHackLabel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISLabel,
        0,
        0,
        fontHeight,
        self.searchInfoText,
        0.3,
        0.3,
        0.3,
        1,
        UIFont.NewSmall,
        true
    )
    --self.searchHackLabel.center = true;
    --self.searchHackLabel.textColor = self.textColor;
    self.searchHackLabel:initialise();
    self.searchHackLabel:instantiate();
    self:addChild(self.searchHackLabel);

    self.filterAnimalGroup = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISComboBox,
        0,
        0,
        10,
        BUTTON_HGT_SEARCH,
        self,
        self.onFilterAnimalGroup
    );
    self.filterAnimalGroup.font = UIFont.NewSmall;
    self.filterAnimalGroup:initialise();
    self.filterAnimalGroup:instantiate();
    self.filterAnimalGroup.target = self;
    self.filterAnimalGroup.onMouseDown = self.OnFilterAnimalGroupChange;
    self.filterAnimalGroup.doRepaintStencil = true
    self:addChild(self.filterAnimalGroup);

    self.btnResetFilter = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISButton,
        0,
        0,
        BUTTON_HGT_SEARCH,
        BUTTON_HGT_SEARCH,
        nil
    );
    self.btnResetFilter.image = getTexture("media/ui/craftingMenus/BuildProperty_Consume.png");
    self.btnResetFilter.target = self;
    self.btnResetFilter.onclick = self.onResetFilters;
    self.btnResetFilter.enable = true;
    self.btnResetFilter:initialise();
    self.btnResetFilter:instantiate();
    self.btnResetFilter:forceImageSize(16, 16);
    self:addChild(self.btnResetFilter);

    self:populateComboList();
end

function LivestockZonesListFilter:populateComboList()
    local textManager = getTextManager();
    local optionsWidth = 50;
    local tooltipMap = {};

    local animalTypes = self.zoneController:getAnimalTypes();
    local defaultAnimalGroup = animalTypes:getDefaultGroup();
    local animalGroups = animalTypes:getGroups(false);
    local filterAnimalGroup = self.zoneController:getFilterAnimalGroup();
    local selectedIndex = 1;
    local option;

    self.filterAnimalGroup:clear();

    option = self.filterAnimalGroup:addOptionWithData(defaultAnimalGroup:getName(), defaultAnimalGroup);

    if defaultAnimalGroup == filterAnimalGroup then
        self.filterAnimalGroup:setSelected(selectedIndex);
    end

    for _, group in pairs(animalGroups) do
        selectedIndex = selectedIndex + 1;
        option =  self.filterAnimalGroup:addOptionWithData(group:getName(), group)
        optionsWidth = math.max(optionsWidth, textManager:MeasureStringX(self.filterAnimalGroup.font, text));
        tooltipMap[text] = text;

        if group == filterAnimalGroup then
            self.filterAnimalGroup:setSelected(selectedIndex);
        end
    end

    --s
    --self.filterAnimalGroup:addOptionWithData(getText("IGUI_FilterType_RecipeName"), "RecipeName")
    --self.filterAnimalGroup:addOptionWithData(getText("IGUI_FilterType_InputName"), "InputName")
    --self.filterAnimalGroup:addOptionWithData(getText("IGUI_FilterType_OutputName"), "OutputName")
    --
    --local tooltipMap = {};
    --tooltipMap[getText("IGUI_FilterType_RecipeName")] = getText("IGUI_FilterType_RecipeNameTooltip");
    --tooltipMap[getText("IGUI_FilterType_InputName")] = getText("IGUI_FilterType_InputNameTooltip");
    --tooltipMap[getText("IGUI_FilterType_OutputName")] = getText("IGUI_FilterType_OutputNameTooltip");

    self.filterAnimalGroup:setToolTipMap(tooltipMap);
    self.filterAnimalGroup:setWidthToOptions(optionsWidth);
end

function LivestockZonesListFilter:onResetFilters()
    self.zoneController:resetFilters();
    self.filterZoneName.javaObject:SetText(self.zoneController:getFilterTextDefault());
    self.filterAnimalGroup:setSelected(1);
end

function LivestockZonesListFilter:onFilterAnimalGroup(box)
    if not box then
        return;
    end

    local group = box.options[box:getSelected()].data;
    self.zoneController:setFilterAnimalGroup(group);
end

function LivestockZonesListFilter.onFilterZoneNameChange(box)
    local text = box:getInternalText() or "";
    ---@type LivestockZonesController
    local zoneController = box.target.zoneController
    zoneController:setFilterText(text);
end

function LivestockZonesListFilter:calculateLayout(preferredWidth, preferredHeight)
    local uiBorderSpacing = UI_BORDER_SPACING + 1;
    local height = math.max(self.minimumHeight, preferredHeight or 0);
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local labelOffset = 10;

    local measuredHeight;
    local measuredWidth;
    local filterAnimalGroupWidth;
    local filterZoneNameWidth;
    local btnResetFilterWidth;
    local y;

    -- combo box height is the same
    measuredHeight = self.filterZoneName:getHeight() + self.margin * 2;
    height = math.max(height, measuredHeight);

    filterAnimalGroupWidth = self.filterAnimalGroup:getWidth();
    filterZoneNameWidth = getTextManager():MeasureStringX(self.searchHackLabel.font, self.searchHackLabel.name) + labelOffset;
    filterZoneNameWidth = math.max(150, filterZoneNameWidth);
    btnResetFilterWidth = self.btnResetFilter:getWidth();

    measuredWidth = (self.margin * 2) + (UI_BORDER_SPACING * 2) + filterZoneNameWidth + filterAnimalGroupWidth + btnResetFilterWidth;
    width = math.max(width, measuredWidth);

    local btnResetFilterX = width - btnResetFilterWidth - UI_BORDER_SPACING;
    local filterAnimalGroupX = btnResetFilterX - filterAnimalGroupWidth - UI_BORDER_SPACING;
    filterZoneNameWidth = math.max(filterZoneNameWidth, filterAnimalGroupX - UI_BORDER_SPACING * 2)

    -- filter combo
    self.filterAnimalGroup:setX(filterAnimalGroupX);
    self.filterAnimalGroup:setY(uiBorderSpacing);

    -- search
    self.filterZoneName:setX(UI_BORDER_SPACING);
    self.filterZoneName:setY(uiBorderSpacing);
    self.filterZoneName:setWidth(filterZoneNameWidth);

    self.searchHackLabel:setX(self.filterZoneName:getX() + 4);
    self.searchHackLabel.originalX = self.searchHackLabel:getX();

    y = self.filterZoneName:getY() + (self.filterZoneName:getHeight() / 2);
    y = y - self.searchHackLabel:getHeight() / 2;
    self.searchHackLabel:setY(y);

    self.btnResetFilter:setX(btnResetFilterX);
    self.btnResetFilter:setY(uiBorderSpacing);

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesListFilter:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesListFilter:prerender()
    ISPanel.prerender(self);

    if self.filterZoneName:isFocused() or (self.filterZoneName:getText() and #self.filterZoneName:getText() > 0) then
        self.searchHackLabel:setVisible(false);
    else
        self.searchHackLabel:setVisible(true);
    end
end

function LivestockZonesListFilter:render()
    ISPanel.render(self);
end

function LivestockZonesListFilter:update()
    ISPanel.update(self);
end


--************************************************************************--
--** LivestockZonesListFilter:new
--**
--************************************************************************--
function LivestockZonesListFilter:new(x, y, width, height, zoneController)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.minimumHeight = height or 0;
    o.minimumWidth = width or 0;
    o.zoneController = zoneController;

    o.backgroundColor = {r=0, g=0, b=0, a=0};

    o.paddingTop = 2;
    o.paddingBottom = 2;
    o.paddingLeft = 2;
    o.paddingRight = 2;
    o.marginTop = 5;
    o.marginBottom = 5;
    o.marginLeft = 5;
    o.marginRight = 5;

    o.margin = UI_BORDER_SPACING;

    o.autoFillContents = false;

    -- these may or may not be used by a parent control while calculating layout:
    o.isAutoFill = false;
    o.isAutoFillX = false;
    o.isAutoFillY = false;

    return o
end
