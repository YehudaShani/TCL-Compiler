package require itcl

itcl::class VMWriter {

    variable outputFileName
    variable outputFile

    method setFile {_outputFile} {
        # remove the .jack extension
        set outputFileName $_outputFile
        # add the .vm extension
        append outputFileName ".vm"
        set outputFile [open $outputFileName w]
    }

    # destructor {
    #     close $outputFile
    # }

    method writePush {segment index} {
        puts $outputFile "push $segment $index"
    }

    method writePop {segment index} {
        puts $outputFile "pop $segment $index"
    }

    method writeArithmetic {command} {
        puts $outputFile "$command"
    }

    method writeLabel {label} {
        puts $outputFile "label $label"
    }

    method writeGoto {label} {
        puts $outputFile "goto $label"
    }

    method writeIf {label} {
        puts $outputFile "if-goto $label"
    }

    method writeCall {name nArgs} {
        puts $outputFile "call $name $nArgs"
    }

    method writeFunction {name nVars} {
        puts $outputFile "function $name $nVars"
    }

    method writeReturn {} {
        puts $outputFile "return"
    }

    method close {} {
        close $outputFile
    }
}