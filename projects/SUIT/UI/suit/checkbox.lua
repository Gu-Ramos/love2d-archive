-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

return function(core, checkbox, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	local rx, ry, rw, rh

	if opt.rbox then
		rx = x+opt.rbox.x
		ry = y+opt.rbox.y
		rw = opt.rbox.w
		rh = opt.rbox.h
	else
		rx, ry, rw, rh = x, y, w, h
	end
	opt.id = opt.id or checkbox
	opt.font = opt.font or love.graphics.getFont()

	local text = type(checkbox.text) == 'function' and checkbox.text() or tostring(checkbox.text) --luacheck: ignore
	local utext = type(checkbox.utext) == 'function' and checkbox.utext() or utext and tostring(checkbox.utext) --luacheck: ignore

	if utext and not checkbox.checked then
		w = w or (opt.font:getWidth(utext) + opt.font:getHeight() + 4)
	else
		w = w or (opt.font:getWidth(text) + opt.font:getHeight() + 4)
	end

	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt.id, rx, ry, rw, rh)
	local hit = core:mouseReleasedOn(opt.id)
	if hit then
		checkbox.checked = not checkbox.checked
	end
	core:registerDraw(opt.draw or core.theme.Checkbox, checkbox, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = hit,
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
