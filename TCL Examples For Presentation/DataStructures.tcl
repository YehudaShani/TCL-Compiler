# # Using Lists
# set myList {apple banana cherry}
# puts "List: $myList"
# puts "Length of the list: [llength $myList]"
# puts "First element: [lindex $myList 0]"
# puts "Last element: [lindex $myList end]"
# puts "Join list elements: [join $myList ,]"


# proc foreachmultidemo {args} {
#    foreach {a b} $args {
#        puts "a=$a, b=$b, a+b=[expr {$a+$b}]" 
#    } 
# } ; foreachmultidemo 1 2 3 4 5 6  ; puts " "

# proc foreachdoubledemo {list1 list2} {
#    foreach a $list1 b $list2 {
#        puts "a=$a, b=$b, a+b=[expr {$a+$b}]"   
#     }
# } ; foreachdoubledemo {1 2 3} {4 5 6}






# Using Dicts (Dictionaries)
set myDict [dict create]
dict set myDict fruit1 apple
dict set myDict fruit2 banana
dict set myDict fruit3 cherry
puts "Dict: $myDict"
puts "Value of fruit2: [dict get $myDict fruit2]"
puts "Keys of the dict: [dict keys $myDict]"
puts "Values of the dict: [dict values $myDict]"
