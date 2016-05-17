Bombs = class()

function Bombs:init()
    self.max = 6
    self.x,self.y,self.r,self.s= {},{},{},{} -- x,y,rotation,spin
    for n=1,self.max do
        self.x[n],self.y[n],self.r[n],self.s[n] = 0,HEIGHT * 2,0,0
    end
    self.free = self.max
    self.next = 1
    self.speed = 0
    self.spin = 0
    self.onCatch = function() end
    self.onMiss = function() end
    self.flower = false
end

function Bombs:reset(level)
    self.flower = false
    if level == 1 then
        self.speed = HEIGHT * 0.004
        self.spin = 1.6
    elseif level == 2 then
        self.speed = HEIGHT * 0.007
        self.spin = 2
    elseif level == 3 then
        self.speed = HEIGHT * 0.012
        self.spin = 2.4
    elseif level == 4 then
        self.speed = HEIGHT * 0.018
        self.spin = 2.8
    elseif level == 5 then
        self.speed = HEIGHT * 0.025
        self.spin = 3.2
    elseif level == 6 then
        self.speed = HEIGHT * 0.033
        self.spin = 3.6
    end
end

function Bombs:draw(scene)
    local max = self.max
    local speed,spin = self.speed,self.spin
    local x,y,r,s = self.x,self.y,self.r,self.s
    local flower = self.flower
    for n=1,max do
        if y[n] < -64 then
            self.onMiss(scene, x[n],y[n],r[n])
            y[n] = HEIGHT * 2
            self.free = self.free + 1
        elseif y[n] < HEIGHT then
            if bucket:canCatchBomb(x[n],y[n]) then
                self.onCatch(scene)
                y[n] = HEIGHT * 2
                self.free = self.free + 1
            end
            pushMatrix()
            if r[n] > 0 then r[n] = r[n] + s[n]
            elseif r[n] < 0 then r[n] = r[n] - s[n] end
            y[n] = y[n] - speed
            translate(x[n],y[n])
            rotate(r[n])
            if flower then
                local f = n % 3
                if f == 0 then sprite("Project:Bucket-Flower01")
                elseif f == 1 then sprite("Project:Bucket-Flower02")
                else sprite("Project:Bucket-Flower03")
                end
            else
                sprite("Project:Bucket-Bomb")
            end
            popMatrix()
        end
    end
end

function Bombs:drop(x,y,direction)
    if self.free > 0 then
        local n = self.next
        self.x[n],self.y[n] = x,y
        self.r[n] = direction
        if rand() < 0.05 then
            self.s[n] = 19
        else
            self.s[n] = self.spin
        end
        self.free = self.free - 1
        if n >= self.max then self.next = 1
        else self.next = n + 1 end
    end
end

function Bombs:clear()
    local max = self.max
    local y = self.y
    for n=1,max do
        y[n] = HEIGHT * 2
    end
    self.free = max
end
