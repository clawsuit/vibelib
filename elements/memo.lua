uiMemo = Class(uiElement)

function uiMemo:constructor(array)
    self.type = 'uiMemo'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h

    self.text = array.text or ""
    self.font = array.font or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.textColor = array.color or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].textColor
    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background

    self.readOnly = array.readOnly or false
    self.masked = array.masked or false
    self.rounded = array.rounded or math.round((5/768)*self.screen.y)
    self.padding = self.rounded == 0 and 5 or self.rounded

    self.scroll = {y = 0}
    self.scrollOffset = 0

    self.lineHeight = dxGetFontHeight(1, self.font) * 1.3
    self.caretLine = 1
    self.caretPos = 0
    self.caretVisible = true
    self.lastCaretBlink = getTickCount()

    self.childs = {}

    table.insert(dxLibrary.order, self)
    if type(array.parent) == "table" and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end
    table.insert(dxLibrary.mouseWheels, self)

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    self:updateSvg()

    self.lines = self:splitLines(self.text)


    self.scrollV = uiScroll({
        x = 0, y = 0,
        w = 100,
        vertical = true,
        parent = self
    })
    self.scrollV.visible = false
    --self.scrollV:setPosition(0, 0, 0, 0)
    --self.scrollV:setSize(0, 100, 0, -2)
    self.scrollV:right(-0.5, -self.scrollV.w)

    return self
end

function uiMemo:splitLines(text)
    local lines = {}
    for line in text:gmatch("([^\r\n]*)[\r\n]?") do
        if string.match(line, "^%s*$") then
            table.insert(lines, '')
        else
            if dxGetTextWidth(line, 1, self.font) > self.w + self.padding * 2 and #line > 1 then

                local new = ''
                for i = 1, #line do
                    local k = line:sub(i,i)

                    if dxGetTextWidth(new..k, 1, self.font) > self.w + self.padding * 2 then
                        table.insert(lines, new)
                        new = ''
                    end

                    new = new..k
                end

                table.insert(lines, new)
            else
                table.insert(lines, line)
            end
        end
    end
    table.remove(lines)
    --iprint(lines)
    return lines
end


function uiMemo:setText(text)
    self.text = text or ""
    self.lines = self:splitLines(self.text)

    local totalLines = #self.lines
    self.caretLine = totalLines
    self.caretPos = utf8.len(self.lines[totalLines] or "")

    local totalHeight = totalLines * self.lineHeight
    local visibleHeight = self.h
    if totalHeight > visibleHeight then
        local scrollProgress = (totalHeight - visibleHeight) / (totalHeight - visibleHeight)
        self.scrollV:setProgress(scrollProgress)
    else
        self.scrollV:setProgress(0)
    end
end

function uiMemo:getText()
    return self.text
end

function uiMemo:setMasked(mask)
    self.masked = mask
end

function uiMemo:setReadOnly(state)
    self.readOnly = state
end


