-- require "scripts.util"
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
	}
	self.setters = {
		sound_on = function(value) 
			if value then
				love.audio.setVolume(self:get("volume"))
			else
				love.audio.setVolume(0)
			end
		end,
		volume = function(value) 
			love.audio.setVolume(value)
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

function OptionsManager:set(name, val)
	self.options[name] = val
	if self.setters[name] then
		self.setters[name](val)
	end
	self:update_options_file()
end

function OptionsManager:toggle(name)
	self:set(name, not self.options[name])
end

function OptionsManager:update_volume()
	love.audio.setVolume(self:get("sound_on") and self:get("volume") or 0.0)
end

return OptionsManager