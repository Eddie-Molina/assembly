@ Eddie Molina
@ Program 2
.global main
.func main
   
main:
    BL _seedrand            @ seed random number generator with current time
    MOV R0, #0              @ initialze index variable
writeloop:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ writedone           @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    PUSH {R0}               @ backup iterator before procedure call
    PUSH {R2}               @ backup element address before procedure call
    BL _getrand             @ get a random number
    MOV R1, R0
    MOV R2, #1000
    BL  mod_un
    POP {R2}                @ restore element address
    STR R0, [R2]            @ write the address of a[i] to a[i]
    POP {R0}                @ restore iterator
    ADD R0, R0, #1          @ increment index
    B   writeloop           @ branch to next loop iteration
writedone:
    MOV R0, #0              @ initialze index variable
readloop:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ readdone            @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    LDR R1, [R2]            @ read the array at address 
    PUSH {R0}               @ backup register before printf
    PUSH {R1}               @ backup register before printf
    PUSH {R2}               @ backup register before printf
    MOV R2, R1              @ move array value to R2 for printf
    MOV R7, #1000           @ move array index to R1 for printf
    CMP R8, R2
    MOVLT R8, R2
    CMP R7, R2
    MOVGT R7, R2
    MOV R1, R0
    BL  _printf             @ branch to print procedure with return
    POP {R2}                @ restore register
    POP {R1}                @ restore register
    POP {R0}                @ restore register
    ADD R0, R0, #1          @ increment index
    B   readloop            @ branch to next loop iteration
readdone:
    BL _min
    BL _max
    B _exit                 @ exit if done


mod_un:
    CMP R2, R1
    MOVHS R0, R1
    MOVHS R1, R2
    MOVHS R2,R0
    MOV R0, #0
    B check
    loop: 
       ADD R0, R0, #1
       SUB R1, R1, R2
    check:
       CMP R1, R2
       BHS loop
    MOV R0,R1
    MOV PC, LR

_max:
    MOV R4, LR
    LDR R0, =printf_max
    MOV R1, R8
    BL printf
    MOV PC, R4


_min:
    MOV R4, LR
    LDR R0, =printf_min
    MOV R1, R7
    BL  printf
    MOV PC, R4

    
_exit:  
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #21             @ print string length
    LDR R1, =exit_str       @ string at label exit_str:
    SWI 0                   @ execute syscall
    MOV R7, #1              @ terminate syscall, 1
    SWI 0                   @ execute syscall
       
_printf:
    PUSH {LR}               @ store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return
    
_seedrand:
    PUSH {LR}               @ backup return address
    MOV R0, #0              @ pass 0 as argument to time call
    BL time                 @ get system time
    MOV R1, R0              @ pass sytem time as argument to srand
    BL srand                @ seed the random number generator
    POP {PC}                @ return 
    
_getrand:
    PUSH {LR}               @ backup return address
    BL rand                 @ get a random number
    POP {PC}                @ return 
   
.data

.balign 4
a:              .skip       40
printf_str:     .asciz      "a[%d] = %d\n"
debug_str:
.asciz "R%-2d   0x%08X  %011d \n"
exit_str:       .ascii      "Terminating program.\n"
printf_max:     .asciz    "Max value = %d\n"
printf_min:     .asciz    "Min value = %d\n"
