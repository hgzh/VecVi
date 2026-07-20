; ###########################################################
; ################ VECVI (VectorView) MODULE ################
; ###########################################################

;   written by Andesdaf/hgzh, 2017-2026

;   this module allows you to create documents using the
;   VectorDrawing library of PureBasic and output it to a
;   CanvasGadget, Window, Image object, .svg file, .pdf file
;   or send it directly to a printer.

; ###########################################################
;                          LICENSING
; Copyright (c) 2017-2025 Andesdaf/hgzh

; Permission is hereby granted, free of charge, to any person
; obtaining a copy of this software and associated
; documentation files (the "Software"), to deal in the
; Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute,
; sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so,
; subject to the following conditions:

; The above copyright notice and this permission notice shall
; be included in all copies or substantial portions of the
; Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
; KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
; OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; ###########################################################

;                VERSION 1.21 FROM 2026-07-20

; ###########################################################

EnableExplicit

XIncludeFile "Public.pb"

Module VecVi
  EnableExplicit
  
  XIncludeFile "Internal.pb"
  XIncludeFile "Base.pb"
  XIncludeFile "Area.pb"
  XIncludeFile "ElementProperties.pb"
  XIncludeFile "OutputProperties.pb"
  XIncludeFile "Page.pb"
  XIncludeFile "Font.pb"
  XIncludeFile "Variable.pb"
  XIncludeFile "NamedPos.pb"
  XIncludeFile "Element.pb"
  XIncludeFile "Output.pb"
EndModule