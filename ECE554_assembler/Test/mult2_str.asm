ldi r1,2   //load 2 to r1
ldi r2,4   //load 4 to r2
ldi r3,4   //load 4 to r3
ldi r4,6   //load 6 to r4
mult r5,r1,r2   // expect r5 = 8
mult r6,r3,r4   // expect r6 = 24
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
