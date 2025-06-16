uiElement = Class()

function uiElement:virtual_constructor()

	dxLibrary.count = dxLibrary.count + 1
    self.id = dxLibrary.count
    --
    self.visible = true
    self.move = true
    self.enabled = true
    self.screen = Vector2(GuiElement.getScreenSize())
    --
    if not dxLibrary.isRender then
        addEventHandler('onClientRender', root, dxLibrary.global_render)
        dxLibrary.isRender = true
    end
end

function uiElement:destroy(byParent)
    self.visible = false

    if self.childs then
        for i = #self.childs, 1, -1 do
            local v = self.childs[i]
            if v then
                table.remove(self.childs, i):destroy(true)
            end
        end 
    end

    for i, v in ipairs({'svg', 'svg2', 'renderTarget', 'renderTarget2', 'shader', 'image'}) do
        if isElement(self[v]) then
            self[v]:destroy()
            self[v] = nil
        end
    end

    if self.parent and not byParent and self.parent.childs then
        for i = #self.parent.childs, 1, -1 do
            local v = self.parent.childs[i]
            if v and v == self then
                table.remove(self.parent.childs, i)
                break
            end
        end 
    end

    if not self.parent then
        for i = #dxLibrary.render, 1, -1 do
            local v = dxLibrary.render[i]
            if v and v == self then
                table.remove(dxLibrary.render, i)
                break
            end
        end 
    end

    for i = #dxLibrary.mouseWheels, 1, -1 do
        local v = dxLibrary.mouseWheels[i]
        if v and v == self then
            table.remove(dxLibrary.mouseWheels, i)
            break
        end
    end

    for i = #dxLibrary.restoreTarget, 1, -1 do
        local v = dxLibrary.restoreTarget[i]
        if v and v == self then
            table.remove(dxLibrary.restoreTarget, i)
            break
        end
    end

    for i = #dxLibrary.order, 1, -1 do
        local v = dxLibrary.order[i]
        if v and v == self then
            table.remove(dxLibrary.order, i)
            break
        end
    end 

    if #dxLibrary.render <= 0 then
        if dxLibrary.isRender then
            removeEventHandler('onClientRender', root, dxLibrary.global_render)
            dxLibrary.isRender = nil
        end
    end

    self = nil
end

function uiElement:getCursor()
    if isCursorShowing() then
        return Vector2(getCursorPosition()) * self.screen
    end
end

function uiElement:isCursorOver(position)
    if isCursorShowing() then
         
        local cursor = self:getCursor()
        local x, y = self:getRealXY()
        --
        if not position then
            return (cursor.x >= x and cursor.x <= x+self.w) and (cursor.y >= y and cursor.y <= y+self.h)
        elseif position == 'windowTitle' then
            return (cursor.x >= self.x and cursor.x <= self.x+self.w) and (cursor.y >= self.y and cursor.y <= self.y+self.titleH)
        elseif position == 'windowClose' then

            local max = math.max(math.max(self.rounded[1], self.rounded[2]), math.max(self.rounded[3], self.rounded[4])) / 4 + 2
            local fw, fh = self.closeW, math.min( self.closeH, self:calc(self.h, 5)+max)
            return (cursor.x >= x+self.w-max-self.closeW*1.5 and cursor.x <= (x+self.w-max-self.closeW*1.5)+self.closeW) and (cursor.y >= y+fh and cursor.y <= (y+fh)+self.closeH)

        elseif position == 'circleSlider' then
            local cw = self.cw

            if self.vertical then
                return (cursor.x >= x and cursor.x <= x+cw) and (cursor.y >= math.min(y+self.h-cw, y+self.cx) and cursor.y <= y+self.cx+cw) 
            else
                return (cursor.x >= math.min(x+self.w-cw, x+self.cx) and cursor.x <= x+self.cx+cw) and (cursor.y >= y and cursor.y <= y+cw)
            end
        end
    end
end

function uiElement:calc(mult, value)
    return mult * (value/100)
end


function uiElement:adjustPosition()
    self:setSize(self.w, self.h)
    self:setPosition(self.x, self.y)
end

function uiElement:setPosition(x, y, offX, offY)
    local px, py = self:getReferenceSize()
    
    self.coord[1], self.coord[2] = {x=x, offX=(offX or 0)}, {y=y, offY=(offY or 0)}

    self.x = self:calc(px, x) + (offX or 0)
    self.y = self:calc(py, y) + (offY or 0)
end

