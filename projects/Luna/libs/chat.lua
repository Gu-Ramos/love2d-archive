return function(arg)
	if arg == 'draw' then
		local ch_value = Chat_data.HEIGHT.sv
		love.graphics.setColor(rgb{24,24,24})
		love.graphics.rectangle('fill',0,0,1080,1920)
		Draw.chat:draw()
		love.graphics.setColor(0,0,0,1)
		
		local wx, wy = love.window.getMode()
		local sc = 16/9*wx > wy and wy/1920 or wx/1080
		local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960
		
		love.graphics.rectangle("fill",0-px,0-py,1080+px*2,260+py)
		love.graphics.rectangle("fill",0-px,1780-ch_value,1080+px*2,140+py+ch_value)
		
		Draw.chat_input:draw()
		love.graphics.setColor(rgb{32,32,32})
		love.graphics.draw(assets.send, 965, 1800-ch_value)
		love.graphics.setColor(1,1,1,1)
	else
		-- Chat sliders
		Draw.chat_input:Slider(Chat_data.HEIGHT, {color=UI_COLOR.grayFG, cornerRadius=25}, 280, __R0Y__+20, 640, 100)
		local ch_value = Chat_data.HEIGHT.sv
		
		Client.data.newMessage = false
		Draw.chat.layout:reset(10, 1780-ch_value+Chat_data.SCROLL*Chat_data.SLIDER.sv/1000)
		Draw.chat.layout:padding(20, 20)
		Draw.chat.layout:up(940, 40)
		-- -60 because of the first layout:up (40h+20p)
		local totalLineSize =  -60

		-- Shows the player messages
		-- Blue for your messages, red for server messages,
		-- white for player messages.

		-- User-102A9E2B falou: bom dia
		for i = #Chat_data.messages, 1, -1 do
			local minfo = Chat_data.messages[i]
			local message = string.format('%s'..minfo.message, minfo.user..' falou: ')
			
			-- Get message height
			local lines = #(({fonts.chat:getWrap(message, 940)})[2])
			local fontHeight = fonts.chat:getHeight() + fonts.chat:getLineHeight()
			local lineSize = lines*fontHeight
			totalLineSize = totalLineSize + lineSize + 20
            
            local x, y, w, h = Draw.chat.layout:up(940, lineSize)
            if y+h < 250 then break           
			elseif y < 1800 then
                local color = UI_COLOR[minfo.userid] or UI_COLOR.dark
                if minfo.userid == Client.data.userid then color = UI_COLOR.blueFG end
				Draw.chat:Label(message, {color=color, align='left', valign='top', font=fonts.chat}, x, y, w, h)
			end
		end
		Chat_data.SCROLL = totalLineSize
		
		Draw.chat_input:Slider(Chat_data.SLIDER, {vertical=true, cornerRadius=25, mscroll=true, keyboard=true}, 960, 320, 100, 1400-ch_value)
		
		-- Chat input
		local chat_input = Draw.chat_input:Input(Chat_data.INPUT, {id='chat_input', cornerRadius=50, font=fonts.chat}, 20, 1800-ch_value, 920, 100)

		-- Sends the message if it is not empty or only spaces.
		local send_message = Draw.chat_input:Button(' ', {id='send_message', cornerRadius=50}, 960, 1800-ch_value, 100, 100)
		if (send_message.hit or chat_input.submitted) and Chat_data.INPUT.text:gsub(' ', '') ~= '' then
			Client.link:send('chat_message', {user=Client.data.user, message=Chat_data.INPUT.text, userid=Client.data.userid})
			Chat_data.INPUT.text = ''
		end
	end
end
