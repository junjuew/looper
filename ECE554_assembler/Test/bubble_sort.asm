ldi r1, 0	// constant 0
ldi r2, 1	// constant 1
ldi r3, 100	// memory start at 100
ldi r5, 2	
str r5, r3, 0
add r3, r3, r2
ldi r5, 21	
str r5, r3, 0
add r3, r3, r2
ldi r5, -2	
str r5, r3, 0
add r3, r3, r2
ldi r5, 52	
str r5, r3, 0
add r3, r3, r2
ldi r5, -22	
str r5, r3, 0
add r3, r3, r2
ldi r5, -38	
str r5, r3, 0
add r3, r3, r2
ldi r5, -97	
str r5, r3, 0
add r3, r3, r2
ldi r5, 98
str r5, r3, 0
add r3, r3, r2
ldi r5, 123	
str r5, r3, 0
add r3, r3, r2
ldi r5, 321	
str r5, r3, 0
add r3, r3, r2
ldi r5, 178	
str r5, r3, 0
add r3, r3, r2
ldi r5, -169	
str r5, r3, 0
add r3, r3, r2
ldi r5, 144	
str r5, r3, 0
add r3, r3, r2
ldi r5, -16	
str r5, r3, 0
add r3, r3, r2
ldi r5, 25	
str r5, r3, 0
add r3, r3, r2
ldi r5, -4	
str r5, r3, 0
add r3, r3, r2
ldi r5, 69	
str r5, r3, 0
add r3, r3, r2
ldi r5, 39	
str r5, r3, 0
add r3, r3, r2
ldi r5, -50	
str r5, r3, 0
add r3, r3, r2
ldi r5, -240	
str r5, r3, 0
add r3, r3, r2
ldi r5, -178	
str r5, r3, 0
add r3, r3, r2
ldi r5, 239	
str r5, r3, 0
add r3, r3, r2
ldi r5, 37	
str r5, r3, 0
add r3, r3, r2
ldi r5, 19	
str r5, r3, 0
add r3, r3, r2
ldi r5, 73	
str r5, r3, 0
add r3, r3, r2
ldi r5, -100	
str r5, r3, 0
add r3, r3, r2
ldi r5, 92	
str r5, r3, 0
add r3, r3, r2
ldi r5, 108	
str r5, r3, 0
add r3, r3, r2
ldi r5, 216	
str r5, r3, 0
add r3, r3, r2
ldi r5, 49	
str r5, r3, 0
add r3, r3, r2
ldi r5, -81	
str r5, r3, 0
add r3, r3, r2
ldi r5, -121	
str r5, r3, 0
add r3, r3, r2
ldi r5, -198	
str r5, r3, 0
add r3, r3, r2
ldi r5, 196	
str r5, r3, 0
add r3, r3, r2
ldi r5, 137	
str r5, r3, 0
add r3, r3, r2
ldi r5, -184	
str r5, r3, 0
add r3, r3, r2
ldi r5, -7	
str r5, r3, 0
add r3, r3, r2
ldi r5, 55	
str r5, r3, 0
add r3, r3, r2
ldi r5, -66	
str r5, r3, 0
add r3, r3, r2
ldi r5, 172	
str r5, r3, 0
add r3, r3, r2
ldi r3, 100	// memory start
ldi r4, 40	// length of array
ldi r5, 100	// outter index
ldi r12, 140	// constant 140
.outter_loop:
beqz r4, .end_outter_loop
add r6, r5, r2	// generate inner index
sub r9, r12, r5	// generate inner count
.inner_loop:
beqz r9, .end_inner_loop
ldr r7, r5, 0	// load first number
ldr r8, r6, 0	// load second number
sub r10, r7, r8	// r10 = r7 - r8
bltz r10, .swap_end
add r10, r7, r1	// r10 = r7
add r7, r8, r1	// r7 = r8
add r8, r10, r1 // r8 = r10 
str r7, r5, 0
str r8, r6, 0
.swap_end:
sub r9, r9, r2
add r6, r6, r2	// update inner loop index
j	.inner_loop
.end_inner_loop:
add r5, r5, r2	// update outter loop index
sub r4, r4, r2
j	.outter_loop
.end_outter_loop:
ldi r0, 108	// start storing registers from mem[216]
add r0, r0, r0	
str r1, r0, 0
str r2, r0, 1
str r3, r0, 2
str r4, r0, 3
str r5, r0, 4
str r6, r0, 5
str r7, r0, 6
str r8, r0, 7
str r9, r0, 8
str r10, r0, 9
str r11, r0, 10
str r12, r0, 11
str r13, r0, 12
str r14, r0, 13
str r15, r0, 14
