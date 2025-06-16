uiCheckbox = Class(uiElement)

function uiCheckbox:constructor (array) --x, y, w, h, parent, state
    self.type = 'uiCheckbox'

    self.x = array.x
    self.y = array.y
    self.w = math.round((14/768)*self.screen.y)--array.w
    self.h = math.round((14/768)*self.screen.y)--array.w
    
    self.text = array.text or ''
    self.textState = array.textState or '✔'
    self.state = array.state or false
    self.font = array.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.fontH = dxGetFontHeight(self.textScale, self.font)

    self.style = array.style or 1
    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.backgroundAlpha = 0
    self.outline = array.outline or 3
    self.outlineColor = -1
    self.rounded = array.rounded or 4
    self.selectedColor = {color2rgb(array.selectedColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].selectedColor)}

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    self:updateSvg()

    return self
end

function uiCheckbox:dx ()
    if (not self:isVisible()) then return end

    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    local w, h, x, y = self.w, self.h, self:getRealXY()

    dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, tocolor(255, 255, 255, 255), false)

    if self.state or self:isCursorOver() then
        local ap = self.state and 255 or 255/2
        local textScale = (self.w-self.outline) / self.fontH

        dxDrawText2(self.textState, x+(self.outline/2), y, w-self.outline/2, h, tocolor(self.selectedColor[1], self.selectedColor[2], self.selectedColor[3], ap), textScale, self.font, 'center', 'center', false)
    end

    if #self.text > 0 then
        local margin = 5
        local rectX, rectY = x + w + margin, y
        --local textWidth, textHeight = dxGetTextWidth(self.text, self.scale, self.font), h
        
        dxDrawText2(self.text, rectX, rectY, 1, h+self.rounded, tocolor(255, 255, 255, 255), self.scale, self.font, 'left', 'center', false)
    end
end

function uiCheckbox:setState(bool)
    self.state = bool
end

function uiCheckbox:setStyle(number)
    if number == 2 then
        self.backgroundColor = tocolor(0, 0, 0, 255)
        self.outline = 5
        self.outlineColor = 1522
    elseif number == 1 then
        self.backgroundColor = tocolor(0, 0, 0, 0)
        self.outline = 3
        self.outlineColor = 1522
    end

    self:updateSvg()
    self.style = number
end

function uiCheckbox:setText(text, scale, font)
    self.text = text or ''
    self.scale = scale or 1
    self.font = font or self.font
end

function uiCheckbox:setTextState(text)
    self.textState = text or '✔'
end

function uiCheckbox:getState()
    return self.state
end



--check:setStyle(2)