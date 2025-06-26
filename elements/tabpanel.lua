uiTabpanel = Class(uiElement)

local tabAnimations = {}

function uiTabpanel:constructor(array)--x, y, w, h, parent)

    self.type = 'uiTabpanel'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h

    self.style = array.style or 1
    self.vertical = array.vertical or false

    self.childs = {}
    self.selectTab = nil
    self.previousTab = nil
    self.animationX, self.animationY = nil, nil
    self.animationTick = getTickCount()

    self.rounded = array.rounded or 8
    self.font = array.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.textColor = array.textColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].text
    self.selectedColor = array.selectedColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].selected


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

function uiTabpanel:dx ()
    if (not self:isVisible()) then return end

    local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        px, py = x, y
        x, y = self.x, self.y
    end

    self.animationX = self.animationX or x
    self.animationY = self.animationY or Y

    local startX, startY = x, y
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    self.click = getKeyState('mouse1')

    for i, v in pairs(self.childs) do
        if v.type == 'uiTab' then
            if not self.selectTab then
                self.selectTab = v
            end

            v.index = i
            local isSelected = self.selectTab == v
            if isSelected then
                v.visible = true
            else
                v.visible = false
            end
            local widthUsed, heightUsed = 0, 0

            widthUsed, heightUsed = dxTabStyle(self.style, self.vertical, v, startX, startY, x, y, isSelected, self.font)

            local tabHeight = 20
            
            if self.vertical then
                if isCursorOver(x - widthUsed, startY, widthUsed, heightUsed) and click then
                    local cancel
                    if self.onChange then
                        cancel = self:onChange(self.selectTab, v)
                    end
                    if not cancel and self.selectTab ~= v then
                        self.previousTab = self.selectTab
                        self.selectTab = v
                        self.animationTick = getTickCount()
                    end
                end
            else
                if isCursorOver(startX, y - tabHeight, widthUsed, tabHeight) and click then
                    local cancel
                    if self.onChange then
                        cancel = self:onChange(self.selectTab, v)
                    end
                    if not cancel and self.selectTab ~= v then
                        self.previousTab = self.selectTab
                        self.selectTab = v
                        self.animationTick = getTickCount()
                    end
                end
            end

            startX = startX + widthUsed
            startY = startY + heightUsed

            if isSelected and #v.childs > 0 then
                for _, class in ipairs(v.childs) do
                    if class and class.visible then
                        class:dx(getTickCount())
                    end
                end
            end
        end
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

