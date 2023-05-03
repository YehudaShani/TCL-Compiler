@256
D=A
@SP
M=D

//call Sys.init
@Return-Address-output.asm.0-1
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1

//ARG = SP - n - 5
@SP
D=M
@
D=D-A
@5
D=D-A
@ARG
M=D

//LCL = SP
@SP
D=M
@LCL
M=D

//goto function
@output.asm.0
0; JMP

//return address label
(Return-Address-output.asm.0-1)

//function Main.fibonacci 0
($Main.vm.Main.fibonacci)
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
D=M-D
@TRUElt-12
D;JLT
@SP
A=M-1
M=0
@ENDlt-12
0;JMP
(TRUElt-12)
@SP
A=M-1
M=-1
(ENDlt-12)

//if-goto IF_TRUE
@SP
M=M-1
A=M
D=M
@if-goto-false-13
D;JEQ
@IF_TRUE
0;JMP
(if-goto-false-13)

//goto function
@Main.vm.goto IF_FALSE
0; JMP
(Main.vm.label IF_TRUE          )
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1

//Frame = LCL
@LCL
D=M
@FRAME
M=D

//RET = *(FRAME-5)
@FRAME
D=M
@5
A=D-A
D=M
@RET
M=D

//*ARG = pop()
@SP
AM=M-1
D=M
@ARG
A=M
M=D

//SP = ARG + 1
@ARG
D=M+1
@SP
M=D

//THAT = *(FRAME-1)
@FRAME
D=M
@1
A=D-A
D=M
@THAT
M=D

//THIS = *(FRAME-2)
@FRAME
D=M
@2
A=D-A
D=M
@THIS
M=D

//ARG = *(FRAME-3)
@FRAME
D=M
@3
A=D-A
D=M
@ARG
M=D

//LCL = *(FRAME-4)
@FRAME
D=M
@4
A=D-A
D=M
@LCL
M=D

//goto RET
@RET
A=M
0;JMP
(Main.vm.label IF_FALSE        )
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M-D
@Return-Address-Main.vm.Main.fibonacci-16
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1

//ARG = SP - n - 5
@SP
D=M
@1
D=D-A
@5
D=D-A
@ARG
M=D

//LCL = SP
@SP
D=M
@LCL
M=D

//goto function
@Main.vm.Main.fibonacci
0; JMP

//return address label
(Return-Address-Main.vm.Main.fibonacci-16)
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
AM=M-1
D=M
A=A-1
M=M-D
@Return-Address-Main.vm.Main.fibonacci-18
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1

//ARG = SP - n - 5
@SP
D=M
@1
D=D-A
@5
D=D-A
@ARG
M=D

//LCL = SP
@SP
D=M
@LCL
M=D

//goto function
@Main.vm.Main.fibonacci
0; JMP

//return address label
(Return-Address-Main.vm.Main.fibonacci-18)
@SP
AM=M-1
D=M
A=A-1
M=M+D

//Frame = LCL
@LCL
D=M
@FRAME
M=D

//RET = *(FRAME-5)
@FRAME
D=M
@5
A=D-A
D=M
@RET
M=D

//*ARG = pop()
@SP
AM=M-1
D=M
@ARG
A=M
M=D

//SP = ARG + 1
@ARG
D=M+1
@SP
M=D

//THAT = *(FRAME-1)
@FRAME
D=M
@1
A=D-A
D=M
@THAT
M=D

//THIS = *(FRAME-2)
@FRAME
D=M
@2
A=D-A
D=M
@THIS
M=D

//ARG = *(FRAME-3)
@FRAME
D=M
@3
A=D-A
D=M
@ARG
M=D

//LCL = *(FRAME-4)
@FRAME
D=M
@4
A=D-A
D=M
@LCL
M=D

//goto RET
@RET
A=M
0;JMP

//function Sys.init 0
($Sys.vm.Sys.init)
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
@Return-Address-Sys.vm.Main.fibonacci-32
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1

//ARG = SP - n - 5
@SP
D=M
@1
D=D-A
@5
D=D-A
@ARG
M=D

//LCL = SP
@SP
D=M
@LCL
M=D

//goto function
@Sys.vm.Main.fibonacci
0; JMP

//return address label
(Return-Address-Sys.vm.Main.fibonacci-32)
(Sys.vm.label WHILE)

//goto function
@Sys.vm.goto WHILE              // loops infinitely
0; JMP
