-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local function isType(val, typ)
	return type(val) == "userdata" and val.typeOf and val:typeOf(typ)
end

return function(core, text, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	if type(text) == 'function' then
		text = text()
	elseif not (type(text) == 'table' and isType(text[1], 'Image')) then
		text = tostring(text)
	end
	opt.id = opt.id or text
	opt.font = opt.font or love.graphics.getFont()

	w = w or opt.font:getWidth(text) + 4
	h = h or opt.font:getHeight() + 4

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	core:registerDraw(opt.draw or core.theme.Button, text, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
