return function()

-- Helpers
require('lib.helpers')
require('lib.batteries'):export()
lg = love.graphics
floor, ceil = math.floor, math.ceil
max, min = math.max, math.min
lerp = math.lerp
abs = math.abs
sin, cos = math.sin, math.cos
tinsert = table.insert
tremove = table.remove
love.keyboard.setKeyRepeat(true)

-- Importing libraries and declaring globals
Class  = require('lib.classic')
Tick   = require('lib.tick')
Json   = require('lib.json')
Flux   = require('lib.flux')

UI = require('lib.ui')
Drawable = require('drawable')
State  = {debug=true}
Game = {}
function Game:draw() return; end -- luacheck: ignore
function Game:update() return; end -- luacheck: ignore
function Game:keypressed() return; end -- luacheck: ignore
function Game:mousepressed() return; end -- luacheck: ignore

Transform = {}
Assets = {
  ui = {
    options  = lg.newImage('assets/ui/wrench.png'),
    audioOn  = lg.newImage('assets/ui/audioOn.png'),
    audioOff = lg.newImage('assets/ui/audioOff.png'),
    musicOn  = lg.newImage('assets/ui/musicOn.png'),
    musicOff = lg.newImage('assets/ui/musicOff.png'),
    color    = lg.newImage('assets/ui/contrast.png'),
    flscrn   = lg.newImage('assets/ui/larger.png')
  },
  particles = {
    sqr = lg.newImage('assets/particles/sqr.png')
  },
  fonts = {
    comfortaa = lg.newFont('assets/fonts/Comfortaa-Bold.ttf', 40),
    comfortaa_small = lg.newFont('assets/fonts/Comfortaa-Bold.ttf', 30),
    mono = lg.newFont('assets/fonts/UbuntuMono-Regular.ttf', 30),
    ubuntu = lg.newFont('assets/fonts/Inter-Medium.otf', 45)
  },
  misc = {
    title = lg.newImage('assets/others/title.png'),
    title_r = lg.newImage('assets/others/title_red.png')
  }
}

lg.setFont(Assets.fonts.mono)

DrawList = {{},{},{},{}, sleep={}}

Threads = {
  server = love.thread.newThread('server.lua'),
  client = love.thread.newThread('client.lua'),
}

Channels = {
  send = {
    server = love.thread.getChannel('send_server'),
    client = love.thread.getChannel('send_client'),
  },
  receive = {
    server = love.thread.getChannel('get_server'),
    client = love.thread.getChannel('get_client')
  }
}

Games = {
  UNO = require('games.UNO.game'),
  CCH = require('games.CCH.game')
}

local theme = {
  normal   = {bg = {0.96, 0.96, 0.96}, fg = {0.13, 0.13, 0.13}},
  hovered  = {bg = {0.96, 0.96, 0.96}, fg = {0.13, 0.13, 0.13}},
  active   = {bg = {0.7, 0.7, 0.7}, fg = {0.13, 0.13, 0.13}}
}

local invtheme = {
  normal   = {fg = {0.96, 0.96, 0.96}, bg = {0.13, 0.13, 0.13}},
  hovered  = {fg = {0.96, 0.96, 0.96}, bg = {0.13, 0.13, 0.13}},
  active   = {fg = {0.7, 0.7, 0.7}, bg = {0.13, 0.13, 0.13}}
}

local comfortaa = Assets.fonts.comfortaa
local comfortaa_small = Assets.fonts.comfortaa_small

