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
filename: .asciiz "/Users/avik/Desktop/My Stuff/SBU/Sophomore Year/Spring 2019/CSE 220/Spring 2019/Projects/Project 4/boards/game_status3.txt"
.align 2
board: .space 1000
num_columns: .asciiz "Number of columns: "
num_rows: .asciiz "Number of rows: "
v0: .asciiz "# of X's v0: "
v1: .asciiz "# of O's v1: "
done: .asciiz "Board has been added!"

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
jal game_status
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

quit:

	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $v0, 10
	syscall
	
.include "proj4.asm"
