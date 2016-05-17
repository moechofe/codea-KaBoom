HiScore = class()

function HiScore:init(score)
    self.hiscore = score
    self.score = string.format("Who made the score: %d?",score)
    self.name = ""
end

function HiScore:setUp()
    showKeyboard()
end

function HiScore:tearDown()
    hideKeyboard()
end

function HiScore:draw(scene)
    scenery:draw()

    pushStyle()
    pushMatrix()
    font("DINAlternate-Bold")
    fontSize(HEIGHT * 0.07)
    translate(WIDTH * 0.5, HEIGHT * 0.90)
    fill(0,0,0,127)
    text(self.score)
    translate(0,5)
    fill(255)
    text(self.score)
    popStyle()
    popMatrix()

    pushStyle()
    pushMatrix()
    font("DINAlternate-Bold")
    fontSize(HEIGHT * 0.17)
    translate(WIDTH * 0.5, HEIGHT * 0.7)
    fill(0,0,0,127)
    text(keyboardBuffer())
    translate(0,5)
    fill(255)
    text(keyboardBuffer())
    popStyle()
    popMatrix()
    
    if not isKeyboardShowing() then
        if keyboardBuffer() == "" then
            showKeyboard() 
        else
            saveLocalData("hiscore",self.hiscore)
            saveLocalData("hiname",keyboardBuffer())
            switchScene(Board())
        end
    end
end

function HiScore:touched(t)
    showKeyboard()
end