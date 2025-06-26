---@class uiGridList
---@field addColumn fun(name: string, size?: number, color?: number, alignment?: string, image?: table) 
uiGridList = Class(uiElement)


function uiGridList:constructor(array)--x, y, w, h, parent)
    self.type = 'uiGridList'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h

    self.resto = 0
    self.font = array.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font

    array.rowStyle = array.rowStyle or {}
    self.rowStyle = {
        rounded = array.rowStyle.rounded or 5,
        padding = array.rowStyle.padding or 2,
        height  = dxGetFontHeight(1, self.font) * 1.65,
        backgroundColor = array.rowStyle.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].row.background,
        textColor = array.rowStyle.textColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].row.text,
        selectedColor = array.rowStyle.selectedColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].row.selected
    }
    
    array.columnStyle = array.columnStyle or {}
    local font2 = array.columnStyle.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].fontco
    
    self.columnStyle = {
        height = dxGetFontHeight(1, font2) * 2 + (array.columnStyle.height or 0),
        rounded = array.columnStyle.rounded or 5,
        padding = array.columnStyle.padding or -2,
        backgroundColor = array.columnStyle.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].column.background,
        textColor = array.columnStyle.textColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].column.text,
        font = font2
    }
    self.columnStyle.fontH = dxGetFontHeight(1, self.columnStyle.font)

    self.selectedType = math.max(1, math.min(2, array.selectedType or 1))
    self.selected = self.selectedType == 2 and {}
    self.columns = {}
    self.items = {}
    self.childs = {}
    self.scroll = {y=0}
    --

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end
    table.insert(dxLibrary.mouseWheels, self)
    table.insert(dxLibrary.restoreTarget, self)

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    self:updateSvg()

    local coH = math.round(self.columnStyle.height+self.columnStyle.padding)
    self.scrollV = uiScroll({x=0, y=0, w=100, vertical=true, parent=self})
    self.scrollV.visible = false
    self.scrollV:setPosition(0, 0, 0, coH)
    self.scrollV:setSize(0, 100, 0, -coH+2)
    self.scrollV:right(-0.5, -self.scrollV.w)

    self.update = true
    return self
end

function uiGridList:setSelectedType(selectedType)
    self.selectedType = math.max(1, math.min(2, selectedType or 1))
    self.selected = self.selectedType == 2 and {}
    self.update = true
end

--- Agrega una columna al uiGridList
---@param name string Nombre de la columna
---@param size number Ancho de la columna
---@param color number Color de tocolor(r, g, b, a)
---@param alignment string ['left', 'center', 'right']
---@param image table {path = string, alignment = string, x = number, y = number, w = number, h = number, color = number}
function uiGridList:addColumn(name, size, color, alignment, image)
    local new = {
        gridColumn = true,
        name = tostring(name),
        size = tonumber(size) or 0.3,
        color = color or -1,
        alignment = alignment or 'left'
    }

    if image then
        new.image = {
            path = ((type(image.path) == 'string' and File.exists(image.path)) or isElement(image.path)) and image.path,
            alignment = image.alignment or 'left',
            x = image.x or 0,
            y = image.y or 0,
            w = self:calc(self.columnStyle.height, image.w or 0),
            h = self:calc(self.columnStyle.height, image.h or 0),
            color = image.color or -1
        }
    end

    table.insert(self.columns, new)
    --
    return #self.columns;
end

function uiGridList:addRow(...)
    local reform = {}
    for i, v in ipairs({...}) do
        table.insert(reform, {text=v, x=0, y=0, color=-1})
    end
    table.insert(self.items, reform)
    return #self.items
end

function uiGridList:editRow(row, column, text, section, alignment, x, y, image, switch)
    local pre = self.items[row]
    if not pre then return end

    local item = {} --if not item then return end
    item.text = text
    item.section = section
    item.alignment = alignment
    item.x = x or 0
    item.y = y or 0

    if image then
        item.image = {
            path = image.path,
            alignment = image.alignment or 'left',
            x = image.x or 0,
            y = image.y or 0,
            w = self:calc(self.rowStyle.height, image.w or 0),
            h = self:calc(self.rowStyle.height, image.h or 0),
            color = image.color or -1
        }
    end

    if switch then
        item.switch = {
            state = switch.state,
            x = switch.x or 0,
            y = switch.y or 0,
            bx = 0,
            backgroundColor = switch.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected]['uiSwitch'].background,
            onColor     = switch.onColor or dxLibrary.Theme[dxLibrary.Theme.selected]['uiSwitch'].on,
            offColor    = switch.offColor or dxLibrary.Theme[dxLibrary.Theme.selected]['uiSwitch'].off
            --tick = getTickCount()
        }
    end

    pre[column] = item
end

function uiGridList:setData(row, column, ...)
    local pre = self.items[row]
    if not pre then return end
    if not pre[column] then return end

    pre[column].data = {...}
end

function uiGridList:getData(row, column)
    local pre = self.items[row]
    if not pre then return end
    if not pre[column] then return end

    return pre[column].data
end

