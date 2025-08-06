require "util"
-- require "scripts.meta.constants"
local Class = require "lib.options.class"
local Files = (require "lib.options.files"):new()

local OptionsManager = Class:inherit()

function OptionsManager:init()
	self.is_first_time = false
	self.default_options = {
		["$version"] = 2,
		language = "default",

        sound_on = true,
		volume = 1.0,
		fullscreen = false,
	}
	self.setters = {
		language = function(value)
			if value == "default" then
				set_lang(get_fallback_lang()) -- TODO get user lang instead
			else
				set_lang(value)
			end
		end,
		sound_on = function(value) 
			if value then
				love.audio.setVolume(self:get("volume"))
			else
				love.audio.setVolume(0)
			end
		end,
		volume = function(value) 
			if self:get("sound_on") then
				love.audio.setVolume(value)
			end
		end,
		fullscreen = function(value) 
			love.window.setFullscreen(value)		
		end,
	}

	self:load_options()
end

function OptionsManager:load_options()
	print("Loading options...")
	self.options = Files:read_config_file("options.txt", self.default_options)
	print("Finished loading options.")
end

function OptionsManager:update_options_file()
	Files:write_config_file("options.txt", self.options)
end

function OptionsManager:get(name)
	return self.options[name]
end

function OptionsManager:set(name, val, do_not_update_file)
	do_not_update_file = param(do_not_update_file, false)
	self.options[name] = val
	if self.setters[name] then
		self.setters[name](val)
	end

	if not do_not_update_file then
		self:update_options_file()
	end
end

function OptionsManager:toggle(name)
	self:set(name, not self.options[name])
end

function OptionsManager:update_options()
	for k, v in pairs(self.options) do
		self:set(k, self:get(k), true)
	end
end

return OptionsManager:new()