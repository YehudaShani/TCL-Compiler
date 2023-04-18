# This is the main part of the program, it will open the input and output files, call the parser
# and code writer

package require itcl


source "parser.tcl"
source "codeWriter.tcl"

parser pars input.vm
codeWriter code output.asm

while {[pars hasMoreCommands]} {
    pars advance

    set operation [pars info variable commandType -value]
    if {$operation eq "C_PUSH" || $operation eq "C_POP"} {
        code writePushPop [pars info variable command -value]
    } elseif {$operation eq "C_ARITHMETIC"} {
        code writeArithmetic [pars info variable command -value]
    }
}

