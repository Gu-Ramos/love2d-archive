function love.conf(t)
  t.identity = "Sol"
  t.appendidentity = false
  t.version = "11.3"
  t.console = false
  t.accelerometerjoystick = true
  t.externalstorage = false
  t.gammacorrect = false

  t.audio.mic = false
  t.audio.mixwithsystem = true

  t.window.title = "Solaria"
  t.window.icon = 'assets/images/icon.png'
  t.window.borderless = false
  t.window.resizable = true
  t.window.width = 1024
  t.window.height = 576
  t.window.minwidth = 1
  t.window.minheight = 1
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
  t.window.vsync = 0
  t.window.msaa = 0
  t.window.depth = nil
  t.window.stencil = nil
  t.window.display = 1
  t.window.highdpi = false
  t.window.usedpiscale = true
  t.window.x = 448
  t.window.y = 252

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.audio    = true
  t.modules.data     = true
  t.modules.font     = true
  t.modules.graphics = true
  t.modules.image    = true
  t.modules.keyboard = true
  t.modules.math     = true
  t.modules.mouse    = true
  t.modules.physics  = true
  t.modules.sound    = true
  t.modules.system   = true
  t.modules.thread   = true
  t.modules.touch    = true
  t.modules.window   = true

  t.modules.joystick = false
  t.modules.video    = false
end
