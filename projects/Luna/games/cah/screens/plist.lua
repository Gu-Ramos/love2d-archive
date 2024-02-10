return function()
	Client.game.draw_cs = {}
	Draw.ui.layout:reset(20, __R0Y__+260)
	Draw.ui.layout:padding(20,40)
	-- Shows a list of players in the player list screen
	for k, pinfo in pairs(Client.game.players) do
		--[[
		Nome: User-1A2B3C4D
		Vitórias: 000 || Tipo: Jogador || Não está pronto.
		--]]
		local pronto = 'Não está pronto.';
		if pinfo.ready then pronto = 'Está pronto.' end
		
		local tipo = ({player='Jogador || ', judge='Juíz || '})[pinfo.ptype]
		
		Draw.ui:Label(
			string.format('Nome: %-30s\nVitórias: %03d || Tipo: %s %-16s', pinfo.user, pinfo.vcount, tipo, pronto), 
			{align='left', color=UI_COLOR.dark}, Draw.ui.layout:row(1040, 50)
		)
	end
	-- Opens the chat
	if Draw.selects:Button(' ',{id='open_chat',cornerRadius=12.5, font=fonts.big}, __R0X__+140, __R0Y__+140, 100, 100).hit then
		assets.audio.ui.click:stop()
		assets.audio.ui.click:play()
		Client.game.open_chat = true
	end
	
end
