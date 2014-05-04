ldi r1, 15      // load 15 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 35
add r2, r1, r3  // expect r2 = 50
add r4, r3, r2  // expect r4 = 85