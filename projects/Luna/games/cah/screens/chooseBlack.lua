return function()
	Client.game.draw_cs = {}
	table.insert(Client.game.draw_cs,
				 Games.cah.card({posX=26,posY=340,scale=1,bcard=Client.game.bchoice[1]}))
	table.insert(Client.game.draw_cs,
				 Games.cah.card({posX=554,posY=340,scale=1,bcard=Client.game.bchoice[2]}))
					 
	if Client.game.ptype == 'judge' then
		if Client.game.sent then
			Draw.ui:Label('Aguarde...', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
			return
		else
			Draw.ui:Label('Escolha uma das cartas.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
			-- Black cards checkbox
			Draw.checks.layout:reset(235, 1200)
			Draw.checks.layout:padding(438,0)
			local c1 = Draw.checks:Checkbox(Client.game.choices[1], {cornerRadius=12.5, rbox={x=-207,y=-860,w=500,h=950}}, Draw.checks.layout:col(90, 90))
			local c2 = Draw.checks:Checkbox(Client.game.choices[2], {cornerRadius=12.5, rbox={x=-207,y=-860,w=500,h=950}}, Draw.checks.layout:col())
			-- Unchecks the other option if clicked
			if c1.hit then Client.game.choices[2].checked = not Client.game.choices[1].checked; assets.audio.ui.click:stop(); assets.audio.ui.click:play() end
			if c2.hit then Client.game.choices[1].checked = not Client.game.choices[2].checked; assets.audio.ui.click:stop(); assets.audio.ui.click:play() end
			-- Select button. Only appears if one of the two cards is selected.
			if (Client.game.choices[2].checked or Client.game.choices[1].checked) and
			Draw.selects:Button('Selecionar',{cornerRadius=50, font=fonts.big}, 190, 1500, 700, 100).hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				local sb_card = 1
				if Client.game.choices[2].checked then
					sb_card = 2
				end
				Client.link:send('bchoice', Client.game.bchoice[sb_card])
				Client.game.sent = true
			end
		end
	else
		Draw.ui:Label('Aguarde o juiz escolher uma das cartas.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	end
end
