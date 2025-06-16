uiScrollpane = Class(uiElement)

function uiScrollpane:constructor(array)--x, y, w, h, parent)

    self.type = 'uiScrollpane'
    self.x = array.x
    self.y = array.y
    self.w = array.w
    self.h = array.h

    self.scrollX = 0
    self.scrollY = 0
    self.contentW = w
    self.contentH = h
    self.scrollbarW = 10
    self.scrollSpeed = 20
    self.childs = {}

    self.scrollV = uiScroll({x=self.w+3, y=self.y, w=self.h, vertical=true, parent = array.parent and array.parent or false})
    self.scroll = {y=0}

    if type(array.parent) == 'table' and dxLibrary.parentValids[array.parent.type] then
        self.parent = array.parent
        table.insert(self.parent.childs, self)
    else
        table.insert(dxLibrary.render, self)
    end
    return self
end



function uiScrollpane:dx()
    if not self:isVisible() then return end

    local x, y = self:getRealXY()
    local w, h = self.w, self.h
    local childs = self.childs

    local scpy = 0

    if self.scrollV.visible then
        scpy = self.scrollV:getPosition()
    end

    if not self.renderTarget then
        self.renderTarget = dxCreateRenderTarget(w, h, true)
    end

    dxDrawRectangle(x, y, w, h, tocolor(255, 0, 0, 10))

    if isElement(self.renderTarget) then
        dxSetRenderTarget(self.renderTarget, true)
            if #childs > 0 then
                for _, class in ipairs(childs) do
                    if class then
                        if class.visible then
                            class:dx(getTickCount())
                        end
                    end
                end
            end   
        dxSetRenderTarget()
    end

    dxSetBlendMode('add')
    dxDrawImage(x, y, w, h, self.renderTarget)
    dxSetBlendMode('blend')
end




