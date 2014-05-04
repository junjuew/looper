ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1,	0		// r1 will be the division counter and memory base index
ldi r2, 16	// r2 <-64, r2 contains C
add r3, r2, r1	// r3 = r2, r3 will always be a copy of r2
ldi r4, 1		// r4 will serve as x(n)
ldi r5, 0		// r5 will serve as x(n+1)
ldi r6, 1		// constant 1
ldi r8, 0		// constant 0
.main_start:
add r1, r8, r8	// reset r1
.divide_start:
sub r3, r3, r4
bltz	r3, .divide_end
add r1, r1, r6	// increment counter
j		.divide_start
.divide_end:
add r1, r1, r4	// r1 = r1 + r4 = C / x(n) + x (n)
sra r5, r1, r6	// r5 = r1 >> 1 = r1 / 2 ==> x(n+1) = 1/2 * [x(n) + C / x(n)]
add r3, r2, r8	// reset r3, so that r3 = r2 = C again
sub r7, r5, r4
beqz	r7, .main_end
add r4, r5, r8	// r4 = r5 + 0 = r5
j		.main_start
.main_end:
ldi r0, 92	// start storing registers from mem[184]
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
ldi r0, 0
jr	r0, 0