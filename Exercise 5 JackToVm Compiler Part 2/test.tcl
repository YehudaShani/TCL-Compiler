

source "SymbolTable.tcl"
source "SR_SymbolTable.tcl"
source "TokenizerHelper.tcl"

set st [SymbolTable SymbolTable::new]

$st setCategory [$st addSymbolWithName "d0"] "class"
$st setCategory [$st addSymbolWithName "d1"] "class"

set st_sr [SR_SymbolTable SR_SymbolTable::new]
$st_sr reset
$st_sr setCategory [$st_sr addSymbolWithName "d4"] "class"
$st_sr setCategory [$st_sr addSymbolWithName "d5"] "class"

puts [$st allSymbols]
puts [$st_sr allSymbols]