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

    method getLine { } {
        set currentPosition [tell $fileReader]
        set line [gets $fileReader]
        seek $fileReader $currentPosition
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

    method nextTokenType { } {
        # receives a line and returns the type of the line
        # returns: keyword, symbol, identifier, int_const, string_const
        variable fileReader

        #save current position
        set currentPosition [tell $fileReader]
        set line [gets $fileReader]

        set wordList [split $line " "]
        set firstWord [lindex $wordList 0]
        set modifiedString [string range $firstWord 1 end-1]

        #return to previous position
        seek $fileReader $currentPosition

        return $modifiedString
    }

    method nextToken { } {
                # receives a line and returns the type of the line
        # returns: keyword, symbol, identifier, int_const, string_const
        variable fileReader

        #save current position
        set currentPosition [tell $fileReader]
        set line [gets $fileReader]

        set wordList [split $line " "]
        set token [lindex $wordList 1]

        #return to previous position
        seek $fileReader $currentPosition

        return $token
    }

    method nextNextToken { } {
                # receives a line and returns the type of the line
        # returns: keyword, symbol, identifier, int_const, string_const
        variable fileReader

        #save current position
        set currentPosition [tell $fileReader]
        gets $fileReader
        set line [gets $fileReader]

        set wordList [split $line " "]
        set token [lindex $wordList 1]

        #return to previous position
        seek $fileReader $currentPosition

        return $token
    }

    method hasMoreTokens {} {
        #check if end of file
        variable fileReader
        set currentPosition [tell $fileReader]
        set line [gets $fileReader]
        seek $fileReader $currentPosition
        if {$line == ""} {
            return 0
        } else {
            return 1
        }
    }

}
