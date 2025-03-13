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

The same VecVi document can be used to output to different output types. This enables you to create a preview in a CanvasGadget before sending the document
to the printer. For the canvas, image and window output, the output object has to be an already correctly initialized PureBasic object. For use with a printer,
you'll have to create the printing job before using the output function. SVG and PDF output take a filename as parameter and output to the disk, nothing else
has to be initialized before saving as a file.
 
## Multi page output
Output types differ in how they support output of multiple pages. In general, there are three ways to handle multiple pages in the VecVi document while outputting:
- *single*: only one page is shown at once
- *multi*: multiple pages may be shown at once
- *paged*: multiple pages are supported and the output supports 'real' pages

Paged output is only supported by Printer and PDF output types. These output types implement a native concept of 'pages', so a VecVi document can be
transformed accordingly. SVG requires single page output as there isn't such thing like pages in svg files. Therefore, you'll always have to specify
a page you want to output when using the svg output type.

Canvas, image and window output types accept both single and multi page output. Multiple page output is mimicked by displaying a page border and margin
between the pages. To switch between multi and single page output for these output types, use ```VecVi:SetMultiPageOutput()```.

> SetMultiPageOutput(*psV.VECVI, piOutput.i, pdMargin.d = 0)

*SetMultiPageOutput* takes the VecVi structure, an output and a margin parameter to control the multi page output.
The output parameter can have the following values:
- ```#False```: multi page output deactivated, use single page output
- ```VecVi::VERTICAL```: activate multi page output and display the pages in vertical direction
- ```VecVi::HORIZONTAL```: activate multi page output and display the pages in horizontal direction

The margin parameter specifies the distance between two page borders in multi page output.

## Scaling and offset
Scaling and offset only make sense in the context of canvas, image and gadget output, but can be used also in other output types.
You are able to scale the VecVi document and define the root starting position of the output. This is useful if you have canvas output enabled
and want to allow the user to zoom in, out and move the document around with the mouse.
All scaling and offset functions always apply to the whole document.

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
## Width and height
There are two functions to get a page's width and height. Both are working in a similar way and take a section and a net size parameter.
- ```VecVi::GetPageWidth()```
- ```VecVi::GetPageHeight()```

With the section parameter, it is possible to get the size of the pages in the section with the given index (first section is has the index 1).
If it is ```0```, the functions will return the size of the current page.

The net parameter controls wheter the page margins should be included in the returned value.
If it is ```#True```, it will return the page size without top and bottom or left and right margins, so this is the remaining size for adding
content after respecting the page's margins. For page height, it will also account for the size of header and footer.
When given ```#False```, the absolute width or height of the page is returned, as defined in the format parameter of *BeginSection* or *Create*.

## Header and footer
VecVi supports adding header and footer to pages. They will be displayed on every page and included in the calculation of the remaining page height,
which is also important for determining where to set page breaks. Both header and footer consist of one single block.
To start defining a header or a footer, use the following functions:
- ```VecVi::BeginHeader()```
- ```VecVi::BeginFooter()```

Just like for sections and blocks, all elements that are defined after a *Begin* function are considered part of the header/footer,
until another *Begin* function is called. The header and footer defined this way bill be displayed on all pages that are created afterwards.
You can also call one of *BeginHeader* or *BeginFooter* again to define a new header or footer for the next page.
To clear a header or footer, call the *Begin* function without specifying any element afterwards.
For manipulating already defined headers and footers, see the chapter in the advanced section.

## Page breaks
Page breaks happen under the following circumstances:
- a new section is defined. Defining a new section will always cause a page break because it is possible to change format or orientation for the new section.
- a new block is defined with disallowed page breaks and the width of the elements inside the block exceed the remaining vertical space of the page.
- a new element is defined inside a block with allowed page breaks and the element's width exceed the remaining vertical space of the page.

Forced page breaks inside a section are currently not supported. You'll have to create a new section for this.

