local function level_adjusted_multiplier(multiplier, level)
  if settings.global["long-science-ignore-level-bonus"].value then return multiplier end
  local int = math.floor(multiplier)
  local frac = multiplier - int
  return int + frac / level 
end

local function apply_multiplier()
    local base = settings.startup["long-science-base-max-multiplier-override"].value / 1000
    local mul = settings.global["long-science-initial-multiplier"].value
    local exclude_essential_techs = settings.global["long-science-exclude-basic-techs"].value
    
    for _, tech in pairs(game.forces.player.technologies) do
        if not tech.researched then goto next end
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

    local new = math.min(1000, mul / base)
    local old = game.difficulty_settings.technology_price_multiplier 
    game.difficulty_settings.technology_price_multiplier = new
    if old ~= new then
        for _, player in pairs(game.players) do
            if player.mod_settings["long-science-log-current"].value then
                player.print("[item=science] Cost multiplier changed: "..old * base.." -> "..new * base .. " (x"..new/old..")")
            end
        end
    end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting:match("^long%-science%-") then
        apply_multiplier()
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    apply_multiplier()
end)

script.on_init(apply_multiplier)