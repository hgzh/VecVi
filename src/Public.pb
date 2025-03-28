; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; PUBLIC DECLARATION
;
; ###########################################################

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
  zName.s
  zRefPath.s
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
  Map Variables.s()
  
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
  Map Variables.s()
  Map NamedPos.VECVI_POS()
  
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

;- >>> functions <<<

  Declare.i Create(pzFormat.s, piOrientation.i)
  Declare   Process(*psV.VECVI)
  Declare   Free(*psV.VECVI)
  Declare.i LoadFile(pzPath.s)
  Declare.i SaveFile(*psV.VECVI, pzPath.s)
  Declare.i BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)
  Declare.i BeginBlock(*psV.VECVI, piPageBreak.i = #True)
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
  Declare.d GetNamedPos(*psV.VECVI, pzName.s, piXY.i)
  Declare   SetNamedPos(*psV.VECVI, pzName.s, pdX.d = -1, pdY.d = -1)
  Declare   UseNamedPos(*psV.VECVI, pzName.s)
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
  Declare.d GetParagraphHeight(*psV.VECVI, pzText.s, pdWidth.d)
  Declare.s GetImageReferencePath(*psV.VECVI, pzName.s)
  Declare   SetImageReferencePath(*psV.VECVI, pzName.s, pzPath.s)
  Declare   SetPageNumberingTokens(*psV.VECVI, pzCurrent.s = "", pzTotal.s = "")
  Declare.s GetVariable(*psV.VECVI, pzVariable.s)
  Declare   SetVariable(*psV.VECVI, pzVariable.s, pzValue.s)
  Declare   RemoveVariable(*psV.VECVI, pzVariable.s)
  Declare.i DuplicateBlock(*psV.VECVI, *psBlock.VECVI_BLOCK, piPos = #RIGHT, *psRelative.VECVI_BLOCK = #Null)
  Declare.i DuplicateSection(*psV.VECVI, *psSection.VECVI_SECTION, piPos = #RIGHT, *psRelative.VECVI_SECTION = #Null)
  Declare.i ReplaceHeader(*psV.VECVI, *psBlock.VECVI_BLOCK)
  Declare.i ReplaceFooter(*psV.VECVI, *psBlock.VECVI_BLOCK)
  Declare.i AppendHeader(*psV.VECVI, *psBlock.VECVI_BLOCK)
  Declare.i AppendFooter(*psV.VECVI, *psBlock.VECVI_BLOCK)
  Declare   TextCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare.d ParagraphCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piFill.i = #False)
  Declare   ImageCell(*psV.VECVI, pdW.d, pdH.d, pdImageW.d, pdImageH.d, piImage.i = -1, pzName.s = "", piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
  Declare   HorizontalLine(*psV.VECVI, pdW.d, piHAlign.i = #LEFT)
  Declare   VerticalLine(*psV.VECVI, pdH.d, piVAlign.i = #TOP)
  Declare   XYLine(*psV.VECVI, pdDeltaX.d, pdDeltaY.d)
  Declare   Curve(*psV.VECVI, pdS1X.d, pdS1Y.d, pdS2X.d, pdS2Y.d, pdEndX.d, pdEndY.d)
  Declare   Ln(*psV.VECVI, pdLn.d = -1)
  Declare   Sp(*psV.VECVI, pdSp.d = -1)
  Declare   Rectangle(*psV.VECVI, pdW.d, pdH.d, piLn.i = #RIGHT, piBorder.i = #False, piFill.i = #False)
  Declare   Sector(*psV.VECVI, pdW.d, pdH.d, pdStart.d, pdEnd.d, piLn.i = #RIGHT, piBorder.i = #False, piConnect.i = #True, piFill.i = #False)
  Declare.i OutputCanvas(*psV.VECVI, piGadget.i, piPage.i = 1)
  Declare.i OutputImage(*psV.VECVI, piImage.i, piPage.i = 1)
  Declare.i OutputWindow(*psV.VECVI, piWindow.i, piPage.i = 1)
  Declare.i OutputPrinter(*psV.VECVI)
  Declare.i OutputSVG(*psV.VECVI, pzPath.s, piPage.i = 1)
  Declare.i OutputPDF(*psV.VECVI, pzPath.s)
  
EndDeclareModule