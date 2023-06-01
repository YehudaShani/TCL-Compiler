package require itcl

source "TokenizerHelper.tcl"
source "WriteFinalXML.tcl"

itcl::class CompilerEngine {
    variable tokenizer
    variable fileName
    variable outputFileName
    variable outputFile

    constructor {  } {
        set tokenizer [TokenizerHelper new]
    }



    method setFileName { _fileName } {
        set fileName $_fileName
        set outputFileName [file rootname $fileName]2.xml
        set outputFile [open $outputFileName w]
        $tokenizer setFile [file rootname $fileName]T.xml
    }

    method printTokens { } {
        # print while not end of file
        while { [ $tokenizer hasMoreTokens ] } {
            set token [ $tokenizer nextToken ]
            set types [ $tokenizer nextTokenType]
            puts "token: $token, type: $types"
            puts $outputFile "token: $token, type: $types"
            $tokenizer advance

        }
    }

    method compile { } {
        # compile class
        $tokenizer advance
        compileClass
    }

    method eat { _token } {
        set realToken [$tokenizer nextToken]
        puts "[$tokenizer getLine] "
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
            error "expected $token1 or $token2 or $token3, got [$tokenizer tokenType]"
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
        eatVarName
        eat "{"
        # compile classVarDec*
        while { [ $tokenizer nextToken ] == "static" || [ $tokenizer nextToken ] == "field" } {
            compileClassVarDec
        }
        # compile subroutineDec*
        while { [ $tokenizer nextToken ] == "constructor" || [ $tokenizer nextToken ] == "function" || [ $tokenizer nextToken ] == "method" } {
            compileSubroutineDec
        }
        eat "}"
        puts $outputFile "</class>"
    }

    method compileClassVarDec { } {
        #compile class variable declaration, of the form: "static|field type varName (, varName)*;"
        puts $outputFile "<classVarDec>"
        twoOptionsEat "static" "field"
        if { [ $tokenizer nextToken ] == "int" || [ $tokenizer nextToken ] == "char" || [ $tokenizer nextToken ] == "boolean"} {
            eatType
        } else {
            eatVarName
        }
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
            eatType
            eatVarName
            while { [ $tokenizer nextToken ] == "," } {
                eat ","
                eatType
                eatVarName
            }
        }
        puts $outputFile "</parameterList>"
    }

    method compileSubroutineBody { } {
        #compile subroutine body, of the form: "{ varDec* statements }"
        puts $outputFile "<subroutineBody>"
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
        eatType
        eatVarName
        while { [ $tokenizer nextToken ] == "," } {
            eat ","
            eatVarName
        }
        eat ";"
        puts $outputFile "</varDec>"
    }

    method compileWhileStatement { } {
        # compile while statement, of the form: "while (expression) { statements }"
        eat "while"
        eat "("
        puts $outputFile "<whileStatement>"


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
        eat "if"
        eat "("
        puts $outputFile "<ifStatement>"

        # compile expression
        compileExpression
        eat ")"
        eat "{"
        # compile statements
        compileStatements
        eat "}"

        puts $outputFile "</ifStatement>"
    }


    method compileDoStatement { } {
        # compile do statement, of the form: "do subroutineCall;"
        eat "do"
        puts $outputFile "<doStatement>"

        # compile subroutineCall
        compileSubroutineCall
        eat ";"

        puts $outputFile "</doStatement>"
    }

    method compileLet { } {
        # compile let statement, of the form: "let varName ([ expression ])? = expression;"
        eat "let"
        puts $outputFile "<letStatement>"

        # compile varName
        eatVarName
        # compile ([ expression ])? = expression
        if { [ $tokenizer nextToken ] == "\[" } {
            eat "\["
            compileExpression
            eat "\]"
        }
        eat "="
        compileExpression
        eat ";"

        puts $outputFile "</letStatement>"
    }

    method compileDo { } {
        # compile do statement, of the form: "do subroutineCall;"
        eat "do"
        puts $outputFile "<doStatement>"

        # compile subroutineCall
        compileSubroutineCall
        eat ";"

        puts $outputFile "</doStatement>"
    }

    method compileReturn { } {
        # compile return statement, of the form: "return expression?;"
        eat "return"
        puts $outputFile "<returnStatement>"

        # compile expression?
        if { [ $tokenizer nextToken ] != ";" } {
            compileExpression
        }
        eat ";"

        puts $outputFile "</returnStatement>"
    }

    method compileExpression { } {
        #dummy operation
        puts $outputFile "<expression>"
        set line [$tokenizer advance]
        puts $outputFile $line
        puts $outputFile "</expression>"

    }

}

