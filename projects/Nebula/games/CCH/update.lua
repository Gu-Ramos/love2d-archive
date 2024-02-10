local invisible = {
  normal   = {fg = {0, 0, 0, 0}, bg = {0, 0, 0, 0}},
  hovered  = {fg = {0, 0, 0, 0}, bg = {0, 0, 0, 0}},
  active   = {fg = {0, 0, 0, 0}, bg = {0, 0, 0, 0}}
}

local invtheme = {
  normal   = {fg = {0.96, 0.96, 0.96}, bg = {0.09, 0.09, 0.09}},
  hovered  = {fg = {0.96, 0.96, 0.96}, bg = {0.09, 0.09, 0.09}},
  active   = {fg = {0.7, 0.7, 0.7}, bg = {0.09, 0.09, 0.09}}
}

local function chooseBlack(n)
  local fb = UI.newScreen('flipBlack', invisible)
  fb:setTransform(Transform.obj)
  if n == 1 then
    fb:newWidget('Button', 'c1', '', {}, 772,180, 375,600, function() Game.cards.black[1].xs = 0.75; end) --luacheck: ignore
  elseif n == 2 then
    fb:newWidget('Button', 'c1', '', {}, 522,180, 375,600, function() Game.cards.black[1].xs = 0.75; end) --luacheck: ignore
    fb:newWidget('Button', 'c2', '', {}, 1022,180, 375,600, function() Game.cards.black[2].xs = 0.75; end) --luacheck: ignore
  else
    fb:newWidget('Button', 'c1', '', {}, 272,180, 375,600, function() Game.cards.black[1].xs = 0.75; end) --luacheck: ignore
    fb:newWidget('Button', 'c2', '', {}, 772,180, 375,600, function() Game.cards.black[2].xs = 0.75; end) --luacheck: ignore
    fb:newWidget('Button', 'c3', '', {}, 1272,180, 375,600, function() Game.cards.black[3].xs = 0.75; end) --luacheck: ignore
  end
  Game.ui.fb = fb

  local cb = UI.newScreen('chooseBlack', invisible)
  cb:setTransform(Transform.obj)
  if n == 1 then
    cb:newWidget(
      'Radio', 'r1', {id=1,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={772,180, 375,600}},
      909,780, 100,100,
      function() Game.cards.black[1].xs = 0.75; end
    )
  elseif n == 2 then
    cb:newWidget(
      'Radio', 'r1', {id=1,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={522,180, 375,600}},
      659,780, 100,100,
      function() Game.cards.black[1].xs = 0.75; end
    )
    cb:newWidget(
      'Radio', 'r2', {id=2,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={1022,180, 375,600}},
      1159,780, 100,100,
      function() Game.cards.black[2].xs = 0.75; end
    )
  else
    cb:newWidget(
      'Radio', 'r1', {id=1,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={272,180, 375,600}},
      409,780, 100,100,
      function() Game.cards.black[1].xs = 0.75; end
    )
    cb:newWidget(
      'Radio', 'r2', {id=2,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={772,180, 375,600}},
      909,780, 100,100,
      function() Game.cards.black[2].xs = 0.75; end
    )
    cb:newWidget(
      'Radio', 'r3', {id=3,list=Game.ui.radio},
      {color=invtheme, cornerRadius=50, rbox={1272,180, 375,600}},
      1409,780, 100,100,
      function() Game.cards.black[3].xs = 0.75; end
    )
  end
  Game.ui.cb = cb

  UI.activateScreen('chooseBlack')
end

local bsc

return function()
  if not bsc then
    Game.ui = Game.ui or {}
    Game.ui.radio = {
      {text=''},{text=''},{text=''},
      max=1,active={}
    }
    chooseBlack(Game.conf.bc)
    bsc = true
  end
end
