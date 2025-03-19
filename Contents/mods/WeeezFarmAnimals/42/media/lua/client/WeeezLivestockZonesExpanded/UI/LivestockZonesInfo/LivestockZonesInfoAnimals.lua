require("ISUI/ISPanel");

local moodleOrder = require("WeeezLivestockZonesExpanded/Defaults/Config").moodleOrder;
local animalMoodle = require("WeeezLivestockZonesExpanded/Module/LivestockZonesExpanded").getAnimalMoodle();

local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19;
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MIN_LIST_BOX_WIDTH = 125 * FONT_SCALE;

local ANIMAL_TEXTURE_SIZE = 32;
local ICON_SIZE = 16;

local iconPadding = 10;
local iconSize = 32;
local titleX = iconSize + iconPadding * 2;
local moodleOffsetY = 32;
local moodleTextureWH = 20;

--- @class LivestockZonesInfoAnimals: ISPanel
--- @field private animalsProvider LivestockZonesAnimals
--- @field private livestockZone LivestockZone
--- @field private animalList ISScrollingListBox
LivestockZonesInfoAnimals = ISPanel:derive("LivestockZonesInfoAnimals");

function LivestockZonesInfoAnimals:initialise()
    ISPanel.initialise(self);

    log(DebugType.Zone, "Creating LivestockZonesInfoAnimals");
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
    self.animalList.onItemMouseHover = function(list, item)
        self:onItemMouseHover(list, item)
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

--- @param animal LivestockZonesAnimal
function LivestockZonesInfoAnimals:setAnimalSelected(animal)
    local items = self.animalList.items;

    for i = 1, #items do
        local itemAnimal = items[i].item.animal;
        if itemAnimal:getId() == animal:getId() then
            self.previousSelected = i;
            self.animalList.selected = i;
            self.animalList:ensureVisible(i);
        end
    end
end

