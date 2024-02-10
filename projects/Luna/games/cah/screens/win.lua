return function()
	Client.game.draw_cs = {}
	table.insert(Client.game.draw_cs,
					 Games.cah.card({posX=26,posY=340,scale=1,bcard=Client.game.black}))
	table.insert(Client.game.draw_cs,
					 Games.cah.card({posX=554,posY=340,scale=1,wcards=Client.game.wchoice[1].cards, vertical=true}))
	
	if not Client.game.sent then
		local blackColor = {
			normal  = {bg = rgb{32, 32, 32}, fg = rgb{192, 192, 192}},
			hovered = {bg = rgb{32, 32, 32}, fg = rgb{192, 192, 192}},
			active  = {bg = rgb{48, 48, 48}, fg = rgb{228, 228, 228}},
		}
		local send = Draw.selects:Button('Continuar',{cornerRadius=50, color=blackColor, font=fonts.big}, 190, 1720, 700, 100)
		Draw.ui:Label('O ganhador foi '..Client.game.wchoice[1].user..'!', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
		if send.hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			Client.link:send('win_continue',Client.data.userid)
			Client.game.sent = true
		end
	else
		Draw.ui:Label('Aguarde os outros jogadores.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	end
end
