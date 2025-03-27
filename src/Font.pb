; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; FONT MANAGEMENT
;
; ###########################################################

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