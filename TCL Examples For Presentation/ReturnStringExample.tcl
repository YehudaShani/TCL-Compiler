
package require itcl
itcl::class MyClass {
    method hello2 { } { return "hi! class"}
}
itcl::class Factory {
    method hello { } { return "hi! fact"}
    method getClass { } { 
        set myClass [MyClass MyClass::new]
        return $myClass }
    method callClass { } { 
        set myClass [MyClass MyClass::new]
        return [ $myClass hello2 ] }
} ; #main:
set fact [Factory Factory::new]
puts "what's in fact?: $fact"
puts "fact calling function: [$fact hello]"
puts "fact calling class's: [$fact callClass]"
set class [$fact getClass]
puts "what's in class?: $class"
puts "class calling function: [$class hello2]"

# Notice:
# Main has an obj Factory, can access functions
# Factory can return results from it's inner class
# but factory CANT return a reference 
# to it's innner class... interpreted as a string
# 

























