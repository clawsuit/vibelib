uiWindow = Class(uiElement)

function uiWindow:constructor(array)--x, y, w, h, text, rounded, close, backgroundColor, backgroundTitle, textColor)
    self.type = 'uiWindow'
    
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h
    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}

    self:adjustPosition()

    self.text = array.text or ''
    self.textAlign = 'center'

    self.closebutton = (array.close == nil and true) or array.close

    self.backgroundColor = array.backgroundColor or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].background
    self.backgroundTitle = array.backgroundTitle or dxLibrary.Theme[dxLibrary.Theme.selected][self.type].backgroundTitle
    self.textColor       = array.textColor

    self.font  = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.fontClose  = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].fontClose
    self.opacity = 1
    self.titleH = dxGetFontHeight(1, self.font)
    self.closeH = dxGetFontHeight(1, self.fontClose)
    self.closeW = dxGetTextWidth('X', 1, self.fontClose) * 2
    
    self.outline = {size=0, color=-1}
    self.rounded = array.rounded
    

    if self.rounded == nil or self.rounded == true then
        self.rounded = {5,5,5,5}
    elseif type(self.rounded) == 'number' then
        self.rounded = {self.rounded, self.rounded, self.rounded, self.rounded}
    elseif self.rounded == false then
        self.rounded = {0,0,0,0}
    end

    if array.center then
        self:center()
    end

    self:updateSvg()
    --print(self.type, self.x, self.y, self.w, self.h)
    --self.xml = svgGetDocumentXML(self.svg)

    self.shader = DxShader(":"..dxLibrary.name.."/files/fx/hud_mask.fx")

    self.textureRender = nil
    self.childs = {}
    self.update = true

    table.insert(dxLibrary.order, self)
    table.insert(dxLibrary.render, self)

    return self;
end

function uiWindow:dx(tick)

    if not self.visible then return end
    if not isElement(self.svg) then return end
    
    local Color = dxLibrary.Theme[dxLibrary.Theme.selected][self.type]
    local xw, xh = dxGetTextWidth( "X", 1, self.font ), dxGetFontHeight(1, self.font)
    local click = not self.click and getKeyState('mouse1') and not guiGetInputMode()
    local x, y, w, h = self.x, self.y, self.w, self.h
    
    ---------------------------------------------------------------------------------------------

    dxDrawImage(x, y, w, h, self.svg, 0, 0, 0, self:gColor(-1), false)

    local max = math.max(math.max(self.rounded[1], self.rounded[2]), math.max(self.rounded[3], self.rounded[4])) / 4 + 2
    local fw, fh = self.closeW, math.min( self.closeH, self:calc(self.h, 5)+max)
    --dxDrawRectangle(x+max, y, w-max*2, self.titleH, tocolor(255,0,0), false)
    dxDrawText2(self.text, x+max+fw, y+max+fh, w-(max+fw)*2, self.titleH, self:gColor(self.textColor or Color.text), 1, self.font, self.textAlign, "top", false, false, false, false)

    if self.closebutton then
        --dxDrawRectangle(x+w-max-self.closeW*2, y+fh, self.closeW, self.closeH, tocolor(255,0,0))
        dxDrawText2("X", x+w-max-self.closeW*1.5, y+fh, self.closeW, self.closeH, -1, 1, self.fontClose, "center", "top", false, false, false, false)
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
        

    if self.move then
        if self.movePos then

            local cursor = self:getCursor()
            local pos = (cursor - self.movePos)

            self.x = self.x + pos.x
            self.y = self.y + pos.y

            self.movePos = cursor

        end
    end

    if not getKeyState('mouse1') and self.movePos then
        self.movePos = nil
    end

    self.click = getKeyState('mouse1')
end

function uiWindow:setTextAlign(alignment)
    self.textAlign = alignment
end

function uiWindow:setOutline(size, color)
    self.outline = {size=size, color=color}
    self:updateSvg()
end







