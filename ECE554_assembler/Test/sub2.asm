// test of subtracting negative number
ldi r1, -5
ldi r2, -10
sub r3, r2, r1  // expect r3 = -15
ldi r1, 0
jr  r1, 0