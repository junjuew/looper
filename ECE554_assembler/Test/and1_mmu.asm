ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1 0x00ff
ldi r2 0x00ce
and r3, r2, r1  // expect r3 = 0xce
