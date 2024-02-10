------------------------------------------------------------------------
-- Loading essentials
math.randomseed(os.time())
for c = 1, math.random(100, 1000) do
	math.random(1, 0xffffffff)
end
rgb = function(colors)
	return {colors[1]/255, colors[2]/255, colors[3]/255, colors[4] and colors[4]/255}
end
Rng = love.math.newRandomGenerator(os.time())
Classic = require('libs.classic')
suit    = require('suit')
sock    = require('libs.sock')
chance  = require('libs.chance')
json    = require('libs.json')
CHAT_UI = require('libs.chat')
TERMINAL = require('libs.terminal')
require('client')
require('ui')

Games = {}
Games.cah = require('games.cah.game')

UI_COLOR = {
	base = {
		normal  = {bg = rgb{256, 256, 256}, fg = rgb{32, 32, 32}},
		hovered = {bg = rgb{256, 256, 256}, fg = rgb{32, 32, 32}},
		active  = {bg = rgb{192, 192, 192}, fg = rgb{48, 48, 48}}
	},
	grayFG = {
		normal  = {bg = rgb{192, 192, 192}, fg = rgb{64, 64, 64}},
		hovered = {bg = rgb{192, 192, 192}, fg = rgb{64, 64, 64}},
		active  = {bg = rgb{228, 228, 228}, fg = rgb{96, 96, 96}},
	},
	blueFG = {
		normal  = {bg = rgb{192, 192, 192}, fg = rgb{128, 128, 228}},
		hovered = {bg = rgb{192, 192, 192}, fg = rgb{128, 128, 228}},
		active  = {bg = rgb{228, 228, 228}, fg = rgb{128, 128, 228}},
	},
	SERVER = {
		normal  = {bg = rgb{192, 192, 192}, fg = rgb{228, 128, 128}},
		hovered = {bg = rgb{192, 192, 192}, fg = rgb{228, 128, 128}},
		active  = {bg = rgb{228, 228, 228}, fg = rgb{228, 128, 128}},
	},
	dark = {
		normal  = {bg = rgb{32, 32, 32}, fg = rgb{192, 192, 192}},
		hovered = {bg = rgb{32, 32, 32}, fg = rgb{192, 192, 192}},
		active  = {bg = rgb{48, 48, 48}, fg = rgb{228, 228, 228}},
	},
	light = {
		normal  = {bg = rgb{192, 192, 192}, fg = rgb{32, 32, 32}},
		hovered = {bg = rgb{192, 192, 192}, fg = rgb{32, 32, 32}},
		active  = {bg = rgb{228, 228, 228}, fg = rgb{48, 48, 48}}
	},
	__bgc = {1,1,1,1}
}
suit.transformObj = __GTRANSFORM__
suit.theme.color = UI_COLOR.base

Head = suit.new()

function len(array)
	local lenght = 0
	for k, v in pairs(array) do
		lenght = lenght+1
	end
	return lenght
end

------------------------------------------------------------------------
-- Loading assets
fonts = {
	small  = love.graphics.newFont('assets/fonts/Ubuntu-Medium.ttf', 34),
	medium = love.graphics.newFont('assets/fonts/Ubuntu-Medium.ttf', 50),
	big    = love.graphics.newFont('assets/fonts/Ubuntu-Bold.ttf', 60),

	card   = love.graphics.newFont('assets/fonts/Ubuntu-Medium.ttf', 45),
	cardi  = love.graphics.newFont('assets/fonts/Ubuntu-MediumItalic.ttf', 45),
	cardb  = love.graphics.newFont('assets/fonts/Ubuntu-Bold.ttf', 45),
	cardbi = love.graphics.newFont('assets/fonts/Ubuntu-BoldItalic.ttf', 45),
	cardl  = love.graphics.newFont('assets/fonts/Ubuntu-Light.ttf', 45),
	cardli = love.graphics.newFont('assets/fonts/Ubuntu-LightItalic.ttf', 45),
	cardm  = love.graphics.newFont('assets/fonts/UbuntuMono-Regular.ttf', 45),
	cardsw = love.graphics.newFont('assets/fonts/Sw-Regular.ttf', 45),

	chat     = love.graphics.newFont('assets/fonts/Comfortaa-Bold.ttf', 34),
	terminal = love.graphics.newFont('assets/fonts/UbuntuMono-Regular.ttf',36)
}
love.graphics.setFont(fonts.small)

