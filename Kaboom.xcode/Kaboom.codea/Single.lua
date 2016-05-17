        Single = class()

function Single:init()
    self.level = 1
    self.tutoShown = false
    self.tutoHeight = HEIGHT * 0.11
    self.tutoX = WIDTH * 0.5
    self.tutoY = HEIGHT * 0.6
    self.tutoTid = false
    self.score = "0"
    self.bonus = "0"
    self.nextLiveAt = 200
    self.total = "0"
    self.scoreTint = color(255)
    self.scoreShown = false
    self.titleHeight = HEIGHT * 0.06
    self.scoreHeight = HEIGHT * 0.3
    self.bonusX = WIDTH * 0.5
    self.titleY = HEIGHT * 0.8
    self.scoreY = WIDTH * 0.12
    self.scoreOnCatch = 1
    self.bonusOnCatch = 1
    self.bombsToLevelUp = 0
    self.lives = 1
    self.liveX = WIDTH * 0.05
    self.liveY = HEIGHT - self.liveX
    self.failShown = false
    self.failX = 0
    self.failY = 0
    self.failBombScale = 0
    self.failSkyColor = vec4(0,0,0,0)
    self.allShake = false
    self.failFlash = 0
    self.failCityAlpha = 0
    self.overShown = false
end

function Single:reset(level)
    if level == 1 then
        self.scoreTint = color(198,141,16)
        self.bombsToLevelUp = 10
    elseif level == 2 then
        self.scoreTint = color(117,190,37)
        self.bombsToLevelUp = 14
    elseif level == 3 then
        self.scoreTint = color(65,154,190)
        self.bombsToLevelUp = 18
    elseif level == 4 then
        self.scoreTint = color(132,81,178)
        self.bombsToLevelUp = 22
    elseif level == 5 then
        self.scoreTint = color(200,72,77)
        self.bombsToLevelUp = 26
    elseif level == 6 then
        self.scoreTint = color(0,0,0)
        self.bombsToLevelUp = 0
    end
end

function Single:setUp()
    music("Project:Bucket-City")
    self.level = 1
    self:reset(1)
    self.tutoShown = true
    self.tutoY = HEIGHT * 0.6
    self:switchTutoShown()
    tween.delay(1.8, self.tutoToScore, self)
    self.bonus = "0"
    self.scoreShown = false
    bombs.onCatch = self.bombsCatched
    bombs.onMiss = self.bombsMissed    
    scenery:reset(1)
    monster:reset(1)
    bombs:reset(1)
end

function Single:tearDown()
    music.stop()
    bombs.onCatch = function() end
    bombs.onMiss = function() end
end

function Single:draw(scene)
    local rand = math.random
    if self.allShake then
        translate(rand(-2,2),rand(-2,2))
    end

    scenery:draw()
    
    if self.lives == 1 then
        pushMatrix()
        translate(self.liveX, self.liveY)
        scale(0.2)
        sprite("Project:Bucket-Heart",0,0)
        popMatrix()
    end
    
    if self.tutoShown then
        pushMatrix()
        pushStyle()
        self.tutoY = self.tutoY - bombs.speed
        font("DINCondensed-Bold")
        fontSize(self.tutoHeight)
        translate(self.tutoX,self.tutoY)
        fill(0,0,0,127)
        text("Guide the bucket, catch the bombs!")
        translate(0, 5)
        fill(255)
        text("Guide the bucket, catch the bombs!")
        popStyle()
        popMatrix()
    end
    
    if self.scoreShown then
        pushStyle()
        font("DINAlternate-Bold")
        fill(self.scoreTint)
        
        if self.overShown then
            
            pushMatrix()
            fontSize(self.titleHeight)
            translate(WIDTH/2,self.titleY)
            text("Score")
            fontSize(self.scoreHeight)
            translate(0,-self.scoreY)
            text(self.total)
            popMatrix()
            
        else
            
            pushMatrix()
            fontSize(self.titleHeight)
            translate(self.bonusX,self.titleY)
            text("Score")
            fontSize(self.scoreHeight)
            translate(0,-self.scoreY)
            text(self.bonus)
            popMatrix()
            
        end
        
        popStyle()
    end

    monster:draw()
    
    if self.overShown then
        pushStyle()
        pushMatrix()
        
        font("DINCondensed-Bold")
        fill(self.scoreTint)
        fontSize(self.scoreHeight)
        translate(WIDTH/2,HEIGHT*0.35)
        text("Game Over")
        
        popMatrix()
        pushMatrix()
    else
        bucket:draw()
    end
    
    bombs:draw(scene)
    
    pushStyle()
    local skyColor = self.failSkyColor
    fill(skyColor.x,skyColor.y,skyColor.z,skyColor.w)
    rect(-5,5,WIDTH+5,HEIGHT+5)
    popStyle()
    
    if self.failShown then
        pushStyle()
        
        pushMatrix()
        translate(0,40)
        
        if self.failBombScale > 0.02 then
            pushMatrix()
            fill(253,255,88,127)
            translate(self.failX,self.failY)
            scale(self.failBombScale)
            ellipse(0,0,640,540)
            fill(253,255,88,255)
            popMatrix()
            
            pushMatrix()
            translate(self.failX + rand(-5,5),self.failY + rand(-5,5))
            scale(self.failBombScale)
            ellipse(0,0,630,530)
            popMatrix()
            
            pushMatrix()
            fill(254,255,218)
            translate(self.failX,self.failY)
            scale(self.failBombScale)
            ellipse(0,0,600,500)
            popMatrix()
        end
        
        popMatrix()
        
        pushMatrix()
        tint(255,255,255,self.failCityAlpha)
        sprite("Project:Bucket-City",scenery.cityX,124)
        popMatrix()
        
        popStyle()
    end
    
    if self.failFlash > 0 then
        background(255)
        self.failFlash = self.failFlash - 1
    end
    
