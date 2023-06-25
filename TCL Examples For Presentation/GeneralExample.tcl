package require itcl
itcl::class Example { 
    variable total 0
    method calc { x y } { 
        set sum [expr $x + $y]
        set total [expr $total + $sum + 1]
        return [concat $sum " " $total] 
    }
}
proc print { str times } {
    for {set index 0} {$index < $times} {incr index} {
        puts str$str
    }
}
Example ex
print [ex calc 3 4] 3


# NOTICE:
# only one constructor
# a "proc" can exist w/out a class
# params are just sent falanga
# sensitive to " " "\n"
# line 6 - expr
# line 8 vs 13