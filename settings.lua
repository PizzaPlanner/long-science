data:extend({
    
    {
        type = "bool-setting",
        name = "long-science-exclude-basic-techs",
        setting_type = "runtime-global",
        default_value = true,
        allow_blank = false
    },
    {
        type = "bool-setting",
        name = "long-science-ignore-level-bonus",
        setting_type = "runtime-global",
        default_value = false,
        allow_blank = false
    },
    {
        type = "bool-setting",
        name = "long-science-log-current",
        setting_type = "runtime-per-user",
        default_value = true,
        allow_blank = false
    },
    {
        type = "double-setting",
        name = "long-science-base-max-multiplier-override",
        setting_type = "startup",
        default_value = 100000,
        minimum_value = 1,
        maximum_value = 1000000,
        allow_blank = false
    },
    {
        type = "double-setting",
        name = "long-science-normal-multiplier",
        setting_type = "runtime-global",
        default_value = 1.06,
        minimum_value = 0.8,
        maximum_value = 5,
        allow_blank = false
    },
    {
        type = "double-setting",
        name = "long-science-trigger-multiplier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.8,
        maximum_value = 5,
        allow_blank = false
    },
    {
        type = "double-setting",
        name = "long-science-initial-multiplier",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 0.01,
        maximum_value = 100000,
        allow_blank = false
    },
})