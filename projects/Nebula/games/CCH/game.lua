local BASE = (...):match('(.-)[^%.]+$')
local host_ui, game_ui = require(BASE..'ui')
local update = require(BASE..'update')

local assets = {
  normal = {
    w_back = lg.newImage('assets/sprites/White_back.png'),
    w_front = lg.newImage('assets/sprites/White_front.png'),
    b_back = lg.newImage('assets/sprites/Black_back.png'),
    b_front = lg.newImage('assets/sprites/Black_front.png'),
  }
}

local function spin_change(self)
  Flux.to(
    self.obj, .25,
    {
      xs = .75
    }
  ):ease('quadout')
end

local function create_black(bc, t)
  local card,card2,card3
  if bc == 1 then
    card = Drawable(assets.normal.b_front, t[1].text, 710,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card:associate(1,1)

    card:setTransform('cubicout', .75, nil, nil, 80)
  elseif bc == 2 then
    card = Drawable(assets.normal.b_back, t[1].text, 460,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card:associate(1,1)
    card2 = Drawable(assets.normal.b_back, t[2].text, 960,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card2:associate(1,1)

    card:setTransform('cubicout', .75, nil, nil, 80)
    card2:setTransform('cubicout', .75, nil, nil, 80)
  else
    card = Drawable(assets.normal.b_back, t[1].text, 210,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card:associate(1,1)
    card2 = Drawable(assets.normal.b_back, t[2].text, 710,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card2:associate(1,1)
    card3 = Drawable(assets.normal.b_back, t[3].text, 1210,1880, 0, -0.75, 0.75, 1, Assets.fonts.ubuntu)
    card3:associate(1,1)

    card:setTransform('cubicout', .75, nil, nil, 80)
    card2:setTransform('cubicout', .75, nil, nil, 80)
    card3:setTransform('cubicout', .75, nil, nil, 80)
  end
  Game.cards = Game.cards or {}
  Game.cards.black = {
    card,
    card2,
    card3,
  }
end


-- Wrapper for server thread//channel
local Server = {
  thread=Threads.server,
  schannel=Channels.send.server,
  rchannel=Channels.receive.server,
  messageList={}
}
function Server:start(c)
  self.thread:start()
  self.schannel:push({info='start', game='CCH', conf=c})
end
function Server:update()
  self.schannel:push({info='update'})
  local msg = self.rchannel:pop()
  if msg then
    self.messageList[msg.info] = msg
  end
end
-- Gets a server message, returns nil if no message
function Server:getMessage(name, peek)
  local msg = self.messageList[name]
  if not peek then
    self.messageList[name] = nil
  end
  return msg
end
-- Waits for a message to arrive.
function Server:waitMessage(name, peek)
  while true do
    local msg = self.messageList[name]
    if msg then
      if not peek then
        self.messageList[name] = nil
      end
      return msg
    end

    msg = self.rchannel:pop()
    if msg then
      self.messageList[msg.info] = msg
    end
  end
end


-- Starts the game when told to in hostgame scene
local function start(c)
  UI.deactivateScreen('CCH')
  UI.deactivateScreen('host')

  Game.conf = {
    enter = State.CCH.enter_game.checked,
    voting = State.CCH.voting_mode.checked,
    bc = State.CCH.black_cards.value,
  }

--  UI_Maker.game = game_ui

-- Creates the game UI
--     local scr = UI.newScreen('game', theme)
--     scr:setTransform(Transform.obj)
--     for i = 1, #game_ui do
--       scr:newWidget(unpack9(game_ui[i](Transform)))
--     end

  Server:start(Game.conf)

  if Game.conf.enter then
    Client:start('localhost')
  end
end

return {
  start=start,
  info=info,
  host=host_ui,
  game=game_ui,
}
