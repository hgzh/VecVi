XIncludeFile "../VecVi.pb"

Global *VecVi
Global.i iCurPage,
         iMaxPage,
         iImage
Global.d dRes

UsePNGImageEncoder()

Runtime Enumeration Window
  #WIN_MAIN
EndEnumeration

Runtime Enumeration Gadget
  #CNV_PREVIEW
EndEnumeration

Runtime Enumeration Toolbar
  #TBA_MAIN
  #TBB_PRINT
  #TBB_ZOOMO
  #TBB_ZOOMI
  #TBB_SINGLE
  #TBB_PAGEP
  #TBB_PAGEN
  #TBB_PDF
  #TBB_SVG
EndEnumeration

Procedure createVecVi()
  Protected.i i,
              j
  Protected.s zText
  
  ; //
  ; create the VecVi object
  ; //
  *VecVi = VecVi::Create(VecVi::#FORMAT_A4, VecVi::#VERTICAL)
    
  ; //
  ; define a page header
  ; //
  VecVi::BeginHeader(*VecVi)
  Vecvi::SetMargin(*VecVi, Vecvi::#BOTTOM, 3, VecVi::#AREA_HEADER, #True)
  VecVi::SetLineStyle(*VecVi, VecVi::#LINESTYLE_DASH | VecVi::#LINESTYLE_SQUAREEND, 5)
  VecVi::TextCell(*VecVi, 100, 5, "VecVi Test", VecVi::#RIGHT, VecVi::#BOTTOM)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  VecVi::TextCell(*VecVi, 0, 5, "Date: " + FormatDate("%yyyy-%mm-%dd", Date()), VecVi::#BOTTOM, VecVi::#BOTTOM, VecVi::#RIGHT, VecVi::#BOTTOM)
  VecVi::SetLineStyle(*VecVi, VecVi::#LINESTYLE_STROKE)
  
  ; //
  ; define a page footer
  ; //
  Vecvi::SetMargin(*VecVi, Vecvi::#TOP, 3, VecVi::#AREA_FOOTER, #True)
  VecVi::BeginFooter(*VecVi)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#CENTER)
  VecVi::Ln(*VecVi, 5)
  Vecvi::TextCell(*VecVi, 0, 5, "Page {Nb} of {NbTotal}", VecVi::#BOTTOM, #False, VecVi::#CENTER)

  ; //
  ; create the first page with the first block
  ; //
  VecVi::BeginSection(*VecVi)
  VecVi::BeginBlock(*VecVi)
    
  VecVi::SetFont(*VecVi, "Arial", 0, 4)
  zText = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore"
  zText + " magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,"
  zText + " no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam"
  zText + " nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo"
  zText + " duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
  VecVi::ParagraphCell(*VecVi, 0, 0, zText, VecVi::#BOTTOM)
  
  VecVi::Ln(*VecVi, 5)
  VecVi::SetLineSize(*VecVi, 0.5)
  VecVi::HorizontalLine(*VecVi, 0)
  VecVi::Ln(*VecVi, 5)
  
  Vecvi::SetFont(*VecVi, "Arial", #PB_Font_Bold, 4)
  VecVi::SetLineSize(*VecVi, 0.2)
  VecVi::SetFillColor(*VecVi, RGBA(200, 200, 200, 255))
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.05, 5, "#", VecVi::#RIGHT, VecVi::#ALL, VecVi::#LEFT, VecVi::#CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Name", VecVi::#RIGHT, VecVi::#ALL, VecVi::#LEFT, VecVi::#CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Address", VecVi::#RIGHT, VecVi::#ALL, VecVi::#LEFT, VecVi::#CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.15, 5, "Telephone", VecVi::#RIGHT, VecVi::#ALL, VecVi::#LEFT, VecVi::#CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.20, 5, "E-Mail", VecVi::#NEWLINE, VecVi::#ALL, VecVi::#LEFT, VecVi::#CENTER, #True)

  Vecvi::SetFont(*VecVi, "Arial", 0, 4)  
  For i = 0 To 10
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.05, 5, Str(i), VecVi::#RIGHT, VecVi::#ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Mr. " + Str(i), VecVi::#RIGHT, VecVi::#ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Torplätzle " + Str(i + Random(9, 1)), VecVi::#RIGHT, VecVi::#ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.15, 5, Str(Random(9, 0)), VecVi::#RIGHT, VecVi::#ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.20, 5, "mail" + Str(i) + "@test.com", VecVi::#NEWLINE, VecVi::#ALL)
  Next i
  
  VecVi::Ln(*VecVi, 5)
  
  For i = 0 To 83
    VecVi::VerticalLine(*VecVi, 50)
    VecVi::Sp(*VecVi, 2)
  Next i
  
  VecVi::Ln(*VecVi, 55)
  
  VecVi::TextCell(*VecVi, 0, 5, "There is a page break in the following table:", VecVi::#NEWLINE)
  
  VecVi::Ln(*VecVi, 5)
  
  For i = 0 To 20
    VecVi::TextCell(*VecVi, 50, 5, Str(i) + " + " + Str(i), VecVi::#RIGHT, VecVi::#TOP | VecVi::#LEFT)
    VecVi::TextCell(*VecVi,  5, 5, " = ", VecVi::#RIGHT, VecVi::#ALL)
    VecVi::TextCell(*VecVi, 50, 5, Str(i + i), VecVi::#NEWLINE, VecVi::#TOP | VecVi::#RIGHT)
  Next i
  
  VecVi::ln(*VecVi)
  
  VecVi::TextCell(*VecVi, 0, 5, "Now there is a manual page break. The new page will not be numbered.")

  ; //
  ; create a new footer for the page without numbering, otherwise the tokens won't be replaced
  ; //
  VecVi::BeginFooter(*VecVi)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#CENTER)
  VecVi::Ln(*VecVi, 5)
  Vecvi::TextCell(*VecVi, 0, 5, "The new footer without page numbers", VecVi::#BOTTOM, #False, VecVi::#CENTER)

  ; //
  ; create a page without numbering
  ; //
  VecVi::BeginSection(*VecVi, VecVi::#FORMAT_INHERIT, VecVi::#INHERIT, -1)
  Vecvi::BeginBlock(*VecVi)
  Vecvi::SetFont(*VecVi, "Arial", 0, 4)  
  VecVi::TextCell(*VecVi, 0, 5, "On this page, there will be no page breaks within a table.", VecVi::#BOTTOM)
  
  For i = 0 To 6
    VecVi::BeginBlock(*VecVi, #False)
    VecVi::SetLineColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    For j = 0 To 6
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " foo " + Str(j), VecVi::#RIGHT, VecVi::#ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " bar " + Str(j), VecVi::#RIGHT, VecVi::#ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " bla " + Str(j), VecVi::#RIGHT, VecVi::#ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " blub " + Str(j), VecVi::#NEWLINE, VecVi::#ALL)
    Next j
    VecVi::Ln(*VecVi, 10)
  Next i
  VecVi::SetLineColor(*VecVi, $FF000000)
  
  ; //
  ; restore the first footer
  ; //
  VecVi::BeginFooter(*VecVi)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#CENTER)
  VecVi::Ln(*VecVi, 5)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  Vecvi::TextCell(*VecVi, 0, 5, "Page {Nb} of {NbTotal}", VecVi::#BOTTOM, #False, VecVi::#CENTER)

  ; //
  ; define the next page
  ; //
  VecVi::BeginSection(*VecVi)
  VecVi::BeginBlock(*VecVi)
  VecVi::SetFont(*VecVi, "Arial", 0, 4)
  VecVi::TextCell(*VecVi, 0, 5, "This page is numbered again.", VecVi::#BOTTOM)
  
  VecVi::ImageCell(*VecVi, 0, 30, 80, 15, LoadImage(#PB_Any, #PB_Compiler_Home + "Examples\Sources\Data\PureBasicLogo.bmp"), VecVi::#NEWLINE, VecVi::#ALL)
  
  VecVi::Ln(*VecVi, 5)
  
  For i = 0 To 7
    VecVi::SetLineColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    VecVi::SetFillColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    VecVi::SetLineSize(*VecVi, Random(3, 1))
    VecVi::Rectangle(*VecVi, VecVi::GetPageWidth(*VecVi, 0) / 8, 15, VecVi::#RIGHT, VecVi::#ALL, #True)
  Next
  
  VecVi::Ln(*VecVi, 20)
  
  VecVi::SetLineSize(*VecVi, 0.5)
  For i = 0 To 5
    VecVi::SetLineColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    VecVi::SetFillColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    VecVi::Sector(*VecVi, 20, 15, Random(120, 0), Random(360, 180), VecVi::#RIGHT, Random(1, 0), Random(1, 0), Random(1, 0))
  Next
  
  VecVi::Ln(*VecVi)
  
  For i = 0 To 60
    If Mod(i, 10) = 0
      VecVi::BeginBlock(*VecVi)
    EndIf
    VecVi::TextCell(*VecVi, 0, 5, "Nr. " + Str(i), VecVi::#NEWLINE)
  Next i
  
EndProcedure

Procedure createVecVi2()
  Protected.i i

  *VecVi = VecVi::Create(VecVi::#FORMAT_A4, VecVi::#VERTICAL)

  ; //
  ; define a page header
  ; //
  VecVi::BeginHeader(*VecVi)
  Vecvi::SetMargin(*VecVi, Vecvi::#BOTTOM, 3, VecVi::#AREA_HEADER, #True)
  VecVi::SetLineStyle(*VecVi, VecVi::#LINESTYLE_DASH | VecVi::#LINESTYLE_SQUAREEND, 5)
  VecVi::TextCell(*VecVi, 100, 5, "VecVi Test", VecVi::#RIGHT, VecVi::#BOTTOM)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  VecVi::TextCell(*VecVi, 0, 5, "Date: " + FormatDate("%yyyy-%mm-%dd", Date()), VecVi::#BOTTOM, VecVi::#BOTTOM, VecVi::#RIGHT, VecVi::#BOTTOM)
  VecVi::SetLineStyle(*VecVi, VecVi::#LINESTYLE_STROKE)

  ; //
  ; define a page footer
  ; //
  VecVi::SetMargin(*VecVi, VecVi::#TOP, 3, VecVi::#AREA_FOOTER, #True)
  VecVi::BeginFooter(*VecVi)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#CENTER)
  VecVi::Ln(*VecVi, 5)
  VecVi::TextCell(*VecVi, 0, 5, "Page {Nb} of {NbTotal}", VecVi::#BOTTOM, #False, VecVi::#CENTER)

  ; //
  ; create the first page with the first block
  ; //
  VecVi::BeginSection(*VecVi)
  VecVi::BeginBlock(*VecVi, #True)
  VecVi::SetFont(*VecVi, "Arial", 0, 5)
  For i = 0 To 800
    If Mod(i, 10) = 0
      VecVi::BeginBlock(*VecVi)
    EndIf
    VecVi::TextCell(*VecVi, 0, 5, "Nr. " + Str(i), VecVi::#NEWLINE)
  Next i

EndProcedure

Procedure move()
  Protected.i iWheelData,
              iEventType,
              iChange
  Protected.d dOffTop,
              dOffLeft,
              dScale
  Static.i siMode,
           siMouseX,
           siMouseY
  
  iEventType = EventType()

  dScale     = VecVi::GetOutputScale(*VecVi, 0)
  dOffTop    = VecVi::GetOutputOffset(*VecVi, VecVi::#TOP)
  dOffLeft   = VecVi::GetOutputOffset(*VecVi, VecVi::#LEFT)
  
  If iEventType = #PB_EventType_MouseWheel
    iChange    = 1
    iWheelData = GetGadgetAttribute(0, #PB_Canvas_WheelDelta)
    dOffTop + (iWheelData * 50) / dRes / dScale
    
  ElseIf iEventType = #PB_EventType_LeftButtonDown
    siMode = 1
    SetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_Cursor, #PB_Cursor_Arrows)
    siMouseX = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseX)
    siMouseY = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseY)
    
  ElseIf iEventType = #PB_EventType_LeftButtonUp
    siMode = 0
    SetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_Cursor, #PB_Cursor_Default)
    
  ElseIf iEventType = #PB_EventType_MouseMove
    If siMode = 1
      iChange = 1
      siMouseX = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseX) - siMouseX
      siMouseY = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseY) - siMouseY
            
      dOffLeft + siMouseX / dRes / dScale
      dOffTop  + siMouseY / dRes / dScale
      
      siMouseX = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseX)
      siMouseY = GetGadgetAttribute(#CNV_PREVIEW, #PB_Canvas_MouseY)    
    EndIf
  EndIf
  
  If iChange = 1
    VecVi::SetOutputOffset(*VecVi, VecVi::#TOP, dOffTop)
    VecVi::SetOutputOffset(*VecVi, VecVi::#LEFT, dOffLeft)
    VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
        
    If GetToolBarButtonState(#TBA_MAIN, #TBB_SINGLE) = 0
      If -dOffTop > -VecVi::GetPageStartOffset(*VecVi, iCurPage + 1) And iCurPage < iMaxPage
        iCurPage + 1
      EndIf
      
      If -dOffTop < -VecVi::GetPageStartOffset(*VecVi, iCurPage - 1) And iCurPage > 1
        iCurPage - 1
      EndIf
    EndIf
    
  EndIf
  
EndProcedure

Procedure zoom()
  Protected.d dScale
  
  dScale = VecVi::GetOutputScale(*VecVi, 0)
  
  If EventMenu() = #TBB_ZOOMI
    dScale + dScale * 0.1
  ElseIf EventMenu() = #TBB_ZOOMO
    dScale - dScale * 0.1
  EndIf
  
  VecVi::SetOutputScale(*VecVi, dScale, dScale)
  VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
  
EndProcedure

Procedure printDocument()
  
  If Not PrintRequester()
    ProcedureReturn 1
  EndIf
  If StartPrinting("Test")
    VecVi::OutputPrinter(*VecVi)
    StopPrinting()
  EndIf
  
EndProcedure

Procedure pdfDocument()
  Protected.s zFile
    
  zFile = OpenFileRequester("PDF-Ausgabe", GetTemporaryDirectory(), "PDF;*.pdf", 0)
  VecVi::OutputPDF(*VecVi, zFile + ".pdf")
  RunProgram(zFile + ".pdf")
  
EndProcedure

Procedure svgDocument()
  Protected.s zFile
    
  zFile = OpenFileRequester("SVG-Ausgabe", GetTemporaryDirectory(), "SVG;*.svg", 0)
  VecVi::OutputSVG(*VecVi, zFile + ".svg", Val(InputRequester("Seite", "", "1")))
  RunProgram(zFile + ".svg")
  
EndProcedure

Procedure switchOutputMode()
  
  If GetToolBarButtonState(#TBA_MAIN, #TBB_SINGLE) = 1
    VecVi::SetMultiPageOutput(*VecVi, 0, 0)
  Else
    VecVi::SetMultiPageOutput(*VecVi, VecVi::#VERTICAL, 10)
    iCurPage = 1
  EndIf
  VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
  
EndProcedure

Procedure simpleRedraw()
  
  VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
  
EndProcedure

Procedure stepPage()
  Protected.i iButton
  Protected.d dOffTop
  
  iButton = EventMenu()
  dOffTop = VecVi::GetOutputOffset(*VecVi, VecVi::#TOP)
  
  If iButton = #TBB_PAGEN
    If iCurPage < iMaxPage
      iCurPage + 1
      If GetToolBarButtonState(#TBA_MAIN, #TBB_SINGLE) = 1
        VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
      Else
        VecVi::SetOutputOffset(*VecVi, VecVi::#TOP, VecVi::GetPageStartOffset(*VecVi, iCurPage))
        VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
      EndIf
    EndIf
  ElseIf iButton = #TBB_PAGEP
    If iCurPage > 1
      iCurPage - 1
      If GetToolBarButtonState(#TBA_MAIN, #TBB_SINGLE) = 1
        VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
      Else
        VecVi::SetOutputOffset(*VecVi, VecVi::#TOP, VecVi::GetPageStartOffset(*VecVi, iCurPage))      
        VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure main()
  Protected.s zXML
  Protected.i i,
              iDialog,
              iEvent
  Protected.d dDpi
  
  zXML = "<window name='WIN_MAIN' id='WIN_MAIN' text='VecVi Preview Window' flags='#PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget'>"
  zXML + "  <gridbox columns='1' rowexpand='item:2'>"
  zXML + "    <empty colspan='2' height='15' />"
  zXML + "    <canvas id='#CNV_PREVIEW' flags='#PB_Canvas_ClipMouse | #PB_Canvas_Keyboard' width='800' height='600' />"
  zXML + "  </gridbox>"
  zXML + "</window>"
  iDialog = CreateDialog(#PB_Any)
  If Not IsDialog(iDialog) : ProcedureReturn : EndIf
  If Not OpenXMLDialog(iDialog, ParseXML(#PB_Any, zXML), "WIN_MAIN") : ProcedureReturn : EndIf
  
  If CreateToolBar(#TBA_MAIN, WindowID(#WIN_MAIN), #PB_ToolBar_Small | #PB_ToolBar_Text | #PB_ToolBar_InlineText)
    ToolBarImageButton(#TBB_PRINT, 0, #PB_ToolBar_Normal, "Print")
    ToolBarSeparator()
    ToolBarImageButton(#TBB_ZOOMI, 0, #PB_ToolBar_Normal, "+")
    ToolBarImageButton(#TBB_ZOOMO, 0, #PB_ToolBar_Normal, "-")
    ToolBarSeparator()
    ToolBarImageButton(#TBB_SINGLE, 0, #PB_ToolBar_Toggle, "Single Page View")
      SetToolBarButtonState(#TBA_MAIN, #TBB_SINGLE, 1)
    ToolBarImageButton(#TBB_PAGEP, 0, #PB_ToolBar_Normal, "Previous Page")
    ToolBarImageButton(#TBB_PAGEN, 0, #PB_ToolBar_Normal, "Next Page")
    ToolBarImageButton(#TBB_PDF, 0, #PB_ToolBar_Normal, "PDF")
    ToolBarImageButton(#TBB_SVG, 0, #PB_ToolBar_Normal, "SVG")
  EndIf
  
  dRes = VecVi::GetCanvasOutputResolution(#CNV_PREVIEW) * 0.05
  
  dDpi = GetDeviceCaps_(GetDC_(0), #LOGPIXELSX)
 
  createVecVi()
  
  VecVi::Process(*VecVi)
  
  BindGadgetEvent(#CNV_PREVIEW, @move(), #PB_EventType_MouseWheel)
  BindGadgetEvent(#CNV_PREVIEW, @move(), #PB_EventType_LeftButtonDown)
  BindGadgetEvent(#CNV_PREVIEW, @move(), #PB_EventType_LeftButtonUp)
  BindGadgetEvent(#CNV_PREVIEW, @move(), #PB_EventType_MouseMove)
  BindGadgetEvent(#CNV_PREVIEW, @zoom(), #PB_EventType_KeyDown)
  
  BindEvent(#PB_Event_Menu, @printDocument(), #WIN_MAIN, #TBB_PRINT)
  BindEvent(#PB_Event_Menu, @zoom(), #WIN_MAIN, #TBB_ZOOMI)
  BindEvent(#PB_Event_Menu, @zoom(), #WIN_MAIN, #TBB_ZOOMO)
  BindEvent(#PB_Event_Menu, @switchOutputMode(), #WIN_MAIN, #TBB_SINGLE)
  BindEvent(#PB_Event_Menu, @stepPage(), #WIN_MAIN, #TBB_PAGEN)
  BindEvent(#PB_Event_Menu, @stepPage(), #WIN_MAIN, #TBB_PAGEP)
  BindEvent(#PB_Event_Menu, @pdfDocument(), #WIN_MAIN, #TBB_PDF)
  BindEvent(#PB_Event_Menu, @svgDocument(), #WIN_MAIN, #TBB_SVG)
  
  BindEvent(#PB_Event_SizeWindow, @simpleRedraw(), #WIN_MAIN)
  
  iCurPage = 1
  iMaxPage = VecVi::GetPageCount(*VecVi)
  VecVi::OutputCanvas(*VecVi, #CNV_PREVIEW, iCurPage)  
  
  Repeat
    iEvent = WaitWindowEvent()
    
  Until iEvent = #PB_Event_CloseWindow
EndProcedure

main()