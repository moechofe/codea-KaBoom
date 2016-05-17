-- Kaboom

Board = class()

function Board:init()
    self.startShown = false
    self.showWait = 0
    self.startShownTid = false
    self.startTouchPos = false
    self.startTouch = false
    bombs:clear()
    if not readLocalData("hiname") then saveLocalData("hiname","Arika") end
    if not readLocalData("hiscore") then saveLocalData("hiscore","666") end
end

function Board:setUp()
    local m = random(1,2)
    if m == 1 then music("Project:Bucket-Menu01",true)
    elseif m == 2 then music("Project:Bucket-Menu02",true) end
    scenery:reset(0)
    monster:reset(0)
    self:switchStartShown()
end

function Board:tearDown()
    music.stop()
    tween.stop(self.startShownTid)
end

function Board:draw(scene)    
    scenery:draw()
    
    pushMatrix()
    pushStyle()
    translate(WIDTH * 0.5, HEIGHT * 0.93)
    font("DINAlternate-Bold")
    fontSize(HEIGHT * 0.05)
    fill(0,0,0,127)
    local l=string.format("%s: %d",readLocalData("hiname"),readLocalData("hiscore"))
    text(l)
    translate(0, 5)
    fill(255)
    text(l)
    popStyle()
    popMatrix()
    
    monster:draw()
    
    if self.startShown then
        pushStyle()
        pushMatrix()
        font("DINCondensed-Bold")
        fontSize(HEIGHT * 0.11)
        translate(WIDTH * 0.5,HEIGHT * 0.4)
        fill(0,0,0,127)
        text("- tap to start -")
        translate(0, 5)
        fill(255)
        text("- tap to start -")
        popStyle()
        popMatrix()
    end
end

function Board:touched(scene,t)
    if t.state == BEGAN then
        self.startTouch = t.id
        self.startTouchPos = vec2(t.x,t.y)
    elseif t.state == ENDED then
        if self.startTouch == t.id then
            if vec2(t.x,t.y):dist(self.startTouchPos) < WIDTH * 0.03 then
                switchScene(Single())
            end
        end
        self.startTouch = false
    end 
end

function Board:switchStartShown()
    if self.startShown then
        self.startShown = false
        self.startShownTid = tween.delay(0.4, self.switchStartShown, self)
    else
        self.startShown = true
        self.startShownTid = tween.delay(0.8, self.switchStartShown, self)
    end
end