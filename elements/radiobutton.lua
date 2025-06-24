uiRadioButton = Class(uiElement)

dxLibrary.radioButtonGroups = {}

function uiRadioButton:constructor(array)--groupKey, x, y, parent, state, backgroundColor, checkedColor)
    self.type = 'uiRadioButton'

    self.x = array.x
    self.y = array.y
    self.w = math.round((16/768)*self.screen.y)
    self.h = math.round((16/768)*self.screen.y)
    
    self.groupKey = array.groupKey or 'defaultGroup'
    
    if not dxLibrary.radioButtonGroups[self.groupKey] then
        dxLibrary.radioButtonGroups[self.groupKey] = {
            state = false,
            buttons = {}
        }
    end

    table.insert(dxLibrary.radioButtonGroups[self.groupKey].buttons, self)

    self.font = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font

    self.style = 1
    self.backgroundColor = array.backgroundColor
    self.checkedColor = array.checkedColor
    self.rounded = self.w/2

    if not dxLibrary.radioButtonGroups[self.groupKey].state or array.state then
        dxLibrary.radioButtonGroups[self.groupKey].state = self
    end

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

function uiRadioButton:dx ()
    if (not self:isVisible()) then return end

    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    local w, h, x, y = self.w, self.h, self:getRealXY()
    
    dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, (self.backgroundColor or Color.background), false)

    local group = dxLibrary.radioButtonGroups[self.groupKey]
    if group and group.state == self or self:isCursorOver() then

        local ap = group.state == self and 255 or 255/2
        local r,g,b = color2rgb(self.checkedColor or Color.checked)

        dxDrawImage(x, y, w, h, self.svg2, 0, 0, 0, tocolor(r,g,b, ap), false)
        --dxDrawText2(self.textState or '✔', x - textScale, y - textScale, w - textScale, h - textScale, tocolor(255, 0, 0, ap), textScale, self.font, 'center', 'center', false)
        
    end

    if self.text then
        local margin = 10
        local rectX, rectY = x + w + margin, y
        local textWidth, textHeight = dxGetTextWidth(self.text, self.scale, self.font), h
        
        dxDrawText(self.text, rectX, rectY, textWidth, textHeight + rectY, tocolor(255, 255, 255, 255), self.scale, self.font, 'left', 'center', false)
    end
end

function uiRadioButton:setSelected()
    local group = dxLibrary.radioButtonGroups[self.groupKey]
    group.state = self
end

function uiRadioButton:getSelected()
    local group = dxLibrary.radioButtonGroups[self.groupKey]
    return group.state and group.state == self 
end


