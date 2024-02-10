function love.conf(t)
  t.window.resizable=true
  t.window.width = 1000
  t.window.height = 500
  t.window.fullscreen=false
  t.window.usedpiscale=false
  t.window.vsync = 0

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.audio    = false -- Music and sounds
  t.modules.font     = true -- Fonts
  t.modules.graphics = true -- Graphics
  t.modules.keyboard = true -- Keyboard
  t.modules.math     = false -- RNG
  t.modules.mouse    = true -- Mouse
  t.modules.system   = true -- Mobile clipboard
  t.modules.thread   = false -- Threads
  t.modules.window   = true -- Window
  t.modules.image    = false -- Images
  t.modules.sound    = false -- Audio

  t.modules.touch    = false -- idk

  t.modules.data     = false -- prob not needed
  t.modules.physics  = false
  t.modules.joystick = false
  t.modules.video    = false
end
