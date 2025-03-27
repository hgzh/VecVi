; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; NAMED POSITIONS CONTROL
;
; ###########################################################

Procedure.d GetNamedPos(*psV.VECVI, pzName.s, piXY.i)
; ----------------------------------------
; public     :: returns the x or y position of the given named position
; param      :: *psV   - VecVi structure
;               pzName - name of position
;               piXY   - which position to return
;                        0: x
;                        1: y
; returns    :: (d) selected position or -1 if error
; remarks    :: 
; ----------------------------------------

  If Not FindMapElement(*psV\NamedPos(), pzName)
    ProcedureReturn -1
  EndIf
  
  If piXY = 0
    ProcedureReturn *psV\NamedPos(pzName)\dX
  ElseIf piXY = 1
    ProcedureReturn *psV\NamedPos(pzName)\dY
  EndIf

EndProcedure

Procedure SetNamedPos(*psV.VECVI, pzName.s, pdX.d = -1, pdY.d = -1)
; ----------------------------------------
; public     :: registers a named x, y position on the page
; param      :: *psV   - VecVi structure
;               pzName - name for position
;               pdX    - (S: -1) x position
;                        -1: x position will be kept unchanged
;               pdY - (S: -1) y position
;                     -1: y position will be kept unchanged
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  *psV\NamedPos(pzName)\dX = pdX
  *psV\NamedPos(pzName)\dY = pdY

EndProcedure

Procedure UseNamedPos(*psV.VECVI, pzName.s)
; ----------------------------------------
; public     :: uses the named position
; param      :: *psV   - VecVi structure
;               pzName - name of position
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  If Not FindMapElement(*psV\NamedPos(), pzName)
    ProcedureReturn
  EndIf
  
  If *psV\NamedPos(pzName)\dX > -1
    SetXPos(*psV, *psV\NamedPos(pzName)\dX)
  EndIf
  
  If *psV\NamedPos(pzName)\dY > -1
    SetYPos(*psV, *psV\NamedPos(pzName)\dY)
  EndIf
  
EndProcedure