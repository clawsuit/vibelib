uiSwitch = Class(uiElement)



dxLibrary.img = {
    circle1 = svgCreate(34, 14, [[
        <svg width="30" height="14">
            <circle cx="7" cy="7" r="7" fill="#fff"/>
        </svg>
    ]]),
    switch1 = svgCreate(30, 14, [[
        <svg width="30" height="14">
            <rect x="0" y="2" width="30" height="10" rx="5" ry="5" fill="#fff" />
        </svg>
    ]]),

    circle2 = svgCreate(34, 14, [[
        <svg width="30" height="14">
            <circle cx="7" cy="7" r="5.5" fill="#fff"/>
        </svg>
    ]]),
    switch2 = svgCreate(30, 14, [[
        <svg width="30" height="14">
            <rect x="0" y="0" width="30" height="14" rx="7" ry="7" fill="white" />
        </svg>
    ]]),

    circle3 = svgCreate(34, 14, [[
        <svg width="30" height="14">
            <circle cx="7" cy="7" r="4" fill="#fff"/>
        </svg>
    ]]),
    switch3 = svgCreate(30, 14, [[
        <svg width="30" height="14">
            <rect x="1" y="1" width="28" height="12" rx="6" ry="6" fill="none" stroke-width="2"  stroke="#fff" />
        </svg>
    ]]),
}
        
function uiSwitch:constructor(array)--x, y, parent, backgroundColor, onColor, offColor, mode)
    self.type = 'uiSwitch'
    self.mode = tonumber(array.mode) and math.max(1, math.min(array.mode, 3)) or 2
    self.x = math.round(array.x)
    self.y = math.round(array.y)

    self.w = 30
    self.h = 14

    self.opacity = 1
    self.bx = 0
    self.state = false

    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.onColor     = array.onColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].on
    self.offColor    = array.offColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].off

    table.insert(dxLibrary.order, self)
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




function uiSwitch:dx(tick)
    if (not self:isVisible()) then return end

    --local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    local x, y = self:getRealXY()

    local w, h = self.w*0.4, self.h
    if self.mode == 1 then
        x = x - 1
    end

    if self.tick then
        self.bx = interpolateBetween((self.state and 0 or self.w-w-(self.mode == 1 and 1 or 2)), 0, 0, (not self.state and 0 or self.w-w-(self.mode == 1 and 1 or 2)), 0, 0, (tick-self.tick)/500, 'InOutQuad')
        if (tick-self.tick)/500 >= 1 then
            self.tick = nil
        end
    end

    dxDrawImage(x, y, self.w, self.h, dxLibrary.img['switch'..self.mode], 0, 0, 0, self:gColor(self.backgroundColor))
    dxDrawImage(x+self.bx, y, self.w, self.h, dxLibrary.img['circle'..self.mode], 0, 0, 0, (self.state and self.onColor or self.offColor))

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




-- switch1 = uiSwitch({x=20, y=200, mode=1})
-- switch2 = uiSwitch({x=20, y=250, mode=2})
-- switch3 = uiSwitch({x=20, y=300, mode=3})