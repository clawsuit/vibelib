--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias Array { x: number, y: number, w: number, h: number, parent?: uiElement, rounded?: number, backgroundColor?: integer, padding?: number, title?: string, placeholder?: string, maxLength?: number, masked?: boolean }

--- @class uiEditbox: uiElement
--- @field constructor fun(self: uiEditbox, array: Array): uiEditbox
--- @field getText fun(self: uiEditbox): string
--- @field setText fun(self: uiEditbox, text: string): boolean
--- @field setMaxLength fun(self: uiEditbox, length: number): boolean
uiEditbox = Class(uiElement)

--- @param array Array
--- @return uiEditbox
function uiEditbox:constructor(array)
	self.type = "uiEditbox"
	self.x = array.x
	self.y = array.y
	self.w = array.w
	self.h = array.h
	self.masked = array.masked or false
	self.padding = array.padding or 10
	self.rounded = tonumber(array.rounded) or 5
	self.outline = 0
	self.outlineColor = -1
	self.text = ""
	self.title = array.title-- or "Input Title"
	self.placeholder = array.placeholder or "Input Placeholder"
	self.maxLength = array.maxLength or 64
	self.titleFont = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].titleFont
	self.titleFontScale = 1--self:getScale(1)
	self.titleFontHeight = dxGetFontHeight(self.titleFontScale, self.titleFont)
	self.textFont = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].textFont
	self.textFontScale = 1--self:getScale(1)
	self.textFontHeight = dxGetFontHeight(self.textFontScale, self.textFont)
	self.cursorPosition = 0
	self.selectionStart = nil
	self.selectionEnd = nil
	self.writeTick = 0
	local backgroundColor = array.backgroundColor
	local r, g, b, a
	if backgroundColor then
		r, g, b, a = color2rgb(backgroundColor)
	else
		r, g, b, a = color2rgb(dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background)
	end
	self.backgroundColor = { r, g, b, a }
	self.hovered = false
	self.hovering = false
	self.progress = 0
	self.tick = 0
	table.insert(dxLibrary.order, self)
	--- @diagnostic disable-next-line: undefined-field
	if type(array.parent) == "table" and dxLibrary.parentValids[array.parent.type] then
		self.parent = array.parent
		--- @diagnostic disable-next-line: undefined-field
		table.insert(self.parent.childs, self)
	else
		table.insert(dxLibrary.render, self)
	end

	self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()
    self:updateSvg()

	return self
end

function uiEditbox:getText()
	return self.text
end

function uiEditbox:setText(text)
	if not text or type(text) ~= "string" then
		return false
	end
	self.text = ""
	self.cursorPosition = 0
	self.selectionStart = nil
	self.selectionEnd = nil
	self:onPaste(text)
	return true
end

function uiEditbox:setMaxLength(length)
    if not length or type(length) ~= "number" then
        return false
    end
    self.maxLength = length
    return true
end

function uiEditbox:onKey(key, pressed)
	if not pressed then
		return
	end

	local isShiftPressed = getKeyState("lshift") or getKeyState("rshift")
	local isCTRLPressed = getKeyState("lctrl") or getKeyState("rctrl")

	if key == "a" and isCTRLPressed then
		self.selectionStart = 0
		self.selectionEnd = utf8.len(self.text)
		self.cursorPosition = self.selectionEnd
		self.writeTick = getTickCount()
	elseif key == "c" and isCTRLPressed then
		if self.selectionStart and self.selectionEnd and self.selectionStart ~= self.selectionEnd then
			local start = math.min(self.selectionStart, self.selectionEnd)
			local finish = math.max(self.selectionStart, self.selectionEnd)
			local selectedText = utf8.sub(self.text, start + 1, finish)
			setClipboard(selectedText)
		end
	elseif key == "arrow_l" and isCTRLPressed then
		local pos = self.cursorPosition
		local foundSpace = false
		while pos > 0 do
			local char = utf8.sub(self.text, pos, pos)
			if char ~= " " then
				break
			end
			pos = pos - 1
			foundSpace = true
		end
		while pos > 0 do
			local char = utf8.sub(self.text, pos, pos)
			if char == " " then
				if foundSpace then
					pos = pos + 1
					break
				end
				foundSpace = true
			end
			pos = pos - 1
		end
		if isShiftPressed then
			if not self.selectionStart then
				self.selectionStart = self.cursorPosition
			end
			self.selectionEnd = pos
		else
			self.selectionStart = nil
			self.selectionEnd = nil
		end
		self.cursorPosition = pos
		self.writeTick = getTickCount()
	elseif key == "arrow_r" and isCTRLPressed then
		local pos = self.cursorPosition
		local textLength = utf8.len(self.text)
		local foundSpace = false
		while pos < textLength do
			local char = utf8.sub(self.text, pos + 1, pos + 1)
			if char ~= " " then
				break
			end
			pos = pos + 1
			foundSpace = true
		end
		while pos < textLength do
			local char = utf8.sub(self.text, pos + 1, pos + 1)
			if char == " " then
				break
			end
			pos = pos + 1
		end
		if isShiftPressed then
			if not self.selectionStart then
				self.selectionStart = self.cursorPosition
			end
			self.selectionEnd = pos
		else
			self.selectionStart = nil
			self.selectionEnd = nil
		end
		self.cursorPosition = pos
		self.writeTick = getTickCount()
	end
	if key == "arrow_l" then
		if self.cursorPosition > 0 then
			self.cursorPosition = self.cursorPosition - 1
			if isShiftPressed then
				if not self.selectionStart then
					self.selectionStart = self.cursorPosition + 1
				end
				self.selectionEnd = self.cursorPosition
			else
				self.selectionStart = nil
				self.selectionEnd = nil
			end
			self.writeTick = getTickCount()
		end
	elseif key == "arrow_r" then
		if self.cursorPosition < utf8.len(self.text) then
			self.cursorPosition = self.cursorPosition + 1
			if isShiftPressed then
				if not self.selectionStart then
					self.selectionStart = self.cursorPosition - 1
				end
				self.selectionEnd = self.cursorPosition
			else
				self.selectionStart = nil
				self.selectionEnd = nil
			end
			self.writeTick = getTickCount()
		end
	end
