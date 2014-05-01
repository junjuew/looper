// first 11 Fibonacci numbers
ldi r1, 0		// this would be the counter
ldi r2, 0		// this would be prev number1
ldi r3, 1 		// this would be prev number2
ldi r4, 0		// constant 0
ldi r6, 1 		// constant 1
ldi r7, 23		// constant 24
.loop_start:
add	r5, r2, r3	// generate the next Fibonacci number
add r2, r3, r4	// update prev number 1
add r3, r5, r4	// update prev number 5
sub r7, r7, r6	// r7 = r7 - 1
bgtz	r7, .loop_start	// branch if not reaching 24 times
add r5, r5, r4	// else r5 = r5
