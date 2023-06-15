package require itcl

source "TokenizerHelper.tcl"
source "WriteFinalXML.tcl"
source "SymbolTable.tcl"
source "SR_SymbolTable.tcl"

itcl::class CompilerEngine2 {
    variable tokenizer
    variable fileName
    variable outputFileName
    variable outputFile
    variable st 
    variable st_sr ;# for subroutine
    # repsonse codes:
    variable RES_NOT_FOUND 1
    variable RES_FOUND 0

    constructor {  } {
        set tokenizer [TokenizerHelper TokenizerHelper::new]
        set st [SymbolTable SymbolTable::new]
        set st_sr [SR_SymbolTable SR_SymbolTable::new]
    }



    method setFileName { _fileName } {
        set fileName $_fileName
        set outputFileName [file rootname $fileName].xml
        set outputFile [open $outputFileName w]
        $tokenizer setFile [file rootname $fileName]T.xml
        $st reset
    }

    method printTokens { } {
        # print while not end of file
        while { [ $tokenizer hasMoreTokens ] } {
            set token [ $tokenizer nextToken ]
            set types [ $tokenizer nextTokenType]
            # puts "token: $token, type: $types"
            puts $outputFile "token: $token, type: $types"
            $tokenizer advance
        }
    }

    method compile { } {
        # compile class
        $tokenizer advance
        compileClass
        puts [concat "Class " [$st getClassName] [$st allSymbols]]
    }

    method eat { _token } {
        set realToken [$tokenizer nextToken]
        if { $realToken == $_token } {
            puts $outputFile [$tokenizer advance]
        } else {

            error "expected $_token, got $realToken"
        }
    }

    method eatType { } {
        # list of types
        if { [ $tokenizer nextToken ] == "int" || [ $tokenizer nextToken ] == "char" || [ $tokenizer nextToken ] == "boolean" || [ $tokenizer nextTokenType ] == "identifier" } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected type, got [$tokenizer nextTokenType]"
        }
    }

    method eatVarName { } {
        set type [ $tokenizer nextTokenType ]
        if { $type == "identifier" } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected varName, got $type"
        }
    }

    method twoOptionsEat { token1 token2 } {
        if { [ $tokenizer nextToken ] == $token1 || [ $tokenizer nextToken ] == $token2 } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected $token1 or $token2, got [$tokenizer nextTokenType]"
        }
    }

    method threeOptionsEat { token1 token2 token3 } {
        if { [ $tokenizer nextToken ] == $token1 || [ $tokenizer nextToken ] == $token2 || [ $tokenizer nextToken ] == $token3 } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected $token1 or $token2 or $token3, got [$tokenizer nextTokenType]"
        }
    }

    method eatUnaryOp { } {
        if { [ $tokenizer nextToken ] == "-" || [ $tokenizer nextToken ] == "~" } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected unaryOp, got [$tokenizer nextTokenType]"
        }
    }

    method eatOp { } {
        if { [ $tokenizer nextToken ] == "+" || [ $tokenizer nextToken ] == "-" || [ $tokenizer nextToken ] == "*" || [ $tokenizer nextToken ] == "/" || [ $tokenizer nextToken ] == "\&amp;" || [ $tokenizer nextToken ] == "|" || [ $tokenizer nextToken ] == "\&lt;" || [ $tokenizer nextToken ] == "\&gt;" || [ $tokenizer nextToken ] == "=" } {
            puts $outputFile [$tokenizer advance]
        } else {
            error "expected op, got [$tokenizer nextToken]"
        }
    }

    method compileStatements { } {
        # compile statements, of the form: "statement*"
        puts $outputFile "<statements>"
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
        puts $outputFile "</statements>"

    }

    method compileClass { } {
        # compile class, of the form: "class className { classVarDec* subroutineDec* }"
        puts $outputFile "<class>"

        eat "class"
        $st setCategory [$st addSymbolWithName [$tokenizer nextToken]] "class"
    
        eatVarName
        eat "{"
        # compile classVarDec*
        while { [ $tokenizer nextToken ] == "static" || [ $tokenizer nextToken ] == "field" } {
            compileClassVarDec
        }
        # compile subroutineDec*
        while { [ $tokenizer nextToken ] == "constructor" || [ $tokenizer nextToken ] == "function" || [ $tokenizer nextToken ] == "method" } {
            $st_sr reset
            compileSubroutineDec
            puts [concat "subroutines table: \n" [$st_sr allSymbols] ]
        }
        eat "}"
        puts $outputFile "</class>"
    }

    method compileClassVarDec { } {
        # (1) get category
        set category [$tokenizer nextToken]
        #compile class variable declaration, of the form: "static|field type varName (, varName)*;"
        puts $outputFile "<classVarDec>"
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
            eatVarName
        }
        eat ";"
        puts $outputFile "</classVarDec>"
    }

    method compileSubroutineDec { } {
        #compile subroutine declaration, of the form: "constructor|function|method (void|type) subroutineName (parameterList) subroutineBody"
        puts $outputFile "<subroutineDec>"
        threeOptionsEat "constructor" "function" "method"
        if { [ $tokenizer nextToken ] == "void" } {
            eat "void"
        } else {
            eatType
        }
        $st setCategory [$st addSymbolWithName [$tokenizer nextToken]] "subroutine" 
        puts "-"
        puts [concat "compiling subroutine - " [$tokenizer nextToken]]
        $st_sr setType [$st_sr setCategory [$st_sr addSymbolWithName "this"] "arg"] [$st getClassName]; #careful <- last one is st, not st_sr.
            
        eatVarName
        eat "("
        compileParameterList
        eat ")"
        compileSubroutineBody
        puts $outputFile "</subroutineDec>"
    }

    method compileParameterList { } {
        # compile parameter list, of the form: "( (type varName) (, type varName)*)?"
        puts $outputFile "<parameterList>"
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
        puts $outputFile "</parameterList>"
    }

    method compileSubroutineBody { } {
        #compile subroutine body, of the form: "{ varDec* statements }"
        puts $outputFile "<subroutineBody>"
        # puts "$outputFileName"
        eat "{"
        #compile varDec*
        while { [ $tokenizer nextToken ] == "var" } {
            compileVarDec
        }
        #compile statements
        compileStatements
        eat "}"
        puts $outputFile "</subroutineBody>"
    }

    method compileVarDec { } {
        #compile variable declaration, of the form: "var type varName (, varName)*;"
        puts $outputFile "<varDec>"
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
        puts $outputFile "</varDec>"
    }

    method compileWhileStatement { } {
        # compile while statement, of the form: "while (expression) { statements }"
        puts $outputFile "<whileStatement>"
        eat "while"
        eat "("


        # compile expression
        compileExpression
        eat ")"
        eat "{"
        # compile statements
        compileStatements
        eat "}"

        puts $outputFile "</whileStatement>"
    }

    method compileIfStatement { } {
        # compile if statement, of the form: "if (expression) { statements }"
        puts $outputFile "<ifStatement>"
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

        puts $outputFile "</ifStatement>"
    }


    method compileLet { } {
        # compile let statement, of the form: "let varName ([ expression ])? = expression;"
        puts $outputFile "<letStatement>"
        eat "let"
        set name [$tokenizer nextToken] 
        
        eatVarName
        # compile ([ expression ])? = expression
        if { [ $tokenizer nextToken ] == "\[" } {
            if {[$st_sr addUsageUsed $name] == $RES_NOT_FOUND} {
                #look it up on the class's symbol table!
            }
            eat "\["
            compileExpression
            eat "\]"
        } else {
            if {[$st_sr addUsageDecl $name] == $RES_NOT_FOUND} {
                #look it up on the class's symbol table!
            }
        }
        eat "="
        compileExpression
        eat ";"

        puts $outputFile "</letStatement>"
    }

    method compileDo { } {
        # compile do statement, of the form: "do subroutineCall;"
        puts $outputFile "<doStatement>"
        eat "do"

        # compile subroutineCall
        compileSubroutineCall
        eat ";"

        puts $outputFile "</doStatement>"
    }

    method compileReturn { } {
        # compile return statement, of the form: "return expression?;"
        puts $outputFile "<returnStatement>"
        eat "return"

        # compile expression?
        if { [ $tokenizer nextToken ] != ";" } {
            compileExpression
        }
        eat ";"

        puts $outputFile "</returnStatement>"
    }

    method compileExpression { } {
        # compile expression, of the form: "term (op term)*"
        puts $outputFile "<expression>"
        compileTerm
        set nextToken [ $tokenizer nextToken ]
        # puts "nextToken: $nextToken"
        while { $nextToken == "+" || $nextToken == "-" || $nextToken == "*" || $nextToken == "/" || $nextToken == "\&amp;" || $nextToken == "|" || $nextToken == "\&lt;" || $nextToken == "\&gt;" || $nextToken == "=" } {
            # puts "nextToken: $nextToken"
            eatOp
            compileTerm
            set nextToken [ $tokenizer nextToken ]
        }
        puts $outputFile "</expression>"
    }

    method compileTerm { } {
        # compile term, of the form: "integerConstant | stringConstant | keywordConstant | varName | varName[expression] | subroutineCall | (expression) | unaryOp term"
        puts $outputFile "<term>"
        set type [ $tokenizer nextTokenType ]
        if { $type == "integerConstant" || $type == "stringConstant" || $type == "keywordConstant" } {
            set line [$tokenizer advance]
            puts $outputFile $line
        } elseif { $type == "identifier" } {
            if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
                #look it up on the class's symbol table!
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
                eatUnaryOp
                compileTerm
            }
        } else {
            ### might need to change this
            puts $outputFile [$tokenizer advance]
        }
        puts $outputFile "</term>"
    }

    method compileSubroutineCall { } {
        # compile subroutine call, of the form: "subroutineName (expressionList) | (className | varName).subroutineName (expressionList)"
        #puts $outputFile "<subroutineCall>"

        # compile subroutineName | (className | varName)
        if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
            #look it up on the class's symbol table!
        }
        eatVarName
        if { [ $tokenizer nextToken ] == "." } {
            eat "."
            if {[$st_sr addUsageUsed [$tokenizer nextToken]] == $RES_NOT_FOUND} {
                #look it up on the class's symbol table!
            }
            eatVarName
        }
        eat "("
        # compile expressionList
        compileExpressionList
        eat ")"

        #puts $outputFile "</subroutineCall>"
    }

    method compileExpressionList { } {
        # compile expression list, of the form: "(expression (, expression)*)?"
        puts $outputFile "<expressionList>"
        if { [ $tokenizer nextToken ] != ")" } {
            compileExpression
            while { [ $tokenizer nextToken ] == "," } {
                eat ","
                compileExpression
            }
        }
        puts $outputFile "</expressionList>"
    }

}

