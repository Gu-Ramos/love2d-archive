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
local slider = {min=1, value=2, max=3, round=true}

State.CCH = {
  enter_game = {text='Entrar no jogo?',checked=true},
  voting_mode = {text='Modo votação?', checked=true},
  black_cards = slider
}

local state = State.CCH

local host = {
  function()
    return {'Button', 'GameBack', '<', {cornerRadius=50,font=comfortaa},
            1920/2-250, 1080/2-240, 100,100,
            function()
              UI.deactivateScreen('CCH')
              UI.activateScreen('UNO')
            end};
  end,
  function()
    return {'Button', 'GameNext', '>', {cornerRadius=50,font=comfortaa},
            1920/2+150, 1080/2-240, 100,100,
            function()
              UI.deactivateScreen('CCH')
              UI.activateScreen('UNO')
            end};
  end,
  function()
    return {'Label', 'GameName', 'CCH', {cornerRadius=50,font=comfortaa,color=invtheme},
            1920/2-150, 1080/2-240, 300,100,
            function()
            end};
  end,

  function()
    return {'Checkbox', 'Entrar', state.enter_game, {cornerRadius=50,font=comfortaa},
            1920/2-250, 1080/2-100, 500,100,
            function()
            end};
  end,
  function()
    return {'Checkbox', 'GameMode', state.voting_mode, {cornerRadius=50,font=comfortaa},
            1920/2-250, 1080/2+20, 500,100,
            function()
            end};
  end,
  function()
    return {'Label', 'BlackCounter', function() return 'Cartas pretas: '..slider.value; end, {cornerRadius=12.5,font=comfortaa_small,color=theme,color=invtheme},
            1920/2-250, 1080/2+130, 500,50,
            function()
            end};
  end,
  function()
    return {'Slider', 'BlackChoice', slider, {cornerRadius=12.5,font=comfortaa,color=theme},
            1920/2-250, 1080/2+180, 500,50,
            function()
            end};
  end,
}

return host
