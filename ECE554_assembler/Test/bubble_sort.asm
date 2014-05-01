ldi r1, 0	// constant 0
ldi r2, 1	// constant 1
ldi r3, 500	// memory start at 500
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

// r1	constant 0
// r2	constant 1
// r3	memory start
// r4	length of array, outter count
// r5	outter index
// r6	inner index
// r7	first number to compare
// r8 	second number to compare
// r9	inner count
// r10	result of r7-r8
// r11	temp number

ldi r3, 500	// memory start
ldi r4, 40	// length of array
ldi r5, 0	// outter index

.outter_loop:
beqz r4, .end_outter_loop
add r6, r5, r2	// generate inner index
sub r9, r4, r5	
sub r9, r9, r2	// generate inner count
.inner_loop:
beqz r9, .end_inner_loop
ldr r7, r5, 0	// load first number
ldr r8, r6, 0	// load second number
sub r10, r7, r8	// r10 = r7 - r8
bltz r10, .swap_end
add r10, r7, r1	// r10 = r7
add r7, r8, r1	// r7 = r8
add r8, r10, r1 // r8 = r10 
.swap_end:
sub r9, r9, r2
j	.inner_loop
.end_inner_loop:
add r5, r5, r2
sub r4, r4, r2
j	.outter_loop
.end_outter_loop:
add r1, r1, r1

