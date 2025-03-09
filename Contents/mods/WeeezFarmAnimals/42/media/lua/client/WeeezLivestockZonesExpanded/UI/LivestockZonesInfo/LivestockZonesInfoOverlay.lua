require("ISUI/ISPanel");

--- @class LivestockZonesInfoOverlay
--- @field private zoneIcons LivestockZonesIcons
--- @field private livestockZone LivestockZone
LivestockZonesInfoOverlay = ISPanel:derive("LivestockZonesInfoOverlay");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewSmall)
local FONT_HGT_MED = getTextManager():getFontHeight(UIFont.NewMedium)
local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 19; -- normalize to 1080p
local ICON_SIZE = 48 * math.max(1, FONT_SCALE);

LivestockZonesInfoOverlay.modeNameChange = 0;
LivestockZonesInfoOverlay.modeIconChange = 1;
LivestockZonesInfoOverlay.modePetAnimals = 2;
--- reserved
LivestockZonesInfoOverlay.modeRemove = 100;

function LivestockZonesInfoOverlay:initialise()
    ISPanel.initialise(self);
end

function LivestockZonesInfoOverlay:createChildren()
    ISPanel.createChildren(self);

    local title = self.livestockZone:getName();
    local oneSymbolWidth = getTextManager():MeasureStringX(UIFont.NewMedium, "#");

    self.entryBox = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISTextEntryBox,
        title,
        0,
        0,
        oneSymbolWidth * 30,
        FONT_HGT_MED + 10
    );
    self.entryBox.font = UIFont.NewMedium;
    self.entryBox:initialise();
    self.entryBox:instantiate();
    self.entryBox.javaObject:setCentreVertically(true);
    self:addChild(self.entryBox);
    self.entryBox:setVisible(false);

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
    self.icon:setVisible(false);

    self.iconList = ISScrollingListBox:new(0, 0, 200, 50)
    self.iconList:initialise();
    self.iconList:setFont(UIFont.Small, 2)
    self.iconList.itemheight = FONT_HGT_SMALL + 10
    self.iconList.selected = 0
    self.iconList.onmousedown = self.onIconSelected
    self.iconList.target = self
    self.iconList.doDrawItem = function(list, y, item, alt)
        return self:doDrawIconItem(list, y, item, alt)
    end
    self:addChild(self.iconList);
    self.iconList:setVisible(false);

    self.btnConfirm = ISButton:new(0, 0, 100, 30, getText("UI_Ok"), self, self.onClickConfirm, nil, false);
    self.btnConfirm.internal = "OK";
    self.btnConfirm:initialise();
    self.btnConfirm:instantiate();
    self.btnConfirm:enableAcceptColor();
    self:addChild(self.btnConfirm);

    self.btnCancel = ISButton:new(120, 0, 100, 30, getText("UI_Cancel"), self, self.onClickCancel, nil, false);
    self.btnCancel.internal = "CANCEL";
    self.btnCancel:initialise();
    self.btnCancel:instantiate();
    self.btnCancel:enableCancelColor();
    self:addChild(self.btnCancel);

    --getText("IGUI_Designation_RemoveConfirm", self.livestockZone:getName())
    self.removeLabel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISLabel,
        30,
        0,
        FONT_HGT_MED,
        "",
        1,
        1,
        1,
        1,
        UIFont.NewMedium,
        true
    );
    self.removeLabel:initialise();
    self.removeLabel:instantiate();
    self.removeLabel:setHeightToName(0);
    self:addChild(self.removeLabel);

    self.petAnimalsLabel = ISXuiSkin.build(
        self.xuiSkin,
        "S_NeedsAStyle",
        ISLabel,
        0,
        0,
        FONT_HGT_MED,
        "",
        1,
        1,
        1,
        1,
        UIFont.NewMedium,
        true
    );
    self.petAnimalsLabel:initialise();
    self.petAnimalsLabel:instantiate();
    self.petAnimalsLabel:setHeightToName(0);
    self:addChild(self.petAnimalsLabel);
end

