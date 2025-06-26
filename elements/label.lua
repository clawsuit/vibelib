uiLabel = Class(uiElement)

function uiLabel:constructor (array)--text, x, y, w, h, parent, color, scale, font, alignX, alignY, postGUI, colorCoded)

    self.type = 'uiLabel'
    self.element = Element(self.type)

    self.text = array.text or ''
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h

    self.textColor = array.color
    self.scale = array.scale or 1
    self.font = array.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.alignX = array.alignX or 'left'
    self.alignY = array.alignY or 'center'
    self.clip = true
    self.wordBreak = true
    self.postGUI = array.postGUI or false
    self.colorCoded = array.colorCoded or false

    dxLibrary.instances[self.element] = self

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    --print(self.type, self.x, self.y, self.w, self.h, self:getRealXY())
    return self
end

function uiLabel:dx (tick)

    if (not self:isVisible()) then return end

    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local w, h, x, y = self.w, self.h, self:getRealXY()
    
  --- print(x, y, w, h)
    if self.underline then
        local v = self.underline
        local textWidth = dxGetTextWidth(self.text, self.scale, self.font, self.colorCoded)
        local textHeight = dxGetFontHeight(self.scale, self.font)     
        local offsetX = self.alignX == 'center' and ( x+self.w/2 - textWidth/2 ) or ( self.alignX == 'right' ) and x-( textWidth ) + self.w or x
        local offsetY = (self.alignY == 'center' and ( y+((self.h*0.7)/2) + textHeight/2)) or (self.alignY == 'bottom' and y+self.h*0.85) or y+textHeight*0.7

        --dxDrawRectangle(x, y, w, h, tocolor(0, 255, 0, 100))
        if v.text then
            dxDrawText2(string.rep(v.text, #self.text), x, y, w, h, (self.textColor or Color.text), self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, true, self.colorCoded)
        else
            dxDrawLine( offsetX, offsetY, offsetX + textWidth, offsetY, v.color, v.size)
        end
    end

    if self.shadow then
        local v = self.shadow

        dxDrawBorderedText(v.radius[1], v.radius[2], self.text, x, y, w, h, (self.textColor or Color.text), v.color, self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, self.colorCoded)
    else
        dxDrawText2(self.text, x, y, w, h, (self.textColor or Color.text), self.scale, self.font, self.alignX, self.alignY, self.clip, self.wordBreak, self.postGUI, self.colorCoded)
    end

    if self:isCursorOver() then
        if not self.isOver then
            if self.onHover then
                self:onHover('enter')
            end
            self.isOver = true 
        end
    elseif self.isOver then
        if self.onHover then
            self:onHover('leave')
        end
        self.isOver = nil
    end
end

function uiLabel:setShadow(r, r2, c)
    self.shadow = {radius = {r, r2}, color = c}
end

function uiLabel:setUnderline(s, c, t)
    self.underline = {size = s, color = c, text = t}
end

-- if localPlayer.name == 'RattyAntelope26' then
    
-- end
