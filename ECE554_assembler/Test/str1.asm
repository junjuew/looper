ldi r0, 100
ldi r1, 5
ldi r3, 2
str r1, r0, 2      // mem[102] = 5
add r0, r0, r3
ldr r2, r0, 0      // r2 = 5
