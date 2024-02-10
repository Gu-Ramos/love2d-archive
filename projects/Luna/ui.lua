function game(arg) end
function ui_maker()
	-- This will be in every single screen.
	local audio = Head:Button('', {id='audio',cornerRadius=12.5}, __R0X__+20, __R0Y__+20, 100, 100)
	local music = Head:Button('', {id='music',cornerRadius=12.5}, __R0X__+140, __R0Y__+20, 100, 100)
	if audio.hit then
		Local_info.config.audio = not Local_info.config.audio
		assets.audio.ui.click:stop()
		assets.audio.ui.click:play()
		if Local_info.config.audio then
			assets.audio.ui.click:setVolume(0.8)
			assets.audio.ui.c_error:setVolume(0.5)
			assets.audio.ui.s_exit:setVolume(0.5)
			assets.audio.ui.alert:setVolume(0.5)
			assets.audio.ui.victory:setVolume(0.8)
		else
			for _, v in pairs(assets.audio.ui) do v:setVolume(0); end
		end
	end
	if music.hit then
		Local_info.config.music = not Local_info.config.music
		assets.audio.ui.click:stop()
		assets.audio.ui.click:play()
		if Local_info.config.music then
			Playlist:unmute()
		else
			Playlist:mute()
		end
	end
	
	---------------------------------------------------------------------
	-- Wait screen
	if ui.events.wait_screen then
		Head.layout:reset(240,910)
		Head:Label('Aguarde...', {align='center', color=UI_COLOR.dark}, Head.layout:row(600,100))
	end
	
	---------------------------------------------------------------------
	-- Disconnect menu
	if ui.events.disc_menu then
		Head.layout:reset(240,850)
		Head.layout:padding(20,20)
		
		-- Códigos de disconnect:
		--  - 9999: Servidor cheio.
		--  - 6000: Você foi expulso do servidor.
		--  - 3315: Você saiu do servidor // o servidor te desconectou.
		--  - 2000: O servidor foi fechado.
		--  - 1600: O pedido de conexão não foi aceito.
		--  - 4040: Connection timeout
		--  -    0: "putaqpariu sei não"
		Head:Label('Você foi desconectado do servidor.\nCódigo: '..tostring(disconnect_code), {align='center', color=UI_COLOR.dark}, Head.layout:row(600,100))
		
		-- Te leva de volta ao menu.
		local play_button = Head:Button("Ok", {cornerRadius=50}, Head.layout:row(600,100))
		if play_button.hit then
			Chat_data.messages = {}
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			ui.events.disc_menu = false
			ui.events.menu = true
		end
	
	---------------------------------------------------------------------
	-- Main menu
	elseif not ui.events.host and ui.events.menu then
		Head.layout:reset(240,670)
		Head.layout:padding(20,20)
		
		-- Botão de jogar.
		-- Tenta conectar o cliente no ip "ui.data.ip.text".
		-- O nome de usuário é o escolhido pelo jogador se ele não tiver
		-- mais de 30 caracteres, não for uma string vazia,
		-- ou não for composto exclusivamente de espaços.
		local play_button = Head:Button("Jogar", {cornerRadius=50}, Head.layout:row(600,100))
		if play_button.hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			ui.events.menu = false
			create_client()
		end
		
		-- Input de IP
		Head:Label('Digite o endereço de IP a se conectar.', {align='center', color=UI_COLOR.dark}, Head.layout:row(600,40))
		Head:Input(ui.data.ip, {cornerRadius=50}, Head.layout:row(600,100))
		
		-- Input de USERNAME
		Head:Label('Digite o seu nome de usuário.', {align='center', color=UI_COLOR.dark}, Head.layout:row(600,40))
		Head:Input(ui.data.user, {cornerRadius=50, limit=16}, Head.layout:row(600,100))
		
		-- Botão de fechar o servidor.
		-- Aparece apenas se você estiver hosteando um servidor.
		-- Quando clicado, desconecta todos os clientes com o código 2000,
		-- e espera todos desconectarem antes de destruir o servidor.
		if host then
			if Head:Button("Fechar o servidor", {cornerRadius=50}, Head.layout:row()).hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				TERMINAL:log('Fechando o servidor...', {fg='red'})
				local count = 0
				for key, client in pairs(host.server:getClients()) do
					client:disconnect(2000)
					count = count+1
				end
				TERMINAL:log(count..' Jogadores desconectados.', {fg='red'})
				host.destroy = true
			end
			
		-- Botão de hostear um servidor.
		-- Te leva ao menu de hosting.
		else
			local host_button = Head:Button("Hostear uma partida", {cornerRadius=50}, Head.layout:row())
			if host_button.hit then
				assets.audio.ui.click:stop()
				assets.audio.ui.click:play()
				ui.events.host = true
				ui.events.menu = false
			end
		end
	---------------------------------------------------------------------
	-- Hosting menu
	elseif ui.events.host then
		Head.layout:reset(240,790)
		Head.layout:padding(20,20)
		
		-- Botão de hostear um servidor + botão de participar do jogo.
		-- Abre um servidor na porta 22122 para outros jogadores na mesma
		-- rede se conectarem.
		-- Se a checkbox de participar do jogo estiver ativada, ele cria
		-- um cliente no localhost na porta 22122 e conecta o jogador
		-- ao servidor criado.
		local play_button = Head:Button("Hostear", {cornerRadius=50}, Head.layout:row(600,100))
		local chk = Head:Checkbox(ui.data.host_check, {cornerRadius=50, t_color=UI_COLOR.dark}, Head.layout:row())
		if chk.hit then assets.audio.ui.click:stop(); assets.audio.ui.click:play() end
		if play_button.hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			ui.events.host = false
			Games.cah.make_host()
			Client.hosting = true
			if ui.data.host_check.checked then
				ui.events.menu = false
				ui.data.ip.text = 'localhost'
				create_client()
				ui.data.ip.text = '172.24.0.0'
			else
				ui.events.menu = true
			end
		end
		
		local back_button = Head:Button("Voltar", {cornerRadius=50}, Head.layout:row())
		if back_button.hit then
			assets.audio.ui.click:stop()
			assets.audio.ui.click:play()
			ui.events.host = false
			ui.events.menu = true
		end
	end
end