function uiMemo:onCharacter(char)
    if self.readOnly then return end

    local line = self.lines[self.caretLine] or ""
    local before = utf8.sub(line, 1, self.caretPos)
    local after = utf8.sub(line, self.caretPos + 1)

    local newLine = before .. char .. after

    self.lines[self.caretLine] = nil
    table.remove(self.lines, self.caretLine)

    local wrapped = {}
    local new = ""
    for i = 1, #newLine do
        local k = newLine:sub(i,i)
        if dxGetTextWidth(new .. k, 1, self.font) > self.w - self.padding * 2 then
            table.insert(wrapped, new)
            new = ""
        end
        new = new .. k
    end
    table.insert(wrapped, new)

    for i = #wrapped, 1, -1 do
        table.insert(self.lines, self.caretLine, wrapped[i])
    end

    if #wrapped == 1 then
        self.caretPos = utf8.len(before .. char)
    else
        self.caretLine = self.caretLine + (#wrapped - 1)
        self.caretPos = utf8.len(wrapped[#wrapped])
    end

    self:updateTextFromLines()
end

-- function uiMemo:onCharacter(char)
--     if self.readOnly then return end

--     -- Obtener línea actual
--     local line = self.lines[self.caretLine] or ""
--     local before = utf8.sub(line, 1, self.caretPos)
--     local after = utf8.sub(line, self.caretPos + 1)

--     local newLine = before .. char .. after

--     self.lines[self.caretLine] = nil
--     table.remove(self.lines, self.caretLine)

--     local wrapped = {}
--     local tmp = ""
--     for i = 1, #newLine do
--         local k = newLine:sub(i,i)
--         if dxGetTextWidth(tmp .. k, 1, self.font) > self.w - self.padding * 2 then
--             table.insert(wrapped, tmp)
--             tmp = ""
--         end
--         tmp = tmp .. k
--     end
--     table.insert(wrapped, tmp)

--     for i = #wrapped, 1, -1 do
--         table.insert(self.lines, self.caretLine, wrapped[i])
--     end

--     if #wrapped == 1 then
--         self.caretPos = utf8.len(before .. char)
--     else
--         self.caretLine = self.caretLine + (#wrapped - 1)
--         if self.caretPos == utf8.len(before .. after) then
            
--             self.caretPos = utf8.len(wrapped[#wrapped])
--         else
--             self.caretPos = utf8.len(before .. char)
--         end
--     end

--     self:updateTextFromLines()
-- end


function uiMemo:onPaste(text)
    if self.readOnly then return end
    --for char in text:gmatch(".") do
        for i = 1, #text do
            self:onCharacter(text:sub(i,i))
        end
    --end
end

function uiMemo:onKey(key, press)
    if self.readOnly or not press then return end

    local line = self.lines[self.caretLine] or ""

    if key == "backspace" then
        if self.caretPos > 0 then
            local before = utf8.sub(line, 1, self.caretPos - 1)
            local after = utf8.sub(line, self.caretPos + 1)
            self.lines[self.caretLine] = before .. after
            self.caretPos = self.caretPos - 1
        elseif self.caretLine > 1 then
            local prev = self.lines[self.caretLine - 1]
            self.caretPos = utf8.len(prev)
            self.lines[self.caretLine - 1] = prev .. line
            table.remove(self.lines, self.caretLine)
            self.caretLine = self.caretLine - 1
        end
    elseif key == "enter" then
        local before = utf8.sub(line, 1, self.caretPos)
        local after = utf8.sub(line, self.caretPos + 1)
        self.lines[self.caretLine] = before
        table.insert(self.lines, self.caretLine + 1, after)
        self.caretLine = self.caretLine + 1
        self.caretPos = 0
    elseif key == "arrow_l" then
        if self.caretPos > 0 then
            self.caretPos = self.caretPos - 1
        elseif self.caretLine > 1 then
            self.caretLine = self.caretLine - 1
            self.caretPos = utf8.len(self.lines[self.caretLine] or "")
        end
    elseif key == "arrow_r" then
        if self.caretPos < utf8.len(line) then
            self.caretPos = self.caretPos + 1
        elseif self.caretLine < #self.lines then
            self.caretLine = self.caretLine + 1
            self.caretPos = 0
        end
    elseif key == "arrow_u" then
        if self.caretLine > 1 then
            self.caretLine = self.caretLine - 1
            self.caretPos = math.min(self.caretPos, utf8.len(self.lines[self.caretLine] or ""))
        end
    elseif key == "arrow_d" then
        if self.caretLine < #self.lines then
            self.caretLine = self.caretLine + 1
            self.caretPos = math.min(self.caretPos, utf8.len(self.lines[self.caretLine] or ""))
        end
    end

    self:updateTextFromLines()
    self:ensureCaretVisible()
end



function uiMemo:dx()
    if (not self:isVisible()) then return end
    if not isElement(self.svg) then return end

    local w, h, x, y = self.w, self.h, self:getRealXY()
    dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, self.backgroundColor)

    local visibleLines = math.floor(h / self.lineHeight)
    local startLine = math.floor(self.scrollV:getProgress() * math.max(0, #self.lines - visibleLines)) + 1
    local my = y + self.padding

    local caretDrawn = false
    local now = getTickCount()
    if now - self.lastCaretBlink >= 500 then
        self.caretVisible = not self.caretVisible
        self.lastCaretBlink = now
    end

    for i = startLine, math.min(#self.lines, startLine + visibleLines - 1) do
        local lineText = self.lines[i] or ""
        dxDrawText(lineText, x + self.padding, my, x + w - self.padding, my + self.lineHeight, self.textColor, 1, self.font, "left", "top", true)

        if not self.readOnly and self.caretVisible and i == self.caretLine and not caretDrawn and dxLibrary.editSelected == self then
            local beforeText = utf8.sub(lineText, 1, self.caretPos)
            local textWidth = dxGetTextWidth(beforeText, 1, self.font)
            dxDrawLine(x + self.padding + textWidth, my-1, x + self.padding + textWidth, my + self.lineHeight-1, self.textColor, 1)
            caretDrawn = true
        end
        my = my + self.lineHeight
    end

    local needScroll = (#self.lines * self.lineHeight) > h
    self.scrollV.visible = needScroll
    if not needScroll then
        self.scrollV:setProgress(0)
    end

    if #self.childs > 0 then
        for i, class in ipairs(self.childs) do
            if class then  
                if class.visible then
                    class:dx(getTickCount())
                end
            end
        end
    end 
end

function uiMemo:updateTextFromLines()
    self.text = table.concat(self.lines, "\n")
end

function uiMemo:ensureCaretVisible()
    local h = self.h
    local visibleLines = math.floor(h / self.lineHeight)
    local totalLines = #self.lines
    local scrollLine = math.floor(self.scrollV:getProgress() * math.max(0, totalLines - visibleLines)) + 1

    if self.caretLine < scrollLine then
        self.scrollV:setProgress((self.caretLine - 1) / math.max(1, totalLines - visibleLines))
    elseif self.caretLine > scrollLine + visibleLines - 1 then
        self.scrollV:setProgress((self.caretLine - visibleLines) / math.max(1, totalLines - visibleLines))
    end
end

function uiMemo:moveCaretToPosition(button, state, aX, aY)
    if self.readOnly or button ~= "left" or state ~= "down" then return end

    local x, y = self:getRealXY()
    local relX, relY = aX - x, aY - y

    local visibleLines = math.floor(self.h / self.lineHeight)
    local startLine = math.floor(self.scrollV:getProgress() * math.max(0, #self.lines - visibleLines)) + 1
    local clickedLine = math.floor((relY - self.padding) / self.lineHeight) + startLine

    clickedLine = math.max(1, math.min(#self.lines, clickedLine))
    self.caretLine = clickedLine

    local lineText = self.lines[clickedLine] or ""
    local bestPos = 0
    local bestDist = math.huge

    for i = 0, utf8.len(lineText) do
        local subText = utf8.sub(lineText, 1, i)
        local width = dxGetTextWidth(subText, 1, self.font)
        local dist = math.abs(width - (relX - self.padding))

        if dist < bestDist then
            bestDist = dist
            bestPos = i
        end
    end

    self.caretPos = bestPos
    self:ensureCaretVisible()
end