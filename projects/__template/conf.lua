function love.conf(t)
    t.identity = 'Untitled'
    t.appendidentity = true
    t.externalstorage = true

    t.window.title = "Untitled"         -- The window title (string)
    t.window.width = 1024
    t.window.height = 576
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 0

--     t.window.borderless = false
--     t.window.minwidth = 1
--     t.window.minheight = 1
--     t.window.x = nil
--     t.window.y = nil

--     t.version = "11.3"
--     t.console = false
--     t.gammacorrect = false
--     t.window.icon = nil
--     t.audio.mic = false
--     t.audio.mixwithsystem = true
--     t.window.msaa = 0
--     t.window.depth = nil
--     t.window.stencil = nil
--     t.window.display = 1
--     t.window.highdpi = false
--     t.window.usedpiscale = false
--     t.accelerometerjoystick = true

    -- Basically mandatory
    t.modules.timer    = true
    t.modules.event    = true

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

    t.modules.video    = false
    t.modules.joystick = false
end
