---
require "ISUI/ISPanel"
local styles = require "WeeezLivestockZonesExpanded/Defaults/Styles"

--- @class LivestockZonesWindowBody: ISPanel
--- @field private player IsoPlayer
--- @field private zoneController LivestockZonesController
--- @field private rootTable ISTableLayout
--- @field private zoneListColumn LivestockZonesList
--- @field private zoneInfoColumn LivestockZonesInfo
LivestockZonesWindowBody = ISPanel:derive("LivestockZonesWindowBody");

--************************************************************************--
--** LivestockZonesWindowBody:initialise
--**
--************************************************************************--

function LivestockZonesWindowBody:initialise()
    ISPanel.initialise(self);
end

function LivestockZonesWindowBody:createChildren()
    ISPanel.createChildren(self);

    log(DebugType.Zone, "Creating LivestockZonesWindowBody")

    self.rootTable = ISXuiSkin.build(
        self.xuiSkin,
        "S_TableLayout_Main",
        ISTableLayout,
        0,
        0,
        10,
        10,
        nil,
        nil,
        "S_TableLayoutCell_Pad5"
    );
    self.rootTable.drawDebugLines = self.drawDebugLines;
    self.rootTable.drawBorder = false;
    self.rootTable:addRowFill(nil);
    self.rootTable:initialise();
    self.rootTable:instantiate();
    self.rootTable.drawBorder = false;
    self:addChild(self.rootTable);

    self:createZoneListColumn(self.rootTable);
    self:createZoneInfoColumn(self.rootTable);
end

function LivestockZonesWindowBody:createZoneListColumn(parentTable)
    self.zoneListColumn = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesList,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );
    self.zoneListColumn:initialise();
    self.zoneListColumn:instantiate();

    local column = parentTable:addColumnFill(nil);
    parentTable:setElement(column:index(), 0, self.zoneListColumn);
end

function LivestockZonesWindowBody:createZoneInfoColumn(parentTable)
    self.zoneInfoColumn = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        LivestockZonesInfo,
        0,
        0,
        10,
        10,
        self.player,
        self.zoneController
    );

    self.zoneInfoColumn:initialise();
    self.zoneInfoColumn:instantiate();

    local column = parentTable:addColumn(nil);
    parentTable:setElement(column:index(), 0, self.zoneInfoColumn);
end

function LivestockZonesWindowBody:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);

    self.rootTable:setX(0);
    self.rootTable:setY(0);
    self.rootTable:calculateLayout(width, height);

    width = math.max(width, self.rootTable:getWidth());
    height = math.max(height, self.rootTable:getHeight());

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesWindowBody:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesWindowBody:prerender()
    ISPanel.prerender(self);
end

function LivestockZonesWindowBody:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesWindowBody:update()
    ISPanel.update(self);

    if self.updateTimer > 0 then
        self.updateTimer = self.updateTimer - 1;
    end

    if LivestockZonesWindowBody.drawDirty and self.updateTimer == 0 then
        --local previousSelected = self.recipesPanel.recipeListPanel.recipeListPanel.selected;
        LivestockZonesWindowBody.drawDirty = false;
        --self:refreshRecipeList();
        --self.logic:autoPopulateInputs();
        -- change the timer value depending on the list, so it's faster if the list is small
        --if #self.recipesPanel.recipeListPanel.recipeListPanel.items < 100 then
        --    self.updateTimer = 1;
        --else
        --    self.updateTimer = 10;
        --end
        --self.recipesPanel.recipeListPanel.recipeListPanel.selected = previousSelected;
    end
end

function LivestockZonesWindowBody:refreshRecipeList()
    self:updateContainers();

    if self.recipeQuery then
        self.logic:setRecipes(CraftRecipeManager.queryRecipes(self.recipeQuery));
    else
        self.logic:setRecipes(self.craftBench:getRecipes());
    end

    if getDebugOptions():getBoolean("Cheat.Recipe.SeeAll") then
        --self.logic:setRecipes(ScriptManager.instance:getAllCraftRecipes())
    end
end

function LivestockZonesWindowBody:close()
    ISPanel.close(self);

    if self.zoneListColumn then
        self.zoneListColumn:close();
    end

    if self.zoneInfoColumn then
        self.zoneInfoColumn:close();
    end
end

function LivestockZonesWindowBody:new(x, y, width, height, player, zoneController)
    local panel = ISPanel:new(x, y, width, height);
    setmetatable(panel, self)
    self.__index = self

    panel.background = false;

    --panel.logic = HandcraftLogic.new(player, craftBench, isoObject);
    --panel.logic:setManualSelectInputs(true);
    --panel.logic:addEventListener("onUpdateContainers", panel.onUpdateContainers, panel);
    --panel.logic:addEventListener("onRecipeChanged", panel.onRecipeChanged, panel);
    --panel.logic:addEventListener("onSetRecipeList", panel.onSetRecipeList, panel);
    --panel.logic:addEventListener("onUpdateRecipeList", panel.onUpdateRecipeList, panel);
    --panel.logic:addEventListener("onShowManualSelectChanged", panel.onShowManualSelectChanged, panel);
    --panel.logic:addEventListener("onStopCraft", panel.onStopCraft, panel);
    --panel.tooltipLogic = HandcraftLogic.new(player, craftBench, isoObject);
    --panel.margin = 5;
    panel.player = player;
    panel.zoneController = zoneController;

    panel.leftHandedMode = true;
    panel.recipeListMode = true;

    panel.minimumWidth = 0;
    panel.minimumHeight = 0;

    panel.tooltipCounterTime = 0.75;
    panel.tooltipCounter = panel.tooltipCounterTime;
    panel.tooltipRecipe = nil;
    panel.activeTooltip = nil;
    panel.updateTimer = 0; -- just to not update everytime we refresh backpacks, adding bit of a timer as sometimes it can trigger fast

    --local test = getScriptManager():getAllRecipes();
    --log(DebugType.CraftLogic, "Recipe count: "..tostring(test:size()))

    return panel;
end
