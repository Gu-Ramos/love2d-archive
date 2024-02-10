function love.conf(t)
  t.window.width = 520
  t.window.height = 820
  t.window.usedpiscale = false
  t.window.fullscreen = false

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.audio    = false -- Music and sounds
  t.modules.font     = false -- Fonts
  t.modules.graphics = true -- Graphics
  t.modules.keyboard = false -- Keyboard
  t.modules.math     = false -- RNG
  t.modules.mouse    = false -- Mouse
  t.modules.system   = false -- Android//PC check
  t.modules.thread   = false -- Threads
  t.modules.window   = true -- Window
  t.modules.image    = true -- Images

  t.modules.touch    = false -- Touch -> Mouse // Not sure if needed though?

  t.modules.data     = false -- Not sure if needed?
  t.modules.sound    = false -- Not sure if needed?

  t.modules.physics  = false
  t.modules.joystick = false
  t.modules.video    = false
end
