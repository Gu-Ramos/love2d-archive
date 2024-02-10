local Terminal = setmetatable({}, {__call=function(terminal, ...) return terminal:deal(...) end})

function Terminal:deal(args)
	args = self.getArguments(args)
	local command = args[1]
	table.remove(args, 1)

	local erro, message

	if self.commands[command] then
		erro, message =  pcall(self.commands[command], args)
	elseif self.basecommands[command] then
		erro, message = pcall(self.basecommands[command], args)
	else
		self:log('O comando "'..command..'" não existe.', {bg='red', fg='red'});
		return
	end

	if not erro then
		self:log('ERRO: '..message, {bg='red', fg='red'});
		return erro
	else
		return message
	end
end

Terminal.all_logs = {}

function Terminal:log(log, opt)
	local message = {log=log,opt=opt}
	message = setmetatable(message,
		{__index=Terminal,
		__call=function(msgdata)
			local __index = getmetatable(msgdata).__index;
			local lineSize = #(({fonts.terminal:getWrap(msgdata.log, 940)})[2]) * (fonts.terminal:getHeight() + fonts.terminal:getLineHeight());
			local align    = msgdata.opt and msgdata.opt.align or 'left';
			local fg_color = msgdata.opt and msgdata.opt.fg and __index.colors[msgdata.opt.fg] or __index.colors.white;
			return msgdata.log, align, fg_color, lineSize
		end,

		__tostring=function(msgdata)
			return msgdata.log
		end})
	table.insert(self.logs, message)
	table.insert(self.all_logs, log)
  if #self.logs >= 100 then
    table.remove(self.logs, 1)
  end
	collectgarbage('collect')
end

function Terminal:export_log()
	local lf = love.filesystem
	local dtable = os.date('*t', os.time())
	local time = dtable.year..'-'..dtable.month..'-'..dtable.day..'_'..dtable.hour..'-'..dtable.min..'-'..dtable.sec
	local log, error = lf.newFile('error-log_'..time..'.json', 'w')
	print(error)
	local suc, err = log:write(json.encode(self.all_logs))
	print(suc,err)
	local err = log:close()
	print(err)
	print(lf.getSaveDirectory())
end

function Terminal.getArguments(argstr)
	local argtbl = {}
	for arg, sep in string.gmatch(argstr, "([^;]*)(;?)") do
		table.insert(argtbl, arg)
		if sep == '' then break end
	end
	return argtbl
end

function Terminal:new_game_commands(commands)
	for k, v in pairs(commands) do
		self.commands[k] = v
	end
end

function Terminal:remove_game_commands(name)
	self.commands[name] = nil
	collectgarbage('collect')
end

function Terminal:reset_commands()
	self.commands = {}
	collectgarbage('collect')
end

Terminal.basecommands = {
	help = setmetatable({},
		{__index=Terminal,
		__tostring=function() return 'Mostra os comandos disponíveis ou informação sobre um comando específico.\n     EX: help;close_server' end,
		__call=function(help, args)
			local terminal = getmetatable(help).__index
			local command = args[1]
			if command then
				if terminal.commands[command] then
					terminal:log('  -  '..command..': '..tostring(terminal.commands[command]))
				elseif terminal.basecommands[command] then
					terminal:log('  -  '..command..': '..tostring(terminal.basecommands[command]))
				else
					terminal:log('O comando "'..command..'" não existe.', {fg='red'});
					return
				end
			else
				terminal:log('Comandos base:', {fg='green'})
				for k, v in pairs(terminal.basecommands) do
					terminal:log('  -  '..k..': '..tostring(v))
				end
				terminal:log('Comandos de jogo:', {fg='blue'})
				for k, v in pairs(terminal.commands) do
					terminal:log('  -  '..k..': '..tostring(v))
				end
			end
		end}),

	exit_game = setmetatable({},
	{__index=Terminal,
	__tostring=function() return 'Fecha o jogo.' end,
	__call=function() love.event.quit() end}),

	close_server = setmetatable({},
	{__index=Terminal,
	__tostring=function() return 'Fecha o servidor pelo terminal com um código (numérico) específico.\n     EX: close_server;2000' end,
	__call=function(_, code)
		local terminal = getmetatable(_).__index
		if host then
			terminal:log('Fechando o servidor...', {fg='red'})
			local count = 0
			for key, client in pairs(host.server:getClients()) do
				client:disconnect(code[1] or 2000)
				count = count+1
			end
			terminal:log(count..' Jogadores desconectados.', {fg='red'})
			host.destroy = true
		else
			terminal:log('Você não está hosteando um servidor.', {fg='blue'})
		end
	end}),

	get_debug_info = setmetatable({},
	{__index=Terminal,
	__tostring=function() return 'Mostra diversas informações de debugging.' end,
	__call=function(tbl)
		local terminal = getmetatable(tbl).__index
		terminal:log('FPS: '..love.timer.getFPS())
		terminal:log('Garbage collector: '..collectgarbage('count')..'kb')
		terminal:log('')
		terminal:log('OS: '..love.system.getOS())
		terminal:log('Informações sobre a bateria: '..table.concat({love.system.getPowerInfo()}))
		terminal:log('Número de núcleos do processador: '..love.system.getProcessorCount())
		terminal:log('')
		local width, height = love.window.getMode()
		terminal:log('Tamanho da tela: '..width..'x'..height)
		terminal:log('')
		terminal:log('Jogo atual: '..tostring(client and Client.game and Client.game.name))
		terminal:log('Servidor hosteado: '..tostring(host and host.game.name))
		terminal:log('')
		terminal:log('Música: '..tostring(Local_info.config.music))
		terminal:log('Efeitos: '..tostring(Local_info.config.audio))
	end}),
	ping = setmetatable({},
	{__index=TERMINAL,
	__tostring=function() return 'Testa a conexão com o servidor.\n     EX: ping;testando_conexão' end,
	__call=function(help, args)
		if client and Client.link then
			Client.link:send('ping', 'ping! '..tostring(args[1]))
		else
			TERMINAL:log('Você não está conectado ao servidor...')
		end
	end}),
	toggle_debug = setmetatable({},
	{__index=TERMINAL,
	__tostring=function() return 'Ativa a visualização do FPS e ping.' end,
	__call=function(help, args)
		Local_info.debug = not Local_info.debug
	end}),
}

