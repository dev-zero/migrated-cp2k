<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output indent="no" method="text" omit-xml-declaration="yes" version="2.0"/>
<xsl:template match="/">
" Vim syntax file
" Language: cp2k input files
" Maintainer: based on work by Alin M Elena available at https://gitorious.org/cp2k-vim
" Revision: 13th of September 2010
" History: 
" - XSLT dump and improved syntax highlighting (10.12.2013, Matthias Krack)

if exists("b:current_syntax")
  finish
endif

syn case ignore

"----------------------------------------------------------------/
" CP2K numbers used in blocks
"----------------------------------------------------------------/
" Regular int like number with - + or nothing in front
" e.g. 918, or -49

syn match cp2kNumber '\d\+'
syn match cp2kNumber '[-+]\d\+'

" Floating point number with decimal no E or e (+,-)
" e.g. 0.198781, or -3.141592

syn match cp2kNumber '\d\+\.\d*'
syn match cp2kNumber '[-+]\d\+\.\d*'

" Floating point like number with E and no decimal point (+,-)
" e.g. 3E+9, 3e+09, or -3e+02

syn match cp2kNumber '[-+]\=\d[[:digit:]]*[eE][\-+]\=\d\+'
syn match cp2kNumber '\d[[:digit:]]*[eE][\-+]\=\d\+'

" Floating point like number with E and decimal point (+,-)
" e.g. -3.9188e+09, or 0.9188E-93

syn match cp2kNumber '[-+]\=\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'
syn match cp2kNumber '\d[[:digit:]]*\.\d*[eE][\-+]\=\d\+'

"----------------------------------------------------------------/
" CP2K Boolean entities
"----------------------------------------------------------------/

syn keyword cp2kBool true false T F yes no

"-----------------------------------------------------------------/
" CP2K comments
"-----------------------------------------------------------------/

syn keyword cp2kTodo TODO FIXME NOTE REMARK
syn match cp2kComment "#.*$" contains=cp2kTodo
syn match cp2kComment "!.*$" contains=cp2kTodo

"----------------------------------------------------------------/
" CP2K predefined constants
"----------------------------------------------------------------/
<xsl:for-each-group select="//ITEM" group-by="NAME">
<xsl:sort select="NAME"/>
syn keyword cp2kConstant <xsl:value-of select="NAME"/>
</xsl:for-each-group>

"----------------------------------------------------------------/
" CP2K sections
"----------------------------------------------------------------/
<xsl:for-each-group select="//SECTION" group-by="NAME">
<xsl:sort select="NAME"/>
syn keyword cp2kSection <xsl:value-of select="NAME"/>
</xsl:for-each-group>
syn keyword cp2kSection END
syn match cp2kBegSection "^\s*&amp;\w\+" contains=cp2kSection nextgroup=test
syn match test ".*[^!#]" contains=cp2kConstant,cp2kNumber,cp2kBool,cp2kComment,cp2kSection

"----------------------------------------------------------------/
" CP2K keywords
"----------------------------------------------------------------/
<xsl:for-each-group select="//KEYWORD" group-by="NAME[@type='default']">
<xsl:sort select="NAME[@type='default']"/>
syn keyword cp2kKeyword <xsl:value-of select="NAME"/>
</xsl:for-each-group>
syn match cp2kBegKeyword "^\s*\w\+" contains=cp2kKeyword

"-----------------------------------------------------------------/
" CP2K preprocessing directives
"-----------------------------------------------------------------/

syn keyword cp2kPreProc endif if include set
syn match cp2kBegPreProc "^\s*@\w\+" contains=cp2kPreProc

"----------------------------------------------------------------------------/
" Final setup
"----------------------------------------------------------------------------/

let b:current_syntax="cp2k"
set fdm=manual
set foldlevel=3

"----------------------------------------------------------------------------/
" CP2K keyword highlighting rules
"----------------------------------------------------------------------------/

hi def link cp2kComment Comment
hi def link cp2kTodo Todo
hi def link cp2kBool Boolean
hi def link cp2kNumber Number
hi def link cp2kSection Type
hi def link cp2kKeyword Identifier
hi def link cp2kConstant Constant
hi def link cp2kPreProc PreProc
</xsl:template>
</xsl:stylesheet>
