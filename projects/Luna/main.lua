love.keyboard.setKeyRepeat(true)

function love.load()
	local sys = love.system.getOS()
	if sys ~= 'Linux' and sys ~= 'Android' then
		local _, maxY = love.window.getDesktopDimensions()
		maxY = maxY - 50
		love.window.setMode(maxY/9*16, maxY, {resizable=true})
		local pX, _ = love.window.getPosition()
		love.window.setPosition(pX, 10)
	elseif sys == 'Linux' then
		love.window.setMode(480, 850, {resizable=true});
	end

	require('loader')
	love.graphics.setCanvas()

	if sys == 'Android' then
		local wx, wy = love.window.getMode()
		if wx > wy then wx, wy = wy, wx end
		love.window.setMode(wx,wy, {fullscreen=true, fullscreentype='exclusive', usedpiscale=false, resizable=false})
	end
end

do -- GLOBAL SCALER
	local wx, wy = love.window.getMode()
	__WINX__ = wx
	__WINY__ = wy

	local sc = 16/9*wx > wy and wy/1920 or wx/1080

	__GSCALE__ = sc
	__GTRANSFORM__ = love.math.newTransform(wx/2-1080*sc/2, wy/2-1920*sc/2, 0,
											sc,sc,0,0)
	__R0X__, __R0Y__ = __GTRANSFORM__:inverseTransformPoint(0,0)
	__R1X__, __R1Y__ = __GTRANSFORM__:inverseTransformPoint(wx,wy)
end


function love.update(dt)
	do -- GLOBAL SCALER
		local wx, wy = love.window.getMode()
		if wx ~= __WINX__ or wy ~= __WINY__ then
			__WINX__ = wx
			__WINY__ = wy

			local sc = 16/9*wx > wy and wy/1920 or wx/1080

			__GSCALE__ = sc
			__GTRANSFORM__ = love.math.newTransform(wx/2-1080*sc/2, wy/2-1920*sc/2, 0,
													sc,sc,0,0)
			__R0X__, __R0Y__ = __GTRANSFORM__:inverseTransformPoint(0,0)
			__R1X__, __R1Y__ = __GTRANSFORM__:inverseTransformPoint(wx,wy)
		end
	end

	--------------------------------------------------------------------
	-- Makes the game UI
	TERMINAL:update()
	if not TERMINAL.active then
		ui_maker()
		game({switch='update'})
	end

	--------------------------------------------------------------------
	-- Updates client, host, playlist & particles.

	if Client.link then pcall(Client.link.update, Client.link) end
	if host then
		pcall(host.server.update, host.server)
		if host.destroy and #host.server:getClients() == 0 then
			host.server:destroy()
			host = nil
			collectgarbage('collect')
			TERMINAL:log('Servidor fechado e destruído com sucesso.', {fg='green'})
			TERMINAL:reset_commands()
		end
	end
	background_particles:update(dt)
	confetti_particles:update(dt)
	Playlist:update(dt)

	if Client.waiting_connection then
		Client.connection_timer = Client.connection_timer+dt
		if Client.connection_timer >= 10 then
			print("Client: Cannot connect to the server. || Data: ", 4040)
			assets.audio.ui.c_error:play()

			ui.events.disc_menu = true
			disconnect_code = 4040
			game = function() end
			Client = {data = {user=0, ip=0, userid=0}}
			assets.CAH, assets.UNO = nil, nil

			Chat_data.SLIDER.value = 0
			Chat_data.SCROLL = 0
			Chat_data.INPUT  = {text=''}

			ui.events.wait_screen = false

			collectgarbage('collect')
		end
	end
end


function love.draw()
	love.graphics.push()
	love.graphics.applyTransform(__GTRANSFORM__)
		love.graphics.setColor(1,1,1,1)
		if not TERMINAL.active then
			love.graphics.setDefaultFilter('linear', 'linear', 8)
			local draw = love.graphics.draw
			draw(background_particles, 540, 960)

			if ui.events.menu then
				draw(assets.title, 240, 370)
			end
			game({switch='draw'})
			Head:draw()

			-- Draws music & audio buttons icons.
			-- They appear in every single screen.
			love.graphics.setColor(rgb{32, 32, 32})
			if Local_info.config.music then
				draw(assets.musicOn, __R0X__+140, __R0Y__+20, 0, 1)
			else
				draw(assets.musicOff, __R0X__+140, __R0Y__+20, 0, 1)
			end
			if Local_info.config.audio then
				draw(assets.audioOn, __R0X__+20, __R0Y__+20, 0, 1)
			else
				draw(assets.audioOff, __R0X__+20, __R0Y__+20, 0, 1)
			end
		end
		TERMINAL:draw()
		if Local_info.debug then
			love.graphics.print(love.timer.getFPS()..' FPS', __R0X__+10, __R1Y__-50)
			if Client.link then
				love.graphics.print(Client.link:getRoundTripTime()..'ms', __R0X__+10, __R1Y__-100)
			end
		end
    love.graphics.pop()
end

function love.keypressed(k)
	if k == 'escape' then love.event.quit() end
	Head:keypressed(k)
	Draw.ui:keypressed(k)
	Draw.chat:keypressed(k)
	Draw.chat_input:keypressed(k)
	Draw.selects:keypressed(k)
	Draw.checks:keypressed(k)
	TERMINAL.input_suit:keypressed(k)
end

function love.textinput(t)
	Head:textinput(t)
	Draw.ui:textinput(t)
	Draw.chat:textinput(t)
	Draw.chat_input:textinput(t)
	Draw.selects:textinput(t)
	Draw.checks:textinput(t)
	TERMINAL.input_suit:textinput(t)
end

function love.wheelmoved(x,y)
	Head:wheelmoved(y,y)
	Draw.ui:wheelmoved(y,y)
	Draw.chat:wheelmoved(y,y)
	Draw.chat_input:wheelmoved(y,y)
	Draw.selects:wheelmoved(y,y)
	Draw.checks:wheelmoved(y,y)
	TERMINAL.input_suit:wheelmoved(y,y)
end

function love.touchmoved(_,_,_,dx,dy)
	dx, dy = dx*__GSCALE__/67.5, dy*__GSCALE__/120
	dx = -dx
	Head:wheelmoved(dx,dy)
	Draw.ui:wheelmoved(dx,dy)
	Draw.selects:wheelmoved(dx,dy)
	Draw.checks:wheelmoved(dx,dy)
	Draw.chat:wheelmoved(dx,dy)
	Draw.chat_input:wheelmoved(dx,dy)
	TERMINAL.input_suit:wheelmoved(dx,dy)
end
