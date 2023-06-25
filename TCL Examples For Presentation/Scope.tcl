# #static scope:
# set x 10
# proc outerProcedure {} {
#     set x 20
#     innerProcedure
# }
# proc innerProcedure {} {
#     puts $x
# }
# outerProcedure ;#call


# proc foreachmultidemo {args} {
#     foreach {a b} $args {
#         puts "a=$a, b=$b, a+b=[expr {$a+$b}]"
#     }
# }
# foreachmultidemo 1 2 3 4 5 6


proc lassigndemo {mylist} {
    foreach pair $mylist {
        lassign $pair a b
        puts "a=$a, b=$b, a+b=[expr {$a+$b}]"
    }
}
lassigndemo {{1 2} {3 4} {5 6}}

