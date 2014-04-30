# fixed point iteration
# get square root of a given number C
# x(n+1) = 1/2 * [x(n) + C / x(n)]

# GLOBAL DATA
.data  
C:		.word	16
Zero:	.word	0
One:	.word	1

# PROGRAM START
.text
.globl main # globally define 'main' 
main: # initialization

lw 	$s0, 	Zero			# s0 will be the division counter and memory base index
lw	$s1, 	C				# s1 = C
add $s2, 	$s2, 	$s1		# s2 = s1, s2 will always be a copy of s1
lw 	$s3, 	One				# s3 will serve as x(n)
lw 	$s4, 	Zero			# s4 will serve as x(n+1)
lw 	$s5, 	One				# constant 1
lw 	$s7, 	Zero			# constant 0

# main program
main_start:
# do C / x(n)
divide_start:
# this loop produces result of C / x(n)
sub $s2, 	$s2, 	$s3
slt	$t0,	$s2,	$s7
beq	$t0,	$s5, 	divide_end
add $s0, 	$s0, 	$s5		# increment counter
j		divide_start
divide_end:	
# now s0 = C / x(n)
# do x(n) + C / x(n)
add $s0, 	$s0, 	$s3		# s0 = s0 + s3 = C / x(n) + x (n)
# do [x(n) + C / x(n)] / 2
sra $s4, 	$s0, 	1		# s4 = s0 >> 1 = s4 / 2 ==> x(n+1) = 1/2 * [x(n) + C / x(n)]
add $s2, 	$s1, 	$s7		# reset s2, so that s2 = s1 = C again
# convergent?
sub $s6, 	$s4, 	$s3
# if yes, quit the loop, and r4 should contain the final result
beq	$s6, 	$s7, 	main_end
# else, update x(n), and redo the loop
add $s3, 	$s4, 	$s7		# s3 = s4 + 0 = s4
add $s0, 	$0,		$0		# s0 = 0
j		main_start
main_end:
add	$s4, 	$s4, 	$s7		# s4 = s4 + 0 = s4


syscall # this ends execution 
 
.end

