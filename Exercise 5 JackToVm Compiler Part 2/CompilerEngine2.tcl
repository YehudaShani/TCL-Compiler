package require itcl

source "TokenizerHelper.tcl"
# source "WriteFinalXML.tcl"
source "SymbolTable.tcl"
source "SR_SymbolTable.tcl"
source "VMWriter.tcl"

itcl::class CompilerEngine2 {
    variable tokenizer
    variable fileName
    variable outputFileName
    # variable outputFile uses the vmWriter..
    variable vmWriter
    variable st 
    variable st_sr ;# for subroutine symbol Table
    # repsonse codes:
    variable RES_NOT_FOUND 1
    variable RES_FOUND 0

    # Segments - to send as parameters to vmwriter (if i wasnt sure, i left the value as a number)
    variable CONSTANT "constant"
    variable ARGUMENT "argument"
    variable LOCAL "local"
    variable STATIC "static"
    variable THIS "this"
    variable THAT "that"
    variable POINTER "pointer"
    variable TEMP "temp"

    variable dictForOps 
    variable dictForSegments

    constructor {  } {
        set tokenizer [TokenizerHelper TokenizerHelper::new]
        set st [SymbolTable SymbolTable::new]
        set st_sr [SR_SymbolTable SR_SymbolTable::new]

        set dictForOps [dict create "+" "add" "-" "sub" "=" "eq" "&gt;" "gt" "&lt;" "lt" "|" "or" "&amp;" "and" "*" "call Math.multiply 2" "/" "call Math.divide "]
        set dictForSegments [dict create "field" "this" "static" "static" "arg" "arg" "local" "local"]
    }

    method setFileName { _fileName } {
        set fileName $_fileName
        $tokenizer setFile [file rootname $fileName]T.xml
        set outputFileName [file rootname $fileName]
        # set outputFileName [file rootname $fileName].xml
        # set outputFile [open $outputFileName w]
        $st reset
        set vmWriter [VMWriter VMWriter::new]
        $vmWriter setFile $outputFileName
    }


    method printTokens { } {
        # print while not end of file
        while { [ $tokenizer hasMoreTokens ] } {
            set token [ $tokenizer nextToken ]
            set types [ $tokenizer nextTokenType]
            # puts "token: $token, type: $types"
            # puts $outputFile "token: $token, type: $types"
            $tokenizer advance
        }
    }

    method compile { } {
        # compile class
        $tokenizer advance
        compileClass
        puts [concat "Class " [$st getClassName] [$st allSymbols]]
        # $vmWriter close
    }

    method eat { _token } {
        set realToken [$tokenizer nextToken]
        if { $realToken == $_token } {
            # puts $outputFile 
            $tokenizer advance
        } else {

            error "expected $_token, got $realToken"
        }
    }

    method eatType { } {
        # list of types
        if { [ $tokenizer nextToken ] == "int" || [ $tokenizer nextToken ] == "char" || [ $tokenizer nextToken ] == "boolean" || [ $tokenizer nextTokenType ] == "identifier" } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected type, got [$tokenizer nextTokenType]"
        }
    }

    method eatVarName { } {
        set type [ $tokenizer nextTokenType ]
        if { $type == "identifier" } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected varName, got $type"
        }
    }

    method twoOptionsEat { token1 token2 } {
        if { [ $tokenizer nextToken ] == $token1 || [ $tokenizer nextToken ] == $token2 } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected $token1 or $token2, got [$tokenizer nextTokenType]"
        }
    }

    method threeOptionsEat { token1 token2 token3 } {
        if { [ $tokenizer nextToken ] == $token1 || [ $tokenizer nextToken ] == $token2 || [ $tokenizer nextToken ] == $token3 } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected $token1 or $token2 or $token3, got [$tokenizer nextTokenType]"
        }
    }

    method eatUnaryOp { } {
        if { [ $tokenizer nextToken ] == "-" || [ $tokenizer nextToken ] == "~" } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected unaryOp, got [$tokenizer nextTokenType]"
        }
    }

    method eatOp { } {
        if { [ $tokenizer nextToken ] == "+" || [ $tokenizer nextToken ] == "-" || [ $tokenizer nextToken ] == "*" || [ $tokenizer nextToken ] == "/" || [ $tokenizer nextToken ] == "\&amp;" || [ $tokenizer nextToken ] == "|" || [ $tokenizer nextToken ] == "\&lt;" || [ $tokenizer nextToken ] == "\&gt;" || [ $tokenizer nextToken ] == "=" } {
            # puts $outputFile 
            $tokenizer advance
        } else {
            error "expected op, got [$tokenizer nextToken]"
        }
    }

    method compileStatements { } {
        # compile statements, of the form: "statement*"
        # puts $outputFile "<statements>"
        while { [ $tokenizer nextToken ] == "let" || [ $tokenizer nextToken ] == "if" || [ $tokenizer nextToken ] == "while" || [ $tokenizer nextToken ] == "do" || [ $tokenizer nextToken ] == "return" } {
            switch [ $tokenizer nextToken ] {
                "let" {
                    compileLet
                }
                "if" {
                    compileIfStatement
                }
                "while" {
                    compileWhileStatement
                }
                "do" {
                    compileDo
                }
                "return" {
                    compileReturn
                }
            }
        }
        # puts $outputFile "</statements>"

    }

    method compileClass { } {
        # compile class, of the form: "class className { classVarDec* subroutineDec* }"
        # puts $outputFile "<class>"

        eat "class"
        $st setCategory [$st addSymbolWithName [$tokenizer nextToken]] "class"

    
        eatVarName
        eat "{"
        # compile classVarDec*
        while { [ $tokenizer nextToken ] == "static" || [ $tokenizer nextToken ] == "field" } {
            # no need to write VM (i think)
            compileClassVarDec
        }
        # compile subroutineDec*
        while { [ $tokenizer nextToken ] == "constructor" || [ $tokenizer nextToken ] == "function" || [ $tokenizer nextToken ] == "method" } {
            $st_sr reset
            compileSubroutineDec
            puts [concat "subroutines table: \n" [$st_sr allSymbols] ]
        }
        eat "}"
        # puts $outputFile "</class>"
    }

    method compileClassVarDec { } {
        # (1) get category
        set category [$tokenizer nextToken]
        #compile class variable declaration, of the form: "static|field type varName (, varName)*;"
        twoOptionsEat "static" "field" ;
        
        # (2) get type
        set type [$tokenizer nextToken]
        #note - type can be an identifier (like SquareGame...)!
        if { [ $tokenizer nextToken ] == "int" || [ $tokenizer nextToken ] == "char" || [ $tokenizer nextToken ] == "boolean"} {
            eatType
        } else { 
            eatVarName
        }
        
        # (3) set name
        $st setType [$st setCategory [$st addSymbolWithName [$tokenizer nextToken]] $category] $type
        eatVarName
        while { [ $tokenizer nextToken ] == "," } {
            eat ","
            $st setType [$st setCategory [$st addSymbolWithName [$tokenizer nextToken]] $category] $type
            eatVarName
        }
        eat ";"
    }

    method compileSubroutineDec { } {
        #compile subroutine declaration, of the form: "constructor|function|method (void|type) subroutineName (parameterList) subroutineBody"
        threeOptionsEat "constructor" "function" "method"
        set subRoutineType [$tokenizer nextToken]
        if { [ $tokenizer nextToken ] == "void" } {
            eat "void"
        } else {
            eatType
        }
        $st setCategory [$st addSymbolWithName [$tokenizer nextToken]] "subroutine" 
        puts "-"
        puts [concat "compiling subroutine - " [$tokenizer nextToken]]
        $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName "this"] "arg"] [$st getClassName]; #careful <- last one is st, not st_sr.

        set subRoutineName [$tokenizer nextToken]
        
        eatVarName
        eat "("
        compileParameterList
        eat ")"

        puts [concat "subroutine table: \n" [$st_sr allSymbols] ]

        $vmWriter writeFunction "[$st getClassName].$subRoutineName" [$st_sr getNumLocals]
        compileSubroutineBody

        # push the return value of the function onto the stack

        if { $subRoutineType == "void" } {
            $vmWriter writePush "constant" 0
        } else {
            $vmWriter writePush "constant" 1
        }

        $vmWriter writeReturn

    }

    method compileParameterList { } {
        # compile parameter list, of the form: "( (type varName) (, type varName)*)?"
        if { [ $tokenizer nextToken ] == "int" || [ $tokenizer nextToken ] == "char" || [ $tokenizer nextToken ] == "boolean" || [ $tokenizer nextTokenType ] == "identifier" } {
            set type [$tokenizer nextToken]
            eatType
            set name [$tokenizer nextToken]
            eatVarName
            $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName $name] "arg"] $type ; #careful <- last one is st..
            while { [ $tokenizer nextToken ] == "," } {
                eat ","
                set type [$tokenizer nextToken]
                eatType
                set name [$tokenizer nextToken]
                eatVarName
                $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName $name] "arg"] $type ; #careful <- last one is st..
            }
        }
    }

    method compileSubroutineBody { } {
        #compile subroutine body, of the form: "{ varDec* statements }"
        eat "{"
        #compile varDec*
        while { [ $tokenizer nextToken ] == "var" } {
            compileVarDec ; # no need to write VM (i think...)
        }
        #compile statements
        compileStatements
        eat "}"
    }

    method compileVarDec { } {
        #compile variable declaration, of the form: "var type varName (, varName)*;"
        # puts $outputFile "<varDec>"
        eat "var"
        set type [$tokenizer nextToken]
        eatType
        set name [$tokenizer nextToken]
        eatVarName
        $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName $name] "local"] $type ;
        while { [ $tokenizer nextToken ] == "," } {
            eat ","
            set name [$tokenizer nextToken]
            $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName $name] "local"] $type ;
            eatVarName
        }
        eat ";"
        # puts $outputFile "</varDec>"
    }

    method compileWhileStatement { } {
        # compile while statement, of the form: "while (expression) { statements }"
        # puts $outputFile "<whileStatement>"
        eat "while"
        eat "("


        # compile expression
        compileExpression
        eat ")"
        eat "{"
        # compile statements
        compileStatements
        eat "}"

        # puts $outputFile "</whileStatement>"
    }

    method compileIfStatement { } {
        # compile if statement, of the form: "if (expression) { statements }"
        # puts $outputFile "<ifStatement>"
        eat "if"
        eat "("

        # compile expression
        compileExpression
        eat ")"
        eat "{"
        # compile statements
        compileStatements
        eat "}"

        # compile else statement, of the form: "else { statements }"
        if { [ $tokenizer nextToken ] == "else" } {
            eat "else"
            eat "{"
            # compile statements
            compileStatements
            eat "}"
        }

        # puts $outputFile "</ifStatement>"
    }


    method compileLet { } {
        # compile let statement, of the form: "let varName ([ expression ])? = expression;"
        # puts $outputFile "<letStatement>"
        eat "let"

        # compile varName
        set varName [$tokenizer nextToken]
        eatVarName

        # compile ([ expression ])? = expression
        if { [ $tokenizer nextToken ] == "\[" } {
            eat "\["
            # compile expression
            compileExpression
            eat "]"

            # push the base address of the array onto the stack
            $vmWriter writePush [$st getCategory [$st getIndexOfSymbolByName $varName]] [$st getIndexOfSymbolByName $varName]

            # add the expression to the base address
            $vmWriter writeArithmetic "add"

            eat "="

            # compile expression
            compileExpression

            # pop the result of the expression into temp 0
            $vmWriter writePop "temp" 0

            # pop the result of the expression into that address
            $vmWriter writePop "pointer" 1
            $vmWriter writePush "temp" 0
            $vmWriter writePop "that" 0
        } else {
            eat "="

            # compile expression
            compileExpression

            # pop the result of the expression into the variable
            # search for the variable in the symbol table

            set found true
            if {[$st_sr getIndexOfSymbolByName $varName] >= 0} {
                #look it up on the subrountine's symbol table:
                set category [$st_sr getCategory [$st_sr getIndexOfSymbolByName $varName]]
                set index [$st_sr getIndex [$st_sr getIndexOfSymbolByName $varName]]
            } elseif {[$st getIndexOfSymbolByName $varName] >= 0} { ;# if found on the class's symbol table...
                set category [$st getCategory [$st getIndexOfSymbolByName $varName]]
                set index [$st getIndex [$st getIndexOfSymbolByName $varName]]
            } else {
                set found false
            }
            if { $found } {
                $vmWriter writePop $category $index
            } else {
                puts "ERROR: variable $varName not found"
            }
        }

        eat ";"

        # puts $outputFile "</letStatement>"
    }
    method compileDo { } {
        # compile do statement, of the form: "do subroutineCall;"
        # puts $outputFile "<doStatement>"
        eat "do"

        # compile subroutineCall
        compileSubroutineCall
        eat ";"

        # puts $outputFile "</doStatement>"

        # pop the return value of the subroutine call
        $vmWriter writePop "temp" 0
    }

    method compileReturn { } {
        # compile return statement, of the form: "return expression?;"
        # puts $outputFile "<returnStatement>"
        eat "return"

        # compile expression?
        if { [ $tokenizer nextToken ] != ";" } {
            compileExpression
        }
        eat ";"

        # puts $outputFile "</returnStatement>"
    }

    method compileExpression { } {
        # compile expression, of the form: "term (op term)*"
        compileTerm

        set nextType [ $tokenizer nextTokenType ]

        set nextToken [ $tokenizer nextToken ]
        # puts "nextToken: $nextToken"
        while { $nextToken == "+" || $nextToken == "-" || $nextToken == "*" || $nextToken == "/" || $nextToken == "\&amp;" || $nextToken == "|" || $nextToken == "\&lt;" || $nextToken == "\&gt;" || $nextToken == "=" } {
            
            set op [$tokenizer nextToken]
            eatOp
            compileTerm
            $vmWriter writeArithmetic [dict get $dictForOps $op]
            set nextToken [ $tokenizer nextToken ]
        }
    }

    method compileTerm { } {
        # compile term, of the form: "integerConstant | stringConstant | keywordConstant | varName | varName[expression] | subroutineCall | (expression) | unaryOp term"
        
        set type [ $tokenizer nextTokenType ]
        set 2ndToken [ $tokenizer nextNextToken ]
        if { $2ndToken == "." } {
            puts "subroutine call"
            compileSubroutineCall
        } elseif { $type == "integerConstant" || $type == "stringConstant" || $type == "keyword" } {
            $vmWriter writePush $CONSTANT [$tokenizer nextToken]
            $tokenizer advance

        } elseif { $type == "identifier" } {
            set name [$tokenizer nextToken]
            set category ""
            set index ""
            set found true
            if {[$st_sr getIndexOfSymbolByName $name] >= 0} {
                #look it up on the subrountine's symbol table:
                set category [$st_sr getCategory [$st_sr getIndexOfSymbolByName $name]]
                set index [$st_sr getIndex [$st_sr getIndexOfSymbolByName $name]]
            } elseif {[$st getIndexOfSymbolByName $name] >= 0} { ;# if found on the class's symbol table...
                set category [$st getCategory [$st getIndexOfSymbolByName $name]]
                set index [$st getIndex [$st getIndexOfSymbolByName $name]]
            } else {
                set found false
            }
            if { $found } {
                $vmWriter writePush [dict get $dictForSegments $category] $index
            }
            
            eatVarName
            if { [ $tokenizer nextToken ] == "\[" } {
                eat "\["
                compileExpression
                eat "\]"
            } elseif { [ $tokenizer nextToken ] == "." } {
                eat "."
                if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
                    #look it up on the class's symbol table!
                }
                eatVarName
                eat "("
                compileExpressionList
                eat ")"
            } elseif { [ $tokenizer nextToken ] == "(" } {
                eat "("
                compileExpressionList
                eat ")"
            }
        } elseif { $type == "symbol" } {
            if { [ $tokenizer nextToken ] == "(" } {
                eat "("
                compileExpression
                eat ")"
            } else {
                set unaryOp [$tokenizer nextToken]
                eatUnaryOp
                compileTerm
                if { $unaryOp == "-" } {
                    $vmWriter writeArithmetic "neg"
                } elseif { $unaryOp == "~" } {
                    $vmWriter writeArithmetic "not"
                }
                
            }
        } else {
            puts "ERROR: invalid term, got $type"
        }
        
        
    }

    method compileSubroutineCall { } {
        # compile subroutine call, of the form: "subroutineName (expressionList) | (className | varName).subroutineName (expressionList)"
        
        set functionCallName [$tokenizer nextToken]
        # compile subroutineName | (className | varName)
        if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
            #look it up on the class's symbol table!
        }
        eatVarName
        if { [ $tokenizer nextToken ] == "." } {
            append functionCallName "."
            eat "."
            append functionCallName [$tokenizer nextToken]
            if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
                #look it up on the class's symbol table!
            }
            eatVarName
        }

        eat "("
        # compile expressionList
        set numArgsSent [compileExpressionList]
        eat ")"
        $vmWriter writeCall $functionCallName $numArgsSent
    }

    method compileExpressionList { } {
        # compile expression list, of the form: "(expression (, expression)*)?"
        set numArgsSent "0"
        if { [ $tokenizer nextToken ] != ")" } {
            incr numArgsSent
            compileExpression
            while { [ $tokenizer nextToken ] == "," } {
                eat ","
                incr numArgsSent
                compileExpression
            }
        }
        return $numArgsSent
    }

}

