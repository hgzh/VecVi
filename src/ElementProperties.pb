; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; ELEMENT PROPERTY CONTROL
;
; ###########################################################

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