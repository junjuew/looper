ldi r1,2   //load 2 to r1
ldi r2,4   //load 4 to r2
ldi r3,4   //load 4 to r3
ldi r4,6   //load 6 to r4
mult r5,r1,r2   // expect r5 = 8
mult r6,r3,r4   // expect r6 = 24
