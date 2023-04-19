package require itcl

itcl::class codeWriter {
    variable outputFile

    constructor {fileName} {
        set outputFile [open $fileName w]
    }

    method writeArithmetic {command} {
        set operation [lindex $command 0]
        if {$operation eq "add" || $operation eq "sub" || $operation eq "and" || $operation eq "or" } {
            puts $outputFile "@SP"
            puts $outputFile "AM=M-1"
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
            puts $outputFile "@TRUE$operation"
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
            puts $outputFile "@END$operation"
            puts $outputFile "0;JMP"
            puts $outputFile "(TRUE$operation)"
            puts $outputFile "@SP"
            puts $outputFile "A=M-1"
            puts $outputFile "M=-1"
            puts $outputFile "(END$operation)"
        }

    }

    method writePushPop {command} {
        #parse the given command into 3 parts. Example of a command: "push constant 10"
        set operation [lindex $command 0] 
        set segment [lindex $command 1] 
        set index [lindex $command 2]

        if {$operation eq "push"} {
            if {$segment eq "constant"} {
                puts $outputFile "@$index"
                puts $outputFile "D=A"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"
            }
            elseif {$segment eq "local" || $segment eq "argument" || $segment eq "this" || $segment eq "that"} {
                if {$segment eq "local"} {
                    puts $outputFile "@LCL"
                } elseif {$segment eq "argument"} {
                    puts $outputFile "@ARG"
                } elseif {$segment eq "this"} {
                    puts $outputFile "@THIS"
                } elseif {$segment eq "that"} {
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
            }
            elseif {$segment eq "temp"} {
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
            }
            elseif {$segment eq "pointer"} {
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
            } elseif {$segment eq "static"} {
                puts $outputFile "@$fileName.$index"
                puts $outputFile "D=M"
                puts $outputFile "@SP"
                puts $outputFile "A=M"
                puts $outputFile "M=D"
                puts $outputFile "@SP"
                puts $outputFile "M=M+1"
            }
        } elseif {$operation eq "pop"} {
            if {$segment eq "local" || $segment eq "argument" || $segment eq "this" || $segment eq "that"} {
                if {$segment eq "local"} {
                    puts $outputFile "@LCL"
                } elseif {$segment eq "argument"} {
                    puts $outputFile "@ARG"
                } elseif {$segment eq "this"} {
                    puts $outputFile "@THIS"
                } elseif {$segment eq "that"} {
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
            } elseif {$segment eq "static"} {
                puts $outputFile "@SP"
                puts $outputFile "AM=M-1"
                puts $outputFile "D=M"
                puts $outputFile "@$fileName.$index"
                puts $outputFile "M=D"
            }
        }
    }

    method writeLabel {command} {
        
    }
    method writeGoTo {command}{
        
    }
    method writeIfGoTo {command}{
        
    }

}