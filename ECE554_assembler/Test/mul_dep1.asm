// 
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