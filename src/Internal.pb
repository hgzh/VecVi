; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; INTERNAL FUNCTIONS
;
; ###########################################################

Declare _process(*psV.VECVI)
Declare _processNewPage(*psV.VECVI, pdRestoreX.d = 0)
Declare _processEndPage(*psV.VECVI)
Declare _drawElements(*psV.VECVI, piStartPageRef.i, piE.i = 0)

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

Enumeration DrawingMode
  ; ----------------------------------------
  ; internal   :: possible drawing modes
  ; ----------------------------------------
  #DRAW_PAGED
  #DRAW_SINGLE
  #DRAW_MULTIH
  #DRAW_MULTIV
EndEnumeration

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

Procedure _appendHeaderFooter(*psV.VECVI, *psB.VECVI_BLOCK, piMode.i)
; ----------------------------------------
; internal   :: appends the given block to the header or footer
; param      :: *psV   - VecVi structure
;               *psB   - VecVi block to append to header
;               piMode - wheter to append to the header or footer
;                        1: header
;                        2: footer
; returns    :: (i) appending state
;               0: error while appending
;               1: appending successful
; remarks    :: 
; ----------------------------------------
  Protected.i iOldPagePosX,
              iOldGlobPosX
  Protected   *Target.VECVI_BLOCK
  Protected   NewList sllElementsTemp.VECVI_ELEMENT()
; ----------------------------------------
  
  ; //
  ; return if block pointer is invalid
  ; //
  If *psB = 0
    ProcedureReturn 0
  EndIf
  
  ; //
  ; determine wheter to use header or footer
  ; //
  If piMode = 1
    *Target = @*psV\Header\Block
  ElseIf piMode = 2
    *Target = @*psV\Footer\Block
  Else
    ProcedureReturn 0
  EndIf
  
  ; //
  ; create temp copy of block elements
  ; //
  If Not CopyList(*psB\Elements(), sllElementsTemp())
    ProcedureReturn 0
  EndIf
  
  ; //
  ; save current x positions for restoring later
  ; //
  iOldPagePosX = *psV\CurrPagePos\dX
  iOldGlobPosX = *psV\CurrGlobPos\dX
  
  ; //
  ; replace current x positions with the ones from the last element in the header or footer
  ; //
  LastElement(*Target\Elements())
  *psV\CurrPagePos\dX = *Target\Elements()\PagePos\dX
  *psV\CurrGlobPos\dX = *Target\Elements()\DrawPos\dX
  
  ; //
  ; manually add linebreak to get x position back to left border
  ; //
  If AddElement(*Target\Elements())
    _defTarget(*psV, piMode)
    *Target\Elements()\iType   = #ELEMENTTYPE_LN
    *Target\Elements()\d("Ln") = 0
    _applyPosition(*psV, _defTarget(*psV), @*Target\Elements())
    _defTarget(*psV, 0)
  EndIf
  
  ; //
  ; restore current x positions
  ; //
  *psV\CurrPagePos\dX = iOldPagePosX
  *psV\CurrGlobPos\dX = iOldGlobPosX
  
  ; //
  ; merge block into header or footer block and restore elements from temp copy
  ; //
  MergeLists(*psB\Elements(), *Target\Elements())
  CopyList(sllElementsTemp(), *psB\Elements())
  
  ProcedureReturn 1
  
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
    VectorFont(FontID(\i("Font")), \d("FontSize"))
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

    VectorFont(FontID(\i("Font")), \d("FontSize"))
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
    If \i("Image") > 0
      DrawVectorImage(ImageID(\i("Image")), 255, \d("ImageW"), \d("ImageH"))
    EndIf
    
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
  If *psV\iDrawMode = #DRAW_PAGED And Not *psV\Sections()\Pages()\iNr = 1
    NewVectorPage()
  EndIf
  
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
  Protected.s zText
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
    ; replace variables and numbering tokens
    ; //
    If FindMapElement(*Target\Elements()\s(), "TextRaw")
      zText = *Target\Elements()\s("TextRaw")
      ForEach *Target\Variables()
        zText = ReplaceString(zText, "{{" + MapKey(*Target\Variables()) + "}}", *Target\Variables())
      Next
      
      If *psV\Sections()\Pages()\iNb > -1
        zText = ReplaceString(zText, *psV\s("NbCurrent"), Str(*psV\Sections()\Pages()\iNb))
        zText = ReplaceString(zText, *psV\s("NbTotal"),   Str(*psV\iNbTotal))
      EndIf
      
      *Target\Elements()\s("Text") = zText
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

