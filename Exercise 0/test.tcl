#!/usr/bin/tclsh


proc handleBuy {line} {
   set result "### BUY "
   append result [lindex $line 1]
   append result "$$$\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append result mult
   return $result

}

set fp [open "input.txt" r]
set file_data [read $fp]
puts $file_data

puts [lindex $file_data  1]

handleBuy file_data

close $fp