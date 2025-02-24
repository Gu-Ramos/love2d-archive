function love.conf(t)
  t.window.resizable=true
  t.window.width = 1024
  t.window.height = 576
  t.window.fullscreen=false
  t.window.usedpiscale=false
  t.window.vsync = 0

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.font     = true -- Fonts
  t.modules.graphics = true -- Graphics
  t.modules.keyboard = true -- Keyboard
  t.modules.mouse    = true -- Mouse
  t.modules.window   = true -- Window
  t.modules.image    = true -- Images

  t.modules.touch    = true -- Touch -> Mouse // Not sure if needed though?
  t.modules.system   = true -- Android//PC check

  t.modules.sound    = false
  t.modules.data     = false
  t.modules.thread   = false
  t.modules.math     = false
  t.modules.audio    = false
  t.modules.physics  = false
  t.modules.joystick = false
  t.modules.video    = false
end
