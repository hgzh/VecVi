; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; BASE FUNCTIONS
;
; ###########################################################

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

Procedure.i LoadFile(pzPath.s)
; ----------------------------------------
; public     :: loads VecVi data from a file
; param      :: pzPath - file path
; returns    :: (i) pointer to VecVi structure or 0 if error
; remarks    :: 
; ----------------------------------------
  Protected.i iJSON
  Protected   *sVecVi.VECVI
; ----------------------------------------
  
  ; //
  ; load JSON file
  ; //
  iJSON = LoadJSON(#PB_Any, pzPath)
  If Not IsJSON(iJSON)
    FreeJSON(iJSON)
    ProcedureReturn 0
  EndIf
 
  ; //
  ; allocate the main structure and extract json data
  ; //
  *sVecVi = AllocateStructure(VECVI)
  If *sVecVi = 0
    FreeJSON(iJSON)
    ProcedureReturn 0
  EndIf
  ExtractJSONStructure(JSONValue(iJSON), *sVecVi, VECVI)
  
  ; //
  ; free JSON resources
  ; //
  FreeJSON(iJSON)
  
  ; //
  ; reload fonts and images
  ; //
  _reloadFonts(*sVecVi)
  _reloadImages(*sVecVi)
  
  ; //
  ; process
  ; //
  _process(*sVecVi)
  *sVecVi\i("NoReprocessing") = 1

  ; //
  ; return pointer
  ; //
  ProcedureReturn *sVecVi

EndProcedure

Procedure.i SaveFile(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: saves VecVi data to a json file
; param      :: *psV   - VecVi structure
;               pzPath - file path
; returns    :: (i) save success
;               0: error while saving
;               1: saving succeeded
; remarks    :: 
; ----------------------------------------
  Protected.i iJSON
; ----------------------------------------
  
  ; //
  ; create JSON and insert data
  ; //
  iJSON = CreateJSON(#PB_Any)
  If Not IsJSON(iJSON)
    FreeJSON(iJSON)
    ProcedureReturn 0
  EndIf
  InsertJSONStructure(JSONValue(iJSON), *psV, VECVI)
  
  ; //
  ; save JSON to file
  ; //
  If Not SaveJSON(iJSON, pzPath)
    FreeJSON(iJSON)
    ProcedureReturn 0
  EndIf
  
  ; //
  ; free JSON resources
  ; //
  FreeJSON(iJSON)
  
  ; //
  ; return success
  ; //
  ProcedureReturn 1

EndProcedure