function dxTabStyle(style, isVertical, v, x, y, x2, y2, selected, font)
    local xImg, xImgL, xImgR, yImg, wImg, hImg = 0, 0, 0, 0, 0, 0
    
    textWidth = dxGetTextWidth(v.text, 1, font)
    textHeight = dxGetFontHeight(1, font)
    tabHeight = 20

    if v.image and ((type(v.image.path) == 'string' and File.exists(v.image.path)) or isElement(v.image.path)) then
        yImg, wImg, hImg = isVertical and (v.image.y + y) - (tabHeight - textHeight) / 2 or (v.image.y + y2) - tabHeight + (tabHeight - textHeight) / 2, v.image.w, math.min(tabHeight, v.image.h)

        if v.image.alignment == 'left' then
            xImgL = wImg + 5
        elseif v.image.alignment == 'center' then
            xImg = isVertical and ((textWidth + wImg) / 2) + 5 or ((textWidth - wImg) / 2)
        elseif v.image.alignment == 'right' then
            xImg = dxGetTextWidth(v.text, 1, font, true) + 5
            xImgR = isVertical and (dxGetTextWidth(v.text, 1, font, true) - 5) / 2 or (dxGetTextWidth(v.text, 1, font, true) + 5) / 2
        end

        if not isVertical then
            dxDrawImage((x + (textWidth + tabHeight - textWidth) / 2) + xImg, yImg, wImg, hImg, v.image.path, 0, 0, 0, selected and v.parent.selectedColor or v.parent.textColor)
        end
    end

    if isVertical then
        if selected then
            local progress = math.min((getTickCount() - v.parent.animationTick) / 300, 1)
            local fromY, toY = v.parent.animationY or y, y
            local currentY = interpolateBetween(fromY, 0, 0, toY, 0, 0, progress, 'Linear')
            
            dxDrawSmartOutlineBox(x2 - (xImgL + (textWidth + tabHeight) + xImgR), currentY - (tabHeight - textHeight) / 2, xImgL + (textWidth + tabHeight) + xImgR, tabHeight, v.parent.backgroundColor, v.parent.rounded, 3, tabHeight, {left=true, right=true, top=true, bottom=true})
            
            if progress >= 1 then
                v.parent.animationY = toY
            end
        end
        
        local textX = v.image and xImg + (((xImgL + x2 + tabHeight - xImgR) + (xImgL + (textWidth + tabHeight) - xImgR)) / 2) - xImgR or xImgL + x2 - (textWidth + tabHeight / 2) - xImgR
        local textY = y - (tabHeight - textHeight) / 2
        
        if v.image then
            dxDrawImage((((x2 + textWidth + tabHeight + textWidth) / 2) + xImgR) + xImg, yImg, wImg, hImg, v.image.path, 0, 0, 0, selected and v.parent.selectedColor or v.parent.textColor)
        end

        dxDrawText(v.text, textX, textY, textX + textWidth, textY + textHeight + (tabHeight / 2), selected and v.parent.selectedColor or v.parent.textColor, 1, font, 'center', 'center')

        return xImgL + (textWidth + tabHeight) - xImgR, tabHeight
    else
        if style == 1 then
            if selected then
                local progress = math.min((getTickCount() - v.parent.animationTick) / 300, 1)
                local fromX, toX = v.parent.animationX or x, x
                local currentX = interpolateBetween(fromX, 0, 0, toX, 0, 0, progress, 'Linear')
                
                dxDrawSmartOutlineBox(currentX, y2 - tabHeight, xImgL + (textWidth + tabHeight) + xImgR, tabHeight, v.parent.backgroundColor, v.parent.rounded, 3, tabHeight, {left=true, right=true, top=true, bottom=true})
                
                if progress >= 1 then
                    v.parent.animationX = toX
                end
            end
            
            local textX = xImgL + x + (textWidth + tabHeight - textWidth) / 2
            local textY = y2 - tabHeight + (tabHeight - textHeight) / 2
            
            if v.image then 
                dxDrawImage((x + (textWidth + tabHeight - textWidth) / 2) + xImg, yImg, wImg, hImg, v.image.path, 0, 0, 0, selected and v.parent.selectedColor or v.parent.textColor)
            end
            
            dxDrawText(v.text, textX, textY, textX + textWidth, textY + textHeight, selected and v.parent.selectedColor or v.parent.textColor, 1, font, 'center', 'center')

        elseif style == 2 then
            if selected then
                local progress = math.min((getTickCount() - v.parent.animationTick) / 300, 1)
                local fromX, toX = v.parent.animationX or x, x
                local currentX = interpolateBetween(fromX, 0, 0, toX, 0, 0, progress, 'Linear')
                
                dxDrawRectangle(currentX, y2 - tabHeight + 18, textWidth, tabHeight - 18, v.parent.backgroundColor)

                if progress >= 1 then
                    v.parent.animationX = toX
                end
            end

            local textX = x + (textWidth - textWidth) / 2
            local textY = y2 - tabHeight + (tabHeight - textHeight) / 2
            dxDrawText(v.text, textX, textY, textX + textWidth, textY + textHeight, selected and v.parent.selectedColor or v.parent.textColor, 1, font, 'center', 'center')

        elseif style == 3 then
            if selected then
                local progress = math.min((getTickCount() - v.parent.animationTick) / 4000, 1)
                v.parent.animationX = interpolateBetween(v.parent.animationX, 0, 0, x, 0, 0, progress, 'SineCurve')
                local currentX = v.parent.animationX + 2   
                local lineStartX = x2 + 2--(v.index == 1 and 2 or 0)
                local lineEndX = x2 + v.parent.w - 4 --xImgL + lineStartX + v.parent.w  --+ xImgR

                local tabWidth = xImgL + textWidth + tabHeight + xImgR

                dxDrawSmartOutlineBox(currentX, y2 - tabHeight - 4, xImgL + (textWidth + tabHeight) + xImgR, tabHeight + 6, v.parent.backgroundColor, 6, 2, 3, {left=true, right=true, top=true, bottom=false})

                if currentX > lineStartX then -- Izq
                    dxDrawLine(lineStartX, y2 - 2, currentX, y2 - 2, v.parent.backgroundColor, 2)
                end

                if currentX + tabWidth < lineEndX then -- Der
                    dxDrawLine(currentX + tabWidth, y2 - 2, lineEndX, y2 - 2, v.parent.backgroundColor, 2)
                end


                if progress >= 1 then
                    v.parent.animationX = x
                end
            end

            local textX = xImgL + x + (textWidth + tabHeight - textWidth) / 2
            local textY = y2 - tabHeight + (tabHeight - textHeight) / 2
            dxDrawText(v.text, textX, textY, textX + textWidth, textY + textHeight, selected and v.parent.selectedColor or v.parent.textColor, 1, font, 'center', 'center')

        end
    end

    return textWidth + tabHeight + xImgL + xImgR, textHeight + tabHeight
end

function uiTabpanel:setSelectedTab(element)
    if element.type ~= 'uiTab' then
        return
    end
    
    self.selectTab = element
end

function uiTabpanel:getSelectedTab()
    return self.selectTab
end