-- Loading basic stuff
-- TODO: Finish map generator
-- TODO: Make a object creator

Lib   = {}
Data  = {}
State = {}
Game  = {}
Conf  = {}
Scale = {}
Conf.post = {bloom=true,csep=false,bloomSt=3}

la = love.audio
lg = love.graphics
lp = love.physics
lm = love.mouse
lk = love.keyboard

lg.setLineStyle('smooth')
Rng = love.math.newRandomGenerator()
math.randomseed(os.time())
love.math.setRandomSeed(os.time())
Rng:setSeed(os.time())
local pi = math.pi
local sin = math.sin
local cos = math.cos
function rgb(r,g,b,a) return {r/255, g/255, b/255, a and a/255}; end
function updateScaling(wx,wy)
  if wx ~= Scale.wx or wy ~= Scale.wy then
    Canvas1 = lg.newCanvas(wx,wy,{type='2d',format='rgba8',
                                        readable=true,msaa=0})
    Canvas2 = lg.newCanvas(wx,wy,{type='2d',format='rgba8',
                                        readable=true,msaa=0})
    Canvas3 = lg.newCanvas(wx,wy,{type='2d',format='rgba8',
                                        readable=true,msaa=0})
    Scale.wx = wx
    Scale.wy = wy

    local sc = 16/9*wx > wy and wy/1080 or wx/1920

    Scale.sc = sc
    Scale.tx, Scale.ty = wx/2-1920*sc/2, wy/2-1080*sc/2
    Scale.transform = love.math.newTransform(wx/2-1920*sc/2, wy/2-1080*sc/2, 0,
                                            sc,sc,0,0)
    Scale.r0x, Scale.r0y = Scale.transform:inverseTransformPoint(0,0)
    Scale.r1x, Scale.r1y = Scale.transform:inverseTransformPoint(wx,wy)

    Suit.transformer = Scale.transform
    collectgarbage('collect')
  end
end
function love.resize(wx,wy) updateScaling(wx,wy); end

-- Loading libraries and UI
require('util')
Suit    = require('suit')
Json    = require('lib.json')
Chance  = require('lib.chance')
Classic = require('lib.classic')
Stalker = require('lib.stalker')
SplashMaker = require('splash')
UI = require('ui')

UI.color = {
  blank = {
           normal  = {bg = rgb(255, 255, 255), fg = rgb(255, 255, 255)},
           hovered = {bg = rgb(255, 255, 255), fg = rgb(255, 255, 255)},
           active  = {bg = rgb(255, 255, 255), fg = rgb(255, 255, 255)}
         },
  base = {
          normal  = {bg = rgb(191, 39, 39), fg = rgb(207, 207, 207)},
          hovered = {bg = rgb(191, 39, 39), fg = rgb(207, 207, 207)},
          active  = {bg = rgb(255, 69, 69), fg = rgb(255, 255, 255)}
         },
}

-- Loading game assets and shaders
Assets = {}
Assets.font = {}
Assets.font.TurretRoad = lg.newFont('assets/fonts/TurretRoad_M.ttf',50)
Assets.font.KumarOne = lg.newFont('assets/fonts/KumarOne.ttf',140,"light")
Assets.font.MajorMono = lg.newFont('assets/fonts/MajorMono.ttf',130)

Assets.shaders = {bloom={}}

Assets.shaders.bloom[4] = lg.newShader('assets/shaders/bloom4.glsl')

Assets.shaders.bloom[3] = lg.newShader('assets/shaders/bloom3.glsl')

Assets.shaders.bloom[2] = lg.newShader('assets/shaders/bloom2.glsl')

Assets.shaders.bloom[1] = lg.newShader('assets/shaders/bloom1.glsl')

Assets.shaders.chroma = lg.newShader('assets/shaders/chroma.glsl')
Assets.shaders.chroma:send('direction',{cos(pi/4)*3/lg.getWidth(),
                         sin(pi/4)*3/lg.getHeight()})

local vertices = {
  -- top-left
  {
    0,0,
    0,0,
    0.815, 0.330, 0.186
  },
  -- top-right
  {
    700,0,
    1,0,
    0.380, 0.118, 0.729
  },
  -- bottom-right
  {
    700,100,
    1,1,
    0.371, 0.114, 0.738
  },
  -- bottom-left
  {
    0,100,
    0,1,
    0.808, 0.325, 0.200
  },
}