function Terminal:update()
	if self.termi_suit:Button(' ',{id='open_terminal',cornerRadius=12.5},__R1X__-120,__R0Y__+140,100,100).hit then
		self.active = not self.active
	end
	if self.active then
		self.input_suit:Slider(Chat_data.HEIGHT, {color=UI_COLOR.grayFG, cornerRadius=25}, 140, __R0Y__+20, 780, 100)
		local ch_value = Chat_data.HEIGHT.sv

		self.label_suit.layout:reset(10, 1780-ch_value+self.ui_data.SCROLL*self.ui_data.SLIDER.sv/1000)
		self.label_suit.layout:padding(20, 20)
		self.label_suit.layout:up(940, 40)
		totalLineSize = -60


		for i = #self.logs, 1, -1 do
			local minfo = self.logs[i]
			local msg, align, fg, lineSize = minfo()
			totalLineSize = totalLineSize + lineSize + 20

			local x, y, w, h = self.label_suit.layout:up(940, lineSize)
            if y+h < 250 then break
			elseif y < 1800 then
				self.label_suit:Label(msg, {color=fg, align=align, valign='top', font=fonts.terminal}, x, y, w, h)
			end
		end

		self.ui_data.SCROLL = totalLineSize

		self.input_suit:Slider(self.ui_data.SLIDER, {vertical=true, cornerRadius=25, mscroll=true, keyboard=true}, 960, 320, 100, 1400-ch_value)

		-- Chat input
		local chat_input = self.input_suit:Input(self.ui_data.INPUT, {id='chat_input', cornerRadius=50, font=fonts.terminal}, 20, 1800-ch_value, 920, 100)

		-- Sends the message if it is not empty or only spaces.
		local send_message = self.input_suit:Button(' ', {id='send_message', cornerRadius=50}, 960, 1800-ch_value, 100, 100)
		if send_message.hit or chat_input.submitted then
			self:log('> '..self.ui_data.INPUT.text)
			self:deal(self.ui_data.INPUT.text)
			self.ui_data.INPUT.text = ''
		end
	end
end

function Terminal:draw()
	if self.active then
		local ch_value = Chat_data.HEIGHT.sv
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle('fill',0,0,1080,1920)
		self.label_suit:draw()
		love.graphics.setColor(0.07,0.07,0.07,1)

		local wx, wy = love.window.getMode()
		local sc = 16/9*wx > wy and wy/1920 or wx/1080
		local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960

		love.graphics.rectangle("fill",0-px,0-py,1080+px*2,260+py)
		love.graphics.rectangle("fill",0-px,1780-ch_value,1080+px*2,140+py+ch_value)

		self.input_suit:draw()
		love.graphics.setColor(rgb{32,32,32})
		love.graphics.draw(assets.send, 965, 1800-ch_value)
		love.graphics.setColor(1,1,1,1)
	end
	self.termi_suit:draw()
	love.graphics.setColor(rgb{32, 32, 32})
	love.graphics.draw(assets.terminal, __R1X__-120,__R0Y__+140)
	love.graphics.setColor(1, 1, 1)
end

Terminal.commands = {}
Terminal.logs = {}
Terminal.colors = {
	blue = {
		normal  = {bg = rgb{64, 64, 128}, fg = rgb{96, 96, 228}},
		hovered = {bg = rgb{64, 64, 128}, fg = rgb{96, 96, 228}},
		active  = {bg = rgb{64, 64, 128}, fg = rgb{96, 96, 228}},
	},
	red = {
		normal  = {bg = rgb{128, 64, 64}, fg = rgb{228, 96, 96}},
		hovered = {bg = rgb{128, 64, 64}, fg = rgb{228, 96, 96}},
		active  = {bg = rgb{128, 64, 64}, fg = rgb{228, 96, 96}},
	},
	green = {
		normal  = {bg = rgb{64, 128, 64}, fg = rgb{96, 228, 96}},
		hovered = {bg = rgb{64, 128, 64}, fg = rgb{96, 228, 96}},
		active  = {bg = rgb{64, 128, 64}, fg = rgb{96, 228, 96}},
	},
	white = {
		normal  = {bg = rgb{128, 128, 128}, fg = rgb{228, 228, 228}},
		hovered = {bg = rgb{128, 128, 128}, fg = rgb{228, 228, 228}},
		active  = {bg = rgb{128, 128, 128}, fg = rgb{228, 228, 228}},
	},
}

Terminal.ui_data = {
	SLIDER = setmetatable({min=0, max=1000, rv=0, sv=0, s_factor=2},
						  {__index = function(t, i) return t.rv; end,
						__newindex = function(t, i, v)
							t.rv = v;
							t.sv = t.sv + (t.rv-t.sv)/t.s_factor
						end}),
	SCROLL = 0,
	INPUT  = {text=''}
}

Terminal.label_suit = suit.new()
Terminal.input_suit = suit.new()
Terminal.termi_suit = suit.new()

Terminal.active = false

return Terminal
