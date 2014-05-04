ldi r0, 100
ldi r1, 5
str r1, r0, -2      // mem[98] = 5
ldr r2, r0, -2      // r2 = 5
