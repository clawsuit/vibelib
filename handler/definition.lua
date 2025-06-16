dxLibrary = {}

dxLibrary.name = 'vibelib'
dxLibrary.instances = {}
dxLibrary.order     = {}
dxLibrary.render    = {}
dxLibrary.inside    = {}
dxLibrary.count = 0
dxLibrary.scale = select(2, guiGetScreenSize())

dxLibrary.parentValids = {
    ['uiWindow'] = true,
    ['uiScrollpane'] = true,
    ['uiTabpanel'] = true,
    ['uiTab'] = true,
    ['uiIcon'] = true,
}

dxLibrary.availableSVG = {
    ['uiWindow'] = true,
    ['uiButton'] = true,
    ['uiColorpicker'] = true,
    ['uiCheckbox'] = true,
    ['uiRadioButton'] = true,
    ['uiSlider'] = true,
    ['uiProgress'] = true,
    ['uiTreeview'] = true,
    ['uiScroll'] = true,
    ['uiTabpanel'] = true,
    ['uiEditbox'] = true,
    ['uiMemo'] = true,
}
 

dxLibrary.fonts = {
    font1 = DxFont(":"..dxLibrary.name.."/files/fonts/semibold.ttf", dxLibrary.scale*0.00926, true), -- 10
    font2 = DxFont(":"..dxLibrary.name.."/files/fonts/regular.ttf", dxLibrary.scale*0.00833, false), --9
    font3 = DxFont(":"..dxLibrary.name.."/files/fonts/regular.ttf", dxLibrary.scale*0.00926, false),--10
    font4 = DxFont(":"..dxLibrary.name.."/files/fonts/regular.ttf", dxLibrary.scale*0.015, false),
}




dxLibrary.Theme = {
	selected = 1,

    [1] = {
        uiWindow = {
            background      = tocolor(17, 17, 17, 255),
            backgroundTitle = tocolor(17, 17, 17, 255),
            text      = tocolor(255,255,255),

            font = dxLibrary.fonts.font1,
            fontClose = dxLibrary.fonts.font2,
        },

        uiLabel = {
            text = tocolor(255,255,255),
            font = dxLibrary.fonts.font3
        },

        uiButton = {
            background     = tocolor(13, 180, 13),
            text = -1,
            textFont = dxLibrary.fonts.font3,

            hover = tocolor(33, 119, 255)
        },

        uiEditbox = {
            background = tocolor(40, 40, 40, 255),
            titleFont = dxLibrary.fonts.font3,
            textFont = dxLibrary.fonts.font2,
        },

        uiColorpicker = {
            font = dxLibrary.fonts.font3
        },

        uiCheckbox = {
            font = dxLibrary.fonts.font3,
            background = -1,
            selectedColor = tocolor(13, 180, 13)
        },

        uiRadioButton = {
            background = tocolor(30, 30, 30, 255),
            checked = tocolor(13, 180, 13),
            font = dxLibrary.fonts.font3
        },

        uiProgress = {
            background  = tocolor(25, 25, 25, 255),
            progress = tocolor(13, 180, 13),
            text = -1,
            font = dxLibrary.fonts.font3
        },

        uiCombobox = {
            font = dxLibrary.fonts.font3
        },

        uiTreeview = {
            font = dxLibrary.fonts.font3,
            background  = tocolor(50, 50, 50, 255),
            backgroundHover  = tocolor(40, 40, 40, 255),
            selectedColor  = tocolor(30, 30, 30, 255),
            textColor  = tocolor(255, 255, 255, 255),
        },

        uiSwitch = {
            background = tocolor(30, 30, 30, 255),
            on = tocolor(13, 180, 13),
            off = tocolor(100, 100, 100)
        },

        uiScroll = {
            background  = tocolor(28, 28, 28, 255),
            progress = tocolor(13, 180, 13),
        },

        uiSlider = {
            background  = tocolor(30, 30, 30, 255),
            background2 = tocolor(13, 180, 13),
            circle = tocolor(255,255,255,255)
        },

        uiGridList = {
            font = dxLibrary.fonts.font3,
            fontco = dxLibrary.fonts.font1,
            row = {
                background = tocolor(20, 20, 20, 200),
                text = tocolor(255,255,255,255),
                selected = tocolor(13, 180, 13, 200)
            },
            column = {
                background = tocolor(20, 20, 20, 200),
                text = tocolor(255,255,255,255)
            }
        },

        uiTabpanel = {
            background = tocolor(30, 30, 30, 255),
            text = tocolor(255,255,255,255),
            selected = tocolor(13, 180, 13),
            font = dxLibrary.fonts.font1--dxLibrary.fonts.semibold_2
        },
        uiMemo = {
            background = tocolor(40, 40, 40, 255),
            textColor = -1,
            font = dxLibrary.fonts.font3,
        },
    }
}
