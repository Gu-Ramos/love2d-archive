return function()
	Client.game.draw_cs = {}
	local checks = {}
	local pick = Client.game.black.pick
	local card_size = (340*pick+40)
	table.insert(Client.game.draw_cs,
					 Games.cah.card({bcard=Client.game.black, posX=290, posY=270, scale=1}))
	
	local wx, wy = love.window.getMode()
	local sc = 16/9*wx > wy and wy/1920 or wx/1080
	local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960
	
	for i = 1, #Client.game.wchoice do
		local cardX = 22 + (i-1)*card_size - Client.game.slider.sv/10*card_size
		if cardX < -px-(340*pick) or cardX > 1080+px then
			goto continue
		end
		
		
		table.insert(Client.game.draw_cs,
					 Games.cah.card({wcards=Client.game.wchoice[i].cards, posX=cardX, posY=1100, scale=2/3, card_num=card_id}))
		
		
		::continue::
		if Client.game.ptype == 'judge' and not Client.game.sent then
			table.insert(checks,
						 Draw.checks:Checkbox(Client.game.choices[i],
						{color=UI_COLOR.dark, cornerRadius=12.5, rbox={x=0,y=-475,w=card_size-40+25,h=800/3*2+25}}, cardX-25, 1575, 75, 75))
		end
	end
	
	Draw.selects:Slider(Client.game.slider, {color=UI_COLOR.grayFG, cornerRadius=12.5, var=Client.game.slider.sv, mscroll=true}, 90, 1680, 900, 50)
	
		
	if Client.game.ptype == 'judge' and not Client.game.sent then
		Draw.ui:Label('Escolha a melhor resposta.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
		local check_count = 0
		local chosen = 1
		for c = 1, #Client.game.choices do
			if Client.game.choices[c].checked then
				check_count = check_count+1
				chosen = c
			end
		end
		if check_count == 1 and Draw.selects:Button('Selecionar',{cornerRadius=50, font=fonts.big}, 190, 1770, 700, 100).hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			Client.game.sent = true
			Client.link:send('judged', Client.game.wchoice[chosen])
		end
		
		for i = 1, #checks do
			if checks[i].hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				for c = 1, #Client.game.choices do
					if c ~= i then Client.game.choices[c].checked = false end
				end
				break
			end
		end
		
	elseif Client.game.ptype == 'judge' then
		Draw.ui:Label('Aguarde...', {valign='top', align='center', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	else
		Draw.ui:Label('Aguarde o juiz escolher a melhor resposta.', {align='center', valign='top', font=fonts.big, color=UI_COLOR.dark}, 190, 140, 700, 100)
	end
end
