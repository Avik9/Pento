###############################################################
# 
# IMPORTANT NOTES
#
# The filename you provide should be given in an absolute path.
# Example: C:/Users/Joe/Documents/CSE 220/Project3/hash_table1.txt
#
# Alternatively, you can leave it as a relative path, but then
# you must move MARS into the same directory as the main files.
# Why? Because MARS is a little buggy with file I/O.
#
################################################################

.data
filename: .asciiz "/Users/avik/Desktop/My Stuff/SBU/Sophomore Year/Spring 2019/CSE 220/Spring 2019/Projects/Project 4/boards/generic_board1.txt"
num_columns: .asciiz "Number of columns: "
num_rows: .asciiz "Number of rows: "
v0: .asciiz "v0: "
done: .asciiz "Board has been added!"

row: .word 3
column: .word 0
char: .asciiz "X"

board:
.word 0
.word 0
.word 0

.text
.globl main

main:

la $a0, board
la $a1, filename
jal load_board

    la $a0, done
    li $v0, 4
    syscall
    
    li $a0, '\n'
    li $v0, 11
    syscall

la $a0, board
lw $a1, row
lw $a2, column
lw $a3, char
jal set_slot
move $t0, $v0

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
    # addi $s0, $s0, 1

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

	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $v0, 10
	syscall
	
.include "proj4.asm"
