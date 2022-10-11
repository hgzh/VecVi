; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ################  WITH pbPDF INTEGRATION   ################
; ###########################################################

;   written by Andesdaf/hgzh, 2020-2022

;   this module allows you to create documents using the
;   VectorDrawing library of PureBasic and output it to a
;   CanvasGadget, Window, Image object, .svg file (Linux),
;   .pdf file (not Windows) or send it directly to a printer.

; ###########################################################
;                          LICENSING
; Copyright (c) 2020-2022 Andesdaf/hgzh

; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated
; documentation files (the "Software"), to deal in the
; Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute,
; sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so,
; subject to the following conditions:

; The above copyright notice and this permission notice shall
; be included in all copies or substantial portions of the
; Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
; KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
; OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; ###########################################################
;                          CHANGELOG
;
;   v.ppdf.1.00 (2020-07-24)
;    - first version
;   v.ppdf.1.01 (2022-10-11)
;    - aligned with VecVi v.1.11
; ###########################################################

EnableExplicit

XIncludeFile "pbPDFModule.pbi"

DeclareModule VecVi

;- >>> enumerations <<<

Enumeration Orientation
  ; ----------------------------------------
  ; public     :: orientation types
  ; ----------------------------------------
  #INHERIT
  #VERTICAL
  #HORIZONTAL
EndEnumeration

Enumeration Position
  ; ----------------------------------------
  ; public     :: position attributes
  ; ----------------------------------------
  #TOP     =  1
  #RIGHT   =  2
  #BOTTOM  =  4
  #LEFT    =  8
  #CENTER  = 16
  #NEWLINE = 32
  #ALL     = -1
EndEnumeration

Enumeration Area
  ; ----------------------------------------
  ; public     :: area types
  ; ----------------------------------------
  #AREA_HEADER
  #AREA_FOOTER
  #AREA_SECTION
  #AREA_CELL
EndEnumeration

EnumerationBinary LineStyle
  ; ----------------------------------------
  ; public     :: linestyle attributes
  ; ----------------------------------------
  #LINESTYLE_STROKE
  #LINESTYLE_DASH
  #LINESTYLE_DOT
  #LINESTYLE_ROUNDEND
  #LINESTYLE_SQUAREEND
  #LINESTYLE_ROUNDCORNER
  #LINESTYLE_DIAGONALCORNER
EndEnumeration

; ----------------------------------------
; public     :: possible page formats
; ----------------------------------------
#FORMAT_INHERIT = ""
#FORMAT_A0  = "841,1189"
#FORMAT_A1  = "594,841"
#FORMAT_A2  = "420,594"
#FORMAT_A3  = "297,420"
#FORMAT_A4  = "210,297"
#FORMAT_A5  = "148,210"
#FORMAT_A6  = "105,148"
#FORMAT_A7  = "74,105"
#FORMAT_A8  = "52,74"
#FORMAT_A9  = "37,52"
#FORMAT_A10 = "26,37"

;- >>> structures <<<

Structure VECVI_POS
  ; ----------------------------------------
  ; public     :: position attributes
  ; ----------------------------------------
  dX.d
  dY.d
EndStructure

Structure VECVI_MARGIN
  ; ----------------------------------------
  ; public     :: margin attributes
  ; ----------------------------------------
  dTop.d
  dRight.d
  dBottom.d
  dLeft.d
EndStructure

Structure VECVI_SIZE
  ; ----------------------------------------
  ; public     :: size attributes
  ; ----------------------------------------
  dWidth.d
  dHeight.d
EndStructure

Structure VECVI_FONT
  ; ----------------------------------------
  ; public     :: font attributes
  ; ----------------------------------------
  iHandle.i
  zName.s
  iStyle.i
EndStructure

Structure VECVI_IMAGE
  ; ----------------------------------------
  ; public     :: image management
  ; ----------------------------------------
  iHandle.i
EndStructure

Structure VECVI_ELEMENT
  ; ----------------------------------------
  ; public     :: one element in a block
  ; ----------------------------------------
  iID.i
  iType.i
  
  iPageRef.i
  
  BlockPos.VECVI_POS
  PagePos.VECVI_POS
  DrawPos.VECVI_POS
  Size.VECVI_SIZE
  
  AddPos.VECVI_POS
  
  Map i.i()
  Map s.s()
  Map d.d()
EndStructure

Structure VECVI_BLOCK
  ; ----------------------------------------
  ; public     :: one element block
  ; ----------------------------------------
  List Elements.VECVI_ELEMENT()
  
  SectPos.VECVI_POS
  PagePos.VECVI_POS
  DrawPos.VECVI_POS
  Size.VECVI_SIZE
  
  iPageBreak.i
  
  iPageBeginRef.i
  iPageEndRef.i
EndStructure

Structure VECVI_HEADFOOT
  ; ----------------------------------------
  ; public     :: page header/footer structure
  ; ----------------------------------------
  Margin.VECVI_MARGIN
  
  Block.VECVI_BLOCK
EndStructure

Structure VECVI_PAGE
  ; ----------------------------------------
  ; public     :: one real page
  ; ----------------------------------------
  iNr.i
  iNb.i
  
  DrawPos.VECVI_POS
  
  Header.VECVI_HEADFOOT
  Footer.VECVI_HEADFOOT
EndStructure

Structure VECVI_SECTION
  ; ----------------------------------------
  ; public     :: one VecVi section
  ; ----------------------------------------
  List Pages.VECVI_PAGE()
  List Blocks.VECVI_BLOCK()
  
  iNr.i
  iNb.i
  iNbStartValue.i
  
  iNrPages.i
  
  iOrientation.i
  zFormat.s
  
  Size.VECVI_SIZE
  Margin.VECVI_MARGIN
  DrawPos.VECVI_POS
  
  Header.VECVI_HEADFOOT
  Footer.VECVI_HEADFOOT
EndStructure

Structure VECVI
  ; ----------------------------------------
  ; public     :: basic VecVi structure
  ; ----------------------------------------
  List Sections.VECVI_SECTION()
  List Fonts.VECVI_FONT()
  List Images.VECVI_IMAGE()
  
  iNrSections.i
  iNrPages.i
  iOnlyPage.i
  
  iDefTarget.i
  iOutput.i
  iDrawMode.i

  iNbCurrent.i
  iNbTotal.i
  
  Offset.VECVI_MARGIN
  Margin.VECVI_MARGIN
  CellMargin.VECVI_MARGIN
  Size.VECVI_SIZE
  RootPos.VECVI_POS
  CurrPagePos.VECVI_POS
  CurrGlobPos.VECVI_POS
  
  Header.VECVI_HEADFOOT
  Footer.VECVI_HEADFOOT
  
  Map i.i()
  Map s.s()
  Map d.d()
EndStructure