assets = {
	audioOn    = love.graphics.newImage('assets/ui/audioOn.png'),
	audioOff   = love.graphics.newImage('assets/ui/audioOff.png'),
	musicOn    = love.graphics.newImage('assets/ui/musicOn.png'),
	musicOff   = love.graphics.newImage('assets/ui/musicOff.png'),
	exitButton = love.graphics.newImage('assets/ui/exitLeft.png'),
	openChat   = love.graphics.newImage('assets/ui/barsHorizontal.png'),
	exitChat   = love.graphics.newImage('assets/ui/exitRight.png'),
	players    = love.graphics.newImage('assets/ui/multiplayer.png'),
	send       = love.graphics.newImage('assets/ui/send.png'),
	terminal   = love.graphics.newImage('assets/ui/terminal.png'),

	particle = love.graphics.newImage('assets/others/particle.png'),
	title    = love.graphics.newImage('assets/others/title.png')
}

assets.audio = {
	ui = {
			click   = love.audio.newSource('assets/audio/ui/click.ogg', 'static'),
			c_error = love.audio.newSource('assets/audio/ui/error.ogg', 'static'),
			s_exit  = love.audio.newSource('assets/audio/ui/exit.ogg', 'static'),
            alert   = love.audio.newSource('assets/audio/ui/alert.ogg', 'static'),
			victory = love.audio.newSource('assets/audio/ui/victory.ogg', 'static')
			}
}


assets.audio.ui.click:setVolume(0.8)
assets.audio.ui.c_error:setVolume(0.5)
assets.audio.ui.s_exit:setVolume(0.5)
assets.audio.ui.alert:setVolume(0.5)
assets.audio.ui.victory:setVolume(0.8)

background_particles = love.graphics.newParticleSystem(assets.particle, 500)
background_particles:setEmissionRate(20)
background_particles:setEmissionArea('normal', 1080, 1920)
background_particles:setLinearAcceleration(15, 30, -15, -15)
background_particles:setParticleLifetime(10, 15)
background_particles:setRotation(-45*math.pi/180, 45*math.pi/180)
background_particles:setColors(1, 1, 1, 0,
							   1, 1, 1, 0.8,
							   1, 1, 1, 0)
background_particles:setSizes(1.8, 0.4)
background_particles:setSizeVariation(1)

confetti_particles = love.graphics.newParticleSystem(assets.particle, 1000)
confetti_particles:setEmissionRate(0)
confetti_particles:setEmissionArea('normal', 120, 8)
confetti_particles:setInsertMode('random')
confetti_particles:setParticleLifetime(2, 5)
confetti_particles:setSizes(4, 2.7, 2.1, 1.5, 0.9, 0.3)
confetti_particles:setSpeed(0, 850)
confetti_particles:setDirection(-1.6)
confetti_particles:setSpread(1)
confetti_particles:setRotation(-1,1)
confetti_particles:setSpin(-1,1)
confetti_particles:setSpinVariation(1)
confetti_particles:setOffset(8,8)
confetti_particles:setColors(1, 0, 0, 0.84,
							 1, 1, 0, 0.68,
							 0, 1, 0, 0.52,
                             0, 1, 1, 0.36,
                             0, 0, 1, 0.20,
                             1, 0, 1, 0.04)

Games.cah.pt_cards = json.decode(require('assets.game.cards_pt'))
local blk = chance.helpers.shuffle(Games.cah.pt_cards.blackCards)
local wht = chance.helpers.shuffle(Games.cah.pt_cards.whiteCards)
Games.cah.pt_cards = {white = wht, black = blk}

