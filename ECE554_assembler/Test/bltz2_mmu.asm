ldi r0, 0xff		// assign 0xffff to r0
jr  r0, 0		// jump to 0xffff
nop
nop
.label1:
ldi r1, 1            // set r1 to 1
ldi r2, 1	    	 // set r2 to 2
ldi r4, 2			 // set r4 to 4
add r3, r1, r2       // r3 = r1 + r2 = 2
bltz r3, .label1     // it will not do branch here
sub r3, r3, r4       // r3 = r3 - r4 = 0
bltz r3, .label1     // it will not do branch here
sub r3, r3, r1       // set r3 = r3 - r1 = -1
bltz r3, .label1     // it will do branch here
