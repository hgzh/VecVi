; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; AREA DEFINITION AND MANIPULATION
;
; ###########################################################

Procedure.i BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)
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
; returns    :: (i) pointer to the new section element
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
  
  ProcedureReturn @*psV\Sections()
  
EndProcedure

Procedure.i BeginBlock(*psV.VECVI, piPageBreak.i = #True)
; ----------------------------------------
; public     :: starts a new element block on the current section.
; param      :: *psV        - VecVi structure
;               piPageBreak - (S: #True) wheter to accept page breaks within this block
;                             #True:  accept page breaks
;                             #False: disallow page breaks
; returns    :: (i) pointer to the new block element
; remarks    :: 
; ----------------------------------------
  Protected.d dOldPagePos
; ----------------------------------------  
  
  *psV\iDefTarget = 0
  AddElement(*psV\Sections()\Blocks())
  
  ; //
  ; copy current variables to the block
  ; //
  CopyMap(*psV\Variables(), *psV\Sections()\Blocks()\Variables())
  
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
  
  ProcedureReturn @*psV\Sections()\Blocks()
  
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
  ; copy current variables to the block
  ; //
  CopyMap(*psV\Variables(), *psV\Header\Block\Variables())

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
  ; copy current variables to the block
  ; //
  CopyMap(*psV\Variables(), *psV\Footer\Block\Variables())

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

Procedure.i DuplicateBlock(*psV.VECVI, *psBlock.VECVI_BLOCK, piPos = #RIGHT, *psRelative.VECVI_BLOCK = #Null)
; ----------------------------------------
; public     :: duplicates the given block.
; param      :: *psV        - VecVi structure
;               *psBlock    - VecVi block to duplicate
;               piPos       - (S: #RIGHT) where to add the new block
;                             #TOP:    add as first block
;                             #BOTTOM: add as last block
;                             #LEFT:   add before current block
;                             #RIGHT:  add after current block
;               *psRelative - piPos relative to block
;                             if not given, position is determined from *psBlock
; returns    :: (i) pointer to the new block element
; remarks    :: 
; ----------------------------------------
  Protected *sNew.VECVI_BLOCK
; ----------------------------------------
  
  ; //
  ; return if block pointer is invalid
  ; //
  If *psBlock = 0
    ProcedureReturn 0
  EndIf
  
  ; //
  ; save current block list position
  ; //
  PushListPosition(*psV\Sections()\Blocks())
  
  ; //
  ; create new block and copy the contents
  ; //
  *sNew = AddElement(*psV\Sections()\Blocks())
  CopyStructure(*psBlock, *sNew, VECVI_BLOCK)
  
  ; //
  ; return when block doesn't need to be moved
  ; //
  If *psRelative = #Null And (piPos = #LEFT Or piPos = #RIGHT)
    PopListPosition(*psV\Sections()\Blocks())
    ProcedureReturn *sNew
  EndIf
  
  ; //
  ; move block
  ; //
  If piPos = #LEFT
    MoveElement(*psV\Sections()\Blocks(), #PB_List_Before, *psRelative)
  ElseIf piPos = #RIGHT
    MoveElement(*psV\Sections()\Blocks(), #PB_List_After, *psRelative)
  ElseIf piPos = #TOP
    MoveElement(*psV\Sections()\Blocks(), #PB_List_First)
  ElseIf piPos = #BOTTOM
    MoveElement(*psV\Sections()\Blocks(), #PB_List_Last)
  EndIf

  ; //
  ; copy current variables to the block
  ; //
  CopyMap(*psV\Variables(), *psV\Sections()\Blocks()\Variables())
  
  ; //
  ; restore block list position
  ; //
  PopListPosition(*psV\Sections()\Blocks())
  
  ProcedureReturn *sNew

EndProcedure

Procedure.i DuplicateSection(*psV.VECVI, *psSection.VECVI_SECTION, piPos = #RIGHT, *psRelative.VECVI_SECTION = #Null)
; ----------------------------------------
; public     :: duplicates the given section.
; param      :: *psV        - VecVi structure
;               *psSection  - VecVi section to duplicate
;               piPos       - (S: #RIGHT) where to add the new section
;                             #TOP:    add as first section
;                             #BOTTOM: add as last section
;                             #LEFT:   add before current section
;                             #RIGHT:  add after current section
;               *psRelative - piPos relative to section
;                             if not given, position is determined from *psSection
; returns    :: (i) pointer to the new section element
; remarks    :: 
; ----------------------------------------
  Protected *sNew.VECVI_SECTION
; ----------------------------------------
  
  ; //
  ; return if section pointer is invalid
  ; //
  If *psSection = 0
    ProcedureReturn 0
  EndIf
  
  ; //
  ; save current section list position
  ; //
  PushListPosition(*psV\Sections())
  
  ; //
  ; create new section and copy the contents
  ; //
  *sNew = AddElement(*psV\Sections())
  CopyStructure(*psSection, *sNew, VECVI_SECTION)
  
  ; //
  ; return when section doesn't need to be moved
  ; //
  If *psRelative = #Null And (piPos = #LEFT Or piPos = #RIGHT)
    PopListPosition(*psV\Sections())
    ProcedureReturn *sNew
  EndIf
  
  ; //
  ; move section
  ; //
  If piPos = #LEFT
    MoveElement(*psV\Sections(), #PB_List_Before, *psRelative)
  ElseIf piPos = #RIGHT
    MoveElement(*psV\Sections(), #PB_List_After, *psRelative)
  ElseIf piPos = #TOP
    MoveElement(*psV\Sections(), #PB_List_First)
  ElseIf piPos = #BOTTOM
    MoveElement(*psV\Sections(), #PB_List_Last)
  EndIf
  
  ; //
  ; copy current variables to all blocks in the section
  ; //
  PushListPosition(*psV\Sections()\Blocks())
  ForEach *psV\Sections()\Blocks()
    CopyMap(*psV\Variables(), *psV\Sections()\Blocks()\Variables())
  Next
  PopListPosition(*psV\Sections()\Blocks())
  
  ; //
  ; restore section list position
  ; //
  PopListPosition(*psV\Sections())
  
  ProcedureReturn *sNew

EndProcedure

Procedure.i ReplaceHeader(*psV.VECVI, *psBlock.VECVI_BLOCK)
; ----------------------------------------
; public     :: replaces the header with the given block.
; param      :: *psV     - VecVi structure
;               *psBlock - VecVi block to replace header with
; returns    :: (i) replace state
;               0: error while replacing
;               1: replacing successful
; remarks    :: 
; ----------------------------------------
  
  If *psBlock = 0
    ProcedureReturn 0
  EndIf
  
  CopyStructure(*psBlock, *psV\Header\Block, VECVI_BLOCK)
  
  ProcedureReturn 1
  
EndProcedure

Procedure ReplaceFooter(*psV.VECVI, *psBlock.VECVI_BLOCK)
; ----------------------------------------
; public     :: replaces the footer with the given block.
; param      :: *psV     - VecVi structure
;               *psBlock - VecVi block to replace footer with
; returns    :: (i) replace state
;               0: error while replacing
;               1: replacing successful
; remarks    :: 
; ----------------------------------------
  
  If *psBlock = 0
    ProcedureReturn 0
  EndIf
  
  CopyStructure(*psBlock, *psV\Footer\Block, VECVI_BLOCK)
  
  ProcedureReturn 1
  
EndProcedure

Procedure.i AppendHeader(*psV.VECVI, *psBlock.VECVI_BLOCK)
; ----------------------------------------
; public     :: appends the given block to the header
; param      :: *psV     - VecVi structure
;               *psBlock - VecVi block to append to header
; returns    :: (i) appending state
;               0: error while appending
;               1: appending successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _appendHeaderFooter(*psV, *psBlock, 1)
  
EndProcedure

Procedure.i AppendFooter(*psV.VECVI, *psBlock.VECVI_BLOCK)
; ----------------------------------------
; public     :: appends the given block to the footer
; param      :: *psV     - VecVi structure
;               *psBlock - VecVi block to append to footer
; returns    :: (i) appending state
;               0: error while appending
;               1: appending successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _appendHeaderFooter(*psV, *psBlock, 2)
  
EndProcedure