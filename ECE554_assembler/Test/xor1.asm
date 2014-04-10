// test of xor
ldi r1, 0xec
ldi r2, 0xce
xor r3, r2, r1  // expect r3 = 0x22
ldi r1, 0
jr  r1, 0