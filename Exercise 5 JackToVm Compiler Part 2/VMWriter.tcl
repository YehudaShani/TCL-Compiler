package require itcl

itcl::class VMWriter {

    public variable outputFileName
    public variable outputFile


    constructor {outputFile} {
        # remove the .jack extension
        set outputFileName [file rootname $outputFile]
        # add the .vm extension
        append outputFileName ".vm"
        set outputFile [open $outputFileName w]
    }

    destructor {
        close $outputFile
    }

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

    method writeFunction {name nLocals} {
        puts $outputFile "function $name $nLocals"
    }

    method writeReturn {} {
        puts $outputFile "return"
    }

    method close {} {
        close $outputFile
    }
}