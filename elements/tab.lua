uiTab = Class(uiElement)

function uiTab:constructor(text, image, parent)
    if not (parent and parent.type == 'uiTabpanel') then
        return
    end

    self.type = 'uiTab'
    self.text = text or 'tab'

    if image then
        self.image = {
            path = image.path,
            alignment = image.alignment or 'left',
            x = image.x or 0,
            y = image.y or 0,
            w = self:calc(dxGetFontHeight(1, parent.font), image.w or 0),
            h = self:calc(dxGetFontHeight(1, parent.font), image.h or 0),
            color = image.color or -1
        }
    end

    self.childs = {}
    self.parent = parent
    table.insert(self.parent.childs, self)

    return self
end

-- function uiTab:destroy()
--     if self.parent then
--         for i, child in ipairs(self.parent.childs) do
--             if child == self then
--                 table.remove(self.parent.childs, i)
--                 break
--             end
--         end
--     end

--     for i, element in ipairs(dxLibrary.render) do
--         if element == self then
--             table.remove(dxLibrary.render, i)
--             break
--         end
--     end

--     self.childs = nil
--     self.parent = nil
-- end