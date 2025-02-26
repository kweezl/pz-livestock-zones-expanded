-- todo: add styles form ui constants
local style = {
    livestockZonesWindow = {
        borderColor = { r=0.4, g=0.4, b=0.4, a=1 },
        backgroundColor = { r=0, g=0, b=0, a=0.8 },
        minimumWidth = 150,
        maximumWidth = 0,
        minimumHeight = 400,
        maximumHeight = 0,
        maximumHeightPercent = -1,
        enableHeader = true,
        resizeable = true,
        anchorLeft = true,
        anchorRight = false,
        anchorTop = true,
        anchorBottom = false,
        pin = true,
        drawFrame = true,
    },
    livestockZonesWindowHeader = {
        paddingTop = 2,
        paddingBottom = 2,
        paddingLeft = 2,
        paddingRight = 2,
        marginTop = 5,
        marginBottom = 5,
        marginLeft = 5,
        marginRight = 5,
        enableTitle = true,
        enableIcon = true,
        enableInfoButton = true,
    },
    livestockZonesPanel = {

    },
}

return style