;- >>> public declaration <<<

  Declare.i Create(pzFormat.s, piOrientation.i)
  Declare   Process(*psV.VECVI)
  Declare   Free(*psV.VECVI)
  Declare   BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)
  Declare   BeginBlock(*psV.VECVI, piPageBreak.i = #True)
  Declare   BeginHeader(*psV.VECVI)
  Declare   BeginFooter(*psV.VECVI)
  Declare.i GetFillColor(*psV.VECVI)
  Declare   SetFillColor(*psV.VECVI, piColor.i)
  Declare.i GetTextColor(*psV.VECVI)
  Declare   SetTextColor(*psV.VECVI, piColor.i)
  Declare.i GetBackColor(*psV.VECVI, piDeskColor.i = #False)
  Declare   SetBackColor(*psV.VECVI, piColor.i, piDeskColor.i = #False)
  Declare.i GetLineColor(*psV.VECVI)
  Declare   SetLineColor(*psV.VECVI, piColor.i)
  Declare.d GetLineSize(*psV.VECVI)
  Declare   SetLineSize(*psV.VECVI, pdSize.d)
  Declare.d GetLineStyle(*psV.VECVI, piGetLength.i = #False)
  Declare   SetLineStyle(*psV.VECVI, piStyle.i = -1, pdLength.d = -1)
  Declare.d GetMargin(*psV.VECVI, piMargin.i, piArea.i = #AREA_SECTION, piDefault.i = #False)
  Declare   SetMargin(*psV.VECVI, piMargin.i, pdValue.d, piArea.i = #AREA_SECTION, piDefault.i = #False)
  Declare.d GetXPos(*psV.VECVI)
  Declare   SetXPos(*psV.VECVI, pdX.d, piRelative = #False)
  Declare.d GetYPos(*psV.VECVI)
  Declare   SetYPos(*psV.VECVI, pdY.d, piRelative = #False)
  Declare.d GetPageWidth(*psV.VECVI, piPage.i = 0, piNet = #True)
  Declare.d GetPageHeight(*psV.VECVI, piPage.i = 0, piNet = #True)
  Declare.d GetOutputScale(*psV.VECVI, piAxis.i)
  Declare   SetOutputScale(*psV.VECVI, pdX.d = 1, pdY.d = 1)
  Declare.d GetOutputOffset(*psV.VECVI, piOffset.i)
  Declare   SetOutputOffset(*psV.VECVI, piOffset.i, pdValue.d)
  Declare.i GetMultiPageOutput(*psV.VECVI)
  Declare   SetMultiPageOutput(*psV.VECVI, piOutput.i, pdMargin.d = 0)
  Declare   SetFont(*psV.VECVI, pzName.s, piStyle.i = 0, pdSize.d = 0)
  Declare.d GetFontSize(*psV.VECVI)
  Declare   SetFontSize(*psV.VECVI, pdSize.d)
  Declare.i GetFontStyle(*psV.VECVI)
  Declare.i SetFontStyle(*psV.VECVI, piStyle.i)
  Declare.i GetSectionCount(*psV.VECVI)
  Declare.i GetPageCount(*psV.VECVI, piSection.i = 0)
  Declare.d GetPageStartOffset(*psV.VECVI, piPage.i)
  Declare.d GetOutputSize(*psV.VECVI, piOrientation.i)
  Declare.d GetCanvasOutputResolution(piCanvas.i)
  Declare.d GetTextWidth(*psV.VECVI, pzText.s)
  Declare   SetPageNumberingTokens(*psV.VECVI, pzCurrent.s = "", pzTotal.s = "")
  Declare   TextCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare   ParagraphCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piFill.i = #False)
  Declare   ImageCell(*psV.VECVI, pdW.d, pdH.d, pdImageW.d, pdImageH.d, piImage.i, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare   HorizontalLine(*psV.VECVI, pdW.d, piHAlign.i = #LEFT)
  Declare   VerticalLine(*psV.VECVI, pdH.d, piVAlign.i = #TOP)
  Declare   XYLine(*psV.VECVI, pdDeltaX.d, pdDeltaY.d)
  Declare   Curve(*psV.VECVI, pdS1X.d, pdS1Y.d, pdS2X.d, pdS2Y.d, pdEndX.d, pdEndY.d)
  Declare   Ln(*psV.VECVI, pdLn.d = -1, piForPbPDF.i = 0)
  Declare   Sp(*psV.VECVI, pdSp.d = -1)
  Declare   Rectangle(*psV.VECVI, pdW.d, pdH.d, piLn.i = #RIGHT, piBorder.i = #False, piFill.i = #False)
  Declare   Sector(*psV.VECVI, pdW.d, pdH.d, pdStart.d, pdEnd.d, piLn.i = #RIGHT, piBorder.i = #False, piConnect.i = #True, piFill.i = #False)
  Declare   OutputCanvas(*psV.VECVI, piGadget.i, piPage.i = 1)
  Declare   OutputCanvasImage(*psV.VECVI, piGadget.i, piImage.i, piPage.i = 1)
  Declare   OutputImage(*psV.VECVI, piImage.i, piPage.i = 1)
  Declare   OutputWindow(*psV.VECVI, piWindow.i, piPage.i = 1)
  Declare   OutputPrinter(*psV.VECVI)
  Declare   OutputSVG(*psV.VECVI, pzPath.s)
  Declare   OutputPDF(*psV.VECVI, pzPath.s)
  Declare   OutputPbPDF(*psV.VECVI, pzPath.s)

  UsePNGImageEncoder()

EndDeclareModule

Module VecVi
EnableExplicit

Declare _process(*psV.VECVI)
Declare _processNewPage(*psV.VECVI, pdRestoreX.d = 0)
Declare _processEndPage(*psV.VECVI)
Declare _drawElements(*psV.VECVI, piStartPageRef.i, piE.i = 0)

Enumeration Output
  ; ----------------------------------------
  ; internal   :: possible output types
  ; ----------------------------------------
  #OUTPUT_CANVAS
  #OUTPUT_CANVASIMAGE
  #OUTPUT_IMAGE
  #OUTPUT_WINDOW
  #OUTPUT_PRINTER
  #OUTPUT_SVG
  #OUTPUT_PDF
  #OUTPUT_PBPDF
EndEnumeration

Enumeration ElementType
  ; ----------------------------------------
  ; internal   :: possible element types
  ; ----------------------------------------
  #ELEMENTTYPE_TEXTCELL
  #ELEMENTTYPE_PARACELL
  #ELEMENTTYPE_IMAGECELL
  #ELEMENTTYPE_HLINE
  #ELEMENTTYPE_VLINE
  #ELEMENTTYPE_XYLINE
  #ELEMENTTYPE_LN
  #ELEMENTTYPE_SP
  #ELEMENTTYPE_X
  #ELEMENTTYPE_Y
  #ELEMENTTYPE_RECTANGLE
  #ELEMENTTYPE_SECTOR
  #ELEMENTTYPE_CURVE
EndEnumeration

Enumeration DrawingMode
  ; ----------------------------------------
  ; internal   :: possible drawing modes
  ; ----------------------------------------
  #DRAW_PAGED
  #DRAW_SINGLE
  #DRAW_MULTIH
  #DRAW_MULTIV
EndEnumeration

;- >>> internal functions <<<

Procedure.i _defTarget(*psV.VECVI, piTarget.i = -1)
; ----------------------------------------
; internal   :: returns a pointer to the current definition block.
; param      :: *psV     - VecVi structure
;               piTarget - (S: -1) which target to use
;                          if -1, target specified in *psV\iDefTarget will be used
;                          if other, set the current target and *psV\iDefTarget to piTarget:
;                            0 : normal page block
;                            1 : default header block
;                            2 : default footer block
;                            11: header block of the current page
;                            21: footer block of the current page
; returns    :: (i) pointer to the current definition block
; remarks    :: this is used to distinguish between header, footer, and page blocks
;               in the definition procedures. *psV\iDefTarget is set by the VecVi::Begin* procedures.
; ----------------------------------------
  
  If piTarget > -1
    *psV\iDefTarget = piTarget
  EndIf
  
  If *psV\iDefTarget = 0
    ; //
    ; normal page block
    ; //
    ProcedureReturn @*psV\Sections()\Blocks()
  ElseIf *psV\iDefTarget = 1
    ; //
    ; standard header block
    ; //
    ProcedureReturn @*psV\Header\Block
  ElseIf *psV\iDefTarget = 2
    ; //
    ; standard footer block
    ; //
    ProcedureReturn @*psV\Footer\Block
  ElseIf *psV\iDefTarget = 11
    ; //
    ; page header block
    ; //
    ProcedureReturn @*psV\Sections()\Pages()\Header\Block
  ElseIf *psV\iDefTarget = 21
    ; //
    ; page footer block
    ; //
    ProcedureReturn @*psV\Sections()\Pages()\Footer\Block
  EndIf
  
  ProcedureReturn 0
  
EndProcedure

Procedure.d _calcBlockWidth(*psB.VECVI_BLOCK, piPurge.i = 0)
; ----------------------------------------
; internal   :: calculates the width of a single block.
; param      :: *psB    - VecVi block
;               piPurge - (S: 0) wheter to force-update the saved block width
;                         0: only return, no update
;                         1: update and return new calculated value
; returns    :: (d) block width
; remarks    :: 
; ----------------------------------------
  Protected.d dWidth
; ----------------------------------------
    
  If *psB\Size\dWidth = 0 Or piPurge = 1
    PushListPosition(*psB\Elements())
    ForEach *psB\Elements()
      With *psB\Elements()
        
        ; //
        ; get the element with the highest sum of x block coordinate and width.
        ; this sum will be the x space needed to display the full block.
        ; //
        dWidth = \BlockPos\dY + \Size\dWidth
        If dWidth > *psB\Size\dWidth
          *psB\Size\dWidth = dWidth
        EndIf
      EndWith
    Next
    PopListPosition(*psB\Elements())
  EndIf
  
  ProcedureReturn *psB\Size\dWidth

EndProcedure

Procedure.d _calcBlockHeight(*psB.VECVI_BLOCK, piPurge.i = 0)
; ----------------------------------------
; internal   :: calculates the height of a single block.
; param      :: *psB    - VecVi block
;               piPurge - (S: 0) wheter to force-update the saved block height
;                         0: only return, no update
;                         1: update and return new calculated value
; returns    :: (d) block height
; remarks    :: 
; ----------------------------------------
  Protected.d dHeight
; ----------------------------------------
    
  If *psB\Size\dHeight = 0 Or piPurge = 1
    PushListPosition(*psB\Elements())
    ForEach *psB\Elements()
      With *psB\Elements()
        
        ; //
        ; get the element with the highest sum of y block coordinate and height.
        ; this sum will be the y space needed to display the full block.
        ; //
        dHeight = \BlockPos\dY + \Size\dHeight
        If dHeight > *psB\Size\dHeight
          *psB\Size\dHeight = dHeight
        EndIf
      EndWith
    Next
    PopListPosition(*psB\Elements())
  EndIf
  
  ProcedureReturn *psB\Size\dHeight

EndProcedure

Procedure.d _calcPageWidth(*psV.VECVI, piMargins.i = #LEFT | #RIGHT, piGetMargins.i = 0)
; ----------------------------------------
; internal   :: calculates widths of the current page.
; param      :: *psV         - VecVi structure
;               piMargins    - which margins to include in the calculation (combineable)
;                              #LEFT:  subtract the left page margin
;                              #RIGHT: subtract the right page margin
;               piGetMargins - (S: 0) return only the left/right margins, not the page width
;                              0: the page width will be returned
;                              1: the margins will be returned
; returns    :: (d) calculated page width
; remarks    :: 
; ----------------------------------------
  Protected.d dWidth
; ----------------------------------------
  
  If piGetMargins = 0
    ; //
    ; get page width
    ; //
    If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
      dWidth = *psV\Sections()\Size\dWidth
    Else
      dWidth = *psV\Size\dWidth
    EndIf
    
    ; //
    ; left margin
    ; //
    If piMargins & #LEFT
      If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
        dWidth - *psV\Sections()\Margin\dLeft
      Else
        dWidth - *psV\Margin\dLeft
      EndIf
      
      If *psV\iDefTarget = 1
        dWidth - *psV\Header\Margin\dLeft
      ElseIf *psV\iDefTarget = 2
        dWidth - *psV\Footer\Margin\dLeft
      ElseIf *psV\iDefTarget = 11
        dWidth - *psV\Sections()\Pages()\Header\Margin\dLeft
      ElseIf *psV\iDefTarget = 21
        dWidth - *psV\Sections()\Pages()\Footer\Margin\dLeft
      EndIf
    EndIf
    
    ; //
    ; right margin
    ; //
    If piMargins & #RIGHT
      If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
        dWidth - *psV\Sections()\Margin\dRight
      Else
        dWidth - *psV\Margin\dRight
      EndIf
      
      If *psV\iDefTarget = 1
        dWidth - *psV\Header\Margin\dRight
      ElseIf *psV\iDefTarget = 2
        dWidth - *psV\Footer\Margin\dRight
      ElseIf *psV\iDefTarget = 11
        dWidth - *psV\Sections()\Pages()\Header\Margin\dRight
      ElseIf *psV\iDefTarget = 21
        dWidth - *psV\Sections()\Pages()\Footer\Margin\dRight
      EndIf
    EndIf
  ElseIf piGetMargins = 1
    ; //
    ; get left/right margins
    ; //
    dWidth = 0
    
    ; //
    ; left margin
    ; //
    If piMargins & #LEFT
      If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
        dWidth + *psV\Sections()\Margin\dLeft
      Else
        dWidth + *psV\Margin\dLeft
      EndIf
      
      If *psV\iDefTarget = 1
        dWidth + *psV\Header\Margin\dLeft
      ElseIf *psV\iDefTarget = 2
        dWidth + *psV\Footer\Margin\dLeft
      ElseIf *psV\iDefTarget = 11
        dWidth + *psV\Sections()\Pages()\Header\Margin\dLeft
      ElseIf *psV\iDefTarget = 21
        dWidth + *psV\Sections()\Pages()\Footer\Margin\dLeft
      EndIf
    EndIf
    
    ; //
    ; right margin
    ; //
    If piMargins & #RIGHT
      If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
        dWidth + *psV\Sections()\Margin\dRight
      Else
        dWidth + *psV\Margin\dRight
      EndIf

      If *psV\iDefTarget = 1
        dWidth + *psV\Header\Margin\dRight
      ElseIf *psV\iDefTarget = 2
        dWidth + *psV\Footer\Margin\dRight
      ElseIf *psV\iDefTarget = 11
        dWidth + *psV\Sections()\Pages()\Header\Margin\dRight
      ElseIf *psV\iDefTarget = 21
        dWidth + *psV\Sections()\Pages()\Footer\Margin\dRight
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn dWidth

EndProcedure

Procedure.d _calcPageHeight(*psV.VECVI, piMargins = #TOP | #BOTTOM, piGetMargins.i = 0)
; ----------------------------------------
; internal   :: calculates heights of the current page.
; param      :: *psV         - VecVi structure
;               piMargins    - which margins to include in the calculation (combineable)
;                              #TOP:    subtract the top page margin and header widths/margins
;                              #BOTTOM: subtract the bottom page margin and footer widths/margins
;               piGetMargins - (S: 0) return only the top/bottom margins, not the page height
;                              0: the page height will be returned
;                              1: the margins will be returned
; returns    :: (d) calculated value as specified
; remarks    :: 
; ----------------------------------------
  Protected.d dHeight
; ----------------------------------------
  
  If piGetMargins = 0
    ; //
    ; get page height
    ; //
    If (*psV\iDefTarget = 0 Or *psV\iDefTarget = 11 Or *psV\iDefTarget = 21) And ListIndex(*psV\Sections()) > -1
      dHeight = *psV\Sections()\Size\dHeight
    Else
      dHeight = *psV\Size\dHeight
    EndIf
    
    ; //
    ; top margin
    ; //
    If piMargins & #TOP
      If *psV\iDefTarget = 0
        dHeight - *psV\Sections()\Header\Margin\dBottom
        dHeight - *psV\Sections()\Header\Block\Size\dHeight
        dHeight - *psV\Sections()\Header\Margin\dTop
        dHeight - *psV\Sections()\Margin\dTop
      ElseIf *psV\iDefTarget = 1 Or *psV\iDefTarget = 2
        dHeight - *psV\Header\Margin\dBottom
        dHeight - *psV\Header\Block\Size\dHeight
        dHeight - *psV\Header\Margin\dTop
        dHeight - *psV\Margin\dTop
      ElseIf *psV\iDefTarget = 11 Or *psV\iDefTarget = 21
        dHeight - *psV\Sections()\Pages()\Header\Margin\dBottom
        dHeight - *psV\Sections()\Pages()\Header\Block\Size\dHeight
        dHeight - *psV\Sections()\Pages()\Header\Margin\dTop
        dHeight - *psV\Sections()\Margin\dTop
      EndIf
    EndIf
    
    ; //
    ; bottom margin
    ; //
    If piMargins & #BOTTOM
      If *psV\iDefTarget = 0
        dHeight - *psV\Sections()\Footer\Margin\dBottom
        dHeight - *psV\Sections()\Footer\Block\Size\dHeight
        dHeight - *psV\Sections()\Footer\Margin\dTop
        dHeight - *psV\Sections()\Margin\dBottom
      ElseIf *psV\iDefTarget = 1 Or *psV\iDefTarget = 2
        dHeight - *psV\Footer\Margin\dBottom
        dHeight - *psV\Footer\Block\Size\dHeight
        dHeight - *psV\Footer\Margin\dTop
        dHeight - *psV\Margin\dBottom
      ElseIf *psV\iDefTarget = 11 Or *psV\iDefTarget = 21
        dHeight - *psV\Sections()\Pages()\Footer\Margin\dBottom
        dHeight - *psV\Sections()\Pages()\Footer\Block\Size\dHeight
        dHeight - *psV\Sections()\Pages()\Footer\Margin\dTop
        dHeight - *psV\Sections()\Margin\dBottom
      EndIf
    EndIf
  ElseIf piGetMargins = 1
    ; //
    ; get top/bottom margin
    ; //
    dHeight = 0
    
    ; //
    ; top margin
    ; //
    If piMargins & #TOP
      If *psV\iDefTarget = 0
        dHeight + *psV\Sections()\Header\Margin\dBottom
        dHeight + *psV\Sections()\Header\Block\Size\dHeight
        dHeight + *psV\Sections()\Header\Margin\dTop
        dHeight + *psV\Sections()\Margin\dTop
      ElseIf *psV\iDefTarget = 1 Or *psV\iDefTarget = 2
        dHeight + *psV\Header\Margin\dBottom
        dHeight + *psV\Header\Block\Size\dHeight
        dHeight + *psV\Header\Margin\dTop
        dHeight + *psV\Margin\dTop
      ElseIf *psV\iDefTarget = 11 Or *psV\iDefTarget = 21
        dHeight + *psV\Sections()\Pages()\Header\Margin\dBottom
        dHeight + *psV\Sections()\Pages()\Header\Block\Size\dHeight
        dHeight + *psV\Sections()\Pages()\Header\Margin\dTop
        dHeight + *psV\Sections()\Margin\dTop
      EndIf
    EndIf
    
    ; //
    ; bottom margin
    ; //
    If piMargins & #BOTTOM
      If *psV\iDefTarget = 0
        dHeight + *psV\Sections()\Footer\Margin\dBottom
        dHeight + *psV\Sections()\Footer\Block\Size\dHeight
        dHeight + *psV\Sections()\Footer\Margin\dTop
        dHeight + *psV\Sections()\Margin\dBottom
      ElseIf *psV\iDefTarget = 1 Or *psV\iDefTarget = 2
        dHeight + *psV\Footer\Margin\dBottom
        dHeight + *psV\Footer\Block\Size\dHeight
        dHeight + *psV\Footer\Margin\dTop
        dHeight + *psV\Margin\dBottom
      ElseIf *psV\iDefTarget = 11 Or *psV\iDefTarget = 21
        dHeight + *psV\Sections()\Pages()\Footer\Margin\dBottom
        dHeight + *psV\Sections()\Pages()\Footer\Block\Size\dHeight
        dHeight + *psV\Sections()\Pages()\Footer\Margin\dTop
        dHeight + *psV\Sections()\Margin\dBottom
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn dHeight

EndProcedure

Procedure _getFirstElementByOffset(*psV.VECVI, *piS.Integer, *piB.Integer, *piE.Integer)
; ----------------------------------------
; internal   :: get the first element displayed in the current output offset
; param      :: *psV - VecVi structure
;               *piS - byref returning the section pointer
;               *piB - byref returning the block pointer in the section
;               *piE - byref returning the element pointer in the block
; returns    :: (i) 0: no element found
;                   1: element found
; remarks    :: 
; ----------------------------------------
  Protected.i iFound
; ----------------------------------------

  ; //
  ; initialization
  ; //  
  iFound = 0
  
  ; //
  ; iterate through all elements in all sections and blocks and try to find
  ; the first one matching the current output offset
  ; //
  PushListPosition(*psV\Sections())
  ForEach *psV\Sections()
    PushListPosition(*psV\Sections()\Blocks())
    PushListPosition(*psV\Sections()\Pages())
    ForEach *psV\Sections()\Blocks()
      PushListPosition(*psV\Sections()\Blocks()\Elements())
      ForEach *psV\Sections()\Blocks()\Elements()
        ChangeCurrentElement(*psV\Sections()\Pages(), *psV\Sections()\Blocks()\Elements()\iPageRef)
        
        If *psV\iDrawMode = #DRAW_SINGLE
          ; //
          ; single drawing mode, look for y page position
          ; //
          If *psV\RootPos\dY + *psV\Sections()\Blocks()\Elements()\PagePos\dY + 10 > 0
            *piS\i = @*psV\Sections()
            *piB\i = @*psV\Sections()\Blocks()
            *piE\i = @*psV\Sections()\Blocks()\Elements()
            
            PopListPosition(*psV\Sections()\Blocks()\Elements())
            PopListPosition(*psV\Sections()\Blocks())
            PopListPosition(*psV\Sections()\Pages())
            PopListPosition(*psV\Sections())
            
            iFound = 1
            Break 3
          EndIf
          
        ElseIf *psV\iDrawMode = #DRAW_MULTIH
          ; //
          ; horizontal multi drawing mode, look for x drawing position of element or space
          ; to display the page bounds
          ; //
          If *psV\RootPos\dX + *psV\Sections()\Blocks()\Elements()\DrawPos\dX + 10 > 0 Or *psV\RootPos\dX + *psV\Sections()\Pages()\DrawPos\dX + *psV\Sections()\Size\dWidth > 0
            *piS\i = @*psV\Sections()
            *piB\i = @*psV\Sections()\Blocks()
            *piE\i = @*psV\Sections()\Blocks()\Elements()

            PopListPosition(*psV\Sections()\Blocks()\Elements())
            PopListPosition(*psV\Sections()\Blocks())
            PopListPosition(*psV\Sections()\Pages())
            PopListPosition(*psV\Sections())

            iFound = 1
            Break 3
          EndIf
          
        ElseIf *psV\iDrawMode = #DRAW_MULTIV
          ; //
          ; vertical multi drawing mode, look for y drawing position of element or space
          ; to display the page bounds
          ; //
          If *psV\RootPos\dY + *psV\Sections()\Blocks()\Elements()\DrawPos\dY + 10 > 0 Or *psV\RootPos\dY + *psV\Sections()\Pages()\DrawPos\dY + *psV\Sections()\Size\dHeight > 0
            *piS\i = @*psV\Sections()
            *piB\i = @*psV\Sections()\Blocks()
            *piE\i = @*psV\Sections()\Blocks()\Elements()

            PopListPosition(*psV\Sections()\Blocks()\Elements())
            PopListPosition(*psV\Sections()\Blocks())
            PopListPosition(*psV\Sections()\Pages())
            PopListPosition(*psV\Sections())

            iFound = 1
            Break 3
          EndIf
        EndIf
        
      Next
      PopListPosition(*psV\Sections()\Blocks()\Elements())
    Next
    PopListPosition(*psV\Sections()\Blocks())
    PopListPosition(*psV\Sections()\Pages())
  Next
  
  ; //
  ; restore the current list position
  ; //
  If iFound = 0
    PopListPosition(*psV\Sections())
  EndIf
  
  ProcedureReturn iFound

EndProcedure

Procedure _getFirstElementByPage(*psV.VECVI, piPage.i, *piS.Integer, *piB.Integer, *piE.Integer)
; ----------------------------------------
; internal   :: get the first element on the given page
; param      :: *psV   - VecVi structure
;               piPage - reference to the page to investigate
;               *piS   - byref returning the section pointer
;               *piB   - byref returning the block pointer in the section
;               *piE   - byref returning the element pointer in the block
; returns    :: (i) 0: no element found
;                   1: element found
; remarks    :: 
; ----------------------------------------
  Protected.i iFound
; ----------------------------------------

  ; //
  ; initialization
  ; //  
  iFound = 0

  ; //
  ; iterate through all elements in all sections and blocks and stop at
  ; the element which is the first one on the given page
  ; //
  PushListPosition(*psV\Sections())
  ForEach *psV\Sections()
    PushListPosition(*psV\Sections()\Blocks())
    ForEach *psV\Sections()\Blocks()
      PushListPosition(*psV\Sections()\Blocks()\Elements())
      ForEach *psV\Sections()\Blocks()\Elements()
        
        If *psV\Sections()\Blocks()\Elements()\iPageRef = piPage
          ; //
          ; found the matching element
          ; //
          *piS\i = @*psV\Sections()
          *piB\i = @*psV\Sections()\Blocks()
          *piE\i = @*psV\Sections()\Blocks()\Elements()

          PopListPosition(*psV\Sections()\Blocks()\Elements())
          PopListPosition(*psV\Sections()\Blocks())
          PopListPosition(*psV\Sections())

          iFound = 1
          Break 3
        EndIf
        
      Next
      PopListPosition(*psV\Sections()\Blocks()\Elements())
    Next
    PopListPosition(*psV\Sections()\Blocks())
  Next
  
  ; //
  ; restore the current list position
  ; //
  If iFound = 0
    PopListPosition(*psV\Sections())
  EndIf
  
  ProcedureReturn iFound
  
EndProcedure

Procedure.d _getElementPosition(*psV.VECVI, *psB.VECVI_BLOCK, piXY.i)
; ----------------------------------------
; internal   :: gets the drawing position of the element dependent on the drawing mode
; param      :: *psV - VecVi structure
;               *psB - current VecVi block
;               piXY - wheter to return the x or y position
;                      0: return x position
;                      1: return y position
; returns    :: (d) x or y position of the given element
; remarks    :: 
; ----------------------------------------
  Protected.d dPos
; ----------------------------------------
  
  If *psV\iDrawMode = #DRAW_SINGLE Or *psV\iDrawMode = #DRAW_PAGED
    If piXY = 0
      dPos = *psV\RootPos\dX + *psB\Elements()\PagePos\dX
    Else
      dPos = *psV\RootPos\dY + *psB\Elements()\PagePos\dY
    EndIf
  Else
    If piXY = 0
      dPos = *psV\RootPos\dX + *psB\Elements()\DrawPos\dX
    Else
      dPos = *psV\RootPos\dY + *psB\Elements()\DrawPos\dY
    EndIf
  EndIf
    
  ProcedureReturn dPos

EndProcedure

Procedure _applyPosition(*psV.VECVI, *psT.VECVI_BLOCK, *psE.VECVI_ELEMENT)
; ----------------------------------------
; internal   :: applies positions to elements and position changes to the corresponding entities.
; param      :: *psV - VecVi structure
;               *psT - current block pointer
;               *psE - current element pointer
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  With *psE
    
    ; //
    ; set position of element in global output
    ; //
    \DrawPos = *psV\CurrGlobPos

    ; //
    ; set position of element inside the current page
    ; this is section y pos at first because the line breaks are
    ; not known already. used for user navigation with SetXPos/SetYPos
    ; //
    \PagePos = *psV\CurrPagePos
    
    ; //
    ; set position of element inside the current block
    ; //
    *psE\BlockPos\dX = *psE\DrawPos\dX - *psT\DrawPos\dX
    *psE\BlockPos\dY = *psE\DrawPos\dY - *psT\DrawPos\dY
    
    Select \iType
      Case #ELEMENTTYPE_TEXTCELL,
           #ELEMENTTYPE_PARACELL,
           #ELEMENTTYPE_IMAGECELL,
           #ELEMENTTYPE_RECTANGLE
           
        \Size\dHeight = \d("H")
        
        ; //
        ; if given width is 0, expand the element to the right side of the page
        ; //
        If \d("W") = 0
          \d("W") = _calcPageWidth(*psV, #RIGHT) - \PagePos\dX
        EndIf
        \Size\dWidth = \d("W")
        
        ; //
        ; handle newline behaviour
        ; //
        If \i("Ln") = #RIGHT
          \AddPos\dX  = \Size\dWidth
          \AddPos\dY  = 0
        ElseIf \i("Ln") = #BOTTOM
          \AddPos\dX = 0
          \AddPos\dY = \Size\dHeight
        ElseIf \i("Ln") = #NEWLINE
          If *psV\iDefTarget = 0
            \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft
          ElseIf *psV\iDefTarget = 1
            \AddPos\dX = - \PagePos\dX + *psV\Margin\dLeft + *psV\Header\Margin\dLeft
          ElseIf *psV\iDefTarget = 2
            \AddPos\dX = - \PagePos\dX + *psV\Margin\dLeft + *psV\Footer\Margin\dLeft
          ElseIf *psV\iDefTarget = 11
            \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Header\Margin\dLeft
          ElseIf *psV\iDefTarget = 21
            \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Footer\Margin\dLeft
          EndIf
          \AddPos\dY = \Size\dHeight
        EndIf
        
        ; //
        ; set last linebreak height
        ; //
        *psV\d("LastLn") = \Size\dHeight
        
      Case #ELEMENTTYPE_HLINE
        \Size\dWidth  = \d("W")
        \Size\dHeight = \d("LineSize")
        
        \AddPos\dX = 0
        \AddPos\dY = \Size\dHeight
        
      Case #ELEMENTTYPE_VLINE
        \Size\dWidth  = \d("LineSize")
        \Size\dHeight = \d("H")
          
        \AddPos\dX = \Size\dWidth
        \AddPos\dY = 0
        
      Case #ELEMENTTYPE_XYLINE
        \Size\dWidth  = \d("dX")
        \Size\dHeight = \d("dY")
        
        \AddPos\dX = \Size\dWidth
        \AddPos\dY = \Size\dHeight
      
      Case #ELEMENTTYPE_CURVE
        \Size\dWidth  = \d("EndX") - \PagePos\dX
        \Size\dHeight = \d("EndY") - \PagePos\dY
        
        \AddPos\dX = \d("EndX")
        \AddPos\dY = \d("EndY")
      
      Case #ELEMENTTYPE_LN
        ; //
        ; if -1, use last linebreak size
        ; //
        If \d("Ln") > -1
          \Size\dHeight    = \d("Ln")
          *psV\d("LastLn") = \d("Ln")
        Else
          \Size\dHeight    = *psV\d("LastLn")
        EndIf
        
        If \i("PPDF") = 1
          ProcedureReturn
        EndIf
        
        If *psV\iDefTarget = 0
          \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft
        ElseIf *psV\iDefTarget = 1
          \AddPos\dX = - \PagePos\dX + *psV\Margin\dLeft + *psV\Header\Margin\dLeft
        ElseIf *psV\iDefTarget = 2
          \AddPos\dX = - \PagePos\dX + *psV\Margin\dLeft + *psV\Footer\Margin\dLeft
        ElseIf *psV\iDefTarget = 11
          \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Header\Margin\dLeft
        ElseIf *psV\iDefTarget = 21
          \AddPos\dX = - \PagePos\dX + *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Footer\Margin\dLeft
        EndIf
        \AddPos\dY = \Size\dHeight
  
      Case #ELEMENTTYPE_SP
        ; //
        ; if -1, use last space size
        ; //
        If \d("Sp") > -1
          *psV\d("LastSp") = \d("Sp")
          \Size\dWidth     = \d("Sp")
        Else
          \Size\dWidth     = *psV\d("LastSp")
        EndIf
        
        \AddPos\dX = \Size\dWidth
        \AddPos\dY = 0
        
      Case #ELEMENTTYPE_SECTOR
        \Size\dHeight = \d("H")
        \Size\dWidth  = \d("W")

        If \i("Ln") = #RIGHT
          \AddPos\dX = \Size\dWidth
          \AddPos\dY = 0
        Else
          \AddPos\dX = 0
          \AddPos\dY = \Size\dHeight
        EndIf

        *psV\d("LastLn") = \Size\dHeight
  
      Case #ELEMENTTYPE_X
        \Size\dWidth  = 0
        \Size\dHeight = 0
        
        ; //
        ; relative move from current position possible
        ; //
        If \i("Rel") = #False
          \AddPos\dX = \d("X") - \PagePos\dX
          \AddPos\dY = 0
        ElseIf \i("Rel") = #True
          \AddPos\dX = \d("X")
          \AddPos\dY = 0
        EndIf
        
      Case #ELEMENTTYPE_Y
        \Size\dWidth  = 0
        \Size\dHeight = 0
        
        ; //
        ; relative move from current position possible
        ; //
        If \i("Rel") = #False
          \AddPos\dX = 0
          \AddPos\dY = \d("Y") - \PagePos\dY
        ElseIf \i("Rel") = #True
          \AddPos\dX = 0
          \AddPos\dY = \d("Y")
        EndIf
      
    EndSelect
  EndWith
  
  ; //
  ; apply new positions for next element
  ; //
  *psV\CurrGlobPos\dX + *psE\AddPos\dX
  *psV\CurrGlobPos\dY + *psE\AddPos\dY
  
  *psV\CurrPagePos\dX + *psE\AddPos\dX
  *psV\CurrPagePos\dY + *psE\AddPos\dY
  
EndProcedure

Procedure _applyLineStyle(*psE.VECVI_ELEMENT)
; ----------------------------------------
; internal   :: applies the current line style to the given element
; param      :: *psE - current VecVi element
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iFlags
; ----------------------------------------

  With *psE
    ; //
    ; get the line drawing parameters
    ; //
    If \i("LineStyle") & #LINESTYLE_DIAGONALCORNER
      iFlags = #PB_Path_DiagonalCorner
    ElseIf \i("LineStyle") & #LINESTYLE_ROUNDCORNER
      iFlags = #PB_Path_RoundCorner
    ElseIf \i("LineStyle") & #LINESTYLE_ROUNDEND
      iFlags = #PB_Path_RoundEnd
    ElseIf \i("LineStyle") & #LINESTYLE_SQUAREEND
      iFlags = #PB_Path_SquareEnd
    EndIf
    
    ; //
    ; draw the line
    ; //
    If \i("LineStyle") & #LINESTYLE_STROKE
      StrokePath(\d("LineSize"), iFlags)
    ElseIf \i("LineStyle") & #LINESTYLE_DASH
      DashPath(\d("LineSize"), \d("LineLen"), iFlags)
    ElseIf \i("LineStyle") & #LINESTYLE_DOT
      DotPath(\d("LineSize"), \d("LineLen"), iFlags)
    EndIf
    
  EndWith

EndProcedure

Procedure _drawTextCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a text cell (#ELEMENTTYPE_TEXTCELL).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dFillX,
              dFillY,
              dFillW,
              dFillH,
              dTextX,
              dTextY
; ----------------------------------------
  
  With *psT\Elements()
    
    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    dFillX = dPosX
    dFillY = dPosY

    If \d("W") = 0
      \d("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    dFillW = \d("W")
    dFillH = \d("H")
    
    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)
      
      \s("PPDF_FontName")  = ""
      \s("PPDF_FontStyle") = ""
      ForEach *psV\Fonts()
        If *psV\Fonts()\iHandle = \i("Font")
          If *psV\Fonts()\iStyle & #PB_Font_Bold
            \s("PPDF_FontStyle") + "B"
            \s("PPDF_FontName") + " Fett"
          EndIf
          If *psV\Fonts()\iStyle & #PB_Font_Italic
            \s("PPDF_FontStyle") + "I"
            \s("PPDF_FontName") + " Kursiv"
          EndIf
          If *psV\Fonts()\iStyle & #PB_Font_Underline
            \s("PPDF_FontStyle") + "U"
          EndIf
          
          PDF::SetFont(0, *psV\Fonts()\zName, \s("PPDF_FontStyle"), \d("FontSize") * 2.83465)
        EndIf
      Next
      
      PDF::SetColorRGB(0, PDF::#FillColor, Red(\i("FillColor")), Green(\i("FillColor")), Blue(\i("FillColor")))
      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetColorRGB(0, PDF::#TextColor, Red(\i("TextColor")), Green(\i("TextColor")), Blue(\i("TextColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      \i("PPDF_Border") = 0
      If \i("Border") = #ALL
        \i("PPDF_Border") = #True
      Else
        If \i("Border") & #TOP
          \i("PPDF_Border") + PDF::#TopBorder
        EndIf
        If \i("Border") & #RIGHT
          \i("PPDF_Border") + PDF::#RightBorder
        EndIf
        If \i("Border") & #BOTTOM
          \i("PPDF_Border") + PDF::#BottomBorder
        EndIf
        If \i("Border") & #LEFT
          \i("PPDF_Border") + PDF::#LeftBorder
        EndIf
      EndIf
      
      Select \i("Ln")
        Case #RIGHT   : \i("PPDF_Ln") = PDF::#Right
        Case #NEWLINE : \i("PPDF_Ln") = PDF::#NextLine
        Case #BOTTOM  : \i("PPDF_Ln") = PDF::#Below
      EndSelect

      Select \i("HAlign")
        Case #LEFT   : \s("PPDF_Align") = PDF::#LeftAlign
        Case #RIGHT  : \s("PPDF_Align") = PDF::#RightAlign
        Case #CENTER : \s("PPDF_Align") = PDF::#CenterAlign
      EndSelect
      
      PDF::SetMargin(0, PDF::#CellMargin, *psV\CellMargin\dTop)
      
      PDF::Cell(0, \s("Text"), \d("W"), \d("H"), \i("PPDF_Border"), \i("PPDF_Ln"), \s("PPDF_Align"), \i("Fill"))
      
      ProcedureReturn 1
    EndIf

    ; //
    ; fill
    ; //
    If \i("Border") = #ALL
      dFillX + \d("BorderSize") / 2
      dFillY + \d("BorderSize") / 2
      dFillW - \d("BorderSize")
      dFillH - \d("BorderSize")
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        dFillY + \d("BorderSize") / 2
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #BOTTOM
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #LEFT
        dFillX + \d("BorderSize") / 2
        dFillW - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #RIGHT
        dFillW - \d("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\i("FillColor"))
    If \i("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf
    
    ; //
    ; border
    ; //
    VectorSourceColor(\i("LineColor"))
    If \i("Border") = #ALL
      AddPathBox(dPosX, dPosY, \d("W"), \d("H"))
      AddPathLine(\d("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \d("H"))
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \i("Border") & #RIGHT
        MovePathCursor(dPosX + \d("W"), dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; text
    ; //
    VectorFont(FontID(\i("Font")), Round(\d("FontSize") * 2.83465, #PB_Round_Nearest) / 2.83465)
    VectorSourceColor(\i("TextColor"))
    
    ; //
    ; horizontal align
    ; //
    dTextX = dPosX + *psV\CellMargin\dLeft - VectorTextWidth(\s("Text"), #PB_VectorText_Visible | #PB_VectorText_Offset)
    If \i("HAlign") = #RIGHT
      dTextX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) - VectorTextWidth(\s("Text"), #PB_VectorText_Visible)
    ElseIf \i("HAlign") = #CENTER
      dTextX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) / 2 - VectorTextWidth(\s("Text"), #PB_VectorText_Visible) / 2
    EndIf
    
    ; //
    ; vertical align
    ; //
    dTextY = dPosY + *psV\CellMargin\dTop - VectorTextHeight(\s("Text"), #PB_VectorText_Visible | #PB_VectorText_Offset)
    If \i("VAlign") = #BOTTOM
      dTextY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) - VectorTextHeight(\s("Text"), #PB_VectorText_Visible)
    ElseIf \i("VAlign") = #CENTER
      dTextY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) / 2 - VectorTextHeight(\s("Text"), #PB_VectorText_Visible) / 2
    EndIf
    
    MovePathCursor(dTextX, dTextY)
    DrawVectorText(\s("Text"))
    
  EndWith
  
EndProcedure

Procedure _drawParagraphCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a paragraph cell (#ELEMENTTYPE_PARACELL).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iHAlign
  Protected.d dPosX,
              dPosY,
              dFillX,
              dFillY,
              dFillW,
              dFillH
; ----------------------------------------
  
  With *psT\Elements()

    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    dFillX = dPosX
    dFillY = dPosY
    
    If \d("W") = 0
      \d("W") = _calcPageWidth(*psV, #RIGHT, 1) - dPosX
    EndIf

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)
      
      \s("PPDF_FontStyle") = ""
      ForEach *psV\Fonts()
        If *psV\Fonts()\iHandle = \i("Font")
          If *psV\Fonts()\iStyle & #PB_Font_Bold
            \s("PPDF_FontStyle") + "B"
          EndIf
          If *psV\Fonts()\iStyle & #PB_Font_Italic
            \s("PPDF_FontStyle") + "I"
          EndIf
          If *psV\Fonts()\iStyle & #PB_Font_Underline
            \s("PPDF_FontStyle") + "U"
          EndIf
          
          PDF::SetFont(0, *psV\Fonts()\zName, \s("PPDF_FontStyle"), \d("FontSize") * 2.83465)
        EndIf
      Next

      If \d("H") = 0
        \i("PPDF_FontHeightImage") = CreateImage(#PB_Any, 10, 10)
        StartVectorDrawing(ImageVectorOutput(\i("PPDF_FontHeightImage"), #PB_Unit_Millimeter))
        VectorFont(FontID(\i("Font")), \d("FontSize"))
        \d("H") = VectorParagraphHeight(\s("Text"), \d("W"), *psV\Sections()\Size\dHeight)
        StopVectorDrawing()
        FreeImage(\i("PPDF_FontHeightImage"))
      EndIf

      PDF::SetColorRGB(0, PDF::#FillColor, Red(\i("FillColor")), Green(\i("FillColor")), Blue(\i("FillColor")))
      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      \i("PPDF_Border") = 0
      If \i("Border") = #ALL
        \i("PPDF_Border") = #True
      Else
        If \i("Border") & #TOP
          \i("PPDF_Border") + PDF::#TopBorder
        EndIf
        If \i("Border") & #RIGHT
          \i("PPDF_Border") + PDF::#RightBorder
        EndIf
        If \i("Border") & #LEFT
          \i("PPDF_Border") + PDF::#LeftBorder
        EndIf
        If \i("Border") & #BOTTOM
          \i("PPDF_Border") + PDF::#BottomBorder
        EndIf
      EndIf
      
      Select \i("Ln")
        Case #RIGHT   : \i("PPDF_Ln") = PDF::#Right
        Case #NEWLINE : \i("PPDF_Ln") = PDF::#NextLine
        Case #BOTTOM  : \i("PPDF_Ln") = PDF::#Below
      EndSelect

      Select \i("HAlign")
        Case #LEFT   : \s("PPDF_Align") = PDF::#LeftAlign
        Case #RIGHT  : \s("PPDF_Align") = PDF::#RightAlign
        Case #CENTER : \s("PPDF_Align") = PDF::#CenterAlign
      EndSelect

      PDF::SetMargin(0, PDF::#CellMargin, *psV\CellMargin\dTop)

      PDF::MultiCell(0, \s("Text"), \d("W"), \d("FontSize") + 0.65, \i("PPDF_Border"), \s("PPDF_Align"), \i("Fill"))
      
      ProcedureReturn 1    
    EndIf

    VectorFont(FontID(\i("Font")), Round(\d("FontSize") * 2.83465, #PB_Round_Nearest) / 2.83465)
    If \d("H") = 0
      \d("H") = VectorParagraphHeight(\s("Text"), \d("W"), *psV\Sections()\Size\dHeight) + *psV\CellMargin\dBottom + *psV\CellMargin\dTop
    EndIf

    dFillW = \d("W")
    dFillH = \d("H")

    ; //
    ; fill
    ; //
    If \i("Border") = #ALL
      dFillX + \d("BorderSize") / 2
      dFillY + \d("BorderSize") / 2
      dFillW - \d("BorderSize")
      dFillH - \d("BorderSize")
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        dFillY + \d("BorderSize") / 2
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #BOTTOM
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #LEFT
        dFillX + \d("BorderSize") / 2
        dFillW - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #RIGHT
        dFillW - \d("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\i("FillColor"))
    If \i("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf

    ; //
    ; border
    ; //
    VectorSourceColor(\i("LineColor"))
    If \i("Border") = #ALL
      AddPathBox(dPosX, dPosY, \d("W"), \d("H"))
      AddPathLine(\d("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \d("H"))
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \i("Border") & #RIGHT
        MovePathCursor(dPosX + \d("W"), dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf

    ; //
    ; text
    ; //
    VectorSourceColor(\i("TextColor"))
    
    If     \i("HAlign") = #LEFT   : iHAlign = #PB_VectorParagraph_Left
    ElseIf \i("HAlign") = #RIGHT  : iHAlign = #PB_VectorParagraph_Right
    ElseIf \i("HAlign") = #CENTER : iHAlign = #PB_VectorParagraph_Center
    EndIf
    
    MovePathCursor(dPosX + *psV\CellMargin\dLeft, dPosY + *psV\CellMargin\dTop)
    DrawVectorParagraph(\s("Text"), \d("W") - *psV\CellMargin\dLeft - *psV\CellMargin\dRight, \d("H") - *psV\CellMargin\dTop - *psV\CellMargin\dBottom, iHAlign)

  EndWith

EndProcedure

Procedure _drawImageCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a image cell (#ELEMENTTYPE_IMAGECELL).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dFillX,
              dFillY,
              dFillW,
              dFillH,
              dImageX,
              dImageY
; ----------------------------------------
  
  With *psT\Elements()
    
    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    dFillX = dPosX
    dFillY = dPosY

    If \d("W") = 0
      \d("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    dFillW = \d("W")
    dFillH = \d("H")

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)
      
      PDF::SetColorRGB(0, PDF::#FillColor, Red(\i("FillColor")), Green(\i("FillColor")), Blue(\i("FillColor")))
      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))

      \i("PPDF_Border") = 0
      If \i("Border") = #ALL
        \i("PPDF_Border") = #True
      Else
        If \i("Border") & #TOP
          \i("PPDF_Border") + PDF::#TopBorder
        EndIf
        If \i("Border") & #RIGHT
          \i("PPDF_Border") + PDF::#RightBorder
        EndIf
        If \i("Border") & #LEFT
          \i("PPDF_Border") + PDF::#LeftBorder
        EndIf
        If \i("Border") & #BOTTOM
          \i("PPDF_Border") + PDF::#BottomBorder
        EndIf
      EndIf
      
      Select \i("Ln")
        Case #RIGHT   : \i("PPDF_Ln") = PDF::#Right
        Case #NEWLINE : \i("PPDF_Ln") = PDF::#NextLine
        Case #BOTTOM  : \i("PPDF_Ln") = PDF::#Below
      EndSelect

      ; //
      ; horizontal align
      ; //
      dImageX = dPosX + *psV\CellMargin\dLeft
      If \i("HAlign") = #RIGHT
        dImageX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) - \d("ImageW")
      ElseIf \i("HAlign") = #CENTER
        dImageX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) / 2 - \d("ImageW") / 2
      EndIf
      
      ; //
      ; vertical align
      ; //
      dImageY = dPosY + *psV\CellMargin\dTop
      If \i("VAlign") = #BOTTOM
        dImageY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) - \d("ImageH")
      ElseIf \i("VAlign") = #CENTER
        dImageY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) / 2 - \d("ImageH") / 2
      EndIf

      PDF::SetMargin(0, PDF::#CellMargin, *psV\CellMargin\dTop)

      \i("PPDF_ImageMem") = EncodeImage(\i("Image"), #PB_ImagePlugin_PNG)
      PDF::Cell(0, "", \d("W"), \d("H"), \i("PPDF_Border"), \i("PPDF_Ln"), "", \i("Fill"))
      PDF::ImageMemory(0, "Image", \i("PPDF_ImageMem"), MemorySize(\i("PPDF_ImageMem")), PDF::#Image_PNG, dImageX, dImageY, \d("ImageW"), \d("ImageH"))
      FreeMemory(\i("PPDF_ImageMem"))
      
      ProcedureReturn 1
    EndIf

    ; //
    ; fill
    ; //
    If \i("Border") = #ALL
      dFillX + \d("BorderSize") / 2
      dFillY + \d("BorderSize") / 2
      dFillW - \d("BorderSize")
      dFillH - \d("BorderSize")
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        dFillY + \d("BorderSize") / 2
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #BOTTOM
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #LEFT
        dFillX + \d("BorderSize") / 2
        dFillW - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #RIGHT
        dFillW - \d("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\i("FillColor"))
    If \i("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf

    ; //
    ; border
    ; //
    VectorSourceColor(\i("LineColor"))
    If \i("Border") = #ALL
      AddPathBox(dPosX, dPosY, \d("W"), \d("H"))
      AddPathLine(\d("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \d("H"))
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \i("Border") & #RIGHT
        MovePathCursor(dPosX + \d("W"), dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; horizontal align
    ; //
    dImageX = dPosX + *psV\CellMargin\dLeft
    If \i("HAlign") = #RIGHT
      dImageX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) - \d("ImageW")
    ElseIf \i("HAlign") = #CENTER
      dImageX + (\d("W") - *psV\CellMargin\dRight - *psV\CellMargin\dLeft) / 2 - \d("ImageW") / 2
    EndIf
    
    ; //
    ; vertical align
    ; //
    dImageY = dPosY + *psV\CellMargin\dTop
    If \i("VAlign") = #BOTTOM
      dImageY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) - \d("ImageH")
    ElseIf \i("VAlign") = #CENTER
      dImageY + (\d("H") - *psV\CellMargin\dBottom - *psV\CellMargin\dTop) / 2 - \d("ImageH") / 2
    EndIf
    
    MovePathCursor(dImageX, dImageY)
    DrawVectorImage(ImageID(\i("Image")), 255, \d("ImageW"), \d("ImageH"))
    
  EndWith
  
EndProcedure

Procedure _drawHorizontalLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a horizontal line (#ELEMENTTYPE_HLINE).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dLineX
; ----------------------------------------
  
  With *psT\Elements()

    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    
    If \d("W") = 0
      \d("W") = _calcPageWidth(*psV, VecVi::#RIGHT) - *psT\Elements()\PagePos\dX
    EndIf
    
    ; //
    ; horizontal align
    ; //
    If \i("HAlign") = #LEFT
      dLineX = dPosX
    ElseIf \i("HAlign") = #RIGHT
      dLineX = dPosX + _calcPageWidth(*psV) - \d("W")
    ElseIf \i("HAlign") = #CENTER
      dLineX = dPosX + _calcPageWidth(*psV) / 2 - \d("W") / 2
    EndIf

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)

      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      PDF::DrawLine(0, dLineX, dPosY, dLineX + \d("W"), dPosY)
      
      ProcedureReturn 1
    EndIf
    
    MovePathCursor(dLineX, dPosY)
    VectorSourceColor(\i("LineColor"))
    AddPathLine(\d("W"), 0, #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
  EndWith

EndProcedure

Procedure _drawVerticalLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a vertical line (#ELEMENTTYPE_VLINE).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dLineY
; ----------------------------------------
  
  With *psT\Elements()

    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    
    If \d("H") = 0
      \d("H") = _calcPageHeight(*psV, #BOTTOM) - *psT\Elements()\PagePos\dY
    EndIf
    
    ; //
    ; vertical align
    ; //
    If \i("VAlign") = #TOP
      dLineY = dPosY
    ElseIf \i("VAlign") = #BOTTOM
      dLineY = _calcPageHeight(*psV, #BOTTOM) - \d("H")
    ElseIf \i("VAlign") = #CENTER
      dLineY = _calcPageHeight(*psV, #BOTTOM) - _calcPageHeight(*psV, #TOP | #BOTTOM, 0) / 2 - \d("H") / 2
    EndIf

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)

      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      PDF::DrawLine(0, dPosX, dLineY, dPosX, dLineY + \d("H"))
      
      ProcedureReturn 1
    EndIf
        
    MovePathCursor(dPosX, dLineY)
    VectorSourceColor(\i("LineColor"))
    AddPathLine(0, \d("H"), #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
  EndWith

EndProcedure

Procedure _drawXYLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a xy line (#ELEMENTTYPE_XYLINE).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dLineX
; ----------------------------------------
  
  With *psT\Elements()

    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    
    If \d("dX") = 0
      \d("dX") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    If \d("dY") = 0
      \d("dY") = _calcPageHeight(*psV, #BOTTOM) - dPosY
    EndIf

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)

      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      PDF::DrawLine(0, dPosX, dPosY, dPosX + \d("dX"), dPosY + \d("dY"))
      
      ProcedureReturn 1
    EndIf
    
    MovePathCursor(dPosX, dPosY)
    VectorSourceColor(\i("LineColor"))
    AddPathLine(\d("dX"), \d("dY"), #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
  EndWith

EndProcedure

Procedure _drawCurve(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a curve (#ELEMENTTYPE_CURVE).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY
  Protected.i iFlags
; ----------------------------------------
  
  With *psT\Elements()
    
    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)

      PDF::SetColorRGB(0, PDF::#FillColor, Red(\i("FillColor")), Green(\i("FillColor")), Blue(\i("FillColor")))
      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))

      ProcedureReturn 1
    EndIf
    
    MovePathCursor(dPosX, dPosY)
    VectorSourceColor(\i("LineColor"))
    AddPathCurve(\d("S1X"), \d("S1Y"), \d("S2X"), \d("S2Y"), \d("EndX"), \d("EndY"))
    _applyLineStyle(@*psT\Elements())
    
  EndWith
  
EndProcedure

Procedure _drawRectangle(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a rectangle (#ELEMENTTYPE_RECTANGLE).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY,
              dFillX,
              dFillY,
              dFillW,
              dFillH
; ----------------------------------------
  
  With *psT\Elements()
    
    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)
    dFillX = dPosX
    dFillY = dPosY

    If \d("W") = 0
      \d("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    If \d("H") = 0
      \d("H") = _calcPageHeight(*psV, #BOTTOM) - dPosY
    EndIf

    dFillW = \d("W")
    dFillH = \d("H")

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)
      
      PDF::SetColorRGB(0, PDF::#FillColor, Red(\i("FillColor")), Green(\i("FillColor")), Blue(\i("FillColor")))
      PDF::SetColorRGB(0, PDF::#DrawColor, Red(\i("LineColor")), Green(\i("LineColor")), Blue(\i("LineColor")))
      PDF::SetLineThickness(0, \d("LineSize"))
      
      \i("PPDF_Border") = 0
      If \i("Border") = #ALL
        \i("PPDF_Border") = #True
      Else
        If \i("Border") & #TOP
          \i("PPDF_Border") + PDF::#TopBorder
        EndIf
        If \i("Border") & #RIGHT
          \i("PPDF_Border") + PDF::#RightBorder
        EndIf
        If \i("Border") & #LEFT
          \i("PPDF_Border") + PDF::#LeftBorder
        EndIf
        If \i("Border") & #BOTTOM
          \i("PPDF_Border") + PDF::#BottomBorder
        EndIf
      EndIf
      
      Select \i("Ln")
        Case #RIGHT   : \i("PPDF_Ln") = PDF::#Right
        Case #NEWLINE : \i("PPDF_Ln") = PDF::#NextLine
        Case #BOTTOM  : \i("PPDF_Ln") = PDF::#Below
      EndSelect
      
      PDF::Cell(0, "", \d("W"), \d("H"), \i("PPDF_Border"), \i("PPDF_Ln"), "", \i("Fill"))
      
      ProcedureReturn 1
    EndIf
    
    ; //
    ; border
    ; //
    VectorSourceColor(\i("LineColor"))
    If \i("Border") = #ALL
      AddPathBox(dPosX, dPosY, \d("W"), \d("H"))
      AddPathLine(\d("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \d("H"))
        AddPathLine(\d("W"), 0, #PB_Path_Relative)
      EndIf
      If \i("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \i("Border") & #RIGHT
        MovePathCursor(dPosX + \d("W"), dPosY - Bool(\i("Border") & #TOP) * (\d("BorderSize") / 2))
        AddPathLine(0, \d("H") + (Bool(\i("Border") & #TOP) + Bool(\i("Border") & #BOTTOM)) * (\d("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; fill
    ; //
    If \i("Border") = #ALL
      dFillX + \d("BorderSize") / 2
      dFillY + \d("BorderSize") / 2
      dFillW - \d("BorderSize")
      dFillH - \d("BorderSize")
    ElseIf \i("Border") <> #False
      If \i("Border") & #TOP
        dFillY + \d("BorderSize") / 2
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #BOTTOM
        dFillH - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #LEFT
        dFillX + \d("BorderSize") / 2
        dFillW - \d("BorderSize") / 2
      EndIf
      If \i("Border") & #RIGHT
        dFillW - \d("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\i("FillColor"))
    If \i("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf
    
  EndWith
  
EndProcedure

Procedure _drawSector(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: drawing of a ellipse sector (#ELEMENTTYPE_SECTOR).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dPosX,
              dPosY
  Protected.i iFlags
; ----------------------------------------
  
  With *psT\Elements()
    
    dPosX = _getElementPosition(*psV, *psT, 0)
    dPosY = _getElementPosition(*psV, *psT, 1)

    ; //
    ; for pbPDF
    ; //
    If *psV\iOutput = #OUTPUT_PBPDF
      PDF::SetPosXY(0, dPosX, dPosY)
      
      If \i("Fill") = #True And \i("Border") = #True
        \s("PPDF_Opt") = PDF::#DrawAndFill
      EndIf
      If \i("Fill") = #True And \i("Border") = #False
        \s("PPDF_Opt") = PDF::#FillOnly
      EndIf
      If \i("Fill") = #False And \i("Border") = #True
        \s("PPDF_Opt") = PDF::#DrawOnly
      EndIf
      
      PDF::DrawSector(0, dPosX + \d("W") / 2, dPosY + \d("H") / 2, \d("W") / 2, \d("Start"), \d("End"), \s("PPDF_Opt"))

      ProcedureReturn 1
    EndIf
    
    If \i("Connect") = #True
      iFlags = #PB_Path_Connected
      MovePathCursor(dPosX + \d("W") / 2, dPosY + \d("H") / 2)
    EndIf
    
    AddPathEllipse(dPosX + \d("W") / 2, dPosY + \d("H") / 2, \d("W") / 2, \d("H") / 2, \d("Start"), \d("End"), iFlags)
    
    If \i("Connect") = #True
      ClosePath()
    EndIf
    
    If \i("Fill") = #True
      VectorSourceColor(\i("FillColor"))
      FillPath(#PB_Path_Preserve)
    EndIf
    
    If \i("Border") = #True
      VectorSourceColor(\i("LineColor"))
      _applyLineStyle(@*psT\Elements())
    EndIf
    ResetPath()
    
  EndWith
  
EndProcedure

Procedure _drawHeader(*psV.VECVI)
; ----------------------------------------
; internal   :: processes drawing of a page's header.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; draw all header elements
  ; //
  _defTarget(*psV, 11)
  _drawElements(*psV, -1)
  _defTarget(*psV, 0)
  
EndProcedure

Procedure _drawFooter(*psV.VECVI)
; ----------------------------------------
; internal   :: draws the page's footer.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dFooterHeight
; ----------------------------------------
  
  ; //
  ; draw all footer elements
  ; //
  _defTarget(*psV, 21)
  _drawElements(*psV, -1)
  _defTarget(*psV, 0)
  
EndProcedure

Procedure _drawNewPage(*psV.VECVI)
; ----------------------------------------
; internal   :: draws a new page and its bounds.
; param      :: psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; for paged outputs, create a new page, if it's not the first one
  ; (it is created automatically.)
  ; //
  If *psV\iDrawMode = #DRAW_PAGED And *psV\iOutput <> #OUTPUT_PBPDF And Not *psV\Sections()\Pages()\iNr = 1
    NewVectorPage()
  EndIf
  
  If *psV\iOutput = #OUTPUT_PBPDF
    If *psV\Sections()\iOrientation = #VERTICAL
      PDF::AddPage(0, "P", StrD(ValD(StringField(*psV\Sections()\zFormat, 1, ",")) * 2.83465, 2) + "," + StrD(ValD(StringField(*psV\Sections()\zFormat, 2, ",")) * 2.83465, 2))
    Else
      PDF::AddPage(0, "L", StrD(ValD(StringField(*psV\Sections()\zFormat, 1, ",")) * 2.83465, 2) + "," + StrD(ValD(StringField(*psV\Sections()\zFormat, 2, ",")) * 2.83465, 2))
    EndIf
  Else
    ; //
    ; fill the page in the current sizes
    ; //
    If *psV\iDrawMode = #DRAW_SINGLE
      AddPathBox(*psV\RootPos\dX, *psV\RootPos\dY, *psV\Sections()\Size\dWidth, *psV\Sections()\Size\dHeight)
    ElseIf *psV\iDrawMode = #DRAW_MULTIH Or *psV\iDrawMode = #DRAW_MULTIV
      AddPathBox(*psV\RootPos\dX + *psV\Sections()\Pages()\DrawPos\dX, *psV\RootPos\dY + *psV\Sections()\Pages()\DrawPos\dY, *psV\Sections()\Size\dWidth, *psV\Sections()\Size\dHeight)
    EndIf  
    VectorSourceColor(*psV\i("BackColor"))
    FillPath()
  EndIf
  
  ; //
  ; draw the header before all further content
  ; //
  _drawHeader(*psV)
  
EndProcedure

Procedure _drawEndPage(*psV.VECVI)
; ----------------------------------------
; internal   :: draws things related to a page finish
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: just calls VecVi::_processFooter()
; ----------------------------------------
  
  _drawFooter(*psV)
  
EndProcedure

Procedure.i _drawElements(*psV.VECVI, piStartPageRef.i, piE.i = 0)
; ----------------------------------------
; internal   :: draws all elements within one block on the current definition target.
; param      :: *psV           - VecVi structure
;               piStartPageRef - reference to page which the first element is on
;               piE            - (S: 0) reference to starting element inside the current block
; returns    :: (i) drawing completion state
;               0: drawing aborted inside the block
;               1: full block has been drawed
; remarks    :: 
; ----------------------------------------
  Protected.i iOldPageRef 
  Protected   *Target.VECVI_BLOCK
; ----------------------------------------
  
  ; //
  ; get definition target
  ; //
  *Target     = _defTarget(*psV)
    
  ; //
  ; select the starting element in the block or the first one,
  ; if none given
  ; //
  If piE = 0
    FirstElement(*Target\Elements())
    If ListIndex(*Target\Elements()) = -1
      ProcedureReturn 1
    EndIf
  Else
    ChangeCurrentElement(*Target\Elements(), piE)
    If ListIndex(*Target\Elements()) = -1
      ProcedureReturn 1
    EndIf
  EndIf
  
  iOldPageRef = piStartPageRef
  
  ; //
  ; loop through all following elements in the block
  ; //
  Repeat
    
    ; //
    ; detect page breaks
    ; //
    If iOldPageRef > -1 And *Target\Elements()\iPageRef <> iOldPageRef
    
      ; //
      ; if drawing is for single page, stop
      ; //
      If *psV\iDrawMode = #DRAW_SINGLE
        ProcedureReturn 0
      EndIf
      
      ; //
      ; draw next page
      ; //
      NextElement(*psV\Sections()\Pages())
      _drawNewPage(*psV)
      _drawEndPage(*psV)
      iOldPageRef = *Target\Elements()\iPageRef
    EndIf
    
    ; //
    ; replace the page numbering tokens with the current page number and the total
    ; page number for text elements.
    ; //
    If FindMapElement(*Target\Elements()\s(), "TextRaw")
      If *psV\Sections()\Pages()\iNb > -1
        *Target\Elements()\s("Text") = ReplaceString(*Target\Elements()\s("TextRaw"), *psV\s("NbCurrent"), Str(*psV\Sections()\Pages()\iNb))
        *Target\Elements()\s("Text") = ReplaceString(*Target\Elements()\s("Text"),    *psV\s("NbTotal"),   Str(*psV\iNbTotal))
      Else
        *Target\Elements()\s("Text") = *Target\Elements()\s("TextRaw")
      EndIf
    EndIf
    
    ; //
    ; split drawing by element type
    ; //
    Select *Target\Elements()\iType
      Case #ELEMENTTYPE_TEXTCELL  : _drawTextCell(*psV, *Target)
      Case #ELEMENTTYPE_PARACELL  : _drawParagraphCell(*psV, *Target)
      Case #ELEMENTTYPE_IMAGECELL : _drawImageCell(*psV, *Target)
      Case #ELEMENTTYPE_HLINE     : _drawHorizontalLine(*psV, *Target)
      Case #ELEMENTTYPE_VLINE     : _drawVerticalLine(*psV, *Target)
      Case #ELEMENTTYPE_XYLINE    : _drawXYLine(*psV, *Target)
      Case #ELEMENTTYPE_CURVE     : _drawCurve(*psV, *Target)
      Case #ELEMENTTYPE_RECTANGLE : _drawRectangle(*psV, *Target)
      Case #ELEMENTTYPE_SECTOR    : _drawSector(*psV, *Target)
    EndSelect

  Until NextElement(*Target\Elements()) = #Null
  
  ; //
  ; all elements drawed, completed block
  ; //
  ProcedureReturn 1
  
EndProcedure

Procedure _draw(*psV.VECVI, piOutput.i, piObject1.i, piObject2.i, pzPath.s, piPage.i)
; ----------------------------------------
; internal   :: output of all VecVi stuff to the specified output channel.
; param      :: psV - VecVi structure
;               piOutput   - output type
;                            #OUTPUT_CANVAS:      output to PB's CanvasGadget()
;                            #OUTPUT_CANVASIMAGE: output to an image object which is loaded into a CanvasGadget()
;                            #OUTPUT_IMAGE:       output to an image object
;                            #OUTPUT_WINDOW:      direct output to a window
;                            #OUTPUT_PRINTER:     send output to a printer using PB Printer lib
;                            #OUTPUT_SVG:         output to a .svg file
;                            #OUTPUT_PDF:         output to a .pdf file
;               piObject1  - first output gadget, window or image
;               piObject2  - second output image for piOutput = #OUTPUT_CANVASIMAGE
;               pzPath     - full output path for .svg and .pdf outputs
;               piPage     - only output the specified page
;                            for single-page output channels
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iOutput,
              iOldPageRef,
              i,
              iRes
  Protected   siS.Integer
  Protected   siB.Integer
  Protected   siE.Integer
; ----------------------------------------

  ; //
  ; get output channel
  ; //  
  *psV\iOutput = piOutput
  If piOutput = #OUTPUT_CANVAS
    iOutput = CanvasVectorOutput(piObject1, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_CANVASIMAGE
    iOutput = ImageVectorOutput(piObject2, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_IMAGE
    iOutput = ImageVectorOutput(piObject1, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_WINDOW
    iOutput = WindowVectorOutput(piObject1, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_PRINTER
    iOutput = PrinterVectorOutput(#PB_Unit_Millimeter)
    *psV\iOnlyPage = -1
  ElseIf piOutput = #OUTPUT_SVG
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      iOutput = SvgVectorOutput(pzPath, *psV\Sizes\dWidth, *psV\Sizes\dHeight, #PB_Unit_Millimeter)
    CompilerElse
      DebuggerError("SvgVectorOutput only supported on Linux.")
    CompilerEndIf
    *psV\iOnlyPage = -1
  ElseIf piOutput = #OUTPUT_PDF
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      DebuggerError("PdfVectorOutput not supported on Windows.")
    CompilerElse
      iOutput = PdfVectorOutput(pzPath, *psV\Sizes\dWidth, *psV\Sizes\dHeight, #PB_Unit_Millimeter)
    CompilerEndIf
    *psV\iOnlyPage = -1
  ElseIf piOutput = #OUTPUT_PBPDF
    *psV\iOnlyPage = -1
  EndIf
  
  ; //
  ; determine drawing mode
  ; //
  If *psV\iOutput = #OUTPUT_PRINTER Or *psV\iOutput = #OUTPUT_PDF Or *psV\iOutput = #OUTPUT_SVG Or *psV\iOutput = #OUTPUT_PBPDF
    *psV\iDrawMode = #DRAW_PAGED
  Else
    If *psV\i("MultiPageOutput") = #False
      *psV\iDrawMode = #DRAW_SINGLE
    ElseIf *psV\i("MultiPageOutput") = #HORIZONTAL    
      *psV\iDrawMode = #DRAW_MULTIH
    ElseIf *psV\i("MultiPageOutput") = #VERTICAL
      *psV\iDrawMode = #DRAW_MULTIV
    EndIf    
  EndIf

  ; //
  ; require processing?
  ; //
  If *psV\i("NoReprocessing") = 0
    _process(*psV)
    *psV\i("NoReprocessing") = 1
  EndIf
  
  ; //
  ; presets
  ; //
  If *psV\iDrawMode = #DRAW_PAGED
    ; //
    ; paged output does not need scaling or offsets
    ; //
    *psV\d("ScaleX") = 1
    *psV\d("ScaleY") = 1
    *psV\d("OutputOffsetLeft") = 0
    *psV\d("OutputOffsetTop") = 0
    *psV\RootPos\dX = 0
    *psV\RootPos\dY = 0   
  Else
    ; //
    ; reset root drawing point to user defined offsets
    ; //
    *psV\RootPos\dX = *psV\d("OutputOffsetLeft")
    *psV\RootPos\dY = *psV\d("OutputOffsetTop")
  EndIf
  
  
  ; //
  ; for pbPDF
  ; //
  If *psV\iOutput = #OUTPUT_PBPDF
    If *psV\i("Orientation") = #VERTICAL
      *psV\s("PPDF_Orientation") = "P"
    Else
      *psV\s("PPDF_Orientation") = "L"    
    EndIf
    PDF::Create(0, *psV\s("PPDF_Orientation"), "mm", StrD(ValD(StringField(*psV\s("Format"), 1, ",")) * 2.83465, 2) + "," + StrD(ValD(StringField(*psV\s("Format"), 2, ",")) * 2.83465, 2))
    PDF::SetAutoPageBreak(0, #False)
    iRes = 1
  EndIf
  
  ; //
  ; start drawing to the specified output
  ; //
  If *psV\iOutput <> #OUTPUT_PBPDF
    iRes = StartVectorDrawing(iOutput)
  EndIf
  
  If iRes

    ; //
    ; scaling
    ; //
    If *psV\iOutput <> #OUTPUT_PBPDF
      ScaleCoordinates(*psV\d("ScaleX"), *psV\d("ScaleY"))
    EndIf
    
    ; //
    ; reset the drawing area if needed
    ; //
    If *psV\iDrawMode <> #DRAW_PAGED
      VectorSourceColor(*psV\i("DeskColor"))
      FillVectorOutput()
    EndIf
    
    ; //
    ; pre-select the very first element
    ; //
    FirstElement(*psV\Sections())
    FirstElement(*psV\Sections()\Blocks())
    FirstElement(*psV\Sections()\Pages())

    iOldPageRef = -1
    
    ; //
    ; determine the starting element
    ; //
    If *psV\iDrawMode = #DRAW_PAGED
      ; //
      ; allow to define a starting page for paged outputs
      ; //
      If *psV\iOnlyPage > 0
        ForEach *psV\Sections()
          ForEach *psV\Sections()\Pages()
            If *psV\Sections()\Pages()\iNr = *psV\iOnlyPage
              *psV\iOnlyPage = @*psV\Sections()\Pages()
              _getFirstElementByPage(*psV, *psV\iOnlyPage, @siS, @siB, @siE)
              Break 2
            EndIf
          Next
        Next
      EndIf
      
    ElseIf *psV\iDrawMode = #DRAW_SINGLE And *psV\iOnlyPage > 0
      ; //
      ; single page output requires first element on given page
      ; //
      ForEach *psV\Sections()
        ForEach *psV\Sections()\Pages()
          If *psV\Sections()\Pages()\iNr = *psV\iOnlyPage
            *psV\iOnlyPage = @*psV\Sections()\Pages()
            _getFirstElementByPage(*psV, *psV\iOnlyPage, @siS, @siB, @siE)
            Break 2
          EndIf
        Next
      Next
      
    Else
      ; //
      ; all other modes go by offset
      ; //
      _getFirstElementByOffset(*psV, @siS, @siB, @siE)
    EndIf
    
    ; //
    ; select the starting element
    ; //
    If siS\i
      ChangeCurrentElement(*psV\Sections(), siS\i)
      If siB\i
        ChangeCurrentElement(*psV\Sections()\Blocks(), siB\i)
        If siE\i
          ; //
          ; select the element
          ; //
          ChangeCurrentElement(*psV\Sections()\Blocks()\Elements(), siE\i)
          
          ; //
          ; select the corresponding page
          ; //
          iOldPageRef = *psV\Sections()\Blocks()\Elements()\iPageRef
          ChangeCurrentElement(*psV\Sections()\Pages(), iOldPageRef)
        EndIf
      EndIf
    EndIf
    
    ; //
    ; loop through all sections
    ; //
    i = 0
    Repeat
      
      ; //
      ; for the first loop, don't reset the substructures as they were already preselected
      ; //
      If i > 0
        ResetList(*psV\Sections()\Pages())
        FirstElement(*psV\Sections()\Blocks())
      EndIf
      
      ; //
      ; loop through all blocks of the section
      ; //
      Repeat
        
        ; //
        ; performance: stop drawing if the block is not displayed in multi page outputs
        ; //
        If *psV\iDrawMode = #DRAW_MULTIV
          If -*psV\d("OutputOffsetTop") * *psV\d("ScaleY") + VectorOutputHeight() < *psV\Sections()\Blocks()\DrawPos\dY * *psV\d("ScaleY")
            Break 2
          EndIf
        ElseIf *psV\iDrawMode = #DRAW_MULTIH
          If -*psV\d("OutputOffsetLeft") * *psV\d("ScaleX") + VectorOutputWidth() < *psV\Sections()\Blocks()\DrawPos\dX * *psV\d("ScaleX")
            Break 2
          EndIf
        EndIf
        
        ; //
        ; detect page breaks
        ; //
        If *psV\iDrawMode <> #DRAW_SINGLE And (*psV\Sections()\Blocks()\iPageBeginRef <> iOldPageRef Or i = 0)
          ; //
          ; non-single page outputs´
          ; //
        
          ; //
          ; select next page if it's not the preselected first one
          ; //
          If i > 0
            NextElement(*psV\Sections()\Pages())
          EndIf
          
          _drawNewPage(*psV)
          _drawEndPage(*psV)
          i + 1
        ElseIf *psV\iDrawMode = #DRAW_SINGLE
          ; //
          ; single page output
          ; //
          
          ; //
          ; if the block is not on the page anymore, stop
          ; //
          If *psV\iOnlyPage <> *psV\Sections()\Blocks()\iPageBeginRef And *psV\iOnlyPage <> *psV\Sections()\Blocks()\iPageEndRef
            Break 2
          EndIf
          
          ; //
          ; draw the only page that has to be displayed in single page output mode
          ; //
          If i = 0
            _drawNewPage(*psV)
            _drawEndPage(*psV)
            i + 1
          EndIf
        EndIf
        
        ; //
        ; draw the block's elements
        ; //
        If *psV\iDrawMode = #DRAW_SINGLE
          ; //
          ; single page output, define starting element and required page reference
          ; //
          If _drawElements(*psV, *psV\iOnlyPage, siE\i) = 0
            Break 2
          EndIf
          siE\i = 0
        Else
          ; //
          ; other outputs, define the starting page reference for detecting page breaks inside the block
          ; //
          If _drawElements(*psV, *psV\Sections()\Blocks()\iPageBeginRef) = 0
            Break 2
          EndIf
        EndIf
        
        ; //
        ; current page after drawing of elements, may differ because
        ; of page breaks inside the block
        ; //
        iOldPageRef = *psV\Sections()\Blocks()\iPageEndRef
        
      Until NextElement(*psV\Sections()\Blocks()) = #Null
    Until NextElement(*psV\Sections()) = #Null
    
    ; //
    ; stop drawing
    ; //
    If *psV\iOutput <> #OUTPUT_PBPDF
      StopVectorDrawing()
    EndIf
  EndIf
  
  ; //
  ; if output channel is canvasimage, draw the image on the canvas gadget
  ; //
  If *psV\iOutput = #OUTPUT_CANVASIMAGE
    If StartVectorDrawing(CanvasVectorOutput(piObject1, #PB_Unit_Millimeter))
      VectorSourceColor(RGBA(125, 125, 125, 255))
      FillVectorOutput()
      DrawVectorImage(ImageID(piObject2))
      StopVectorDrawing()
    EndIf
  EndIf
  
  ; //
  ; for pbPDF
  ; //
  If *psV\iOutput = #OUTPUT_PBPDF
    PDF::Save(0, pzPath)
  EndIf
  
EndProcedure

Procedure _processBlock(*psV.VECVI, piTarget)
; ----------------------------------------
; internal   :: processes a block
; param      :: *psV     - VecVi structure
;            :: piTarget - definition target
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iSize,
              iIndex
  Protected.d dOldPagePos
  Protected   *Target.VECVI_BLOCK
; ----------------------------------------
  
  ; //
  ; get definition target
  ; //
  *Target = _defTarget(*psV, piTarget)

  ; //
  ; recalc size of the block
  ; //
  _calcBlockWidth(*Target, 1)
  _calcBlockHeight(*Target, 1)
  
  ; //
  ; reset x coordinates as blocks always start on the left side of the page
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  If piTarget = 0
    ; //
    ; normal page block margins
    ; //
    *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft
  ElseIf piTarget = 11
    ; //
    ; page header block margins
    ; //
    *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Header\Margin\dLeft
  ElseIf piTarget = 21
    ; //
    ; page footer block margins
    ; //
    *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Footer\Margin\dLeft
  EndIf
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)
  
  If *Target\iPageBreak = #False
    ; //
    ; if page breaks are forbidden within this block, check if the block size fits the
    ; left y space on the page, and create a new page, if it is necessary.
    ; //
    If piTarget = 0 And *psV\CurrPagePos\dY + *Target\Size\dHeight > _calcPageHeight(*psV, #BOTTOM)
      _processEndPage(*psV)
      _processNewPage(*psV)
    EndIf

    ; //
    ; set references to the page this block is on
    ; //
    *Target\iPageBeginRef = @*psV\Sections()\Pages()
    *Target\iPageEndRef   = @*psV\Sections()\Pages()
        
    ; //
    ; set block positions
    ; //
    *Target\DrawPos    = *psV\CurrGlobPos
    *Target\PagePos    = *psV\CurrPagePos
    *Target\SectPos\dX = *psV\CurrGlobPos\dX - *psV\Sections()\DrawPos\dX
    *Target\SectPos\dY = *psV\CurrGlobPos\dY - *psV\Sections()\DrawPos\dY

    ForEach *Target\Elements()
      With *Target\Elements()
        
        ; //
        ; set reference to the page this element is on
        ; //
        \iPageRef = @*psV\Sections()\Pages()

        ; //
        ; set position of element in global output
        ; //
        \DrawPos = *psV\CurrGlobPos
    
        ; //
        ; set position of element inside the current page.
        ; //
        \PagePos = *psV\CurrPagePos
        
        ; //
        ; add positions
        ; //
        *psV\CurrGlobPos\dX + \AddPos\dX
        *psV\CurrGlobPos\dY + \AddPos\dY
        *psV\CurrPagePos\dX + \AddPos\dX
        *psV\CurrPagePos\dY + \AddPos\dY
      EndWith
    Next
  
  ElseIf *Target\iPageBreak = #True
    ; //
    ; if page breaks are allowed in this block, check for page breaks in elements
    ; //
    
    ; //
    ; preset references to the page this block is on
    ; will be overwritten later by element page refs
    ; or stay if the block is empty
    ; //
    *Target\iPageBeginRef = @*psV\Sections()\Pages()
    *Target\iPageEndRef   = @*psV\Sections()\Pages()
    
    iSize = ListSize(*Target\Elements())
    ForEach *Target\Elements()
      With *Target\Elements()

        ; //
        ; check if the element size fits the left y space on the page,
        ; and create a new page, if it is necessary.
        ; //
        If *psV\CurrPagePos\dY + \Size\dHeight > _calcPageHeight(*psV, #BOTTOM)
          _processEndPage(*psV)
          _processNewPage(*psV, *Target\Elements()\BlockPos\dX)
        EndIf
        
        iIndex = ListIndex(*Target\Elements())
        If iIndex = 0
          ; //
          ; set block positions
          ; //
          *Target\DrawPos    = *psV\CurrGlobPos
          *Target\PagePos    = *psV\CurrPagePos
          *Target\SectPos\dX = *psV\CurrGlobPos\dX - *psV\Sections()\DrawPos\dX
          *Target\SectPos\dY = *psV\CurrGlobPos\dY - *psV\Sections()\DrawPos\dY
        
          ; //
          ; set reference to the starting page this block is on
          ; //
          *Target\iPageBeginRef = @*psV\Sections()\Pages()
        EndIf
        If iIndex = iSize - 1
          ; //
          ; set reference to the ending page this block is on
          ; //
          *Target\iPageEndRef   = @*psV\Sections()\Pages()
        EndIf

        ; //
        ; set reference to the page this element is on
        ; //
        \iPageRef = @*psV\Sections()\Pages()

        ; //
        ; set position of element in global output
        ; //
        \DrawPos = *psV\CurrGlobPos
    
        ; //
        ; set position of element inside the current page
        ; //
        \PagePos = *psV\CurrPagePos
        
        ; //
        ; add positions
        ; //
        *psV\CurrGlobPos\dX + \AddPos\dX
        *psV\CurrGlobPos\dY + \AddPos\dY
        *psV\CurrPagePos\dX + \AddPos\dX
        *psV\CurrPagePos\dY + \AddPos\dY
      EndWith
    Next
  
  EndIf
  
EndProcedure

Procedure _processNewPage(*psV.VECVI, pdRestoreX.d = 0)
; ----------------------------------------
; internal   :: processes a page break
; param      :: *psV       - VecVi structure
;               pdRestoreX - Restore x position retrieved from last element before page break
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------
  
  ; //
  ; for multi page output, add the margin between the pages
  ; //
  If *psV\iDrawMode = #DRAW_MULTIH
    If ListIndex(*psV\Sections()\Pages()) = -1
      If *psV\Sections()\iNr = 1
        *psV\CurrGlobPos\dX = *psV\Sections()\DrawPos\dX
      Else
        *psV\CurrGlobPos\dX = *psV\Sections()\DrawPos\dX + *psV\d("MultiPageOutputMargin")
      EndIf
    Else
      *psV\CurrGlobPos\dX = *psV\Sections()\Pages()\DrawPos\dX + *psV\Sections()\Size\dWidth + *psV\d("MultiPageOutputMargin")
    EndIf
    *psV\CurrGlobPos\dY = 0
    
  ElseIf *psV\iDrawMode = #DRAW_MULTIV
    If ListIndex(*psV\Sections()\Pages()) = -1
      If *psV\Sections()\iNr = 1
        *psV\CurrGlobPos\dY = *psV\Sections()\DrawPos\dY
      Else
        *psV\CurrGlobPos\dY = *psV\Sections()\DrawPos\dY + *psV\d("MultiPageOutputMargin")
      EndIf
    Else
      *psV\CurrGlobPos\dY = *psV\Sections()\Pages()\DrawPos\dY + *psV\Sections()\Size\dHeight + *psV\d("MultiPageOutputMargin")
    EndIf
    *psV\CurrGlobPos\dX = 0
  EndIf
  
  ; //
  ; add new page
  ; //
  AddElement(*psV\Sections()\Pages())
  
  ; //
  ; set the global page nr
  ; //
  *psV\iNrPages + 1
  *psV\Sections()\iNrPages + 1
  *psV\Sections()\Pages()\iNr = *psV\iNrPages

  ; //
  ; if page numbering is activated, increment the current page number
  ; for this page based on the start value of the current
  ; section
  ; //
  If *psV\Sections()\iNb > 0
    *psV\iNbCurrent = *psV\Sections()\iNbStartValue + *psV\Sections()\iNrPages - 1
    *psV\iNbTotal + 1
    *psV\Sections()\Pages()\iNb = *psV\iNbCurrent
  ElseIf *psV\Sections()\iNb = 0
    *psV\iNbCurrent + 1
    *psV\iNbTotal + 1
    *psV\Sections()\Pages()\iNb = *psV\iNbCurrent
  EndIf

  ; //
  ; set the start coordinates of the page
  ; //
  *psV\Sections()\Pages()\DrawPos = *psV\CurrGlobPos
  
  ; //
  ; copy the header and footer information
  ; //
  *psV\Sections()\Pages()\Header\Margin = *psV\Sections()\Header\Margin
  *psV\Sections()\Pages()\Footer\Margin = *psV\Sections()\Footer\Margin
  *psV\Sections()\Pages()\Header\Block\Size = *psV\Sections()\Header\Block\Size
  *psV\Sections()\Pages()\Footer\Block\Size = *psV\Sections()\Footer\Block\Size
  CopyList(*psV\Sections()\Header\Block\Elements(), *psV\Sections()\Pages()\Header\Block\Elements())
  CopyList(*psV\Sections()\Footer\Block\Elements(), *psV\Sections()\Pages()\Footer\Block\Elements())
  
  ; //
  ; set the x coordinates to the header root values
  ; //
  *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Header\Margin\dLeft
  *psV\CurrGlobPos\dX + *psV\CurrPagePos\dX
  
  ; //
  ; set the y coordinates to the header root values
  ; //
  *psV\CurrPagePos\dY = *psV\Sections()\Margin\dTop + *psV\Sections()\Pages()\Header\Margin\dTop
  *psV\CurrGlobPos\dY + *psV\CurrPagePos\dY
  
  ; //
  ; set the header block positions
  ; //
  *psV\Sections()\Pages()\Header\Block\DrawPos = *psV\CurrGlobPos
  *psV\Sections()\Pages()\Header\Block\PagePos = *psV\CurrPagePos
  
  ; //
  ; process the header
  ; //
  _processBlock(*psV, 11)

  ; //
  ; set the x coordinates to the page root values
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft + pdRestoreX
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)

  ; //
  ; add header y bottom margin
  ; //
  *psV\CurrPagePos\dY + *psV\Sections()\Pages()\Header\Margin\dBottom
  *psV\CurrGlobPos\dY + *psV\Sections()\Pages()\Header\Margin\dBottom
  
EndProcedure

Procedure _processEndPage(*psV.VECVI)
; ----------------------------------------
; internal   :: processes a page ending
; param      :: *psV     - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------

  ; //
  ; set the x coordinates to the footer root values
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft + *psV\Sections()\Pages()\Footer\Margin\dLeft
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)
  
  ; //
  ; set the y coordinates to the footer root values
  ; //
  dOldPagePos = *psV\CurrPagePos\dY
  *psV\CurrPagePos\dY = _calcPageHeight(*psV, #BOTTOM)
  *psV\CurrGlobPos\dY + (*psV\CurrPagePos\dY - dOldPagePos)

  ; //
  ; add footer y top margin
  ; //
  *psV\CurrPagePos\dY + *psV\Sections()\Pages()\Footer\Margin\dTop
  *psV\CurrGlobPos\dY + *psV\Sections()\Pages()\Footer\Margin\dTop

  ; //
  ; set the footer block positions
  ; //
  *psV\Sections()\Pages()\Footer\Block\DrawPos = *psV\CurrGlobPos
  *psV\Sections()\Pages()\Footer\Block\PagePos = *psV\CurrPagePos

  ; //
  ; process the footer
  ; //
  _processBlock(*psV, 21)

  ; //
  ; set the x coordinates to the pages bottom right corner
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  *psV\CurrPagePos\dX = *psV\Sections()\Size\dWidth
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)

  ; //
  ; add footer y bottom margin and page bottom margin
  ; //
  *psV\CurrGlobPos\dY + *psV\Sections()\Pages()\Footer\Margin\dBottom + *psV\Sections()\Margin\dBottom
  *psV\CurrPagePos\dY + *psV\Sections()\Pages()\Footer\Margin\dBottom + *psV\Sections()\Margin\dBottom
  
EndProcedure

Procedure _process(*psV.VECVI)
; ----------------------------------------
; internal   :: processes the VecVi definition before drawing
; param      :: *psV     - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  ; //
  ; get number of sections
  ; //
  *psV\iNrSections = ListSize(*psV\Sections())
  
  ; //
  ; reset current positions
  ; //
  *psV\CurrGlobPos\dX = 0
  *psV\CurrGlobPos\dY = 0
  *psV\CurrPagePos\dX = 0
  *psV\CurrPagePos\dY = 0
    
  ; //
  ; reset page numbering
  ; //
  *psV\iNrPages = 0
  
  *psV\iNbCurrent = 0
  *psV\iNbTotal   = 0
  
  ForEach *psV\Sections()
    ; //
    ; reset drawing position
    ; //
    *psV\Sections()\DrawPos\dX = *psV\CurrGlobPos\dX
    *psV\Sections()\DrawPos\dY = *psV\CurrGlobPos\dY
    
    ; //
    ; clear list of pages for this section
    ; //
    ClearList(*psV\Sections()\Pages())
    *psV\Sections()\iNrPages = 0
    
    ; //
    ; add first page
    ; //
    _processNewPage(*psV)
    
    ; //
    ; process blocks on the section
    ; //
    ForEach *psV\Sections()\Blocks()
      _processBlock(*psV, 0)
    Next
    
    ; //
    ; finish last page
    ; //
    _processEndPage(*psV)
    
  Next
  
EndProcedure

;- >>> basic functions <<<

Procedure.i Create(pzFormat.s, piOrientation.i)
; ----------------------------------------
; public     :: creates a new VecVi object
; param      :: pzFormat      - page format ('Short side,Long side')
;                               or constant - see #FORMAT_*
;               piOrientation - page orientation
;                               #HORIZONTAL: width: short side, height: long side
;                               #VERTICAL:   width: long side, height: short side
; returns    :: pointer to VecVi object structure
; remarks    :: this procedure has to be called before all other VecVi commands.
; ----------------------------------------
  Protected *psV.VECVI
; ----------------------------------------
  
  ; //
  ; allocate the main structure
  ; //
  *psV = AllocateStructure(VECVI)
  
  With *psV
    ; //
    ; set default page sizes
    ; //
    \i("Orientation") = piOrientation
    \s("Format")      = pzFormat
    If piOrientation = #VERTICAL
      \Size\dWidth  = ValD(StringField(pzFormat, 1, ","))
      \Size\dHeight = ValD(StringField(pzFormat, 2, ","))
    ElseIf piOrientation = #HORIZONTAL
      \Size\dWidth  = ValD(StringField(pzFormat, 2, ","))
      \Size\dHeight = ValD(StringField(pzFormat, 1, ","))
    EndIf
    
    ; //
    ; set default margins
    ; //
    \Margin\dBottom = 12.0
    \Margin\dLeft   = 14.0
    \Margin\dRight  = 12.0
    \Margin\dTop    = 15.0
    
    \CellMargin\dBottom = 1.0
    \CellMargin\dLeft   = 1.0
    \CellMargin\dRight  = 1.0
    \CellMargin\dTop    = 1.0
  
    ; //
    ; set default colors
    ; //
    \i("FillColor") = $FFFFFFFF
    \i("LineColor") = $FF000000
    \i("TextColor") = $FF000000
    \i("BackColor") = $FFFFFFFF
    \i("DeskColor") = $FF7D7D7D
  
    ; //
    ; set default line size and style
    ; //
    \d("LineSize")  = 0.2
    \i("LineStyle") = #LINESTYLE_STROKE
    \d("LineLen")   = 1.0
    
    ; //
    ; set page numbering tokens
    ; //
    \s("NbCurrent") = "{Nb}"
    \s("NbTotal")   = "{NbTotal}"
  
    ; //
    ; set default scale factor
    ; //
    \d("ScaleX") = 1.0
    \d("ScaleY") = 1.0
  
    ; //
    ; multi page output margin
    ; //
    \d("MultiPageOutputMargin") = 10.0
    
    ; //
    ; output offsets
    ; //
    \d("OutputOffsetLeft") = 0.0
    \d("OutputOffsetTop")  = 0.0
  
    ; //
    ; load default font
    ; //
    SetFont(*psV, "Arial", 0, 5)
    
  EndWith
    
  ProcedureReturn *psV
  
EndProcedure

Procedure Process(*psV.VECVI)
; ----------------------------------------
; public     :: manually reprocesses the VecVi data
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  _process(*psV)
  *psV\i("NoReprocessing") = 1
  
EndProcedure

Procedure Free(*psV.VECVI)
; ----------------------------------------
; public     :: frees all VecVi data.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  ; //
  ; free fonts
  ; //
  ForEach *psV\Fonts()
    FreeFont(*psV\Fonts()\iHandle)
  Next
  
  ; //
  ; free images
  ; //
  ForEach *psV\Images()
    FreeImage(*psV\Images()\iHandle)
  Next
  
  ; //
  ; free structure
  ; //
  FreeStructure(*psV)
  
EndProcedure

;- >>> area definition <<<

Procedure BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)
; ----------------------------------------
; public     :: starts a new section on the current VecVi structure.
; param      :: *psV          - VecVi structure
;               pzFormat      - (S: #FORMAT_INHERIT) page format ('Short side,Long side')
;                               or constant - see #FORMAT_*
;               piOrientation - (S: #INHERIT) page orientation inside this section
;                               #HORIZONTAL: width: short side, height: long side
;                               #VERTICAL:   width: long side, height: short side
;                               #INHERIT:    use the orientation specified with VecVi::Create()
;               piNumbering   - (S: 0) page numbering mode
;                               -1: no page numbering
;                                0: resume page numbering from previous section
;                               >0: start value for page numbering in this section
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------

  AddElement(*psV\Sections())
  With *psV\Sections()
    \iNr = *psV\iNrSections + 1
  
    ; //
    ; margin
    ; //
    \Margin = *psV\Margin
    
    ; //
    ; page numbering
    ; //
    \iNb = piNumbering
    If \iNb > 0
      \iNbStartValue = piNumbering
    EndIf

    ; //
    ; header, footer
    ; //
    _calcBlockWidth(*psV\Header\Block)
    _calcBlockWidth(*psV\Footer\Block)
    _calcBlockHeight(*psV\Header\Block)
    _calcBlockHeight(*psV\Footer\Block)
    \Header\Margin = *psV\Header\Margin
    \Footer\Margin = *psV\Footer\Margin
    \Header\Block\Size = *psV\Header\Block\Size
    \Footer\Block\Size = *psV\Footer\Block\Size
    CopyList(*psV\Header\Block\Elements(), \Header\Block\Elements())
    CopyList(*psV\Footer\Block\Elements(), \Footer\Block\Elements())

    ; //
    ; format
    ; //
    If pzFormat <> #FORMAT_INHERIT Or piOrientation <> #INHERIT
      If pzFormat = #FORMAT_INHERIT
        pzFormat = *psV\s("Format")
      EndIf
      If piOrientation = #INHERIT
        piOrientation = *psV\i("Orientation")
      EndIf
      
      \iOrientation = piOrientation
      \zFormat       = pzFormat
      
      If piOrientation = #VERTICAL
        \Size\dWidth  = ValD(StringField(pzFormat, 1, ","))
        \Size\dHeight = ValD(StringField(pzFormat, 2, ","))
      ElseIf piOrientation = #HORIZONTAL
        \Size\dWidth  = ValD(StringField(pzFormat, 2, ","))
        \Size\dHeight = ValD(StringField(pzFormat, 1, ","))
      EndIf
    Else
      \iOrientation = *psV\i("Orientation")
      \zFormat      = *psV\s("Format") 
      \Size         = *psV\Size
    EndIf
    
    ; //
    ; set drawing position
    ; //
    \DrawPos = *psV\CurrGlobPos
    
    ; //
    ; set x position back to the left page margin
    ; set y position back to the top page margin as
    ; the user coordinates start again
    ; //
    dOldPagePos = *psV\CurrPagePos\dX
    *psV\CurrPagePos\dX = \Margin\dLeft
    *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)
    
    *psV\CurrPagePos\dY = _calcPageHeight(*psV, #TOP, 1)
    
  EndWith
  
  *psV\iNrSections + 1
  
EndProcedure

Procedure BeginBlock(*psV.VECVI, piPageBreak.i = #True)
; ----------------------------------------
; public     :: starts a new element block on the current section.
; param      :: *psV        - VecVi structure
;               piPageBreak - (S: #True) wheter to accept page breaks within this block
;                             #True:  accept page breaks
;                             #False: disallow page breaks
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------  
  
  *psV\iDefTarget = 0
  AddElement(*psV\Sections()\Blocks())
  
  ; //
  ; pagebreak setting
  ; //
  *psV\Sections()\Blocks()\iPageBreak = piPageBreak
  
  ; //
  ; reset x coordinates to left page margin as blocks always
  ; start on the left side of any page
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  *psV\CurrPagePos\dX = *psV\Sections()\Margin\dLeft
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)
  
  *psV\Sections()\Blocks()\DrawPos = *psV\CurrGlobPos
  
EndProcedure

Procedure BeginHeader(*psV.VECVI)
; ----------------------------------------
; public     :: begins the definition of the header block for the current and the following sections.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: The header has to be defined before the first section is created.
;               Once defined, it will be used for every page until the header is redefined.
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------
  
  *psV\iDefTarget = 1
  
  ; //
  ; reset the header block
  ; //
  ClearList(*psV\Header\Block\Elements())

  ; //
  ; reset x coordinates to left page margin as headers always
  ; start on the left side of any page
  ; //
  dOldPagePos = *psV\CurrPagePos\dX
  *psV\CurrPagePos\dX = *psV\Margin\dLeft
  *psV\CurrGlobPos\dX + (*psV\CurrPagePos\dX - dOldPagePos)
  
  ; //
  ; reset y page coordinates to top page margin as headers always
  ; start on the top of any page
  ; //
  dOldPagePos = *psV\CurrPagePos\dY
  *psV\CurrPagePos\dY = *psV\Margin\dTop
  *psV\CurrGlobPos\dY + (*psV\CurrPagePos\dY - dOldPagePos)
  
  ; //
  ; set header block positions
  ; //
  *psV\Header\Block\DrawPos = *psV\CurrGlobPos
  *psV\Header\Block\PagePos = *psV\CurrPagePos
  
EndProcedure

Procedure BeginFooter(*psV.VECVI)
; ----------------------------------------
; public     :: begins the definition of the footer block for the current and the following sections.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: The footer has to be defined before the first page is finished.
;               Once defined, it will be used for every page until the footer is redefined.
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------
  
  *psV\iDefTarget = 2

  ; //
  ; reset the footer block
  ; //
  ClearList(*psV\Footer\Block\Elements())

  ; //
  ; reset x coordinates to left page margin as footers always
  ; start on the left side of any page
  ; //
  dOldPagePos = *psV\CurrGlobPos\dX
  *psV\CurrGlobPos\dX = *psV\Margin\dLeft
  *psV\CurrPagePos\dX + (*psV\CurrGlobPos\dX - dOldPagePos)
  
  ; //
  ; set footer block positions
  ; //
  *psV\Footer\Block\DrawPos = *psV\CurrGlobPos
  *psV\Footer\Block\PagePos = *psV\CurrPagePos

EndProcedure

;- >>> get/set <<<

Procedure.i GetFillColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the color that is used for filling cells.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\i("FillColor")
  
EndProcedure

Procedure SetFillColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: gets the color that is used for filling cells.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
;                         if -1, reset color to white
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piColor = -1
    *psV\i("FillColor") = $FFFFFFFF
  Else
    *psV\i("FillColor") = piColor
  EndIf
  
EndProcedure

Procedure.i GetTextColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current font color.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\i("TextColor")
  
EndProcedure

Procedure SetTextColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: sets the current font color.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
;                         if -1, reset color to black
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piColor = -1
    *psV\i("TextColor") = $FF000000
  Else
    *psV\i("TextColor") = piColor
  EndIf
  
EndProcedure

Procedure.i GetBackColor(*psV.VECVI, piDeskColor.i = #False)
; ----------------------------------------
; public     :: gets the color that is used as page background.
; param      :: *psV        - VecVi structure
;               piDeskColor - (S: #False) if #True, returns the color of the 'desk' in
;                             multi page outputs (standard: grey)
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  If piDeskColor = #False
    ProcedureReturn *psV\i("BackColor")
  Else
    ProcedureReturn *psV\i("DeskColor")
  EndIf
  
EndProcedure

Procedure SetBackColor(*psV.VECVI, piColor.i, piDeskColor.i = #False)
; ----------------------------------------
; public     :: sets the color that is used as page background.
; param      :: *psV        - VecVi structure
;               piColor     - color value, see RGBA()
;                             if -1, set color to the defaults
;               piDeskColor - (S: #False) if #True, sets the color of the 'desk' in
;                             multi page outputs (standard: grey)

; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piDeskColor = #False
    If piColor = -1
      *psV\i("BackColor") = $FFFFFFFF
    Else
      *psV\i("BackColor") = piColor
    EndIf
  Else
    If piColor = -1
      *psV\i("DeskColor") = $FF7D7D7D
    Else
      *psV\i("DeskColor") = piColor
    EndIf  
  EndIf
  
EndProcedure

Procedure.i GetLineColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the color that is used for lines and borders.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\i("LineColor")
  
EndProcedure

Procedure SetLineColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: sets the color that is used for lines and borders.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
;                         if -1, reset color to black
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piColor = -1
    *psV\i("LineColor") = $FF000000
  Else
    *psV\i("LineColor") = piColor
  EndIf
  
EndProcedure

Procedure.d GetLineSize(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current width of lines and borders.
; param      :: *psV - VecVi structure
; returns    :: (d) border/line size/width
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\d("LineSize")
  
EndProcedure

Procedure SetLineSize(*psV.VECVI, pdSize.d)
; ----------------------------------------
; public     :: sets the current width of lines and borders
; param      :: *psV   - VecVi structure
;               pdSize - border/line size/width
;                        if -1, reset size to 0.2 mm
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If pdSize = -1
    *psV\d("LineSize") = 0.2
  Else
    *psV\d("LineSize") = pdSize
  EndIf
  
EndProcedure

Procedure.d GetLineStyle(*psV.VECVI, piGetLength = #False)
; ----------------------------------------
; public     :: gets the current style of lines and borders.
; param      :: *psV        - VecVi structure
;               piGetLenght - (S: #False) wheter to get the break length
; returns    :: (d) border/line style or length
; remarks    :: take care of the return value type (double) instead of (expected) integer when
;               piGetLength = #False
; ----------------------------------------
  
  If piGetLength = #False
    ProcedureReturn *psV\i("LineStyle")
  Else
    ProcedureReturn *psV\d("LineLen")
  EndIf
  
EndProcedure

Procedure SetLineStyle(*psV.VECVI, piStyle.i = -1, pdLength.d = -1)
; ----------------------------------------
; public     :: sets the current style of lines and borders
; param      :: *psV     - VecVi structure
;               piStyle  - (S: -1) border/line style
;                          if -1, the style is kept unchanged
;                          if -2, reset style to #LINESTYLE_STROKE
;               piLength - (S: -1) length of the breaks in the line
;                          only used if piStyle & #LINESTYLE_DOT or #LINESTYLE_DASH
;                          if -1, the length is kept unchanged
;                          if -2, reset length to 1
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piStyle > -1
    *psV\i("LineStyle") = piStyle
  ElseIf piStyle = -2
    *psV\i("LineStyle") = #LINESTYLE_STROKE
  EndIf
  If pdLength > -1
    *psV\d("LineLen") = pdLength
  ElseIf pdLength = -2
    *psV\d("LineLen") = 1
  EndIf
  
EndProcedure

Procedure.d GetMargin(*psV.VECVI, piMargin.i, piArea.i = #AREA_SECTION, piDefault.i = #False)
; ----------------------------------------
; public     :: gets VecVi's margin values of the specified area.
; param      :: *psV      - VecVi structure
;               piMargin  - which margin to get
;                           #BOTTOM: get bottom margin
;                           #LEFT:   get left margin
;                           #RIGHT:  get right margin
;                           #TOP:    get top margin
;               piArea    - (S: #AREA_SECTION) margin area
;                           #AREA_SECTION: section margins, the outermost margins of every section
;                           #AREA_HEADER:  header margins, only top/bottom margins are supported
;                           #AREA_FOOTER:  footer margins, only top/bottom margins are supported
;                           #AREA_CELL:    inner cell margins
;               piDefault - (S: #False) which margin types to get, supported for sections, header and footer
;                           #True:  get the default area margins
;                           #False: get the margins of the current area
; returns    :: (d) margin value
; remarks    :: 
; ----------------------------------------
  Protected *Margin.VECVI_MARGIN
; ----------------------------------------
  
  If piArea = #AREA_SECTION
    If piDefault = #False
      *Margin = @*psV\Sections()\Margin
    Else
      *Margin = @*psV\Margin
    EndIf
  ElseIf piArea = #AREA_HEADER
    If piDefault = #False
      *Margin = @*psV\Sections()\Header\Margin
    Else
      *Margin = @*psV\Header\Margin
    EndIf
  ElseIf piArea = #AREA_FOOTER
    If piDefault = #False
      *Margin = @*psV\Sections()\Footer\Margin
    Else
      *Margin = @*psV\Footer\Margin
    EndIf
  ElseIf piArea = #AREA_CELL
    *Margin = @*psV\CellMargin
  EndIf
  
  If piMargin = #BOTTOM
    ProcedureReturn *Margin\dBottom
  ElseIf piMargin = #LEFT
    ProcedureReturn *Margin\dLeft
  ElseIf piMargin = #RIGHT
    ProcedureReturn *Margin\dRight  
  ElseIf piMargin = #TOP
    ProcedureReturn *Margin\dTop  
  EndIf
  
EndProcedure

Procedure SetMargin(*psV.VECVI, piMargin.i, pdValue.d, piArea.i = #AREA_SECTION, piDefault.i = #False)
; ----------------------------------------
; public     :: sets VecVi's margin values of the specified area.
; param      :: *psV      - VecVi structure
;               piMargin  - which margin to set
;                           #BOTTOM: set bottom margin
;                           #LEFT:   set left margin
;                           #RIGHT:  set right margin
;                           #TOP:    set top margin
;               pdValue   - margin value to set for the area
;               piArea    - (S: #AREA_SECTION) margin area
;                           #AREA_SECTION: section margins, the outermost margins of every section
;                           #AREA_HEADER:  header margins, only top/bottom margins are supported
;                           #AREA_FOOTER:  footer margins, only top/bottom margins are supported
;                           #AREA_CELL:    inner cell margins
;               piDefault - (S: #False) which margin types to set, supported for sections, header and footer
;                           #True:  set the default area margins
;                           #False: set the margins of the current area
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Margin.VECVI_MARGIN
; ----------------------------------------
  
  If piArea = #AREA_SECTION
    If piDefault = #False
      *Margin = @*psV\Sections()\Margin
    Else
      *Margin = @*psV\Margin
    EndIf
  ElseIf piArea = #AREA_HEADER
    If piDefault = #False
      *Margin = @*psV\Sections()\Header\Margin
    Else
      *Margin = @*psV\Header\Margin
    EndIf
  ElseIf piArea = #AREA_FOOTER
    If piDefault = #False
      *Margin = @*psV\Sections()\Footer\Margin
    Else
      *Margin = @*psV\Footer\Margin
    EndIf
  ElseIf piArea = #AREA_CELL
    *Margin = @*psV\CellMargin
  EndIf
  
  If piMargin = #BOTTOM
    *Margin\dBottom = pdValue
  ElseIf piMargin = #LEFT
    *Margin\dLeft = pdValue
  ElseIf piMargin = #RIGHT
    *Margin\dRight = pdValue
  ElseIf piMargin = #TOP
    *Margin\dTop = pdValue
  EndIf
  
EndProcedure

Procedure.d GetXPos(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current x position on the output
; param      :: *psV - VecVi structure
; returns    :: (d) x position
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\CurrPagePos\dX
  
EndProcedure

Procedure SetXPos(*psV.VECVI, pdX.d, piRelative = #False)
; ----------------------------------------
; public     :: sets the current x position on the output
; param      :: *psV       - VecVi structure
;               pdX        - new x position
;               piRelative - (S: #False) method to move the x position
;                            #False: absolute positioning
;                            #True:  relative positioning to the current x position
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_X
    \d("X")   = pdX
    \i("Rel") = piRelative
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure.d GetYPos(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current y position on the output
; param      :: *psV - VecVi structure
; returns    :: (d) y position
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\CurrPagePos\dY
  
EndProcedure

Procedure SetYPos(*psV.VECVI, pdY.d, piRelative = #False)
; ----------------------------------------
; public     :: sets the current y position on the output
; param      :: *psV       - VecVi structure
;               pdY        - new y position
;               piRelative - (S: #False) method to move the y position
;                            #False: absolute positioning
;                            #True:  relative positioning to the current y position
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_Y
    \d("Y")   = pdY
    \i("Rel") = piRelative
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure.d GetPageWidth(*psV.VECVI, piSection.i = 0, piNet = #True)
; ----------------------------------------
; public     :: gets the width of the specified page
; param      :: *psV      - VecVi structure
;               piSection - (S: 0) section to get the page width for
;                           0: return the width for the current section's pages
;                           otherwise get the width of the specified section's pages
;               piNet     - (S: #True) wheter to get the net page width
;                           #True:  get the net page width (without margins)
;                           #False: get the full page width
; returns    :: (d) page width
; remarks    :: 
; ----------------------------------------
  
  If piNet = #True
    piNet = #LEFT | #RIGHT
  EndIf
  
  If piSection = 0
    ProcedureReturn _calcPageWidth(*psV, piNet)
  Else
    PushListPosition(*psV\Sections())
    ForEach *psV\Sections()
      If *psV\Sections()\iNr = piSection
        ProcedureReturn _calcPageWidth(*psV, piNet)
      EndIf
    Next
    PopListPosition(*psV\Sections())
  EndIf
  
EndProcedure

Procedure.d GetPageHeight(*psV.VECVI, piSection.i = 0, piNet = #True)
; ----------------------------------------
; public     :: gets the height of the specified page
; param      :: *psV      - VecVi structure
;               piSection - (S: 0) section to get the page height for
;                           0: return the height for the current section's pages
;                           otherwise get the height of the specified section's pages
;               piNet     - (S: #True) wheter to get the net page height
;                           #True:  get the net page height (without margins)
;                           #False: get the full page height
; returns    :: (d) page height
; remarks    :: 
; ----------------------------------------

  If piNet = #True
    piNet = #TOP | #BOTTOM
  EndIf

  If piSection = 0
    ProcedureReturn _calcPageHeight(*psV, piNet)
  Else
    PushListPosition(*psV\Sections())
    ForEach *psV\Sections()
      If *psV\Sections()\iNr = piSection
        ProcedureReturn _calcPageHeight(*psV, piNet)
      EndIf
    Next
    PopListPosition(*psV\Sections())
  EndIf
  
EndProcedure

Procedure.d GetOutputScale(*psV.VECVI, piAxis.i)
; ----------------------------------------
; public     :: gets the scale factor to use for the outputs
; param      :: *psV   - VecVi structure
;               piAxis - direction to get the scale for
;                        0: x axis
;                        1: y axis
; returns    :: (d) scale factor
; remarks    :: 
; ----------------------------------------

  If piAxis = 0
    ProcedureReturn *psV\d("ScaleX")
  ElseIf piAxis = 1
    ProcedureReturn *psV\d("ScaleY")
  EndIf
  
EndProcedure

Procedure SetOutputScale(*psV.VECVI, pdX.d = 1, pdY.d = 1)
; ----------------------------------------
; public     :: sets the scale factor to use for the following outputs
; param      :: *psV - VecVi structure
;               pdX  - (S: 1) scale to set for the x direction, see ScaleCoordinates()
;               pdY  - (S: 1) scale to set for the y direction, see ScaleCoordinates()
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  *psV\d("ScaleX") = pdX
  *psV\d("ScaleY") = pdY
  
EndProcedure

Procedure.d GetOutputOffset(*psV.VECVI, piOffset.i)
; ----------------------------------------
; public     :: gets the current output offset
; param      :: *psV     - VecVi structure
;               piOffset - which offset to get
;                          #TOP:  return top offset
;                          #LEFT: return left offset
; returns    :: (d) value of the specified offset
; remarks    :: 
; ----------------------------------------
  
  If piOffset = #TOP
    ProcedureReturn *psV\d("OutputOffsetTop")
  ElseIf piOffset = #LEFT
    ProcedureReturn *psV\d("OutputOffsetLeft")
  EndIf
  
EndProcedure

Procedure SetOutputOffset(*psV.VECVI, piOffset.i, pdValue.d)
; ----------------------------------------
; public     :: sets the current output offset
; param      :: *psV     - VecVi structure
;               piOffset - which offset to change
;                          #TOP:  set top offset
;                          #LEFT: set left offset
;               pdValue  - value of the specified offset
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; prevent from trying to draw on strange values
  ; //
  If IsNAN(pdValue)
    pdValue = 0
  EndIf
  
  If piOffset = #TOP
    *psV\d("OutputOffsetTop") = pdValue
  ElseIf piOffset = #LEFT
    *psV\d("OutputOffsetLeft") = pdValue
  EndIf
  
EndProcedure

Procedure.i GetMultiPageOutput(*psV.VECVI)
; ----------------------------------------
; public     :: gets the output mode for single page output channels
; param      :: *psV - VecVi structure
; returns    :: (i) output mode
; remarks    :: 
; ----------------------------------------

  ProcedureReturn *psV\i("MultiPageOutput")

EndProcedure

Procedure SetMultiPageOutput(*psV.VECVI, piOutput.i, pdMargin.d = 0)
; ----------------------------------------
; public     :: sets the output mode for single page output channels
; param      :: *psV     - VecVi structure
;               piOutput - new output mode
;                          #False:      output only the page given in Output*()
;                          #VERTICAL:   output all pages in vertical order
;                          #HORIZONTAL: output all pages in horizontal order
;               pdMargin - (S: 0) which margin to use between the pages
;                          only used if piOutput > 0
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  If piOutput = #False
    If *psV\i("MultiPageOutput") = #VERTICAL
      *psV\d("OutputOffsetTop") = 0.0
    ElseIf *psV\i("MultiPageOutput") = #HORIZONTAL
      *psV\d("OutputOffsetLeft") = 0.0
    EndIf
  EndIf
  
  If piOutput = #VERTICAL
    *psV\iDrawMode = #DRAW_MULTIV
  ElseIf piOutput = #HORIZONTAL
    *psV\iDrawMode = #DRAW_MULTIH
  ElseIf piOutput = #False
    *psV\iDrawMode = #DRAW_SINGLE
  EndIf

  *psV\i("MultiPageOutput")       = piOutput
  *psV\d("MultiPageOutputMargin") = pdMargin
  *psV\i("NoReprocessing")        = 0
  
EndProcedure

Procedure SetFont(*psV.VECVI, pzName.s, piStyle.i = 0, pdSize.d = 0)
; ----------------------------------------
; public     :: sets the currently used font for text elements.
; param      :: *psV    - VecVi structure
;               pzName  - name of the font
;               piStyle - (S: 0) font styles, PB constants are accepted, see LoadFont()
;               pdSize  - (S: 0) font size (millimeters)
; returns    :: (nothing)
; remarks    :: every font+style is saved in *psV\Fonts() and recalled if necessary
; ----------------------------------------
  
  ; //
  ; change font size
  ; //
  If pdSize > 0
    *psV\d("FontSize") = pdSize
  EndIf
  
  ; //
  ; search for current font in the list of previous used fonts
  ; //
  ForEach *psV\Fonts()
    If *psV\Fonts()\zName = pzName And *psV\Fonts()\iStyle = piStyle 
      *psV\i("CurrentFont") = *psV\Fonts()\iHandle
      ProcedureReturn 
    EndIf
  Next
  
  ; //
  ; if newly used font, create entry for it and load it
  ; //
  AddElement(*psV\Fonts())
  *psV\Fonts()\iHandle = LoadFont(#PB_Any, pzName, 1, piStyle)
  *psV\Fonts()\zName   = pzName
  *psV\Fonts()\iStyle  = piStyle
  *psV\i("CurrentFont") = *psV\Fonts()\iHandle
  
EndProcedure

Procedure.d GetFontSize(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current font size.
; param      :: *psV - VecVi structure
; returns    :: (d) font size
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\d("FontSize")
  
EndProcedure

Procedure SetFontSize(*psV.VECVI, pdSize.d)
; ----------------------------------------
; public     :: sets the current font size.
; param      :: *psV   - VecVi structure
;               pdSize - new font size
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\d("FontSize") = pdSize
  
EndProcedure

Procedure.i GetFontStyle(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current font style
; param      :: *psV - VecVi structure
; returns    :: (i) font style, see SetFont()
;               if no current font is set, returns -1
; remarks    :: 
; ----------------------------------------
  
  ForEach *psV\Fonts()
    If *psV\Fonts()\iHandle = *psV\i("CurrentFont")
      ProcedureReturn *psV\Fonts()\iStyle
    EndIf
  Next
  
  ProcedureReturn -1
  
EndProcedure

Procedure.i SetFontStyle(*psV.VECVI, piStyle.i)
; ----------------------------------------
; public     :: sets the style of the currently used font family
; param      :: *psV    - VecVi structure
;               piStyle - new font style, see SetFont()
; returns    :: 0: error while setting font style
;               1: success
; remarks    :: invokes SetFont()
; ----------------------------------------
  Protected.i iFound
; ----------------------------------------
  
  ForEach *psV\Fonts()
    If *psV\Fonts()\iHandle = *psV\i("CurrentFont")
      iFound = 1
      Break
    EndIf
  Next
  
  If iFound = 1
    SetFont(*psV, *psV\Fonts()\zName, piStyle, *psV\d("FontSize"))
  EndIf
  
  ProcedureReturn iFound
  
EndProcedure

Procedure.i GetSectionCount(*psV.VECVI)
; ----------------------------------------
; public     :: returns the number of sections in the current output
; param      :: *psV     - VecVi structure
; returns    :: (i) number of sections
; remarks    :: 
; ----------------------------------------

  ProcedureReturn *psV\iNrSections
  
EndProcedure

Procedure.i GetPageCount(*psV.VECVI, piSection.i = 0)
; ----------------------------------------
; public     :: returns the number of pages in the current output.
; param      :: *psV      - VecVi structure
;               piSection - (S: 0) get the page count for the specified section only
;                           if 0, return for all sections, otherwise range: 1 - ...
; returns    :: (i) number of pages
; remarks    :: 
; ----------------------------------------
  Protected.i iCnt
; ----------------------------------------
  
  If piSection = 0
    ProcedureReturn *psV\iNrPages
  Else
    PushListPosition(*psV\Sections())
    ForEach *psV\Sections()
      If *psV\Sections()\iNr = piSection
        iCnt = *psV\Sections()\iNrPages
        Break
      EndIf
    Next
    PopListPosition(*psV\Sections())
  EndIf
  
  ProcedureReturn iCnt
  
EndProcedure

Procedure.d GetPageStartOffset(*psV.VECVI, piPage)
; ----------------------------------------
; public     :: calculates the offset which will display the given page on the beginning of the output.
; param      :: *psV     - VecVi structure
;               piPage   - page to get the offset for
; returns    :: (d) page offset
; remarks    :: only useful with MultiPageOutput > 0
; ----------------------------------------
  Protected.d dOffset
; ----------------------------------------
  
  dOffset = 0
  
  PushListPosition(*psV\Sections())
  ForEach *psV\Sections()
    PushListPosition(*psV\Sections()\Pages())
    ForEach *psV\Sections()\Pages()
      If *psV\Sections()\Pages()\iNr = piPage
      
        If *psV\i("MultiPageOutput") = #HORIZONTAL
          dOffset = *psV\Sections()\Pages()\DrawPos\dX
        ElseIf *psV\i("MultiPageOutput") = #VERTICAL
          dOffset = *psV\Sections()\Pages()\DrawPos\dY
        EndIf
        Break
        
      EndIf
    Next 
    PopListPosition(*psV\Sections()\Pages())
    
    If dOffset > 0
      Break
    EndIf
  Next
  PopListPosition(*psV\Sections())
    
  ProcedureReturn -dOffset

EndProcedure

Procedure.d GetOutputSize(*psV.VECVI, piOrientation.i)
; ----------------------------------------
; public     :: calculates the full size of the output
; param      :: *psV          - VecVi structure
;               piOrientation - which size to get
;                               #HORIZONTAL: get the horizontal size
;                               #VERTICAL:   get the vertical size
; returns    :: (d) full size
; remarks    :: 
; ----------------------------------------
  Protected.i i
  Protected.d dSize,
              dMax
; ----------------------------------------

  If piOrientation = #VERTICAL
    If *psV\i("MultiPageOutput") = #VERTICAL
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        dSize + *psV\Sections()\iNrPages * (*psV\Sections()\Size\dHeight + *psV\d("MultiPageOutputMargin")) - *psV\d("MultiPageOutputMargin")
      Next
      PopListPosition(*psV\Sections())
    Else
      dMax = 0
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        If *psV\Sections()\Size\dHeight > dMax
          dMax = *psV\Sections()\Size\dHeight
        EndIf
      Next
      PopListPosition(*psV\Sections())
      dSize + dMax
    EndIf
  ElseIf piOrientation = #HORIZONTAL
    If *psV\i("MultiPageOutput") = #HORIZONTAL
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        dSize + *psV\Sections()\iNrPages * (*psV\Sections()\Size\dWidth + *psV\d("MultiPageOutputMargin")) - *psV\d("MultiPageOutputMargin")
      Next
      PopListPosition(*psV\Sections())
    Else
      dMax = 0
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        If *psV\Sections()\Size\dWidth > dMax
          dMax = *psV\Sections()\Size\dWidth
        EndIf
      Next
      PopListPosition(*psV\Sections())
      dSize + dMax
    EndIf
  EndIf
  
  ProcedureReturn dSize
  
EndProcedure

Procedure.d GetCanvasOutputResolution(piCanvas.i)
; ----------------------------------------
; public     :: calculates the resolution for outputs on CanvasGadgets
; param      :: piCanvas - CanvasGadget ID
; returns    :: (d) resolution in dpi
; remarks    :: useful to control the display of the output (e.g. print preview)
; ----------------------------------------
  Protected.d dRes
; ----------------------------------------
  
  StartVectorDrawing(CanvasVectorOutput(piCanvas, #PB_Unit_Millimeter))
  dRes = VectorResolutionX()
  StopVectorDrawing()
  
  ProcedureReturn dRes
  
EndProcedure

Procedure.d GetTextWidth(*psV.VECVI, pzText.s)
; ----------------------------------------
; public     :: calculates the needed width of the given text in the current font.
; param      :: *psV   - VecVi structure
;               pzText - text to calculate the width
; returns    :: (d) needed text width
; remarks    :: 
; ----------------------------------------
  Protected.i iImage
  Protected.d dWidth
; ----------------------------------------
  
  iImage = CreateImage(#PB_Any, 1, 1)
  If Not IsImage(iImage)
    ProcedureReturn 0
  EndIf
  
  If StartVectorDrawing(ImageVectorOutput(iImage, #PB_Unit_Millimeter))
    VectorFont(FontID(*psV\i("CurrentFont")), Round(*psV\d("FontSize") * 2.83465, #PB_Round_Nearest) / 2.83465)
    dWidth = VectorTextWidth(pzText, #PB_VectorText_Visible)
    StopVectorDrawing()
  EndIf
  
  FreeImage(iImage)
  
  ProcedureReturn dWidth
  
EndProcedure

Procedure SetPageNumberingTokens(*psV.VECVI, pzCurrent.s = "", pzTotal.s = "")
; ----------------------------------------
; public     :: sets the tokens which are replaced by the page numbering.
; param      :: *psV      - VecVi structure
;               pzCurrent - (S: '') changes the token for the current page number
;                           if empty, it's kept unchanged
;               pzTotal   - (S: '') changes the token for the total number of pages
;                           if empty, it's kept unchanged
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  If pzCurrent <> ""
    *psV\s("NbCurrent") = pzCurrent
  EndIf
  If pzTotal <> ""
    *psV\s("NbTotal") = pzTotal
  EndIf
  
EndProcedure

;- >>> graphical elements <<<

Procedure TextCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new text cell on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the cell
;                          if 0, the cell starts at the current x position and ends at the right page margin
;               pdH      - height of the cell
;               pzText   - cell text (only one line)
;               piLn     - (S: #RIGHT) where to set the position after the cell
;                          #RIGHT:   x to the right border of the cell, y keeps unchanged
;                          #BOTTOM:  y to the bottom border of the cell, x keeps unchanged
;                          #NEWLINE: y to the bottom border of the cell, x to the left margin
;               piBorder - (S: #False) which borders to show around the cell
;                          #False:  show no borders
;                          #LEFT:   show the left border
;                          #RIGHT:  show the right border
;                          #TOP:    show the top border
;                          #BOTTOM: show the bottom border
;                          #ALL:    show all borders
;                          all borders are combineable. one half of each border width (see VecVi::SetLineSize())
;                          is placed inside and outside the cell.
;               piHAlign - (S: #LEFT) horizontal alignment of the text. The cell sizes keep unchanged.
;                          #LEFT:   left horizontal align
;                          #RIGHT:  right horizontal align
;                          #CENTER: central horizontal align
;               piVAlign - (S: #CENTER) vertical alignment of the text. The cell sizes keep unchanged.
;                          #TOP:    top vertical align
;                          #BOTTOM: bottom vertical align
;                          #CENTER: central vertical align
;               piFill   - (S: #False) wheter to fill the cell background with a color.
;                          #True:  fill the cell background (see VecVi::SetFillColor())
;                          #False: no fill, use the color of the background of the output
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_TEXTCELL
    \d("W")          = pdW
    \d("H")          = pdH
    \s("TextRaw")    = pzText
    \i("Ln")         = piLn
    \i("Border")     = piBorder
    \i("HAlign")     = piHAlign
    \i("VAlign")     = piVAlign
    \i("Fill")       = piFill
    \i("FillColor")  = *psV\i("FillColor")
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    \i("TextColor")  = *psV\i("TextColor")
    \i("Font")       = *psV\i("CurrentFont")
    \d("FontSize")   = *psV\d("FontSize")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure ParagraphCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new paragraph cell on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the cell
;                          if 0, the cell starts at the current x position and ends at the right page margin
;               pdH      - height of the cell
;                          if 0, the cell is expanded in y direction to fit the specified text in the current font
;               pzText   - cell text (multiline support)
;               piLn     - (S: #RIGHT) where to set the position after the cell
;                          #RIGHT:   x to the right border of the cell, y keeps unchanged
;                          #BOTTOM:  y to the bottom border of the cell, x keeps unchanged
;                          #NEWLINE: y to the bottom border of the cell, x to the left margin
;               piBorder - (S: #False) which borders to show around the cell
;                          #False:  show no borders
;                          #LEFT:   show the left border
;                          #RIGHT:  show the right border
;                          #TOP:    show the top border
;                          #BOTTOM: show the bottom border
;                          #ALL:    show all borders
;                          all borders are combineable. one half of each border width (see VecVi::SetLineSize())
;                          is placed inside and outside the cell.
;               piHAlign - (S: #LEFT) horizontal alignment of the text. The cell sizes keep unchanged.
;                          #LEFT:   left horizontal align
;                          #RIGHT:  right horizontal align
;                          #CENTER: central horizontal align
;               piFill   - (S: #False) wheter to fill the cell background with a color.
;                          #True:  fill the cell background (see VecVi::SetFillColor())
;                          #False: no fill, use the color of the background of the output
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iImage
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_PARACELL
    \d("W")          = pdW
    \d("H")          = pdH
    \s("TextRaw")    = pzText
    \i("Ln")         = piLn
    \i("Border")     = piBorder
    \i("HAlign")     = piHAlign
    \i("Fill")       = piFill
    \i("FillColor")  = *psV\i("FillColor")
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    \i("TextColor")  = *psV\i("TextColor")
    \i("Font")       = *psV\i("CurrentFont")
    \d("FontSize")   = *psV\d("FontSize")
    
    ; //
    ; variable height of paragraph cells: try to calculate the needed height before
    ; the original drawing
    ; //
    If pdH = 0
      If pdW = 0
        \d("W") = _calcPageWidth(*psV, #RIGHT) - *psV\CurrPagePos\dX
      EndIf
      
      iImage = CreateImage(#PB_Any, 1, 1)
      StartVectorDrawing(ImageVectorOutput(iImage, #PB_Unit_Millimeter))
      VectorFont(FontID(\i("Font")), \d("FontSize"))
      \d("H") = VectorParagraphHeight(\s("TextRaw"), \d("W"), 1e6) + *psV\CellMargin\dBottom + *psV\CellMargin\dTop
      StopVectorDrawing()
      FreeImage(iImage)
    EndIf

    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure ImageCell(*psV.VECVI, pdW.d, pdH.d, pdImageW.d, pdImageH.d, piImage.i, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new text cell on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the cell
;                          if 0, the cell starts at the current x position and ends at the right page margin
;               pdH      - height of the cell
;               pdImageW - width of the image in the cell
;               pdImageH - height of the image in the cell
;               piImage  - cell image, has to be a PB Image object
;               piLn     - (S: #RIGHT) where to set the position after the cell
;                          #RIGHT:   x to the right border of the cell, y keeps unchanged
;                          #BOTTOM:  y to the bottom border of the cell, x keeps unchanged
;                          #NEWLINE: y to the bottom border of the cell, x to the left margin
;               piBorder - (S: #False) which borders to show around the cell
;                          #False:  show no borders
;                          #LEFT:   show the left border
;                          #RIGHT:  show the right border
;                          #TOP:    show the top border
;                          #BOTTOM: show the bottom border
;                          #ALL:    show all borders
;                          all borders are combineable. one half of each border width (see VecVi::SetLineSize())
;                          is placed inside and outside the cell.
;               piHAlign - (S: #LEFT) horizontal alignment of the image in the cell. The cell sizes keep unchanged.
;                          #LEFT:   left horizontal align
;                          #RIGHT:  right horizontal align
;                          #CENTER: central horizontal align
;               piVAlign - (S: #CENTER) vertical alignment of the image in the cell. The cell sizes keep unchanged.
;                          #TOP:    top vertical align
;                          #BOTTOM: bottom vertical align
;                          #CENTER: central vertical align
;               piFill   - (S: #False) wheter to fill the cell background with a color.
;                          #True:  fill the cell background (see VecVi::SetFillColor())
;                          #False: no fill, use the color of the background of the output
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  ; //
  ; create a copy of the image to allow disallocation
  ; //
  AddElement(*psV\Images())
  *psV\Images()\iHandle = CopyImage(piImage, #PB_Any)
  piImage = *psV\Images()\iHandle
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_IMAGECELL
    \d("W")          = pdW
    \d("H")          = pdH
    \d("ImageW")     = pdImageW
    \d("ImageH")     = pdImageH
    \i("Image")      = piImage
    \i("Ln")         = piLn
    \i("Border")     = piBorder
    \i("HAlign")     = piHAlign
    \i("VAlign")     = piVAlign
    \i("Fill")       = piFill
    \i("FillColor")  = *psV\i("FillColor")
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure HorizontalLine(*psV.VECVI, pdW.d, piHAlign.i = #LEFT)
; ----------------------------------------
; public     :: creates a new horizontal line on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the horizontal line
;                          if 0, the line starts at the current x position and ends at the right page margin
;               piHAlign - (S: #LEFT) horizontal alignment of the line
;                          #LEFT:   left horizontal align
;                          #RIGHT:  right horizontal align
;                          #CENTER: central horizontal align
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_HLINE
    \d("W")          = pdW
    \i("HAlign")     = piHAlign
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure VerticalLine(*psV.VECVI, pdH.d, piVAlign.i = #TOP)
; ----------------------------------------
; public     :: creates a new vertical line on the current block.
; param      :: *psV     - VecVi structure
;               pdH      - width of the vertical line
;                          if 0, the line starts at the current y position and ends at the bottom page margin
;               piHAlign - (S: #TOP) vertical alignment of the line
;                          #TOP:    top vertical align
;                          #BOTTOM: bottom vertical align
;                          #CENTER: central vertical align
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_VLINE
    \d("H")          = pdH
    \i("VAlign")     = piVAlign
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure XYLine(*psV.VECVI, pdDeltaX.d, pdDeltaY.d)
; ----------------------------------------
; public     :: creates a new xy line on the current block.
; param      :: *psV     - VecVi structure
;               pdDeltaX - difference between the current x position and the new x position for the line's endpoint
;               pdDeltaY - difference between the current y position and the new y position for the line's endpoint
; returns    :: (nothing)
; remarks    :: The line always starts at the current xy position, see VecVi::SetXPos() and VecVi::SetYPos()
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_XYLINE
    \d("dX")         = pdDeltaX
    \d("dY")         = pdDeltaY
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure Curve(*psV.VECVI, pdS1X.d, pdS1Y.d, pdS2X.d, pdS2Y.d, pdEndX.d, pdEndY.d)
; ----------------------------------------
; public     :: creates a new curve on the current block.
; param      :: *psV   - VecVi structure
;               pdS1X  - x position of the first control point
;               pdS1Y  - y position of the first control point
;               pdS2X  - x position of the second control point
;               pdS2Y  - y position of the second control point
;               pdEndX - x position of the end point
;               pdEndY - y position of the end point
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_CURVE
    \d("S1X")        = pdS1X
    \d("S1Y")        = pdS1Y
    \d("S2X")        = pdS2X
    \d("S2Y")        = pdS2Y
    \d("EndX")       = pdEndX
    \d("EndY")       = pdEndY
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
  
EndProcedure

Procedure Ln(*psV.VECVI, pdLn.d = -1, piForPbPDF.i = 0)
; ----------------------------------------
; public     :: creates a new line break on the current block.
; param      :: *psV         - VecVi structure
;               pdLn         - (S: -1) the height of the line break
;                              if -1, the height of the last line break will be used
;                              (also if you have used VecVi::TextCell() with #BOTTOM or #NEWLINE)
;                              otherwise, the line break will be as specified in this parameter
;               piForPbPDF   - (S: 0) if 1, use this only for PbPDF outputs
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_LN
    \d("Ln")   = pdLn
    \i("PPDF") = piForPbPDF
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure Sp(*psV.VECVI, pdSp.d = -1)
; ----------------------------------------
; public     :: creates a new space on the current block.
; param      :: *psV - VecVi structure
;               pdSp - (S: -1) the width of the space
;                      if -1, the width of the last space will be used
;                      otherwise, the space will be as specified in this parameter
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_SP
    \d("Sp") = pdSp
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
    
EndProcedure

Procedure Rectangle(*psV.VECVI, pdW.d, pdH.d, piLn.i = #RIGHT, piBorder.i = #False, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new recangle on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the rectangle
;                          if 0, the rectangle starts at the current x position and ends at the right page margin
;               pdH      - height of the rectangle
;                          if 0, the rectangle starts at the current y position and ends at the bottom page margin
;               piLn     - (S: #RIGHT) where to set the position after the rectangle
;                          #RIGHT:   x to the right border of the rectangle, y keeps unchanged
;                          #BOTTOM:  y to the bottom border of the rectangle, x keeps unchanged
;                          #NEWLINE: y to the bottom border of the rectangle, x to the left margin
;               piBorder - (S: #False) which borders to show around the rectangle
;                          #False:  show no borders
;                          #LEFT:   show the left border
;                          #RIGHT:  show the right border
;                          #TOP:    show the top border
;                          #BOTTOM: show the bottom border
;                          #ALL:    show all borders
;                          all borders are combineable. one half of each border width (see VecVi::SetLineSize())
;                          is placed inside and outside the rectangle.
;               piFill   - (S: #False) wheter to fill the rectangle background with a color.
;                          #True:  fill the rectangle background (see VecVi::SetFillColor())
;                          #False: no fill, use the color of the background of the output
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_RECTANGLE
    \d("W")          = pdW
    \d("H")          = pdH
    \i("Ln")         = piLn
    \i("Border")     = piBorder
    \i("Fill")       = piFill
    \i("FillColor")  = *psV\i("FillColor")
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
  
EndProcedure

Procedure Sector(*psV.VECVI, pdW.d, pdH.d, pdStart.d, pdEnd.d, piLn.i = #RIGHT, piBorder.i = #False, piConnect.i = #True, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new ellipse sector on the current block.
; param      :: *psV      - VecVi structure
;               pdW       - width of the ellipse sector
;               pdH       - height of the ellipse sector
;               pdStart   - start angle of the ellipse sector
;                           if 0, sector starts on the positive x axis
;                           bounds: 0...360
;               pdEnd     - end angle of the ellipse sector
;                           if 0, sector ends on the positive x axis
;                           bounds: 0...360
;               piLn      - (S: #RIGHT) where to set the position after the ellipse sector
;                           #RIGHT:   x to the right border of the ellipse sector, y keeps unchanged
;                           #BOTTOM:  y to the bottom border of the ellipse sector, x keeps unchanged
;                           #NEWLINE: y to the bottom border of the ellipse sector, x to the left margin
;               piBorder  - (S: #False) wheter to show borders around the ellipse sector
;                           #True:  show borders
;                           #False: show no borders
;                           one half of each border width (see VecVi::SetLineSize()) is placed inside and outside the sector.
;               piConnect - (S: #True) wheter to connect the sector borders with the midpoint if it's not a full ellipse
;                           #True:  draw a line from the linear sector borders back to the midpoint
;                           #False: keep the ellipse "unclosed"
;                           this is also used for defining the filling borders
;               piFill    - (S: #False) wheter to fill the ellipse sector background with a color.
;                           #True:  fill the ellipse sector background (see VecVi::SetFillColor())
;                           #False: no fill, use the color of the background of the output
; returns    :: (nothing)
; remarks    :: the sector midpoint will be at the half width and half height from the current xy position.
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_SECTOR
    \d("W")          = pdW
    \d("H")          = pdH
    \d("Start")      = pdStart
    \d("End")        = pdEnd
    \i("Ln")         = piLn
    \i("Border")     = piBorder
    \i("Connect")    = piConnect
    \i("Fill")       = piFill
    \i("FillColor")  = *psV\i("FillColor")
    \d("LineSize")   = *psV\d("LineSize")
    \i("LineColor")  = *psV\i("LineColor")
    \i("LineStyle")  = *psV\i("LineStyle")
    \d("LineLen")    = *psV\d("LineLen")
    
    _applyPosition(*psV, *Target, @*Target\Elements())
  EndWith
  
EndProcedure

;- >>> output functions <<<

Procedure OutputCanvas(*psV.VECVI, piGadget.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a canvas gadget.
; param      :: *psV     - VecVi structure
;               piGadget - canvas gadget ID
;               piPage   - page to show on the canvas
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_CANVAS, piGadget, -1, "", piPage)
  
EndProcedure

Procedure OutputCanvasImage(*psV.VECVI, piGadget.i, piImage.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a canvas gadget using an image.
; param      :: *psV     - VecVi structure
;               piGadget - canvas gadget ID
;               piImage  - image ID
;               piPage   - page to show on the canvas
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_CANVASIMAGE, piGadget, piImage, "", piPage)
  
EndProcedure

Procedure OutputImage(*psV.VECVI, piImage.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on an image.
; param      :: *psV     - VecVi structure
;               piGadget - image ID
;               piPage   - page to show on the image
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_IMAGE, piImage, -1, "", piPage)
  
EndProcedure

Procedure OutputWindow(*psV.VECVI, piWindow.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a window.
; param      :: *psV     - VecVi structure
;               piGadget - window ID
;               piPage   - real page to show on the window
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_WINDOW, piWindow, -1, "", piPage)
  
EndProcedure

Procedure OutputPrinter(*psV.VECVI)
; ----------------------------------------
; public     :: outputs VecVi on a printer.
; param      :: *psV       - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_PRINTER, -1, -1, "", 0)
  
EndProcedure

Procedure OutputSVG(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _draw(*psV, #OUTPUT_SVG, -1, -1, pzPath, 0)

EndProcedure

Procedure OutputPDF(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  _draw(*psV, #OUTPUT_PDF, -1, -1, pzPath, 0)

EndProcedure

Procedure OutputPbPDF(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to pbPDF
; param      :: *psV   - VecVi Structure
;               pzPath - full output path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  _draw(*psV, #OUTPUT_PBPDF, -1, -1, pzPath, 0)
  
EndProcedure

EndModule