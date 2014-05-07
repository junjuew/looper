ldi r1, -5
ldi r2, -10
sub r3, r2, r1  // expect r3 = -5
sub r4, r2, r3  // expect r4 = -5
sub r5, r3, r4  // expect r5 = 0
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