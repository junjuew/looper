ldi r0, 0xff		// assign 0xffff to r0
ldr r0, r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
ldi r1,2   //load 2 to r1
ldi r2,4   //load 4 to r2
ldi r3,4   //load 4 to r3
ldi r4,6   //load 6 to r4
mult r5,r1,r2   // expect r5 = 8
mult r6,r3,r4   // expect r6 = 24
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
ldi r0, 0
jr	r0, 0