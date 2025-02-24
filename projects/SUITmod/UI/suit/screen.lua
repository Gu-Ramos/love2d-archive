-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')

return function(core, border, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	core:registerScreenDraw(opt.draw or core.theme.Screen, border, opt, x,y,w,h)
end
