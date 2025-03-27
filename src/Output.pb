; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; OUTPUT FUNCTIONS
;
; ###########################################################

Procedure.i OutputCanvas(*psV.VECVI, piGadget.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a canvas gadget.
; param      :: *psV     - VecVi structure
;               piGadget - canvas gadget ID
;               piPage   - page to show on the canvas
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _draw(*psV, #OUTPUT_CANVAS, piGadget, "", piPage)
  
EndProcedure

Procedure.i OutputImage(*psV.VECVI, piImage.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on an image.
; param      :: *psV     - VecVi structure
;               piGadget - image ID
;               piPage   - page to show on the image
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _draw(*psV, #OUTPUT_IMAGE, piImage, "", piPage)
  
EndProcedure

Procedure.i OutputWindow(*psV.VECVI, piWindow.i, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi on a window.
; param      :: *psV     - VecVi structure
;               piGadget - window ID
;               piPage   - page to show on the window
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _draw(*psV, #OUTPUT_WINDOW, piWindow, "", piPage)
  
EndProcedure

Procedure.i OutputPrinter(*psV.VECVI)
; ----------------------------------------
; public     :: outputs VecVi on a printer.
; param      :: *psV       - VecVi structure
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _draw(*psV, #OUTPUT_PRINTER, -1, "", 0)
  
EndProcedure

Procedure.i OutputSVG(*psV.VECVI, pzPath.s, piPage.i = 1)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
;               piPage - page to show on the window
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------
  
  ProcedureReturn _draw(*psV, #OUTPUT_SVG, -1, pzPath, piPage)

EndProcedure

Procedure.i OutputPDF(*psV.VECVI, pzPath.s)
; ----------------------------------------
; public     :: outputs VecVi to a .svg file.
; param      :: *psV   - VecVi structure
;               pzPath - full output path
; returns    :: (i) output state
;               0: error while creating output
;               1: output successful
; remarks    :: 
; ----------------------------------------

  ProcedureReturn _draw(*psV, #OUTPUT_PDF, -1, pzPath, 0)

EndProcedure