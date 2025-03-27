**v.1.00 (2017-11-17)**
- first version

**v.1.01 (2017-11-22)**
- various bug fixes
- added SetOutputScale() / GetOutputScale()
- added GetPageWidth() / GetPageHeight()

**v.1.02 (2017-12-15)**
- fixed GetXPos() / GetYPos()
- merged VECVI_HEADER & VECVI_FOOTER structure
- merged position constants (#BORDER_, #ALIGN_, #MARGIN_, #LN_)
- added SetLineStyle() / GetLineStyle()
- added SetOutputOffset() / GetOutputOffset()
- added Rectangle(), Sector(), Curve()

**v.1.03 (2017-12-19)**
- fixed bug with lines and offsets
- renamed constants: #ORIENTATION_* to #*
- added GetSinglePageOutput() / SetSinglePageOutput()
- added GetOutputSize()
- added GetRealPageStartOffset()
- added GetPageCount()
- added piNet support to GetPageWidth() / GetPageHeight()
- added GetCanvasOutputResolution()

**v.1.04 (2018-01-06)**
- fixed bug with orientations and format
- fixed bug with cell vertical/horizontal alignment
- fixed bug with cell borders
- fixed bugs with page breaks
- fixed bugs with total page count calculation

**v.1.05 (2018-02-25)**
- added GetFontSize() / SetFontSize()
- added GetFontStyle() / SetFontStyle()
- added GetTextWidth()
- changed internal image handling

**v.1.06 (2019-01-31)**
- added CanvasImage output channel
- fixed bug with negative x/y position changes
- fixed bug in GetPageHeight() using piNet parameter

**v.1.10 (2020-07-24)**
- completely reworked processing and drawing engine
- added Process()
- added GetBackColor() / SetBackColor()
- added reset possibility to SetFillColor(), SetTextColor(), SetLineColor(), SetLineStyle()
- renamed *Page*() commands to *Section*() for clarification
- renamed GetRealPageCount() to GetPageCount()
- renamed GetRealPageStartOffset() to GetPageStartOffset()
- renamed *SinglePageOutput() commands to *MultiPageOutput()
- fixed bug in GetLineStyle()
- fixed various bugs in processing and drawing engine
- drawing of bigger documents is now much faster

**v.1.11 (2022-10-11)**
- fixed bug with pagebreak and x position reset

**v.1.12 (2023-10-10)**
- fixed bug causing crash when section is empty

**v.1.13 (2024-04-02)**
- added DuplicateSection(), DuplicateBlock()
- added OutputPDF()/OutputSVG() support for all OS
- changed OutputSVG() to require a page for output
- changed BeginSection() and BeginBlock() to return a handle of the created section or block
- fixed bugs with OutputPDF() and OutputSVG()
- fixed another bug causing crash if section is empty
- removed CanvasImage output

**v.1.14 (2024-04-04)**
- changed the output functions to have a return value indicating output success
- fixed bugs with DuplicateBlock() and DuplicateSection()

**v.1.15 (2024-10-03)**
- added GetParagraphHeight()
- changed ParagraphCell() to return the height of the new paragraph cell
- fixed bug with line numbering and empty sections

**v.1.20 (???)**
- added ReplaceHeader(), ReplaceFooter(), AppendHeader(), AppendFooter()
- added variable support with GetVariable(), SetVariable(), RemoveVariable()
- added named position support with GetNamedPos(), SetNamedPos(), UseNamedPos()
- added LoadFile()/SaveFile()
- added pzName parameter to ImageCell()
- added GetImageReferencePath()/SetImageReferencePath()
- changed internal image handling to load the same image only once