Data.TitleMesh = lg.newMesh(vertices, 'fan')

-- Function used in love.load to restart the game
return function()
  -- Update game scaling
  updateScaling(love.window.getMode())

  -- Sets all game states to initial values
  UI.state = {main='menu',sub1='menu',sub2='menu'}

  World = love.physics.newWorld(0,0,true)
  Body = love.physics.newBody(World, 960,540, 'dynamic')
  Shape = love.physics.newCircleShape(100)
  Fixture = love.physics.newFixture(Body, Shape, 1)

  -- Loading particle systems
  local ptexture = lg.newImage('assets/images/particles.png')
  local quads = {}
  px, py = ptexture:getDimensions()
  quads.line      = lg.newQuad(0,0,     63,63, px,py)
  quads.sine      = lg.newQuad(64,0,    63,63, px,py)
  quads.plus      = lg.newQuad(128,0,   63,63, px,py)
  quads.sqr       = lg.newQuad(192,0,   63,63, px,py)
  quads.sqrFill   = lg.newQuad(0,64,    63,63, px,py)
  quads.circ      = lg.newQuad(64,64,   63,63, px,py)
  quads.circFill  = lg.newQuad(128,64,  63,63, px,py)
  quads.tri       = lg.newQuad(192,64,  63,63, px,py)
  quads.triFill   = lg.newQuad(0,128,   63,63, px,py)
  quads.penta     = lg.newQuad(64,128,  63,63, px,py)
  quads.pentaFill = lg.newQuad(128,128, 63,63, px,py)
  quads.star      = lg.newQuad(192,128, 63,63, px,py)
  quads.starFill  = lg.newQuad(0,192,   63,63, px,py)

  Particles = {}
  Particles.hp = lg.newParticleSystem(ptexture,100)
  Particles.hp:setQuads(quads.plus)
  Particles.hp:setEmissionArea('ellipse',200,100)
  Particles.hp:setParticleLifetime(1.5,3)
  Particles.hp:setEmissionRate(10)
  Particles.hp:setSizes(0.5)
  Particles.hp:setSizeVariation(1)
  Particles.hp:setSpeed(10,30)
  Particles.hp:setLinearAcceleration(0,-10, 0, -30)
  Particles.hp:setDirection(-math.pi/2)
  Particles.hp:setColors(1,0.5,1,0, 1,0.5,1,1, 1,0.5,1,0)

  Particles.line = lg.newParticleSystem(ptexture,1000)
  Particles.line:setQuads(quads.line)
  Particles.line:setEmissionArea('uniform',1920,1080)
  Particles.line:setParticleLifetime(2.5,5)
  Particles.line:setEmissionRate(50)
  Particles.line:setSizeVariation(1)
  Particles.line:setSizes(1,0.6,0.8,0.4,0.9)
  Particles.line:setSpeed(300,500)
  Particles.line:setRelativeRotation(true)
  Particles.line:setLinearAcceleration(-10,0, 50,0)
  Particles.line:setDirection(math.pi/8)
  Particles.line:setColors(1,0,0.3,0, 0.3,0,0.9,1, 1,0.5,0.2,0)

  Particles.circle = lg.newParticleSystem(ptexture,5000)
  Particles.circle:setQuads(quads.circFill)
  Particles.circle:setEmissionArea('ellipse',32,32)
  Particles.circle:setParticleLifetime(0.2,0.3)
  Particles.circle:setEmissionRate(0)
  Particles.circle:setSizeVariation(1)
  Particles.circle:setSizes(0.25,0.22,0.24,0.1,0.3)
  Particles.circle:setSpeed(-155,155)
  Particles.circle:setTangentialAcceleration(-100,100)
  Particles.circle:setSpread(math.pi*2)
  Particles.circle:setColors(1,0.5,0.2,1, 1,0.5,0.3,0.2, 1,0.5,0.3,0)
  Particles.circle:setPosition(960,485)

  Splash = SplashMaker({fill='lighten',background={0,0,0,0},
                        delay_before=0.5,delay_after=0.5})
  Splash.onDone = function()
    State.sfade = 0
    Splash = nil
    collectgarbage('collect')
  end

  collectgarbage('collect')
end
