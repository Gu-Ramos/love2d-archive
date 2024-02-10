local host_ui, game_ui = require('games.UNO.ui')
local deck = {
  R={1,1,1,1,1,1,1,1,1,1, b=1, r=1, p=1},
  G={1,1,1,1,1,1,1,1,1,1, b=1, r=1, p=1},
  B={1,1,1,1,1,1,1,1,1,1, b=1, r=1, p=1},
  Y={1,1,1,1,1,1,1,1,1,1, b=1, r=1, p=1},
  S={p4=2, c=2}
}

local spritesheet = lg.newImage('assets/sprites/uno.png')
local quads = {spritesheet,R={},G={},B={},Y={},S={}}

-- local w,h = 132,183
-- local spacing_x, spacing_y = 8, 13

local quadMaker = {
  {'b','r','p',0,1,2,3,4,5,6,7,8,9},
  {'c', 'p4', 'back1', 'back2'}
}

for i = 0, 3 do
  for ii = 0, 13 do
    local q = lg.newQuad(ii*140,i*196, 132,183, spritesheet)
    local t
    if ii == 13 then t = 'S'; elseif i==0 then t='R'; elseif i==1 then t='G'; elseif i==2 then t='B'; else t='Y'; end

    if ii ~= 13 then
      quads[t][quadMaker[1][ii+1]] = q
    else
      quads[t][quadMaker[2][i+1]] = q
    end
  end
end

return {
  host   = host_ui,
  ui     = game_ui,
  assets = quads
}
