-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

config.font_size = 16.0
config.color_scheme = 'Afterglow'
config.window_background_opacity = 0.95
config.window_background_image_hsb = {
    brightness = 0.2,
}

-- and finally, return the configuration to wezterm
return config