data:extend{
{
    type = "shortcut",
    name = "long-science-show-records",
    action = "lua",
    icons = {
        { icon = "__base__/graphics/icons/signal/signal-science-pack.png" },
        { icon = "__base__/graphics/icons/signal/signal-clock.png", scale = 0.1, shift = {4, 4} },
    },
    small_icons = {
        { icon = "__base__/graphics/icons/signal/signal-science-pack.png" },
        { icon = "__base__/graphics/icons/signal/signal-clock.png", scale = 0.1, shift = {4, 4} },
    },
    toggleable = true,
    unavailable_until_unlocked = false,
    associated_control_input = "long-science-show-records",
},
{
    type = "custom-input",
    name = "long-science-show-records",
    key_sequence = "CONTROL + ALT + T",
    consuming = "game-only",
    action = "lua"
}
}

local styles = data.raw["gui-style"]["default"]
styles.long_science_table_entry = {
    type = "frame_style",
    parent = "achievement_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    horizontally_squashable = "on",
    natural_width = 128,
    minimal_width = 128,
    maximal_width = 256,
}
styles.long_science_table_entry_finished = {
    type = "frame_style",
    parent = "completed_achievement_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    horizontally_squashable = "on",
    natural_width = 128,
    minimal_width = 128,
    maximal_width = 256,
}
styles.long_science_progressbar = {
    type = "progressbar_style",
    parent = "bonus_progressbar",
    natural_width = 128 - 16,
    horizontally_stretchable = "on",
    color = {0, 1, 0}
}