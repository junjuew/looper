ldi r1, -5
ldi r2, 9
j	.label1
add r3, r2, r1	// expect r3 = 4
j	.end
.label1:
ldi r3, -4
.end:
ldi r2, 9
