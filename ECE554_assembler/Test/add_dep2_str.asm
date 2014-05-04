ldi r1, -18     // load -18 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 2
add r2, r1, r3  // expect r2 = -16
add r4, r3, r2  // expect r4 = -14
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