end

function uiEditbox:onCharacter(character)
	if self.selectionStart and self.selectionEnd and self.selectionStart ~= self.selectionEnd then
		local start = math.min(self.selectionStart, self.selectionEnd)
		local finish = math.max(self.selectionStart, self.selectionEnd)
		local beforeText = utf8.sub(self.text, 1, start)
		local afterText = utf8.sub(self.text, finish + 1)
		self.text = beforeText .. afterText
		self.cursorPosition = start
		self.selectionStart = nil
		self.selectionEnd = nil
	end
	if utf8.len(self.text) >= self.maxLength then
		return
	end
	local beforeText = utf8.sub(self.text, 1, self.cursorPosition)
	local afterText = utf8.sub(self.text, self.cursorPosition + 1)
	self.text = beforeText .. character .. afterText
	self.cursorPosition = self.cursorPosition + 1
	self.writeTick = getTickCount()
end

function uiEditbox:onPaste(text)
	if self.selectionStart and self.selectionEnd and self.selectionStart ~= self.selectionEnd then
		local start = math.min(self.selectionStart, self.selectionEnd)
		local finish = math.max(self.selectionStart, self.selectionEnd)
		local beforeText = utf8.sub(self.text, 1, start)
		local afterText = utf8.sub(self.text, finish + 1)
		self.text = beforeText .. afterText
		self.cursorPosition = start
		self.selectionStart = nil
		self.selectionEnd = nil
	end
	if utf8.len(self.text) >= self.maxLength then
		return
	end
	if utf8.len(self.text) + utf8.len(text) > self.maxLength then
		text = utf8.sub(text, 1, self.maxLength - utf8.len(self.text))
	end
	local beforeText = utf8.sub(self.text, 1, self.cursorPosition)
	local afterText = utf8.sub(self.text, self.cursorPosition + 1)
	self.text = beforeText .. text .. afterText
	self.cursorPosition = self.cursorPosition + utf8.len(text)
	self.writeTick = getTickCount()
end


