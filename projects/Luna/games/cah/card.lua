local Card = Classic:extend()

local function getText(card)
	if type(card) == 'string' then
		return card
	elseif type(card) == 'table' then
		if #card == 2 and type(card[1]) == 'string' then
			if type(card[2]) == 'string' then
				return card[2]
			else
				local text = ''
				for i = 2, #card[2], 2 do
					text = text..card[2][i]
				end
				return text
			end
		else
			local text = ''
			for i = 2, #card, 2 do
				text = text..card[i]
			end
			return text
		end
	end
end

local random_chars = {'-', '=', '+', '§', 'ª', 'º', '~', '^', ']', '[', '{',
											'}', ';', ':', '/', '\\', '?', '°', '£', '¢', '¬', '!',
											'@', '#', '$', '%', '¨', '&', '*', '(', ')', '_', "'", '"'}

local function glitch_text(n)
	local text = ''
	for _ = 1, n do
		text = text..random_chars[Rng:random(1,#random_chars)]
	end
	return text
end

local special_cards = {}
special_cards['<Felps_bombado.png>'] = true
special_cards['Carta preta.'] = true
special_cards['<Brasil.png>'] = true
special_cards['<A.png>'] = true
special_cards['<Texto_bugado>'] = true
special_cards['O tamanho dessa carta.'] = true
special_cards['<Bolsonaro.png>'] = true

function Card:new(args)
	self.cards = {}
	self.scale = args.scale
	self.card_num = args.card_num
	if args.wcards then
		self.type = 'wcard'
		if args.vertical then
			local lasty=0
			for i = 1, #args.wcards do
				table.insert(self.cards, {text=args.wcards[i],
										  posX=args.posX,
										  posY=args.posY+lasty*self.scale})
				local _, lines
				local fontHeight
				if type(args.wcards[i]) == 'table' and type(args.wcards[i][1]) == 'string' then
					_, lines   = fonts['card'..args.wcards[i][1]]:getWrap(getText(args.wcards[i]), 460)
					fontHeight = fonts['card'..args.wcards[i][1]]:getHeight() + fonts.card:getLineHeight()
				else
					_, lines   = fonts.card:getWrap(getText(args.wcards[i]), 460)
					fontHeight = fonts.card:getHeight() + fonts.card:getLineHeight()
				end
				lines = #lines
				lasty = lasty+lines*fontHeight+50*self.scale
			end
		else
			for i = 1, #args.wcards do
				table.insert(self.cards, {text=args.wcards[i],
										  posX=args.posX+510*(i-1)*self.scale,
										  posY=args.posY})
			end
		end
	else
		self.type = 'bcard'
		table.insert(self.cards, {text=args.bcard.text,
								  posX=args.posX,
								  posY=args.posY})
	end
end

function Card:draw()
	local cards = self.cards
	local cardtype = self.type
	local scale = self.scale
	local card_num = self.card_num

	local wx, wy = love.window.getMode()
	local sc = 16/9*wx > wy and wy/1920 or wx/1080
	local px, py = (wx/sc - 1080)/2, wy/sc/2 - 960

	for i = 1, #cards do

		if cards[i].posX+20*scale > 1090+px then break end

		if cards[i].posX+20*scale+500*scale >= -px then
			local cardText = cards[i].text
			if not special_cards[cardText] then
				love.graphics.draw(assets.CAH[cardtype],
												   cards[i].posX, cards[i].posY, 0, scale)
			else
				if cardText == 'Carta preta.' then
					love.graphics.draw(assets.CAH.bcard,
													   cards[i].posX, cards[i].posY, 0, scale)
				elseif cardText == '<Brasil.png>' then
					love.graphics.draw(assets.CAH.brasil,
													   cards[i].posX, cards[i].posY, 0, scale)
					goto continue
				elseif cardText == '<A.png>' then
					love.graphics.draw(assets.CAH.A,
													   cards[i].posX, cards[i].posY, 0, scale)
					goto continue
				elseif cardText == '<Felps_bombado.png>' then
					love.graphics.draw(assets.CAH.Felps_bombado,
													   cards[i].posX, cards[i].posY, 0, scale)
					goto continue
				elseif cardText == '<Texto_bugado>' then
					love.graphics.draw(assets.CAH.wcard,
													   cards[i].posX, cards[i].posY, 0, scale)
					love.graphics.setColor(rgb{32,32,32},1)
					love.graphics.printf(glitch_text(16), fonts.card,
										 cards[i].posX+20*scale, cards[i].posY+40*scale,
										 460, 'left',
										 0, scale)
					goto continue
				elseif cardText == 'O tamanho dessa carta.' then
					love.graphics.draw(assets.CAH.big_card,
													   cards[i].posX, cards[i].posY, 0, scale*2)
				elseif cardText == '<Bolsonaro.png>' then
					love.graphics.draw(assets.CAH.Bolsonaro,
													   cards[i].posX, cards[i].posY, 0, scale)
				end
			end

			if cardText == 'Carta preta.' then goto blackcard; end

			if cardtype == 'wcard' and type(cardText) == 'string' then
				love.graphics.setColor(rgb{32,32,32},1)
			elseif cardtype == 'wcard' and #cardText == 2 and type(cardText[1]) == 'string' and type(cardText[2]) == 'string' then
				love.graphics.setColor(rgb{32,32,32},1)
			end

			::blackcard::

			if cardtype == 'wcard' then
				if type(cardText) == 'table' and type(cardText[1]) == 'string' then
					love.graphics.printf(cardText[2], fonts['card'..cardText[1]],
										 cards[i].posX+20*scale, cards[i].posY+40*scale,
										 460, 'left',
										 0, scale)
				else
					love.graphics.printf(cardText, fonts.card,
										 cards[i].posX+20*scale, cards[i].posY+40*scale,
										 460, 'left',
										 0, scale)
				end
			else
				love.graphics.printf(tostring(cardText):gsub('_','____'), fonts.card,
								 cards[i].posX+20*scale, cards[i].posY+40*scale,
								 460, 'left',
								 0, scale)
			end
			::continue::
			if card_num then
				if cardText ~= 'Carta preta.' then
					love.graphics.setColor(rgb{32,32,32},1)
				end
				love.graphics.printf('Carta '..card_num, fonts.card,
									 cards[1].posX+20*scale, cards[1].posY+710*scale,
									 460, 'right',
									 0, scale)
			end
			love.graphics.setColor(1,1,1,1)
		end
	end
end

return Card
