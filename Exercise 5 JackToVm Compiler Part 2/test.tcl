

source "SymbolTable.tcl"
source "SR_SymbolTable.tcl"
source "TokenizerHelper.tcl"
source "VMWriter.tcl"

set v [VMWriter VMWriter::new]
$v setFile "hop"
# $v writeReturn
# $v setFile "hop2"
# $v writeLabel "hi

# Create the dictionary
set myDict {
    "+" "add"
    "-" "sub"
    "=" "eq"
    "&gt;" "gt"
    "&lt;" "lt"
    "|" "or"
    "&amp;" "and"
}

# Convert the dictionary to an array
array set myArray $myDict

# Access the values using keys
puts "Value for key \"+\": $myArray(+)"
puts "Value for key \"-\": $myArray(-)"
puts "Value for key \"=\": $myArray(=)"
puts "Value for key \"&gt;\": $myArray(&gt;)"
puts "Value for key \"&lt;\": $myArray(&lt;)"
puts "Value for key \"|\": $myArray(|)"
puts "Value for key \"&amp;\": $myArray(&amp;)"




# set st [SymbolTable SymbolTable::new]

# $st setType [$st setCategory [$st addSymbolWithName "d0"] "field"] "int"
# $st addUsageDecl "name" 
# $st setCategory [$st addSymbolWithName "d1"] "class"
# $st addUsageUsed "name2" 

# puts [$st allSymbols] 

# puts [concat "d0's category is: " [$st getCategory [$st getIndexOfSymbolByName "d0"]] ]
# puts [concat "d0's index is: " [$st getIndex [$st getIndexOfSymbolByName "d0"]] ]


# set st_sr [SR_SymbolTable SR_SymbolTable::new]
# $st_sr reset
# $st_sr setCategory [$st_sr addSymbolWithName "d4"] "class"
# $st_sr setCategory [$st_sr addSymbolWithName "d5"] "class"

# puts [$st allSymbols]
# puts [$st_sr allSymbols]