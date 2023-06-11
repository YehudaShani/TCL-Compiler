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

    method reset { } {
        set symbolList { }
        set classCounter 0
        set subroutineCounter 0
        set fieldCounter 0
        set staticCounter 0
        set localCounter 0
        set argCounter 0

    }

    # method getAndIncrCounter { counterType } {
    #     # do other counters!
    #     if { $counterType == "class" } {
    #         incr classCounter
    #         return [expr $classCounter - 1]
    #     } 
    # }
    method addSymbolWithName { _name } {

        set existingIndex [getIndexOfSymbolByName $_name]
        if { $existingIndex >= 0} {
            #if already exists..
            return $existingIndex
        }
        set res ""
        append res "|NAME: "
        append res $_name
        append res "|CATEGORY: |TYPE: |INDEX: |END"
        lappend symbolList $res
        return [getIndexOfSymbolByName $_name]
    }
    
    method getIndexOfSymbolByName { _name } {
        # use this to check if exists..
       for {set i 0} {$i < [ llength $symbolList ]} {incr i} {
            set symbol [lindex $symbolList $i]
            if {[string first $_name $symbol] != -1} {
                return $i
            }
       }
       return -1
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
            if { [getCategory $i] == "class" } {
                return getName $i
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
        for {set i 0} {$i < [ llength $symbolList ]} {incr i} {
            append result [lindex $symbolList $i]
            append result "\n"
        }
        return $result
    }
    
 }