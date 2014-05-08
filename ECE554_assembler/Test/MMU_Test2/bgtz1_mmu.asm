ldi r0, 0
jr  r0, 0		// jump to 0xffff
nop
nop
nop
nop
nop
nop
ldi r1, 1            // set r1 to 1
ldi r2, 2	    	 // set r2 to 2
ldi r4, 4			 // set r4 to 4
sub r3, r1, r2       // r3 = r1 - r2 = -1
beqz r3, .label1     // it will not do branch here
add r3, r3, r1       // set r3 = r3 + r1 = 0
beqz r3, .label1     // it will not do branch here
add r3, r3, r2       // r3 = r3 + r2 = 2
beqz r3, .label1     // it will do branch here
add r3, r1, r2		 // set r3 = -1, but this line will be skipped
.label1:
ldi r1, 2            // set r1 to 2
ldi r2, 2	     	 // set r2 to 2
sub r3, r1, r2		 // r3 = 0
beqz r3, .label2     // it will do branch here
add r4, r4, r4	     // if the beqz above didn't branch, r4 will be 8
.label2:
add r4, r4, r1       //if the beqz above brance, r4 will be 6
ldi r0, 57	
str r1, r0, -7
str r2, r0, -6
str r3, r0, -5
str r4, r0, -4
str r5, r0, -3
str r6, r0, -2
str r7, r0, -1
str r8, r0, 0
str r9, r0, 1
str r10, r0, 2
str r11, r0, 3
str r12, r0, 4
str r13, r0, 5
str r14, r0, 6
str r15, r0, 7
ldi r0, 0
jr	r0, 0
