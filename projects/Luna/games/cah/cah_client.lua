--[[
game = {
	name = '',
	state = 'afk', -- cblack, cwhite, judge, win, afk
	ptype = 'judge',
	cards = {1,2,3,4,5,6,7,8,9,10},
	black = {pick=3, text=''},
	bchoice = {{text='',pick=1},{text='',pick=1}},
	wchoice = { {user='',cards={1,2,3}} },
	choices = {},
	draw_cs = {},
	slider  = {min=0,value=0,max=7.15},
	players = {},
	used_cards = {}
},

for c = 1, 10 do
	table.insert(Client.game.choices, {checked=false})
end
--]]

return function(data)
Client.game = {}
Client.game.slider = setmetatable({min=0, max=7.15, rv=0, sv=0, s_factor=3},
								{__index = function(t, i) return t.rv; end,
								__newindex = function(t, i, v)
									t.rv = v;
									t.sv = t.sv + (t.rv-t.sv)/t.s_factor
								end})
Client.game.used_cards  = {}
Client.game.draw_cs = {}
Client.game.choices = {}

for c = 1, 10 do table.insert(Client.game.choices, {checked=false}) end

Client.data.userid  = data.data.userid
Client.game.name    = data.game.name
Client.game.state   = data.game.state
Client.game.ptype   = data.game.ptype
Client.game.cards   = data.game.cards
Client.game.black   = data.game.black
Client.game.bchoice = data.game.bchoice
Client.game.wchoice = data.game.wchoice
Client.game.players = data.game.players
Chat_data.messages  = data.game.chat_messages

Games.cah.run()

------------------------------------------------------------------------
-- Game events
Client.link:on('change_screen', function(data)
	TERMINAL:log('Client: Changing screens. || Data: '..json.encode(data), {fg='blue'})
	Client.game.state = data.screen
	Client.data.ready = false
	Client.game.sent = false
	Client.game.slider.value = 0
	Client.game.black = data.black or Client.game.black
	Client.game.wchoice = data.wchoice or Client.game.wchoice
	Client.game.bchoice = data.bchoice or Client.game.bchoice
	if data.screen == 'judge' then
		Client.game.choices = {}
		for c = 1, #data.wchoice do
			table.insert(Client.game.choices, {checked=false})
		end
		Client.game.slider.max = (#Client.game.wchoice-1)*10
	else
		Client.game.choices = {}
		for c = 1, 10 do
			table.insert(Client.game.choices, {checked=false})
		end
	end
	if data.screen == 'win' then
		assets.audio.ui.victory:play()
		confetti_particles:emit(500)
	elseif data.screen == 'cblack' then
		assets.audio.ui.alert:play()
	elseif data.screen == 'cwhite' then
		Client.game.slider.max = 7
	end
	collectgarbage('collect')
end)


-- Changes player type after win screen or the other
-- judge left the server.
Client.link:on('change_type', function(data)
				Client.game.ptype = data
				TERMINAL:log("Client: Changing player type.\n  Data: "..json.encode(data), {fg='blue'})
				collectgarbage('collect')
				end)


-- Gets new cards from the server after the win screen
-- or after a judge lefts the server.
Client.link:on('card_update', function(data)
				TERMINAL:log("Client: Cards updated.\n   Old: "..json.encode(Client.game.used_cards)..'\n   New: '..json.encode(data), {fg='blue'})
				if #Client.game.used_cards > 0 then
					for k, v in pairs(data) do
						local card = Client.game.used_cards[k]
						Client.game.cards[card] = v
					end
				end
				Client.game.used_cards = {}
				collectgarbage('collect')
				end)


Client.link:on('update_player_list', function(data)
				TERMINAL:log('Client: player list updated.\n  Data: '..json.encode(data), {fg='blue'})
				Client.game.players = data
				end)


Client.link:on('update_chat', function(data)
				if not (Client.game.open_chat and Client.game.list_players) then Client.data.newMessage = true; end
				Chat_data.messages = data
				end)
end