Procedure.i _draw(*psV.VECVI, piOutput.i, piObject.i, pzPath.s, piPage.i)
; ----------------------------------------
; internal   :: output of all VecVi stuff to the specified output channel.
; param      :: psV - VecVi structure
;               piOutput   - output type
;                            #OUTPUT_CANVAS:      output to PB's CanvasGadget()
;                            #OUTPUT_IMAGE:       output to an image object
;                            #OUTPUT_WINDOW:      direct output to a window
;                            #OUTPUT_PRINTER:     send output to a printer using PB Printer lib
;                            #OUTPUT_SVG:         output to a .svg file
;                            #OUTPUT_PDF:         output to a .pdf file
;               piObject   - first output gadget, window or image
;               pzPath     - full output path for .svg and .pdf outputs
;               piPage     - only output the specified page
;                            for single-page output channels
; returns    :: (i) drawing completion state
;               0: error occured while drawing
;               1: drawing finished successfully
; remarks    :: 
; ----------------------------------------
  Protected.i iOutput,
              iOldPageRef,
              i,
              iFail
  Protected   siS.Integer
  Protected   siB.Integer
  Protected   siE.Integer
; ----------------------------------------

  ; //
  ; get output channel
  ; //  
  *psV\iOutput = piOutput
  If piOutput = #OUTPUT_CANVAS
    iOutput = CanvasVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_IMAGE
    iOutput = ImageVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_WINDOW
    iOutput = WindowVectorOutput(piObject, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_PRINTER
    iOutput = PrinterVectorOutput(#PB_Unit_Millimeter)
    *psV\iOnlyPage = -1
  ElseIf piOutput = #OUTPUT_SVG
    iOutput = SvgVectorOutput(pzPath, *psV\Size\dWidth, *psV\Size\dHeight, #PB_Unit_Millimeter)
    *psV\iOnlyPage = piPage
  ElseIf piOutput = #OUTPUT_PDF
    iOutput = PdfVectorOutput(pzPath, *psV\Size\dWidth, *psV\Size\dHeight, #PB_Unit_Millimeter)
    *psV\iOnlyPage = -1
  EndIf
  
  ; //
  ; return if output is invalid
  ; //
  If iOutput = 0
    ProcedureReturn 0
  EndIf
  
  ; //
  ; determine drawing mode
  ; //
  If *psV\iOutput = #OUTPUT_PRINTER Or *psV\iOutput = #OUTPUT_PDF
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
  ; start drawing to the specified output, return if failed
  ; //
  If StartVectorDrawing(iOutput) = 0
    ProcedureReturn 0
  EndIf

  ; //
  ; scaling
  ; //
  ScaleCoordinates(*psV\d("ScaleX"), *psV\d("ScaleY"))
  
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
  iFail = 0
  If FirstElement(*psV\Sections()) = #Null
    iFail = 1
  Else
    While FirstElement(*psV\Sections()\Blocks()) = #Null
      If NextElement(*psV\Sections()) = #Null
        iFail = 1
        Break
      EndIf
    Wend
  EndIf
  
  If iFail = 1
    ; //
    ; stop drawing
    ; //
    StopVectorDrawing()
    ProcedureReturn 0
  EndIf
  
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
      If FirstElement(*psV\Sections()\Blocks()) = #Null
        Continue
      EndIf
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
  StopVectorDrawing()
  
  ProcedureReturn 1
  
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
    ; if the section contains no blocks, continue with next section
    ; //
    If ListSize(*psV\Sections()\Blocks()) < 1
      Continue
    EndIf
    
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

Procedure _replaceHandle(*psB.VECVI_BLOCK, pzName.s, piOldHandle, piNewHandle.i)
; ----------------------------------------
; internal   :: replaces the font handle in every element of the block
; param      :: *psB        - VecVi block
;               pzName      - name of the item containing the handle
;               piOldHandle - old handle
;               piNewHandle - new handle
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  ForEach *psB\Elements()
    If FindMapElement(*psB\Elements()\i(), pzName) And *psB\Elements()\i(pzName) = piOldHandle
      *psB\Elements()\i(pzName) = piNewHandle
    EndIf
  Next

EndProcedure

Procedure _reloadFonts(*psV.VECVI)
; ----------------------------------------
; internal   :: reloads the defined fonts
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iOldHandle
; ----------------------------------------

  ForEach *psV\Fonts()
    ; //
    ; save old handle for replacements
    ; //
    iOldHandle = *psV\Fonts()\iHandle
    
    ; //
    ; free old font handle if valid
    ; //
    If IsFont(iOldHandle)
      FreeFont(iOldHandle)
    EndIf
    
    ; //
    ; reload font
    ; //
    *psV\Fonts()\iHandle = LoadFont(#PB_Any, *psV\Fonts()\zName, 1, *psV\Fonts()\iStyle)
    
    ; //
    ; replace handle in current font
    ; //
    If *psV\i("CurrentFont") = iOldHandle
      *psV\i("CurrentFont") = *psV\Fonts()\iHandle
    EndIf
    
    ; //
    ; replace handle in section
    ; //
    ForEach *psV\Sections()
      ; //
      ; replace in blocks
      ; //
      ForEach *psV\Sections()\Blocks()
        _replaceHandle(@*psV\Sections()\Blocks(), "Font", iOldHandle, *psV\Fonts()\iHandle)
      Next
      
      ; //
      ; replace in section header and footer
      ; //
      _replaceHandle(*psV\Sections()\Header\Block, "Font", iOldHandle, *psV\Fonts()\iHandle)
      _replaceHandle(*psV\Sections()\Footer\Block, "Font", iOldHandle, *psV\Fonts()\iHandle)
    Next
    
    ; //
    ; replace handle in global header/footer
    ; //
    _replaceHandle(*psV\Header\Block, "Font", iOldHandle, *psV\Fonts()\iHandle)
    _replaceHandle(*psV\Footer\Block, "Font", iOldHandle, *psV\Fonts()\iHandle)    
  Next

EndProcedure

Procedure _reloadImages(*psV.VECVI)
; ----------------------------------------
; internal   :: reloads the defined images
; param      :: *psV - VecVi structure
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  Protected.i iOldHandle
; ----------------------------------------

  ForEach *psV\Images()
    ; //
    ; save old handle for replacements
    ; //
    iOldHandle = *psV\Images()\iHandle
    
    ; //
    ; free old image handle if valid
    ; //
    If IsImage(iOldHandle)
      FreeImage(iOldHandle)
    EndIf
    
    ; //
    ; reload image if reference path is set or set handle to -1 to deactivate image drawing
    ; //
    If *psV\Images()\zRefPath <> ""
      *psV\Images()\iHandle     = LoadImage(#PB_Any, *psV\Images()\zRefPath)
    Else
      *psV\Images()\iHandle     = -1
    EndIf
    
    ; //
    ; replace handle in section
    ; //
    ForEach *psV\Sections()
      ; //
      ; replace in blocks
      ; //
      ForEach *psV\Sections()\Blocks()
        _replaceHandle(@*psV\Sections()\Blocks(), "Image", iOldHandle, *psV\Images()\iHandle)
      Next
      
      ; //
      ; replace in section header and footer
      ; //
      _replaceHandle(*psV\Sections()\Header\Block, "Image", iOldHandle, *psV\Images()\iHandle)
      _replaceHandle(*psV\Sections()\Footer\Block, "Image", iOldHandle, *psV\Images()\iHandle)
    Next
    
    ; //
    ; replace handle in global header/footer
    ; //
    _replaceHandle(*psV\Header\Block, "Image", iOldHandle, *psV\Images()\iHandle)
    _replaceHandle(*psV\Footer\Block, "Image", iOldHandle, *psV\Images()\iHandle)    
  Next

EndProcedure