## Page numbering
Pages can be automatically numbered. The current page number and the total number of pages are available for usage inside VecVi text elements.
This is possible via usage of tokens. Tokens represent the number of the current or the total number of pages and are replaced by the actual value while processing.
To change the token, use ```VecVi::SetPageNumberingTokens()```.

> VecVi::SetPageNumberingTokens(*psV.VECVI, pzCurrent.s = "", pzTotal.s = "")

You can set both tokens at one. The initial tokens are ```{Nb}``` for the current page number and ```{NbTotal}``` for the page count.
You can use any string as the token, and the token defined will be replaced in all occurrences on the page.

Page numbering can be controlled on section level. For this, *BeginSection* supports a numbering parameter. Possible values are:
- ```-1```: pages won't be numbered. If this is set for the first section, the page counter will remain at zero until the first page that is numbered (in another following section) is created.
- ```0```: page numbering will continue from the value of the previous section. This is the standard behavior.
- values higher than zero will be used as the page number of the first page in the section.

Note: if page numbering is disabled for a section, the pages of the section will also not count for the total number of pages in the VecVi document.
To determine the full amount of pages in a document including pages without numbering, you can use ```VecVi::GetPageCount()```:

> VecVi::GetPageCount(*psV.VECVI, piSection.i = 0)

The optional section parameter allows you to count only the pages inside the section width the specified index.
If not set, the function will return the number of pages in the whole document.

# Customization
## Font
VecVi's text elements support styling through fonts. Before using any text elements, you should provide a font definition for your VecVi document.
This can be done by ```VecVi::SetFont()```.

> VecVi::SetFont(*psV.VECVI, pzName.s, piStyle.i = 0, pdSize.d = 0)

