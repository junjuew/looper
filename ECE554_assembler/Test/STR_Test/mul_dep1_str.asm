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