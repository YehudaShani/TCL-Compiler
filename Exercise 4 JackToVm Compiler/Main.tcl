#   bs"d
#   Course: Fundamentals of S/W Languages - 150060.5783
#   Submitters: Yehuda Shani 23794253 & David Berger 341441053
#   Exercise: 4
#   Language: TCL
#   Lecturer: Y. Barzilly

# This is the main part of the program, it will open the input and output files, call the parser
# and code writer

package require itcl

#references to our files:
source "Tokenizer.tcl"

#(1) initializes instances of our helper classes:
Tokenizer tok 

# find all jack files
set files [glob *.jack]

#(2) iterate over files, convert Jack -> XML:
foreach file $files {
    #set the tokenizer to the current file
    tok setFile $file
    tok compileFileToXml 
    tok closeCurrFile
}
exit 0

