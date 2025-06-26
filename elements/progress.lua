uiProgress = Class(uiElement)


function uiProgress:constructor(array)--x, y, w, h, parent, mode, rounded, backgroundColor, progressColor)
    self.type = 'uiProgress'
    self.mode = math.max(1, math.min(tonumber(array.mode) or 1, 2))
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = self.mode == 1 and array.w or array.h

    self.progress = 0

    self.backgroundColor  = array.backgroundColor
    self.progressColor = array.rogressColor

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end


    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()

    if self.mode == 1 then
        self.rounded = math.min(self.w, self.h) / 2
        self.roundedLenght = 2 * math.pi * self.rounded
        self.lineWidth = tonumber(array.rounded) or 8
    elseif self.mode == 2 then
        self.rounded = array.rounded or 5
    end
 
 --iprint(self.x, self.y, self.w, self.h)
    self:updateSvg()

    return self
end

function uiProgress:dx(tick)

	if not isElement(self.svg) then return end
    if (not self:isVisible()) then return end

    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    self.click = getKeyState( 'mouse1' )

    local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        x, y = self.x, self.y
    end

    dxDrawImage(x, y, w, h, self.svg)

    if self.mode == 2 then
        dxDrawImageSection(x, y, w*self.progress, h, 0, 0, w*self.progress, h, self.svg2)
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

function uiProgress:setProgress(progress)
    self.progress = (progress > 1 and 1) or (progress < 0 and 0) or progress
    if (self.mode == 1) and self.xml and isElement(self.svg) then
        local rect = self.xml:findChild('circle', 1)
        rect:setAttribute('stroke-dashoffset', '-'..(self.roundedLenght*(1-self.progress)))
        svgSetDocumentXML(self.svg, self.xml)
    end
end

