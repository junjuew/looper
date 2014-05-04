ldi r1, -5
ldi r2, -10
sub r3, r2, r1  // expect r3 = -5
sub r4, r2, r3  // expect r4 = -5
sub r5, r3, r4  // expect r5 = 0
