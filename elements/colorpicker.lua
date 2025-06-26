uiColorpicker = Class(uiElement)

function uiColorpicker:constructor(array)-- x, y, parent
    local self = self

    self.type = 'uiColorpicker'

    self.x = array.x
    self.y = array.y
    self.w = 250
    self.h = 250

    self.font = dxLibrary.Theme[dxLibrary.Theme.selected][self.type].font
    self.rounded = 6
    
    self.cursor = Vector2(10, 10)
    
    self.degrade = {
        color = {255, 255, 255, 255},
        cursorState = false,
        moving = false,

        settings = {
            cursorX = self.w / 2,
            cursorY = self.h / 4,
        }
    }

    self.degradeFile = File(":"..dxLibrary.name..'/files/colorpicker/degrade.png')
    self.degradeFile:close()

    self.spectrum = {
        color = {255, 255, 255, 255},
        cursorState = false,
        moving = false,

        settings = {
            cursorX = self.w / 2,
            cursorY = self.h / 2,
        }
    }

    self.sprectrumFile = File(":"..dxLibrary.name..'/files/colorpicker/spectrum.png')
    self.sprectrumPixels = dxConvertPixels(self.sprectrumFile:read(self.sprectrumFile.size), 'plain')
    self.sprectrumSizes = {dxGetPixelsSize(self.sprectrumPixels)}
    self.sprectrumFile:close()
    
    self.color = {255, 255, 255, 255}

    self.shader = DxShader(":"..dxLibrary.name.."/files/fx/hud_mask.fx")
    self.shader2 = DxShader(":"..dxLibrary.name.."/files/fx/hud_mask.fx")

    self.svgCallBack = function() 
        self.update = true
        self.shader:setValue("sMaskTexture", self.svg)
    end

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

    
    self.textureSpectrum = DxTexture(":"..dxLibrary.name.."/files/colorpicker/spectrum.png", "dxt5", false, "clamp" )
    self.shader2:setValue("sPicTexture", self.textureSpectrum)

    return self
end

function uiColorpicker:dx ()
    if (not self:isVisible()) then return end

    local w, h, x, y = self.w, self.h, self:getRealXY()

    if not self.renderTarget then
        self.renderTarget = dxCreateRenderTarget(w, h, true)
        self.shader:setValue("sPicTexture", self.renderTarget)
    end

    local imgX, imgY = 1, 1
    local imgWidth, imgHeight = w - 7, h / 2
    local spectrumX, spectrumY, spectrumW, spectrumH = 8, (imgY + imgHeight + 10) - 5, 235, 15

    if ((isElement(self.renderTarget) and isElement(self.svg)) and (self.spectrum.moving or self.degrade.moving or self.update)) then
        dxSetRenderTarget(self.renderTarget, true)

            dxDrawImage(0, 0, w, (h / 1.62), self.svg, 0, 0, 0, tocolor(255, 255, 255, 255), false)
            
            dxDrawImage(imgX, imgY, imgWidth, imgHeight, ":"..dxLibrary.name..'/files/colorpicker/degrade.png', 0, 0, 0, tocolor(self.spectrum.color[1], self.spectrum.color[2], self.spectrum.color[3]), false)
            dxDrawImage(spectrumX, spectrumY, spectrumW, spectrumH, self.shader2, 0, 0, 0, tocolor(255, 255, 255, 255), false)
    
        dxSetRenderTarget()
    end

    dxSetBlendMode('add')
        dxDrawImage(x, y, w, h, self.shader)

        dxDrawImage(math.max(x+1.5, math.min(x+self.degrade.settings.cursorX-self.cursor.x/2, x+imgWidth-self.cursor.x)), math.max(y+1.6, math.min(y+self.degrade.settings.cursorY-self.cursor.y/2, y+imgHeight-self.cursor.y)), self.cursor.x, self.cursor.y, ":"..dxLibrary.name..'/files/colorpicker/cursor.png', 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawImage(x+self.spectrum.settings.cursorX, y+self.spectrum.settings.cursorY, self.cursor.x, self.cursor.y, ":"..dxLibrary.name..'/files/colorpicker/cursor.png', 0, 0, 0, tocolor(255, 255, 255, 255))
    dxSetBlendMode('blend')

    if isCursorOver(x + imgX, y + imgY, imgWidth, imgHeight) and not self.degrade.cursorState and getKeyState('mouse1') then
        self.degrade.cursorState = true
        self.degrade.moving = true
    end
    
    if isCursorShowing() and self.degrade.moving then
        self:updateDegrade(x, y, w, h)
    end
    
    if isCursorOver(x + spectrumX, y + spectrumY, spectrumW, spectrumH) and not self.spectrum.cursorState and getKeyState('mouse1') then
        self.spectrum.cursorState = true
        self.spectrum.moving = true
    end

    if isCursorShowing() and self.spectrum.moving then
        self:updateSpectrum(x, y, w, h)
    end

    if (not getKeyState('mouse1') and self.degrade.moving) then
        self.degrade.moving = false
    elseif (not getKeyState('mouse1') and self.spectrum.moving) then
        self.spectrum.moving = false
    end
    
    if self.update then
        self.update = nil
    end

    self.color = self.degrade.color
    self.degrade.cursorState, self.spectrum.cursorState = getKeyState('mouse1'), getKeyState('mouse1')

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

function uiColorpicker:getColor()
    return self.color
end

function uiColorpicker:updateDegrade(x, y, w, h)
    local imgX = 3
    local imgWidth, imgHeight = w - 7, h / 2
    local cursorX, cursorY

    if x and y then
        local cursor = self:getCursor()
        cursorX, cursorY = cursor.x - x, cursor.y - y

        cursorX = math.max(1.5, math.min(cursorX, imgWidth-5))
        cursorY = math.max(1.6, math.min(cursorY, imgHeight))
        
        self.degrade.settings.cursorX, self.degrade.settings.cursorY = cursorX, cursorY
    else
        cursorX, cursorY = self.degrade.settings.cursorX, self.degrade.settings.cursorY
    end

    local color = {dxGetPixelColor(dxGetTexturePixels(self.renderTarget), math.max(11, cursorX), math.max(3, cursorY))}
    self.degrade.color = {color[1], color[2], color[3]}
    
    if self.onChange then
        self:onChange(color[1], color[2], color[3])
    end

end

function uiColorpicker:updateSpectrum(x, y, w, h)
    local imgX = 1.5
    local imgWidth, imgHeight = w - 7, h / 2
    local imgY = (h - imgHeight) / 100
    local spectrumX, spectrumY, spectrumW, spectrumH = 8, (imgY + imgHeight + 10) - 5, 235, 15

    local cursor = self:getCursor()
    cursorX, cursorY = cursor.x - x, cursor.y - y
    
    cursorX = math.max(spectrumX, math.min(cursorX, spectrumX + spectrumW - self.cursor.x))
    cursorY = math.max(spectrumY, math.min(cursorY, spectrumY + spectrumH - self.cursor.y))            

    local color = {dxGetPixelColor(
        self.sprectrumPixels,
        (self.sprectrumSizes[1] / spectrumW) * (cursorX - spectrumX),
        (self.sprectrumSizes[2] / spectrumH) * (cursorY - spectrumY)
    )}

    self.spectrum.settings.cursorX, self.spectrum.settings.cursorY = cursorX, cursorY
    self.spectrum.color = {color[1], color[2], color[3]}

    self:updateDegrade(_,_,w,h)
end

