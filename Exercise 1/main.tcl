#   bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 1
#   Language: TCL
#   Lecturer: Y. Barzilly

# This is the main part of the program, it will open the input and output files, call the parser
# and code writer


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
    set line [pars info variable command -value]

    if {$operation eq "C_PUSH" || $operation eq "C_POP"} {
        code writePushPop $line input.vm
    } elseif {$operation eq "C_ARITHMETIC"} {
        code writeArithmetic $line
    }
}

#(3) closing all files:
pars closeFile
code closeFile
