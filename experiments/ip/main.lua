require('batteries'):export()

local iconfig = io.popen('ifconfig', 'r'):read('*a')
iconfig = string.split(iconfig, '\n')

local iplist = {['local']=''}
for i = 1, #iconfig do
  local v = iconfig[i]
  local iptype = 'other'

  if string.match(iconfig[i-1] or '', 'lo') then goto continue; end

  local test1 = string.match(iconfig[i-1] or '', 'wlan0')
  if test1 then
    iptype = 'local'
  end

  local test2 = string.match(v,' inet [1-9]')
  if test2 then
    local line = string.split(string.gsub(v, '        inet addr:', ''),'')
    if iptype == 'other' then
      iptype = #iplist+1
      iplist[iptype] = ''
    end

    for ii = 1, #line do
      if string.match(line[ii],'[0-9%.]') then
        iplist[iptype] = iplist[iptype]..line[ii]
      else
        break
      end
    end
  end

  ::continue::
end

function love.draw()
  love.graphics.print('IP local: '..iplist['local'], 10,10)
  if iplist[1] then love.graphics.print('Network 1: '..iplist[1], 10,25); end
  if iplist[2] then love.graphics.print('Network 2: '..iplist[1], 10,40); end
  if iplist[3] then love.graphics.print('Network 3: '..iplist[1], 10,55); end

  love.graphics.print(table.concat(iconfig,'\n'), 10,70)

end

function love.keypressed(k)
  if k == 'escape' then
    love.event.quit()
  end
end
