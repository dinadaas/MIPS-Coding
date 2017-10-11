.data

inputMsg: .asciiz "Enter number:"
newline: .asciiz "\n"


.text

main: 

la	$a0, inputMsg
li	$v0, 4
syscall

li $v0, 5
syscall

move $t0, $v0
li $t1, 1
printf:
	move $a0, $t1
	jal fib_recurse

	move $a0, $v0
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	addi $t1, $t1, 1
	ble $t1, $t0, printf




li $v0, 10
syscall	

fib_recurse:
	addi $sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$s0, 8($sp)
	sw	$s1, 12($sp)

	li $s0, 1
	beq $s0, $a0, fib
	li $s0, 2
	beq $s0, $a0, fib

	addi	$a0, $a0, -1
	jal	fib_recurse
	move $s0, $v0

	addi	$a0, $a0, -1
	jal	fib_recurse
	move $s1, $v0

	add $v0, $s0, $s1

clean:
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	addi $sp, $sp, 16
	jr $ra

fib:
	li	$v0, 2
	j clean
