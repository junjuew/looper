ldi r1, 1            // set r1 to 1
ldi r2, 1	    	 // set r2 to 2
ldi r4, 2			 // set r4 to 4
add r3, r1, r2       // r3 = r1 + r2 = 2
bltz r3, .label1     // it will not do branch here
sub r3, r3, r4       // r3 = r3 - r4 = 0
bltz r3, .label1     // it will not do branch here
sub r3, r3, r1       // set r3 = r3 - r1 = -1
bltz r3, .label1     // it will do branch here
add r3, r1, r2		 // set r3 = 2, but this line will be skipped
.label1:
ldi r1, 2            // set r1 to 2
ldi r2, 2	     	 // set r2 to 2
sub r3, r1, r2		 // r3 = 0
beqz r3, .label2     // it will do branch here
add r4, r4, r4	     // if the beqz above didn't branch, r4 will be 4
.label2:
add r4, r4, r1       //if the beqz above brance, r4 will be 3