function uiEditbox:dx(tick)

	if not isElement(self.svg) then return end
    if (not self:isVisible()) then return end

	local w, h, x, y = self.w, self.h, self:getRealXY()
    local px, py = x, y

    if self.parent and self.parent.type == 'uiScrollpane' then
        px, py = x, y
        x, y = self.x, self.y
    end

    local isSelected = dxLibrary.editSelected and dxLibrary.editSelected == self
	local currentTick = tick
	if isSelected then
		self.progress = interpolateBetween(self.progress, 0, 0, 1, 0, 0, math.min(1, (currentTick - self.tick) / 500), "Linear")
	elseif self.hovered then
		self.progress = interpolateBetween(self.progress, 0, 0, 0.9, 0, 0, math.min(1, (currentTick - self.tick) / 500), "Linear")
	else
		self.progress = interpolateBetween(self.progress, 0, 0, 0.8, 0, 0, math.min(1, (currentTick - self.tick) / 500), "Linear")
	end

	self.hovering = self:isCursorOver()
	if self.hovering and not self.hovered then
		self.hovered = true
		self.tick = getTickCount()
	elseif not self.hovering and self.hovered then
		self.hovered = false
		self.tick = getTickCount()
	end

	dxDrawImage(x,y,w,h,self.svg,0,0,0,tocolor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], 255 * self.progress))
	local titleX = x + self.padding
	local titleY = y

	if self.title then

		titleY = titleY + (h - self.titleFontHeight - self.textFontHeight) / 2.2
		dxDrawText2(self.title, titleX, titleY, w - self.padding * 2, self.titleFontHeight, tocolor(255, 255, 255, 255 * self.progress), self.titleFontScale, self.titleFont, "left", "top", true)
		
	end
	local textDisplay, caretOffset = self:getVisibleTextFragment()
	local textX = x + self.padding
	local textY = titleY + (self.title and self.titleFontHeight or 0)

	if isSelected and self.selectionStart and self.selectionEnd and self.selectionStart ~= self.selectionEnd then
		local start = math.min(self.selectionStart, self.selectionEnd)
		local finish = math.max(self.selectionStart, self.selectionEnd)
		local preText = utf8.sub(textDisplay, 1, start)
		local selText = utf8.sub(textDisplay, start + 1, finish)
		local preWidth = dxGetTextWidth(preText, self.textFontScale, self.textFont)
		local selWidth = dxGetTextWidth(selText, self.textFontScale, self.textFont)
		dxDrawRectangle(
			textX + preWidth,
			textY,
			selWidth,
			self.textFontHeight * 0.75,
			tocolor(75, 130, 180, 100 * self.progress)
		)
	end
	if (textDisplay == "" and not isSelected) then
		dxDrawText2(self.placeholder, textX, textY, w - self.padding * 2, (self.title and self.textFontHeight or h), tocolor(255, 255, 255, 255 * self.progress), self.textFontScale,	self.textFont, "left", "center", true )
	else
		dxDrawText2(textDisplay, textX, textY, w - self.padding * 2, (self.title and self.textFontHeight or h), tocolor(255, 255, 255, 255 * self.progress), self.textFontScale, self.textFont, "left", "center", true )
	end

	if isSelected then
		local caretProgress = math.abs(math.sin(currentTick / 500))
		local caretPosText = utf8.sub(textDisplay, 1, self.cursorPosition)
		local caretOffset = dxGetTextWidth(caretPosText, self.textFontScale, self.textFont)
		local caretWidth = 1
		local caretHeight = self.textFontHeight * 0.75
		local caretX = textX + caretOffset--caretOffset + caretWidth
		local caretY = textY + ((self.title and self.textFontHeight or h) - caretHeight) / 2
		if caretX > x + w - self.padding then
			caretX = x + w - self.padding
		end
		dxDrawRectangle(caretX, caretY, caretWidth, caretHeight, tocolor(255, 255, 255, 255 * caretProgress))
		local writeTime = getTickCount() - self.writeTick
		if writeTime > 100 or getKeyState("lshift") and writeTime > 40 then
			if getKeyState("backspace") then
				if self.selectionStart and self.selectionEnd and self.selectionStart ~= self.selectionEnd then
					local start = math.min(self.selectionStart, self.selectionEnd)
					local finish = math.max(self.selectionStart, self.selectionEnd)
					local beforeText = utf8.sub(self.text, 1, start)
					local afterText = utf8.sub(self.text, finish + 1)
					self.text = beforeText .. afterText
					self.cursorPosition = start
					self.selectionStart = nil
					self.selectionEnd = nil
				else
					if self.cursorPosition > 0 then
						local beforeText = utf8.sub(self.text, 1, self.cursorPosition - 1)
						local afterText = utf8.sub(self.text, self.cursorPosition + 1)
						self.text = beforeText .. afterText
						self.cursorPosition = self.cursorPosition - 1
					end
				end
				self.writeTick = getTickCount()
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

function uiEditbox:getVisibleTextFragment()
    local fullText = self.masked and string.rep("*", utf8.len(self.text)) or self.text
    local maxWidth = self.w - self.padding * 2
    local font = self.textFont
    local fontSize = self.textFontScale
    local caretPos = self.cursorPosition

    local startChar = 1
    local endChar = utf8.len(fullText)

    while startChar < caretPos do
        local fragment = utf8.sub(fullText, startChar, caretPos)
        local width = dxGetTextWidth(fragment, fontSize, font)
        if width <= maxWidth then
            break
        end
        startChar = startChar + 1
    end

    endChar = startChar
    while endChar <= utf8.len(fullText) do
        local fragment = utf8.sub(fullText, startChar, endChar)
        local width = dxGetTextWidth(fragment, fontSize, font)
        if width > maxWidth then
            endChar = endChar - 1
            break
        end
        endChar = endChar + 1
    end

    if endChar > utf8.len(fullText) then
        endChar = utf8.len(fullText)
    end

    local visibleText = utf8.sub(fullText, startChar, endChar)
    local caretOffset = dxGetTextWidth(utf8.sub(fullText, startChar, caretPos - 1), fontSize, font)

    return visibleText, caretOffset
end

