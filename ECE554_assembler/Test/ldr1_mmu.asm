ldi r0, 0xff		// assign 0xffff to r0
ldr r0, r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
ldi r0, 100
ldi r1, 5
str r1, r0, 2      // mem[102] = 5
ldr r2, r0, 2      // r2 = 5
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