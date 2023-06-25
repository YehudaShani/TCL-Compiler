# Using "Upvar"
proc outerProcedure {varName} {
    upvar $varName localVar
    puts "3. Inside the outerProcedure:"
    puts "4. localVar before modification: $localVar"
    set localVar "Modified value"
}
set myVariable "Original value"
puts "1. Before calling outerProcedure:"
puts "2. myVariable: $myVariable"
outerProcedure myVariable
puts "5. After calling outerProcedure:"
puts "6. myVariable: $myVariable"
