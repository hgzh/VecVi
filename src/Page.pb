; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; PAGE AND SECTION FUNCTIONS
;
; ###########################################################

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

Procedure.i GetSectionCount(*psV.VECVI)
; ----------------------------------------
; public     :: returns the number of sections in the current output
; param      :: *psV     - VecVi structure
; returns    :: (i) number of sections
; remarks    :: 
; ----------------------------------------

  ProcedureReturn *psV\iNrSections
  
EndProcedure