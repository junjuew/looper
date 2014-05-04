ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1, 0x00e5
ldi r2, 0x00c4
or r3, r1, r2   // expect r3 = 0xc4
