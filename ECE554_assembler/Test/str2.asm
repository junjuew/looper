// str test, negative offset

ldi r0, 100
ldi r3, -2
ldi r1, 5
str r1, r0, -2      // mem[98] = 5
sub r0, r0, r3
ldr r2, r0, 0      // r2 = 5