#   bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 4
#   Language: TCL
#   Lecturer: Y. Barzilly

package require itcl
source "WriteTokensToXML.tcl"
    
itcl::class Tokenizer {
    # Fields
    public variable nameOfCurrFile
    public variable currFile
    public variable myWriter
    variable lstWhiteSpace
    variable lstKeywords
    variable lstSymbols

    # Constructor
    constructor {} {
        set myWriter [XMLWriter new]
        set lstWhiteSpace [list " " "\t" "\n" "\r"]
        set lstKeywords [list "class" "constructor" "function" "method" "field" "static" "var" "int" "char" "boolean" "void" "true" "false" "null" "this" "let" "do" "if" "else" "while" "return"]
        set lstSymbols [list "\{" "\}" "\(" "\)" "\[" "\]" "." "," ";" "+" "-" "*" "/" "\&" "|" "<" ">" "=" "~"]   
    }

    # Methods:
    method setFile { newFile } {
        
        set nameOfCurrFile [string map {".jack" ""}  $newFile]
        set currFile [open $newFile r]
    }

    method compileFileToXml { } {
        set tempOutputFileName [concat $nameOfCurrFile "T.xml"]
        $myWriter setOutputFile [string map {" " ""} $tempOutputFileName]

        puts "FILTER OUT COMMENTS: \n\n"
        set linesWoutCmmnts [getListWoutCommentsCurrFile]
        puts "\n\nCREATING TOKENS FROM THE JACK CODE:\n\n"
        
        # set openQuotes 0; # if true - we are in the middle of " " (for string constant)

        foreach line $linesWoutCmmnts {

            # puts proccessing $line

            for {set i 0} {$i < [string length $line]} {incr i} {
                # iterates over each char in this line
                set char [string index $line $i]
                
                if {![isStringInList $char $lstWhiteSpace]} {
                    #if NOT whitespace:
                    # (1) check if Symbol:
                    if {[isStringInList $char $lstSymbols]} {
                        $myWriter writeTokenSymbol $char
                        continue
                    }
                    # (2) check if within quotations (string constant)
                    if { $char eq "\"" } { 
                        set stringConstantBuffer ""
                        incr i
                        set char [string index $line $i]
                        puts [append "at" $char]
                        while { ![ string equal $char "\""] } {
                            append stringConstantBuffer $char
                            incr i
                            set char [string index $line $i]
                            # assumes that we'll hit a quotation mark before the end of the line
                        }
                       $myWriter writeTokenStrCons $stringConstantBuffer
                        continue      
                    }


                    # (3) buffer = the rest of the word until white space, symbol, or closed quotation
                    set buffer $char ; # resets buffer
                    incr i
                    set char [string index $line $i]
                    
                    while { ![isStringInList $char $lstWhiteSpace] 
                    && ![isStringInList $char $lstSymbols]} {
                        # if {$char eq "\""} { set isOpenQuote [![expr $isOpenQuote]]}
                        append buffer $char
                        if { $i < [string length $line] } {
                            incr i
                            set char [string index $line $i]
                        } else {
                            break ;#breaks from this local while
                        }
                    }

                    incr i -1

                    # (4) CHECK if buffer is keyword, int constant, or identifier
                    if { [isStringInList $buffer $lstKeywords]} {
                        $myWriter writeTokenKeyword $buffer
                    } elseif {[isInteger $buffer]} {
                        $myWriter writeTokenIntCons $buffer
                    } elseif {[isIdentifer $buffer]} {
                        $myWriter writeTokenIden $buffer
                    }
                    puts [concat "buffer:" $buffer]
                    
                    
                }
                
            }   
        }
        
    }
    
    method getListWoutCommentsCurrFile { } {
        # returns a list of each line of code, without comments, of the current file
        # but it retains the white spaces!
        set fileLines {} ; #list to hold all of the lines of the doc, which are not meant to be in comments
       
        set inOpenComment 0 ; # if true - we are in middle of a /* */ (multi line comment)
        set inLineComment 0; # if true - we break from the line totally (one liner comment)
            
        while {[gets $currFile line] != -1} {

            set buffer ""            
            
            # puts [concat "reading: " $line "from " $nameOfCurrFile]
            for {set i 0} {$i < [string length $line]} {incr i} {
                if { $inLineComment } {
                    set inLineComment 0
                    puts [append "removing one-line comment:" $line]
                    break; #breaks from for loop, ignore any characters after the "//"..
                }
                set char [string index $line $i]
                if {$inOpenComment} {
                    # we are in btw /* */
                    if { $char eq "*"} {
                        incr i
                        if { [string index $line $i] eq "/"} {
                            set inOpenComment 0
                            continue
                        }
                        incr i -1
                    }
                } else {
                    # detect a beginning of a comment
                    if { $char eq "/" } {
                        incr i
                        if { [string index $line $i] eq "/" } {
                            # the line has "//", then skip this line and move to the next
                            set inLineComment 1
                            continue
                        } elseif { [string index $line $i] eq "*" } {
                            # the line has "/*", then keep skipping till we find another "*/"
                            set inOpenComment 1
                            continue
                        } else {
                            incr i -1
                        }
                    } 
                    # this is NOT a comment:
                    append buffer $char
                    
                }                
            }
            # (2) add the buffer to the final code:
            lappend fileLines $buffer
            set buffer ""
        }
        return $fileLines
    }
   
    method closeCurrFile { } {
        puts "closing input file"
        close $currFile
        puts "closing output file"
        $myWriter closeFile
    }
    
    method isStringInList {str listVar} {
        if {[lsearch -exact $listVar $str] >= 0} {
            return 1
        } else {
            return 0
        }
    }    

    method isInteger {str} {
        if {[string is integer -strict $str]} {
            return 1
        } else {
            return 0
        }
    }

    method isIdentifer {str} {
        if {[isInteger [string index $str 0]]} {
            return 0
        } elseif {[string is alnum $str]} {
            return 1
        } else {
            return 0
        }
    }

}
    