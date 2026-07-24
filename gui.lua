local function to_time(tick)
    if not tick or tick >= 0xFFFFFFFF then return "-" end
    local is_over = false
    if tick < 0 then
        tick = -tick
        is_over = true
    end
    local seconds = tick / 60
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    local fmt
    if hours > 0 then
        -- Format as h:mm
        fmt = "%d:%02d:%02d"
        if is_over then fmt = "+"..fmt end
        return string.format(fmt, hours, minutes, secs)
    else
        -- Format as m.ss
        fmt = "%d:%02d"
        if is_over then fmt = "+"..fmt end
        return string.format(fmt, minutes, secs)
    end
end

local function get_techs()
    local techs = { }
    for _, entry in pairs(storage.records or { }) do
        table.insert(techs, entry)
    end
    table.sort(techs, function(a, b)
        if a.tick_at_completion and b.tick_at_completion then
            return a.tick_at_completion > b.tick_at_completion
        elseif a.tick_at_completion then return true
        elseif b.tick_at_completion then return false
        else return a.progress > b.progress end
    end)
    return techs
end

local function add_button(parent, sprite, style, name, size)
    local btn = parent.add{
        type = "sprite-button",
        sprite= sprite,
        style = style,
        name = name,
        show_percent_for_small_numbers = true
    }
    btn.style.size = size
    return btn
end

local M = { }
function M.toggle_ui(player)
    local frame = player.gui.screen.long_science_records
    if frame then frame.destroy() return end
    local current_head = #player.force.research_queue > 0 and player.force.research_queue[1].name
    frame = player.gui.screen.add {
        name = "long_science_records",
        type = "frame",
        caption = "Research stats",
    }.add{type = "frame", direction = "vertical", style = "inside_deep_frame"}
    frame.style.natural_height = 640
    frame.style.height = 640
    local header = frame.add{ type = "frame", style = "subheader_frame" }
    header.style.horizontally_stretchable = true
    header.style.horizontally_squashable = true
    local t = frame.add{ type = "scroll-pane", style = "naked_scroll_pane" }
                   .add { type = "table", column_count = 3, style = "filter_slot_table" }
    header.add{ type = "label", caption = "" }.style.width = 64
    header.add{ type = "label", caption = { "long-science-ui.completed-header" },   style = "subheader_caption_label" }.style.width = 128
    header.add{ type = "label", caption = { "long-science-ui.started-header" }, style = "subheader_caption_label" }
    for _, entry in pairs(get_techs()) do
        local is_done = entry.progress >= 1
        local frame_style = is_done and "long_science_table_entry_finished" or "long_science_table_entry"
        local btn = add_button(t, "technology/"..entry.name, is_done and "tool_button_green" or "tool_button_blue", nil, 64)
        btn.elem_tooltip = { type = "technology", name = entry.name }
        local f1 = t.add { type = "frame", direction = "vertical", style = frame_style } 
        if entry.name == current_head then
            f1.add{ type = "label", caption = { "long-science-ui.working-on" } }
        else
            f1.add{ type = "label", caption = { "long-science-ui.science-spent", string.format("%i", entry.invested) } }
            f1.add{ type = "label", caption = is_done and { "long-science-ui.time-finished", to_time(entry.tick_at_completion) } or { "long-science-ui.percent-finished", string.format("%i", entry.progress * 100) } }
        end
        local f2 = t.add { type = "frame", direction = "vertical", style = frame_style }
        if entry.progress > 0 then
            f2.add{ type = "label", caption = { "long-science-ui.time-stats", string.format("%.2f", entry.multiplier_average / entry.progress), to_time((entry.tick_at_completion or game.tick) - entry.tick_at_start)  } }
        end
        if is_done and entry.multiplier_at_completion ~= entry.multiplier_at_start then
            f2.add{ type = "label", caption = { "long-science-ui.mult-progress",  string.format("%.2f", entry.multiplier_at_start), is_done and string.format("%.2f", entry.multiplier_at_completion) or "-" } }
        end
    end
end
return M