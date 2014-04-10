// test of or
ldi r1, 0xe5
ldi r2, 0xc4
or r3, r1, r2   // expect r3 = 0xc4
ldi r1, 0
jr r1, 0