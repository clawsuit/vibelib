local lastClickTime = 0

dxLibrary.events = {'onClick', 'onChange', 'onEnter', 'onLeave'}

dxLibrary.restoreTarget = {}
dxLibrary.mouseWheels = {}
dxLibrary.testMode = false

function dxLibrary.global_render()
	local tick = getTickCount()
	for i, class in ipairs(dxLibrary.render) do
		if class and not class.parent then
			class:dx(tick)
		end
	end

	if dxLibrary.testMode and isCursorShowing() then
		local screen = Vector2(guiGetScreenSize())
		local cursor = Vector2(getCursorPosition()) * screen
		dxDrawText(inspect(cursor), screen.x/2, 0)
	end
end


function dxLibrary.global_click(button, state, aX, aY)
	local currentTime = getTickCount() / 500

	if (currentTime - lastClickTime) < 1 then return end

	lastClickTime = currentTime

	local editInside
	for i = #dxLibrary.order, 1, -1 do

		local self = dxLibrary.order[i]
		if self then
			
			if self:isCursorOver() and self:isVisible() and self.enabled and self.type ~= 'uiSlider'then
				
				local cancel
				if self.onClick then
					cancel = self:onClick(button, state)
				end

				if not cancel then

					if button == 'left' then

						if self.type == 'uiWindow' then
							if state == 'down' then
								
								if self:isCursorOver('windowTitle') then
									self.movePos = Vector2(aX, aY)
								elseif self:isCursorOver('windowClose') then
									if self.onClose then
										self:onClose()
									end
									self:destroy()
								end

							else
								self.movePos = nil
							end
						elseif self.type == 'uiCheckbox' then
							if state == 'down' then
								self.state = not self.state
							end
						elseif self.type == 'uiSwitch' then
							if state == 'down' then

								self.state = not self.state
								self.tick = getTickCount()

								if self.onChange then
									self:onChange()
								end

							end
						elseif self.type == 'uiRadioButton' then
							if state == 'down' then
								local group = dxLibrary.radioButtonGroups[self.groupKey]

								if group.state and group.state ~= self then
									--group.state:setSelected(false)
								end
								
								group.state = self

								if self.onChange then
									self:onChange(group.state)
								end
							end
						elseif self.type == 'uiCombobox' then
							if state == 'down' then

								self.stateList = not self.stateList
								-- self.tick = getTickCount()
							end
						elseif self.type == 'uiEditbox' then
							dxLibrary.editSelected = self
							editInside = true
						elseif self.type == 'uiMemo' and not self.readOnly then
							dxLibrary.editSelected = self
							editInside = true
							self:moveCaretToPosition(button, state, aX, aY)
						end
					end
				end
			else
				if i == #dxLibrary.order then
					if not editInside then
						dxLibrary.editSelected =  nil
					end
				end
			end
		end
	end
end

function dxLibrary.global_move()
	for i = #dxLibrary.order, 1, -1 do
		local self = dxLibrary.order[i]
		if self then
			if self:isVisible() and self.enabled then
				if self:isCursorOver() then
					if not dxLibrary.inside[self.id] then
						dxLibrary.inside[self.id] = true
						if self.onEnter then
							self:onEnter()
						end
					end
				else
					if dxLibrary.inside[self.id] then
						dxLibrary.inside[self.id] = nil
						if self.onLeave then
							self:onLeave()
						end
					end
				end
			end
		end
	end
end


-- function dxLibrary.global_key(key, press)
-- 	local edit = dxLibrary.editSelected
-- 	if edit then
-- 		if edit:isVisible() and edit.enabled then
-- 			if edit.onKey then
-- 				edit:onKey(key, press)
-- 			end
-- 		end	
-- 	end

-- 	local isKey = key == 'mouse_wheel_up' or key == 'mouse_wheel_down'
-- 	if not isKey then return end
-- 	if not press then return end
-- 	if #dxLibrary.mouseWheels == 0 then return end

-- 	for i = 1, #dxLibrary.mouseWheels do
-- 		local self = dxLibrary.mouseWheels[i]
-- 		if self then
-- 			if self:isVisible() and self.enabled then

