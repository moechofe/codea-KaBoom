Monster = class()

function Monster:init()
    self.x = WIDTH / 2
    self.y = HEIGHT * 0.83
    self.speed = 0
    self.leftBound = WIDTH * 0.12
    self.leftSlow = WIDTH * 0.14
    self.rightBound = WIDTH - self.leftBound
    self.rightSlow = WIDTH - self.leftSlow
    self.dropWait = 0
    self.dropIn = 0
    self.cooldown = 0
    self.levelUping = false
    self.levelUpingTid = false
    self.levelUpingFrame = 0
    self.revertChance = 0
    self.revertLeft = WIDTH * 0.3
    self.revertRight = WIDTH * 0.7
    self.soundSequence = 1
end

function Monster:reset(level)
    if level == 0 then
        self.speed = WIDTH * 0.001
        self.dropWait = 0
        self.revertChance = 0
    elseif level == 1 then
        self.speed = WIDTH * 0.004
        self.dropWait = 60
        self.cooldown = 60
        self.dropIn = 0
        self.revertChance = 0
    elseif level == 2 then
        self.speed = WIDTH * 0.006
        self.cooldown = 40
        self.dropWait = 40
        self.dropIn = 40
        self.revertChance = 0.01
    elseif level == 3 then
        self.speed = WIDTH * 0.008
        self.cooldown = 30
        self.dropWait = 30
        self.dropIn = 30
        self.revertChance = 0.03
    elseif level == 4 then
        self.speed = WIDTH * 0.012
        self.cooldown = 20
        self.dropWait = 20
        self.dropIn = 20
        self.revertChance = 0.05
    elseif level == 5 then
        self.speed = WIDTH * 0.016
        self.cooldown = 10
        self.dropWait = 10
        self.dropIn = 10
        self.revertChance = 0.08
    elseif level == 6 then
        self.speed = WIDTH * 0.024
        self.cooldown = 10
        self.dropWait = 10
        self.dropIn = 10
        self.revertChance = 0.2
    end
end

function Monster:stop()
    self.dropWait = 0
    self.dropIn = 0
end

function Monster:levelUp()
    sound("Project:Bucket-LevelUp")
    self.levelUping = true
    self.speed = 0
    self.levelUpingTid = tween(0.4, self, {levelUpingFrame=2}, {loop=tween.loop.forever})
    tween.delay(1.5, function()
        self.levelUping = false
        tween.stop(self.levelUpingTid)
    end)
end

function Monster:draw()
    pushStyle()
    pushMatrix()
    
    if self.x < self.leftBound or self.x > self.rightBound then
        self.speed = -self.speed
    elseif self.x > self.revertLeft and self.x < self.revertRight then
        if rand() <= self.revertChance then
            self.speed = -self.speed
        end
    end
    
    if (self.x < self.leftSlow and self.speed < 0) or
    (self.x > self.rightSlow and self.speed > 0) then
        self.x = self.x + self.speed / 2
    else
        self.x = self.x + self.speed
    end
        
    translate(self.x, self.y)
    if self.levelUping then
        pushMatrix()
        scale(1.4)
        translate(0,25)
        if self.levelUpingFrame <= 1 then sprite("Project:Bucket-LevelUp01")
        else sprite("Project:Bucket-LevelUp02") end
        popMatrix()
        
        translate(random(-5,5),random(-5,5))
    end
    sprite("Project:Bucket-Monster")
    
    if self.dropWait > 0 then
        if self.dropIn < 1 then
            bombs:drop(self.x,self.y,self.speed * self.x)
            self.dropIn = self.dropWait
            if self.soundSequence == 1 then
                sound("Project:Bucket-Kick",0.6)
                self.soundSequence = self.soundSequence + 1
            elseif self.soundSequence == 2 then
                sound("Project:Bucket-Hihat",0.4)
                self.soundSequence = self.soundSequence + 1
            elseif self.soundSequence == 3 then
                sound("Project:Bucket-Snare",0.4)
                self.soundSequence = self.soundSequence + 1
            elseif self.soundSequence == 4 then
                sound("Project:Bucket-Hihat",0.4)
                self.soundSequence = 1
            end
        else
            self.dropIn = self.dropIn - 1
        end
    end
    
    popMatrix()
    popStyle()
end