You can specify the font name, the font style (this matches PureBasic's constants for *LoadFont()* and a font size in millimeters.

If you want to change the font, it is possible to call *SetFont()* again. If you only want to change one aspect of the current font (e.g. reducing the font size),
you can use shorthand functions as follows:
- ```VecVi::SetFontSize()```: change only the font size of the following elements
- ```VecVi::SetFontStyle()```: change only the font style of the following elements

For *SetFontStyle()*, you can specify ```0``` as the font style to deactivate any special styling.

To change the text color, use ```VecVi::SetTextColor()```.

## Lines
It is possible to set the color, width and segment style of all lines VecVi outputs. This applies to borders of cells and geometric elements
and to horizontal lines, vertical lines, xy lines and curves as well. Line styling is controlled by the following functions:
- ```VecVi::SetLineSize()```: change the width of the lines in the following elements
- ```VecVi::SetLineColor()```: change the color of the lines in the following elements. Requires an rgba value.
- ```VecVi::SetLineStyle()```: change the way the lines are drawn.

## Filling and background
VecVi allows filling of cells and geometric forms. To specify the color used for this, you can use ```VecVi::SetFillColor()```.

There are two types of background colors: the standard one is the background of the VecVi document's pages (the 'paper'), which natively is white.
The other background is the 'desk color' for canvas output, which defaults to dark grey. You can specify both background colors using ```VecVi::SetBackColor()```.

# Advanced functions
## Block and section pointers
*BeginSection* and *BeginBlock* return a pointer to the section or block that is started with these functions. You need the pointers for performing
advanced actions with sections and blocks:

> *Section = VecVi::BeginSection(*psV.VECVI, pzFormat.s = #FORMAT_INHERIT, piOrientation.i = #INHERIT, piNumbering = 0)
> 
> *Block = VecVi::BeginBlock(*psV.VECVI, piPageBreak.i = #True)

## Duplicating sections and blocks
Sections and blocks can be duplicated. For this, the block or section pointer returned by *BeginSection* or *BeginBlock* is needed.
To duplicate sections or blocks, use the following functions:
- ```VecVi::DuplicateSection()```
- ```VecVi::DuplicateBlock()```

These functions take a VecVi structure, a section or block pointer and a position and relative element parameter
to determine the position of the duplicated section or block:

> VecVi::DuplicateBlock(*psV.VECVI, *psBlock.VECVI_BLOCK, piPos = #RIGHT, *psRelative.VECVI_BLOCK = #Null)
> 
> VecVi::DuplicateSection(*psV.VECVI, *psSection.VECVI_SECTION, piPos = #RIGHT, *psRelative.VECVI_SECTION = #Null)

The position parameter can have one of the following values:
- ```VecVi::#TOP```: add duplicated section/block as first item of its sibling items
- ```VecVi::#BOTTOM```: add duplicated section/block as last item of its sibling items
- ```VecVi::#LEFT```: add duplicated section/block before the current item
- ```VecVi::#RIGHT```: add duplicated section/block after the current item

The relative parameter allows you to choose the element or block from which the positioning is determined.
It takes a pointer to the section or block which is considered the 'base' item for the duplicated one.
This is useful with ```VecVi::#LEFT``` or ```VecVi::#RIGHT``` in the position parameter.
It doesn't have an effect for duplicating to the first or last position in the list of sections or blocks.
If omitted, the position of the new item is determined from the source block or section that is duplicated.

## Variables
Variables can be used inside text elements. While processing, they get replaced by the value that is currently bound to the variable.

To call a variable from a VecVi text element, enclose its name in double curly brackets as follows: ```{{<NAME>}}```.
*NAME* can be any string and is case-sensitive.

Variable binding is controlled by the following functions:
- ```VecVi::SetVariable()```: bind a variable to the given value
- ```VecVi::GetVariable()```: get the value that is currently bound to the variable
- ```VecVi::RemoveVariable()```: remove the variable binding

Variables work on block level: inside a block, a variable can only have one value bound to it, but the value can change for the next block.
The binding between a variable and a value remains the same for all calls until it is changed using *SetVariable* again or removed with *RemoveVariable*.
If a block is duplicated, the variable bindings will also be updated to the current ones.

If a variable is called without a value being bound to it, the call syntax will remain unchanged in the processed document.
You can also bind an empty string to the value, in that case the call will disappear from the output.

## Manipulating header and footer
After a header or footer was defined, it is possible to replace it completely or append elements to it.

Replacing the whole header or footer can be done via ```VecVi::ReplaceHeader()``` resp. ```VecVi::ReplaceFooter()```. These functions take the pointer
of an already generated block and copy it to the header or footer area, replacing the current elements there. The source block remains valid.

It is also possible to append elements of another block to the header or footer. This is allowed through the functions ```VecVi::AppendHeader()``` and
```VecVi::AppendFooter()```. The elements of the source block will be appended to the elements already present in the header or footer.

## Named positions
Named positions act like tab stops in the document that can be accessed by using a name instead of a position.
You can define a position on both the x and y axis, or make VecVi ignore one axis and change only the other.
Named positions can be a shorthand function for *SetXPos* and *SetYPos*.

To define a named position, use ```VecVi::SetNamedPos()```.

> VecVi::SetNamedPos(*psV.VECVI, pzName.s, pdX.d = -1, pdY.d = -1)

The name parameter is the identifier for the position. If you specify both the x or y parameter, the named position will contain a specific point on the page.
If the x parameter is omitted, the named position will be on a horizontal line on the given y position. If the y parameter is omitted, the named position
will be on a vertical line on the given x position. The exact position will then be determined from the given x or y position and the current position
that was not specified in the named position.

To return the a position point of a named position, there is ```VecVi::GetNamedPos()```.

> VecVi::GetNamedPos(*psV.VECVI, pzName.s, piXY.i)

The XY parameter controls which axis position is returned: ```0``` will return the x position, ```1``` the y position of the named position with the given name.

To apply a named position during element definition, use ```VecVi::UseNamedPos()```. The position will then be determined like described above.

Named positions work on global level: they are the same in the whole document and for all sections and blocks.
