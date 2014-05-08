ldi r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
nop
ldi r1, 100		// memory base register
ldi r3, 100		// prev number1 memory base
ldi r5, 101		// prev number2 memory base
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r2, 2		// constant 2
ldi r7, 23		// constant 23
str r4, r1, 0		// mem[100] = 0
add r1, r1, r6		// r1 = 101
str r6, r1, 0		// mem[101] = 1
add r1, r1, r6		// r1 = 102
.loop_start:
ldr r9, r3, 0		// r9 = prev number1
ldr r10, r5, 0		// r10 = prev number 2
add r11, r9, r10	// generate the next Fibonacci number
str r11, r1, 0		// store the next Fibonacci number
add r1, r1, r6
add r9, r10, r4		// update prev number 1
add r10, r11, r4	// update prev number 2
add r3, r3, r6		// update prev number 1's memory base
add r5, r5, r6		// update prev number 2's memory base
str r9, r3, 0		// store prev number 1
str r10, r5, 0		// store prev number 2
sub r7, r7, r6		// r7 = r7 - 1
bgtz	r7, .loop_start	// branch if not reaching 24 times
add r5, r5, r4		// else r5 = r5
ldi r0, 124	// start storing registers from mem[241] ~ mem[255]
add r0, r0, r0	
str r1, r0, -7
str r2, r0, -6
str r3, r0, -5
str r4, r0, -4
str r5, r0, -3
str r6, r0, -2
str r7, r0, -1
str r8, r0, 0
str r9, r0, 1
str r10, r0, 2
str r11, r0, 3
str r12, r0, 4
str r13, r0, 5
str r14, r0, 6
str r15, r0, 7
ldi r0, 0
jr	r0, 0
