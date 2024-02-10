function love.conf(t)
  t.window.resizable=true
  t.window.width = 1024
  t.window.height = 576
  t.window.fullscreen=false
  t.window.usedpiscale=false
  t.window.vsync = 0

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.window   = true
  t.modules.graphics = true
  t.modules.image    = true
  t.modules.font     = true

  t.modules.math     = true
  t.modules.physics  = true

  t.modules.keyboard = true
  t.modules.mouse    = true
  t.modules.joystick = true
  t.modules.touch    = true

  t.modules.audio    = true
  t.modules.sound    = true

  t.modules.system   = false
  t.modules.data     = false
  t.modules.thread   = false
  t.modules.video    = false
end

