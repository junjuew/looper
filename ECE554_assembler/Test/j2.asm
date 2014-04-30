// test for j
ldi r1, -5
.label1:
ldi r2, 9
j	.label1
add r3, r2, r1	// expect r3 = 4
j	.end
ldi r3, -4
.end:
ldi r2, 9