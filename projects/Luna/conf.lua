function love.conf(t)
	t.identity = 'Luna'
	t.version = "11.3"
	t.console = false

	t.accelerometerjoystick = false
	t.externalstorage = true
	t.gammacorrect = false
	t.audio.mic = false
	t.appendidentity = false            -- Search files in source directory before save directory (boolean)

	t.audio.mixwithsystem = true

	t.window.title = "Luna"
	t.window.icon  = 'assets/others/icon.png'
	t.window.height = 850
	t.window.width  = 480
	t.window.borderless = false
	t.window.resizable = false
	t.window.minwidth = 1
	t.window.minheight = 2
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = nil
	t.window.stencil = nil
	t.window.display = 1
	t.window.highdpi = false
	t.window.usedpiscale = false
	t.window.x = nil
	t.window.y = nil

	t.modules.event    = true
	t.modules.timer    = true

	t.modules.audio    = true
	t.modules.font     = true
	t.modules.graphics = true
	t.modules.image    = true
	t.modules.keyboard = true
	t.modules.mouse    = true
	t.modules.sound    = true
	t.modules.touch    = true
	t.modules.window   = true
	t.modules.system   = true
	t.modules.math     = true

	t.modules.thread   = false
	t.modules.data     = false
	t.modules.physics  = false
	t.modules.video    = false
	t.modules.joystick = false
end
