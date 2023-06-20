package require itcl

itcl::class SR_SymbolTable {

    # ASSUMES THAT ALL NAMES ARE UNIQUE!!!

    variable symbolList { } ; #holds the symbols, each as a string in this format:
                         # "|NAME: name|CATEGORY: cate|TYPE: type|INDEX: index|END"
    variable classCounter 0
    variable subroutineCounter 0
    variable fieldCounter 0
    variable staticCounter 0
    variable localCounter 0
    variable argCounter 0
    variable st_name ""

    # repsonse codes:
    variable RES_NOT_FOUND 1
    variable RES_FOUND 0

    method reset { } {
        set symbolList { }
        set classCounter 0
        set subroutineCounter 0
        set fieldCounter 0
        set staticCounter 0
        set localCounter 0
        set argCounter 0

    }

    
    method addSymbolWithName { _name } {

        set existingIndex [getIndexOfSymbolByName $_name]
        if { $existingIndex >= 0} {
            #if already exists..
            puts [concat "ERROR tried adding symbol, it already exists! - " $_name]
            return -1
        }
        set res ""
        append res "|NAME: "
        append res $_name
        append res "|CATEGORY: |TYPE: |INDEX: |END"
        lappend symbolList $res
        return [getIndexOfSymbolByName $_name]
    }
    # method addSymbolNameCateType { _name _cate _type } {
    #     setType [setCategory [addSymbolWithName $_name] $_cate] $_type
    # }
    method getIndexOfSymbolByName { _name } {
        # use this to check if exists..
       for {set i 0} {$i < [ llength $symbolList ]} {incr i} {
            if { [isUsage $i]} {
                continue
            }
            set existingName [getName $i]
            if {[string compare $_name $existingName] == 0} {
                return $i
            }
       }
       return -1
    }
    method getFullSymbolByName { _name } {
        return [lindex $symbolList [getIndexOfSymbolByName $_name] ]
    }

# only adds the usage if we recognize the name of the variable..
    method addUsagePRIVATE_DONT_USE { _nameOfVar decOrAssi} {
        if { [getIndexOfSymbolByName $_nameOfVar] != -1} {
            lappend symbolList [concat ">>Usage: (" $_nameOfVar ") " $decOrAssi "- found"]
            return $RES_FOUND
        } else {
            lappend symbolList [concat ">>Noticed: (" $_nameOfVar ")" $decOrAssi "- not found on this Symbol Table!" ]
            return $RES_NOT_FOUND
        }
    }
    method addUsageDecl { _nameOfVar} {
        return [addUsagePRIVATE_DONT_USE $_nameOfVar "declared/assigned"]
    }
    method addUsageUsed { _nameOfVar} {
        return [addUsagePRIVATE_DONT_USE $_nameOfVar "used"]
    }

    method isUsage { _index } {
        set firstChar [string index [lindex $symbolList $_index] 0]
        if { [string compare $firstChar ">"] == 0} {
            return true
        } else {
            return false
        }
    }

    method getNumArgs { } {
        return [expr $argCounter - 1] ; # because we always send "this" as an arg..
    }

    method getNumLocals { } {
        return $localCounter
    }

    method getName { index } {
        return [getVal [lindex $symbolList $index] "|NAME" "|CATEGORY"]
    }
    method setName { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|NAME" "|CATEGORY" $newVal] ]
        return $index
    }

    method getCategory { index } {
        return [getVal [lindex $symbolList $index] "|CATEGORY" "|TYPE"]
    }
    method setCategory { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|CATEGORY" "|TYPE" $newVal] ]
        if { $newVal == "class" } {
            setIndex $index $classCounter
            incr classCounter
            setType $index "class"
        }
        if { $newVal == "subroutine" } {
            setIndex $index $subroutineCounter
            incr subroutineCounter
            setType $index "subroutine"
        }
        if { $newVal == "field" } {
            setIndex $index $fieldCounter
            incr fieldCounter
        }
        if { $newVal == "static" } {
            setIndex $index $staticCounter
            incr staticCounter
        }
        if { $newVal == "local" } {
            setIndex $index $localCounter
            incr localCounter
        }
        if { $newVal == "arg" } {
            setIndex $index $argCounter
            incr argCounter
        }
        return $index
    }

    method getType { index } {
        return [getVal [lindex $symbolList $index] "|TYPE" "|INDEX" ]
    }
    method setType { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|TYPE" "|INDEX" $newVal] ]
        return $index
    }

    method getIndex { index } {
        return [getVal [lindex $symbolList $index] "|INDEX" "|END"]
    }
    method setIndex { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|INDEX" "|END" $newVal] ]
        return $index
    }

    method getClassName { } {
        for {set i 0} {$i < [ llength $symbolList ]} {incr i} {
            if { [isUsage $i]} {
                continue
            }
            if { [getCategory $i] == "class" } {
                return [getName $i]
            }
        }
        return "ERROR - COULDNT FIND CLASS NAME..."
    }

    # PRIVATE:
    method setVal { symbol begin end newVal} {
        set left [expr [string first $begin $symbol] + [string length $begin] + 1]
        set right [expr [string first $end $symbol] ]
        set res ""
        append res [string range $symbol 0 $left]
        append res $newVal
        append res [string range $symbol $right end]
        return $res
    }
    method getVal { symbol begin end } {
        set left [expr [string first $begin $symbol] + [string length $begin] + 2]
        set right [expr [string first $end $symbol] - 1 ]
        return [string range $symbol $left $right]
    }

    method allSymbols { } {
        set result "symbol table:\n"

        set slCopy $symbolList
        for {set i 0} {$i < [ llength $symbolList ]} {incr i} {

            if {[isUsage $i]} {
                append result [lindex $symbolList $i]
                append result "\n"
                continue
            }

            set diff [expr 12 - [string length [getName $i] ] ]
            if {$diff > 0} {
                setName $i [concat [getName $i] [getSpaces $diff]]
            }
            set diff [expr 12 - [string length [getCategory $i] ] ]
            if {$diff > 0} {
                setCategory $i [concat [getCategory $i] [getSpaces $diff]]
            }
            set diff [expr 12 - [string length [getType $i] ] ]
            if {$diff > 0} {
                setType $i [concat [getType $i] [getSpaces $diff]]
            } 
            set diff [expr 12 - [string length [getIndex $i] ] ]
            if {$diff > 0} {
                setIndex $i [concat [getIndex $i] [getSpaces $diff]]
            }            
            append result [lindex $symbolList $i]
            append result "\n"
        }
        set symbolList $slCopy
        return $result
    }
    
    method getSpaces { n } {
        set res ""
        for {set i 0} {$i < $n} {incr i} {
            append res "-"
        }
        return $res
    }


 }