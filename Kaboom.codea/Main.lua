--# KaBoom
--- ======

supportedOrientations(LANDSCAPE_ANY)
displayMode(FULLSCREEN)
backingMode(RETAINED)
    
function setup()
    -- local i=readImage("Project:Bucket-Icon")
    -- saveImage("Project:Icon", i)
    scenery = Scenery()
    monster = Monster()
    bucket = Bucket()
    bombs = Bombs()
    switchScene(Board())
end

function switchScene(new)
    if scene then scene:tearDown() end
    scene = new
    scene:setUp()
end

function draw()
    scene:draw(scene)
end

function touched(t)
    scene:touched(scene,t)
end

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function rand()
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

function random(min,max)
    return math.floor(rand()*max) + min
end