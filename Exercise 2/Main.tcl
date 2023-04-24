#   bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 2
#   Language: TCL
#   Lecturer: Y. Barzilly

package require itcl

#references to our files:
source "parser.tcl"
source "codeWriter.tcl"

#(1) initializes instances of our helper classes:
parser pars input.vm
codeWriter code output.asm

#(2) converting vm code to asm code:
while {[pars hasMoreCommands]} {
    pars advance
    #set local variable "operation" to the value of the "commandType" field from the parser object
    set operation [pars info variable commandType -value]
    
    if {$operation eq "C_PUSH" || $operation eq "C_POP"} {
        code writePushPop [pars info variable command -value]
    } elseif {$operation eq "C_ARITHMETIC"} {
        code writeArithmetic [pars info variable command -value]
    } elseif {$operation eq "C_LABEL"} {
        code writeLabel [pars info variable command -value]
    } elseif {$operation eq "C_GOTO"} {
        code writeGoTo [pars info variable command -value]
    } elseif {$operation eq "C_IF"} {
        code writeIfGoTo [pars info variable command -value]
    } 
}