ldi r0, 0xff		// assign 0xffff to r0
ldr r0, r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
ldi r1, 2      	// load 2 to r1
ldi r2, 1      	// load 1 to r2
add r3, r1, r2  // expect r3 = 3
add r2, r1, r3  // expect r2 = 5
add r4, r3, r2  // expect r4 = 8
sub r3, r4, r3	// expect r3 = r4 - r3 = 5
add r2, r3, r1	// expect r2 = r3 + r1 = 7
mult r5, r2, r1	// expect r5 = r2 * r1 = 14
add r5, r5, r1	// expect r5 = r5 + r1 = 16
mult r5, r5, r1	// expect r5 = r5 * r1 = 32
mult r5, r5, r1	// expect r5 = r5 * r1 = 64
add r1, r1, r2	// expect r1 = r1 + r2 = 3
mult r5, r5, r1	// expect r5 = r5 * r1 = 192
ldi r0, 50	
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
ldi r0, 0
jr	r0, 0