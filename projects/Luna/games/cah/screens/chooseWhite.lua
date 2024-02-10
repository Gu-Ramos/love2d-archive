return function()
	local pick = Client.game.black.pick
	Client.game.draw_cs = {}

	table.insert(Client.game.draw_cs,
				 Games.cah.card({bcard=Client.game.black, posX=290, posY=270, scale=1}))

	local checks = {}

	local wx, wy = love.window.getMode()
	local sc = 16/9*wx > wy and wy/1920 or wx/1080
	local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960

	for i = 1, 10 do
		local cardX = 25+(i-1)*380-Client.game.slider.sv*390
		local card_id
		if cardX < -px-334 or cardX > 1080+px then goto continue; end


		-- Checks if the card is chosen and assigns its card number
		for c = 1, #Client.game.wchoice do
			card_id = Client.game.wchoice[c].id == i and c
			if card_id then break end
		end
		table.insert(Client.game.draw_cs,
					 Games.cah.card({wcards={Client.game.cards[i]}, posX=cardX, posY=1100, scale=2/3, card_num=card_id}))


		::continue::
		if Client.game.ptype == 'player' and not Client.game.sent then
			table.insert(checks,
						 Draw.checks:Checkbox(Client.game.choices[i],
						 {color=UI_COLOR.dark, cornerRadius=12.5, rbox={x=0,y=-475,w=500/3*2+25,h=800/3*2+25}}, cardX-25, 1575, 75, 75))
		end
	end

	Draw.selects:Slider(Client.game.slider, {color=UI_COLOR.grayFG, cornerRadius=12.5, var=Client.game.slider.sv, mscroll=true}, 90, 1680, 900, 50)

	-- Labels and send button
	-- Send button only appears if wchoice == pick number
	if Client.game.ptype == 'player' and not Client.game.sent then
		local plural = {'uma carta.', 'duas cartas.', 'três cartas.'}
		Draw.ui:Label('Escolha '..plural[pick], {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
		if #Client.game.wchoice == pick and Draw.selects:Button('Selecionar',{cornerRadius=50, font=fonts.big}, 190, 1770, 700, 100).hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			Client.game.sent = true
			local wchoices = {user=Client.data.user,cards={},userid=Client.data.userid}
			for k, v in pairs(Client.game.wchoice) do
				table.insert(wchoices.cards, v[1])
				table.insert(Client.game.used_cards, v.id)
			end
			Client.link:send('wchosen', wchoices)
		end

		-- Adds//Removes cards from the choices.
		for i = 1, 10 do
			if checks[i].hit and Client.game.choices[i].checked then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				table.insert(Client.game.wchoice, {Client.game.cards[i], id=i})
				-- Unchecks first card if check count is higher than pick number
				if (#Client.game.wchoice > pick) and Client.game.choices[Client.game.wchoice[1].id] then
					Client.game.choices[Client.game.wchoice[1].id].checked = false
					table.remove(Client.game.wchoice, 1)
				end
				break
			elseif checks[i].hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				-- Unchecks selected card
				for c = 1, #Client.game.wchoice do
					if Client.game.wchoice[c].id == i then
						table.remove(Client.game.wchoice, c)
						break
					end
				end
				break
			end
		end

	elseif Client.game.ptype == 'player' then
		Draw.ui:Label('Aguarde os outros jogadores.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	else
		Draw.ui:Label('Aguarde os jogadores escolherem as cartas.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	end
end
