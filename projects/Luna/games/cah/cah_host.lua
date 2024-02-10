local function pick_new(t,n)
	::retry::
	local cards = {}
	if t == 1 then
		cards = chance.helpers.pick_unique(Games.cah.pt_cards.white, n)
		for _, card in ipairs(cards) do if host.wpile[card] then goto retry end; end
		for _, card in ipairs(cards) do host.wpile[card] = true; end
		if #host.wpile >= 1000 then host.wpile = {}; collectgarbage('collect'); end
	else
		cards = chance.helpers.pick_unique(Games.cah.pt_cards.black, n)
		for _, card in ipairs(cards) do if host.bpile[card.text] then goto retry end; end
		for _, card in ipairs(cards) do host.bpile[card.text] = true; end
		if #host.bpile >= 500 then host.bpile = {}; collectgarbage('collect'); end
	end
	return cards
end

return function()
	host = {
		server = sock.newServer("*", 22122),
		clients = {},
		game = {
				name  = 'cah',
				state = 'cblack',
				black = {pick=1, text=''},
				wchoice = {},
				b_players_list = {},
				chat_messages = {}
	            },
		wpile = {},
		bpile = {}
	}
	host.game.bchoice = pick_new(2,2)

	local comandos = {list_players_id = setmetatable({},
	{__index=TERMINAL,
	__tostring=function() return 'Mostra o ID secreto dos jogadores na partida.' end,
	__call=function(help, args)
		for k, v in pairs(host.clients) do
			TERMINAL:log(v.data.user..' --> '..k, {fg='blue'})
		end
	end}),
	kick = setmetatable({},
	{__index=TERMINAL,
	__tostring=function() return 'Expulsa um jogador da partida com seu ID secreto.\n     EX: kick;13B0FD30' end,
	__call=function(help, args)
		if host.clients[args[1]] then
			TERMINAL:log('O jogador '..host.clients[args[1]].data.user..' foi expulso da partida.', {fg='green'})
			host.clients[args[1]].data.client:disconnect(6000)
		else
			TERMINAL:log('Não existe um jogador com o ID '..args[1]..' nesta partida.', {fg='red'})
		end
	end}),
	sping = setmetatable({},
	{__index=TERMINAL,
	__tostring=function() return 'Testa a conexão do servidor com os jogadores.\n     EX: ping;testando_conexão' end,
	__call=function(help, args)
		host.server:sendToAll('ping', 'ping! '..tostring(args[1]))
	end}),
	}
	TERMINAL:new_game_commands(comandos)

	host.bpile[host.game.bchoice[1].text], host.bpile[host.game.bchoice[2].text] = true, true
	-- Conexão inicial com o servidor.
	host.server:on('connect', function(data, client)
		TERMINAL:log('Server: New connection established.', {fg='red'});
	end)

	-- Pedido para entrar no servidor.
	-- Dado esperado: string com o nome de usuário.
	host.server:on('join', function(username, client)
		TERMINAL:log('Server: Join request received. || Data: '..json.encode(username), {fg='red'});
		if type(username) == 'string' and not (ui.data.user.text:gsub(' ', '') == '' or ({ui.data.user.text:gsub(';','')})[2] ~= 0 or #ui.data.user.text > 16) then
			-- Gera um ID aleatório para o jogador.
			-- ID: número aleatório entre 0 e 2^32 (0xffffffff)
			local ID = tostring(math.random(0, 0xffffffff));


			-- Se o jogador for o primeiro a entrar no servidor,
			-- ele será o juíz, se não, ele será um player normal.
			local ptype = 'player'
			if len(host.clients) == 0 then ptype = 'judge' end

			-- Enviando ao jogador uma table com suas informações.
			local pcards = pick_new(1, 10)
			local players = {}
			for p_id, client in pairs(host.clients) do
				players[p_id] = {user=client.data.user,
								 ready=client.data.ready,
								 ptype=client.game.ptype}
			end

			local cdata = {
				data = {user=username, userid=ID, ready=false, victory_count=0},
				game = {
	                    name    = host.game.name,
						state   = host.game.state,
						ptype   = ptype,
						cards   = pcards,
						black   = host.game.black,
						bchoice = host.game.bchoice,
						wchoice = host.game.wchoice,
						players = players,
						chat_messages = host.game.chat_messages
						}
					}

			client:send('join', cdata);
			-- Armazenando informações do jogador.
			host.clients[ID] = cdata;
			host.clients[ID].data.client = client
			table.insert(host.game.b_players_list, ID)
			local all_players = {}
			for k, v in pairs(host.clients) do
				all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
			end
			host.server:sendToAll('update_player_list', all_players)
			TERMINAL:log('Server: '..username..' joined the game.\n        ID: '..tostring(ID)..' || username: '..username..' || ptype: '..ptype, {fg='red'});

			local msg = {user='Server',message=host.clients[ID].data.user..' entrou no servidor.',userid='SERVER'}
			table.insert(host.game.chat_messages, msg)
			host.server:sendToAll('update_chat', host.game.chat_messages)
		else
			-- Se tiver problema com o nome do jogador manda toma no cu.
			client:disconnect(1600)
			TERMINAL:log('        Join request denied. || Data: '..tostring(username), {fg='red'})
		end
	end)

	-- Avisa quando um jogador sai do servidor.
	host.server:on('disconnect', function(data)
		TERMINAL:log('Server: A client disconnected from the server.', {fg='red'})
		for id, plyr in pairs(host.clients) do
			if plyr.data.client:getState() == 'disconnected' then
				local ptype = plyr.game.ptype
				for k, v in pairs(host.game.b_players_list) do
					if v == id then
						table.remove(host.game.b_players_list, k)
					end
				end

				local msg = {user='Server',message=plyr.data.user..' saiu do servidor.',userid='SERVER'}
				table.insert(host.game.chat_messages, msg)
				host.server:sendToAll('update_chat', host.game.chat_messages)

				host.clients[id] = nil
				if len(host.clients) == 0 then return end
				if ptype == 'judge' then
					local randplyr = host.game.b_players_list[math.random(1, #host.game.b_players_list)]

					host.clients[randplyr].data.client:send('change_type', 'judge')
					host.clients[randplyr].game.ptype = 'judge'
					host.game.wchoice={}
					local blkChoice = pick_new(2, 2)
					host.game.bchoice = blkChoice
					host.server:sendToAll('change_screen',
										{screen='cblack',
										bchoice=blkChoice,
										wchoice={}})
					for k, client in pairs(host.clients) do
						local whiChoice = pick_new(1, host.game.black.pick)
						client.data.client:send('card_update', whiChoice)
					end
					for k, v in pairs(host.clients) do
						v.data.ready = false
					end
					host.game.state = 'cblack'
				end
			end
		end
		local all_players = {}
		for k, v in pairs(host.clients) do
			all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
		end
		host.server:sendToAll('update_player_list', all_players)

		if host.game.state == 'cwhite' then
			local ready_count = 0
			local player_count = 0
			for k, v in pairs(host.clients) do
			if v.game.state ~= 'afk' then
				player_count = player_count+1
					if v.data.ready or v.game.ptype == 'judge' then
						ready_count = ready_count+1
					end
				end
			end
			if player_count == ready_count then
				host.game.state = 'judge'
				host.server:sendToAll('change_screen',
										{screen='judge', wchoice=host.game.wchoice})
				TERMINAL:log("All players ready. Changing screen.",{fg='red'})
			end
			local all_players = {}
			for k, v in pairs(host.clients) do
				all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
			end
			host.server:sendToAll('update_player_list', all_players)
		elseif host.game.state == 'win' then
			local player_count = 0
			local ready_count = 0
			for k, v in pairs(host.clients) do
				if v.game.state ~= 'afk' then
					player_count = player_count+1
					if v.data.ready then
						ready_count = ready_count+1
					end
				end
			end
			if player_count == ready_count then
				for c = 1, #host.game.b_players_list do
					local plyr = host.game.b_players_list[c]
					local nxtplyr = host.game.b_players_list[c+1] or host.game.b_players_list[1]
					if host.clients[plyr].game.ptype == 'judge' then
						host.clients[plyr].data.client:send('change_type', 'player')
						host.clients[plyr].game.ptype = 'player'
						host.clients[nxtplyr].data.client:send('change_type', 'judge')
						host.clients[nxtplyr].game.ptype = 'judge'
						break
					end
				end
				host.game.wchoice={}
				local blkChoice = pick_new(2,2)

				host.game.bchoice = blkChoice
				host.server:sendToAll('change_screen',
										{screen='cblack',
										bchoice=blkChoice,
										wchoice={}})
				TERMINAL:log("All players ready. Changing screen.",{fg='red'})
				for k, client in pairs(host.clients) do
					local whiChoice = pick_new(1,host.game.black.pick)
					client.data.client:send('card_update', whiChoice)
				end
				for k, v in pairs(host.clients) do
					v.data.ready = false
				end
				host.game.state = 'cblack'
			end
			local all_players = {}
			for k, v in pairs(host.clients) do
				all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
			end
			host.server:sendToAll('update_player_list', all_players)
		end

		collectgarbage('collect')
	end)

	host.server:on('bchoice', function(data)
	               host.game.black = data
	               host.game.state = 'cwhite'
				   host.server:sendToAll('change_screen',
	                                     {screen='cwhite',black=data})
				   TERMINAL:log('Server: Black card received. Changing screen.',{fg='red'})
				   TERMINAL:log('        Black card:'..json.encode(data),{fg='red'})
				   local all_players = {}
				   for k, v in pairs(host.clients) do
					   all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
				   end
				   host.server:sendToAll('update_player_list', all_players)
				   collectgarbage('collect')
	               end)

	host.server:on('wchosen', function(data)
					host.clients[data.userid].data.ready=true
					table.insert(host.game.wchoice, data)
					TERMINAL:log('Server: White cards received.\n  Data: '..json.encode(data),{fg='red'})
					local ready_count = 0
					local player_count = 0
					for k, v in pairs(host.clients) do
						if v.game.state ~= 'afk' then
							player_count = player_count+1
							if v.data.ready or v.game.ptype == 'judge' then
								ready_count = ready_count+1
							end
						end
					end
					if player_count == ready_count then
						host.game.state = 'judge'
						host.server:sendToAll('change_screen',
											  {screen='judge', wchoice=host.game.wchoice})
						TERMINAL:log("All players ready. Changing screen.",{fg='red'})
					end
					local all_players = {}
					for k, v in pairs(host.clients) do
						all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
					end
					host.server:sendToAll('update_player_list', all_players)
					collectgarbage('collect')
					end)

	host.server:on('judged', function(data)
					host.game.wchoice = {data}
					if host.clients[data.userid] then
						host.clients[data.userid].data.victory_count = host.clients[data.userid].data.victory_count + 1
					end
					host.server:sendToAll('change_screen',
	                                      {screen='win', wchoice=host.game.wchoice})
					TERMINAL:log('Server: Judge choice received. Changing screen.\n  Data: '..json.encode(data),{fg='red'})
					for k, v in pairs(host.clients) do
						v.data.ready = false
						host.game.state = 'win'
					end
					local all_players = {}
					for k, v in pairs(host.clients) do
						all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
					end
					host.server:sendToAll('update_player_list', all_players)
					collectgarbage('collect')
	              end)

	host.server:on('win_continue', function(data)
					host.clients[data].data.ready = true
					local player_count = 0
					local ready_count = 0
					for k, v in pairs(host.clients) do
						if v.game.state ~= 'afk' then
							player_count = player_count+1
							if v.data.ready then
								ready_count = ready_count+1
							end
						end
					end
					if player_count == ready_count then
						for c = 1, #host.game.b_players_list do
							local plyr = host.game.b_players_list[c]
							local nxtplyr = host.game.b_players_list[c+1] or host.game.b_players_list[1]
							if host.clients[plyr].game.ptype == 'judge' then
								host.clients[plyr].data.client:send('change_type', 'player')
								host.clients[plyr].game.ptype = 'player'
								host.clients[nxtplyr].data.client:send('change_type', 'judge')
								host.clients[nxtplyr].game.ptype = 'judge'
								break
							end
						end
						host.game.wchoice={}
						local blkChoice = pick_new(2,2)
						host.game.bchoice = blkChoice
						host.server:sendToAll('change_screen',
											 {screen='cblack',
											  bchoice=blkChoice,
	                                          wchoice={}})
						TERMINAL:log("All players ready. Changing screen.",{fg='red'})
						for k, client in pairs(host.clients) do
							local whiChoice = pick_new(1, host.game.black.pick)
							client.data.client:send('card_update', whiChoice)
						end
						for k, v in pairs(host.clients) do
							v.data.ready = false
						end
						host.game.state = 'cblack'
					end
					local all_players = {}
					for k, v in pairs(host.clients) do
						all_players[k] = {user=v.data.user,ptype=v.game.ptype,ready=v.data.ready,vcount=v.data.victory_count}
					end
					host.server:sendToAll('update_player_list', all_players)

					if len(host.bpile) >= 200 then host.bpile = {} end
					if len(host.wpile) >= 500 then host.wpile = {} end
					collectgarbage('collect')
	               end)

	host.server:on('chat_message', function(data)
					table.insert(host.game.chat_messages, data)
                    if #host.game.chat_messages >= 100 then
						table.remove(host.game.chat_messages, 1)
					end
					host.server:sendToAll('update_chat', host.game.chat_messages)
	               end)

	host.server:on('pong', function(data, client)
					TERMINAL:log(tostring(data), {fg='red'})
                   end)

	host.server:on('ping', function(data, client)
					TERMINAL:log(tostring(data), {fg='red'})
					client:send('pong', 'pong!')
	               end)
end

