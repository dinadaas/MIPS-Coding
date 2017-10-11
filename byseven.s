.data

inputMsg: .asciiz "Enter number:"
newline: .asciiz "\n"

.text

main: 
	addi $sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)

	la	$a0, inputMsg
	li	$v0, 4
	syscall
	li $v0, 5
	syscall

	move $s2, $v0
	move $s1, $0
	move $s0, $0

printloop:
	addu $s0, 1
	addu $s1, 7

	li $v0, 1
	move $a0, $s1
	syscall
	la $a0, newline
	li $v0, 4
	syscall

	bne $s0, $s2, printloop
	j clean

clean:
	move $v0, $0
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra