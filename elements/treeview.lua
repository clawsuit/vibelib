uiTreeview = Class(uiElement)

function uiTreeview:constructor(array)--x, y, w, h, parent)
    self.type = 'uiTreeview'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h
    self.font = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font

    self.listTreeview = {}
    self.selectedItems = {}
    self.selectList = nil

    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.backgroundHover = array.backgroundHover or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].backgroundHover
    self.selectedColor = array.selectedColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].selectedColor
    self.textColor = array.textColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].textColor

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

function uiTreeview:dx()
    if not self:isVisible() then return end

    local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y
    local isScrollpane = self.parent and self.parent.type == 'uiScrollpane'

    if isScrollpane then
        x, y = self.x, self.y 
    end
    
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    local currentY = y


    for _, node in pairs(self.listTreeview) do
        currentY = self:renderNode(node, x, (currentY or py), click, 0, px, py, isScrollpane)
    end

    self.click = getKeyState('mouse1')
end

function uiTreeview:renderNode(node, x, y, click, level, px, py, pane)
    local w, h = self.w, self.h
    local isHovered
    if pane then
        isHovered = isCursorOver(px + x, py + y, w, h)
    else
        isHovered = isCursorOver(x, y, w, h)
    end

    local bgColor

    if node.isParent and node.expanded then
        bgColor = isHovered and self.backgroundHover or self.backgroundColor
    elseif not node.isParent and table.find(self.selectedItems, node) then
        bgColor = self.selectedColor
    else
        bgColor = isHovered and self.backgroundHover or self.backgroundColor
    end

    local toggleSymbol = node.isParent and (node.expanded and '▾' or '▸') or '• '
    local textOffsetX = 15 * level
    local wSymbol = dxGetTextWidth(toggleSymbol, 1, dxLibrary.fonts.font4)

    dxDrawRectangle(x, y, w, h, bgColor)
    dxSetBlendMode('modulate_add')
        dxDrawText2(toggleSymbol, x + textOffsetX + 2, y-1, w, h, self.textColor, 1, dxLibrary.fonts.font4, 'left', 'center', false, false, false, true)
        dxDrawText2(node.name, x + textOffsetX + 5 + wSymbol, y, w - wSymbol, h, self.textColor, 1, self.font, 'left', 'center', false, false, false, true)
    dxSetBlendMode('blend')

    if not node.animating and isHovered and click then
        if node.isParent then
            node.expanded = not node.expanded
            node.animating = true
            node.animationStart = getTickCount()
            node.startHeight = node.currentHeight or 0
            node.targetHeight = node.expanded and (#node.children * h) or 0
        end

        if not node.isParent then
            local index = table.find(self.selectedItems, node)
            if index then
                table.remove(self.selectedItems, index)
            else
                for _, selectedNode in ipairs(self.selectedItems) do
                    if selectedNode.parent == node.parent then
                        table.remove(self.selectedItems, table.find(self.selectedItems, selectedNode))
                    end
                end
            
                table.insert(self.selectedItems, node)
            end
        end
        
        
    end

    y = y + h

    if node.isParent then
        if node.animating then
            local currentTick = getTickCount()
            local progress = math.min((currentTick - node.animationStart) / 250, 1)

            node.currentHeight = interpolateBetween(node.startHeight, 0, 0, node.targetHeight, 0, 0, progress, 'Linear')

            if progress == 1 then
                node.animating = false
                node.currentHeight = node.targetHeight
            end

            dxDrawRectangle(x, y, w, node.currentHeight, self.backgroundHover)
        end

        if not node.animating and node.expanded then
            for _, child in ipairs(node.children) do
                y = self:renderNode(child, x, y, click, level + 1, px, py, pane)
            end
        end
    end

    return y + (node.animating and node.currentHeight or 0)
end

function uiTreeview:addRoot(name, isParent)
    local item = {name = name, children = {}, expanded = false, isParent = isParent or false}

    table.insert(self.listTreeview, item)
    
    return item
end

function uiTreeview:addItem(name, parent, isParent)
    if parent then
        local item = {name = name, children = {}, expanded = false, isParent = isParent or false, parent = parent or false}

        if parent.isParent then
            table.insert(parent.children, item)
        end

        return item
    end
end

function uiTreeview:getItem()
    return self.selectList
end

