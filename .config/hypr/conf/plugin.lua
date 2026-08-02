-- plugin.lua
hl.config({
    plugin = {
        hyprexpo = {
            columns = 3,
            gap_size = 2,
            bg_col = "rgb(0d1c2e)",
            workspace_method = "first 1",
            enable_gesture = true,
            gesture_distance = 300,
            gesture_positive = true,
        },
    },
})

-- No native hl.dsp/hl.plugin mapping exists for this plugin yet,
-- so fall back to calling the old dispatcher through hyprctl:
hl.bind("SUPER + Z", function()
    hl.exec("hyprctl dispatch hyprexpo:expo toggle")
end)
