-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

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

local max,min = math.max,math.min

return function(core, info, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)

	opt.id = opt.id or info

	info.min = info.min or min(info.value, 0)
	info.max = info.max or max(info.value, 1)
-- 	local fraction = (info.value - info.min) / (info.max - info.min)
	local value_changed = false
	local svalue_changed = true
	local old_svalue = info.svalue or info.value

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	local fraction

	if core:isActive(opt.id) then
		-- mouse update
		local mx,my = core:getMousePosition()
		if opt.vertical then
			fraction = min(1, max(0, (y+h - my) / h))
		else
			fraction = min(1, max(0, (mx - x) / w))
		end
		local v = fraction * (info.max - info.min) + info.min
		if v ~= info.value then
			info.value = v
			value_changed = true
		end
	else
		if opt.keyboard then
			-- keyboard update
			local key_up = opt.vertical and 'up' or 'right'
			local key_down = opt.vertical and 'down' or 'left'
			if core:getPressedKey() == key_up then
				info.value = min(info.max, info.value + info.step)
				value_changed = true
			elseif core:getPressedKey() == key_down then
				info.value = max(info.min, info.value - info.step)
				value_changed = true
			end
		end
		if opt.mscroll then
			if not opt.scroll_area or core:mouseInRect(opt.sarea.x, opt.sarea.y, opt.sarea.w, opt.sarea.h) then
				local wheelVar = opt.vertical and core.mouseWheel_y or core.mouseWheel_x or 0
				if wheelVar > 0 then
					info.value = min(info.max, info.value + info.step*wheelVar)
					value_changed = true
				elseif wheelVar < 0 then
					info.value = max(info.min, info.value + info.step*wheelVar)
					value_changed = true
				end
			end
		end
	end

	info.value = min(info.max, info.value)
	if info.round then info.value = round(info.value); end
	info.svalue = info.svalue and smooth(info.svalue, info.value, clamp( 0.4 * love.timer.getDelta()/(1/60), 0.1, 0.75 ) ) or info.value
	fraction = ((info.svalue or info.value) - info.min) / (info.max - info.min)

	local m = (info.max - info.min)/1000
	if info.svalue - m < old_svalue and  info.svalue + m > old_svalue then
		svalue_changed = false
	end

	core:registerDraw(opt.draw or core.theme.Slider, fraction, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		changed = value_changed,
		schanged = svalue_changed,
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
