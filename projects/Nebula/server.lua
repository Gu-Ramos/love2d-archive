sock = require('lib.sock')
require('love.math')

RNG = love.math.newRandomGenerator(os.time())
local json = require('lib.json')
local schannel = love.thread.getChannel('get_server')
local rchannel = love.thread.getChannel('send_server')
local server

Conf = {}
State = {}

local slist = {
  UNO = require('games.UNO.server'),
  CCH = require('games.CCH.server')
}

local cards = json.decode(require('games.CCH.cards'))
local whiteCards = cards.whiteCards
local blackCards = cards.blackCards
cards = nil --luacheck: ignore
collectgarbage('collect')

local assets = {
  CCH = {
    bcards = blackCards,
    wcards = whiteCards
  }
}

local function newWhiteCards(n)
  State.used_white = State.used_white or {}
  local cards = {}
  for i = 1, n do
    local c = table.remove(assets.CCH.wcards, RNG:random(1, #assets.CCH.wcards))
    State.used_white[c] = true
    cards[#cards+1] = c
  end
  return cards
end

local function newBlackCards(n)
  State.used_black = State.used_black or {}
  local cards = {}
  for i = 1, n do
    local c = table.remove(assets.CCH.bcards, RNG:random(1, #assets.CCH.bcards))
    State.used_black[c.text] = c
    cards[#cards+1] = c
  end
  return cards
end

-- Main loop: handles server and communication with main thread.
while true do
  local msg = rchannel:pop()
  if not msg then goto continue; end
  if msg.info == 'kill' then
    if server then server:destroy(); end
    break
  end

  if server and msg.info == 'update' then
    server:update()
  else
    if msg.info == 'start' then
      server = sock.newServer('*', 2134)
      Conf = msg.conf
      for name, func in pairs(slist[msg.game]) do
        server:on(name, func)
      end
      schannel:push({info='cards', w=newWhiteCards(10), b=newBlackCards(Conf.bc)})
    end
  end

  ::continue::
end

return

