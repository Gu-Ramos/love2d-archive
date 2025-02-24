local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local slider = base_node:extend('slider')

local function clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

local function smooth(a, b, amount)
	local t = clamp(amount, 0, 1)
	local m = t * t * (3 - 2 * t)
	return a + (b - a) * m
end

local ceil,floor = math.ceil,math.floor
local function round(v)
	if v < 0 then
		return ceil(v - 0.5)
	end
	return floor(v + 0.5)
end

function slider:constructor()
	slider.super.constructor(self)
	self.maxValue = self.maxValue or 1
	self.minValue = self.minValue or 0
	self.value = self.value or 0.5
	self.svalue = self.value
	self.axis = self.axis or 'x'
end

function slider:draw()
	local _, fgc = self:getLayerColors()
	lovg.setColor(fgc)

	if self.axis == 'x' then
		local w = self.cr*2 or 24
		local x = self.x + (self.w - w) * ((self.svalue - self.minValue) / (self.maxValue - self.minValue))
		utils.rect('fill', x, self.y, w, self.h, self.cr)
	else
		local h = self.cr*2 or 24
		local y = self.y + (self.h - h) * (1-((self.svalue - self.minValue) / (self.maxValue - self.minValue)))
		utils.rect('fill', self.x, y, self.w, h, self.cr)
	end
end

function slider:setValue(value)
	self.value = value
	if self.value > self.maxValue then self.value = self.maxValue end
	if self.value < self.minValue then self.value = self.minValue end
end

local min,max = math.min, math.max
function slider:update()
	local mx, my = utils.getMouse()

	if self.pressed then
		if self.axis == 'y' then
			local h = (self.h - self.padding * 2)
			fraction = min(1, max(0, (self.py + h - my) / h))
		else
			fraction = min(1, max(0, (mx - self.px) / (self.w - self.padding * 2)))
		end
		self:setValue(fraction * (self.maxValue - self.minValue) + self.minValue)
	end

	if self.round then self.value = round(self.value); end

	self.svalue = smooth(self.svalue, self.value, 0.4)
end

return slider
