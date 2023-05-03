package require itcl

itcl::class codeWriter {
    variable outputFile ; # file handler..
    variable outputFileName ; # actual name, used to write labels
    variable labelCounter 0

    constructor {fileName} {
        set outputFileName $fileName
        set outputFile [open $fileName w]
    }

    method closeFile { } {
        close $outputFile
    }
    
    method writeArithmetic {command} {
        variable labelCounter
        set labelCounter [expr $labelCounter + 1]
        set operation [lindex $command 0]
        if {$operation eq "add" || $operation eq "sub" || $operation eq "and" || $operation eq "or" } {
            puts $outputFile "@SP"
            puts $outputFile "AM=M-1" ;
            puts $outputFile "D=M"
            puts $outputFile "A=A-1"
            if {$operation eq "add"} {
                puts $outputFile "M=M+D"
            } elseif {$operation eq "sub"} {
                puts $outputFile "M=M-D"
            } elseif {$operation eq "and"} {
                puts $outputFile "M=M&D"
            } elseif {$operation eq "or"} {
                puts $outputFile "M=M|D"
            }
        }
        if {$operation eq "neg" || $operation eq "not"} {
            puts $outputFile "@SP"
            puts $outputFile "A=M-1"
            if {$operation eq "neg"} {
                puts $outputFile "M=-M"
            } elseif {$operation eq "not"} {
                puts $outputFile "M=!M"
            }
        }
        if {$operation eq "eq" || $operation eq "gt" || $operation eq "lt"} {
            puts $outputFile "@SP"
            puts $outputFile "AM=M-1"
            puts $outputFile "D=M"
            puts $outputFile "A=A-1"
            puts $outputFile "D=M-D"
            puts $outputFile "@TRUE$operation-$labelCounter"
            if {$operation eq "eq"} {
                puts $outputFile "D;JEQ"
            } elseif {$operation eq "gt"} {
                puts $outputFile "D;JGT"
            } elseif {$operation eq "lt"} {
                puts $outputFile "D;JLT"
            }
            puts $outputFile "@SP"
            puts $outputFile "A=M-1"
            puts $outputFile "M=0"
            puts $outputFile "@END$operation-$labelCounter"
            puts $outputFile "0;JMP"
            puts $outputFile "(TRUE$operation-$labelCounter)"
            puts $outputFile "@SP"
            puts $outputFile "A=M-1"
            puts $outputFile "M=-1"
            puts $outputFile "(END$operation-$labelCounter)"
        }

    }

    method writePushPop {command fileName} {
        #parse the given command into 3 parts. Example of a command: "push constant 10"
        set operation [lindex $command 0]
        set segment [lindex $command 1]
        set index [lindex $command 2]

        set firstOptions {"local" "argument" "this" "that"}

        if {$operation eq "push"} {
            if {$segment in $firstOptions} {
                if {$segment eq "local"} {
                    puts $outputFile "@LCL"
                }
                if {$segment eq "argument"} {
                    puts $outputFile "@ARG"
                }
                if {$segment eq "this"} {
                    puts $outputFile "@THIS"
                }
                if {$segment eq "that"} {
                    puts $outputFile "@THAT"
                }
                puts $outputFile "D=M"
                puts $outputFile "@$index"
                puts $outputFile "A=D+A"
                puts $outputFile "D=M"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"
            } elseif {$segment eq "temp"} {
                #temp segment starts at 5
                puts $outputFile "@5"
                puts $outputFile "D=A"
                puts $outputFile "@$index"
                puts $outputFile "A=D+A"
                puts $outputFile "D=M"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"

            } elseif {$segment eq "constant"} {
                puts $outputFile "@$index"
                puts $outputFile "D=A"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"

            } elseif {$segment eq "static"} {
                puts $outputFile "@$fileName.$index"
                puts $outputFile "D=M"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"

            } elseif {$segment eq "pointer"} {
                if {$index eq "0"} {
                    puts $outputFile "@THIS"
                } elseif {$index eq "1"} {
                    puts $outputFile "@THAT"
                }
                puts $outputFile "D=M"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"
            }


        } elseif {$operation eq "pop"} {
            if {$segment in $firstOptions} {
                if {$segment eq "local"} {
                    puts $outputFile "@LCL"
                }
                if {$segment eq "argument"} {
                    puts $outputFile "@ARG"
                }
                if {$segment eq "this"} {
                    puts $outputFile "@THIS"
                }
                if {$segment eq "that"} {
                    puts $outputFile "@THAT"
                }
                puts $outputFile "D=M"
                puts $outputFile "@$index"
                puts $outputFile "D=D+A"
                puts $outputFile "@R13"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "AM=M-1"
                puts $outputFile "D=M"
                puts $outputFile "@R13"
                puts $outputFile "A=M"
                puts $outputFile "M=D"

            } elseif {$segment eq "temp"} {
                puts $outputFile "@5"
                puts $outputFile "D=A"
                puts $outputFile "@$index"
                puts $outputFile "D=D+A"
                puts $outputFile "@R13"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "AM=M-1"
                puts $outputFile "D=M"
                puts $outputFile "@R13"
                puts $outputFile "A=M"
                puts $outputFile "M=D"

            } elseif {$segment eq "static"} {
                puts $outputFile "@SP"
                puts $outputFile "AM=M-1"
                puts $outputFile "D=M"
                puts $outputFile "@$fileName.$index"
                puts $outputFile "M=D"

            } elseif {$segment eq "pointer"} {
                puts $outputFile "@SP"
                puts $outputFile "AM=M-1"
                puts $outputFile "D=M"
                if {$index eq "0"} {
                    puts $outputFile "@THIS"
                } elseif {$index eq "1"} {
                    puts $outputFile "@THAT"
                }
                puts $outputFile "M=D"
            }
        }
    }
    
    method writeLabel {functionName} {
            
        puts $outputFile "($functionName)"
    }

    method writeGoTo {functionName} {
        puts $outputFile "\n//goto function"
        puts $outputFile "@$functionName"
        puts $outputFile "0; JMP"
    }

    method writeIfGoTo {command} {
        #set op number++
        variable labelCounter
        set labelCounter [expr $labelCounter + 1]

        set newLabel [lindex $command 1]
        puts $outputFile "\n//if-goto $newLabel"
        puts $outputFile "@SP"
        puts $outputFile "M=M-1"
        puts $outputFile "A=M"
        puts $outputFile "D=M"
        puts $outputFile "@if-goto-false-$labelCounter"
        puts $outputFile "D;JEQ"
        puts $outputFile "@$newLabel"
        puts $outputFile "0;JMP"
        puts $outputFile "(if-goto-false-$labelCounter)"

    }

    method call {command} {
        variable labelCounter
        set labelCounter [expr $labelCounter + 1]

        #set call variables
        set functionName [lindex $command 1]
        set numArgs [lindex $command 2]

        #save return address and push it, so that after we execute the code we will now where to return 
        set returnAddress "Return-Address-$functionName-$labelCounter"
        puts $outputFile "@$returnAddress"
        puts $outputFile "D=A"
        puts $outputFile "@SP"
        puts $outputFile "A=M"
        puts $outputFile "M=D"
        puts $outputFile "@SP"
        puts $outputFile "M=M+1"


        #push LCL, ARG, THIS, THAT, of caller so that the calee can use them for himself
        set pointers ["LCL" "ARG" "THIS" "THAT"]
        foreach pointer $pointers {
            pushPointer $pointer
        }

        #ARG = SP - n - 5, so that the callee can use the arguments the caller passed him
        puts $outputFile "\n//ARG = SP - n - 5"
        puts $outputFile "@SP"
        puts $outputFile "D=M"
        puts $outputFile "@$numArgs"
        puts $outputFile "D=D-A"
        puts $outputFile "@5"
        puts $outputFile "D=D-A"
        puts $outputFile "@ARG"
        puts $outputFile "M=D"

        #LCL = SP, so that the callee can use the local variables he needs to 
        puts $outputFile ""
        puts $outputFile "//LCL = SP"
        puts $outputFile "@SP"
        puts $outputFile "D=M"
        puts $outputFile "@LCL"
        puts $outputFile "M=D"

        #goto function
        write GoTo $functionName
        
        #add return address label, so that we can return to this location after the function is done
        puts $outputFile "\n//return address label"
        puts $outputFile "($returnAddress)"
    }



    # helper function to push pointers
    method pushPointer {pointer} {
        puts $outputFile "@$pointer"
        puts $outputFile "D=M"
        puts $outputFile "@SP"
        puts $outputFile "A=M"
        puts $outputFile "M=D"
        puts $outputFile "@SP"
        puts $outputFile "M=M+1"

    }

    method function {command} {
        #set function variables
        set functionName [lindex $command 1]
        set numLocals [lindex $command 2]

        #add function label
        puts $outputFile "\n//function $functionName $numLocals"
        puts $outputFile "($functionName)"

        #add local variables
        for {set i 0} {$i < $numLocals} {incr i} {
            pushConstant 0
        }
    }

    method return { } {
        variable labelCounter
        set labelCounter [expr $labelCounter + 1]
        
        #Frame = LCL
        puts $outputFile "\n//Frame = LCL"
        puts $outputFile "@LCL"
        puts $outputFile "D=M"
        puts $outputFile "@FRAME"
        puts $outputFile "M=D"

        #RET = *(FRAME-5)
        puts $outputFile "\n//RET = *(FRAME-5)"
        puts $outputFile "@FRAME"
        puts $outputFile "D=M"
        puts $outputFile "@5"
        puts $outputFile "A=D-A"
        puts $outputFile "D=M"
        puts $outputFile "@RET"
        puts $outputFile "M=D"

        #*ARG = pop()
        puts $outputFile "\n//*ARG = pop()"
        puts $outputFile "@SP"
        puts $outputFile "AM=M-1"
        puts $outputFile "D=M"
        puts $outputFile "@ARG"
        puts $outputFile "A=M"
        puts $outputFile "M=D"

        #SP = ARG + 1
        puts $outputFile "\n//SP = ARG + 1"
        puts $outputFile "@ARG"
        puts $outputFile "D=M+1"
        puts $outputFile "@SP"
        puts $outputFile "M=D"

        #THAT = *(FRAME-1)
        puts $outputFile "\n//THAT = *(FRAME-1)"
        puts $outputFile "@FRAME"
        puts $outputFile "D=M"
        puts $outputFile "@1"
        puts $outputFile "A=D-A"
        puts $outputFile "D=M"
        puts $outputFile "@THAT"
        puts $outputFile "M=D"

        #THIS = *(FRAME-2)
        puts $outputFile "\n//THIS = *(FRAME-2)"
        puts $outputFile "@FRAME"
        puts $outputFile "D=M"
        puts $outputFile "@2"
        puts $outputFile "A=D-A"
        puts $outputFile "D=M"
        puts $outputFile "@THIS"
        puts $outputFile "M=D"
        
        #ARG = *(FRAME-3)
        puts $outputFile "\n//ARG = *(FRAME-3)"`
        puts $outputFile "@FRAME"
        puts $outputFile "D=M"
        puts $outputFile "@3"
        puts $outputFile "A=D-A"
        puts $outputFile "D=M"
        puts $outputFile "@ARG"
        puts $outputFile "M=D"

        #LCL = *(FRAME-4)
        puts $outputFile "\n//LCL = *(FRAME-4)"
        puts $outputFile "@FRAME"
        puts $outputFile "D=M"
        puts $outputFile "@4"
        puts $outputFile "A=D-A"
        puts $outputFile "D=M"
        puts $outputFile "@LCL"
        puts $outputFile "M=D"

        #goto RET
        puts $outputFile "\n//goto RET"
        puts $outputFile "@RET"
        puts $outputFile "A=M"
        puts $outputFile "0;JMP"


    }



    
    #end of class
}