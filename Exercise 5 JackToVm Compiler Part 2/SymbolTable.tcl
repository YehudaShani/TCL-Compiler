package require itcl

itcl::class SymbolTable {

    # ASSUMES THAT ALL NAMES ARE UNIQUE!!!

    variable symbolList { } ; #holds the symbols, each as a string in this format:
                         # "|NAME: name|CATEGORY: cate|TYPE: type|INDEX: index|END"

    constructor { } {

   }

    method addSymbolWithName { _name } {
        set existsAlready [getIndexOfSymbolByName $_name]
        if { $existsAlready  >= 0} {
            #if already exists..
            return $existsAlready
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
    }

    method getCategory { index } {
        return [getVal [lindex $symbolList $index] "|CATEGORY" "|TYPE"]
    }
    method setCategory { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|CATEGORY" "|TYPE" $newVal] ]
    }

    method getType { index } {
        return [getVal [lindex $symbolList $index] "|TYPE" "|INDEX" ]
    }
    method setType { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|TYPE" "|INDEX" $newVal] ]
    }

    method getIndex { index } {
        return [getVal [lindex $symbolList $index] "|INDEX" "|END"]
    }
    method setIndex { index newVal } {
        set symbolList [lreplace $symbolList $index $index [setVal [lindex $symbolList $index] "|INDEX" "|END" $newVal] ]
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
        set left [expr [string first $begin $symbol] + [string length $begin] + 1]
        set right [expr [string first $end $symbol] - 1 ]
        return [string range $symbol $left $right]
    }

    method allSymbols { } {
        set result ""
        foreach s $symbolList {
            append result $s
            append result "\n"
        }
        return $result
    }
    
    
 }
