local hypr = "~/.config/hypr"
local conf = hypr .. "/conf"
local theme = "tokyonight"

require("conf.env_vars")
require("conf.env_vars_nvidia")
require("themes." .. theme)
require("conf.startup")
require("conf.monitors")
require("conf.binds")
require("conf.input")
require("conf.layouts")
require("conf.rules")
require("conf.decoration")
-- require("conf.plugin")

hl.config({
    input = {
        kb_layout = "fr",
    },
})
