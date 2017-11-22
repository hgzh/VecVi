XIncludeFile "../VecVi.pb"

Global *VecVi

Procedure createVecVi()
  Protected.i i,
              j
  Protected.s zText
  
  ; //
  ; create the VecVi object
  ; //
  *VecVi = VecVi::Create(VecVi::#FORMAT_A4, VecVi::#ORIENTATION_VERTICAL)
  
  ; //
  ; define a page header
  ; //
  VecVi::BeginHeader(*VecVi)
  Vecvi::SetMargin(*VecVi, Vecvi::#MARGIN_BOTTOM, 3, VecVi::#AREA_HEADER, #True)
  VecVi::TextCell(*VecVi, 0, 5, "VecVi Test", VecVi::#LN_RIGHT, VecVi::#BORDER_BOTTOM)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  VecVi::TextCell(*VecVi, 0, 5, "Date: " + FormatDate("%yyyy-%mm-%dd", Date()), VecVi::#LN_DOWN, VecVi::#BORDER_BOTTOM, VecVi::#ALIGN_RIGHT, VecVi::#ALIGN_BOTTOM)
  
  ; //
  ; define a page footer
  ; //
  Vecvi::SetMargin(*VecVi, Vecvi::#MARGIN_TOP, 3, VecVi::#AREA_FOOTER, #True)
  VecVi::BeginFooter(*VecVi)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#ALIGN_CENTER)
  VecVi::Ln(*VecVi, 5)
  Vecvi::TextCell(*VecVi, 0, 5, "Page {Nb} of {NbTotal}", VecVi::#LN_DOWN, VecVi::#BORDER_NONE, VecVi::#ALIGN_CENTER)

  ; //
  ; create the first page with the first block
  ; //
  VecVi::BeginPage(*VecVi)
  VecVi::BeginBlock(*VecVi)
  VecVi::SetFont(*VecVi, "Arial", 0, 4)
  zText = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore"
  zText + " magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren,"
  zText + " no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam"
  zText + " nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo"
  zText + " duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
  VecVi::ParagraphCell(*VecVi, 0, 0, zText, VecVi::#LN_DOWN)
  
  VecVi::Ln(*VecVi, 5)
  VecVi::SetLineSize(*VecVi, 0.5)
  VecVi::HorizontalLine(*VecVi, 0)
  VecVi::Ln(*VecVi, 5)
  
  Vecvi::SetFont(*VecVi, "Arial", #PB_Font_Bold, 4)
  VecVi::SetLineSize(*VecVi, 0.2)
  VecVi::SetFillColor(*VecVi, RGBA(200, 200, 200, 255))
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.05, 5, "#", VecVi::#LN_RIGHT, VecVi::#BORDER_ALL, VecVi::#ALIGN_LEFT, VecVi::#ALIGN_CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Name", VecVi::#LN_RIGHT, VecVi::#BORDER_ALL, VecVi::#ALIGN_LEFT, VecVi::#ALIGN_CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Address", VecVi::#LN_RIGHT, VecVi::#BORDER_ALL, VecVi::#ALIGN_LEFT, VecVi::#ALIGN_CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.15, 5, "Telephone", VecVi::#LN_RIGHT, VecVi::#BORDER_ALL, VecVi::#ALIGN_LEFT, VecVi::#ALIGN_CENTER, #True)
  VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.20, 5, "E-Mail", VecVi::#LN_NEWLINE, VecVi::#BORDER_ALL, VecVi::#ALIGN_LEFT, VecVi::#ALIGN_CENTER, #True)

  Vecvi::SetFont(*VecVi, "Arial", 0, 4)  
  For i = 0 To 10
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.05, 5, Str(i), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Mr. " + Str(i), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.30, 5, "Torplatz " + Str(i + Random(9, 1)), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.15, 5, Str(Random(9, 0)), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)    
    VecVi::TextCell(*VecVi, VecVi::GetPageWidth(*VecVi) * 0.20, 5, "mail" + Str(i) + "@test.com", VecVi::#LN_NEWLINE, VecVi::#BORDER_ALL)    
  Next i
  
  VecVi::Ln(*VecVi, 5)
  
  For i = 0 To 83
    VecVi::VerticalLine(*VecVi, 50)
    VecVi::Sp(*VecVi, 2)
  Next i
  
  VecVi::Ln(*VecVi, 55)
  
  VecVi::TextCell(*VecVi, 0, 5, "There is a page break in the following table:", VecVi::#LN_NEWLINE)
  
  VecVi::Ln(*VecVi, 5)
  
  For i = 0 To 20
    VecVi::TextCell(*VecVi, 50, 5, Str(i) + " + " + Str(i), VecVi::#LN_RIGHT, VecVi::#BORDER_TOP | VecVi::#BORDER_LEFT)
    VecVi::TextCell(*VecVi,  5, 5, " = ", VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)
    VecVi::TextCell(*VecVi, 50, 5, Str(i + i), VecVi::#LN_NEWLINE, VecVi::#BORDER_TOP | VecVi::#BORDER_RIGHT)
  Next i
  
  VecVi::ln(*VecVi)
  
  VecVi::TextCell(*VecVi, 0, 5, "Now there is a manual page break. The new page will not be numbered.")

  ; //
  ; create a new footer for the page without numbering, otherwise the tokens won't be replaced
  ; //
  VecVi::BeginFooter(*VecVi)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#ALIGN_CENTER)
  VecVi::Ln(*VecVi, 5)
  Vecvi::TextCell(*VecVi, 0, 5, "The new footer without page numbers", VecVi::#LN_DOWN, VecVi::#BORDER_NONE, VecVi::#ALIGN_CENTER)

  ; //
  ; create a page without numbering
  ; //
  VecVi::BeginPage(*VecVi, VecVi::#FORMAT_INHERIT, VecVi::#ORIENTATION_INHERIT, -1)
  Vecvi::BeginBlock(*VecVi)
  Vecvi::SetFont(*VecVi, "Arial", 0, 4)  
  VecVi::TextCell(*VecVi, 0, 5, "On this page, there will be no page breaks within a table.", VecVi::#LN_DOWN)
  
  For i = 0 To 6
    VecVi::BeginBlock(*VecVi, #False)
    VecVi::SetLineColor(*VecVi, RGBA(Random(255), Random(255), Random(255), 255))
    For j = 0 To 6
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " foo " + Str(j), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " bar " + Str(j), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " bla " + Str(j), VecVi::#LN_RIGHT, VecVi::#BORDER_ALL)
      VecVi::TextCell(*VecVi, 20, 5, Str(i) + " blub " + Str(j), VecVi::#LN_NEWLINE, VecVi::#BORDER_ALL)
    Next j
    VecVi::Ln(*VecVi, 10)
  Next i
  VecVi::SetLineColor(*VecVi, $FF000000)

  ; //
  ; restore the first footer
  ; //
  VecVi::BeginFooter(*VecVi)
  VecVi::HorizontalLine(*VecVi, 100, Vecvi::#ALIGN_CENTER)
  VecVi::Ln(*VecVi, 5)
  VecVi::SetFont(*VecVi, "Arial", #PB_Font_Italic, 3)
  Vecvi::TextCell(*VecVi, 0, 5, "Page {Nb} of {NbTotal}", VecVi::#LN_DOWN, VecVi::#BORDER_NONE, VecVi::#ALIGN_CENTER)

  ; //
  ; define the next page
  ; //
  VecVi::BeginPage(*VecVi)
  VecVi::BeginBlock(*VecVi)
  VecVi::SetFont(*VecVi, "Arial", 0, 4)
  VecVi::TextCell(*VecVi, 0, 5, "This page is numbered again.", VecVi::#LN_DOWN)
  
  VecVi::ImageCell(*VecVi, 0, 30, 0, 0, LoadImage(#PB_Any, #PB_Compiler_Home + "Examples\Sources\Data\PureBasicLogo.bmp"))
  
EndProcedure

Procedure main()
  Protected.i i,
              iEvent,
              iMaxPage
              
  OpenWindow(0, 0, 0, 800, 650, "VecVi", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ButtonGadget(1, 5, 5, 100, 25, "Drucken")
  ButtonGadget(2, 110, 5, 50, 25, "<")
  StringGadget(3, 165, 5, 100, 25, "", #PB_String_ReadOnly)
  ButtonGadget(4, 270, 5, 50, 25, ">")
  TextGadget(6, 350, 5, 30, 25, "Zoom:")
  ScrollBarGadget(5, 400,  5, 300, 20, 0, 200, 1)
    SetGadgetState(5, 100)
  
  CanvasGadget(0, 5, 35, 790, 600)
  
  createVecVi()
  
  iMaxPage = VecVi::GetRealPageCount(*VecVi)
  i = 1
  SetGadgetText(3, "Seite " + Str(i) + " von " + Str(iMaxPage))
  VecVi::OutputCanvas(*VecVi, 0, i)
  
  Repeat
    iEvent = WaitWindowEvent()
    
    Select iEvent
      Case #PB_Event_Gadget
        Select EventGadget()
          
          Case 1
            If Not PrintRequester()
              Continue
            EndIf
            If StartPrinting("Test")
              VecVi::OutputPrinter(*VecVi)
              StopPrinting()
            EndIf
            
          Case 2
            If i > 1
              i - 1
              SetGadgetText(3, "Seite " + Str(i) + " von " + Str(iMaxPage))
              VecVi::OutputCanvas(*VecVi, 0, i)
            EndIf
          
          Case 4
            If i < iMaxPage
              i + 1
              SetGadgetText(3, "Seite " + Str(i) + " von " + Str(iMaxPage))
              VecVi::OutputCanvas(*VecVi, 0, i)
            EndIf
            
          Case 5
            VecVi::SetOutputScale(*VecVi, GetGadgetState(5) / 100, GetGadgetState(5) / 100)
            VecVi::OutputCanvas(*VecVi, 0, i)
          
        EndSelect
        
    EndSelect
    
  Until iEvent = #PB_Event_CloseWindow
EndProcedure

main()