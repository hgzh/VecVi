; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################
;
; OUTPUT PROPERTY CONTROL
;
; ###########################################################

Procedure.d GetOutputScale(*psV.VECVI, piAxis.i)
; ----------------------------------------
; public     :: gets the scale factor to use for the outputs
; param      :: *psV   - VecVi structure
;               piAxis - direction to get the scale for
;                        0: x axis
;                        1: y axis
; returns    :: (d) scale factor
; remarks    :: 
; ----------------------------------------

  If piAxis = 0
    ProcedureReturn *psV\d("ScaleX")
  ElseIf piAxis = 1
    ProcedureReturn *psV\d("ScaleY")
  EndIf
  
EndProcedure

Procedure SetOutputScale(*psV.VECVI, pdX.d = 1, pdY.d = 1)
; ----------------------------------------
; public     :: sets the scale factor to use for the following outputs
; param      :: *psV - VecVi structure
;               pdX  - (S: 1) scale to set for the x direction, see ScaleCoordinates()
;               pdY  - (S: 1) scale to set for the y direction, see ScaleCoordinates()
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  *psV\d("ScaleX") = pdX
  *psV\d("ScaleY") = pdY
  
EndProcedure

Procedure.d GetOutputOffset(*psV.VECVI, piOffset.i)
; ----------------------------------------
; public     :: gets the current output offset
; param      :: *psV     - VecVi structure
;               piOffset - which offset to get
;                          #TOP:  return top offset
;                          #LEFT: return left offset
; returns    :: (d) value of the specified offset
; remarks    :: 
; ----------------------------------------
  
  If piOffset = #TOP
    ProcedureReturn *psV\d("OutputOffsetTop")
  ElseIf piOffset = #LEFT
    ProcedureReturn *psV\d("OutputOffsetLeft")
  EndIf
  
EndProcedure

Procedure SetOutputOffset(*psV.VECVI, piOffset.i, pdValue.d)
; ----------------------------------------
; public     :: sets the current output offset
; param      :: *psV     - VecVi structure
;               piOffset - which offset to change
;                          #TOP:  set top offset
;                          #LEFT: set left offset
;               pdValue  - value of the specified offset
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------
  
  ; //
  ; prevent from trying to draw on strange values
  ; //
  If IsNAN(pdValue)
    pdValue = 0
  EndIf
  
  If piOffset = #TOP
    *psV\d("OutputOffsetTop") = pdValue
  ElseIf piOffset = #LEFT
    *psV\d("OutputOffsetLeft") = pdValue
  EndIf
  
EndProcedure

Procedure.i GetMultiPageOutput(*psV.VECVI)
; ----------------------------------------
; public     :: gets the output mode for single page output channels
; param      :: *psV - VecVi structure
; returns    :: (i) output mode
; remarks    :: 
; ----------------------------------------

  ProcedureReturn *psV\i("MultiPageOutput")

EndProcedure

Procedure SetMultiPageOutput(*psV.VECVI, piOutput.i, pdMargin.d = 0)
; ----------------------------------------
; public     :: sets the output mode for single page output channels
; param      :: *psV     - VecVi structure
;               piOutput - new output mode
;                          #False:      output only the page given in Output*()
;                          #VERTICAL:   output all pages in vertical order
;                          #HORIZONTAL: output all pages in horizontal order
;               pdMargin - (S: 0) which margin to use between the pages
;                          only used if piOutput > 0
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  If piOutput = #False
    If *psV\i("MultiPageOutput") = #VERTICAL
      *psV\d("OutputOffsetTop") = 0.0
    ElseIf *psV\i("MultiPageOutput") = #HORIZONTAL
      *psV\d("OutputOffsetLeft") = 0.0
    EndIf
  EndIf
  
  If piOutput = #VERTICAL
    *psV\iDrawMode = #DRAW_MULTIV
  ElseIf piOutput = #HORIZONTAL
    *psV\iDrawMode = #DRAW_MULTIH
  ElseIf piOutput = #False
    *psV\iDrawMode = #DRAW_SINGLE
  EndIf

  *psV\i("MultiPageOutput")       = piOutput
  *psV\d("MultiPageOutputMargin") = pdMargin
  *psV\i("NoReprocessing")        = 0
  
EndProcedure

Procedure.d GetOutputSize(*psV.VECVI, piOrientation.i)
; ----------------------------------------
; public     :: calculates the full size of the output
; param      :: *psV          - VecVi structure
;               piOrientation - which size to get
;                               #HORIZONTAL: get the horizontal size
;                               #VERTICAL:   get the vertical size
; returns    :: (d) full size
; remarks    :: 
; ----------------------------------------
  Protected.i i
  Protected.d dSize,
              dMax