end

function Single:touched(scene,t)
    if self.overShown then
        if t.state == BEGAN then
            self.startTouch = t.id
            self.startTouchPos = vec2(t.x,t.y)
        elseif t.state == ENDED then
            if self.startTouch == t.id then
                if vec2(t.x,t.y):dist(self.startTouchPos) < WIDTH * 0.03 then
                    tween.stopAll()
                    if tonumber(self.total) > tonumber(readLocalData("hiscore")) then
                        switchScene(HiScore(self.total))
                    else
                        switchScene(Board())
                    end
                end
            end
            self.startTouch = false
        end 
    else
        bucket:touched(t)
    end
end

function Single:switchTutoShown()
    if self.tutoShown then
        self.tutoShown = false
        self.tutoTid = tween.delay(0.1, self.switchTutoShown, self)
    else
        self.tutoShown = true
        self.tutoTid = tween.delay(0.6, self.switchTutoShown, self)
    end
end

function Single:tutoToScore()
    self.tutoShown = false
    tween.stop(self.tutoTid)
    self.scoreShown = true
end

function Single:bombsMissed(x,y,r)
    self.failX = x
    self.failY = y
    self.failBombScale = 1
    self.failSkyColor = vec4(0,0,95,15)
    
    tween.sequence(
        tween(0.4, self, {
            failSkyColor = vec4(0,0,95,175)
        }, tween.easing.linear, function()
            sound("Project:Bucket-BombFront02")
        end),
        tween(0.2, self, {
            failSkyColor = vec4(0,0,95,255)
        }, tween.easing.linear, function()
            self.failShown = true
            self.failCityAlpha = 255
            self.failFlash = 10
            sound("Project:Bucket-BombFront01")
        end),
        tween(0.8, self, {
            failBombScale = 1.3
        }),
        tween(3.2, self, {
            failBombScale = 0.01
        }, tween.easing.quintIn, function()
            sound("Project:Bucket-BombBack02")
            self.allShake = false
        end),
        tween(1.6, self, {
            failSkyColor = vec4(0,0,0,0),
            failCityAlpha = 0
        }, tween.easing.linear, function()
            self.failShown = false
            if not self.overShown then
                monster:reset(self.level)
            else
                local flowerDrop
                flowerDrop = function()
                    bombs:drop(monster.x,monster.y,monster.speed)
                    tween.delay(1,flowerDrop)
                end
                monster:reset(0)
                bombs:clear()
                bombs.speed = HEIGHT * 0.002
                bombs.spin = 1.6
                bombs.flower = true
                bombs.onMiss = function() end
                bombs.onCatch = function() end
                flowerDrop()
                music("Project:Bucket-Over",true,0.5)
            end
        end)
    )

    sound("Project:Bucket-LevelDown")
    sound("Project:Bucket-Panic",0.3)
    sound("Project:Bucket-BombBack01")

    self.allShake = true
    bombs:clear()
    monster:stop()
    
    if self.lives >= 1 then
        self.lives = self.lives - 1
        self.level = math.max(1, self.level - 1)
        self:reset(self.level)
        scenery:reset(self.level)
        bombs:reset(self.level)
    elseif self.lives == 0 then
        self.total = tostring(tonumber(self.score) + tonumber(self.bonus))
        tween.delay(1, function()
            self.overShown = true
        end)
    end

end

function Single:bombsCatched()
    local min = math.min
    local bonus = min(9999,tonumber(self.bonus) + self.bonusOnCatch * self.level)
    self.bonus = tostring(bonus)
    if bonus > self.nextLiveAt then
        if self.lives < 1 then
            self.lives = 1
            sound("Project:Bucket-OneUp")
        end
        self.nextLiveAt = self.nextLiveAt + 200
    end
    
    local s = random(1,6)
    if s == 1 then sound("Project:Bucket-Catch01")
    elseif s == 2 then sound("Project:Bucket-Catch02")
    elseif s == 3 then sound("Project:Bucket-Catch03")
    elseif s == 4 then sound("Project:Bucket-Catch04")
    elseif s == 5 then sound("Project:Bucket-Catch05")
    elseif s == 6 then sound("Project:Bucket-Catch06") end
    
    if self.bombsToLevelUp == 1 then
        self.bombsToLevelUp = 0
        monster:stop()
        monster:levelUp()
        scenery:levelUp()
        tween.delay(1, function()
            sound("Project:Bucket-Speeder")
            self.level = self.level + 1
            self:reset(self.level)
            scenery:reset(self.level)
            bombs:reset(self.level)
            monster:reset(self.level)
        end)
    else
        self.bombsToLevelUp = self.bombsToLevelUp - 1
    end
end
