
package require itcl

itcl::class WriteFinalXML {
    variable outputFileName;
    variable outputFile ; # file handler..

    method setOutputFile {fileName} {
        set outputFileName $fileName
        set outputFile [open $fileName w]
        puts $outputFile "<tokens>"
    }
    method writeTokenSymbol {symbol} {
        set symbolToWrite $symbol
        switch $symbol {
            "<" {
                set symbolToWrite "\&lt;"
            }
            ">" {
                set symbolToWrite "\&gt;"
            }
            "\"" {
                set symbolToWrite "\&quot;"
            }
            "\&" {
                set symbolToWrite "\&amp;"
            }
        }
        
        puts $outputFile [concat "<symbol>" $symbolToWrite "</symbol>"]
    }
    method writeTokenKeyword {keyword} {
        puts $outputFile [concat "<keyword>" $keyword "</keyword>"]
    }
    method writeTokenIntCons { integer } {
        puts $outputFile [concat "<integerConstant>" $integer "</integerConstant>"]
    }
    method writeTokenStrCons { str } {
        puts $outputFile [concat "<stringConstant>" $str "</stringConstant>"]
    }
    method writeTokenIden {iden} {
        puts $outputFile [concat "<identifier>" $iden "</identifier\>"]
    }

    # adding a new method to write a tag
    method writeTag { tag } {
        puts $outputFile [concat "<" $tag ">"]
    }

    method writeLine { line } {
        puts $outputFile $line
    }
    
    method closeFile { } {
        puts $outputFile "</tokens>"
        close $outputFile
    }
    
}
