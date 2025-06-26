uiScroll = Class(uiElement)
  

function uiScroll:constructor(array)--x, y, wh, parent, vertical, backgroundColor, progressColor)
    self.type = 'uiScroll'
    self.vertical = array.vertical

    self.x = array.x
    self.y = array.y

    if self.vertical then
        self.w = math.round((11.96/768)*self.screen.y)
        self.h = array.w
    else
        self.w = array.w
        self.h = math.round((11.96/768)*self.screen.y)
    end
 
    self.rounded = math.round((5/768)*self.screen.y)--5

    self.pos = 0 
    self.from = 0 
    self.to = 0
    
    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.progressColor = array.progressColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].progressColor

    self.easing = 'SineCurve'
    self.tick = getTickCount()
    self.lapse = 150

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and (dxLibrary.parentValids[array.parent.type] or array.parent.type == 'uiGridList' or array.parent.type == 'uiMemo') then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end
    table.insert(dxLibrary.mouseWheels, self)

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    self:updateSvg()

    return self
end

function uiScroll:dx(tick)
    if (not self:isVisible()) then return end
    --if (self.attached and not self.attached.visible) then return end
    if not isElement(self.svg) then return end

    --local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    self.click = getKeyState('mouse1')

    local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        px, py = x, y
        x, y = self.x, self.y
    end

    self.from = interpolateBetween(self.from, 0, 0, self.to, 0, 0, (tick-self.tick)/self.lapse, self.easing)

    if not self.hidden then
        dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, -1, false)

        if self.vertical then
           dxDrawImage(x, y+self.from, w, h, self.svg2, 0, 0, 0, -1, false)
        else
           dxDrawImage(x+self.from, y, w, h, self.svg2, 0, 0, 0, -1, false)
        end
    end

    if click then
        if self.vertical and isCursorOver(x, y+self.from, w, h*.3) or not self.vertical and isCursorOver(x+self.from, y, w*.3, h) then
            self.movePos = self:getCursor()
        end
    end

    if self.click then
        if self.movePos then
            local cursor = self:getCursor()
            local pos = (cursor - self.movePos)

            local offset = self.vertical and pos.y or pos.x
            self.to = math.max(0, math.min(self.to + offset, (self.vertical and self.h * 0.7 or self.w * 0.7)))

            self.easing = 'SineCurve'
            self.lapse = 125
            self.tick = getTickCount()

            self.movePos = cursor
        end
    elseif self.movePos then
        self.movePos = nil
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


function uiScroll:getProgress()
    if self.vertical then
        return self.to/(self.h*0.7)
    else
        return self.to/(self.w*0.7)
    end
end

function uiScroll:setProgress(pos)
    self.to = (self.vertical and self.h*.7 or self.w*0.7) * math.max(0, math.min(pos or 0, 1))
end






-- local anim = {
--     tick = getTickCount()
-- }

-- local sx, sy = guiGetScreenSize()
-- local W, H = 800, dxGetFontHeight(1, 'default-bold')
-- local bX = (sx-W) / 2
-- local selected = 1
-- local _click


-- addEventHandler("onClientRender", root, function()

--     local click = not _click and getKeyState('mouse1')
--     _click = getKeyState 'mouse1'

--     local tW = 0
--     local width = {}
--     for i, v in ipairs({'hola', 'funcion', 'procedimiento', 'juzgado'}) do 

--         local _tW = dxGetTextWidth(v, 1) + 30
--         dxDrawText2(v, bX+tW, 150, _tW, H, -1, 1, 'default-bold', 'center')

--         if not anim.from then
--             anim.from = bX+tW
--             anim.to = bX+tW
--         end

        

--         table.insert(width, {v, bX+tW, 150, _tW, H})
--         tW = tW + _tW
--     end

--     for i, v in ipairs(width) do
--         if click and isCursorOver(unpack(v, 2)) then
--             anim.from = width[selected][2]
--             anim.to = v[2]
--             anim.tick = getTickCount()
--             selected = i
--         end
--     end


--     local px = interpolateBetween(anim.from, 0, 0, anim.to, 0, 0, (getTickCount()-anim.tick)/500, 'Linear')
--     local v = width[selected]

--     dxDrawLine(bX, 150+H, px+1, 150+H, -1, 2)-- lefd
--     dxDrawLine(px+v[4]-1, 150+H, bX+tW, 150+H, -1, 2) -- right
--     dxDrawSmartOutlineBox(px, 145, v[4], 5+H+3, -1, 6, 2, 3, {left=true, right=true, top=true, bottom=false})


-- end)



