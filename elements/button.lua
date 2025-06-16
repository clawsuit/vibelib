uiButton = Class(uiElement)

function uiButton:constructor(array)--text, x, y, w, h, parent, rounded, backgroundColor, textColor, hoverColor)
    self.type = 'uiButton'

    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.circle and self.w or array.h

    self.circle = array.circle
    self.text = array.text or ''
    self.textFont = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].textFont

    self.image = image
    self.imageAlign = imageAlign or 'left'

    self.backgroundColor = array.backgroundColor
    self.textColor       = array.textColor
    self.hoverColor      = array.hoverColor 

    self.outline = 0
    self.outlineColor = -1
    self.rounded = tonumber(array.rounded) or 5
    self.effect = 1

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


function uiButton:setOutline(radius, color)
    if tonumber(radius) then
        self.outline = radius
    end
    if tonumber(color) then
        self.outlineColor = color
    end

    if tonumber(color) or tonumber(radius) then
        self:updateSvg()
    end
end


function uiButton:addImage(offX, offY, w, h, image, align, color)
    self.image = {x=2+self:calc(self.w, offX or 0), y=2+self:calc(self.h, offY or 0), w=self:calc(self.h, w)-4, h=self:calc(self.h, h)-8, texture=image, align=align or 'left', color=color}
end 

function uiButton:dx(tick)
    
    if not isElement(self.svg) then return end
    if (not self:isVisible()) then return end

    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()

    local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        px, py = x, y
        x, y = self.x, self.y
    end

    local color = self.backgroundColor or Color.background

    if self:isCursorOver() then
        if self.effect == 1 then

            if click then

                local o = 1.2
                x, y, w, h = x+o, y+o, w-o*2, h-o*2

            end
        else

            color = self.hoverColor or Color.hover
        end
    end

    --dxSetBlendMode( 'add' )
        local r,g,b = color2rgb(color)
        dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, tocolor(r,g,b))
    --dxSetBlendMode('blend')

    if self.image then

        local v = self.image
        local x, y = x + v.x + (self.circle and self.rounded-4 or 0), y + v.y + (h-8-v.h)/2 - (self.circle and 2 or 0)

        if v.align == 'left' then

        elseif v.align == 'center' then
            x = x + (w - v.w) / 2 - self.rounded
        elseif v.align == 'right' then
            x = x + w - v.w
        end

        dxDrawImage(x, y, v.w, v.h, v.texture, 0, 0, 0, v.color)

    end

    dxSetBlendMode( 'modulate_add' )
        dxDrawText2(self.text, x-1, y-1, w, h, (self.textColor or Color.text), 1, self.textFont, "center", "center", false, false, false, false)
    dxSetBlendMode('blend')

    self.click = getKeyState('mouse1')
end



