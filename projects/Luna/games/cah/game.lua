local CAH = {}
CAH.cblack = require('games.cah.screens.chooseBlack')
CAH.cwhite = require('games.cah.screens.chooseWhite')
CAH.judge  = require('games.cah.screens.judge')
CAH.win    = require('games.cah.screens.win')
CAH.afk    = require('games.cah.screens.afk')
CAH.card   = require('games.cah.card')
CAH.plist  = require('games.cah.screens.plist')
CAH.make_client = require('games.cah.cah_client')
CAH.make_host   = require('games.cah.cah_host')

CAH.run = function()
	assets.CAH = {
		bcard = love.graphics.newImage('games/cah/assets/Black_front.png'),
		wcard = love.graphics.newImage('games/cah/assets/White_front.png'),
		brasil = love.graphics.newImage('games/cah/assets/Brasil.png'),
		A = love.graphics.newImage('games/cah/assets/A.png'),
		Felps_bombado = love.graphics.newImage('games/cah/assets/Felps_bombado.png'),
		Bolsonaro = love.graphics.newImage('games/cah/assets/Bolsonaro.png'),
		big_card = love.graphics.newImage('games/cah/assets/Big_card.png')
	}
	game = function(arg)
		if arg.switch == 'update' then
			-- Disconenct & List players buttons
			if Draw.ui:Button('', {id='list', cornerRadius=12.5}, __R0X__+20, __R0Y__+140, 100, 100).hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				if Client.game.list_players then
					Client.game.list_players = false
				else
					Client.game.list_players = true
				end
			end

			if Draw.ui:Button('', {id='disconnect', cornerRadius=12.5}, __R1X__-120, __R0Y__+20, 100, 100).hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				Client.link:disconnect(3315)
			end

			if not Client.game.list_players then
				CAH[Client.game.state](arg.switch)
			elseif not Client.game.open_chat then
				CAH.plist()
			else
				Client.game.draw_cs = {}
				CHAT_UI()
				-- Closes the chat
				if Draw.ui:Button('', {id='leave_chat', cornerRadius=12.5}, __R0X__+140, __R0Y__+140, 100, 100).hit then
					assets.audio.ui.click:stop()
					assets.audio.ui.click:play()
					Client.game.open_chat = not Client.game.open_chat
				end
			end
		elseif arg.switch == 'draw' then
			-- If the player list screen is open
			if Client.game.list_players then
				-- Player list background
				love.graphics.setColor(rgb{24,24,24})
				local wx, wy = love.window.getMode()
				local sc = 16/9*wx > wy and wy/1920 or wx/1080
				local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960
				love.graphics.rectangle('fill',0-px,0-py,1080+px*2,1920+py*2)
				love.graphics.setColor(1,1,1)
				-- Chat UI if it is open.
				-- Draws buttons in correct places.
				if Client.game.open_chat then
					CHAT_UI('draw')

					Draw.ui:draw()
					Draw.checks:draw()
					Draw.selects:draw()

					love.graphics.setColor(rgb{32,32,32})
					love.graphics.draw(assets.exitChat, __R0X__+140, __R0Y__+136)
				else
					Draw.ui:draw()
					Draw.checks:draw()
					Draw.selects:draw()

					love.graphics.setColor(rgb{32,32,32})
					love.graphics.draw(assets.openChat, __R0X__+136, __R0Y__+143)
				end
			else
				for i = 1, #Client.game.draw_cs do
					Client.game.draw_cs[i]:draw()
				end
				Draw.ui:draw()
				Draw.checks:draw()
				Draw.selects:draw()
			end
			-- Draws the part of the UI that always appears.
			love.graphics.setColor(rgb{32,32,32})
			love.graphics.draw(assets.exitButton, __R1X__-120, __R0Y__+16, 0, 1)
			love.graphics.draw(assets.players, __R0X__+20, __R0Y__+140, 0, 1)
			-- Notification bubble if new message arrived.
			if Client.data.newMessage then
				love.graphics.setColor(rgb{256,64,64})
				if Client.game.list_players then
					love.graphics.circle('fill', __R0X__+240, __R0Y__+140, 20)
				else
					love.graphics.circle('fill', __R0X__+120, __R0Y__+140, 20)
				end
			end
			love.graphics.setColor(1,1,1,1)
			-- Draws confetti over everything if the player list is not open.
			if not Client.game.list_players then love.graphics.draw(confetti_particles, 540, __R1Y__+80) end
		end
	end
end
return CAH
