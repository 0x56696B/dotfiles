local M = {}

local function safeInspect(obj)
	local ok, res = pcall(function()
		return hs.inspect(obj, { depth = 5 })
	end)
	if ok then
		return res
	else
		return tostring(obj)
	end
end

-- Unified formatter for any type
local function fmt(value)
	if type(value) == "table" then
		return safeInspect(value)
	elseif type(value) == "userdata" then
		-- try to stringify common Hammerspoon objects
		local mt = getmetatable(value)
		if mt == hs.window then
			local ok, t = pcall(function()
				return value:title()
			end)
			local ok2, a = pcall(function()
				return value:application():name()
			end)
			return string.format("<window: %s · %s>", a or "?", t or "?")
		elseif mt == hs.application then
			local ok, n = pcall(function()
				return value:name()
			end)
			return string.format("<app: %s>", n or "?")
		elseif mt == hs.screen then
			local ok, n = pcall(function()
				return value:name()
			end)
			return string.format("<screen: %s>", n or "?")
		else
			return tostring(value)
		end
	else
		return tostring(value)
	end
end

-- Create a logger instance
function M.new(name, level)
	local log = hs.logger.new(name or "hammerspoon", level or "info")
	hs.logger.setGlobalLogLevel(level or "info")

	-- Wrap standard log methods to pretty-print tables
	local levels = { "f", "e", "w", "i", "d", "v" }
	for _, lvl in ipairs(levels) do
		local orig = log[lvl]
		log[lvl] = function(self, ...)
			local parts = {}
			for _, arg in ipairs({ ... }) do
				table.insert(parts, fmt(arg))
			end
			return orig(self, table.concat(parts, " "))
		end
	end

	-- Helper method: log:p(obj, [label])
	function log:p(obj, label)
		self.i(label or "object", safeInspect(obj))
	end

	return log
end

return M
