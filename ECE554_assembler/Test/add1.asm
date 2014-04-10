// test of adding two positive number

ldi r1, 15      // load 15 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 35
ldi r1, 0
jr  r1, 0       // jump to memory 0