ldi r1, 100		// memory base register
ldi r3, 0		// prev number1 memory base
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r2, 2		// constant 2
ldi r7, 9		// constant 9
str r2, r1, 0		// mem[0] = 2
.loop_start2:
ldr r9, r1, 0		// r9 = prev number1
add r9, r9, r6		// r9 = r9 + 1
mult r9, r9, r2		// r9 = r9 * 2
add r1, r1, r6
str r9, r1, 0		// store the next Fibonacci number
sub r7, r7, r6		// r7 = r7 - 1
bgtz r7,	.loop_start2
add r5, r5, r4		// else r5 = r5