UI_Maker = {
  menu = {
    function()
      return {'Button', 'Jogar', 'Jogar', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2-120, 500,100,
              function()
                UI.deactivateScreen('menu')
                UI.activateScreen('play')
              end};
    end,
    function()
      return {'Button', 'Host', 'Abrir servidor', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2+20, 500,100,
              function()
                UI.deactivateScreen('menu')
                UI.activateScreen('host')
                UI.activateScreen('CCH')
              end};
    end,
  },
  play = {
    function()
      return {'Button', 'Entrar', 'Entrar no jogo', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2-290, 500,100,
              function()

              end};
    end,
    function()
      return {'Label', 'descriptNome', 'Digite seu nome de usuário.', {cornerRadius=50,font=comfortaa_small,color=invtheme},
              1920/2-250, 1080/2-200, 500,100,
              function()

              end};
    end,
    function()
      return {'Input', 'Nome', {text='Gasolina :3'}, {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2-110, 500,100,
              function()

              end};
    end,
    function()
      return {'Label', 'descriptIP', 'Digite o IP do servidor.', {cornerRadius=50,font=comfortaa_small,color=invtheme},
              1920/2-250, 1080/2-20, 500,100,
              function()

              end};
    end,
    function()
      return {'Input', 'IP', {text='172.24.0.0'}, {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2+70, 500,100,
              function()

              end};
    end,
    function()
      return {'Button', 'Voltar', 'Voltar ao menu', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2+190, 500,100,
              function()
                UI.deactivateScreen('play')
                UI.activateScreen('menu')
              end};
    end
  },
  host = {
    function()
      return {'Button', 'Open', 'Abrir servidor', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2-360, 500,100,
              function()
                local activeList = {}
                for k,v in pairs(UI.getActiveList()) do
                  activeList[v] = k
                end

                if activeList.CCH and UI.getScreen('CCH').active then
                  Games.CCH.start('server')
                elseif activeList.UNO and UI.getScreen('UNO').active then
                  Games.UNO.start()
                end
              end};
    end,
    function()
      return {'Button', 'Back', 'Voltar', {cornerRadius=50,font=comfortaa},
              1920/2-250, 1080/2+260, 500,100,
              function()
                UI.deactivateScreen('host')
                UI.deactivateScreen('UNO')
                if Games.CCH then UI.deactivateScreen('CCH'); end
                UI.activateScreen('menu')
              end};
    end,
  },
  opt = {
    function(t)
      return {'Button', 'options', {Assets.ui.options, 0.95}, {cornerRadius=50,font=comfortaa},
              t.x0+20, t.y0+20, 100,100,
              function()
                if not UI.getScreen('opt_open').active then
                  UI.activateScreen('opt_open')
                else
                  UI.deactivateScreen('opt_open')
                end
              end}
    end
  },
  opt_open = {
    function(t)
      return {'Button', 'color', {Assets.ui.color, 0.95, -5}, {cornerRadius=50,font=comfortaa},
              t.x0+140, t.y0+20, 100,100,
              function()
                local bgColor = UI.getBgColor()
                if bgColor == 'purple' then
                  UI.changeColor('red')
                elseif bgColor == 'red' then
                  UI.changeColor('black')
                else
                  UI.changeColor('purple')
                end
              end};
    end,
    function(t)
      return {'Button', 'music', {Assets.ui.musicOn, 0.95}, {cornerRadius=50,font=comfortaa},
              t.x0+260, t.y0+20, 100,100,
              function()

              end};
    end,
    function(t)
      return {'Button', 'audio', {Assets.ui.audioOn, 0.95}, {cornerRadius=50,font=comfortaa},
              t.x0+380, t.y0+20, 100,100,
              function()

              end};
    end,
    love._os ~= 'Android' and function(t)
      return {'Button', 'fullscreen', {Assets.ui.flscrn, 0.96}, {cornerRadius=50,font=comfortaa},
              t.x0+500, t.y0+20, 100,100,
              function()
                if love.window.getFullscreen() then
                  love.window.setMode(t.w-100, t.h-100, {fullscreen=false,resizable=true})
                else
                  love.window.setFullscreen(true)
                end
              end};
    end or nil,
  },
  UNO = Games.UNO.host,
  CCH = Games.CCH.host
}


RNG = love.math.newRandomGenerator(os.time())

local unpack9 = table.unpack9

function updateScaling(w,h) -- Scale
  if Transform.w ~= w or Transform.h ~= h then
    local scale = 16/9*w > h and h/1080 or w/1920
    local tx, ty = w/2-1920*scale/2, h/2-1080*scale/2

    local transform = love.math.newTransform(tx,ty, 0, scale,scale, 0,0)

    local rx0, ry0 = transform:inverseTransformPoint(0,0)
    local rx1, ry1 = transform:inverseTransformPoint(w,h)

    Transform = {
      obj = transform,
      x = tx, y = ty, sc = scale,
      x0 = rx0, y0 = ry0,
      x1 = rx1, y1 = ry1,
      w = w, h = h
    }

    UI.updateMesh(w,h)

    local list = UI.getActiveList()

    for name, widgets in pairs(UI_Maker) do
      UI.rmvScreen(name)
      local scr = UI.newScreen(name, theme)
      scr:setTransform(Transform.obj)
      for i = 1, #widgets do
        scr:newWidget(unpack9(widgets[i](Transform)))
      end
    end

    for i = 1, #list do
      UI.activateScreen(list[i])
    end
  end
end

updateScaling(love.window.getMode())
UI.activateScreen('menu')
UI.activateScreen('opt')
local opt = UI.getScreen('opt')
opt:getWidget('options').f()
opt:getWidget('options').f()

function love.quit()
  for _,v in pairs(Threads) do
    if not v:isRunning() then v:start(); end
  end
  for _,v in pairs(Channels.send) do
    v:push({info='kill'})
  end
  for _,v in pairs(Threads) do
    v:wait()
  end
end

end
