love.blobs = require "loveblobs"
local util = require "loveblobs.util"

local idkX, maxY = love.window.getMode()
if idkX > maxY then idkX, maxY = maxY, idkX end
love.window.setMode(idkX,maxY, {fullscreen=true, fullscreentype='exclusive', usedpiscale=false, resizable=false})

local mousejoint
math.randomseed(os.time())
for _ = 1, math.random(1,1000) do math.random(0,0xffffffff); end
local function int(b) return b and 1 or 0 end
love.graphics.setBackgroundColor(0.07,0.07,0.1)

do -- GLOBAL SCALER
	local wx, wy = love.window.getMode()
	__WINX__ = wx
	__WINY__ = wy
	
	local sc = 21/12*wx > wy and wy/2100 or wx/1200
	
	__GSCALE__ = sc
	__GTRANSFORM__ = love.math.newTransform(wx/2-1200*sc/2, wy/2-2100*sc/2, 0,
											sc,sc,0,0)
end

function love.load()
	blobs = {}
	worldBlobs = {}
	worldWalls = {}
	worldSensors = {}
	
	a_button = love.graphics.newImage('a.png')
	l_button = love.graphics.newImage('left.png')
	r_button = love.graphics.newImage('right.png')
	d_button = love.graphics.newImage('down.png')
	s_button = love.graphics.newImage('spin.png')
	
	PieceTimer = 16
	function New_Piece()
		worldBlobs[#worldBlobs]:setLinearDamping(0)
		worldBlobs[#worldBlobs]:setCategory(16)
		local blob = math.random(1,7)
		b = love.blobs.softsurface(world, blobs[blob], 32, "dynamic")
		b:setFrequency(10)
		b:setDampingRatio(1)
		b:setFriction(2)
		b:setPosition(600,-50)
		b:setLinearDamping(2)
		b:setAngularDamping(2)
		b:setCategory(15)
		b:setBullet(false)
		b.color = blobs[blob].color
		b.id = 1
		table.insert(worldBlobs, b)
	end
	
	love.physics.setMeter(32)
	world = love.physics.newWorld(0, 4.81*32, false)
	ptimg = love.graphics.newImage('particle.png')
	particles = love.graphics.newParticleSystem(ptimg, 25000)
	particles:setParticleLifetime(1,2.5)
	particles:setEmissionRate(0)
	particles:setLinearAcceleration(-150,-150,150,150)
	particles:setSpeed(-150,150)
	particles:setRotation(-math.pi,math.pi)
	particles:setSpread(math.pi*2)
	particles:setColors(1,0,0,1, 1,0.8,0.4,0.5, 0.8,0.2,1,0)
	particles:setEmissionArea('uniform',10,10)
	
	local sensorShape = love.physics.newRectangleShape(3,3)
	for l=1,20 do
		local line = {}
		for c=1,40 do
			local b = love.physics.newBody(world, 84+c*25, -35+100*l, 'static')
			local f = love.physics.newFixture(b, sensorShape, 1)
			f:setSensor(true)
			b:setBullet(true)
			f:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
			f:setCategory(16)
			line[c] = {b=b, s=sensorShape, f=f}
		end
		line.timer = 0
		worldSensors[l] = line
	end

	blobs[1] = {-200, -50, 200, -50,
				200, 50, -200, 50, color={0.5,1,1}}
	blobs[2] = {-50, -100, 150, -100, 150, 0,
				50, 0, 50, 100, -150, 100,
				-150, 0, -50, 0, color={0.5,1,0.5}}
	blobs[3] = {-100, -150, 100, -150, 100, 150,
				0, 150, 0, -50, -100, -50, color={1,0.5,0.3}}
	blobs[4] = {-100, -100, 100, -100,
				100, 100, -100, 100, color={1,0.8,0.4}}
	blobs[5] = {-100,-150, 100,-150, 100,-50,
	            0,-50, 0, 150, -100,150, color={0.5,0.5,1}}
	blobs[6] = {150,0, 150,100, -150,100, -150,0,
	            -50,0, -50,-100, 50,-100, 50,0, color={1,0.4,0.8}}
	blobs[7] = {-150,-100, 50,-100, 50,0, 150,0,
	            150,100, -50,100, -50,0, -150,0, color={1,0.5,0.5}}
	
	local b
	local s
	local f
	
	local blob = math.random(1,7)
	b = love.blobs.softsurface(world, blobs[blob], 32, "dynamic")
	b:setFrequency(10)
	b:setDampingRatio(1)
	b:setFriction(2)
	b:setPosition(600,-50)
	b:setLinearDamping(2)
	b:setAngularDamping(2)
	b:setCategory(15)
	b:setBullet(false)
	b.color = blobs[blob].color
	b.id = 1
	table.insert(worldBlobs, b)
	
	
	b = love.physics.newBody(world, 40, 1050,'static')
	s = love.physics.newRectangleShape(100,2100)
	f = love.physics.newFixture(b,s,1)
	table.insert(worldWalls, {b=b,s=s,f=f})
	
	b = love.physics.newBody(world, 1160, 1050,'static')
	s = love.physics.newRectangleShape(100,2100)
	f = love.physics.newFixture(b,s,1)
	table.insert(worldWalls, {b=b,s=s,f=f})
	
	b = love.physics.newBody(world, 600, 2050,'static')
	s = love.physics.newRectangleShape(1200,100)
	f = love.physics.newFixture(b,s,1)
	table.insert(worldWalls, {b=b,s=s,f=f})
end

function love.update(dt)
	do -- GLOBAL SCALER
		local wx, wy = love.window.getMode()
		if wx ~= __WINX__ or wy ~= __WINY__ then
			__WINX__ = wx
			__WINY__ = wy
			
			local sc = 21/12*wx > wy and wy/2100 or wx/1200
			
			__GSCALE__ = sc
			__GTRANSFORM__ = love.math.newTransform(wx/2-1200*sc/2, wy/2-2100*sc/2, 0,
													sc,sc,0,0)
		end
	end
	world:update(1/240)
	world:update(1/240)
	world:update(1/240)
	
	particles:update(1/60)
	PieceTimer = PieceTimer-1/60
	if PieceTimer < 0 then
		New_Piece();
		PieceTimer = 16;
	end
	
	if #worldWalls[3].b:getContacts() > 0 then
		for i,v in pairs(worldWalls[3].b:getContacts()) do
			local f1, f2 = v:getFixtures()
			if f1:getUserData() == worldBlobs[#worldBlobs] or f2:getUserData() == worldBlobs[#worldBlobs] then 
				New_Piece(); PieceTimer = 16; break
			end
			
		end
	end
	
	for l = 1, 20 do
		local isFull = true
		for c = 1, 40 do
			if #worldSensors[l][c].b:getContacts() == 0 then
				isFull = false
				break
			end
		end
		local bodies = {}
		if isFull then
			worldSensors[l].timer = worldSensors[l].timer + 1/60*int(worldSensors[l].timer+1/60<=5.05)
			if worldSensors[l].timer >= 4.965 then
				for c = 1, 40 do
					for i,v in pairs(worldSensors[l][c].b:getContacts()) do
						local f1, f2 = v:getFixtures()
						if not bodies[f1] and f1 ~= worldSensors[l][c].f then bodies[f1] = true end
						if not bodies[f2] and f2 ~= worldSensors[l][c].f then bodies[f2] = true end
					end
				end
				for f,_ in pairs(bodies) do
					if not f:isDestroyed() then
						for a,b in pairs(f:getUserData().phys) do
							particles:setPosition(b.body:getPosition())
							particles:emit(10)
						end
						f:getUserData():destroy();
					end
				end
			end
		else
			worldSensors[l].timer = 0
		end
	end
end

function love.draw()
	love.graphics.push()
		love.graphics.applyTransform(__GTRANSFORM__)
		love.graphics.setColor(0.6*2, 0.1, 0.25)
		
		for i,v in ipairs(worldWalls) do
			love.graphics.polygon('fill',v.b:getWorldPoints(v.s:getPoints()))
		end
		
		for i,v in ipairs(worldBlobs) do
			love.graphics.setColor(v.color)
			v:draw(DEBUG)
		end
		
		love.graphics.setColor(0,1,0,0.2)
		for i,v in ipairs(worldSensors) do
			love.graphics.rectangle('fill',90,i*100, 1020, v.timer/5*-100)
		end
		
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(particles, 0, 0)
		
		love.graphics.setColor(0.4,1,0.4,1)
		love.graphics.rectangle('fill',10,10,67,200*PieceTimer/12)
		
		
		
		
		
		
		local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
		local mp = love.mouse.isDown(1)
		
		
		
		love.graphics.setColor(1,1,1)
		if mp and util.dist(mx,my, 230,1380) <= 80 then
			love.graphics.setColor(0.5,0.5,0.5)
			worldBlobs[#worldBlobs]:applyAngularImpulse(-30000,0);
		end
		love.graphics.draw(s_button, 150,1300,0,-2,2,80)
		
		love.graphics.setColor(1,1,1)
		if mp and util.dist(mx,my, 430,1380) <= 80 then
			love.graphics.setColor(0.5,0.5,0.5)
			worldBlobs[#worldBlobs]:applyAngularImpulse(30000,0);
		end
		love.graphics.draw(s_button, 350,1300,0,2)
		
		
		
		love.graphics.setColor(1,1,1)
		if mp and util.dist(mx,my, 230,1580) <= 80 then
			love.graphics.setColor(0.5,0.5,0.5)
			worldBlobs[#worldBlobs]:applyForce(-50000,0);
		end
		love.graphics.draw(l_button, 150,1500,0,2)
		
		love.graphics.setColor(1,1,1)
		if mp and util.dist(mx,my, 430,1580) <= 80 then
			love.graphics.setColor(0.5,0.5,0.5)
			worldBlobs[#worldBlobs]:applyForce(50000,0);
		end
		love.graphics.draw(r_button, 350,1500,0,2)
		
		love.graphics.setColor(1,1,1)
		if mp and util.dist(mx,my, 330,1755) <= 80 then
			love.graphics.setColor(0.5,0.5,0.5)
			worldBlobs[#worldBlobs]:applyForce(0,50000);
		end
		love.graphics.draw(d_button, 250,1675,0,2)
		
		
		
		love.graphics.setColor(1,1,1)
		if CLICOU then love.graphics.setColor(0.5,0.5,0.5); CLICOU = false; end
		love.graphics.draw(a_button, 880,1400,0,2)
	love.graphics.pop()
	
	love.graphics.setColor(1,1,1)
	love.graphics.print(love.timer.getFPS()..' FPS',100*maxY/2100,10)
	love.graphics.print('Setas tortas: girar a peça\nSetas retas: mover e abaixar a peça\nA: soltar a peça',100*maxY/2100,25)
end

function love.touchpressed(_,mx,my)
	mx,my=__GTRANSFORM__:inverseTransformPoint(mx,my)
	if util.dist(mx,my, 960,1480) <= 80 then
		CLICOU = true
		New_Piece()
		PieceTimer = 16
	end
end
