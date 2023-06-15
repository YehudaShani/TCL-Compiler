#   bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 5
#   Language: TCL
#   Lecturer: Y. Barzilly

# This is the main part of the program, it will open the input and output files, call the parser
# and code writer

package require itcl

#references to our files:
source "Tokenizer.tcl"
source "CompilerEngine2.tcl"

#(1) initializes instances of our helper classes:
Tokenizer tok 
CompilerEngine2 comp

# find all jack files
set jackFiles [glob *.jack]


#(2) iterate over files, convert Jack -> XML:
foreach file $jackFiles {
    tok setFile $file
    tok compileFileToXml 
    tok closeCurrFile
    comp setFileName $file
    puts [concat "Beginning Compilation of " $file ]
    comp compile
}

set xmlFiles [glob *.xml]


exit 0

