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
source "CompilerEngine.tcl"

#(1) initializes instances of our helper classes:
Tokenizer tok 
CompilerEngine comp

# find all jack files
set jackFiles [glob *.jack]


#(2) iterate over files, convert Jack -> XML:
foreach file $jackFiles {
    #set the tokenizer to the current file
    #tok setFile $file
    #tok compileFileToXml 
    #tok closeCurrFile
}

set xmlFiles [glob *.xml]

#(3) iterate over files, check grammer of files


#set the tokenizer to the current file
comp setFileName "MainT.xml"
comp printTokens 


exit 0

