# What is VecVi?
VecVi is a PureBasic module that allows you to create documents using the VectorDrawing library of PureBasic and output it to one of the following:
- CanvasGadget
- Image
- Window
- Printer
- SVG file
- PDF file

# Basic usage
To use VecVi, include the VecVi source file in your project.

    XIncludeFile "VecVi.pb"

Every function of the VecVi module requires a pointer to a VecVi structure. You can allocate a VecVi structure by using ```VecVi::Create()```.
This function takes a page format and an orientation as parameter and returns a pointer to a VecVi structure:

    *VecVi = VecVi::Create(VecVi::#FORMAT_A4, VecVi::#VERTICAL)

There are some predefined ```#FORMAT_``` constants for easy usage, but you may also use a custom format by passing the size of the page's short
and long side in millimeters, separated by comma: ```210,297``` is the same as ```VecVi::#FORMAT_A4```. Depending on the value passed as
orientation, the long side is either the horizontal or the vertical side.

If there were any errors during the creation of the VecVi structure, the pointer will be zero. If ```*VecVi``` is nonzero, the initialization
succeeded and you are ready to start creating your VecVi document.

## Sections and Blocks
VecVi documents are structured in sections and blocks. A section groups a list of blocks and a block groups a list of elements. Elements are the
items that are actually displayed in an output.

A VecVi document can have as many **sections** as wanted. Every section can have an own page format and orientation or inherit it from the document.
To begin defining a section, use ```VecVi::BeginSection()```.

> VecVi::BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)

*BeginSection* takes the VecVi structure and some optional parameters. Format and orientation can be set in the same way like for the document.
If omitted, the section inherits the values from the document. *piNumbering* controls the page numbering behavior. See the chapter for page
numbering for more information.

Sections always start on a new page. If you create a new section after an existing one, it will cause a page break in your document.

**Blocks** contain elements that semantically belong together. A section can have as many blocks as needed. A block always starts from the left
margin of the document and has to be defined inside a section, that means, that you will need to create a section before creating the first block.

To begin defining a block, use ```VecVi::BeginBlock()```.

