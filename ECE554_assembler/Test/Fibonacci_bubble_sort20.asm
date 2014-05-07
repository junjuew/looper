ldi r1, 50		// memory base register
ldi r3, 50		// prev number1 memory base
ldi r5, 51		// prev number2 memory base
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r2, 2		// constant 2
ldi r7, 23		// constant 23
str r4, r1, 0		// mem[50] = 0
add r1, r1, r6		// r1 = 101
str r6, r1, 0		// mem[51] = 1
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
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
ldi r1, 0	// constant 0
ldi r2, 1	// constant 1
ldi r3, 100	// memory start at 100
ldi r5, 2	
str r5, r3, 0
add r3, r3, r2
ldi r5, 21	
str r5, r3, 0
add r3, r3, r2
ldi r5, -2	
str r5, r3, 0
add r3, r3, r2
ldi r5, 52	
str r5, r3, 0
add r3, r3, r2
ldi r5, -22	
str r5, r3, 0
add r3, r3, r2
ldi r5, -38	
str r5, r3, 0
add r3, r3, r2
ldi r5, -97	
str r5, r3, 0
add r3, r3, r2
ldi r5, 98
str r5, r3, 0
add r3, r3, r2
ldi r5, 103	
str r5, r3, 0
add r3, r3, r2
ldi r5, 107	
str r5, r3, 0
add r3, r3, r2
ldi r5, 108	
str r5, r3, 0
add r3, r3, r2
ldi r5, -98	
str r5, r3, 0
add r3, r3, r2
ldi r5, -10	
str r5, r3, 0
add r3, r3, r2
ldi r5, 115	
str r5, r3, 0
add r3, r3, r2
ldi r5, 106	
str r5, r3, 0
add r3, r3, r2
ldi r5, -120	
str r5, r3, 0
add r3, r3, r2
ldi r5, -7	
str r5, r3, 0
add r3, r3, r2
ldi r5, 55	
str r5, r3, 0
add r3, r3, r2
ldi r5, -66	
str r5, r3, 0
add r3, r3, r2
ldi r5, 104	
str r5, r3, 0
add r3, r3, r2
ldi r3, 100	// memory start
ldi r4, 20	// length of array
ldi r5, 100	// outter index
ldi r12, 120	// constant 120
.outter_loop:
beqz r4, .end_outter_loop
add r6, r5, r2	// generate inner index
sub r11,r6,r12
beqz r11,.end_inner_loop
sub r9, r12, r5	// generate inner count
.inner_loop:
beqz r9, .end_inner_loop
ldr r7, r5, 0	// load first number
ldr r8, r6, 0	// load second number
sub r10, r7, r8	// r10 = r7 - r8
bltz r10, .swap_end
add r10, r7, r1	// r10 = r7
add r7, r8, r1	// r7 = r8
add r8, r10, r1 // r8 = r10 
str r7, r5, 0
str r8, r6, 0
.swap_end:
sub r9, r9, r2
add r6, r6, r2	// update inner loop index
sub r11,r6,r12
beqz r11,.end_inner_loop
j	.inner_loop
.end_inner_loop:
add r5, r5, r2	// update outter loop index
sub r4, r4, r2
j	.outter_loop
.end_outter_loop:
ldi r1, 0
