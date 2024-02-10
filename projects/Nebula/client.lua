sock = require('lib.sock')

local schannel = love.thread.getChannel('get_client')
local rchannel = love.thread.getChannel('send_client')
local client
local state
local clist = {
  UNO = require('games.UNO.client'),
  CCH = require('games.UNO.client')
}

while true do
  local msg = rchannel:pop()
  if not msg then goto continue; end
  if msg.info == 'kill' then
    if client then client:disconnectNow(); end
    break
  end

  if client then
    if msg.info == 'update' then
      client:update()
    elseif msg.info == 'disconnect' then
      client:disconnectNow()
    end
  else
    if msg.info == 'start' then
      string.gsub(msg.ip, string.match(msg.ip, '/%d+', #msg.ip-3) or '', '')
      client = sock.newClient(msg.ip, 2134)
      state = msg.state
      for name, func in pairs(clist[msg.game]) do
        client:on(name, func)
      end
    end
  end

  ::continue::
end

return

