# program will go through xml file and give helper functions such as advance, type, hasMoreTokens, etc.


itcl::class TokenizerHelper {
    variable fileName
    variable fileReader

    constructor { } {
    }



    method setFile {_fileName} {
        set fileName $_fileName
        set fileReader [open $fileName r]
    }

    method advance {} {
        set line [gets $fileReader]
        return $line
    }

    method tokenType { line } {
        # receives a line and returns the type of the line
        # returns: keyword, symbol, identifier, int_const, string_const

        set wordList [split $line " "]
        set firstWord [lindex $wordList 0]
        set modifiedString [string range $firstWord 1 end-1]
        return $modifiedString

    }

    method tokenType { line } {
        # receives a line and returns the type of the line
        # returns: keyword, symbol, identifier, int_const, string_const

        set wordList [split $line " "]
        set firstWord [lindex $wordList 0]
        set modifiedString [string range $firstWord 1 end-1]
        return $modifiedString

    }

    method hasMoreTokens {} {
        #check if end of file
        if {[eof $fileReader]} {
            return 0
        }
        return 1
    }
}
