package require itcl

# this class retrieves the different commands found in it's input File
itcl::class parser {
    public variable inputFile ; # initialized by the ctor
    public variable command ; # holds current command being processed
    variable commandType

    constructor {inputVm} {
        set inputFile [open $inputVm r]
    }

    method hasMoreCommands { } {
        # returns boolean value
        if {[eof $inputFile]} {
            return "false"
        } else {
            return "true"
        }  
        return [eof $inputFile] ; # QQ_Yehuda what is the point of this line? should we erase it?
    }

    method advance { } 
        #updates "command" field to next line in input file
        set command [gets $inputFile]
        setCommandType
    }

    method setCommandType { } {
        #updates "commandType" field according to the current command
        set commandName [lindex $command 0]
        if {$commandName == "push"} {
            set commandType "C_PUSH"
        } elseif {$commandName == "pop"} {
            set commandType "C_POP"
        } elseif {$commandName == "label"} {
            set commandType "C_LABEL"
        } elseif {$commandName == "goto"} {
            set commandType "C_GOTO"
        } elseif {$commandName == "if-goto"} {
            set commandType "C_IF"
        } elseif {$commandName == "function"} {
            set commandType "C_FUNCTION"
        } elseif {$commandName == "return"} {
            set commandType "C_RETURN"
        } elseif {$commandName == "call"} {
            set commandType "C_CALL"
        } else {
            set commandType "C_ARITHMETIC"
        }
        return $commandType
    }

#QQ_Yehuda when are these 2 methods used? arg1 and arg2 ?
    method arg1 { } { 
        if {$commandType != "C_RETURN"} {
            return [lindex $command 0]
        }
    }

    method arg2 { } {
        if {$commandType == "C_PUSH" || $commandType == "C_POP" || $commandType == "C_FUNCTION" || $commandType == "C_CALL"} {
            return [lindex $command 1]
        }
    } 
}