function uiGridList:removeRow(row)
    if self.items[row] then
        table.remove(self.items, row)
        self.selected = nil
        self.update2 = true
    end
end

function uiGridList:setRowColor(row, column, r,g,b,a)
    local pre = self.items[row]
    if not pre then return end

    local item = pre[column]
    if not item then return end

    item.color = tocolor(r or 255, g or 255, b or 255, a or 255)
end


function uiGridList:getSelectedItem(row)
    if row or ((self.selectedType == 1) and (self.selected)) then

        local item = self.items[row or self.selected]
        if not item then return end

        local reform = {}
        for i, v in ipairs(item) do
            table.insert(reform, v.text)
        end
        return reform, self.selected

    elseif self.selectedType == 2 then

        local items = {}
        for k in pairs(self.selected) do 
            local o = {}
            for i, v in ipairs(self.items[k]) do
                table.insert(o, v.text)
            end
            table.insert(items, o)
        end

        return items, self.selected
    end
end

function uiGridList:clear()
    self.items = {}
    self.selected = nil
    self.update2 = true
end

function uiGridList:dx(tick)
    if (not self:isVisible()) then return end

    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    self.click = getKeyState('mouse1')

    local w, h, x, y = math.round(math.max(1,self.w)), self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        px, py = x, y
        x, y = self.x, self.y
    end

    local coH = math.round(self.columnStyle.height+self.columnStyle.padding)
    if isElement(self.renderTarget) then
        local size = Vector2(self.renderTarget:getSize())
        if size.x ~= w or size.y ~= coH then
            self.renderTarget:destroy()
        end
    end

    if not isElement(self.renderTarget) then
        self.renderTarget = DxRenderTarget(math.round(w), coH, true)
    end

    h = math.round(math.max(1, h-coH))

    local checkH = self:calc(self.rowStyle.height, 60)
    local checkX = self:calc(w, 2)

    if click and isCursorOver(px+checkX, py+(coH-checkH)/2, checkH, checkH) then
        self.columnStyle.selected = not self.columnStyle.selected
        for i = 1, #self.items, 1 do
            self.selected[i] = self.columnStyle.selected
        end
        self.update = true
    end

    if self.update then
        self.update = nil

        self.renderTarget:setAsTarget(true)

            dxDrawRectangle(0, 0, w, coH, self.columnStyle.backgroundColor)

            local px2 = 0
            local sizeTotal = 0
            local font = self.columnStyle.font

            if self.selectedType == 2 then
                local fontH = self.columnStyle.fontH
                local textScale = checkH / fontH

                dxDrawSmartOutlineBox(checkX, (coH-checkH)/2, checkH, checkH, tocolor(30, 30, 30, 255), 6, 2, 3, {left=true, right=true, top=true, bottom=true})

                if self.columnStyle.selected then
                    dxDrawText2('✔', checkX, (coH-checkH)/2, checkH, checkH, tocolor(13, 180, 13), textScale, font, 'center', 'center')
                end

                px2 = px2 + checkH + (checkX*2)
            end

            if #self.columns > 0 then
                for ci = 1, #self.columns do

                    local column = self.columns[ci]
                    local size = w * column.size
                    local ofx = 0
                    if column.image and ((type(column.image.path) == 'string' and File.exists(column.image.path)) or isElement(column.image.path)) then

                        local x, y, w, h = column.image.x, column.image.y, column.image.w, math.min(coH, column.image.h)
                        y = y+((coH - h) /2)

                        if column.image.alignment == 'left' then
                            ofx = w + x + 5
                        elseif column.image.alignment == 'center' then
                            x = x + ((size - w) / 2)
                        elseif column.image.alignment == 'right' then
                            x = x + dxGetTextWidth(column.name, 1, font, true) + 5
                        end

                        dxDrawImage(px2+x, y, w, h, column.image.path, 0, 0, 0, tocolor(255,255,255))

                    end
                    dxSetBlendMode('modulate_add')
                        dxDrawText2(column.name, ofx+px2, 0, size, coH, self.columnStyle.textColor, 1, font, column.alignment, 'center', true, true, false, true)
                    dxSetBlendMode('blend')

                    px2 = px2 + size
                    sizeTotal = sizeTotal + size
                end
            end

        if self.parent and self.parent.type == 'uiScrollpane' then
            dxSetRenderTarget(self.parent.renderTarget)
        else
            dxSetRenderTarget()
        end

        self.update2 = true
    end
    
    dxSetBlendMode('add')
        dxDrawImage(math.round(x), math.round(y), w, coH, self.renderTarget)
    dxSetBlendMode('blend')

    if isElement(self.renderTarget2) then
        local size = Vector2(self.renderTarget2:getSize())
        if size.x ~= w or size.y ~= h then
            self.renderTarget2:destroy()
        end
    end

    if not isElement(self.renderTarget2) then
        self.renderTarget2 = DxRenderTarget(math.round(w), math.round(h), true)
    end

    local y = y + coH + 2
    local py = py + coH + 2
    local scpy = 0

    if self.scrollV.visible then
        scpy = self.scrollV:getProgress()
    end


    if self.update2 or (isCursorOver(px, py, w, h)) or scpy ~= self.scroll.scpy then
        self.update2 = nil

        self.scroll.scpy = scpy
        dxSetRenderTarget(self.renderTarget2, true)

           -- dxDrawRectangle(0, 0, w, h, tocolor(200, 10, 10, 50))
            if #self.items > 0 then
                local ph = 0
                local py2 = -((self.scroll.y-h) * scpy)
                local rowH = self.rowStyle.height
                local resto = 0

                for i = 1, #self.items, 1 do
                    if py2 + rowH > 0 and py2 < h then

                        local row = self.items[i]
                        dxDrawRectangle(0, py2, w, rowH, self.rowStyle.backgroundColor)

                        if self.selectedType == 1 then
                            if self.selected == i then
                                dxDrawRectangle(0, py2, w, rowH, self.rowStyle.selectedColor)
                            end
                        end

                        local px2 = 0
                        if self.selectedType == 2 then
                            local fontH = self.columnStyle.fontH
                            --local checkH = coH*0.5
                            local textScale = checkH / fontH

                            dxDrawSmartOutlineBox(checkX, py2+(rowH-checkH)/2, checkH, checkH, tocolor(30, 30, 30, 255), 6, 2, 3, {left=true, right=true, top=true, bottom=true})

                            if self.selected[i] then
                                dxDrawText2('✔', checkX, py2+(rowH-checkH)/2, checkH, checkH, tocolor(13, 180, 13), textScale, self.columnStyle.font, 'center', 'center')
                            end

                            px2 = px2 + checkH + (checkX*2)
                        end
                            
                        local clickSwitch
                        if #self.columns > 0 then
                            for ci = 1, #self.columns do

                                local column = self.columns[ci]
                                local size = w * column.size
                                local font = self.columnStyle.font

                                local item = row[ci]
                                if item then
                                    local color = item.color
                                    local alignment = item.alignment or column.alignment

                                    
                                    dxSetBlendMode('modulate_add')
                                        dxDrawText2(tostring(item.text), px2+item.x, py2+item.y, size, rowH, color, 1, self.font, alignment, 'center', true, true, false, true)
                                    dxSetBlendMode('blend')
                                    
                                    if item.image then
                                        if item.image then

                                            local x, y = px2+item.image.x, py2 + item.image.y + (rowH - item.image.h) / 2
                                            if item.image.alignment == 'center' then
                                                x = x + (size - item.image.w) / 2
                                            elseif item.image.alignment == 'right' then
                                                x = x + size - item.image.w
                                            end

                                            dxDrawImage(x, y, item.image.w, item.image.h, item.image.path, 0, 0, 0, item.image.color)
                                        end
                                    end

                                    if item.switch then
                                        local w, h = 30,14
                                        local px2, py2 = math.round(px2 + item.switch.x + (size - w) / 2), math.round(py2 + item.switch.y + (rowH - h) / 2)

                                        dxDrawImage(px2, py2, w, h, dxLibrary.img['switch2'], 0, 0, 0, item.switch.backgroundColor)

                                        if item.switch.tick then
                                            item.switch.bx = interpolateBetween((item.switch.state and 0 or w-14), 0, 0, (not item.switch.state and 0 or w-14), 0, 0, (tick-item.switch.tick)/500, 'InOutQuad')
                                            if (tick-item.switch.tick)/500 >= 1 then
                                                item.switch.tick = nil
                                            end
                                        end
                                        
                                        dxDrawImage(px2+item.switch.bx, py2, 30, 14, dxLibrary.img['circle2'], 0, 0, 0, (item.switch.state and item.switch.onColor) or item.switch.offColor)
                                        

                                        if click and isCursorOver(x+px2, y+py2, w, h) then
                                            clickSwitch = true
                                            item.switch.state = not item.switch.state
                                            item.switch.tick = getTickCount()
                                            if self.onChange then
                                                self:onChange(i, item.switch.state)
                                            end
                                        end
                                    end
                                end

                                px2 = px2 + size
                            end
                        end

                        if isCursorOver(px, py+py2, w, rowH) and click and not clickSwitch then
                            if self.selectedType == 1 then
                                self.selected = i
                            else
                                self.selected[i] = not self.selected[i]
                            end
                        end
                    else
                        resto = resto + 1
                    end
                    py2 = py2 + rowH + self.rowStyle.padding
                    ph = ph + rowH + self.rowStyle.padding
                end
                self.scroll.y = ph
                self.resto = resto
            end

        if self.parent and self.parent.type == 'uiScrollpane' then
            dxSetRenderTarget(self.parent.renderTarget)
        else
            dxSetRenderTarget()
        end
    end

    if self.scroll.y > h and not self.scrollV.visible then
        self.scrollV.visible = true
    elseif self.scroll.y < h and self.scrollV.visible then
        self.scrollV.visible = false
    end

    dxSetBlendMode('add')
        dxDrawImage(math.round(x), math.round(y), w, h, self.renderTarget2)
    dxSetBlendMode('blend')

    if #self.childs > 0 then
        for i, class in ipairs(self.childs) do
            if class then  
                if class.visible then
                    class:dx(getTickCount())
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







