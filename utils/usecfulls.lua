function Class(base)
    local cls = {}
    cls.__index = cls

    local mt = {
        __call = function(class_tbl, ...)
            return class_tbl:new(...)
        end
    }

    if base then
        mt.__index = base
    end

    setmetatable(cls, mt)

    function cls:new(...)
        local instance = setmetatable({}, cls)

        if instance.virtual_constructor then
            instance:virtual_constructor()
        end

        if instance.constructor then
            instance:constructor(...)
        end

        return instance
    end

    return cls
end




function bind(func, ...)
	if not func then
		if DEBUG then
			outputConsole(debug.traceback())
			outputServerLog(debug.traceback())
		end
		error("Bad function pointer @ bind. See console for more details")
	end
	local boundParams = {...}
	return
	function(...)
		local params = {}
		local boundParamSize = select("#", unpack(boundParams))
		for i = 1, boundParamSize do
			params[i] = boundParams[i]
		end
		local funcParams = {...}
		for i = 1, select("#", ...) do
			params[boundParamSize + i] = funcParams[i]
		end
		return func(unpack(params))
	end
end


function dxDrawText2(t,x,y,w,h,...)
	dxDrawText(t,x,y,w+x,h+y,...)
end

function dxDrawBorderedText (outline1, outline2, text, left, top, right, bottom, color, colorShadow, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
    for oX = (outline1 * -1), outline1 do
        for oY = (outline2 * -1), outline2 do
            dxDrawText2 (text, left + oX, top + oY, right + oX, bottom + oY, colorShadow, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
        end
    end
    dxDrawText2 (text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning, fRotation, fRotationCenterX, fRotationCenterY)
end

function isCursorOver(x,y,w,h)

    if isCursorShowing() then

        local sx,sy = guiGetScreenSize(  ) 
        local cx,cy = getCursorPosition(  )
        local px,py = sx*cx,sy*cy

        if (px >= x and px <= x+w) and (py >= y and py <= y+h) then

            return true

        end

    end
    return false
end

function isCursorText(x,y,w,h)

    if isCursorShowing() then

        local sx,sy = guiGetScreenSize(  ) 
        local cx,cy = getCursorPosition(  )
        local px,py = sx*cx,sy*cy
        local w,h = w-x, h-y

        if (px >= x and px <= x+w) and (py >= y and py <= y+h) then

            return true

        end

    end
    return false
end


function color2rgb(color)
	return bitExtract(color,16,8),bitExtract(color,8,8), bitExtract(color,0,8), bitExtract(color,24,8)
end

function rgb2hex(red, green, blue, alpha)
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function color2hex(color)
	local red, green, blue, alpha = color2rgb(color)
	return rgb2hex(red, green, blue)
end

function math.round(number, decimals)
    return tonumber(string.format(("%."..(decimals or 0).."f"), number))
end

function getScreenScale(bx, by)
    local sx, sy = guiGetScreenSize()
    local sw, sh = sx/bx, sy/by
    local scale = math.sqrt((sx*sy)/(bx*by))--math.max(0.65, sh)
    local scale = scale - (sh-scale)
    return sx, sy, sw, sh, scale
end

function lerpColor(color1, color2)
    local r = math.min((color1[1] / 255) * (color2[1] / 255) * 255, 255)
    local g = math.min((color1[2] / 255) * (color2[2] / 255) * 255, 255)
    local b = math.min((color1[3] / 255) * (color2[3] / 255) * 255, 255)
    local r, g, b = math.floor(r), math.floor(g), math.floor(b)
    
    return {r, g, b}
end

function table.find (t, d)
    for i, v in ipairs(t) do
        if v == d then
            return i
        end
    end

    return nil
end

function colorToRgba(color)
   return bitExtract(color,16,8),bitExtract(color,8,8), bitExtract(color,0,8), bitExtract(color,24,8)
end

_guiSetInputMode = guiSetInputMode
_guiGetInputMode = guiGetInputMode

local inputMode = "allow_binds"
function guiSetInputMode(bool)
    if bool then
        guiSetInputMode ( "no_binds" )
        inputMode = "no_binds"
    else
        guiSetInputMode ( "allow_binds" )
        inputMode = "allow_binds"
    end
end

function guiGetInputMode()
    return inputMode == "no_binds"
end

local smartOutlineBox = dxCreateShader([[
// rounded_rect_outline.fx

float2 resolution;
float radius;
float smoothness;
float thickness = 2.0;
float4 color = float4(1, 1, 1, 1);

// Lados habilitados (1.0 = visible, 0.0 = oculto)
float showTop = 1.0;
float showBottom = 1.0;
float showLeft = 1.0;
float showRight = 1.0;

float roundedBoxOutline(float2 uv, float2 size, float rad, float smooth, float thick)
{
    float2 halfSize = size * 0.5;
    float2 coord = uv * size;
    float2 dist = abs(coord - halfSize);
    float2 inner = halfSize - rad;

    float d = length(max(dist - inner, 0.0)) - rad;

    float alphaOuter = 1.0 - smoothstep(0.0, smooth, d);
    float alphaInner = 1.0 - smoothstep(-thick, -thick + smooth, d);
    float baseAlpha = saturate(alphaOuter - alphaInner);

    // Filtrado por lados
    float isTop    = step(0.0, (1.0 - uv.y));         // y cercano a 0
    float isBottom = step(0.0, uv.y - 0.99);          // y cercano a 1
    float isLeft   = step(0.0, (1.0 - uv.x));         // x cercano a 0
    float isRight  = step(0.0, uv.x - 0.99);          // x cercano a 1

    float sideMask = 1.0;

    if (baseAlpha > 0.0)
    {
        float2 pixelPos = uv * size;

        // Se anulan zonas si no se deben mostrar
        if (!showTop    && pixelPos.y < thickness)     sideMask = 0.0;
        if (!showBottom && pixelPos.y > size.y - thickness) sideMask = 0.0;
        if (!showLeft   && pixelPos.x < thickness)     sideMask = 0.0;
        if (!showRight  && pixelPos.x > size.x - thickness) sideMask = 0.0;
    }

    return baseAlpha * sideMask;
}

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float alpha = roundedBoxOutline(uv, resolution, radius, smoothness, thickness);
    return float4(color.rgb, color.a * alpha);
}

technique Draw
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
]])

function dxDrawSmartOutlineBox(x, y, w, h, color, radius, smoothness, thickness, visibleSides)
    local radius = radius or 12
    local thickness = thickness or 2
    local color = color or -1
    local smoothness = smoothness or 1.0
    local visibleSides = visibleSides or {top=true, bottom=true, left=true, right=true}

    -- Color RGBA normalizado
    local r, g, b, a = color2rgb(color)

    dxSetShaderValue(smartOutlineBox, "resolution", w, h)
    dxSetShaderValue(smartOutlineBox, "radius", radius)
    dxSetShaderValue(smartOutlineBox, "thickness", thickness)
    dxSetShaderValue(smartOutlineBox, "smoothness", smoothness)
    dxSetShaderValue(smartOutlineBox, "color", {r/255, g/255, b/255, a/255})

    dxSetShaderValue(smartOutlineBox, "showTop", visibleSides.top and 1 or 0)
    dxSetShaderValue(smartOutlineBox, "showBottom", visibleSides.bottom and 1 or 0)
    dxSetShaderValue(smartOutlineBox, "showLeft", visibleSides.left and 1 or 0)
    dxSetShaderValue(smartOutlineBox, "showRight", visibleSides.right and 1 or 0)

    dxDrawImage(x, y, w, h, smartOutlineBox)
end

-- Dibuja un borde redondeado con opción de quitar caras
-- x, y: coordenadas
-- w, h: ancho y alto
-- radius: radio de las esquinas
-- color: color del borde
-- thickness: grosor del borde
-- sides: tabla con flags para mostrar/ocultar caras. Ej: {top=true, bottom=false, left=true, right=false}
function dxDrawRoundedRectOutline(x, y, w, h, radius, color, thickness, sides)
    sides = sides or {top = true, bottom = true, left = true, right = true}

    -- Esquinas
    local segments = 6
    local function drawCorner(cx, cy, startAngle, stopAngle)
        for i = 0, segments - 1 do
            local a1 = math.rad(startAngle + (i / segments) * (stopAngle - startAngle))
            local a2 = math.rad(startAngle + ((i + 1) / segments) * (stopAngle - startAngle))
            local x1 = cx + math.cos(a1) * radius
            local y1 = cy + math.sin(a1) * radius
            local x2 = cx + math.cos(a2) * radius
            local y2 = cy + math.sin(a2) * radius
            dxDrawLine(x1, y1, x2, y2, color, thickness)
        end
    end

    -- Lados rectos
    if sides.top then
        dxDrawLine(x + radius, y, x + w - radius, y, color, thickness)
    end
    if sides.bottom then
        dxDrawLine(x + radius, y + h, x + w - radius, y + h, color, thickness)
    end
    if sides.left then
        dxDrawLine(x, y + radius, x, y + h - radius, color, thickness)
    end
    if sides.right then
        dxDrawLine(x + w, y + radius, x + w, y + h - radius, color, thickness)
    end

    -- Esquinas redondeadas
    if sides.top and sides.left then
        drawCorner(x + radius, y + radius, 180, 270)
    end
    if sides.top and sides.right then
        drawCorner(x + w - radius, y + radius, 270, 360)
    end
    if sides.bottom and sides.right then
        drawCorner(x + w - radius, y + h - radius, 0, 90)
    end
    if sides.bottom and sides.left then
        drawCorner(x + radius, y + h - radius, 90, 180)
    end
end