collectgarbage('collect')

------------------------------------------------------------------------
-- Loading game, ui and client data
ui = {}
ui.events = {
	menu = true,
	host = false,
}

ui.data = {
	slider = {value = 1, min = 0, max = 2},
	ip = {text = '172.24.0.0'},
	user = {text = 'User-'..string.format('%x', tostring(math.random(1,0xffffffff))):upper()},
	host_check = {text = '   Participar do jogo', checked = true},
}

Local_info = {}
Local_info.config = {audio=true, music=true}

Client = {data = {user=0, ip=0, userid=0}}

Chat_data = {}
Chat_data.SLIDER = setmetatable({min=0, max=1000, rv=0, sv=0, s_factor=2},
								{__index = function(t, i) return t.rv; end,
								__newindex = function(t, i, v)
									t.rv = v;
									t.sv = t.sv + (t.rv-t.sv)/t.s_factor
                                end})
Chat_data.SCROLL = 0
Chat_data.HEIGHT = setmetatable({min=0, max=1000, rv=0, sv=0, s_factor=2},
								{__index = function(t, i) return t.rv; end,
								__newindex = function(t, i, v)
									t.rv = v;
									t.sv = t.sv + (t.rv-t.sv)/t.s_factor
                                end})
Chat_data.INPUT  = {text=''}

-- for player pick:    slider  = {min=0,value=3.575,max=7.15}
-- for judge pick:     slider  = {0, #client.game.wchoice-1}


------------------------------------------------------------------------
-- Loading useful stuff


Playlist = {}
Playlist.music = {
	love.audio.newSource('assets/audio/music/slowly.ogg', 'stream'),
	love.audio.newSource('assets/audio/music/Sincerely.ogg', 'stream'),
	love.audio.newSource('assets/audio/music/Morfin.ogg', 'stream'),
	love.audio.newSource('assets/audio/music/Cool vibes.ogg', 'stream'),
	love.audio.newSource('assets/audio/music/Clean soul.ogg', 'stream'),
}
Playlist.music = chance.helpers.pick_unique(Playlist.music, #Playlist.music)
Playlist.playing = 1
Playlist.seek = 0
for k, v in ipairs(Playlist.music) do
	v:setVolume(0.25)
end

Draw = {}
Draw.ui = suit.new()
Draw.checks  = suit.new()
Draw.selects = suit.new()
Draw.chat = suit.new()
Draw.chat_input = suit.new()

function Playlist:update(dt)
	-- If the music already ended then move on to the next track.
	if not self.music[self.playing]:isPlaying() then
		if self.music[self.playing]:tell('seconds') <= self.music[self.playing]:getDuration('seconds')-5 then
			self.music[self.playing]:play()
			self.music[self.playing]:seek(self.seek, 'seconds')
		else
			if self.music[self.playing+1] then
				self.playing = self.playing+1
			else
				self.playing = 1
				Playlist.music = chance.helpers.pick_unique(Playlist.music, #Playlist.music)
				Playlist.playing = 1
				self.music[self.playing]:play()
			end
		end
	end
	self.seek = self.music[self.playing]:tell('seconds')
	-- Makes sure only the current song is playing.
	for i = 1, #self.music do
		if self.music[i]:isPlaying() and i ~= self.playing then self.music[i]:stop() end
	end
	if Local_info.config.music then
		for k, v in ipairs(self.music) do
			v:setVolume(0.25)
		end
	else
		for k, v in ipairs(self.music) do
				v:setVolume(0)
		end
	end
end

function Playlist:mute()
	for k, v in ipairs(self.music) do v:setVolume(0) end
end

function Playlist:unmute()
	for k, v in ipairs(self.music) do v:setVolume(0.25) end
end

local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont('assets/fonts/UbuntuMono-Regular.ttf', 18)

	love.graphics.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = 70
		love.graphics.clear(1,0,0,1)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	TERMINAL:log(p, {fg='red'})
	TERMINAL:export_log()

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

collectgarbage('collect')
