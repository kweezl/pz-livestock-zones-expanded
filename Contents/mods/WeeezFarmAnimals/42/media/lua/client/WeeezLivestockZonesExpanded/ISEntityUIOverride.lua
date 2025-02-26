local config = require("WeeezLivestockZonesExpanded/Defaults/Config");
local livestockZonesExpanded = require("WeeezLivestockZonesExpanded/Module/LivestockZonesExpanded");

-- duplicated local function from client/Entity/ISEntityUI.lua
local function createWindow(_player, _windowInstance, _isoObject)
    local playerNum = _player:getPlayerNum();

    local x = getMouseX() + 10;
    local y = getMouseY() + 10;
    local adjustPos = true;

    local width = 0;
    local height = 0;

    local windowKey = _windowInstance.xuiStyleName or "Default";

    -- close all other entity windows - we only allow one open at the moment. - spurcival
    ISEntityUI.CloseWindows();

    if ISEntityUI.players[playerNum] and ISEntityUI.players[playerNum].windows[windowKey] then
        if ISEntityUI.players[playerNum].windows[windowKey].instance then
            ISEntityUI.players[playerNum].windows[windowKey].instance:close();
        end
        if ISEntityUI.players[playerNum].windows[windowKey].x and ISEntityUI.players[playerNum].windows[windowKey].y then
            x = ISEntityUI.players[playerNum].windows[windowKey].x;
            y = ISEntityUI.players[playerNum].windows[windowKey].y;
            adjustPos = false;
        end
        if ISEntityUI.players[playerNum].windows[windowKey].width and ISEntityUI.players[playerNum].windows[windowKey].height then
            width = ISEntityUI.players[playerNum].windows[windowKey].width;
            height = ISEntityUI.players[playerNum].windows[windowKey].height;
        end
    else
        ISEntityUI.players[playerNum] = ISEntityUI.players[playerNum] or {};
        ISEntityUI.players[playerNum].windows = ISEntityUI.players[playerNum].windows or {};
        ISEntityUI.players[playerNum].windows[windowKey] = {};
    end

    _windowInstance:initialise();
    _windowInstance:instantiate();
    _windowInstance:setX(x);
    _windowInstance:setY(y);
    _windowInstance:setVisible(true);
    if _windowInstance.calculateLayout then
        _windowInstance:calculateLayout(width,height);
    end
    _windowInstance:addToUIManager();

    ISEntityUI.players[playerNum].windows[windowKey].instance = _windowInstance;
    ISEntityUI.players[playerNum].windows[windowKey].playerObj = _player;
    ISEntityUI.players[playerNum].windows[windowKey].entityObj = _isoObject;

    --first time open panel and isoobject then middle of screen.
    if adjustPos and instanceof(_isoObject, "IsoObject") then
        local x = (getCore():getScreenWidth()/2) - (_windowInstance:getWidth()/2);
        local y = (getCore():getScreenHeight()/2) - (_windowInstance:getHeight()/2);
        _windowInstance:setX(x);
        _windowInstance:setY(y);
        ISEntityUI.players[playerNum].windows[windowKey].x = x;
        ISEntityUI.players[playerNum].windows[windowKey].y = y;
    end

    if JoypadState.players[playerNum+1] then
        if getFocusForPlayer(playerNum) then getFocusForPlayer(playerNum):setVisible(false); end
        if getPlayerInventory(playerNum) then getPlayerInventory(playerNum):close(); end
        if getPlayerLoot(playerNum) then getPlayerLoot(playerNum):close(); end
        setJoypadFocus(playerNum, _windowInstance);
    end
end

function ISEntityUI.OpenLivestockZones(player, isoObject)
    local windowInstance = ISXuiSkin.build(
        XuiManager.GetDefaultSkin(),
        config.livestockZoneWindowStyle,
        LivestockZonesWindow,
        0,
        0,
        60,
        30,
        player,
        livestockZonesExpanded.getZonesController(player)
    );
    createWindow(player, windowInstance, isoObject);
end
