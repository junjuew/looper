// test of adding a positive and a negative number, 
// and Rt dependency on the result of previous operation

ldi r1, -18     // load -18 to r1
ldi r2, 20      // load 20 to r2
add r3, r1, r2  // expect r3 = 2
add r2, r1, r3  // expect r2 = -16
add r4, r3, r2  // expect r4 = -4