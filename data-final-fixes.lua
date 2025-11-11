local base = settings.startup["long-science-base-max-multiplier-override"].value / 1000
if base ~= 1 then -- multiply all science by this value to fake a higher maximum multiplier
    for _, tech in pairs(data.raw["technology"]) do
        if tech.unit and not tech.ignore_tech_cost_multiplier then
            if tech.unit.count then 
                tech.unit.count = tech.unit.count * base
            elseif tech.unit.count_formula then
                tech.unit.count_formula = "("..tech.unit.count_formula..") * "..base
            end 
        end
    end

end