ldi r1, 0		// this would be the counter
ldi r2, 0		// this would be prev number1
ldi r3, 1 		// this would be prev number2
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r7, 23		// constant 24
.loop_start:
add	r5, r2, r3	// generate the next Fibonacci number
add r2, r3, r4	// update prev number 1
add r3, r5, r4	// update prev number 5
sub r7, r7, r6	// r7 = r7 - 1
bgtz	r7, .loop_start	// branch if not reaching 24 times
add r5, r5, r4	// else r5 = r5
ldi r0, 116	// start storing registers from mem[232]
add r0, r0, r0	
str r1, r0, 0
str r2, r0, 1
str r3, r0, 2
str r4, r0, 3
str r5, r0, 4
str r6, r0, 5
str r7, r0, 6
str r8, r0, 7
str r9, r0, 8
str r10, r0, 9
str r11, r0, 10
str r12, r0, 11
str r13, r0, 12
str r14, r0, 13
str r15, r0, 14
