

source "SymbolTable.tcl"

set st [SymbolTable new]
$st addSymbolWithName "newguy"
puts [$st allSymbols] 
set index [$st getIndexOfSymbolByName "newguy"]
$st setCategory $index "newCategory"
$st setType $index "newType"
$st setIndex $index "newIndex"
puts [$st allSymbols]