> VecVi::BeginBlock(*psV.VECVI, piPageBreak.i = #True)

*BeginBlock* only takes one parameter besides the VecVi structure, and that is a switch to control page break behavior. One of the most important features
of a block is to allow keeping the block elements together on one page. If *piPageBreak* is set to ```#False```, page breaks are not allowed inside the
block. If the height of all the elements exceeds the remaining vertical space on the page, VecVi will insert a page break before the block. If page breaks
are allowed, as many elements of the block as possible will be displayed on the page, the rest breaks to a new page.

## Elements
Elements contain the actual content of the VecVi document, while sections and blocks structure it. Currently, VecVi supports these elements:
- ```VecVi::TextCell()```: single-line text with width/height boundaries, borders, background filling, vertical and horizontal alignment
- ```VecVi::ParagraphCell()```: multi-line text with width/height boundaries, borders, background filling and horizontal alignment
- ```VecVi::ImageCell()```: image transclusion with width/height boundaries, borders, background filling, vertical and horizontal alignment
- ```VecVi::HorizontalLine()```
- ```VecVi::VerticalLine()```
- ```VecVi::XYLine()```: line from x to y position
- ```VecVi::Curve()```: curved line between two points
- ```VecVi::Rectangle()```: geometric element with width/height boundaries, borders and background filling
- ```VecVi::Sector()```: ellipse sector with width/height boundaries, sector boundaries, borders and background filling
- ```VecVi::Ln()```: manual linebreak
- ```VecVi::Sp()```: variable space

All elements have to be defined inside a block. It is possible to customize the appearance of the elements, like changing text font, text size, fill color,
line style, line color and cell margins.

## Positioning
To ease positioning, VecVi by default uses a relative positioning approach while defining elements. That means that the position of an element is determined
by the position and size of the previously defined element. To control this, the VecVi elements (besides the line elements) have a ```piLn``` parameter,
that supports up to three modes regarding the position of the following element:
- ```VecVi::#RIGHT```: move the next element to the right outer corner of the current element (change x position, keep y position unchanged)
- ```VecVi::#BOTTOM```: move the next element to right below the current element (change y position, keep x position unchanged)
- ```VecVi::#NEWLINE```: move the next element to a new line (set x position to the left page margin, change y position to below the current element).

To add manual linebreaks or spaces to the right, use the ```VecVi::Ln()``` and ```VecVi::Sp()``` elements. ```VecVi::Ln()``` takes a parameter for the
height of the linebreak, if omitted, it takes the last specified linebreak height or the height of the last defined element.

If you need absolute positioning, VecVi supports this through the functions ```VecVi::SetXPos()``` and ```VecVi::SetYPos()```. With these functions, it is
also possible to do relative movements from the current position by specifying an offset. Both approaches can be mixed.

## Example
The following code creates a VecVi document, a section, a block and a table with 4 cells.

    ; create the VecVi structure
    *VecVi = VecVi::Create(VecVi::#FORMAT_A4, VecVi::#VERTICAL)

    ; create a section by using page format and orientation from the document
    VecVi::BeginSection(*VecVi)

    ; create a block in the section
    VecVi::BeginBlock(*VecVi)

    ; create table with 4 cells inside of the current block
    ; 50 is the width, 5 the height in millimeters of the current cell
    ; VecVi::#ALL causes the cell to have borders on all four sides
    VecVi::TextCell(*VecVi, 50, 5, "Cell 1", VecVi::#RIGHT, VecVi::#ALL)   ; VecVi::#RIGHT shifts the next element to the right to create a second column
    VecVi::TextCell(*VecVi, 50, 5, "Cell 2", VecVi::#NEWLINE, VecVi::#ALL) ; VecVi::#NEWLINE causes a line break to create a second row
    VecVi::TextCell(*VecVi, 50, 5, "Cell 3", VecVi::#RIGHT, VecVi::#ALL)
    VecVi::TextCell(*VecVi, 50, 5, "Cell 4", VecVi::#NEWLINE, VecVi::#ALL)

## Definition logic
As seen in the above example, the *Begin* functions make all the following blocks or elements belong to the block or section that was begun the last, until
a new block or section is begun (with another call to a *Begin* function) or the output starts.

# Output
## Output types
VecVi supports the following output types:
- ```VecVi::OutputCanvas()```: output the document to a PureBasic CanvasGadget
- ```VecVi::OutputImage()```: draw the document to a PureBasic image object
- ```VecVi::OutputWindow()```: draw the document on the window itself
- ```VecVi::OutputPrinter()```: print the document directly
- ```VecVi::OutputSVG()```: save the document as a svg file on the disk
- ```VecVi::OutputPDF()```: save the document as a pdf file on the disk

The same VecVi document can be used to output to different output types. This enables you to create a preview in a CanvasGadget before sending the document to the printer. For the canvas, image and window output, the output object has to be an already correctly initialized PureBasic object. For use with a printer, you'll have to create the printing job before using the output function. SVG and PDF output take a filename as parameter and output to the disk, nothing else has to be initialized before saving as a file.
 
## Multi page output
Output types differ in how they support output of multiple pages. In general, there are three ways to handle multiple pages in the VecVi document while outputting:
- *single*: only one page is shown at once
- *multi*: multiple pages may be shown at once
- *paged*: multiple pages are supported and the output supports 'real' pages

Paged output is only supported by Printer and PDF output types. These output types implement a native concept of 'pages', so a VecVi document can be transformed accordingly. SVG requires single page output as there isn't such thing like pages in svg files. Therefore, you'll always have to specify a page you want to output when using the svg output type.

Canvas, image and window output types accept both single and multi page output. Multiple page output is mimicked by displaying a page border and margin between the pages. To switch between multi and single page output for these output types, use ```VecVi:SetMultiPageOutput()```.

> SetMultiPageOutput(*psV.VECVI, piOutput.i, pdMargin.d = 0)

*SetMultiPageOutput* takes the VecVi structure, an output and a margin parameter to control the multi page output. The output parameter can have the following values:
- ```#False```: multi page output deactivated, use single page output
- ```VecVi::VERTICAL```: activate multi page output and display the pages in vertical direction
- ```VecVi::HORIZONTAL```: activate multi page output and display the pages in horizontal direction

The margin parameter specifies the distance between two page borders in multi page output.

## Scaling and offset
Scaling and offset only make sense in the context of canvas, image and gadget output, but can be used also in other output types. You are able to scale the VecVi document and define the root starting position of the output. This is useful if you have canvas output enabled and want to allow the user to zoom in, out and move the document around with the mouse. All scaling and offset functions always apply to the whole document.

Scaling is done with ```VecVi::SetOutputScale()```.

> VecVi::SetOutputScale(*psV.VECVI, pdX.d = 1, pdY.d = 1)

You have to supply a relative scaling value for x and y axis. The original scaling can be restored by setting the scale to 1 for both axes.

The offset can be set using ```VecVi::SetOutputOffset()```. The root position is always on the upper left corner of the output area.

> VecVi::SetOutputOffset(*psV.VECVI, piOffset.i, pdValue.d)

The offset parameter takes one of the following values:
- ```VecVi::#TOP```: set the top offset
- ```VecVi::#LEFT```: set the left offset

After setting the offset target, you can specify the actual offset through the value parameter. The initial offset is 0 for both top and left.

# Pages
## Properties
## Header and footer
## Page breaks
## Page numbering

# Customization
## Font
VecVi's text elements support styling through fonts. Before using any text elements, you should provide a font definition for your VecVi document. This can be done by ```VecVi::SetFont()```.

> VecVi::SetFont(*psV.VECVI, pzName.s, piStyle.i = 0, pdSize.d = 0)

You can specify the font name, the font style (this matches PureBasic's constants for *LoadFont()* and a font size in millimeters.

If you want to change the font, it is possible to call *SetFont()* again. If you only want to change one aspect of the current font (e.g. reducing the font size), you can use shorthand functions as follows:
- ```VecVi::SetFontSize()```: change only the font size of the following elements
- ```VecVi::SetFontStyle()```: change only the font style of the following elements

For *SetFontStyle()*, you can specify ```0``` as the font style to deactivate any special styling.

To change the text color, use ```VecVi::SetTextColor()```.

## Lines
It is possible to set the color, width and segment style of all lines VecVi outputs. This applies to borders of cells and geometric elements and to horizontal lines, vertical lines, xy lines and curves as well. Line styling is controlled by the following functions:
- ```VecVi::SetLineSize()```: change the width of the lines in the following elements
- ```VecVi::SetLineColor()```: change the color of the lines in the following elements. Requires an rgba value.
- ```VecVi::SetLineStyle()```: change the way the lines are drawn.

## Filling and background
VecVi allows filling of cells and geometric forms. To specify the color used for this, you can use ```VecVi::SetFillColor()```.

There are two types of background colors: the standard one is the background of the VecVi document's pages (the 'paper'), which natively is white. The other background is the 'desk color' for canvas output, which defaults to dark grey. You can specify both background colors using ```VecVi::SetBackColor()```.

# Advanced functions
## Duplicating sections and blocks
## Variables
## Manipulating header and footer
## Named positions
