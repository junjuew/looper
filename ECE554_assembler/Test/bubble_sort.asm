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
ldi r5, 127	
str r5, r3, 0
add r3, r3, r2
ldi r5, 178	
str r5, r3, 0
add r3, r3, r2
ldi r5, -98	
str r5, r3, 0
add r3, r3, r2
ldi r5, 111	
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
ldi r5, -120	
str r5, r3, 0
add r3, r3, r2
ldi r5, -52	
str r5, r3, 0
add r3, r3, r2
ldi r5, 109	
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
ldi r5, 101	
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
ldi r5, -10	
str r5, r3, 0
add r3, r3, r2
ldi r5, 115	
str r5, r3, 0
add r3, r3, r2
ldi r5, 106	
str r5, r3, 0
add r3, r3, r2
ldi r5, -120	
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
ldi r5, 104	
str r5, r3, 0
add r3, r3, r2
ldi r3, 100	// memory start
ldi r4, 40	// length of array
ldi r5, 100	// outter index
ldi r12, 140	// constant 140
.outter_loop:
beqz r4, .end_outter_loop
add r6, r5, r2	// generate inner index
sub r11,r6,r12
beqz r11,.end_inner_loop
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
sub r11,r6,r12
beqz r11,.end_inner_loop
j	.inner_loop
.end_inner_loop:
add r5, r5, r2	// update outter loop index
sub r4, r4, r2
j	.outter_loop
.end_outter_loop:
ldi r1, 0