function LivestockZonesInfoAnimals:populateAnimalList()
    local animals = self.animalsProvider:getAllForZone(self.livestockZone);

    for i = 0, animals:size() - 1 do
        --- @type LivestockZonesAnimal
        local animal = animals:get(i);
        self.animalList:addItem(animal:getName(), {
            animal = animal,
            moodleList = nil,
        });
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
    local itemData = item.item;
    --- @type LivestockZonesAnimal
    local animal = itemData.animal;

    list:drawRectBorder(0, (y), list:getWidth(), item.height, 0.5, list.borderColor.r, list.borderColor.g, list.borderColor.b);
    local itemPadY = 10;

    -- animal texture
    list:drawTextureScaledAspect2(animal:getTexture(), iconPadding, y + (itemHeight - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1);

    -- animal info
    -- scroll bar width 17
    local iconBorderX = width - itemPadY - 20 - 17;
    local iconBorderY = y + itemPadY;

    -- animal info icon
    if animal:isOutsideHutch() then
        list:drawRectBorder(iconBorderX, iconBorderY, 20, 20, self.infoBorderColor.a, self.infoBorderColor.r, self.infoBorderColor.g, self.infoBorderColor.b);
        list:drawTextureScaledAspect2(self.infoTexture, iconBorderX + 2, iconBorderY + 2, 16, 16, 1, 1, 1, 1);
        iconBorderX = iconBorderX - 25;
    end

    -- animal pet action icon
    if animal:isCanBePet() and animal:isOutsideHutch() then
        list:drawRectBorder(iconBorderX, iconBorderY, 20, 20, self.infoBorderColor.a, self.infoBorderColor.r, self.infoBorderColor.g, self.infoBorderColor.b);
        list:drawTextureScaledAspect2(self.petTexture, iconBorderX + 2, iconBorderY + 2, 16, 16, 1, 1, 1, 1);
    end

    -- animal name
    list:drawText(animal:getName(), iconSize + iconPadding * 2, (y) + itemPadY, 0.9, 0.9, 0.9, 0.9, list.font);

    local itemMoodleOffsetY =  y + moodleOffsetY;
    local moodleOffsetX = titleX;

    itemData.moodleList = animalMoodle:getMoodleList(animal:getIsoAnimal(), itemData.moodleList);
    itemData.moodleIndex = {};
    local moodleIndex = itemData.moodleIndex;

    local moodleListItems = itemData.moodleList.list;
    local i = 1;

    for _, moodleType in pairs(moodleOrder) do
        local moodle = moodleListItems[moodleType];

        if moodle then
            local color = moodle.color;
            list:drawRectBorder(moodleOffsetX, itemMoodleOffsetY, moodleTextureWH, moodleTextureWH, color:getA(), color:getR(), color:getG(), color:getB());
            list:drawTextureScaled(moodle.texture, moodleOffsetX, itemMoodleOffsetY, moodleTextureWH, moodleTextureWH, color:getA(), color:getR(), color:getG(), color:getB());
            moodleOffsetX = moodleOffsetX + moodleTextureWH + 5;
            moodleIndex[i] = moodleType;
            i = i + 1;
        end
    end

    return y + item.height;
end

--- @param item LivestockZonesAnimal | nil
function LivestockZonesInfoAnimals:onItemMouseHover(list, item)
    if not item then
        return;
    end

    item.tooltip = nil;
    local itemData = item.item;
    local moodleIndex = itemData.moodleIndex;
    local moodleIndexTotal = #moodleIndex;

    if moodleIndexTotal <= 0 then
        return;
    end

    local mouseX = list:getMouseX();
    local mouseY = list:getMouseY() - (self.animalList.itemheight * (item.index - 1));

    if mouseX >= titleX and mouseY >= moodleOffsetY and  mouseY <= moodleOffsetY + moodleTextureWH then
        local moodleIndexVal = math.floor((mouseX - titleX) / (moodleTextureWH + 5)) + 1;
        local moodleType = moodleIndex[moodleIndexVal];

        if not moodleType then
            return;
        end

        local moodle = itemData.moodleList.list[moodleType];

        if moodle then
            item.tooltip = moodle.tooltip;
        end
    end
end

--- @param item LivestockZonesAnimal | nil
function LivestockZonesInfoAnimals:onMouseDownAnimalListItem(item)
    if not item then
        return;
    end

    local animal = item.animal;
    local isoAnimal = animal:getIsoAnimal();
    -- icon width with border 20
    -- icon pad right 10 + 17 scrollbar
    local width = self:getWidth() - 47;
    --- icon height with border 20
    --- icon pad top 10
    local height = 10 + self.animalList.itemheight * (self.animalList.selected - 1);
    local inputX = self.animalListItemX;
    local inputY = self.animalListItemY;

    local hitX = width <= inputX and width + 20 >= inputX;
    local hitY = height <= inputY and height + 20 >= inputY;

    if hitX and hitY then
        if self.previousSelected ~= self.animalList.selected then
            self.previousSelected = self.animalList.selected;
            self:triggerOnAnimalSelected(animal);
        end

        -- open info window
        -- todo: create better info info window and trace duplicates
        if luautils.walkAdj(self.player, isoAnimal:getSquare()) then
            ISTimedActionQueue.add(ISOpenAnimalInfo:new(self.player, isoAnimal, self))
        end

        return;
    end

    -- hit pet icon
    width = width - 25;
    hitX = width <= inputX and width + 20 >= inputX;

    if hitX and hitY then
        if self.previousSelected ~= self.animalList.selected then
            self.previousSelected = self.animalList.selected;
            self:triggerOnAnimalSelected(animal);
        end

        self.previousSelected = self.animalList.selected;
        -- begin pet timed action
        AnimalContextMenu.onPetAnimal(isoAnimal, self.player);

        return;
    end

    if self.previousSelected == self.animalList.selected then
        self.animalList.selected = -1;
        self.previousSelected = -1;
        self:triggerOnAnimalSelected(nil);
    else
        self.previousSelected = self.animalList.selected;
        self:triggerOnAnimalSelected(animal);
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

--- @param target table
--- @param fn function
function LivestockZonesInfoAnimals:setOnAnimalSelected(target, fn)
    self.onAnimalSelectedTarget = target;
    self.onAnimalSelectedFn = fn;
end

--- @param animal LivestockZonesAnimal | nil
function LivestockZonesInfoAnimals:triggerOnAnimalSelected(animal)
    if self.onAnimalSelectedFn and self.onAnimalSelectedTarget then
        self.onAnimalSelectedFn(self.onAnimalSelectedTarget, animal)
    end
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
    o.previousSelected = -1;
    o.minimumWidth = 280;
    o.minimumHeight = 0;
    o.background = false;

    o.onAnimalSelectedTarget = nil;
    o.onAnimalSelectedFn = nil;

    -- todo: move to config
    o.infoTexture = getTexture("media/ui/Entity/blueprint_info.png");
    -- todo: need new pet icon
    o.petTexture = getTexture("media/ui/Entity/Icon_Crafted_48x48.png");
    o.infoBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 1.0 };

    return o;
end
