; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; ELEMENT DEFINITION
;
; ###########################################################

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

Procedure.d ParagraphCell(*psV.VECVI, pdW.d, pdH.d, pzText.s, piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piFill.i = #False)
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
; returns    :: (d) height of the paragraph
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
  
  ProcedureReturn *Target\Elements()\d("H")
    
EndProcedure

Procedure ImageCell(*psV.VECVI, pdW.d, pdH.d, pdImageW.d, pdImageH.d, piImage.i = -1, pzName.s = "", piLn.i = #RIGHT, piBorder.i = #False, piHAlign.i = #LEFT, piVAlign.i = #CENTER, piFill.i = #False)
; ----------------------------------------
; public     :: creates a new text cell on the current block.
; param      :: *psV     - VecVi structure
;               pdW      - width of the cell
;                          if 0, the cell starts at the current x position and ends at the right page margin
;               pdH      - height of the cell
;               pdImageW - width of the image in the cell
;               pdImageH - height of the image in the cell
;               piImage  - (S: -1) cell image
;                          can be a PB Image object, if -1, the image with the given name will be used
;               pzName   - (S: '') name of the image
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
  ; check if image is already loaded
  ; //
  Repeat
    ForEach *psV\Images()
      If pzName <> "" And *psV\Images()\zName = pzName
        piImage = *psV\Images()\iHandle
        Break 2
      EndIf
    Next
    ; //
    ; create a copy of the image to allow disallocation
    ; //
    AddElement(*psV\Images())
    *psV\Images()\iHandle = CopyImage(piImage, #PB_Any)
    *psV\Images()\zName   = pzName
    piImage = *psV\Images()\iHandle
  Until 1
  
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
    \d("Ln") = pdLn
    
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