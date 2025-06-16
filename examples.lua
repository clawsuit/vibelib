 


--loadstring(exports.vibelib:getLibrary())()
showExample = nil

if showExample then

    dxLibrary.init() -- esta linea es exclusiva de este script, no usar en scripts terceros

    clearChatBox()
    showCursor(true)
    bindKey('m', 'down', 
        function()
            showCursor(not isCursorShowing())   
        end
    )

    setTime(0,0)
    setTimeFrozen ( true )

    local w, h = 75,80
    win = uiWindow({x=50, y=50, w=w, h=h, text='Dashboard2', rounded={4,5,5,5}, close=true})
   -- win:setTextAlign('left')
    win:center()

    local tabPanel = uiTabpanel({
        x = 0, 
        y = 10, 
        w = 100, 
        h = 90,
        style = 3,
        vertical = false,
        parent = win
    })
    local image = svgCreate(64, 70, [[<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill='#fff' d="M575.8 255.5c0 18-15 32.1-32 32.1l-32 0 .7 160.2c0 2.7-.2 5.4-.5 8.1l0 16.2c0 22.1-17.9 40-40 40l-16 0c-1.1 0-2.2 0-3.3-.1c-1.4 .1-2.8 .1-4.2 .1L416 512l-24 0c-22.1 0-40-17.9-40-40l0-24 0-64c0-17.7-14.3-32-32-32l-64 0c-17.7 0-32 14.3-32 32l0 64 0 24c0 22.1-17.9 40-40 40l-24 0-31.9 0c-1.5 0-3-.1-4.5-.2c-1.2 .1-2.4 .2-3.6 .2l-16 0c-22.1 0-40-17.9-40-40l0-112c0-.9 0-1.9 .1-2.8l0-69.7-32 0c-18 0-32-14-32-32.1c0-9 3-17 10-24L266.4 8c7-7 15-8 22-8s15 2 21 7L564.8 231.5c8 7 12 15 11 24z"/></svg>]])

    local tab1 = uiTab('Tab 1', {path=image, alignment='left', x=0, y=0, w=100, h=100}, tabPanel)
    local tab2 = uiTab('Tab 2', {path=image, alignment='center', x=0, y=0, w=100, h=100}, tabPanel)
    local tab3 = uiTab('Tab 3', {path=image, alignment='right', x=0, y=0, w=100, h=100}, tabPanel)

    tabPanel:setSelectedTab(tab1)

    label = uiLabel({x=0, y=0, w=100, h=5, text='Label de pruebas', parent=tab1, alignX='center'})--text, x, y, w, h, parent, color, scale, font, alignX, alignY, postGUI, colorCoded)

   -- -- scrollpane = uiScrollpane({
   -- --      x = 0, 
   -- --      y = 0, 
   -- --      w = 550, 
   -- --      h = 200,
   -- --      parent = tab3
   -- -- })
   -- --  uiButton({text='Boton', x=0, y=0, w=150, h=40, parent=scrollpane})

    uiButton({text='Boton de pruebas', x=2, y=7, w=12, h=6, parent=tab1})
    b1 = uiButton({text='Boton', x=2, y=15, w=12, h=6, parent=tab1, rounded=5})
    b2 = uiButton({text='', x=2, y=23, w=6, h=0, parent=tab1, rounded=30, circle=true})

   -- local texture = DxTexture('files/car.png', "dxt5", false, "wrap")
    b1:addImage(5, 0, 75, 75, image, 'left')
    b2:addImage(0, 0, 75, 75, image, 'center')

    b2.effect = 2
    b2.hoverColor = tocolor(255,0,0)

    local check = uiCheckbox({x=2, y=2, parent=tab1, state=true})
    --  --check:setTextState('X')
    check:setText('Activar shader', 1)
   --  -- check:setStyle(1)
   --  -- check:setTextState('✗')

    local colorpicker = uiColorpicker({x=0, y=7, parent=tab1})
    colorpicker:right(2)

   --  -- local w, h = 800, 100


    progress = uiProgress({x=2, y=35, w=16, parent=tab1, mode=1, rounded=10})
    progress2 = uiProgress({x=2, y=53, w=9.5, h=2, parent=tab1, mode=2, rounded=5})


    local tick = getTickCount(  )
    local tick2 = getTickCount(  )
    local sum = 0
    addEventHandler('onClientRender', root,
        function(b,s)

            local from = interpolateBetween(0, 0, 0, 100, 0, 0, (getTickCount()-tick2)/4000, 'SineCurve')
            progress2:setProgress(from/100)
            progress:setProgress(from/100)

        end
    )

    local radio1 = uiRadioButton({groupKey='grupo1', x=2, y=58, parent=tab1})
    local radio2 = uiRadioButton({groupKey='grupo1', x=2, y=63, parent=tab1})
    local radio3 = uiRadioButton({groupKey='grupo1', x=2, y=68, parent=tab1})

    slider2 = uiSlider({x=2, y=74, w=20, parent=tab1, vertical=true})
    slider1 = uiSlider({x=2, y=70, w=12, parent=tab1})
    slider1:setProgress(0.5)
    slider2:setProgress(0.5)
    slider1:bottom(2)

    switch1 = uiSwitch({x=5, y=58, parent=tab1, mode=1})
    switch2 = uiSwitch({x=5, y=63, parent=tab1, mode=2})
    switch3 = uiSwitch({x=5, y=68, parent=tab1, mode=3})

    local tree = uiTreeview({x=17, y=6, w=17, h=5, parent=tab1})
    local root1 = tree:addRoot('Category 1', true)

    tree:addItem('child 1', root1, false)
    tree:addItem('child 2', root1, false)


    local subChild = tree:addItem('Sub Category', root1, true)
    tree:addItem('child 1', subChild, false)

    local root2 = tree:addRoot('Category 2', true)
    tree:addItem('child 1', root2, false)

    local subChild2 = tree:addItem('Sub Category', root2, true)
    tree:addItem('child 1', subChild2, false)

    local root3 = tree:addRoot('Category 3', true)
    tree:addItem('child 1', root3, false)

    local subChild2 = tree:addItem('Sub Category', root3, true)
    tree:addItem('child 1', subChild2, false)

    scrollV = uiScroll({x=17, y=27, w=24, parent=tab1, vertical=true})
    scrollH = uiScroll({x=17, y=25, w=17, parent=tab1, vertical=false})

    scrollV:setProgress(.5)

    editbox = uiEditbox({x = 21, y = 28,w = 10, h = 4,
     backgroundColor = tocolor(50, 60, 70),
     title = false,
     placeholder = "Ingresa un texto",
     parent = tab1,
    })

   editbox2 = uiEditbox({x = 21, y = 35, w = 10, h = 6,
     --backgroundColor = tocolor(50, 60, 70),
     title = 'Titulo',
     placeholder = "Ingresa un texto",
     parent = tab1,
    })

    gridlist = uiGridList({
        x = 2, 
        y = 5, 
        w = 40, 
        h = 40,
        selectedType = 2,
        parent = tab2,
    })

    b3 = uiButton({text='Cambiar Seleccion', x=2, y=50, w=12, h=6, parent=tab2})
    function b3:onClick(b, s)
        if b == 'left' and s == 'down' then
            gridlist:setSelectedType(3-gridlist.selectedType)
        end
    end

    gridlist.onChange = function(self, row, state)
        local item = gridlist:getSelectedItem(row)
        iprint(item, row, state)
    end

    local co1 = gridlist:addColumn('', 0.075, -1, 'left', {path=image, alignment='left', x=0, y=0, w=60, h=60})
    local co2 = gridlist:addColumn('Jugadores', 0.3, -1, 'left')
    local co3 = gridlist:addColumn('Nivel', 0.2, -1, 'center')--, {path=image, alignment='center', x=-30, y=0, w=15, h=15})
    local co4 = gridlist:addColumn('Dinero', 0.2, -1, 'center')
    local co5 = gridlist:addColumn('Active', 0.1, -1, 'center')


    for i = 1, 50 do
        local row = gridlist:addRow('', '-', 1, 1150, 6, 7, 8, 9, 10)

        gridlist:editRow(row, co1, '', false, 'left', 0, 0, {path=image, alignment='left', x=0, y=0, w=75, h=75})--{path='files/image/circle2.png', alignment='center', x=0, y=0, w=15, h=15})
        gridlist:editRow(row, co2, 'Developer', false, 'left', 0, 0)

        gridlist:editRow(row, co5, '', false, 'left', 0, 0, nil, {state=false})
        gridlist:editRow(row, co3, i, false, 'center', 0, 0)
    end

    local mask = svgCreate(64, 70, [[<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><!--!Font Awesome Free 6.7.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.--><path fill='#fff' d="M135.2 117.4L109.1 192l293.8 0-26.1-74.6C372.3 104.6 360.2 96 346.6 96L165.4 96c-13.6 0-25.7 8.6-30.2 21.4zM39.6 196.8L74.8 96.3C88.3 57.8 124.6 32 165.4 32l181.2 0c40.8 0 77.1 25.8 90.6 64.3l35.2 100.5c23.2 9.6 39.6 32.5 39.6 59.2l0 144 0 48c0 17.7-14.3 32-32 32l-32 0c-17.7 0-32-14.3-32-32l0-48L96 400l0 48c0 17.7-14.3 32-32 32l-32 0c-17.7 0-32-14.3-32-32l0-48L0 256c0-26.7 16.4-49.6 39.6-59.2zM128 288a32 32 0 1 0 -64 0 32 32 0 1 0 64 0zm288 32a32 32 0 1 0 0-64 32 32 0 1 0 0 64z"/></svg>]])

    uiLabel({x=0, y=0, w=100, h=5, text='Dale click al icono', parent=tab1, alignX='center'}):centerY(-8)

    icono = uiIcon({x=0, y=0, w=10, h=10, image=image, parent=tab1})
    icono:center() 

    function icono:onClick(b)
        if b == 'left' then
            if not maskedActive then
                icono:addMask(mask)
                maskedActive = true
            else
                icono:removeMask()
                maskedActive = nil
            end
        end
    end

    memo = uiMemo({x=0, y=2, w=40, h=40, text='Texto nuevo con\nmultilineas', parent=tab2})
    memo:right(5)

    memo:setText([[Teresa tenía seis años y una gran pasión por las estrellas. Cada noche, desde la ventana de su habitación, miraba el cielo y se preguntaba cuántos secretos guardaba el universo. Su abuelo, un explorador espacial desaparecido hace mucho tiempo, le había contado historias sobre viajes a galaxias lejanas.

Un día, mientras visitaba el laboratorio del excéntrico Profesor Neutrón, encontró algo sorprendente: un enorme telescopio cubierto con un manto de polvo estelar.

—¡Cuidado, Teresa! —advirtió el Profesor—. Ese no es un telescopio cualquiera.

—¿Qué tiene de especial? —preguntó Teresa, acercándose con curiosidad.

—Es el Telescopio Temporal. Si miras a través de él, puedes ver el pasado… y el futuro.

Los ojos de Teresa brillaron de emoción. ¿Y si podía ver a su abuelo en una de sus aventuras? Sin dudarlo, giró la rueda de ajuste y miró por la lente. Lo que vio la dejó sin aliento.

Allí estaba su abuelo, flotando en el espacio junto a una extraña nave. Pero antes de que pudiera observar más, una sombra oscura cruzó la visión.

—¡Alguien más está usando el telescopio! —exclamó Quark, el pequeño robot flotante del Profesor Neutrón.

De pronto, una voz grave resonó en el laboratorio.]])
end


