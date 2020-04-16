.data
filename: .asciiz "/Users/avik/Desktop/My Stuff/SBU/Sophomore Year/Spring 2019/CSE 220/Spring 2019/Projects/Project 4/boards/generic_board2.txt"
.align 2
board: .space 1000
buffer: .asciiz "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
turns: .asciiz "X0104X0307X0408O1107O0708O1101X1102X1107O0801X0205O0003X0903X0907X0304O0305X0601X0106X0009O0507X0006O1109X0507X0503O0005X0004X0509X0500O1104X0105O0501"
num_columns: .asciiz "Number of columns: "
num_rows: .asciiz "Number of rows: "
v0: .asciiz "v0: "
v1: .asciiz "v1: "
done: .asciiz "Board has been added!"

num_turns_to_play: .word 30

.text
.globl main

main:

la $a0, board
la $a1, filename
la $a2, turns
lw $a3, num_turns_to_play

jal simulate_game

move $t0, $v0
move $t1, $v1

print:

    la $a0, v0
    li $v0, 4
    syscall

    li $v0, 1
    move $a0, $t0
    syscall
    
    li $a0, '\n'
    li $v0, 11
    syscall

    la $a0, v1
    li $v0, 4
    syscall

    li $v0, 1
    move $a0, $t1
    syscall
    
    li $a0, '\n'
    li $v0, 11
    syscall

    la $a0 board

    la $a0, num_rows
    li $v0, 4
    syscall

    li $v0, 1
    la $a0, board
    lw $a0, 0($a0)
    syscall
    
    li $a0, '\n'
    li $v0, 11
    syscall

    la $a0, num_columns
    li $v0, 4
    syscall

    li $v0, 1
    la $a0, board
    lw $a0, 4($a0)
    syscall
    li $a0, '\n'
    li $v0, 11
    syscall

    la $a0, board
    lw $t1, 0($a0) # number of rows
    lw $t2, 4($a0) # number of columns
    move $s0, $a0
    addi $s0, $s0, 8

    li $t3, 0 # number of columns counter
    li $t4, 0 # number of row counter
    li $t5, 0 # $t5 = 0

    mul $t5, $t1, $t2

print_column:

	beq $t4, $t1, quit

    li $t3, 0

    print_row:

        beq $t3, $t2, next_row
    	
    	lb $a0, 0($s0)
        beq $a0, 'X', found_X
        beq $a0, 'O', found_O
        beq $a0, '.', found_dot
        
        j found_else

next_row:

    addi $t4, $t4, 1

    li $a0, '\n'
    li $v0, 11
    syscall

    j print_column

found_X:
	
	li $a0, 'X'
 	li $v0, 11
  	syscall

	addi $t3, $t3, 1
    addi $s0, $s0, 1

    j print_row
        
found_O:
	
	li $a0, 'O'
 	li $v0, 11
  	syscall

	addi $t3, $t3, 1
    addi $s0, $s0, 1

    j print_row
    
found_dot:

    li $a0, '.'
 	li $v0, 11
  	syscall

	addi $t3, $t3, 1
    addi $s0, $s0, 1

    j print_row

found_else:
	
	lb $a0, 0($s0)
	li $v0, 11
  	syscall

	addi $t3, $t3, 1
    addi $s0, $s0, 1

    j print_row

quit:
	
	li $v0, 10
	syscall
	
.include "proj4.asm"
