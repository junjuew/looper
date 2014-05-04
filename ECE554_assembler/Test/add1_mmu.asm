ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
ldi r1, 15      // load 15 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 35