-- 				if self.type == 'uiScroll' then
-- 					if (not self.parent and self:isCursorOver()) or (self.parent and self.parent.type ~= 'uiTab' and self.parent:isCursorOver() and self.vertical) then -- 

-- 						local resto = 0
-- 						if (self.parent and self.parent:isCursorOver() and self.vertical) then
-- 							resto = self.parent.resto*0.7
-- 						end

-- 						local sum = ((self.vertical and self.h or self.w) * 0.7) * (1/(resto))--0.01
-- 						local direction = key == 'mouse_wheel_up' and -1 or 1

-- 						self.to = math.max(0, math.min(self.to + sum * direction, (self.vertical and self.h * 0.7 or self.w * 0.7)))

-- 						self.easing = 'Linear'
-- 						self.lapse = 300
-- 						self.tick = getTickCount()
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function dxLibrary.global_key(key, press)
    local edit = dxLibrary.editSelected
    if edit and edit:isVisible() and edit.enabled and edit.onKey then
        edit:onKey(key, press)
    end

    local isKey = key == 'mouse_wheel_up' or key == 'mouse_wheel_down'
    if not isKey or not press or #dxLibrary.mouseWheels == 0 then return end

    for i = 1, #dxLibrary.mouseWheels do
        local self = dxLibrary.mouseWheels[i]
        if self and self:isVisible() and self.enabled then

            if self.type == 'uiScroll' then
                if (not self.parent and self:isCursorOver()) or
                   (self.parent and self.parent.type ~= 'uiTab' and self.parent.type ~= 'uiMemo' and self.parent:isCursorOver() and self.vertical) then

                    local resto = (self.parent and self.parent.resto or 1) * 0.7
                    local sum = ((self.vertical and self.h or self.w) * 0.7) * (1 / (resto > 0 and resto or 1))
                    local direction = key == 'mouse_wheel_up' and -1 or 1

                    self.to = math.max(0, math.min(self.to + sum * direction, (self.vertical and self.h * 0.7 or self.w * 0.7)))
                    self.easing = 'Linear'
                    self.lapse = 300
                    self.tick = getTickCount()
                end

            elseif self.type == 'uiMemo' and self:isCursorOver() then
			    local totalHeight = #self.lines * self.lineHeight
			    local visibleHeight = self.h

			    if totalHeight > visibleHeight then
			        local scrollStep = self.lineHeight * (key == 'mouse_wheel_up' and -1 or 1)
			        local currentScroll = self.scrollV:getProgress() * (totalHeight - visibleHeight)
			        local newScroll = math.max(0, math.min(currentScroll + scrollStep, totalHeight - visibleHeight))
			        local progress = newScroll / (totalHeight - visibleHeight)

			        self.scrollV:setProgress(progress)
			    end
			end
        end
    end
end


function dxLibrary.global_character(character)
	local edit = dxLibrary.editSelected
	if edit then
		if edit:isVisible() and edit.enabled then
			if edit.onCharacter then
				edit:onCharacter(character)
			end
		end	
	end
end

function dxLibrary.global_paste(text)
	local edit = dxLibrary.editSelected
	if edit then
		if edit:isVisible() and edit.enabled then
			if edit.onPaste then
				edit:onPaste(text)
			end
		end	
	end
end

function dxLibrary.global_restore()
	for i = #dxLibrary.restoreTarget, 1, -1 do
        local v = dxLibrary.restoreTarget[i]
        if v then
            v.update = true
   			v.update2 = true
        end
    end 
end

function dxLibrary.render_check()
	if isMTAWindowActive(  ) then
        if not dxLibrary.isWindowActive then
            dxLibrary.isWindowActive =  true
        end
    elseif dxLibrary.isWindowActive then
        dxLibrary.isWindowActive = false
        dxLibrary.global_restore()
    end
end

function dxLibrary.init()
	addEventHandler('onClientClick', root, dxLibrary.global_click)
	addEventHandler('onClientKey', root, dxLibrary.global_key)

	addEventHandler('onClientCharacter', root, dxLibrary.global_character)
	addEventHandler('onClientPaste', root, dxLibrary.global_paste)
	addEventHandler('onClientRestore', root, dxLibrary.global_restore)
	--addEventHandler('onClientCursorMove', root, dxLibrary.global_move)
end

--dxLibrary.init()

