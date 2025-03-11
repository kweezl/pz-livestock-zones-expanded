local stat = require("WeeezLivestockZonesExpanded/Enums/LivestockZoneStat").stat;
local animalMoodleType = require("WeeezLivestockZonesExpanded/Enums/AnimalMoodleType");
local animalGrowStageType = require("WeeezLivestockZonesExpanded/Enums/AnimalGrowStageType");
local animalGenderType = require("WeeezLivestockZonesExpanded/Enums/AnimalGenderType");

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

    moodleColor = {
        neutral = ColorInfo.new(1.0, 1.0, 1.0, 1.0),
        geriatric = ColorInfo.new(1.0, 0.53, 0.21, 1.0),
        negative = {
            min = ColorInfo.new(255, 0.83, 0.83, 1.0),
            max = getCore():getBadHighlitedColor(),
        },
        positive = {
            min = ColorInfo.new(0.83, 1.0, 0.83, 1.0),
            max = getCore():getGoodHighlitedColor(),
        },
    },

    moodle = {
        -- stats
        [animalMoodleType.health] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_health.png"),
        },
        [animalMoodleType.hungry] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_hungry.png"),
        },
        [animalMoodleType.thirsty] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_thirsty.png"),
        },
        [animalMoodleType.anxiety] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_anxiety.png"),
        },

        -- resources
        [animalMoodleType.shear] = {
            texture = getTexture("media/ui/animal_moodle_basic_resource_shear.png"),
        },
        [animalMoodleType.milk] = {
            texture = getTexture("media/ui/animal_moodle_basic_resource_milk.png"),
        },

        -- grow stage
        [animalGrowStageType.baby] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_baby.png"),
        },
        [animalGrowStageType.juvenile] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_juvenile.png"),
        },
        [animalGrowStageType.adult] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_adult.png"),
        },
        [animalGrowStageType.geriatric] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_geriatric.png"),
        },

        -- gender
        [animalGenderType.female] = {
            texture = getTexture("media/ui/animal_moodle_basic_gender_female.png"),
        },
        [animalGenderType.male] = {
            texture = getTexture("media/ui/animal_moodle_basic_gender_male.png"),
        },
    },

    moodleOrder = {
        animalMoodleType.gender,
        animalMoodleType.growStage,
        animalMoodleType.health,
        animalMoodleType.hungry,
        animalMoodleType.thirsty,
        animalMoodleType.anxiety,
        animalMoodleType.milk,
        animalMoodleType.shear,
    },
};

return config;
