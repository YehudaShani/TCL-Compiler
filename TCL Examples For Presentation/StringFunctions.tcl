puts "\n\n"
set string "Hello, World!"

puts [string length $string]
puts [string toupper $string]
puts [string tolower $string]
puts [string range $string 0 4]
puts [string trim $string]
puts [string compare $string "Hello, Earth!"]
puts [string is digit "123"]
puts [string map {o a} $string]
puts [string first "o" $string]
puts [string last "o" $string]
puts [string match "*World*" $string]





