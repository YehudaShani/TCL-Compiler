} {
        set symbolToWrite $symbol
        switch $symbol {
            "<" {
                set symbolToWrite "\&lt"
            }
            ">" {
                set symbolToWrite "\&gt"
            }
            "\"" {
                set symbolToWrite "\&quot"
            }
            "\&" {
                set symbolToWrite "\&amp"
            }
        }
        
        puts $outputFile [concat "<symbol>" $symbolToWrite "</symbol>"]
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
        puts $outputFile [concat "<identifier>" $iden "</identifier\>"]
    }
    

    # method write { msg } {
    #     # puts [concat "writing " $msg " to " $outputFileName ]
    #     puts $outputFile $msg
    # }
    
    method closeFile { } {
        puts $outputFile "</tokens>"
        close $outputFile
    }
    
}