function LivestockZonesInfoOverlay:calculateLayout(preferredWidth, preferredHeight, titleX, titleY, iconX, iconY)
    local width = math.max(self.minimumWidth, preferredWidth or 0);
    local height = math.max(self.minimumHeight, preferredHeight or 0);
    local middleX = width / 2;

    if self.entryBox then
        self.entryBox:setX(titleX - 2);
        self.entryBox:setY(titleY - 5);
    end

    local btnConfirmVisible = false;
    if self.btnConfirm then
        local btnConfirmX = middleX - self.btnConfirm:getWidth() - 15;
        self.btnConfirm:setX(btnConfirmX);
        self.btnConfirm:setY(height - self.btnConfirm:getHeight() - 5);
        btnConfirmVisible = self.btnConfirm:getIsVisible();
    end

    if self.btnCancel then
        local btnCancelX;

        if btnConfirmVisible then
            btnCancelX = middleX + 15;
        else
            btnCancelX = middleX - self.btnCancel:getWidth() / 2;
        end

        self.btnCancel:setX(btnCancelX);
        self.btnCancel:setY(height - self.btnCancel:getHeight() - 5);
    end

    local iconPad = 0;
    if self.icon then
        self.icon:setX(iconX);
        self.icon:setY(iconY);
        iconPad = iconX + self.icon:getWidth() + 30;
    end

    if self.iconList then
        self.iconList:setX(iconPad);
        self.iconList:setY(5);
        self.iconList:setWidth(300);
        self.iconList:setHeight(self.iconList.itemheight * 2 + 10);

        self.iconList.vscroll:setHeight(self.iconList:getHeight());
        self.iconList.vscroll:setX(self.iconList:getWidth() - self.iconList.vscroll:getWidth());
    end

    if self.removeLabel then
        self.removeLabel:setX(30);
        self.removeLabel:setY(titleY);
    end

    if self.petAnimalsLabel then
        self.petAnimalsLabel.originalX = titleX;
        self.petAnimalsLabel:setX(titleX);
        self.petAnimalsLabel:setY(titleY);
    end

    self:setWidth(width);
    self:setHeight(height);
end

function LivestockZonesInfoOverlay:onResize()
    ISUIElement.onResize(self)
end

function LivestockZonesInfoOverlay:prerender()
    ISPanel.prerender(self);
end

function LivestockZonesInfoOverlay:render()
    ISPanel.render(self);
end

function LivestockZonesInfoOverlay:update()
    ISPanel.update(self);
end

function LivestockZonesInfoOverlay:doDrawIconItem(list, y, item)
    local yScroll = list:getYScroll();
    local height = list:getHeight();
    local itemHeight = list.itemheight;

    -- Check if the item is within the visible area
    if y + yScroll + itemHeight < 0 or y + yScroll >= height then
        return y + itemHeight;
    end

    local width = list:getWidth()
    local iconSize = FONT_HGT_SMALL + 5
    local iconPadding = 5;
    local data = item.item;

    -- Draw main background
    list:drawRectBorder(0, y, width, itemHeight, list.borderColor.a, list.borderColor.r, list.borderColor.g, list.borderColor.b)

    -- Draw alternating colors
    if list.selected == item.index then
        list:drawRect(0, y, width, itemHeight, 0.3, 0.7, 0.35, 0.15);
    end

    -- Draw item icon
    local texture = getTexture(data.icon);
    if texture then
        list:drawTextureScaledAspect2(texture, iconPadding, y + (itemHeight - iconSize) / 2, iconSize, iconSize, 1, 1, 1, 1);
    end

    -- Draw item name
    list:drawText(data.title, iconSize + (iconPadding * 3), y + 4, 1, 1, 1, 1, list.font);

    return y + itemHeight;
end

--- @param livestockZone LivestockZone
function LivestockZonesInfoOverlay:setLivestockZone(livestockZone)
    self.entryBox:setText(livestockZone:getName());
end

function LivestockZonesInfoOverlay:onClickConfirm()
    -- todo: clean
    if self.overlayMode == self.modeRemove then
        if self.onClickRemoveTarget and self.onClickRemoveFn then
            self.onClickRemoveFn(self.onClickRemoveTarget, true)
        end
        return;
    end

    if self.overlayMode == self.modeIconChange then
        if self.onClickChangeIconTarget and self.onClickChangeIconFn then
            local icon = self.iconList.items[self.iconList.selected].item.icon;
            self.onClickChangeIconFn(self.onClickChangeIconTarget, true, icon)
        end
        return;
    end

    if self.onClickRenameTarget and self.onClickRenameFn then
        self.onClickRenameFn(self.onClickRenameTarget, true, self.entryBox:getText())
    end
end

function LivestockZonesInfoOverlay:onClickCancel()
    -- todo: clean
    if self.overlayMode == self.modeRemove then
        if self.onClickRemoveTarget and self.onClickRemoveFn then
            self.onClickRemoveFn(self.onClickRemoveTarget, false)
        end
        return;
    end

    if self.overlayMode == self.modeIconChange then
        if self.onClickChangeIconTarget and self.onClickChangeIconFn then
            self.onClickChangeIconFn(self.onClickChangeIconTarget, false, nil)
        end
        return;
    end

    if self.overlayMode == self.modeNameChange then
        if self.onClickRenameTarget and self.onClickRenameFn then
            self.onClickRenameFn(self.onClickRenameTarget, false, nil)
        end
    end

    if self.overlayMode == self.modePetAnimals then
        if self.onClickRenameTarget and self.onClickRenameFn then
            self.onClickCancelPetAnimalsFn(self.onClickCancelPetAnimalsTarget)
        end
    end
end

--- @param target table
--- @param fn function
function LivestockZonesInfoOverlay:setOnRename(target, fn)
    self.onClickRenameTarget = target;
    self.onClickRenameFn = fn;