function uiElement:setSize(w, h, offW, offH)
    local px, py = self:getReferenceSize()
    px = px + (offW or 0)
    py = py + (offH or 0)

    if self.type == 'uiColorpicker' then
        return
    end

    if self.type == 'uiLabel' then
        self.w = self:calc(px, w) 
        self.h = self:calc(py, h)
    elseif self.type == 'uiRadioButton' or self.type == 'uiCheckbox' or self.type == 'uiSwitch' then
        return
    else
        if self.parent then
            if self.type == 'uiCheckbox' or (self.type == 'uiIcon' and self.circle) then
                self.w = self:calc(py, w) 
                self.h = self:calc(py, h)
            elseif self.type == 'uiSlider' or self.type == 'uiScroll' then
                if self.vertical then
                    self.h = self:calc(py, h)
                else
                    self.w = self:calc(px, w)
                end
            elseif self.type == 'uiButton' and self.circle then
                self.w = self:calc(px, w) 
                self.h = self:calc(px, h)
            else
                self.w = self:calc(px, w) 
                self.h = self:calc(py, h)
            end
        else
            if self.type == 'uiSlider' or self.type == 'uiScroll' then
                if self.vertical then
                    self.h = self:calc(py, h)
                else
                    self.w = self:calc(py, self:normalizeXValueFromY(w))
                end
            else
                self.w = self:calc(py, self:normalizeXValueFromY(w))
                self.h = self:calc(py, h)
            end
        end
    end

    self.coord[3], self.coord[4] = {w=w, offW=(offW or 0)}, {h=h, offH=(offH or 0)}
end

function uiElement:getReferenceSize()
    local px, py = self.screen.x, self.screen.y
    local parent = self.parent
    if parent then
        parent = parent.type == 'uiTab' and parent.parent or parent
        if parent.type == 'uiWindow' or parent.type == 'uiIcon' or parent.type == 'uiTabpanel' or parent.type == 'uiGridList' or parent.type == 'uiMemo' then
            px, py = parent.w, parent.h
        end
    end
    return px, py
end

function uiElement:normalizeXValueFromY(value)
    local sx, sy = self.screen.x, self.screen.y
    return value * (sx / sy)
end

function uiElement:center(x, y, offX, offY)
    self:centerX(x, offX)
    self:centerY(y, offY)
end

function uiElement:centerX(x, offX)
    local px = self:getReferenceSize()
    self.x = (px-self.w) / 2 + self:calc(px, (x or 0)) + (offX or 0)
end

function uiElement:centerY(y, offY)
    local _, py = self:getReferenceSize()
    self.y = (py-self.h) / 2 + self:calc(py, (y or 0)) + (offY or 0)
end

function uiElement:right(x, offX)
    local px = self:getReferenceSize()
    self.x = (px-self.w) - self:calc((px-self.w), (x or 0)) - (offX or 0)
end

function uiElement:bottom(y, offY)
    local _, py = self:getReferenceSize()
    self.y = (py-self.h) - self:calc((py-self.h), (y or 0)) - (offY or 0)
end


function uiElement:getPostGui()
    return self.postgui and not self.parent
end

function uiElement:gColor(c)
    local r,g,b,a = colorToRgba(c)
    a = a*self.opacity
    return tocolor(r,g,b,a)
end

function uiElement:setValue(value, newValue)
    self[value] = newValue
end

function uiElement:getValue(value, newValue)
    return self[value]
end

function uiElement:getParentRoot()
    if self.parent and type(self.parent) == 'table' then
        if self.parent.parent then
            return self.parent:getParentRoot()
        else
            return self.parent
        end
    end
end

function uiElement:isVisible()
    if not self.visible then return false end
    if self.parent and type(self.parent) == 'table' then
        return self.parent:isVisible()
    end
    return true
end

function uiElement:setEnabled(value)
    if not self.visible then return false end
    if type(value) ~= 'boolean' then return false end

    self.enabled = value

    return true
end

function uiElement:getEnabled()
    return self.enabled
end

function uiElement:getRealXY()
    local x, y = self.x or 0, self.y or 0
    local parent = self.parent

    if parent then
        if parent.type == 'uiScrollpane' then
            -- aún vacío
        elseif parent.type == 'uiTab' then
            parent = parent.parent
        end
    end

    while parent do
        if parent.type == 'uiTab' then
            parent = parent.parent
        end

        x = x + (parent.x or 0)
        y = y + (parent.y or 0)
        parent = parent.parent
    end

    return x, y
end

-- function uiElement:getRealXY(x, y)
--     local x, y = self.x + (x or 0), self.y + (y or 0)
--     local parent = self.parent

--     if parent then
--         if self.type == 'uiScrollpane' then
--         elseif self.type == 'uiTab' then
--             parent = self.parent
--         end

--         return parent:getRealXY(x, y)
--     end
--     --
--     return x, y
-- end

