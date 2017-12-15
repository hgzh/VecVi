; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################

;   written by Andesdaf/hgzh, 2017

;   this module allows you to create documents using the
;   VectorDrawing library of PureBasic and output it to a
;   CanvasGadget, Window, Image object, .svg file (Linux),
;   .pdf file (not Windows) or send it directly to a printer.

; ###########################################################
;                          LICENSING
; Copyright (c) 2017 Andesdaf/hgzh

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
;   v.1.00 (2017-11-17)
;    - first version
;   v.1.01 (2017-11-22)
;    - various bug fixes
;    - added SetOutputScale() / GetOutputScale()
;    - added GetPageWidth() / GetPageHeight()
;   v.1.02 (2017-12-15)
;    - fixed GetXPos() / GetYPos()
;    - merged VECVI_HEADER & VECVI_FOOTER structure
;    - merged position constants (#BORDER_, #ALIGN_, #MARGIN_, #LN_)
;    - added SetLineStyle() / GetLineStyle()
;    - added SetOutputOffset() / GetOutputOffset()
;    - added Rectangle(), Sector(), Curve()
; ###########################################################

EnableExplicit

DeclareModule VecVi

;- >>> enumerations <<<

Enumeration Orientation
  ; ----------------------------------------
  ; public     :: orientation types, used for new pages
  ; ----------------------------------------
  #ORIENTATION_INHERIT
  #ORIENTATION_VERTICAL
  #ORIENTATION_HORIZONTAL
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
  #AREA_PAGE
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

Structure VECVI_MARGINS
  ; ----------------------------------------
  ; public     :: margin attributes
  ; ----------------------------------------
  dTop.d
  dRight.d
  dBottom.d
  dLeft.d
EndStructure

Structure VECVI_SIZES
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

Structure VECVI_ELEMENT
  ; ----------------------------------------
  ; public     :: one element in a block
  ; ----------------------------------------
  iType.i
  Map miVal.i()
  Map msVal.s()
  Map mdVal.d()
EndStructure

Structure VECVI_BLOCK
  ; ----------------------------------------
  ; public     :: one element block
  ; ----------------------------------------
  List Elements.VECVI_ELEMENT()

  iPageBreak.i

  Pos.VECVI_POS
EndStructure

Structure VECVI_HEADFOOT
  ; ----------------------------------------
  ; public     :: page header/footer structure
  ; ----------------------------------------
  Margins.VECVI_MARGINS
  
  Block.VECVI_BLOCK
EndStructure

Structure VECVI_PAGE
  ; ----------------------------------------
  ; public     :: one VecVi page
  ; ----------------------------------------
  List Blocks.VECVI_BLOCK()

  iNr.i
  iNrRealPages.i
  
  iNb.i
  iNbStartValue.i
  
  Sizes.VECVI_SIZES
  Margins.VECVI_MARGINS
  Pos.VECVI_POS
  
  Header.VECVI_HEADFOOT
  Footer.VECVI_HEADFOOT
EndStructure

Structure VECVI
  ; ----------------------------------------
  ; public     :: basic VecVi structure
  ; ----------------------------------------
  List Pages.VECVI_PAGE()
  List Fonts.VECVI_FONT()
  
  iNrPages.i
  iNrRealPages.i
  iOnlyRealPage.i
  
  iDefTarget.i
  iOutput.i

  iNbCurrent.i
  iNbTotal.i
  
  Offsets.VECVI_MARGINS
  Margins.VECVI_MARGINS
  CellMargins.VECVI_MARGINS
  Sizes.VECVI_SIZES
  
  Map miVal.i()
  Map msVal.s()
  Map mdVal.d()
  
  Header.VECVI_HEADFOOT
  Footer.VECVI_HEADFOOT
EndStructure

;- >>> public declaration <<<

  Declare.i Create(pzFormat.s, piOrientation.i)
  Declare   Free(*psV.VECVI)
  Declare   BeginPage(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #ORIENTATION_INHERIT, piNumbering = 0)
  Declare   BeginBlock(*psV.VECVI, piPageBreak.i = #True)
  Declare   BeginHeader(*psV.VECVI)
  Declare   BeginFooter(*psV.VECVI)
  Declare.i GetFillColor(*psV.VECVI)
  Declare   SetFillColor(*psV.VECVI, piColor.i)
  Declare.i GetTextColor(*psV.VECVI)
  Declare   SetTextColor(*psV.VECVI, piColor.i)
  Declare.i GetLineColor(*psV.VECVI)
  Declare   SetLineColor(*psV.VECVI, piColor.i)
  Declare.d GetLineSize(*psV.VECVI)
  Declare   SetLineSize(*psV.VECVI, pdSize.d)
  Declare.d GetLineStyle(*psV.VECVI, piGetLenght.i = #False)
  Declare   SetLineStyle(*psV.VECVI, piStyle.i = -1, pdLenght.d = -1)
  Declare.d GetMargin(*psV.VECVI, piMargin.i, piArea = #AREA_PAGE, piDefault.i = #False)
  Declare   SetMargin(*psV.VECVI, piMargin.i, pdValue.d, piArea = #AREA_PAGE, piDefault.i = #False)
  Declare.d GetXPos(*psV.VECVI)
  Declare   SetXPos(*psV.VECVI, pdX.d, piRelative = #False)
  Declare.d GetYPos(*psV.VECVI)
  Declare   SetYPos(*psV.VECVI, pdY.d, piRelative = #False)
  Declare.d GetPageWidth(*psV.VECVI, piPage.i = 0)
  Declare.d GetPageHeight(*psV.VECVI, piPage.i = 0)
  Declare.d GetOutputScale(*psV.VECVI, piAxis.i)
  Declare   SetOutputScale(*psV.VECVI, pdX.d = 1, pdY.d = 1)
  Declare.d GetOutputOffset(*psV.VECVI, piOffset.i)
  Declare   SetOutputOffset(*psV.VECVI, piOffset.i, pdValue.d)
  Declare   SetFont(*psV.VECVI, pzName.s, piStyle.i = 0, pdSize.d = 0)
  Declare.i GetRealPageCount(*psV.VECVI, piPage.i = 0)
  Declare   SetPageNumberingTokens(*psV.VECVI, pzCurrent.s = "", pzTotal.s = "")
  Declare   TextCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare   ParagraphCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piFill.i = #False)
  Declare   ImageCell(*psV.VECVI, pdW.d, pdH.d, pdImageW.d, pdImageH.d, piImage.i, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare   HorizontalLine(*psV.VECVI, pdW.d, piHAlign.i = #LEFT)
  Declare   VerticalLine(*psV.VECVI, pdH.d, piVAlign.i = #TOP)
  Declare   XYLine(*psV.VECVI, pdDeltaX.d, pdDeltaY.d)
  Declare   Curve(*psV.VECVI, pdS1X.d, pdS1Y.d, pdS2X.d, pdS2Y.d, pdEndX.d, pdEndY.d)
  Declare   Ln(*psV.VECVI, pdLn.d = -1)
  Declare   Sp(*psV.VECVI, pdSp.d = -1)
  Declare   Rectangle(*psV.VECVI, pdW.d, pdH.d, piLn.i = #RIGHT, piBorder.i = #False, piFill.i = #False)
  Declare   Sector(*psV.VECVI, pdW.d, pdH.d, pdStart.d, pdEnd.d, piLn.i = #RIGHT, piBorder.i = #False, piConnect.i = #True, piFill.i = #False)
  Declare   OutputCanvas(*psV.VECVI, piGadget.i, piRealPage.i = 1)
  Declare   OutputImage(*psV.VECVI, piImage.i, piRealPage.i = 1)
  Declare   OutputWindow(*psV.VECVI, piWindow.i, piRealPage.i = 1)
  Declare   OutputPrinter(*psV.VECVI)
  Declare   OutputSVG(*psV.VECVI, pzPath.s)
  Declare   OutputPDF(*psV.VECVI, pzPath.s)

EndDeclareModule

Module VecVi
EnableExplicit

Declare _processNewPage(*psV.VECVI)
Declare _processEndPage(*psV.VECVI)

Enumeration Output
  ; ----------------------------------------
  ; internal   :: possible output types
  ; ----------------------------------------
  #OUTPUT_CANVAS
  #OUTPUT_IMAGE
  #OUTPUT_WINDOW
  #OUTPUT_PRINTER
  #OUTPUT_SVG
  #OUTPUT_PDF
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
    ProcedureReturn @*psV\Pages()\Blocks()
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
    ProcedureReturn @*psV\Pages()\Header\Block
  ElseIf *psV\iDefTarget = 21
    ; //
    ; page footer block
    ; //
    ProcedureReturn @*psV\Pages()\Footer\Block
  EndIf
  
  ProcedureReturn 0
  
EndProcedure

Procedure.d _calcBlockHeight(*psB.VECVI_BLOCK)
; ----------------------------------------
; internal   :: calculates the height of a single block.
; param      :: *psB - VecVi block
; returns    :: (d) block height
; remarks    :: 
; ----------------------------------------
  Protected.d dHeight,
              dMaxHeight
; ----------------------------------------
  
  dMaxHeight = 0
  
  ForEach *psB\Elements()
    With *psB\Elements()
      
      ; //
      ; get the element with the highest sum of y block coordinate and height.
      ; this sum will be the y space needed to display the full block.
      ; //
      dHeight = \mdVal("_BlockY") + \mdVal("_BlockH")
      If dHeight > dMaxHeight
        dMaxHeight = dHeight
      EndIf
    EndWith
  Next
  
  ProcedureReturn dMaxHeight

EndProcedure

Procedure.d _calcPageWidth(*psV.VECVI, piMargins.i = #LEFT | #RIGHT, piPureWidth.i = 0)
; ----------------------------------------
; internal   :: calculates widths of the current page.
; param      :: *psV        - VecVi structure
;               piMargins   - which margins to include in the calculation (combineable)
;                             #LEFT:  subtract the left page margin
;                             #RIGHT: subtract the right page margin
;               piPureWidth - (S: 0) return the pure page width or the width for using with coordinates
;                             0: for coordinates
;                             1: pure width
; returns    :: (d) calculated page width
; remarks    :: 
; ----------------------------------------
  Protected.d dWidth
; ----------------------------------------
  
  If ListIndex(*psV\Pages()) = -1
    dWidth = *psV\Sizes\dWidth
    If piPureWidth = 0
      dWidth + *psV\Offsets\dLeft
    EndIf
    If piMargins & #LEFT
      dWidth - *psV\Margins\dLeft
    EndIf
    If piMargins & #RIGHT
      dWidth - *psV\Margins\dRight
    EndIf
  Else
    dWidth = *psV\Pages()\Sizes\dWidth
    If piPureWidth = 0
      dWidth + *psV\Offsets\dLeft
    EndIf
    If piMargins & #LEFT
      dWidth - *psV\Pages()\Margins\dLeft
    EndIf
    If piMargins & #RIGHT
      dWidth - *psV\Pages()\Margins\dRight
    EndIf
  EndIf
  
  ProcedureReturn dWidth

EndProcedure

Procedure.d _calcPageHeight(*psV.VECVI, piMargins = #TOP | #BOTTOM, piGetMargins.i = 0, piPureHeight.i = 0)
; ----------------------------------------
; internal   :: calculates heights of the current page.
; param      :: *psV         - VecVi structure
;               piMargins    - which margins to include in the calculation (combineable)
;                              #TOP:    subtract the top page margin and header widths/margins
;                              #BOTTOM: subtract the bottom page margin and footer widths/margins
;               piGetMargins - (S: 0) return only the top/bottom margins, not the page height
;                              0: the page height will be returned
;                              1: the margins will be returned
;               piPureHeight - (S: 0) return the pure page height or the height for using with coordinates
;                              0: for coordinates
;                              1: pure height
;                              only supported if piGetMargins = 0
; returns    :: (d) calculated value as specified
; remarks    :: 
; ----------------------------------------
  Protected.d dHeight
; ----------------------------------------
  
  If piGetMargins = 0
    ; //
    ; get page height
    ; //
    dHeight = *psV\Pages()\Sizes\dHeight
    If piPureHeight = 0
      dHeight + *psV\Offsets\dTop
    EndIf
    If piMargins & #TOP
      dHeight - *psV\Pages()\Header\Margins\dBottom
      dHeight - _calcBlockHeight(*psV\Pages()\Header\Block)
      dHeight - *psV\Pages()\Header\Margins\dTop
      dHeight - *psV\Pages()\Margins\dTop
    EndIf
    If piMargins & #BOTTOM
      dHeight - *psV\Pages()\Footer\Margins\dBottom
      dHeight - _calcBlockHeight(*psV\Pages()\Footer\Block)
      dHeight - *psV\Pages()\Footer\Margins\dTop
      dHeight - *psV\Pages()\Margins\dBottom
    EndIf
  ElseIf piGetMargins = 1
    ; //
    ; get top/bottom margins
    ; //
    dHeight = 0
    If piMargins & #TOP
      dHeight + *psV\Pages()\Header\Margins\dBottom
      dHeight + _calcBlockHeight(*psV\Pages()\Header\Block)
      dHeight + *psV\Pages()\Header\Margins\dTop
      dHeight + *psV\Pages()\Margins\dTop
    EndIf
    If piMargins & #BOTTOM
      dHeight + *psV\Pages()\Footer\Margins\dBottom
      dHeight + _calcBlockHeight(*psV\Pages()\Footer\Block)
      dHeight + *psV\Pages()\Footer\Margins\dTop
      dHeight + *psV\Pages()\Margins\dBottom
    EndIf
  EndIf
  
  ProcedureReturn dHeight

EndProcedure

Procedure _incrementPagePosition(*psV.VECVI, piXY.i, pdAdd.d = 0, pdSet.d = 0)
; ----------------------------------------
; internal   :: increments the position values while defining the document
; param      :: *psV  - VecVi structure
;               piXY  - wheter to change the x or y position
;                       0: change x position
;                       1: change y position
;               pdAdd - (S: 0) add this value to the current position
;               pfSet - (S: 0) set the current position to this value
; returns    :: (nothing)
; remarks    :: this is needed for GetXPosition(), GetRealPageCount() etc.
; ----------------------------------------
  Protected   *sPos.VECVI_POS = #Null,
              *sPos2.VECVI_POS = #Null,
              *sVal
; ----------------------------------------
  
  If *psV\iDefTarget = 0
    ; //
    ; normal page block
    ; //
    *sPos  = @*psV\Pages()\Pos
    *sPos2 = @*psV\Pages()\Blocks()\Pos
  ElseIf *psV\iDefTarget = 1
    ; //
    ; standard header block
    ; //
    *sPos = @*psV\Header\Block\Pos
  ElseIf *psV\iDefTarget = 2
    ; //
    ; standard footer block
    ; //
    *sPos = @*psV\Footer\Block\Pos
  Else
    ProcedureReturn
  EndIf
  
  While *sPos <> #Null
    If piXY = 0
      *sVal = @*sPos\dX
    ElseIf piXY = 1
      *sVal = @*sPos\dY
    EndIf
    
    If pdAdd > 0
      PokeD(*sVal, PeekD(*sVal) + pdAdd)
    Else
      PokeD(*sVal, pdSet)
    EndIf

    *sPos  = *sPos2
    *sPos2 = #Null
  Wend
  
EndProcedure

Procedure.i _calcRealPageCount(*psV.VECVI, piPage.i = 0, piPageNb.i = 0)
; ----------------------------------------
; internal   :: calculates the number of real pages that will be displayed after output.
; param      :: *psV     - VecVi structure
;               piPage   - (S: 0) get only the real pages for the specified page(break)
;                          if 0, calculate all pages, otherwise range: 1 - ...
;               piPageNb - (S: 0) used for calculation for page numbering
;                          if 0, all real pages will be counted
;                          if 1, real pages will not be counted if page numbering is disabled
;                            for this page(break)
; returns    :: (i) number of real pages
; remarks    :: 
; ----------------------------------------
  Protected.i iNrP
  Protected.d dPageH,
              dPageY,
              dBlockYKorr
; ----------------------------------------

  If piPage = 0
    ; //
    ; for all pages
    ; //
    ForEach *psV\Pages()
      If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
        iNrP + 1
      EndIf
      dPageH = _calcPageHeight(*psV, #BOTTOM)
      dPageY = _calcPageHeight(*psV, #TOP, 1)
      ForEach *psV\Pages()\Blocks()
        If *psV\Pages()\Blocks()\iPageBreak = #False
          ; //
          ; accept no page break within blocks
          ; //
          If dPageY + _calcBlockHeight(@*psV\Pages()\Blocks()) > dPageH
            If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
              iNrP + 1
            EndIf
            dPageH = _calcPageHeight(*psV, #BOTTOM)
            dPageY = _calcPageHeight(*psV, #TOP, 1)
          EndIf
          dPageY + _calcBlockHeight(@*psV\Pages()\Blocks())
        Else
          ; //
          ; accept page breaks within blocks, check for page breaks in elements
          ; //
          ForEach *psV\Pages()\Blocks()\Elements()
            If dPageY + *psV\Pages()\Blocks()\Elements()\mdVal("_BlockY") - dBlockYKorr + *psV\Pages()\Blocks()\Elements()\mdVal("_BlockH") >= dPageH
              If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
                iNrP + 1
              EndIf
              dPageH = _calcPageHeight(*psV, #BOTTOM)
              dPageY = _calcPageHeight(*psV, #TOP, 1)
              ; //
              ; reduce block y coordinate for all elements not already shown in the previous page
              ; //
              dBlockYKorr = *psV\Pages()\Blocks()\Elements()\mdVal("_BlockY")
            EndIf
          Next
        EndIf
      Next
    Next
  Else
    ; //
    ; for one page
    ; //
    ForEach *psV\Pages()
      If *psV\Pages()\iNr = piPage
        If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
          iNrP + 1
        EndIf
        dPageH = _calcPageHeight(*psV, #BOTTOM)
        dPageY = _calcPageHeight(*psV, #TOP, 1)
        ForEach *psV\Pages()\Blocks()
          If *psV\Pages()\Blocks()\iPageBreak = #False
            ; //
            ; accept no page break within blocks
            ; //
            If dPageY + _calcBlockHeight(@*psV\Pages()\Blocks()) > dPageH
              If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
                iNrP + 1
              EndIf
              dPageH = _calcPageHeight(*psV, #BOTTOM)
              dPageY = _calcPageHeight(*psV, #TOP, 1)
            EndIf
            dPageY + _calcBlockHeight(@*psV\Pages()\Blocks())
          Else
            ; //
            ; accept page breaks within blocks, check for page breaks in elements
            ; //
            ForEach *psV\Pages()\Blocks()\Elements()
              If dPageY + *psV\Pages()\Blocks()\Elements()\mdVal("_BlockY") - dBlockYKorr + *psV\Pages()\Blocks()\Elements()\mdVal("_BlockH") > dPageH
                If Not (piPageNb = 1 And *psV\Pages()\iNb = -1)
                  iNrP + 1
                EndIf
                dPageH = _calcPageHeight(*psV, #BOTTOM)
                dPageY = _calcPageHeight(*psV, #TOP, 1)
                ; //
                ; reduce block y coordinate for all elements not already shown in the previous page
                ; //
                dBlockYKorr = *psV\Pages()\Blocks()\Elements()\mdVal("_BlockY")
              EndIf
            Next
          EndIf
        Next
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn iNrP
  
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
    If \miVal("LineStyle") & #LINESTYLE_DIAGONALCORNER
      iFlags = #PB_Path_DiagonalCorner
    ElseIf \miVal("LineStyle") & #LINESTYLE_ROUNDCORNER
      iFlags = #PB_Path_RoundCorner
    ElseIf \miVal("LineStyle") & #LINESTYLE_ROUNDEND
      iFlags = #PB_Path_RoundEnd
    ElseIf \miVal("LineStyle") & #LINESTYLE_SQUAREEND
      iFlags = #PB_Path_SquareEnd
    EndIf
    
    ; //
    ; draw the line
    ; //
    If \miVal("LineStyle") & #LINESTYLE_STROKE
      StrokePath(\mdVal("LineSize"), iFlags)
    ElseIf \miVal("LineStyle") & #LINESTYLE_DASH
      DashPath(\mdVal("LineSize"), \mdVal("LineLen"), iFlags)
    ElseIf \miVal("LineStyle") & #LINESTYLE_DOT
      DotPath(\mdVal("LineSize"), \mdVal("LineLen"), iFlags)
    EndIf
    
  EndWith

EndProcedure

Procedure _processTextCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a text cell (#ELEMENTTYPE_TEXTCELL).
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
    
    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    dFillX = dPosX
    dFillY = dPosY

    If \mdVal("W") = 0
      \mdVal("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    dFillW = \mdVal("W")
    dFillH = \mdVal("H")
    
    ; //
    ; border
    ; //
    VectorSourceColor(\miVal("LineColor"))
    If \miVal("Border") = #ALL
      AddPathBox(dPosX, dPosY, \mdVal("W"), \mdVal("H"))
      AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \mdVal("H"))
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #RIGHT
        MovePathCursor(dPosX + \mdVal("W"), dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; fill
    ; //
    If \miVal("Border") = #ALL
      dFillX + \mdVal("BorderSize") / 2
      dFillY + \mdVal("BorderSize") / 2
      dFillW - \mdVal("BorderSize")
      dFillH - \mdVal("BorderSize")
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        dFillY + \mdVal("BorderSize") / 2
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #BOTTOM
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #LEFT
        dFillX + \mdVal("BorderSize") / 2
        dFillW - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #RIGHT
        dFillW - \mdVal("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\miVal("FillColor"))
    If \miVal("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf
    
    ; //
    ; text
    ; //
    VectorFont(FontID(\miVal("Font")), \mdVal("FontSize"))
    VectorSourceColor(\miVal("TextColor"))
    
    ; //
    ; horizontal align
    ; //
    dTextX = dPosX + *psV\CellMargins\dLeft - VectorTextWidth(\msVal("Text"), #PB_VectorText_Visible | #PB_VectorText_Offset)
    If \miVal("HAlign") = #RIGHT
      dTextX + \mdVal("W") - VectorTextWidth(\msVal("Text"), #PB_VectorText_Visible) - *psV\CellMargins\dRight
    ElseIf \miVal("HAlign") = #CENTER
      dTextX + \mdVal("W") / 2 - VectorTextWidth(\msVal("Text"), #PB_VectorText_Visible) / 2 - *psV\CellMargins\dRight
    EndIf
    
    ; //
    ; vertical align
    ; //
    dTextY = dPosY + *psV\CellMargins\dTop - VectorTextHeight(\msVal("Text"), #PB_VectorText_Visible | #PB_VectorText_Offset)
    If \miVal("VAlign") = #BOTTOM
      dTextY + \mdVal("H") - VectorTextHeight(\msVal("Text"), #PB_VectorText_Visible) - *psV\CellMargins\dBottom
    ElseIf \miVal("VAlign") = #CENTER
      dTextY + \mdVal("H") / 2 - VectorTextHeight(\msVal("Text"), #PB_VectorText_Visible) / 2 - *psV\CellMargins\dBottom
    EndIf
    
    MovePathCursor(dTextX, dTextY)
    DrawVectorText(\msVal("Text"))
    
    ; //
    ; ln
    ; //
    If \miVal("Ln") = #BOTTOM
      *psV\Pages()\Pos\dY + \mdVal("H")
    ElseIf \miVal("Ln") = #RIGHT
      *psV\Pages()\Pos\dX + \mdVal("W")
    ElseIf \miVal("Ln") = #NEWLINE
      *psV\Pages()\Pos\dY + \mdVal("H")
      *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    EndIf
    *psV\mdVal("LastLn") = \mdVal("H")
    
  EndWith
  
EndProcedure

Procedure _processParagraphCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a paragraph cell (#ELEMENTTYPE_PARACELL).
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

    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    dFillX = dPosX
    dFillY = dPosY
    
    If \mdVal("W") = 0
      \mdVal("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    VectorFont(FontID(\miVal("Font")), \mdVal("FontSize"))
    If \mdVal("H") = 0
      \mdVal("H") = VectorParagraphHeight(\msVal("Text"), \mdVal("W"), *psV\Pages()\Sizes\dHeight) + *psV\CellMargins\dBottom
    EndIf

    dFillW = \mdVal("W")
    dFillH = \mdVal("H")
    
    ; //
    ; border
    ; //
    VectorSourceColor(\miVal("LineColor"))
    If \miVal("Border") = #ALL
      AddPathBox(dPosX, dPosY, \mdVal("W"), \mdVal("H"))
      AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \mdVal("H"))
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #RIGHT
        MovePathCursor(dPosX + \mdVal("W"), dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; fill
    ; //
    If \miVal("Border") = #ALL
      dFillX + \mdVal("BorderSize") / 2
      dFillY + \mdVal("BorderSize") / 2
      dFillW - \mdVal("BorderSize")
      dFillH - \mdVal("BorderSize")
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        dFillY + \mdVal("BorderSize") / 2
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #BOTTOM
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #LEFT
        dFillX + \mdVal("BorderSize") / 2
        dFillW - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #RIGHT
        dFillW - \mdVal("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\miVal("FillColor"))
    If \miVal("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf

    ; //
    ; text
    ; //
    VectorSourceColor(\miVal("TextColor"))
    
    If     \miVal("HAlign") = #LEFT   : iHAlign = #PB_VectorParagraph_Left
    ElseIf \miVal("HAlign") = #RIGHT  : iHAlign = #PB_VectorParagraph_Right
    ElseIf \miVal("HAlign") = #CENTER : iHAlign = #PB_VectorParagraph_Center
    EndIf
    
    MovePathCursor(dPosX + *psV\CellMargins\dLeft, dPosY + *psV\CellMargins\dTop)
    DrawVectorParagraph(\msVal("Text"), \mdVal("W") - *psV\CellMargins\dRight, \mdVal("H") - *psV\CellMargins\dBottom, iHAlign)
    
    ; //
    ; ln
    ; //
    If \miVal("Ln") = #BOTTOM
      *psV\Pages()\Pos\dY + \mdVal("H")
    ElseIf \miVal("Ln") = #RIGHT
      *psV\Pages()\Pos\dX + \mdVal("W")
    ElseIf \miVal("Ln") = #NEWLINE
      *psV\Pages()\Pos\dY + \mdVal("H")
      *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    EndIf
    *psV\mdVal("LastLn") = \mdVal("H")

  EndWith

EndProcedure

Procedure _processImageCell(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a image cell (#ELEMENTTYPE_IMAGECELL).
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
    
    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    dFillX = dPosX
    dFillY = dPosY

    If \mdVal("W") = 0
      \mdVal("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    dFillW = \mdVal("W")
    dFillH = \mdVal("H")
    
    ; //
    ; border
    ; //
    VectorSourceColor(\miVal("LineColor"))
    If \miVal("Border") = #ALL
      AddPathBox(dPosX, dPosY, \mdVal("W"), \mdVal("H"))
      AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \mdVal("H"))
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #RIGHT
        MovePathCursor(dPosX + \mdVal("W"), dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; fill
    ; //
    If \miVal("Border") = #ALL
      dFillX + \mdVal("BorderSize") / 2
      dFillY + \mdVal("BorderSize") / 2
      dFillW - \mdVal("BorderSize")
      dFillH - \mdVal("BorderSize")
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        dFillY + \mdVal("BorderSize") / 2
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #BOTTOM
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #LEFT
        dFillX + \mdVal("BorderSize") / 2
        dFillW - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #RIGHT
        dFillW - \mdVal("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\miVal("FillColor"))
    If \miVal("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf
    
    ; //
    ; horizontal align
    ; //
    dImageX = dPosX + *psV\CellMargins\dLeft
    If \miVal("HAlign") = #RIGHT
      dImageX + \mdVal("W") - \mdVal("ImageW") - *psV\CellMargins\dRight
    ElseIf \miVal("HAlign") = #CENTER
      dImageX + \mdVal("W") / 2 - \mdVal("ImageW") / 2 - *psV\CellMargins\dRight
    EndIf
    
    ; //
    ; vertical align
    ; //
    dImageY = dPosY + *psV\CellMargins\dTop
    If \miVal("VAlign") = #BOTTOM
      dImageY + \mdVal("H") - \mdVal("ImageH") - *psV\CellMargins\dBottom
    ElseIf \miVal("VAlign") = #CENTER
      dImageY + \mdVal("H") / 2 - \mdVal("ImageH") / 2 - *psV\CellMargins\dBottom
    EndIf
    
    MovePathCursor(dImageX, dImageY)
    DrawVectorImage(ImageID(\miVal("Image")), 255, \mdVal("ImageW"), \mdVal("ImageH"))
    
    ; //
    ; ln
    ; //
    If \miVal("Ln") = #BOTTOM
      *psV\Pages()\Pos\dY + \mdVal("H")
    ElseIf \miVal("Ln") = #RIGHT
      *psV\Pages()\Pos\dX + \mdVal("W")
    ElseIf \miVal("Ln") = #NEWLINE
      *psV\Pages()\Pos\dY + \mdVal("H")
      *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    EndIf
    *psV\mdVal("LastLn") = \mdVal("H")
    
  EndWith
  
EndProcedure

Procedure _processHorizontalLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a horizontal line (#ELEMENTTYPE_HLINE).
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

    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    
    If \mdVal("W") = 0
      \mdVal("W")  = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf
    
    ; //
    ; horizontal align
    ; //
    If \miVal("HAlign") = #LEFT
      dLineX = dPosX
    ElseIf \miVal("HAlign") = #RIGHT
      dLineX = _calcPageWidth(*psV, #RIGHT) - \mdVal("W")
    ElseIf \miVal("HAlign") = #CENTER
      dLineX = _calcPageWidth(*psV, #RIGHT) - _calcPageWidth(*psV) / 2 - \mdVal("W") / 2
    EndIf
    
    MovePathCursor(dLineX, dPosY)
    VectorSourceColor(\miVal("LineColor"))
    AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
    *psV\Pages()\Pos\dX = dLineX + \mdVal("W")
    *psV\Pages()\Pos\dY + \mdVal("LineSize")
    
  EndWith

EndProcedure

Procedure _processVerticalLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a vertical line (#ELEMENTTYPE_VLINE).
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

    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    
    If \mdVal("H") = 0
      \mdVal("H") = _calcPageHeight(*psV, #BOTTOM) - dPosY
    EndIf
    
    ; //
    ; vertical align
    ; //
    If \miVal("VAlign") = #TOP
      dLineY = dPosY
    ElseIf \miVal("VAlign") = #BOTTOM
      dLineY = _calcPageHeight(*psV, #BOTTOM) - \mdVal("H")
    ElseIf \miVal("VAlign") = #CENTER
      dLineY = _calcPageHeight(*psV, #BOTTOM) - _calcPageHeight(*psV) / 2 - \mdVal("H") / 2
    EndIf
    
    MovePathCursor(dPosX, dLineY)
    VectorSourceColor(\miVal("LineColor"))
    AddPathLine(0, \mdVal("H"), #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
    *psV\Pages()\Pos\dX + \mdVal("LineSize")
    
  EndWith

EndProcedure

Procedure _processXYLine(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a xy line (#ELEMENTTYPE_XYLINE).
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

    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    
    If \mdVal("dX") = 0
      \mdVal("dX") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    If \mdVal("dY") = 0
      \mdVal("dY") = _calcPageHeight(*psV, #BOTTOM) - dPosY
    EndIf
    
    MovePathCursor(dPosX, dPosY)
    VectorSourceColor(\miVal("LineColor"))
    AddPathLine(\mdVal("dX"), \mdVal("dY"), #PB_Path_Relative)
    _applyLineStyle(@*psT\Elements())
    
  EndWith

EndProcedure

Procedure _processCurve(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a curve (#ELEMENTTYPE_CURVE).
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
    
    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    
    MovePathCursor(dPosX, dPosY)
    VectorSourceColor(\miVal("LineColor"))
    AddPathCurve(\mdVal("S1X"), \mdVal("S1Y"), \mdVal("S2X"), \mdVal("S2Y"), \mdVal("EndX"), \mdVal("EndY"))
    _applyLineStyle(@*psT\Elements())
    
    *psV\Pages()\Pos\dX + \mdVal("EndX")
    *psV\Pages()\Pos\dY + \mdVal("EndY")
    
  EndWith
  
EndProcedure

Procedure _processLn(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a linebreak (#ELEMENTTYPE_LN).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  With *psT\Elements()
  
    If \mdVal("Ln") = -1
      \mdVal("Ln") = *psV\mdVal("LastLn")
    EndIf
    
    *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    *psV\Pages()\Pos\dY + \mdVal("Ln")
    
    *psV\mdVal("LastLn") = \mdVal("Ln")
    
  EndWith

EndProcedure

Procedure _processSp(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a horizontal space (#ELEMENTTYPE_SP).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  With *psT\Elements()
  
    If \mdVal("Sp") = -1
      \mdVal("Sp") = *psV\mdVal("LastSp")
    EndIf
    
    *psV\Pages()\Pos\dX + \mdVal("Sp")
    
    *psV\mdVal("LastSp") = \mdVal("Sp")
    
  EndWith

EndProcedure

Procedure _processRectangle(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a rectangle (#ELEMENTTYPE_RECTANGLE).
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
    
    dPosX = *psV\Pages()\Pos\dX
    dPosY = *psV\Pages()\Pos\dY
    dFillX = dPosX
    dFillY = dPosY

    If \mdVal("W") = 0
      \mdVal("W") = _calcPageWidth(*psV, #RIGHT) - dPosX
    EndIf

    If \mdVal("H") = 0
      \mdVal("H") = _calcPageHeight(*psV, #BOTTOM) - dPosY
    EndIf

    dFillW = \mdVal("W")
    dFillH = \mdVal("H")
    
    ; //
    ; border
    ; //
    VectorSourceColor(\miVal("LineColor"))
    If \miVal("Border") = #ALL
      AddPathBox(dPosX, dPosY, \mdVal("W"), \mdVal("H"))
      AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      _applyLineStyle(@*psT\Elements())
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        MovePathCursor(dPosX, dPosY)
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #BOTTOM
        MovePathCursor(dPosX, dPosY + \mdVal("H"))
        AddPathLine(\mdVal("W"), 0, #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #LEFT
        MovePathCursor(dPosX, dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      If \miVal("Border") & #RIGHT
        MovePathCursor(dPosX + \mdVal("W"), dPosY - Bool(\miVal("Border") & #TOP) * (\mdVal("BorderSize") / 2))
        AddPathLine(0, \mdVal("H") + (Bool(\miVal("Border") & #TOP) + Bool(\miVal("Border") & #BOTTOM)) * (\mdVal("BorderSize") / 2), #PB_Path_Relative)
      EndIf
      _applyLineStyle(@*psT\Elements())
    EndIf
    
    ; //
    ; fill
    ; //
    If \miVal("Border") = #ALL
      dFillX + \mdVal("BorderSize") / 2
      dFillY + \mdVal("BorderSize") / 2
      dFillW - \mdVal("BorderSize")
      dFillH - \mdVal("BorderSize")
    ElseIf \miVal("Border") <> #False
      If \miVal("Border") & #TOP
        dFillY + \mdVal("BorderSize") / 2
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #BOTTOM
        dFillH - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #LEFT
        dFillX + \mdVal("BorderSize") / 2
        dFillW - \mdVal("BorderSize") / 2
      EndIf
      If \miVal("Border") & #RIGHT
        dFillW - \mdVal("BorderSize") / 2
      EndIf
    EndIf
    VectorSourceColor(\miVal("FillColor"))
    If \miVal("Fill")
      MovePathCursor(dFillX, dFillY)
      AddPathBox(dFillX, dFillY, dFillW, dFillH)
      FillPath()
    EndIf
    
    ; //
    ; ln
    ; //
    If \miVal("Ln") = #BOTTOM
      *psV\Pages()\Pos\dY + \mdVal("H")
    ElseIf \miVal("Ln") = #RIGHT
      *psV\Pages()\Pos\dX + \mdVal("W")
    ElseIf \miVal("Ln") = #NEWLINE
      *psV\Pages()\Pos\dY + \mdVal("H")
      *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    EndIf
    *psV\mdVal("LastLn") = \mdVal("H")
    
  EndWith
  
EndProcedure

Procedure _processSector(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes drawing of a ellipse sector (#ELEMENTTYPE_SECTOR).
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
    
    dPosX = *psV\Pages()\Pos\dX + \mdVal("W") / 2
    dPosY = *psV\Pages()\Pos\dY + \mdVal("H") / 2
    
    If \miVal("Connect") = #True
      iFlags = #PB_Path_Connected
      MovePathCursor(dPosX, dPosY)
    EndIf
    
    AddPathEllipse(dPosX, dPosY, \mdVal("W") / 2, \mdVal("H") / 2, \mdVal("Start"), \mdVal("End"), iFlags)
    
    If \miVal("Connect") = #True
      ClosePath()
    EndIf
    
    If \miVal("Fill") = #True
      VectorSourceColor(\miVal("FillColor"))
      FillPath(#PB_Path_Preserve)
    EndIf
    
    If \miVal("Border") = #True
      VectorSourceColor(\miVal("LineColor"))
      _applyLineStyle(@*psT\Elements())
    EndIf
    ResetPath()
    
    ; //
    ; ln
    ; //
    If \miVal("Ln") = #BOTTOM
      *psV\Pages()\Pos\dY + \mdVal("H")
    ElseIf \miVal("Ln") = #RIGHT
      *psV\Pages()\Pos\dX + \mdVal("W")
    ElseIf \miVal("Ln") = #NEWLINE
      *psV\Pages()\Pos\dY + \mdVal("H")
      *psV\Pages()\Pos\dX = *psV\Margins\dLeft + *psV\Offsets\dLeft
    EndIf
    *psV\mdVal("LastLn") = \mdVal("H")
    
  EndWith
  
EndProcedure

Procedure _processSetX(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes a x position manipulation (#ELEMENTTYPE_X).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  With *psT\Elements()
  
    If \miVal("Rel") = #True
      *psV\Pages()\Pos\dX + \mdVal("X")
    Else
      *psV\Pages()\Pos\dX = \mdVal("X")
    EndIf
    
  EndWith

EndProcedure

Procedure _processSetY(*psV.VECVI, *psT.VECVI_BLOCK)
; ----------------------------------------
; internal   :: processes a y position manipulation (#ELEMENTTYPE_Y).
; param      :: *psV - VecVi structure
;               *psT - current VecVi block (returned by VecVi::_defTarget)
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  With *psT\Elements()

    If \miVal("Rel") = #True
      *psV\Pages()\Pos\dY + \mdVal("Y")
    Else
      *psV\Pages()\Pos\dY = \mdVal("Y")
    EndIf
    
  EndWith

EndProcedure

Procedure _processElements(*psV.VECVI, piTarget)
; ----------------------------------------
; internal   :: processes drawing of all elements within one block.
; param      :: *psV     - VecVi structure
;               piTarget - which drawing target block to use
;                          0 : normal page block
;                          1 : default header block
;                          2 : default footer block
;                          11: header block of the current page
;                          21: footer block of the current page
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV, piTarget)
  ForEach *Target\Elements()
    With *Target\Elements()
      
      ; //
      ; if page breaks allowed within blocks, check the height of every element
      ; and do a page break, if necessary.
      ; //
      If *Target\iPageBreak = #True And *psV\Pages()\Pos\dY + \mdVal("_BlockH") > _calcPageHeight(*psV, #BOTTOM)
        _processEndPage(*psV)
        If *psV\iOutput = #OUTPUT_CANVAS Or *psV\iOutput = #OUTPUT_IMAGE Or *psV\iOutput = #OUTPUT_WINDOW
          ; //
          ; for single-page output channels, overwrite the former drawing if it's not the
          ; page that is wanted, or finish.
          ; //
          If *psV\iNrRealPages = *psV\iOnlyRealPage
            ProcedureReturn 
          Else
            VectorSourceColor(RGBA(255, 255, 255, 255))
            FillVectorOutput()
          EndIf
        EndIf
        _processNewPage(*psV)
      EndIf
      
      ; //
      ; replace the page numbering tokens with the current page number and the total
      ; page number for text elements.
      ; //
      If FindMapElement(\msVal(), "TextRaw")
        If *psV\Pages()\iNb > -1
          \msVal("Text") = ReplaceString(\msVal("TextRaw"), *psV\msVal("NbCurrent"), Str(*psV\iNbCurrent))
          \msVal("Text") = ReplaceString(\msVal("Text"), *psV\msVal("NbTotal"), Str(*psV\iNbTotal))
        Else
          \msVal("Text") = \msVal("TextRaw")
        EndIf
      EndIf
      
      ; //
      ; split processing by element type
      ; //
      Select \iType
        Case #ELEMENTTYPE_TEXTCELL  : _processTextCell(*psV, *Target)
        Case #ELEMENTTYPE_PARACELL  : _processParagraphCell(*psV, *Target)
        Case #ELEMENTTYPE_IMAGECELL : _processImageCell(*psV, *Target)
        Case #ELEMENTTYPE_HLINE     : _processHorizontalLine(*psV, *Target)
        Case #ELEMENTTYPE_VLINE     : _processVerticalLine(*psV, *Target)
        Case #ELEMENTTYPE_XYLINE    : _processXYLine(*psV, *Target)
        Case #ELEMENTTYPE_CURVE     : _processCurve(*psV, *Target)
        Case #ELEMENTTYPE_LN        : _processLn(*psV, *Target)
        Case #ELEMENTTYPE_SP        : _processSp(*psV, *Target)
        Case #ELEMENTTYPE_RECTANGLE : _processRectangle(*psV, *Target)
        Case #ELEMENTTYPE_SECTOR    : _processSector(*psV, *Target)
        Case #ELEMENTTYPE_X         : _processSetX(*psV, *Target)
        Case #ELEMENTTYPE_Y         : _processSetY(*psV, *Target)
      EndSelect
      
    EndWith    
  Next
  
EndProcedure

Procedure _processHeader(*psV.VECVI)
; ----------------------------------------
; internal   :: processes drawing of a page's header.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
  *psV\Pages()\Pos\dY = *psV\Pages()\Margins\dTop + *psV\Pages()\Header\Margins\dTop + *psV\Offsets\dTop
  
  ; //
  ; process all header elements
  ; //
  _processElements(*psV, 11)
  
  *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
  *psV\Pages()\Pos\dY + *psV\Pages()\Header\Margins\dBottom
  
EndProcedure

Procedure _processFooter(*psV.VECVI)
; ----------------------------------------
; internal   :: processes drawing of a page's footer.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.d dFooterHeight
; ----------------------------------------
  
  ; //
  ; get the bottom offset for starting the footer drawing
  ; //
  dFooterHeight = _calcBlockHeight(*psV\Pages()\Footer\Block)
  
  *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
  *psV\Pages()\Pos\dY = *psV\Pages()\Sizes\dHeight + *psV\Offsets\dTop - *psV\Pages()\Margins\dBottom - *psV\Pages()\Footer\Margins\dBottom - dFooterHeight - *psV\Pages()\Footer\Margins\dTop
  
  ; //
  ; process all footer elements
  ; //
  _processElements(*psV, 21)
  
  *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
  
EndProcedure

Procedure _processNewPage(*psV.VECVI)
; ----------------------------------------
; internal   :: processes drawing of a new real page.
; param      :: psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; reset page coordinates
  ; //
  *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
  *psV\Pages()\Pos\dY = *psV\Pages()\Margins\dTop + *psV\Offsets\dTop
  
  ; //
  ; increment real page counters
  ; //
  *psV\Pages()\iNrRealPages + 1
  *psV\iNrRealPages + 1
  
  ; //
  ; for multi-page output channels, create a new page, if it's not the first one
  ; (it is created automatically.)
  ; //
  If (*psV\iOutput = #OUTPUT_PRINTER Or *psV\iOutput = #OUTPUT_PDF Or *psV\iOutput = #OUTPUT_SVG) And
     Not (*psV\Pages()\iNr = 1 And *psV\Pages()\iNrRealPages = 1)
    NewVectorPage()
    
    ; //
    ; fill the page in the current sizes
    ; //
    AddPathBox(0, 0, *psV\Sizes\dWidth, *psV\Sizes\dHeight)
    VectorSourceColor(RGBA(255, 255, 255, 255))
    FillPath()
  EndIf
  
  ; //
  ; if page numbering is activated, increment the current page number
  ; for this real page based on the start value of the current
  ; page(break)
  ; //
  If *psV\Pages()\iNb = 0 And *psV\Pages()\iNrRealPages = 1
    *psV\Pages()\iNbStartValue = *psV\iNbCurrent + 1
    *psV\Pages()\iNb = 1
  EndIf
  If *psV\Pages()\iNb > -1
    *psV\iNbCurrent = *psV\Pages()\iNbStartValue + *psV\Pages()\iNrRealPages - 1
  EndIf
  
  ; //
  ; draw the header before all further content
  ; //
  _processHeader(*psV)
  
EndProcedure

Procedure _processEndPage(*psV.VECVI)
; ----------------------------------------
; internal   :: processes a page finish
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: just calls VecVi::_processFooter()
; ----------------------------------------
  
  _processFooter(*psV)
  
EndProcedure

Procedure _processBlocks(*psV.VECVI)
; ----------------------------------------
; internal   :: processes drawing of all blocks on a single page(break).
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; create new real page
  ; //
  _processNewPage(*psV)
  
  ForEach *psV\Pages()\Blocks()
    *psV\Pages()\Pos\dX = *psV\Pages()\Margins\dLeft + *psV\Offsets\dLeft
    
    ; //
    ; if page breaks are forbidden within this block, check if the block size fits the
    ; left y space on the page, and create a new page, if it is necessary.
    ; //
    If *psV\Pages()\Blocks()\iPageBreak = #False And *psV\Pages()\Pos\dY + _calcBlockHeight(@*psV\Pages()\Blocks()) > _calcPageHeight(*psV)
      _processEndPage(*psV)
      If *psV\iOutput = #OUTPUT_CANVAS Or *psV\iOutput = #OUTPUT_IMAGE Or *psV\iOutput = #OUTPUT_WINDOW
        ; //
        ; for single-page output channels, overwrite the former drawing if it's not the
        ; page that is wanted, or finish.
        ; //
        If *psV\iNrRealPages = *psV\iOnlyRealPage
          ProcedureReturn 
        Else
          VectorSourceColor(RGBA(255, 255, 255, 255))
          FillVectorOutput()
        EndIf
      EndIf
      _processNewPage(*psV)
    EndIf
    
    ; //
    ; process all elements of this block
    ; //
    _processElements(*psV, 0)
  Next
  
  ; //
  ; finish the page
  ; //
  _processEndPage(*psV)
  
EndProcedure

Procedure _process(*psV.VECVI, piOutput.i, piObject.i, pzPath.s, piRealPage.i)
; ----------------------------------------
; internal   :: processes drawing of all VecVi stuff to the specified output.
; param      :: psV - VecVi structure
;               piOutput   - output type
;                            #OUTPUT_CANVAS:  output to PB's CanvasGadget()
;                            #OUTPUT_IMAGE:   output to an image object
;                            #OUTPUT_WINDOW:  direct output to a window
;                            #OUTPUT_PRINTER: send output to a printer using PB Printer lib
;                            #OUTPUT_SVG:     output to a .svg file
;                            #OUTPUT_PDF:     output to a .pdf file
;               piObject   - output gadget or output window 
;               pzPath     - full output path for .svg and .pdf outputs
;               piRealPage - only output the specified real page
;                            for single-page output channels
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iOutput
; ----------------------------------------

  ; //
  ; get output channel
  ; //  
  *psV\iOutput = piOutput
  If piOutput = #OUTPUT_CANVAS
    iOutput = CanvasVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyRealPage = piRealPage
  ElseIf piOutput = #OUTPUT_IMAGE
    iOutput = ImageVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyRealPage = piRealPage
  ElseIf piOutput = #OUTPUT_WINDOW
    iOutput = WindowVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyRealPage = piRealPage
  ElseIf piOutput = #OUTPUT_PRINTER
    iOutput = PrinterVectorOutput(#PB_Unit_Millimeter)
  ElseIf piOutput = #OUTPUT_SVG
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      iOutput = SvgVectorOutput(pzPath, *psV\Sizes\dWidth, *psV\Sizes\dHeight, #PB_Unit_Millimeter)
    CompilerElse
      DebuggerError("SvgVectorOutput only supported on Linux.")
    CompilerEndIf
  ElseIf piOutput = #OUTPUT_PDF
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      DebuggerError("PdfVectorOutput not supported on Windows.")
    CompilerElse
      iOutput = PdfVectorOutput(pzPath, *psV\Sizes\dWidth, *psV\Sizes\dHeight, #PB_Unit_Millimeter)
    CompilerEndIf
  EndIf
  
  ; //
  ; reset page numbering and real page counters and page positions
  ; //
  *psV\iNbTotal     = _calcRealPageCount(*psV, 0, 1)
  *psV\iNbCurrent   = 0
  *psV\iNrRealPages = 0
  ForEach *psV\Pages()
    *psV\Pages()\iNrRealPages = 0
    *psV\Pages()\Pos\dX       = 0
    *psV\Pages()\Pos\dY       = 0
  Next
  
  ; //
  ; start drawing to the specified output
  ; //
  If StartVectorDrawing(iOutput)
    
    ; //
    ; scaling
    ; //
    ScaleCoordinates(*psV\mdVal("ScaleX"), *psV\mdVal("ScaleY"))
    
    ; //
    ; iterate over each pagebreak
    ; //
    ForEach *psV\Pages()
      If (*psV\iOutput = #OUTPUT_CANVAS Or *psV\iOutput = #OUTPUT_IMAGE Or *psV\iOutput = #OUTPUT_WINDOW) And
          *psV\iNrRealPages < *psV\iOnlyRealPage
        ; //
        ; for single-page output channels, overwrite the former drawing if it's not the
        ; page that is wanted
        ; //
        VectorSourceColor(RGBA(255, 255, 255, 255))
        FillVectorOutput()
      EndIf
      
      _processBlocks(*psV)
      
      If (*psV\iOutput = #OUTPUT_CANVAS Or *psV\iOutput = #OUTPUT_IMAGE Or *psV\iOutput = #OUTPUT_WINDOW) And
          *psV\iNrRealPages = *psV\iOnlyRealPage
        ; //
        ; for single-page output channels, if the wanted real page is reached, finish
        ; //
        Break
      EndIf
    Next
    
    StopVectorDrawing()
  EndIf
  
EndProcedure

;- >>> basic functions <<<

Procedure.i Create(pzFormat.s, piOrientation.i)
; ----------------------------------------
; public     :: creates a new VecVi object
; param      :: pzFormat      - page format ('Short side,Long side')
;                               or constant - see #FORMAT_*
;               piOrientation - #ORIENTATION_HORIZONTAL: width: short side, height: long side
;                               #ORIENTATION_VERTICAL:   width: long side, height: short side
;                               #ORIENTATION_INHERIT:    use the orientation specified with VecVi::Create()
; returns    :: pointer to VecVi object structure
; remarks    :: this procedure has to be called before all other VecVi commands.
; ----------------------------------------
  Protected *psV.VECVI
; ----------------------------------------
  
  ; //
  ; allocate the main structure
  ; //
  *psV = AllocateStructure(VECVI)
  
  ; //
  ; set default page sizes
  ; //
  If piOrientation = #ORIENTATION_VERTICAL
    *psV\Sizes\dWidth  = ValD(StringField(pzFormat, 1, ","))
    *psV\Sizes\dHeight = ValD(StringField(pzFormat, 2, ","))
  ElseIf piOrientation = #ORIENTATION_HORIZONTAL
    *psV\Sizes\dWidth  = ValD(StringField(pzFormat, 2, ","))
    *psV\Sizes\dHeight = ValD(StringField(pzFormat, 1, ","))
  EndIf
  
  ; //
  ; set default margins
  ; //
  *psV\Margins\dBottom = 12
  *psV\Margins\dLeft   = 14
  *psV\Margins\dRight  = 12
  *psV\Margins\dTop    = 15
  
  *psV\CellMargins\dBottom = 1.5
  *psV\CellMargins\dLeft   = 1.5
  *psV\CellMargins\dRight  = 1.5
  *psV\CellMargins\dTop    = 1.5
  
  ; //
  ; set default colors
  ; //
  *psV\miVal("FillColor") = RGBA(255, 255, 255, 255)
  *psV\miVal("LineColor") = RGBA(0,   0,   0,   255)
  *psV\miVal("TextColor") = RGBA(0,   0,   0,   255)
  
  ; //
  ; set default line size and style
  ; //
  *psV\mdVal("LineSize")  = 0.2
  *psV\miVal("LineStyle") = #LINESTYLE_STROKE
  *psV\mdVal("LineLen")   = 1.0
  
  ; //
  ; set page numbering tokens
  ; //
  *psV\msVal("NbCurrent") = "{Nb}"
  *psV\msVal("NbTotal")   = "{NbTotal}"
  
  ; //
  ; set default scale factor
  ; //
  *psV\mdVal("ScaleX") = 1
  *psV\mdVal("ScaleY") = 1
  
  ; //
  ; load default font
  ; //
  SetFont(*psV, "Arial", 0, 5)
  
  ProcedureReturn *psV
  
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
  ; free structure
  ; //
  FreeStructure(*psV)
  
EndProcedure

;- >>> area definition <<<

Procedure BeginPage(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #ORIENTATION_INHERIT, piNumbering = 0)
; ----------------------------------------
; public     :: starts a new page(break) on the current VecVi structure.
; param      :: *psV          - VecVi structure
;               pzFormat      - page format ('Short side,Long side')
;                               or constant - see #FORMAT_*
;               piOrientation - #ORIENTATION_HORIZONTAL: width: short side, height: long side
;                               #ORIENTATION_VERTICAL:   width: long side, height: short side
;                               #ORIENTATION_INHERIT:    use the orientation specified with VecVi::Create()

; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  AddElement(*psV\Pages())
  With *psV\Pages()
    \iNr     = *psV\iNrPages + 1
    \Margins = *psV\Margins
    
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
    \Header\Margins = *psV\Header\Margins
    \Footer\Margins = *psV\Footer\Margins
    CopyList(*psV\Header\Block\Elements(), \Header\Block\Elements())
    CopyList(*psV\Footer\Block\Elements(), \Footer\Block\Elements())

    ; //
    ; format
    ; //
    If pzFormat <> #FORMAT_INHERIT Or piOrientation <> #ORIENTATION_INHERIT
      If piOrientation = #ORIENTATION_VERTICAL
        \Sizes\dWidth  = ValD(StringField(pzFormat, 1, ","))
        \Sizes\dHeight = ValD(StringField(pzFormat, 2, ","))
      ElseIf piOrientation = #ORIENTATION_HORIZONTAL
        \Sizes\dWidth  = ValD(StringField(pzFormat, 2, ","))
        \Sizes\dHeight = ValD(StringField(pzFormat, 1, ","))
      EndIf
    Else
      \Sizes = *psV\Sizes
    EndIf
    
    ; //
    ; position
    ; //
    \Pos\dY = _calcPageHeight(*psV, #TOP, 1)
    \Pos\dX = 0
    
  EndWith
  
  *psV\iNrPages + 1
  
EndProcedure

Procedure BeginBlock(*psV.VECVI, piPageBreak.i = #True)
; ----------------------------------------
; public     :: starts a new element block on the current page(break).
; param      :: *psV        - VecVi structure
;               piPageBreak - wheter to accept page breaks within this block
;                             #True:  accept page breaks
;                             #False: disallow page breaks
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\iDefTarget = 0
  AddElement(*psV\Pages()\Blocks())
  
  *psV\Pages()\Blocks()\iPageBreak = piPageBreak    
  
EndProcedure

Procedure BeginHeader(*psV.VECVI)
; ----------------------------------------
; public     :: begins the definition of the header block for the current and the following pages.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: The header has to be defined before the first page(break) is created.
;               Once defined, it will be used for every page until the header is redefined.
; ----------------------------------------
  
  *psV\iDefTarget = 1
  
  ; //
  ; reset the header block
  ; //
  ClearList(*psV\Header\Block\Elements())
  *psV\Header\Block\Pos\dX = 0
  *psV\Header\Block\Pos\dY = 0
  
EndProcedure

Procedure BeginFooter(*psV.VECVI)
; ----------------------------------------
; public     :: begins the definition of the footer block for the current and the following pages.
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: The footer has to be defined before the first page is finished.
;               Once defined, it will be used for every page until the footer is redefined.
; ----------------------------------------
  
  *psV\iDefTarget = 2

  ; //
  ; reset the footer block
  ; //
  ClearList(*psV\Footer\Block\Elements())
  *psV\Footer\Block\Pos\dX = 0
  *psV\Footer\Block\Pos\dY = 0
  
EndProcedure

;- >>> get/set <<<

Procedure.i GetFillColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the color that is used for filling cells.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\miVal("FillColor")
  
EndProcedure

Procedure SetFillColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: gets the color that is used for filling cells.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\miVal("FillColor") = piColor
  
EndProcedure

Procedure.i GetTextColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current font color.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\miVal("TextColor")
  
EndProcedure

Procedure SetTextColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: sets the current font color.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\miVal("TextColor") = piColor
  
EndProcedure

Procedure.i GetLineColor(*psV.VECVI)
; ----------------------------------------
; public     :: gets the color that is used for lines and borders.
; param      :: *psV - VecVi structure
; returns    :: (i) color value, see RGBA()
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\miVal("LineColor")
  
EndProcedure

Procedure SetLineColor(*psV.VECVI, piColor.i)
; ----------------------------------------
; public     :: sets the color that is used for lines and borders.
; param      :: *psV    - VecVi structure
;               piColor - color value, see RGBA()
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\miVal("LineColor") = piColor
  
EndProcedure

Procedure.d GetLineSize(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current width of lines and borders.
; param      :: *psV - VecVi structure
; returns    :: (d) border/line size/width
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\mdVal("LineSize")
  
EndProcedure

Procedure SetLineSize(*psV.VECVI, pdSize.d)
; ----------------------------------------
; public     :: sets the current width of lines and borders
; param      :: *psV   - VecVi structure
;               pdSize - border/line size/width
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  *psV\mdVal("LineSize") = pdSize
  
EndProcedure

Procedure.d GetLineStyle(*psV.VECVI, piGetLenght = #False)
; ----------------------------------------
; public     :: gets the current style of lines and borders.
; param      :: *psV        - VecVi structure
;               piGetLenght - (S: #False) wheter to get the break lenght
; returns    :: (d) border/line style or lenght
; remarks    :: take care of the return value type (double) instead of (expected) integer when
;               piGetLenght = #False
; ----------------------------------------
  
  If piGetLenght = #False
    ProcedureReturn *psV\miVal("LineStyle")
  Else
    ProcedureReturn *psV\miVal("LineLen")
  EndIf
  
EndProcedure

Procedure SetLineStyle(*psV.VECVI, piStyle.i = -1, pdLenght.d = -1)
; ----------------------------------------
; public     :: sets the current style of lines and borders
; param      :: *psV     - VecVi structure
;               piStyle  - (S: -1) border/line style
;                          if -1, the style is kept unchanged
;               piLenght - (S: -1) length of the breaks in the line
;                          only used if piStyle & #LINESTYLE_DOT or #LINESTYLE_DASH
;                          if -1, the lenght is kept unchanged
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If piStyle > -1
    *psV\miVal("LineStyle") = piStyle
  EndIf
  If pdLenght > -1
    *psV\mdVal("LineLen") = pdLenght
  EndIf
  
EndProcedure

Procedure.d GetMargin(*psV.VECVI, piMargin.i, piArea = #AREA_PAGE, piDefault.i = #False)
; ----------------------------------------
; public     :: gets VecVi's margin values of the specified area.
; param      :: *psV      - VecVi structure
;               piMargin  - which margin to get
;                           #BOTTOM: get bottom margin
;                           #LEFT:   get left margin
;                           #RIGHT:  get right margin
;                           #TOP:    get top margin
;               piArea    - (S: #AREA_PAGE) margin area
;                           #AREA_PAGE:   page margins, the outermost margins of every page
;                           #AREA_HEADER: header margins, only top/bottom margins are supported
;                           #AREA_FOOTER: footer margins, only top/bottom margins are supported
;                           #AREA_CELL:   inner cell margins
;               piDefault - (S: #False) which margin types to get, supported for page, header and footer
;                           #True:  get the default area margins
;                           #False: get the margins of the current area
; returns    :: (d) margin value
; remarks    :: 
; ----------------------------------------
  Protected *Margin.VECVI_MARGINS
; ----------------------------------------
  
  If piArea = #AREA_PAGE
    If piDefault = #False
      *Margin = @*psV\Pages()\Margins
    Else
      *Margin = @*psV\Margins
    EndIf
  ElseIf piArea = #AREA_HEADER
    If piDefault = #False
      *Margin = @*psV\Pages()\Header\Margins
    Else
      *Margin = @*psV\Header\Margins
    EndIf
  ElseIf piArea = #AREA_FOOTER
    If piDefault = #False
      *Margin = @*psV\Pages()\Footer\Margins
    Else
      *Margin = @*psV\Footer\Margins
    EndIf
  ElseIf piArea = #AREA_CELL
    *Margin = @*psV\CellMargins
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

Procedure SetMargin(*psV.VECVI, piMargin.i, pdValue.d, piArea = #AREA_PAGE, piDefault.i = #False)
; ----------------------------------------
; public     :: sets VecVi's margin values of the specified area.
; param      :: *psV      - VecVi structure
;               piMargin  - which margin to set
;                           #BOTTOM: set bottom margin
;                           #LEFT:   set left margin
;                           #RIGHT:  set right margin
;                           #TOP:    set top margin
;               pdValue   - margin value to set for the area
;               piArea    - (S: #AREA_PAGE) margin area
;                           #AREA_PAGE:   page margins, the outermost margins of every page
;                           #AREA_HEADER: header margins, only top/bottom margins are supported
;                           #AREA_FOOTER: footer margins, only top/bottom margins are supported
;                           #AREA_CELL:   inner cell margins
;               piDefault - (S: #False) which margin types to set, supported for page, header and footer
;                           #True:  set the default area margins
;                           #False: set the margins of the current area
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Margin.VECVI_MARGINS
; ----------------------------------------
  
  If piArea = #AREA_PAGE
    If piDefault = #False
      *Margin = @*psV\Pages()\Margins
    Else
      *Margin = @*psV\Margins
    EndIf
  ElseIf piArea = #AREA_HEADER
    If piDefault = #False
      *Margin = @*psV\Pages()\Header\Margins
    Else
      *Margin = @*psV\Header\Margins
    EndIf
  ElseIf piArea = #AREA_FOOTER
    If piDefault = #False
      *Margin = @*psV\Pages()\Footer\Margins
    Else
      *Margin = @*psV\Footer\Margins
    EndIf
  ElseIf piArea = #AREA_CELL
    *Margin = @*psV\CellMargins
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
  
  ProcedureReturn *psV\Pages()\Pos\dX
  
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
    \mdVal("X")   = pdX
    \miVal("Rel") = piRelative
  EndWith
    
EndProcedure

Procedure.d GetYPos(*psV.VECVI)
; ----------------------------------------
; public     :: gets the current y position on the output
; param      :: *psV - VecVi structure
; returns    :: (d) y position
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn *psV\Pages()\Pos\dY
  
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
    \mdVal("Y")   = pdY
    \miVal("Rel") = piRelative
  EndWith
    
EndProcedure

Procedure.d GetPageWidth(*psV.VECVI, piPage.i = 0)
; ----------------------------------------
; public     :: gets the net width of the specified page
; param      :: *psV   - VecVi structure
;               piPage - (S: 0) page to get the width for
;               if 0, return the width for the current page
;               otherwise get the width of the specified page
; returns    :: (d) page width
; remarks    :: 
; ----------------------------------------

  If piPage = 0
    ProcedureReturn _calcPageWidth(*psV, #LEFT | #RIGHT, 1)
  Else
    PushListPosition(*psV\Pages())
    ForEach *psV\Pages()
      If *psV\Pages()\iNr = piPage
        ProcedureReturn _calcPageWidth(*psV, #LEFT | #RIGHT, 1)
      EndIf
    Next
    PopListPosition(*psV\Pages())
  EndIf
  
EndProcedure

Procedure.d GetPageHeight(*psV.VECVI, piPage.i = 0)
; ----------------------------------------
; public     :: gets the net height of the specified page
; param      :: *psV   - VecVi structure
;               piPage - (S: 0) page to get the height for
;               if 0, return the height for the current page
;               otherwise get the height of the specified page
; returns    :: (d) page height
; remarks    :: 
; ----------------------------------------

  If piPage = 0
    ProcedureReturn _calcPageHeight(*psV, #TOP | #BOTTOM, 0, 1)
  Else
    PushListPosition(*psV\Pages())
    ForEach *psV\Pages()
      If *psV\Pages()\iNr = piPage
        ProcedureReturn _calcPageHeight(*psV, #TOP | #BOTTOM, 0, 1)
      EndIf
    Next
    PopListPosition(*psV\Pages())
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
    ProcedureReturn *psV\mdVal("ScaleX")
  ElseIf piAxis = 1
    ProcedureReturn *psV\mdVal("ScaleY")
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

  *psV\mdVal("ScaleX") = pdX
  *psV\mdVal("ScaleY") = pdY
  
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
    ProcedureReturn *psV\Offsets\dTop
  ElseIf piOffset = #LEFT
    ProcedureReturn *psV\Offsets\dLeft
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
  
  If piOffset = #TOP
    *psV\Offsets\dTop = pdValue
  ElseIf piOffset = #LEFT
    *psV\Offsets\dLeft = pdValue
  EndIf
  
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
    *psV\mdVal("FontSize") = pdSize
  EndIf
  
  ; //
  ; search for current font in the list of previous used fonts
  ; //
  ForEach *psV\Fonts()
    If *psV\Fonts()\zName = pzName And *psV\Fonts()\iStyle = piStyle 
      *psV\miVal("CurrentFont") = *psV\Fonts()\iHandle
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
  *psV\miVal("CurrentFont") = *psV\Fonts()\iHandle
  
EndProcedure

Procedure.i GetRealPageCount(*psV.VECVI, piPage.i = 0)
; ----------------------------------------
; internal   :: calculates the number of real pages in the current output.
; param      :: *psV     - VecVi structure
;               piPage   - (S: 0) get only the real pages for the specified page(break)
;                          if 0, calculate all pages, otherwise range: 1 - ...
; returns    :: (i) number of real pages
; remarks    :: just calls VecVi::_calcRealPageCount()
; ----------------------------------------

  ProcedureReturn _calcRealPageCount(*psV, piPage)
  
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
    *psV\msVal("NbCurrent") = pzCurrent
  EndIf
  If pzTotal <> ""
    *psV\msVal("NbTotal") = pzTotal
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
    \mdVal("W")          = pdW
    \mdVal("H")          = pdH
    \msVal("TextRaw")    = pzText
    \miVal("Ln")         = piLn
    \miVal("Border")     = piBorder
    \miVal("HAlign")     = piHAlign
    \miVal("VAlign")     = piVAlign
    \miVal("Fill")       = piFill
    \miVal("FillColor")  = *psV\miVal("FillColor")
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    \miVal("TextColor")  = *psV\miVal("TextColor")
    \miVal("Font")       = *psV\miVal("CurrentFont")
    \mdVal("FontSize")   = *psV\mdVal("FontSize")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    If \miVal("Ln") <> #RIGHT
      _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    Else
      If pdW = 0
        pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
      EndIf
      _incrementPagePosition(*psV, 0, pdW)
    EndIf
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
    \mdVal("W")          = pdW
    \mdVal("H")          = pdH
    \msVal("TextRaw")    = pzText
    \miVal("Ln")         = piLn
    \miVal("Border")     = piBorder
    \miVal("HAlign")     = piHAlign
    \miVal("Fill")       = piFill
    \miVal("FillColor")  = *psV\miVal("FillColor")
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    \miVal("TextColor")  = *psV\miVal("TextColor")
    \miVal("Font")       = *psV\miVal("CurrentFont")
    \mdVal("FontSize")   = *psV\mdVal("FontSize")
    
    ; //
    ; variable height of paragraph cells: try to calculate the needed height before
    ; the original drawing
    ; //
    If pdH = 0
      If pdW = 0
        pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
      EndIf
      
      iImage = CreateImage(#PB_Any, 1, 1)
      StartVectorDrawing(ImageVectorOutput(iImage, #PB_Unit_Millimeter))
      VectorFont(FontID(\miVal("Font")), \mdVal("FontSize"))
      pdH = VectorParagraphHeight(\msVal("TextRaw"), pdW, *psV\Pages()\Sizes\dHeight) + *psV\CellMargins\dBottom
      StopVectorDrawing()
      FreeImage(iImage)
    EndIf
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    If \miVal("Ln") <> #RIGHT
      _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    Else
      If pdW = 0
        pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
      EndIf
      _incrementPagePosition(*psV, 0, pdW)
    EndIf
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
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_IMAGECELL
    \mdVal("W")          = pdW
    \mdVal("H")          = pdH
    \mdVal("ImageW")     = pdImageW
    \mdVal("ImageH")     = pdImageH
    \miVal("Image")      = piImage
    \miVal("Ln")         = piLn
    \miVal("Border")     = piBorder
    \miVal("HAlign")     = piHAlign
    \miVal("VAlign")     = piVAlign
    \miVal("Fill")       = piFill
    \miVal("FillColor")  = *psV\miVal("FillColor")
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    If \miVal("Ln") <> #RIGHT
      _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    Else
      If pdW = 0
        pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
      EndIf
      _incrementPagePosition(*psV, 0, pdW)
    EndIf
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
    \mdVal("W")          = pdW
    \miVal("HAlign")     = piHAlign
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = \mdVal("LineSize")
    _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    If pdW = 0
      pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
    EndIf
    _incrementPagePosition(*psV, 0, pdW)
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
    \mdVal("H")          = pdH
    \miVal("VAlign")     = piVAlign
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    
    _incrementPagePosition(*psV, 0, \mdVal("LineSize"))
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
    \mdVal("dX")         = pdDeltaX
    \mdVal("dY")         = pdDeltaY
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdDeltaY
    _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
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
    \mdVal("S1X")        = pdS1X
    \mdVal("S1Y")        = pdS1Y
    \mdVal("S2X")        = pdS2X
    \mdVal("S2Y")        = pdS2Y
    \mdVal("EndX")       = pdEndX
    \mdVal("EndY")       = pdEndY
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdEndY - *Target\Pos\dY
    _incrementPagePosition(*psV, 1, pdEndY)
    _incrementPagePosition(*psV, 0, pdEndX)
  EndWith
  
EndProcedure

Procedure Ln(*psV.VECVI, pdLn.d = -1)
; ----------------------------------------
; public     :: creates a new line break on the current block.
; param      :: *psV - VecVi structure
;               pdLn - (S: -1) the height of the line break
;                      if -1, the height of the last line break will be used
;                        (also if you have used VecVi::TextCell() with #BOTTOM or #NEWLINE)
;                      otherwise, the line break will be as specified in this parameter
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected *Target.VECVI_BLOCK
; ----------------------------------------
  
  *Target = _defTarget(*psV)
  AddElement(*Target\Elements())
  With *Target\Elements()
    \iType = #ELEMENTTYPE_LN
    \mdVal("Ln") = pdLn
    
    \mdVal("_BlockY") = *Target\Pos\dY
    If pdLn > -1
      \mdVal("_BlockH") = pdLn
    Else
      \mdVal("_BlockH") = *psV\mdVal("LastLn")
    EndIf
    _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    _incrementPagePosition(*psV, 0, 0, *psV\Margins\dLeft + *psV\Offsets\dLeft)
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
    \mdVal("Sp") = pdSp
    
    If pdSp > -1
      _incrementPagePosition(*psV, 0, pdSp)
    Else
      _incrementPagePosition(*psV, 0, *psV\mdVal("LastSp"))
    EndIf
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
    \mdVal("W")          = pdW
    \mdVal("H")          = pdH
    \miVal("Ln")         = piLn
    \miVal("Border")     = piBorder
    \miVal("Fill")       = piFill
    \miVal("FillColor")  = *psV\miVal("FillColor")
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    If \miVal("Ln") <> #RIGHT
      _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    Else
      If pdW = 0
        pdW = _calcPageWidth(*psV, #RIGHT) - *Target\Pos\dX
      EndIf
      _incrementPagePosition(*psV, 0, pdW)
    EndIf
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
    \mdVal("W")          = pdW
    \mdVal("H")          = pdH
    \mdVal("Start")      = pdStart
    \mdVal("End")        = pdEnd
    \miVal("Ln")         = piLn
    \miVal("Border")     = piBorder
    \miVal("Connect")    = piConnect
    \miVal("Fill")       = piFill
    \miVal("FillColor")  = *psV\miVal("FillColor")
    \mdVal("LineSize")   = *psV\mdVal("LineSize")
    \miVal("LineColor")  = *psV\miVal("LineColor")
    \miVal("LineStyle")  = *psV\miVal("LineStyle")
    \mdVal("LineLen")    = *psV\mdVal("LineLen")
    
    \mdVal("_BlockY") = *Target\Pos\dY
    \mdVal("_BlockH") = pdH
    If \miVal("Ln") <> #RIGHT
      _incrementPagePosition(*psV, 1, \mdVal("_BlockH"))
    Else
      _incrementPagePosition(*psV, 0, pdW)
    EndIf
  EndWith
  
EndProcedure

;- >>> output functions <<<

Procedure OutputCanvas(*psV.VECVI, piGadget.i, piRealPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a canvas gadget.
; param      :: *psV       - VecVi structure
;               piGadget   - canvas gadget ID
;               piRealPage - real page to show on the canvas
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _process(*psV, #OUTPUT_CANVAS, piGadget, "", piRealPage)
  
EndProcedure

Procedure OutputImage(*psV.VECVI, piImage.i, piRealPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on an image.
; param      :: *psV       - VecVi structure
;               piGadget   - image ID
;               piRealPage - real page to show on the image
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _process(*psV, #OUTPUT_IMAGE, piImage, "", piRealPage)
  
EndProcedure

Procedure OutputWindow(*psV.VECVI, piWindow.i, piRealPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a window.
; param      :: *psV       - VecVi structure
;               piGadget   - window ID
;               piRealPage - real page to show on the window
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _process(*psV, #OUTPUT_WINDOW, piWindow, "", piRealPage)
  
EndProcedure

Procedure OutputPrinter(*psV.VECVI)
; ----------------------------------------
; public     :: outputs VecVi on a printer.
; param      :: *psV       - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _process(*psV, #OUTPUT_PRINTER, -1, "", 0)
  
EndProcedure

Procedure OutputSVG(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  _process(*psV, #OUTPUT_SVG, -1, pzPath, 0)
  
EndProcedure

Procedure OutputPDF(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  _process(*psV, #OUTPUT_PDF, -1, pzPath, 0)
  
EndProcedure

EndModule