end

--- @param target table
--- @param fn function
function LivestockZonesInfoOverlay:setOnChangeIcon(target, fn)
    self.onClickChangeIconTarget = target;
    self.onClickChangeIconFn = fn;
end

--- @param target table
--- @param fn function
function LivestockZonesInfoOverlay:setOnRemove(target, fn)
    self.onClickRemoveTarget = target;
    self.onClickRemoveFn = fn;
end

--- @param target table
--- @param fn function
function LivestockZonesInfoOverlay:setOnCancelPetAnimals(target, fn)
    self.onClickCancelPetAnimalsTarget = target;
    self.onClickCancelPetAnimalsFn = fn;
end

function LivestockZonesInfoOverlay:activate(mode)
    self.overlayMode = mode;

    -- todo: clean
    if mode == self.modeRemove then
        self.icon:setVisible(false);
        self.iconList:setVisible(false);
        self.entryBox:setVisible(false);
        self.petAnimalsLabel:setVisible(false);

        self.btnConfirm:setVisible(true);
        self.btnCancel:setVisible(true);
        self.btnCancel:setX(self:getWidth() / 2 + 15);
        local removeLabelText = getTextManager():WrapText(
            self.removeLabel.font,
            getText("IGUI_Designation_RemoveConfirm", self.livestockZone:getName()),
            self:getWidth() - 30 * 2
        );
        self.removeLabel:setName(removeLabelText);
        self.removeLabel:setVisible(true);
        self:setVisible(true);

        return;
    end

    if mode == self.modeIconChange then
        self.entryBox:setVisible(false);
        self.removeLabel:setVisible(false);
        self.petAnimalsLabel:setVisible(false);

        self.btnConfirm:setVisible(true);
        self.btnCancel:setVisible(true);
        self.btnCancel:setX(self:getWidth() / 2 + 15);
        self.icon.texture = self.livestockZone:getIconTexture();
        self.icon:setVisible(true);
        self.iconList:setVisible(true);
        self:setVisible(true);
        self:populateIconList();

        return;
    end

    if mode == self.modeNameChange then
        self.icon:setVisible(false);
        self.iconList:setVisible(false);
        self.removeLabel:setVisible(false);
        self.petAnimalsLabel:setVisible(false);

        self.btnConfirm:setVisible(true);
        self.btnCancel:setVisible(true);
        self.btnCancel:setX(self:getWidth() / 2 + 15);
        self.entryBox:setText(self.livestockZone:getName());
        self.entryBox:setVisible(true);
        self:setVisible(true);

        return;
    end

    if mode == self.modePetAnimals then
        self.iconList:setVisible(false);
        self.removeLabel:setVisible(false);
        self.entryBox:setVisible(false);
        self.btnConfirm:setVisible(false);

        self.btnCancel:setVisible(true);
        self.btnCancel:setX(self:getWidth() / 2 - self.btnCancel:getWidth() / 2);
        self.petAnimalsLabel:setVisible(true);
        self.icon:setVisible(true);
        self:setVisible(true);
    end
end

function LivestockZonesInfoOverlay:deactivate()
    self:setVisible(false);
    self.entryBox:setVisible(false);
    self.icon:setVisible(false);
    self.iconList:setVisible(false);
    self.petAnimalsLabel:setVisible(false);
    self.iconList:clear();
end

function LivestockZonesInfoOverlay:populateIconList()
    local icons = self.zonesIcons:getAll();

    for i = 0, icons:size() - 1 do
        local item = icons:get(i);
        self.iconList:addItem(item.title, item);
    end
end

--- @param animal livestockZonesAnimal
function LivestockZonesInfoOverlay:setPetAnimal(animal)
    self.petAnimalsLabel:setName(getText("IGUI_DesignationZone_Pet_Animal", animal:getName()));
    self.icon.texture = animal:getTexture();
end

--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param zonesIcons LivestockZonesIcons
--- @param livestockZone LivestockZone
function LivestockZonesInfoOverlay:new(x, y, width, height, zonesIcons, livestockZone)
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o.zonesIcons = zonesIcons;
    o.livestockZone = livestockZone;

    o.paddingTop = 2;
    o.paddingBottom = 2;
    o.paddingLeft = 2;
    o.paddingRight = 2;
    o.marginTop = 5;
    o.marginBottom = 5;
    o.marginLeft = 5;
    o.marginRight = 5;

    o.onClickRenameTarget = nil;
    o.onClickRenameFn = nil;

    o.onClickChangeIconTarget = nil;
    o.onClickChangeIconFn = nil;

    o.onClickRemoveTarget = nil;
    o.onClickRemoveFn = nil;

    o.onClickCancelPetAnimalsTarget = nil;
    o.onClickCancelPetAnimalsFn = nil;

    o.overlayMode = o.modeNameChange;

    return o
end