function uiElement:updateSvg()

    if not (dxLibrary.availableSVG[self.type]) then return end
    local self = self
    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    -- local xml = svgGetDocumentXML(self.svg)
    -- local rect = xml:findChild('rect', 0)

    if self.type == 'uiWindow' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        local r1, r2, r3, r4 = self.rounded[1] or 0, self.rounded[2] or 0, self.rounded[3] or 0, self.rounded[4] or 0
        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
                
                <rect x="%s" y="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
            </svg>
        ]], 
            w+4+self.outline.size, h+4+self.outline.size, 
            --self.backgroundTitle, self.backgroundColo
            2+self.outline.size, 2+self.outline.size, r1, w*.7, h/2, color2hex(self.backgroundTitle), self.outline.size, color2hex(self.outline.color), -- title left
            2+self.outline.size+w/2, 2+self.outline.size, r2, w/2, h/2, color2hex(self.backgroundTitle), self.outline.size, color2hex(self.outline.color), -- title right

            2+self.outline.size, 2+self.outline.size+h/2, r3, w*0.7, h/2, color2hex(self.backgroundColor), self.outline.size, color2hex(self.outline.color), --- left down
            (2+self.outline.size+w/2), 2+self.outline.size+h/2, r4, w/2, h/2, color2hex(self.backgroundColor), self.outline.size, color2hex(self.outline.color),--,

            2+self.outline.size, self.outline.size+h/4, w, h/2, color2hex(self.backgroundColor), self.outline.size, color2hex(self.outline.color)
        ))

        -- rect:setAttribute('width', self.width) 
        -- rect:setAttribute('height', self.height)
        -- rect:setAttribute('rx', self.rx)
        -- rect:setAttribute('ry', self.ry)

        -- svgSetDocumentXML(self.svg, xml)
    elseif self.type == 'uiButton' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke-width="%s" stroke="%s"/>
            </svg>
        ]], 
            w+4, h+4, 
            
            2, 2, self.rounded, w-4, h-4, color2hex(-1), ({color2rgb(self.backgroundColor or Color.background)})[4]/255, self.outline, color2hex(self.outlineColor)
        ))

    elseif self.type == 'uiColorpicker' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        if isElement(self.svg2) then
            self.svg2:destroy()
        end

        local w, h = self.w, self.h/ 1.65
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" ry="%s" opacity="1" width="%s" height="%s" fill="%s" stroke-width="%s" stroke="%s" />
            </svg>
        ]], 
            w+4, h+4, 
            
            2, 2, self.rounded, w-4, h-4, color2hex(-1), 0, color2hex(-1)
        ), self.svgCallBack)

        self.svg2 = svgCreate(235, 20, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" width="%s" height="%s" fill="%s"/>
            </svg>
        ]], 
            235+4, 20+4, 
            
            2, 2, 6, 235-4, 20-4, color2hex(-1)
        ), function(s)
            self.shader2:setValue("sMaskTexture", s)
        end)

    elseif self.type == 'uiCheckbox' then
        
        if isElement(self.svg) then
            self.svg:destroy()
        end

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w+self.outline, h+self.outline, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" width="%s" height="%s" fill="none" fill-opacity='0' stroke="%s" stroke-width='%s'/>
            </svg>
        ]], 
            w+self.outline, h+self.outline, self.outline/2, self.outline/2, self.rounded, w, h, color2hex(self.backgroundColor), self.outline
        ))

    elseif self.type == 'uiRadioButton' then
        
        if isElement(self.svg) then
            self.svg:destroy()
        end

        if isElement(self.svg2) then
            self.svg2:destroy()
        end

        -- local rawSvgData = ([[
        --     <svg width="%dpx" height="%dpx">
        --       <circle cx="%d" cy="%d" r="%d" fill="%s" stroke="%s" stroke-width="2px"/>
        --       <circle cx="%d" cy="%d" r="%d" fill="%s"/>
        --     </svg>]]):format(self.w+2, self.h+2, self.rounded+1, self.rounded+1, self.rounded, self.rounded+1, self.rounded+1, self.rounded/2)

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%dpx" height="%dpx">
                <circle cx="%d" cy="%d" r="%d" fill-opacity="0" stroke="#ffffff" stroke-width="3px"/>
            </svg>
        ]], 
            w+4, h+4, 
            self.rounded+2, self.rounded+2, self.rounded
        ))

        self.svg2 = svgCreate(w, h, string.format([[
            <svg width="%dpx" height="%dpx">
                <circle cx="%d" cy="%d" r="%d" fill="#ffffff"/>
            </svg>
        ]], 
            w+4, h+4, 
            self.rounded+2, self.rounded+2, self.rounded/2
        ))

    elseif self.type == 'uiSlider' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" width="%s" height="%s" fill="#ffffff"/>
            </svg>
        ]], 
            w+4, h+4, 
            
            2, 2, self.rounded, w-4, h-4
        ))

        local cw = 32--0.01 * sx

        self.svg2 = svgCreate(cw, cw, string.format([[
            <svg width="%dpx" height="%dpx">
                <circle cx="%d" cy="%d" r="%d" fill="#ffffff"/>
            </svg>
        ]], 
            cw+4, cw+4, 
            cw/2+2, cw/2+2, cw/2
        ))

    elseif self.type == 'uiProgress' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        if isElement(self.svg2) then
            self.svg2:destroy()
        end

        local w, h = self.w, self.h

        if self.mode == 1 then
            local stroke = self.lineWidth

            self.svg = svgCreate(w, h, string.format([[
                <svg width="%s" height="%s">
                    <circle cx="%d" cy="%d" r="%d" fill="none" stroke-width="%s" stroke-dasharray="%s" stroke-dashoffset="%s" stroke='%s' stroke-opacity='%s' transform="rotate(0 60 60)"/>
                    <circle cx="%d" cy="%d" r="%d" fill="none" stroke-width="%s" stroke-dasharray="%s" stroke-dashoffset="%s" stroke='%s' stroke-opacity='%s' transform="rotate(0 60 60)"/>
                </svg>
            ]], 
                w+stroke*2, h+stroke*2, 
                self.rounded+stroke, self.rounded+stroke, self.rounded, stroke, self.roundedLenght, 0, color2hex(self.backgroundColor or Color.background), ({color2rgb(self.backgroundColor or Color.background)})[4]/255,
                self.rounded+stroke, self.rounded+stroke, self.rounded, stroke, self.roundedLenght, (self.roundedLenght*(1-self.progress)), color2hex(self.progressColor or Color.progress), ({color2rgb(self.progressColor or Color.progress)})[4]/255
            ))

            self.xml = svgGetDocumentXML(self.svg)
        elseif self.mode == 2 then
            local stroke = 2
            self.svg = svgCreate(w, h, string.format([[
               <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
                   <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke="none"/>
               </svg>
            ]],
               w+4, h+4,
            
               2, 2, self.rounded, w-4, h-4, color2hex(self.backgroundColor or Color.background), ({color2rgb(self.backgroundColor or Color.background)})[4]/255
            ))

            self.svg2 = svgCreate(w, h, string.format([[
               <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
                   <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke="none"/>
               </svg>
            ]],
               w+4, h+4,
               2+stroke, 2+stroke, self.rounded-stroke, (w-4-stroke*2), h-4-stroke*2, color2hex(self.progressColor or Color.progress), ({color2rgb(self.progressColor or Color.progress)})[4]/255
            ))

        end

    elseif self.type == 'uiScroll' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        if isElement(self.svg2) then
            self.svg:destroy()
        end
 
        local w, h = self.w, self.h
        self.svg = svgCreate(w, h, string.format([[
           <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
               <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke="none"/>
           </svg>
        ]],
           w+4, h+4,
        
           2, 2, self.rounded, w-4, h-4, color2hex(self.backgroundColor or Color.background), ({color2rgb(self.backgroundColor or Color.background)})[4]/255)
        )

        if self.vertical then
            h = h*.3
        else
            w = w*.3
        end

        local stroke = 1
        self.svg2 = svgCreate(self.w, self.h, string.format([[
           <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg">
               <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke="none"/>
           </svg>
        ]],
           self.w+4, self.h+4,
           2+stroke, 2+stroke, self.rounded/2, (w-4-stroke*2), h-4-stroke*2, color2hex(self.progressColor or Color.progress), ({color2rgb(self.progressColor or Color.progress)})[4]/255
        ))

    elseif self.type == 'uiEditbox' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s" fill-opacity='%s' stroke-width="%s" stroke="%s"/>
            </svg>
        ]], 
            w, h, 
            
            0, 0, self.rounded, w, h, color2hex(-1), self.backgroundColor[4]/255, self.outline, color2hex(self.outlineColor)
        ))
    elseif self.type == 'uiMemo' then

        if isElement(self.svg) then
            self.svg:destroy()
        end

        local w, h = self.w, self.h
        
        self.svg = svgCreate(w, h, string.format([[
            <svg width="%s" height="%s" xmlns="http://www.w3.org/2000/svg"> 
                <rect x="%s" y="%s" rx="%s" opacity="1" width="%s" height="%s" fill="%s"/>
            </svg>
        ]], 
            w, h, 
            
            0, 0, self.rounded, w, h, color2hex(-1)
        ))

    end 
end
