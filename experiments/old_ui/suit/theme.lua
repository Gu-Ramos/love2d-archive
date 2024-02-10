-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')
local function unpack4(t) return t[1], t[2], t[3], t[4]; end
local lg = love.graphics

local theme = {}
theme.cornerRadius = 4

theme.color = {
	normal   = {bg = {0.25, 0.25, 0.25}, fg = {0.73, 0.73, 0.73}},
	hovered  = {bg = {0.19, 0.6, 0.73}, fg = {1, 1, 1}},
	active   = {bg = {1, 0.6, 0}, fg = {1, 1, 1}}
}




-- HELPER
function theme.getColorForState(opt)
	local s = opt.state or "normal"
	return (opt.color and opt.color[opt.state]) or theme.color[s]
end

function theme.getTextColorForState(opt)
	local s = opt.state or "normal"
	return (opt.t_color and opt.t_color[opt.state]) or theme.color[s]
end

local stX, stY, stW, stH, stCR, stDM, stLW

local function stencilFunc()
	stCR = stCR or theme.cornerRadius
	stW = math.max(stCR/2, stW)
	if stH < stCR/2 then
		stY,stH = stY - (stCR - stH), stCR/2
	end

	if stDM == 'line' then
		stLW = stLW or 10
		lg.setLineWidth(stLW)
		lg.rectangle(stDM or 'fill', stX+stLW/2,stY+stLW/2, stW-stLW,stH-stLW, stCR-stLW/2)
	end
	lg.rectangle(stDM or 'fill', stX,stY, stW,stH, stCR)
end

function theme.drawBox(x,y,w,h, colors, cornerRadius, drawMode, lineWidth)
	colors = colors or theme.getColorForState(opt)
	cornerRadius = cornerRadius or theme.cornerRadius
	w = math.max(cornerRadius/2, w)
	if h < cornerRadius/2 then
		y,h = y - (cornerRadius - h), cornerRadius/2
	end

	local r,g,b,ta = unpack4(colors.bg)
	local a = select(4,lg.getColor())
	a = ta and a*ta or a

	lg.setColor(r,g,b,a)
	if drawMode == 'line' then
		lineWidth = lineWidth or 10
		lg.setLineWidth(lineWidth);
		lg.rectangle('line', x+lineWidth/2,y+lineWidth/2, w-lineWidth,h-lineWidth, cornerRadius-lineWidth/2)
	else
		lg.rectangle('fill', x,y, w,h, cornerRadius)
	end
end

function theme.getVerticalOffsetForAlign(valign, font, h)
	if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
	end
	-- else: "middle"
	return (h - font:getHeight()) / 2
end

-- WIDGET VIEWS
function theme.Label(text, opt, x,y,w,h)
	y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
	local r,g,b, ta = unpack4((opt.color and opt.color.normal or {}).fg or theme.color.normal.fg)
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)
	lg.setFont(opt.font)
	lg.printf(text, x+2, y, w-4, opt.align or "center")
end

function theme.Button(text, opt, x,y,w,h)
	local c = theme.getColorForState(opt)
	local t = opt.t_color and theme.getTextColorForState(opt)

	if opt.texture then
		stX, stY, stW, stH, stCR, stDM, stLW = x,y,w,h,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.texture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x,y,w,h, c, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end

	local r,g,b
	if t then r,g,b,ta = unpack4(t.fg); else r,g,b,ta = unpack4(c.fg); end
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)

	if type(text) == 'table' and type(text[1]) == 'userdata' then
		lg.draw(text[1], x,y, 0, text[2], text[2], text[3])
	else
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		lg.printf(text, opt.font, x+2, y, w-4, opt.align or "center")
	end
end

function theme.Checkbox(chk, opt, x,y,w,h)
	local c = theme.getColorForState(opt)
	local t = theme.getTextColorForState(opt)
-- 	local th = opt.font:getHeight()

	if opt.texture then
		stX, stY, stW, stH, stCR, stDM, stLW = x+h/10,y+h/10,h*.8,h*.8,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.texture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x+h/10,y+h/10,h*.8,h*.8, c, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end

	local r,g,b,ta = unpack4(c.fg)
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)

	if chk.checked then
		lg.setLineStyle('smooth')
		lg.setLineWidth(5)
		lg.setLineJoin("bevel")
		lg.line(x+h*.2,y+h*.55, x+h*.45,y+h*.75, x+h*.8,y+h*.2)
	end

	if t then r,g,b,ta = unpack4(t.fg); else r,g,b,ta = unpack4(c.fg); end
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)

	if chk.utext and not chk.checked then
		lg.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		lg.printf(tostring(chk.utext), x + h, y, w - h, opt.align or "left")
	elseif chk.text then
		lg.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		lg.printf(tostring(chk.text), x + h, y, w - h, opt.align or "left")
	end
end

function theme.Screen(border, opt, x,y,w,h)
	local c = opt.color and opt.color.normal or theme.color.normal
	if border and opt.fgtexture then
		local lw = opt.lineWidth or 10
		stX, stY, stW, stH, stCR, stLW = x-lw/2,y-lw/2,w+lw,h+lw,opt.cornerRadius+lw/2,opt.lineWidth
		stDM = 'line'
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.fg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.fgtexture, x,y)
		lg.setStencilTest()
	elseif border then
		local lw = opt.lineWidth or 10
		theme.drawBox(x-lw/2,y-lw/2,w+lw,h+lw, {bg=c.fg}, opt.cornerRadius+lw/2, 'line', opt.lineWidth)
	end
	if opt.bgtexture then
		stX, stY, stW, stH, stCR = x,y,w,h,opt.cornerRadius
		stDM = 'fill'
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.bgtexture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x,y,w,h, c, opt.cornerRadius, 'fill')
	end
