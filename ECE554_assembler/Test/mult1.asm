ldi r1, 2      	// load 2 to r1
ldi r2, 1      	// load 1 to r2
add r3, r2, r1	// expect r3 = r2 + r1 = 3
mult r5, r2, r1	// expect r5 = r2 * r1 = 2
mult r2, r3, r1	// expect r2 = r3 * r1 = 6
