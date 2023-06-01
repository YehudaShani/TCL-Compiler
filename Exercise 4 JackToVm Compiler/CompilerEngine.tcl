package require itcl

source "TokenizerHelper.tcl"

itcl::class CompilerEngine {
    public variable tokenizer
    public variable fileName
    public variable outputFileName
    public variable xmlWriter

    constructor {  } {
        set tokenizer [TokenizerHelper new]
        #set xmlWriter [XMLWriter new]
    }



    method setFileName { _fileName } {
        set fileName $_fileName
        set outputFileName [file rootname $fileName]2.xml
        $tokenizer setFile $fileName
        #$xmlWriter setOutputFile $fileName
    }

    method printTokens { } {
        # print while not end of file
        while { [ $tokenizer hasMoreTokens ] } {
            set _token [ $tokenizer advance ]
            set types [ $tokenizer nextTokenType]
            puts "token: $types"
        }
    }

    method compileStatements { } {

    }



}