end

function theme.Radio(chk, opt, x,y,w,h)
	local c = theme.getColorForState(opt)
	local t = theme.getTextColorForState(opt)
-- 	local th = opt.font:getHeight()

	if opt.texture then
		stX, stY, stW, stH, stCR, stDM, stLW = x+h/10,y+h/10,h*.8,h*.8,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.texture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x+h/10,y+h/10,h*.8,h*.8, c, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end

	if chk.checked then
		theme.drawBox(x+h/10 + 20,y+h/10 + 20,h*.8-40,h*.8-40, {bg=c.fg}, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end

	local r,g,b,ta
	if t then r,g,b,ta = unpack4(t.fg); else r,g,b,ta = unpack4(c.fg); end
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)

	if chk.utext and not chk.checked then
		lg.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		lg.printf(tostring(chk.utext), x + h, y, w - h, opt.align or "left")
	elseif chk.text then
		lg.setFont(opt.font)
		y = y + theme.getVerticalOffsetForAlign(opt.valign, opt.font, h)
		lg.printf(tostring(chk.text), x + h, y, w - h, opt.align or "left")
	end
end

function theme.Slider(fraction, opt, x,y,w,h)
	local xb, yb, wb, hb -- size of the progress bar
	local r =  math.min(w,h) / 2.1
	if opt.vertical then
		x, w = x + w*.25, w*.5
		xb, yb, wb, hb = x, y+h*(1-fraction), w, h*fraction
	else
		y, h = y + h*.25, h*.5
		xb, yb, wb, hb = x,y, w*fraction, h
	end

	local c = theme.getColorForState(opt)
	if opt.bgtexture then
		stX, stY, stW, stH, stCR, stDM, stLW = x,y,w,h,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local red,g,b,ta = unpack4(c.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(red,g,b,a)
		lg.draw(opt.bgtexture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x,y,w,h, c, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end
	if opt.fgtexture then
		stX, stY, stW, stH, stCR, stDM, stLW = xb,yb,wb,hb,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local red,g,b,ta = unpack4(c.fg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(red,g,b,a)
		lg.draw(opt.fgtexture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(xb,yb,wb,hb, {bg=c.fg}, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end

	if opt.state ~= nil and opt.state ~= "normal" then
		local red,g,b,ta = unpack4((opt.color and opt.color.active or {}).fg or theme.color.active.fg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(red,g,b,a)
		if opt.vertical then
			lg.circle('fill', x+wb/2, yb, r)
		else
			lg.circle('fill', x+wb, yb+hb/2, r)
		end
	end
end

function theme.Input(input, opt, x,y,w,h)
	local utf8 = require 'utf8'
	local t = opt.t_color
	local c = opt.color or theme.color
	if opt.texture then
		stX, stY, stW, stH, stCR, stDM, stLW = x,y,w,h,opt.cornerRadius,opt.drawMode,opt.lineWidth
		lg.stencil(stencilFunc, 'replace', 1)
		lg.setStencilTest('equal', 1)
		local r,g,b,ta = unpack4(c.normal.bg)
		local a = select(4,lg.getColor())
		a = ta and a*ta or a
		lg.setColor(r,g,b,a)
		lg.draw(opt.texture, x,y)
		lg.setStencilTest()
	else
		theme.drawBox(x,y,w,h, c.normal, opt.cornerRadius, opt.drawMode, opt.lineWidth)
	end
	x = x + 3
	w = w - 6

	local th = opt.font:getHeight()

	-- set scissors
	local sx, sy, sw, sh = lg.getScissor()

	local rx, ry = lg.transformPoint(x-1, y)
	local rw, rh = lg.transformPoint(x+w+2, y+h)
	rw, rh = rw-rx, rh-ry

	lg.setScissor(rx, ry, rw, rh)
	x = x - input.text_draw_offset

	-- text
	local r,g,b
	if t then r,g,b,ta = unpack4(t.normal.fg); else r,g,b,ta = unpack4(c.normal.fg); end
	local a = select(4,lg.getColor())
	a = ta and a*ta or a
	lg.setColor(r,g,b,a)
	lg.setFont(opt.font)
	if input.text == '' and input.placeholder then
		lg.setColor(r,g,b,a*0.6)
		lg.print(tostring(input.placeholder), x, y+(h-th)/2)
	else
		lg.print(input.text, x, y+(h-th)/2)
	end

-- 	-- candidate text
-- 	local tw = opt.font:getWidth(input.text)
-- 	local ctw = opt.font:getWidth(input.candidate_text.text)
-- 	local r,g,b
-- 	if t then r,g,b = unpack4(t.active.fg); else r,g,b = unpack4(c.active.fg); end
-- 	local a = select(4,lg.getColor())
-- 	lg.setColor(r,g,b,a)
-- 	lg.print(input.candidate_text.text, x + tw, y+(h-th)/2)

-- 	-- candidate text rectangle box
-- 	lg.rectangle("line", x + tw, y+(h-th)/2, ctw, th)
	lg.setColor(r,g,b,a)
	-- cursor
	if opt.hasKeyboardFocus and (love.timer.getTime() % 1) > .5 then
		local ct = input.candidate_text;
		local ss = ct.text:sub(1, utf8.offset(ct.text, ct.start))
		local ws = opt.font:getWidth(ss)
		if ct.start == 0 then ws = 0 end

		lg.setLineWidth(2)
		lg.setLineStyle('rough')
		lg.line(x + opt.cursor_pos + ws, y + (h-th)/2,
		                   x + opt.cursor_pos + ws, y + (h+th)/2)
	end

	-- reset scissor
	lg.setScissor(sx,sy,sw,sh)
end

return theme
