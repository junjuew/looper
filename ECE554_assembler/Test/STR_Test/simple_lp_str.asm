ldi r1, 0		// this would be the counter
ldi r2, 0		// this would be prev number1
ldi r3, 1 		// this would be prev number2
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r7, 11		// constant 11
.loop_start:
add	r5, r2, r3	// generate the next Fibonacci number
add r2, r3, r4	// update prev number 1
add r3, r5, r4	// update prev number 5
add r1, r1, r6	// update counter
sub r8, r7, r1	// check counter
bgtz	r8, .loop_start	// branch if not reaching 11 times
add r5, r5, r4	// else r5 = r5
ldi r0, 57	
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