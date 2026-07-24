local BASE_MOD = settings.startup["long-science-base-max-multiplier-override"].value / 1000
local ui = require("gui")

local function update_record(tech, tick)
    local progress = tech.researched and 1 or tech.saved_progress or 0
    local record = storage.records[tech.name]
    if record and progress <= record.progress then return end
    local mult_current = game.difficulty_settings.technology_price_multiplier * BASE_MOD
    record = record or { name = tech.name, progress = 0, tick_at_start = tick, multiplier_at_start = mult_current, multiplier_average = 0, invested = 0 }
    local cost = (tech.research_unit_count or 0)
    if cost > 0 then
        local progress_step = progress - record.progress
        record.invested = record.invested + cost * progress_step
        record.multiplier_average = record.multiplier_average + progress_step * mult_current
    end
    record.progress = progress
    if progress >= 1 then
        record.tick_at_completion = tick
        record.multiplier_at_completion = mult_current
    end
    storage.records[tech.name] = record
end

local function level_adjusted_multiplier(multiplier, level)
  if settings.global["long-science-ignore-level-bonus"].value then return multiplier end
  local int = math.floor(multiplier)
  local frac = multiplier - int
  return int + frac / level 
end

local function print_multiplier_change(prev_multiplier)
    local prev = prev_multiplier and prev_multiplier * BASE_MOD
    local new = game.difficulty_settings.technology_price_multiplier * BASE_MOD
    local message = prev and string.format("[item=science] Cost multiplier changed: %.2f -> %.2f (x%.2f)", prev, new, new / prev) or string.format("[item=science] Cost multiplier changed: %.2f", new)
    for _, player in pairs(game.players) do
        if player.mod_settings["long-science-log-current"].value then
            player.print(message)
        end
    end
end

local function apply_multiplier()
    local max_mul = settings.global["long-science-base-max-multiplier"].value / BASE_MOD
    local mul = settings.global["long-science-initial-multiplier"].value / BASE_MOD
    local exclude_essential_techs = settings.global["long-science-exclude-basic-techs"].value
    local tick = game.tick
    storage.records = storage.records or { }
    for _, tech in pairs(game.forces.player.technologies) do
        if not tech.researched and tech.saved_progress > 0 and (tech.research_unit_energy or 0) > 0 then 
            update_record(tech, tick)
            goto next
        end
        if exclude_essential_techs and tech.prototype.ignore_tech_cost_multiplier then goto next end
        local change = 1
        if tech.prototype.research_trigger then
            change = level_adjusted_multiplier(settings.global["long-science-trigger-multiplier"].value, tech.level or 1)
        else
            change = level_adjusted_multiplier(settings.global["long-science-normal-multiplier"].value, tech.level or 1)
        end
        mul = mul * change
        ::next::
    end

    local new = math.min(max_mul, mul)
    local old = game.difficulty_settings.technology_price_multiplier
    game.difficulty_settings.technology_price_multiplier = new
    if old ~= new then
        print_multiplier_change(old)
    end

    storage.new_researches  = nil
    script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting:match("^long%-science%-") then
        apply_multiplier()
    end
end)

-- called in on_load: must adhere to https://lua-api.factorio.com/latest/classes/LuaBootstrap.html#on_load
local function register_post_apply_handler()
    if (storage.new_researches or 0) == 0 then
      script.on_event(defines.events.on_tick, nil)
    else
      script.on_event(defines.events.on_tick, apply_multiplier)
    end
end

script.on_init(function()
    storage.records = storage.records or { }
end)

script.on_event(defines.events.on_research_started, function(event)
    update_record(event.research, event.tick)
    if event.last_research then
        update_record(event.last_research, game.tick)
    end
end)

script.on_event(defines.events.on_research_cancelled, function(event)
    for research, _ in pairs(event.research) do
        local r = game.forces.player.technologies[research]
        if r then
            update_record(r, event.tick)
        end
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    storage.new_researches = (storage.new_researches or 0) + 1
    update_record(event.research, event.tick)
    register_post_apply_handler()
end)

script.on_event(defines.events.on_research_reversed, function(event)
    storage.records[event.research.name] = nil
end)

script.on_load(register_post_apply_handler)

script.on_event(defines.events.on_lua_shortcut, function (event)
    if event.prototype_name ~= "long-science-show-records" then return end
    local player = game.players[event.player_index]
    ui.toggle_ui(player)
    player.set_shortcut_toggled("long-science-show-records", player.gui.screen.long_science_records ~= nil)
end)