#!tclsh


proc handleBuyAndPrint {line fh} {
    #returns value added in this line, 
    #and prints the finished line to console and file
   set PrintResult "### BUY "
   append PrintResult [lindex $line 1]
   append PrintResult " ###\n"
   set mult [expr { [lindex $line 2] * [lindex $line 3] }]
   append PrintResult $mult
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
   append PrintResult $mult
   puts $PrintResult
   puts $fh $PrintResult
   return $mult

}

#set path to folder, might need to this by getting input from user
set inputPath "C:/TCL/Targil0/" ; #you might have to switch "\" to "/"
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
puts TotalBuys$totalBuy\n
puts $output TotalBuys$totalBuy\n
puts TotalSells$totalSell\n
puts $output TotalSells$totalSell\n
close $output

