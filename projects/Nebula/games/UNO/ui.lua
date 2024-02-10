local theme = {
  normal   = {bg = {0.96, 0.96, 0.96}, fg = {0.13, 0.13, 0.13}},
  hovered  = {bg = {0.96, 0.96, 0.96}, fg = {0.3, 0.3, 0.3}},
  active   = {bg = {0.7, 0.7, 0.7}, fg = {0.13, 0.13, 0.13}}
}

local invtheme = {
  normal   = {fg = {0.96, 0.96, 0.96}, bg = {0.13, 0.13, 0.13}},
  hovered  = {fg = {0.96, 0.96, 0.96}, bg = {0.13, 0.13, 0.13}},
  active   = {fg = {0.7, 0.7, 0.7}, bg = {0.13, 0.13, 0.13}}
}

local comfortaa = Assets.fonts.comfortaa
local comfortaa_small = Assets.fonts.comfortaa_small
local slider = {min=1, value=2, max=4, round=true}

local host = {
  function()
    return {'Button', 'GameBack', '<', {cornerRadius=50,font=comfortaa},
            1920/2-250, 1080/2-240, 100,100,
            function()
              if Games.CCH then
                UI.deactivateScreen('UNO')
                UI.activateScreen('CCH')
              end
            end};
  end,
  function()
    return {'Button', 'GameNext', '>', {cornerRadius=50,font=comfortaa},
            1920/2+150, 1080/2-240, 100,100,
            function()
              if Games.CCH then
                UI.deactivateScreen('UNO')
                UI.activateScreen('CCH')
              end
            end};
  end,
  function()
    return {'Label', 'GameName', 'UNO', {cornerRadius=50,font=comfortaa,color=invtheme},
            1920/2-150, 1080/2-240, 300,100,
            function()
            end};
  end,

  function()
    return {'Checkbox', 'Entrar', {text='Entrar no jogo?',checked=true}, {cornerRadius=50,font=comfortaa},
            1920/2-450, 1080/2-100, 500,100,
            function()
            end};
  end,
  function()
    return {'Checkbox', 'Parar', {text='Parar o jogo na primeira vitória?',checked=true}, {cornerRadius=50,font=comfortaa,valign='top'},
            1920/2+0, 1080/2-100, 500,100,
            function()
            end};
  end,

  function()
    return {'Checkbox', 'R0', {text='Regra do 0?'}, {cornerRadius=50,font=comfortaa},
            1920/2-770, 1080/2+20, 500,100,
            function()
            end};
  end,
  function()
    return {'Checkbox', 'R7', {text='Regra do 7?'}, {cornerRadius=50,font=comfortaa},
            1920/2-250, 1080/2+20, 500,100,
            function()
            end};
  end,
  function()
    return {'Checkbox', 'R9', {text='Regra do 9?'}, {cornerRadius=50,font=comfortaa},
            1920/2+270, 1080/2+20, 500,100,
            function()
            end};
  end,

  function()
    return {'Checkbox', '2e4', {text='Juntar +4 com +2?'}, {cornerRadius=50,font=comfortaa},
            1920/2-770, 1080/2+140, 500,100,
            function()
            end};
  end,
  function()
    return {'Label', 'DeckCounter', setmetatable({}, {__tostring=function() return 'Baralhos: '..slider.value; end}), {cornerRadius=12.5,font=comfortaa_small,color=theme,color=invtheme},
            1920/2-250, 1080/2+130, 500,50,
            function()
            end};
  end,
  function()
    return {'Slider', 'Decks', slider, {cornerRadius=12.5,font=comfortaa,color=theme},
            1920/2-250, 1080/2+180, 500,50,
            function()
            end};
  end,
  function()
    return {'Checkbox', 'Corte', {text='Permitir corte?'}, {cornerRadius=50,font=comfortaa},
            1920/2+270, 1080/2+140, 500,100,
            function()
            end};
  end,
}

return host, game_ui
