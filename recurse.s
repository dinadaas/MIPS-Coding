.data

inputMsg: .asciiz "Enter number:\n"
#f(N) = 3*(N-1)+f(N-1)+1.

.text

main: 

la	$a0, inputMsg #loads input message
li	$v0, 4  #prints message
syscall

li $v0, 5  #reads in a value, stores it in v0
syscall


move $a0, $v0
jal recurse
move $a0, $v0
li $v0, 1
syscall


li $v0, 10
syscall	


recurse:

	addi $sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$t0, 12($sp)
	sw	$t1, 16($sp)
	beq $s0, $a0, base
	move $t0, $a0
	sub	$t0, $t0, 1
	mul $a0, $t0, 3
	move $a1, $a0

	move $a0, $t0
	jal recurse

	move $t1, $v0
	mul $a0, $t1, 1

	add $a1, $a0, $a1
	add $a1, $a1, 1

	move $v0, $a1


clean:
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$t0, 12($sp)
	lw	$t1, 16($sp)
	#lw	$s0, 20($sp)
	addi $sp, $sp, 20
	jr $ra

base:
	#addi $v0, $v0, 5
	li $v0, 2
	j clean
	#li $v0, 10
	#syscall	
