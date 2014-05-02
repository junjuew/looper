// fixed point iteration
// get square root of a given number C
// x(n+1) = 1/2 * [x(n) + C / x(n)]

// initialization
ldi r1,	0		// r1 will be the division counter and memory base index
ldi r2, 16	// r2 <-64, r2 contains C
add r3, r2, r1	// r3 = r2, r3 will always be a copy of r2
ldi r4, 1		// r4 will serve as x(n)
ldi r5, 0		// r5 will serve as x(n+1)
ldi r6, 1		// constant 1
ldi r8, 0		// constant 0

// main program
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
add	r5, r5, r8	// r5 = r5 + 0 = r5

