

package require itcl

itcl::class XMLWriter {
    variable outputFileName;
    variable outputFile ; # file handler..

    method setOutputFile {fileName} {
        set outputFileName $fileName
        set outputFile [open $fileName w]
    }
    method writeTokenSymbol {symbol} {
        puts $outputFile [concat "<symbol>" $symbol "</symbol>"]
        # puts  [concat "writing: " "<symbol>" $symbol "</symbol>"]
    }
    method writeTokenKeyword {keyword} {
        puts $outputFile [concat "<keyword>" $keyword "</keyword>"]
        # puts  [concat "writing: " "<keyword>" $keyword "</keyword>"]
    }
    method writeTokenIntCons { integer } {
        puts $outputFile [concat "<integerConstant>" $integer "</integerConstant>"]
        # puts  [concat "writing: " "<integerConstant>" $integer "</integerConstant>"]
    }
    method writeTokenStrCons { str } {
        puts $outputFile [concat "<stringConstant>" $str "</stringConstant>"]
    }
    method writeTokenIden {iden} {
        puts $outputFile [concat "<identifier>" $iden "<identifier\>"]
    }
    

    # method write { msg } {
    #     # puts [concat "writing " $msg " to " $outputFileName ]
    #     puts $outputFile $msg
    # }
    
    method closeFile { } {
        close $outputFile
    }
    
}