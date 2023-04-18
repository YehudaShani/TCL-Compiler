#!tclsh


proc handleBuy {line} {
   set result "### BUY "
   append result [lindex $line 1]
   append result " ###\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append result $mult
   return $result

}

proc handleSell {line} {
   set result "### SELL "
   append result [lindex $line 1]
   append result " ###\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append result $mult
   return $result

}

#open file for writing
set output [ open "Tar0.txt" w]

#set path to folder, might need to this by getting input from user
set path "C:/Users/yehuda/Workspace/TCLproject"


# scan through the files in the path and find vm files
set files [glob $path/*.vm]
foreach file $files {
    set fh [open $file r]
    puts $fh
	
    # visualize the data on screen of both files
    while { [gets $fh var ] >= 0 } { 
        if {[lindex $var 0] == "buy"} {
            puts [handleBuy $var]
            puts $output [handleBuy $var]
        } elseif {[lindex $var 0] == "cell"} {
            puts [handleSell $var]
            puts $output [handleSell $var]
        }
    }

	
    #insert logic for program
    
	
close $fh
}

