local modules = (...):gsub('%.[^%.]+$', '') .. '.'
local utils = require(modules .. 'utils')
local base_node = require(modules .. 'base_node')

local lovg = love.graphics

local joy = base_node:extend('joy')

function joy:constructor()
	joy.super.constructor(self)
	self.joyX = 0
	self.joyY = 0
end

local sin,cos = math.sin,math.cos
local atan2 = math.atan2
function joy:limitMovement()
	if self:stickRadius() < (self.joyX^2 + self.joyY^2)^0.5 then
		local a = atan2(self.joyY, self.joyX)
		self.joyX, self.joyY = cos(a)*self.w, sin(a)*self.h
	end
end

function joy:getX() return self.joyX / self:stickRadius() end
function joy:getY() return self.joyY / self:stickRadius() end

function joy:draw()
	local _, fgc = self:getLayerColors()
	lovg.setColor(fgc)
	utils.circ('fill', self:centerX() + self.joyX, self:centerY() + self.joyY, self:stickRadius()*0.25)
end

function joy:stickRadius() return math.min(self.w, self.h) end

return joy
