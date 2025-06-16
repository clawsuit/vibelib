local Exports = {}
Exports.name = resource.name
Exports.string = [[
if not isOOPEnabled() then
    return outputDebugString('* El oop esta desactivado, agregue al meta <oop>true</oop>', 2)
end
]]

Exports.files = {'utils/usecfulls.lua', 'handler/definition.lua', 'handler/elements.lua', 'handler/events.lua', 
'elements/window.lua', 'elements/button.lua', 'elements/label.lua', 'elements/colorpicker.lua', 'elements/switch.lua', 
'elements/checkbox.lua', 'elements/radiobutton.lua', 'elements/slider.lua', 'elements/progress.lua', 'elements/treeview.lua', 
'elements/scrollpane.lua', 'elements/scroll.lua', 'elements/tabpanel.lua', 'elements/tab.lua', 'elements/icon.lua', 'elements/editbox.lua', 
'elements/memo.lua'
}


Exports.preCharge = function()
    for i, path in ipairs(Exports.files) do
        local file = File.open(path, true)
        local content = file:getContents()
        file:close()

        Exports.string = Exports.string..'\n'..content
    end

    if File.exists(':'..Exports.name..'/temp.lua') then
        File.delete(':'..Exports.name..'/temp.lua')
    end

    Exports.string = Exports.string..'\ndxLibrary.init()'
    
    local file = File.new(':'..Exports.name..'/temp.lua')
    file:write(Exports.string)
    file:close()
end
addEventHandler('onClientResourceStart', resourceRoot, Exports.preCharge)

function getLibrary()
    return [[function importLibrary()
        local file = fileOpen(':]]..Exports.name..[[/temp.lua', true)
        local content = fileRead(file, fileGetSize(file))
        fileClose(file)
        loadstring(content)()
        importLibrary = nil
    end
    importLibrary()
    ]]
end

--loadstring(exports.vibelib:getLibrary())()
