uiIcon = Class(uiElement)

function uiIcon:constructor(array)
    if not (array.image and (type(array.image) == 'string' and fileExists(array.image) or isElement(array.image))) then
        return error('Invalid Image')
    end

    self.type = 'uiIcon'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h
    self.image = array.image

    self.rotation = array.rotation or {0, 0, 0}
    self.backgroundColor = array.backgroundColor or -1
    self.childs = {}

    table.insert(dxLibrary.order, self)
    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end

    self.coord = {{x=self.x, offX=0}, {y=self.y, offY=0}, {w=self.w, offW=0}, {h=self.h, offH=0}}
    self:adjustPosition()

    return self
end

function uiIcon:dx()
    if (not self:isVisible()) then return end
    local w, h, x, y = self.w, self.h, self:getRealXY()

    dxDrawImage(x, y, w, h, (self.shader or self.image), self.rotation[1], self.rotation[2], self.rotation[3], self.backgroundColor, false)

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

function uiIcon:addMask(texture)
    assert(type(self.image) == 'string' or isElement(texture), 'The base image must be of type element/texture, not string/path.')

    if not isElement( self.shader ) then
        self.shader = DxShader("files/fx/hud_mask.fx")
        self.shader:setValue("sPicTexture", self.image)
    end

    self.shader:setValue("sMaskTexture", texture)
end

function uiIcon:removeMask()
    if isElement( self.shader ) then
        self.shader:destroy()
        self.shader = nil
    end
end

function uiIcon:load(image)
    if not (image and (type(image) == 'string' and fileExists(image) or isElement(image))) then
        return error('Invalid Image')
    end

    self.image = image

    if type(self.image) == 'userdata' and isElement( self.shader ) and isElement(self.image) then
        self.shader:setValue("sPicTexture", self.image)
    end
end