
#bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 0
#   Language: TCL
#   Lecturer: Y. Barzilly



#!tclsh

proc handleBuyAndPrint {line fh} {
    #returns value added in this line, 
    #and prints the finished line to console and file
   set PrintResult "### BUY "
   append PrintResult [lindex $line 1]
   append PrintResult " ###\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append PrintResult [format "%.2f" $mult]
   puts $PrintResult
   puts $fh $PrintResult
   return $mult

}

proc handleSellAndPrint {line fh} {
    #returns value added in this line, 
    #and prints the finished line to console and file
   set PrintResult "$$$ SELL "
   append PrintResult [lindex $line 1]
   append PrintResult " $$$\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append PrintResult [format "%.2f" $mult]
   puts $PrintResult
   puts $fh $PrintResult
   return $mult

}


set inputPath [lindex $argv 0]
if {$inputPath == ""} {
   puts "You didn't give any arguments! Pls send your input file path.."
   return;
}
#example of inputPath: "C:/TCL/Targil0/" ; #you might have to switch "\" to "/"
set outputPath "C:/TCL/Targil0/outputFolder/";

#open file for writing
set outputFileName "Tar0.asm"
set output [ open $outputPath$outputFileName w]

# scan through the files in the path and find vm files
set files [glob $inputPath/*.vm]
set totalBuy 0
set totalSell 0
set temp 0

foreach file $files {
    set fh [open $file r]
    puts [file tail $file]:\n
    puts $output [file tail $file]:\n
	
    # iterate thru files:
    while { [gets $fh var ] >= 0 } { 
	if {[lindex $var 0] == "buy"} {
	    set temp [handleBuyAndPrint $var $output]
       set totalBuy [expr {$totalBuy + $temp}] 
	} elseif {[lindex $var 0] == "cell"} {
	    set temp [handleSellAndPrint $var $output]
        set totalSell [expr {$totalSell + $temp}]
	}
    }
    puts "\n\n"
    puts $output "\n\n"
    close $fh
}

set endMsg "TotalBuys: "
append endMsg $totalBuy
append endMsg \n
append endMsg "TotalSells: "
append endMsg $totalSell
append endMsg \n

puts $endMsg
puts $output #endMsg
close $output
return;

