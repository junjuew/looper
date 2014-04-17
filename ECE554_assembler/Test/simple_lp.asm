// first 11 Fibonacci numbers
ldi r1, 0		// this would be the counter
ldi r2, 0		// this would be prev number1
ldi r3, 1 		// this would be prev number2
.loop_start:
add	r4, r2, r3	// generate the next Fibonacci number