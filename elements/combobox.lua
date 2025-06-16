-- uiCombobox = Class(uiElement)

-- function uiCombobox:constructor (x, y, w, h, parent)
--     self.type = 'uiCombobox'

--     self.x = x
--     self.y = y
--     self.w = w
--     self.h = h
    
--     self.font = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    
--     -- self.backgroundColor = -1000
--     -- self.backgroundAlpha = 0
--     -- self.outline = 3
--     -- self.outlineColor = -1
--     -- self.rounded = 4

--     self.listCombo = {}
--     self.selectList = {}
--     self.moveList = 0
    
--     self:adjustPosition(_,_, true)

--     if type(parent) == 'table' and dxLibrary.parentValids[parent.type] then
--         self.parent = parent
--         table.insert(self.parent.childs, self)
--     else
--         table.insert(dxLibrary.render, self)
--     end

--     return self
-- end

-- function uiCombobox:dx ()
--     if (not self:isVisible()) then return end

--     local x, y = self:getRealXY()
--     local w, h =  self.w, self.h
--     local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
--     local stateList = self.stateList and '⬑' or '⬎'
--     local colorList = self.stateList and tocolor(230, 230, 230) or tocolor(255, 255, 255)
--     local text = self.selectList and self.selectList.name or 'Title'
--     local yListCombo = #self.listCombo * h

--     dxDrawRectangle(x, y, w, h, colorList)
--     dxDrawText2(stateList .. ' ' .. text, x + 5, y, w, h, tocolor(0, 0, 0, 180), 1, self.font, 'left', 'center', false, false, false, true)

--     if self:isCursorOver() and click then
--         self.stateList = not self.stateList
--         self.tick = getTickCount()
--     end
    
--     if self.stateList then
--         self.moveList = interpolateBetween(0, 0, 0, yListCombo, 0, 0, (getTickCount() - self.tick) / 800, 'Linear')
--         dxDrawRectangle(x, y + h, w, self.moveList, tocolor(255, 255, 255))

--         if self.moveList == yListCombo then
--             local yList = y + h

--             for i, _ in pairs(self.listCombo) do
--                 local v = self.listCombo[i]
--                 local colorSelectList = (self.selectList and self.selectList.id == i) and tocolor(180, 180, 180) or (isCursorOver(x, yList, w, h)) and tocolor(200, 200, 200) or tocolor(255, 255, 255)

--                 dxDrawRectangle(x, yList, w, h, colorSelectList)
--                 dxDrawText2(v, x + 5, yList, w, h, tocolor(0, 0, 0, 180), 1, self.font, 'left', 'center', false, false, false, true)

--                 if isCursorOver(x, yList, w, h) and click then
--                     self.selectList = {id = i, name = v}
--                     self.stateList = false
--                 end

--                 yList = yList + h
--             end
--         end
--     elseif not self.stateList and self.moveList > 0 then
--         self.moveList = interpolateBetween(yListCombo, 0, 0, 0, 0, 0, (getTickCount() - self.tick) / 800, 'Linear')
--         dxDrawRectangle(x, y + h, w, self.moveList, tocolor(255, 255, 255))
    
--         if self.moveList <= 0 then
--             self.stateList = false
--         end
--     end

--     self.click = getKeyState('mouse1')
-- end

-- function uiCombobox:addItem (string)
--     iprint('OLD', self.listCombo)
--     table.insert(self.listCombo, string)
--     iprint('NEW', self.listCombo)
-- end

-- local combo = uiCombobox(500, 250, 150, 25, win)

-- combo:addItem('Hola')
-- combo:addItem('Trola')