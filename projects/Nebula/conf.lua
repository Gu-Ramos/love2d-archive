function love.conf(t)
  t.window.resizable=true
  t.window.width = 1024
  t.window.height = 576
  t.window.fullscreen=false
  t.window.usedpiscale=false
  t.window.vsync = 1

  t.modules.event    = true
  t.modules.timer    = true

  t.modules.audio    = true -- Music and sounds
  t.modules.font     = true -- Fonts
  t.modules.graphics = true -- Graphics
  t.modules.keyboard = true -- Keyboard
  t.modules.math     = true -- RNG
  t.modules.mouse    = true -- Mouse
  t.modules.system   = true -- Mobile clipboard
  t.modules.thread   = true -- Threads
  t.modules.window   = true -- Window
  t.modules.image    = true -- Images
  t.modules.sound    = true -- Audio

  t.modules.touch    = true -- idk

  t.modules.data     = false -- prob not needed
  t.modules.physics  = false
  t.modules.joystick = false
  t.modules.video    = false
end
