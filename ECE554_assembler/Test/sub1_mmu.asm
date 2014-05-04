ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1, 5
ldi r2, 10
sub r3, r2, r1  // expect r3 = 5
