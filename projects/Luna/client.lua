function create_client()
	ui.events.wait_screen = true
	Client.data.ip = ui.data.ip.text:gsub(' ', '')
	if ui.data.user.text:gsub(' ', '') == '' or ({ui.data.user.text:gsub(';','')})[2] ~= 0 or #ui.data.user.text > 16 then
		Client.data.user = 'User-'..string.format('%x', tostring(math.random(1,0xffffffff))):upper()
	else
		Client.data.user = ui.data.user.text
	end

	Client.link = sock.newClient(Client.data.ip, 22122)
	Client.waiting_connection = true
	Client.connection_timer = 0

	------------------------------------------------------------------------
	-- Establishing connection

	-- Conexão inicial com o servidor
	-- Ao estabelecer conexão, pede para entrar o servidor com o nome
	-- de usuário.
	Client.link:on("connect", function(data)
		Client.waiting_connection = false
		Client.connection_timer = 0
		TERMINAL:log("Client: Connection established.", {fg='blue'})
		Client.link:send('join', Client.data.user)
		collectgarbage('collect')
		ui.events.wait_screen = false
	end)

	-- Desconectado com o servidor. Destrói toda a informação do cliente
	-- e abre o menu de "disconnected"
	Client.link:on("disconnect", function(data)
		assets.audio.ui.s_exit:play()
		TERMINAL:log("Client: disconnected from the server. || Data: "..data, {fg='blue'})

		-- Deletes client data and moves to the disconnect menu.
		ui.events.disc_menu = true
		disconnect_code = data
		game = function() end
		Client = {data = {user=0, ip=0, userid=0}}
		assets.CAH, assets.UNO = nil, nil

		-- Resets chat slider and input.
		Chat_data.SLIDER.value=0
		Chat_data.SCROLL = 0
		Chat_data.INPUT  = {text=''}

		ui.events.wait_screen = false

		collectgarbage('collect')
	end)

	-- Pedido para entrar no servidor aceito.
	-- Inicia o jogo sendo rodado pelo servidor.
	Client.link:on("join", function(data)
		TERMINAL:log('Client: Joined the server.\n  Data: '..json.encode(data), {fg='blue'})
		Games[data.game.name].make_client(data)
		assets.audio.ui.alert:play()
		collectgarbage('collect')
	end)

	Client.link:on('ping', function(data)
					TERMINAL:log(tostring(data), {fg='blue'})
					Client.link:send('pong', Client.data.user..': pong!')
	               end)

	Client.link:on('pong', function(data)
					TERMINAL:log('Server: pong!', {fg='blue'})
	               end)

	Client.link:connect()
end
