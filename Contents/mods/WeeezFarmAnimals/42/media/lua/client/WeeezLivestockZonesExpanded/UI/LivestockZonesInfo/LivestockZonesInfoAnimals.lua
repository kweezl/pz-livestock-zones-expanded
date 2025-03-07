require("ISUI/ISPanel");

local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local styles = require("WeeezLivestockZonesExpanded/Defaults/Styles");

local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19;
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MIN_LIST_BOX_WIDTH = 125 * FONT_SCALE;

local ANIMAL_TEXTURE_SIZE = 32;
local ICON_SIZE = 16;

--- @class LivestockZonesInfoAnimals: ISPanel
--- @field private animalsProvider LivestockZonesAnimals
--- @field private livestockZone LivestockZone
--- @field private animalList ISScrollingListBox
LivestockZonesInfoAnimals = ISPanel:derive("LivestockZonesInfoAnimals");

function LivestockZonesInfoAnimals:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfoAnimals")
end

function LivestockZonesInfoAnimals:createChildren()
    ISPanel.createChildren(self);

    self.animalList = ISScrollingListBox:new(0, 0, MIN_LIST_BOX_WIDTH, 100);
    self.animalList:initialise();
    self.animalList:instantiate();
    self.animalList.itemheight = math.max(
        ANIMAL_TEXTURE_SIZE + 5,
        16 + FONT_HGT_SMALL + 10 + ICON_SIZE
    );
    self.animalList.selected = 0;
    self.animalList.font = UIFont.Small;
    self.animalList.doDrawItem = function (animalList, y, item, alt)
        return self:drawAnimalItem(animalList, y, item, alt)
    end
    self.animalList.drawBorder = true;
    self.animalList.background = false;
    self.animalList.drawDebugLines = self.drawDebugLines;
    self:addChild(self.animalList);
    self.animalList:setOnMouseDownFunction(self, self.onMouseDownAnimalListItem);

    self.animalListItemX = 0;
    self.animalListItemY = 0;
    self.animalList.onMouseDown = function(list, x, y)
        self.animalListItemX = x;
        self.animalListItemY = y;
        ISScrollingListBox.onMouseDown(list, x, y);
    end

    self:populateAnimalList();
end

function LivestockZonesInfoAnimals:populateAnimalList()
    local animals = self.animalsProvider:getAllForZone(self.livestockZone);

    for i = 0, animals:size() - 1 do
        --- @type LivestockZonesAnimal
        local animal = animals:get(i);
        self.animalList:addItem(animal:getName(), animal);
    end
end

function LivestockZonesInfoAnimals:drawAnimalItem(list, y, item)
    local yScroll = list:getYScroll();
    local height = list:getHeight();
    local itemHeight = list.itemheight;

    if y + yScroll + itemHeight < 0 or y + yScroll >= height then
        return y + itemHeight;
    end

    if list.selected == item.index then
        list:drawRect(0, (y), list:getWidth(), item.height-1, 0.3, 0.7, 0.35, 0.15);
    end

    local width = list:getWidth();
    local iconPadding = 10;
    local iconSize = 32;
    --- @type LivestockZonesAnimal
    local animal = item.item;

    list:drawRectBorder(0, (y), list:getWidth(), item.height, 0.5, list.borderColor.r, list.borderColor.g, list.borderColor.b);
    local itemPadY = 10;

    -- animal texture
    list:drawTextureScaledAspect2(animal:getTexture(), iconPadding, y + (itemHeight - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1);

    -- animal info
    -- scroll bar width 17
    local iconBorderX = width - itemPadY - 20 - 17;
    local iconBorderY = y + itemPadY;
    list:drawRectBorder(iconBorderX, iconBorderY, 20, 20, self.infoBorderColor.a, self.infoBorderColor.r, self.infoBorderColor.g, self.infoBorderColor.b);
    list:drawTextureScaledAspect2(self.infoTexture, iconBorderX + 2, iconBorderY + 2, 16, 16, 1, 1, 1, 1);

    -- animal pet action icon
    if animal:isCanBePet() and animal:isOutsideHutch() then
        list:drawRectBorder(iconBorderX - 25, iconBorderY, 20, 20, self.infoBorderColor.a, self.infoBorderColor.r, self.infoBorderColor.g, self.infoBorderColor.b);
        list:drawTextureScaledAspect2(self.petTexture, iconBorderX - 23, iconBorderY + 2, 16, 16, 1, 1, 1, 1);
    end

    -- animal name
    list:drawText(animal:getName(), iconSize + iconPadding * 2, (y) + itemPadY, 0.9, 0.9, 0.9, 0.9, list.font);

    return y + item.height;
end

--- @param item LivestockZonesAnimal | nil
function LivestockZonesInfoAnimals:onMouseDownAnimalListItem(item)
    if not item then
        return;
    end

    local animal = item:getIsoAnimal();
    -- icon width with border 20
    -- icon pad right 10 + 17 scrollbar
    local width = self:getWidth() - 47;
    --- icon height with border 20
    --- icon pad top 10
    local height = 10 + self.animalList.itemheight * (self.animalList.selected - 1);

    local hitX = width <= self.animalListItemX and width + 20 >= self.animalListItemX;
    local hitY = height <= self.animalListItemY and height + 20 >= self.animalListItemY;

    if hitX and hitY then
        -- open info window
        -- todo: create better info info window and trace duplicates
        if luautils.walkAdj(self.player, animal:getSquare()) then
            ISTimedActionQueue.add(ISOpenAnimalInfo:new(self.player, animal, self))
        end

        return;
    end

    -- hit pet icon
    width = width - 25;
    hitX = width <= self.animalListItemX and width + 20 >= self.animalListItemX;

    if hitX and hitY then
        -- begin pet timed action
        AnimalContextMenu.onPetAnimal(animal, self.player);
    end
end

function LivestockZonesInfoAnimals:calculateLayout(preferredWidth, preferredHeight)
    local width = math.max(0, self.minimumWidth, preferredWidth);
    --local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);

    if self.animalList then
        self.animalList:setWidth(width);
        self.animalList:setHeight(height);
    end

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesInfoAnimals:prerender()
    ISPanel.prerender(self);

    if self.animalList and self.animalList.vscroll then
        self.animalList.vscroll:setHeight(self.animalList:getHeight());
        self.animalList.vscroll:setX(self.animalList:getWidth() - self.animalList.vscroll:getWidth());
    end
end

function LivestockZonesInfoAnimals:render()
    ISPanel.render(self);

    if ISEntityUI.drawDebugLines or self.drawDebugLines then
        self:drawRectBorderStatic(0, 0, self.width, self.height, 1.0, 0, 1, 0);
    end
end

function LivestockZonesInfoAnimals:update()
    ISPanel.update(self);
end

function LivestockZonesInfoAnimals:close()
    ISPanel.close(self);
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param animalsProvider LivestockZonesAnimals
--- @param livestockZone LivestockZone
function LivestockZonesInfoAnimals:new(x, y, width, height, player, animalsProvider, livestockZone)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;

    o.player = player;
    o.animalsProvider = animalsProvider;
    o.livestockZone = livestockZone;
    o.minimumWidth = 280;
    o.minimumHeight = 0;
    o.background = false;

    -- todo: move to config
    o.infoTexture = getTexture("media/ui/Entity/blueprint_info.png");
    -- todo: need new pet icon
    o.petTexture = getTexture("media/ui/Entity/Icon_Crafted_48x48.png");
    o.infoBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 };

    return o;
end
