; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; VARIABLE CONTROL
;
; ###########################################################

Procedure.s GetVariable(*psV.VECVI, pzVariable.s)
; ----------------------------------------
; public     :: gets the value of the given variable
; param      :: *psV       - VecVi structure
;               pzVariable - name of the variable
; returns    :: (s) variable value
; remarks    :: 
; ----------------------------------------
  
  If FindMapElement(*psV\Variables(), pzVariable)
    ProcedureReturn *psV\Variables(pzVariable)
  EndIf

EndProcedure

Procedure SetVariable(*psV.VECVI, pzVariable.s, pzValue.s)
; ----------------------------------------
; public     :: sets a variable to the given value.
; param      :: *psV       - VecVi structure
;               pzVariable - name of the variable
;               pzValue    - variable value
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  *psV\Variables(pzVariable) = pzValue

EndProcedure

Procedure RemoveVariable(*psV.VECVI, pzVariable.s)
; ----------------------------------------
; public     :: removes a variable.
; param      :: *psV       - VecVi structure
;               pzVariable - name of the variable
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  If FindMapElement(*psV\Variables(), pzVariable)
    DeleteMapElement(*psV\Variables(), pzVariable)
  EndIf

EndProcedure