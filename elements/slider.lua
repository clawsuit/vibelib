uiSlider = Class(uiElement)


function uiSlider:constructor(array)--x, y, w, parent, vertical)
    self.type = 'uiSlider'

    self.vertical = array.vertical

    self.x = array.x
    self.y = array.y
    self.w = self.vertical and 12.294 or array.w
    self.h = not self.vertical and 12.294 or array.w

    self.cx = 0
    self.cw = math.max(15, math.min(0.01 * self.screen.y, 19.02))

    self.backgroundColor  = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.backgroundColor2 = array.backgroundColor2 or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background2
    self.circleColor      = array.circleColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].circle

    self.rounded = 4

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

function uiSlider:dx(tick)
    
    if not isElement(self.svg) then return end
    if (not self:isVisible()) then return end

    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    self.click = getKeyState( 'mouse1' )

    local w, h, x, y = self.w, self.h, self:getRealXY()

    local cw = self.cw
    local px, py = math.min(x+w-cw, x+self.cx), (y+(h-cw)/2 - 1)

    if self.vertical then
        px, py = (x+(w-cw)/2 - 1), math.min(y+h-cw, y+self.cx)
    end

    dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, self.backgroundColor)

    if self.vertical then
        dxDrawImageSection(x, y, w, h*self:getProgress(), 0, 0, w, h*self:getProgress(), self.svg, 0, 0, 0, self.backgroundColor2)
    else
        dxDrawImageSection(x, y, w*self:getProgress(), h, 0, 0, w*self:getProgress(), h, self.svg, 0, 0, 0, self.backgroundColor2)
    end
   
    dxDrawImage(px, py, cw, cw, self.svg2, 0, 0, 0, self.circleColor)

    if self:isCursorOver('circleSlider') and click then
        local cancel
        if self.onClick then
            cancel = self:onClick('left', 'down')
            self.pre = true
        end

        if not self.onClick or cancel ~= false then
            self.movePos = self:getCursor()
        end
    end

    if self:isCursorOver('circleSlider') and not self.click and self.pre then
        self:onClick('left', 'up')
        self.pre = nil
    end

    if not self.click and self.movePos then
        self.movePos = nil
    end

    if self.move then
        if self.movePos then

            local cursor = self:getCursor()
            local cursor = cursor - self.movePos
            local old, cx, cancel = self.cx

            if self.vertical then
                cx = math.max(0, math.min(self.cx + cursor.y, h))
            else
                cx = math.max(0, math.min(self.cx + cursor.x, w))  
            end

            if self.cx ~= cx then
                self.cx = cx
                if self.onChange then
                    cancel = self:onChange(self:getProgress())
                end
            end

            if cancel then
               self.cx = old
            end

            self.movePos = self:getCursor()

        end
    end
end

function uiSlider:getProgress()
    return self.cx/((self.vertical and self.h or self.w))
end

function uiSlider:setProgress(pos)
    self.cx = pos*((self.vertical and self.h or self.w))
end


