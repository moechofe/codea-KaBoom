Bucket = class()

function Bucket:init()
    self.x,self.y = WIDTH / 2,HEIGHT * 0.17
    self.target = self.x
    self.maxSpeed = WIDTH * 0.3
    self.leftBound = WIDTH * 0.06
    self.rightBound = WIDTH - self.leftBound
    self.catchUp = self.y + 45
    self.catchDown = self.y - 60
    self.catchSide = 50
    self.tid = false
end

function Bucket:draw()
    pushMatrix()
    local diff = self.target - self.x
    local max = self.maxSpeed
    if diff > max then self.x = self.x + max
    elseif diff < -max then self.x = self.x - max
    else self.x = self.target end
    translate(self.x,self.y)
    sprite("Project:Bucket-Bucket")
    popMatrix()
end

function Bucket:touched(t)
    if self.tid == t.id and t.state == ENDED then
        self.tid = false
    elseif not self.tid and t.state == BEGAN or self.tid == t.id then
        self.tid = t.id
        self.target = math.max(math.min(t.x,self.rightBound),self.leftBound)
    end
end

function Bucket:canCatchBomb(x,y)
    return x > self.x - self.catchSide and
    x < self.x + self.catchSide and
    y > self.catchDown and
    y < self.catchUp
end
