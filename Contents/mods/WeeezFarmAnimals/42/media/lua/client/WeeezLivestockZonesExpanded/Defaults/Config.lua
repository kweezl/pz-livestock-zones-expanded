local stat = require("WeeezLivestockZonesExpanded/Enums/LivestockZoneStat").stat

--- @module config
local config = {
    modDataZoneTag = "WeeezLivestockZonesExpanded_",
    defaultZoneIcon = "media/ui/Zone_Animal_On.png",
    defaultZoneTexture = getTexture("media/ui/Zone_Animal_On.png"),
    zoneBtnInternal = "ZONE_OVERRIDE",
    livestockZoneWindowStyle = "LivestockZonesWindow",
    filterAllTextDefault = "",
    filterAllAnimalGroupText = getText("IGUI_AnimalGroup_all"),
    filterAllAnimalGroupDefault = "*",

    detailsValueHiddenText = getText("IGUI_DesignationZone_Value_Hidden"),

    livestockZoneDetails = {
        [stat.animal] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_DesignationZone_Animals"),
        },
        [stat.connectedZone] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_DesignationZone_ConnectedZones"),
        },
        [stat.roofedArea] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_DesignationZone_RoofArea"),
        },
        [stat.hutch] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_DesignationZone_Hutchs"),
        },
        [stat.feedingTrough] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_DesignationZone_FeedingTroughs"),
        },
        [stat.water] = {
            perk = Perks.Husbandry,
            level = 2,
            title = getText("IGUI_DesignationZone_Water"),
        },
        [stat.food] = {
            perk = Perks.Husbandry,
            level = 2,
            title = getText("IGUI_DesignationZone_Food"),
        },
        [stat.dung] = {
            perk = Perks.Husbandry,
            level = 3,
            title = getText("IGUI_DesignationZone_Dung"),
        },
        [stat.feather] = {
            perk = Perks.Husbandry,
            level = 3,
            title = getText("IGUI_DesignationZone_Feathers"),
        },
        [stat.zoneSize] = {
            perk = Perks.Husbandry,
            level = 0,
            title = getText("IGUI_FeedingTroughUI_Enclosure"),
        },
    },

    -- to add custom icon textures
    zoneIcons = {
        {
            title = "Default zone icon",
            icon = "media/ui/Zone_Animal_On.png",
        }
    },

    iconTypes = {
        invIconMale = getText("IGUI_char_Male"),
        invIconFemale = getText("IGUI_char_Female"),
        invIconBaby = getText("IGUI_animal_baby"),
    },

    iconTypesDefault = "media/inventory/Question_On.png",
};

return config;
