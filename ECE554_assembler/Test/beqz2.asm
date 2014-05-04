.label1:
ldi r1, 1            // set r1 to 1
ldi r2, 2	    	 // set r2 to 2
ldi r4, 4			 // set r4 to 4
sub r3, r1, r2       // r3 = r1 - r2 = -1
beqz r3, .label1     // it will not do branch here
add r3, r3, r2       // r3 = r3 + r2 = 1
beqz r3, .label1     // it will not do branch here
sub r3, r3, r1       // set r3 = r3 - r1 = 0
beqz r3, .end     // it will do branch here
add r3, r1, r2		 // set r3 = -1, but this line will be skipped
.end:
ldi r1, 1