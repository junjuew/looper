ldi r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
nop
ldi r1, 0x00
ldi r0, 0xff
str r0, r1, 0
ldr r2, r1, 0
str r2, r1, 1
str r2, r1, 2
str r2, r1, 3
str r2, r1, 4
ldr r3, r1, 1
ldr r4, r1, 2
ldr r4, r1, 3
ldr r4, r1, 4
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