; ----------------------------------------

  If piOrientation = #VERTICAL
    If *psV\i("MultiPageOutput") = #VERTICAL
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        dSize + *psV\Sections()\iNrPages * (*psV\Sections()\Size\dHeight + *psV\d("MultiPageOutputMargin")) - *psV\d("MultiPageOutputMargin")
      Next
      PopListPosition(*psV\Sections())
    Else
      dMax = 0
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        If *psV\Sections()\Size\dHeight > dMax
          dMax = *psV\Sections()\Size\dHeight
        EndIf
      Next
      PopListPosition(*psV\Sections())
      dSize + dMax
    EndIf
  ElseIf piOrientation = #HORIZONTAL
    If *psV\i("MultiPageOutput") = #HORIZONTAL
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        dSize + *psV\Sections()\iNrPages * (*psV\Sections()\Size\dWidth + *psV\d("MultiPageOutputMargin")) - *psV\d("MultiPageOutputMargin")
      Next
      PopListPosition(*psV\Sections())
    Else
      dMax = 0
      PushListPosition(*psV\Sections())
      ForEach *psV\Sections()
        If *psV\Sections()\Size\dWidth > dMax
          dMax = *psV\Sections()\Size\dWidth
        EndIf
      Next
      PopListPosition(*psV\Sections())
      dSize + dMax
    EndIf
  EndIf
  
  ProcedureReturn dSize
  
EndProcedure

Procedure.d GetCanvasOutputResolution(piCanvas.i)
; ----------------------------------------
; public     :: calculates the resolution for outputs on CanvasGadgets
; param      :: piCanvas - CanvasGadget ID
; returns    :: (d) resolution in dpi
; remarks    :: useful to control the display of the output (e.g. print preview)
; ----------------------------------------
  Protected.d dRes
; ----------------------------------------
  
  StartVectorDrawing(CanvasVectorOutput(piCanvas, #PB_Unit_Millimeter))
  dRes = VectorResolutionX()
  StopVectorDrawing()
  
  ProcedureReturn dRes
  
EndProcedure

Procedure.d GetTextWidth(*psV.VECVI, pzText.s)
; ----------------------------------------
; public     :: calculates the needed width of the given text in the current font.
; param      :: *psV   - VecVi structure
;               pzText - text to calculate the width
; returns    :: (d) needed text width
; remarks    :: 
; ----------------------------------------
  Protected.i iImage
  Protected.d dWidth
; ----------------------------------------
  
  iImage = CreateImage(#PB_Any, 1, 1)
  If Not IsImage(iImage)
    ProcedureReturn 0
  EndIf
  
  If StartVectorDrawing(ImageVectorOutput(iImage, #PB_Unit_Millimeter))
    VectorFont(FontID(*psV\i("CurrentFont")), *psV\d("FontSize"))
    dWidth = VectorTextWidth(pzText, #PB_VectorText_Visible)
    StopVectorDrawing()
  EndIf
  
  FreeImage(iImage)
  
  ProcedureReturn dWidth
  
EndProcedure

Procedure.d GetParagraphHeight(*psV.VECVI, pzText.s, pdWidth.d)
; ----------------------------------------
; public     :: calculates the needed height of the given paragraph in the current font.
; param      :: *psV    - VecVi structure
;               pzText  - text to calculate the height
;               pdWidth - available width
; returns    :: (d) needed text width
; remarks    :: 
; ----------------------------------------
  Protected.i iImage
  Protected.d dHeight
; ----------------------------------------
  
  iImage = CreateImage(#PB_Any, 1, 1)
  If Not IsImage(iImage)
    ProcedureReturn 0
  EndIf
  
  If StartVectorDrawing(ImageVectorOutput(iImage, #PB_Unit_Millimeter))
    VectorFont(FontID(*psV\i("CurrentFont")), *psV\d("FontSize"))
    dHeight = VectorParagraphHeight(pzText, pdWidth, *psV\Size\dHeight)
    StopVectorDrawing()
  EndIf
  
  FreeImage(iImage)
  
  ProcedureReturn dHeight
  
EndProcedure

Procedure.s GetImageReferencePath(*psV.VECVI, pzName.s)
; ----------------------------------------
; public     :: gets the reference path to the given image
; param      :: *psV    - VecVi structure
;               pzName  - image name
; returns    :: (s) reference path
; remarks    :: 
; ----------------------------------------

  ForEach *psV\Images()
    If *psV\Images()\zName = pzName
      ProcedureReturn *psV\Images()\zRefPath
    EndIf
  Next

EndProcedure

Procedure SetImageReferencePath(*psV.VECVI, pzName.s, pzPath.s)
; ----------------------------------------
; public     :: sets a reference path to the image if a reload is needed
; param      :: *psV    - VecVi structure
;               pzName  - image name
;               pzPath  - reference path
; returns    :: (nothing)
; remarks    :: 
; ----------------------------------------

  ForEach *psV\Images()
    If *psV\Images()\zName = pzName
      *psV\Images()\zRefPath = pzPath
    EndIf
  Next

EndProcedure