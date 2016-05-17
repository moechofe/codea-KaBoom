Scenery = class()

function Scenery:init()
    self.bgAlpha = 127
    self.levelUpingTid = false
    self.cityX = WIDTH * 0.5
end

function Scenery:reset(level)
    if level <= 1 then
        self.bgColor = vec4(245,191,73, self.bgAlpha)
        self.tintColor = color(172,218,33)
    elseif level == 2 then
        self.bgColor = vec4(172,218,33, self.bgAlpha)
        self.tintColor = color(55,221,229)
    elseif level == 3 then
        self.bgColor = vec4(55,221,229, self.bgAlpha)
        self.tintColor = color(175,117,226)
    elseif level == 4 then
        self.bgColor = vec4(175,117,226, self.bgAlpha)
        self.tintColor = color(247,110,115)
    elseif level == 5 then
        self.bgColor = vec4(247,110,115, self.bgAlpha)
        self.tintColor = color(123,123,123)
    elseif level == 6 then
        self.bgColor = vec4(82,82,82, self.bgAlpha)
        self.tintColor = color(201,201,201)
    end
end

function Scenery:draw()
    local bgColor = self.bgColor
    pushStyle()
    pushMatrix()
    fill(color(bgColor.x,bgColor.y,bgColor.z,bgColor.w))
    rect(0,0,WIDTH,HEIGHT)
    tint(self.tintColor)
    translate(self.cityX,128)
    sprite("Project:Bucket-City")
    popMatrix()
    popStyle()   
end

function Scenery:levelUp()
    local actual = self.bgColor
    local target = {
        bgColor = vec4(actual.r,actual.g,actual.b,actual.a)
    }
    self.bgColor = vec4(255,255,255,255)
    if self.levelUpingTid then tween.stop(self.levelUpingTid) end
    self.levelUpingTid = tween(0.9, self, target, tween.easing.quadIn)
end