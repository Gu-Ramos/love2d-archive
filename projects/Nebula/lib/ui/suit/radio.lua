-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')
local function index_of(t, a)
	if a == nil then return nil end
	for i = 1, #t do
		if a == t[i] then
			return i
		end
	end
	return nil
end

return function(core, radio, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	local rx, ry, rw, rh
	local checkbox = radio.list[radio.id]
	if opt.rbox then
		rx = opt.rbox[1]
		ry = opt.rbox[2]
		rw = opt.rbox[3]
		rh = opt.rbox[4]
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
		local active = radio.list.active
		if checkbox.checked then
			table.insert(active, radio.id)
			if #active > radio.list.max then
				radio.list[active[1]].checked = false
				table.remove(active, 1)
			end
		else
			table.remove(active, index_of(active,radio.id))
		end
	end
	core:registerDraw(opt.draw or core.theme.Radio, checkbox, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = hit,
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
