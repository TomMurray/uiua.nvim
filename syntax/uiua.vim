" Vim syntax file for the Uiua array language (https://www.uiua.org).
" Glyphs are grouped by arity, mirroring Uiua's own colour convention.

if exists("b:current_syntax")
  finish
endif

" Comments
syntax match uiuaComment "#.*$" contains=@Spell

" Strings & characters
syntax region uiuaString start=+"+ skip=+\\"+ end=+"+
syntax region uiuaFormatString start=+\$"+ skip=+\\"+ end=+"+
syntax match uiuaMultiString +\$\s.*$+
syntax match uiuaChar +@\\\?.+

" Numbers (¯ is Uiua's negation prefix)
syntax match uiuaNumber "¯\?\<\d\+\(\.\d\+\)\?\>"
syntax match uiuaNumber "¯\?\.\d\+"

" Constants
syntax keyword uiuaConstant eta pi tau infinity
syntax match uiuaConstant "[ηπτ∞]"

" Identifiers: user-defined names and un-formatted ascii primitive names.
syntax match uiuaIdent "\<[A-Za-z][A-Za-z0-9_]*\>"

" Bindings and signatures
syntax match uiuaBinding "←\|↚\|~\|≔"
syntax match uiuaSignature "|"

" --- Primitive glyphs by arity ---
" Stack / planet notation
syntax match uiuaStack "[.,:∘⋅⊙⟜⊸◌;⊃⊓]"
" Monadic functions
syntax match uiuaMonadic "[¬±⌵√○∿⌊⌈⁅⧻△⇡⊢⊣⇌♭¤⍉⍏⍖⊚⊛⊝◴□⋕⍆⊠]"
" Dyadic functions
syntax match uiuaDyadic "[+×÷◿↧↥∠ℂ=≠<≤>≥⊟⊂⊏⊡↯↙↘↻◫▽⌕⊗∊∍]"
syntax match uiuaDyadic "[-−]"
" Monadic modifiers
syntax match uiuaMonModifier "[/\\∧≡∵⊞⍥°⌝˜˙˚]"
" Dyadic modifiers
syntax match uiuaDyModifier "[⊕⊜⍜⨬⍢⍣⨼]"

highlight default link uiuaComment      Comment
highlight default link uiuaString       String
highlight default link uiuaFormatString String
highlight default link uiuaMultiString  String
highlight default link uiuaChar         Character
highlight default link uiuaNumber       Number
highlight default link uiuaConstant     Constant
highlight default link uiuaIdent        Identifier
highlight default link uiuaBinding       Define
highlight default link uiuaSignature     Special
highlight default link uiuaStack        Delimiter
highlight default link uiuaMonadic      Function
highlight default link uiuaDyadic       Operator
highlight default link uiuaMonModifier  Keyword
highlight default link uiuaDyModifier   PreProc

let b:current_syntax = "uiua"
