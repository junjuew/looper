ldi r1, 15      // load 15 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 35
add r2, r1, r3  // expect r2 = 50
add r4, r3, r2  // expect r4 = 85
ldi r0, 50	
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
