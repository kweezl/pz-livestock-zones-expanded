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
            min = ColorInfo.new(1.0, 0.88, 0.19, 1.0),
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
            tooltip = getText("IGUI_AnimalMoodle_Health_Tooltip"),
        },
        [animalMoodleType.hungry] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_hungry.png"),
            tooltip = getText("IGUI_AnimalMoodle_Hungry_Tooltip"),
        },
        [animalMoodleType.thirsty] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_thirsty.png"),
            tooltip = getText("IGUI_AnimalMoodle_Thirsty_Tooltip"),
        },
        [animalMoodleType.anxiety] = {
            texture = getTexture("media/ui/animal_moodle_basic_stat_anxiety.png"),
            tooltip = getText("IGUI_AnimalMoodle_Anxiety_Tooltip"),
        },

        -- resources
        [animalMoodleType.shear] = {
            texture = getTexture("media/ui/animal_moodle_basic_resource_shear.png"),
            tooltip = getText("IGUI_AnimalMoodle_Shear_Tooltip"),
        },
        [animalMoodleType.milk] = {
            texture = getTexture("media/ui/animal_moodle_basic_resource_milk.png"),
            tooltip = getText("IGUI_AnimalMoodle_Milk_Tooltip"),
        },

        -- grow stage
        [animalGrowStageType.baby] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_baby.png"),
            tooltip = getText("IGUI_AnimalMoodle_Baby_Tooltip"),
        },
        [animalGrowStageType.juvenile] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_juvenile.png"),
            tooltip = getText("IGUI_AnimalMoodle_Juvenile_Tooltip"),
        },
        [animalGrowStageType.adult] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_adult.png"),
            tooltip = getText("IGUI_AnimalMoodle_Adult_Tooltip"),
        },
        [animalGrowStageType.geriatric] = {
            texture = getTexture("media/ui/animal_moodle_basic_grow_stage_geriatric.png"),
            tooltip = getText("IGUI_AnimalMoodle_Geriatric_Tooltip"),
        },

        -- gender
        [animalGenderType.female] = {
            texture = getTexture("media/ui/animal_moodle_basic_gender_female.png"),
            tooltip = getText("IGUI_AnimalMoodle_Female_Tooltip"),
        },
        [animalGenderType.male] = {
            texture = getTexture("media/ui/animal_moodle_basic_gender_male.png"),
            tooltip = getText("IGUI_AnimalMoodle_Male_Tooltip"),
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

    moodleThreshold = {
        [animalMoodleType.health] = 0.9,
        [animalMoodleType.hungry] = 0.3,
        [animalMoodleType.thirsty] = 0.3,
        [animalMoodleType.anxiety] = 20.0,
        [animalMoodleType.shear] = 1.0,
        [animalMoodleType.milk] = 0.1,
    },
};

return config;
