ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1, 0	// constant 0
ldi r2, 1	// constant 1
ldi r3, 100	// memory start at 500
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
ldi r3, 100	// memory start
ldi r4, 5	// length of array
ldi r5, 100	// outter index
ldi r12, 105	// constant 105
.outter_loop:
beqz r4, .end_outter_loop
add r6, r5, r2	// generate inner index
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
j	.inner_loop
.end_inner_loop:
add r5, r5, r2	// update outter loop index
sub r4, r4, r2
j	.outter_loop
.end_outter_loop:
add r1, r1, r1

