# CSE 220 Programming Project #4
# Name: Avik Kadakia
# Net ID: akadakia
# SBU ID: 111304945

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
################################### PART I ########################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #	
    #		$a1 - filename                                                      #
    #                                                                           #
	#		$s0 - board                                                         #	
    #		$s1 - filename / Counter for the stack                              #
    #		$s2 - strings_length                                                #
    #		$s3 - $sp                                                           #
    #       $s4 - $sp                                                           #
	#																			#
	#	Returns:																#
	#	   $v0 = binary of # of X's, O's, and invalid chars                     #
	#																    		#
####################################################################################
load_board:

    addi $sp, $sp, -24 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function
	sw $s4, 20($sp) # Stored s4 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = filename

    # Open a file
    li $v0, 13          # system call for open file
    move $a0, $s1       # input file name
    li $a1, 0           # Open for reading (flags are 0: read, 1: write)
    li $a2, 0           # mode is ignored
    syscall             # open a file (file descriptor returned in $v0)
    
    beq $v0, -1, file_not_found

    move $t0, $v0 # $t0 = file descriptor

    addi $sp, $sp, -1   # Allocated space on the stack to read the file
    move $s3, $sp       # To store on the stack

    li $t9, 2
    li $t2, 0

    li $t4, 0 # Number of X's
    li $t5, 0 # Number of O's
    li $t6, 0 # Number of invalid characters

read_file:

    move $s4, $s3

    # Read the file just opened
    li $v0, 14      	# system call for write to file
    move $a0, $t0     	# file descriptor 
    move $a1, $s4 		# address of buffer from which to write
    li $a2, 1      		# hardcoded buffer length
    syscall         	# Read the file

    beq $v0, 0, close_file # If nothing is read, file has reached the end, thus close it

    beq $t9, 2, check_num_rows
    beq $t9, 1, check_num_columns

    lb $t1, 0($s4) # get the first char read.

    beq $t1, 'X', add_X_Part_I

    beq $t1, 'O', add_O_Part_I

    beq $t1, '.', add_dot
    
    bne $t1, '\n', found_invalid_character

    j read_file

check_num_rows:

    lb $t1, 0($s4) # get the num read.

    beq $t1, '\n', got_num_rows # If the char read is next line, continue reading
    
    addi $t1, $t1, -48

    li $t3, 10

    mul $t2, $t2, $t3 # multiply $t2 by 10

    add $t2, $t2, $t1 # add the new number read

    j read_file

got_num_rows:

    li $t9, 1
    sw $t2, 0($s0)
    li $t2, 0
    # move $s0, $a0
    addi $s0, $s0, 4

    j read_file

check_num_columns:

    lb $t1, 0($s4) # get the num read.

    beq $t1, '\n', got_num_columns # If the char read is next line, continue reading

    li $t3, 10
    
    addi $t1, $t1, -48

    mul $t2, $t2, $t3 # multiply $t2 by 10

    add $t2, $t2, $t1 # add the new number read 

    j read_file

got_num_columns:

    li $t9, 0
    sw $t2, 0($s0)
    li $t2, 0
    # move $s0, $a0
    addi $s0, $s0, 4

    j read_file

found_invalid_character:

    addi $t6, $t6, 1
    j add_dot

add_X_Part_I:

	li $t2, 'X'
	sb $t2, 0($s0)
    addi $s0, $s0, 1
    addi $t4, $t4, 1

    j read_file

add_O_Part_I:

    li $t2, 'O'
	sb $t2, 0($s0)
    addi $s0, $s0, 1
    addi $t5, $t5, 1

    j read_file

add_dot:

    li $t2, '.'
	sb $t2, 0($s0)
    addi $s0, $s0, 1

    j read_file

close_file:
	
	li   $v0, 16       # system call for close file
    move $a0, $t0      # file descriptor to close
    syscall            # close file
    
    addi $sp, $sp, 1 # Deallocated stack space saved to read the file
    
    j store_v0

file_not_found:
	
 	li $v0, -1
	
 	j Part_I_Done

store_v0:

    li $v0, 0
    move $v0, $t4
    sll $v0, $v0, 8

    add $v0, $v0, $t5
    sll $v0, $v0, 8

    add $v0, $v0, $t6

    j Part_I_Done

Part_I_Done:
    
    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function
    lw $s4, 20($sp) # Loaded s4 from the caller function

    addi $sp, $sp, 24 # Deallocated the stack space
    jr $ra


################################### PART II #######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
	#                                                                           #
	#	Returns:																#
	#	   $v0 = the character found in board.slots[row][col]                   #
    #			 -1	if either row or col (or both) are invalid			   		#
	#																    		#
####################################################################################
get_slot:

    addi $sp, $sp, -16 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number

    lb $t1, 0($s0) # $t1 = number of rows on the board
    lb $t2, 4($s0) # $t2 = number of columns on the board

    blt $t1, $s1, invalid_index_part_II
    blt $t2, $s2, invalid_index_part_II

    blt $s1, 0, invalid_index_part_II
    blt $s2, 0, invalid_index_part_II

    addi $s0, $s0, 8

    mul $t4, $s1, $t2
    add $t4, $t4, $s2
    add $s0, $s0, $t4

    lb $v0, 0($s0)

    j Part_II_Done

invalid_index_part_II:

    li $v0, -1
    j Part_II_Done

Part_II_Done:
    
    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function

    addi $sp, $sp, 16 # Deallocated the stack space
    jr $ra

################################### PART III ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #		$a3 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
    #		$s3 - character                                                     #
	#																			#
	#	Returns:																#
	#	   $v0 = the character found in board.slots[row][col]                   #
    #			 -1	if either row or col (or both) are invalid			   		#
	#																    		#
####################################################################################
set_slot:

    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s2 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number
    move $s3, $a3 # $s3 = character

    lb $t1, 0($s0) # $t1 = number of rows on the board
    lb $t2, 4($s0) # $t2 = number of columns on the board

    blt $t1, $s1, invalid_index_part_III
    blt $t2, $s2, invalid_index_part_III

    blt $s1, 0, invalid_index_part_III
    blt $s2, 0, invalid_index_part_III

    addi $s0, $s0, 8

    mul $t4, $s1, $t2
    add $t4, $t4, $s2
    add $s0, $s0, $t4

    sb $s3, 0($s0)
    move $v0, $s3

    j Part_III_Done

invalid_index_part_III:

    li $v0, -1
    j Part_III_Done

Part_III_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra

#################################### PART IV ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #		$a3 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
    #		$s3 - character                                                     #
	#                                                                           #
	#	Returns:																#
	#	   $v0 = the character found in board.slots[row][col]                   #
    #			 -1	if either row or col (or both) are invalid			   		#
	#																    		#
####################################################################################
place_piece:

    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s2 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number
    move $s3, $a3 # $s3 = character

    jal get_slot

    beq $v0, -1, invalid_input_Part_IV

    beq $v0, 'X', invalid_input_Part_IV

    beq $v0, 'O', invalid_input_Part_IV

    beq $s3, 'X', add_char

    beq $s3, 'O', add_char

    j invalid_input_Part_IV

add_char:

    jal set_slot

    beq $v0, 'X', Part_IV_Done

    beq $v0, 'O', Part_IV_Done

invalid_input_Part_IV:

    li $v0, -1
    j Part_IV_Done

Part_IV_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra

#################################### PART V #######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - Number of X's                                                 #
    #		$s2 - Number of O's                                                 #
	#																			#
	#	Returns:																#
	#	   $v0 = Number of X's                                                  #
	#	   $v1 = Number of O's                                                  #
	#																    		#
####################################################################################
game_status:

    addi $sp, $sp, -16 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) 	# Loaded s1 from the caller function
    sw $s2, 12($sp) # Loaded s2 from the caller function

    move $s0, $a0
    addi $s0, $s0, 8

    li $s1, 0
    li $s2, 0

    lb $t0, 0($a0)
    lb $t1, 4($a0)

    mul $t1, $t1, $t0

    li $t2, 0 

next_char:

    beq $t2, $t1, set_V_registers

    lb $t0, 0($s0)

    beq $t0, 'X', add_X_Part_V
    beq $t0, 'O', add_O_Part_V

    addi $s0, $s0, 1
    addi $t2, $t2, 1

    j next_char

add_X_Part_V:

    addi $s0, $s0, 1
    addi $t2, $t2, 1

    addi $s1, $s1, 1

    j next_char

add_O_Part_V:

    addi $s0, $s0, 1
    addi $t2, $t2, 1

    addi $s2, $s2, 1

    j next_char

set_V_registers:

    move $v0, $s1
    move $v1, $s2

    j Part_V_Done

Part_V_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
    lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    
    addi $sp, $sp, 16 # Deallocated the stack space
    jr $ra

#################################### PART VI ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #		$a3 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
    #		$s3 - character                                                     #
	#	    $s4 - $v0's value   												#
	#																			#
	#	Returns:																#
	#	   $v0 = the number of pieces captured                                  #
	#	       -1: row or col (or both) are invalid                             #
	#			   player is neither ‘X’ nor ‘O’					    		#
	#			   the slot at the given row and column is not equal to player  #
	#																    		#
####################################################################################
check_horizontal_capture:

    addi $sp, $sp, -24 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function
    sw $s4, 20($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number
    move $s3, $a3 # $s3 = character
    li $s4, 0
    li $t8, 0
    move $t7, $s2 # $t7 = column number

    jal get_slot

    beq $v0, $s3, check_for_horizontal_capture

    beq $v0, -1, invalid_input_Part_VI
    bne $v0, $s3, invalid_input_Part_VI
    bne $s3, 'X', maybe_invalid_input_Part_VI

    j no_capture_Part_VI

check_for_horizontal_capture:

    move $t0, $s1
    bge $t0, 3, check_before_Part_VI

    lb $t0, 4($a0)
    move $t1, $s2
    sub $t0, $t0, $t1

    bge $t0, 3, check_after_Part_VI

    j no_capture_Part_VI

check_before_Part_VI:

    beq $s3, 'X', check_X_capture_Part_VI
    beq $s3, 'O', check_O_capture_Part_VI

    j invalid_input_Part_VI 

reset_column_Part_VI:

    addi $t8, $t8, 1

    beq $t8, 2, set_v0_Part_VI
    beq $t8, 1, check_after_Part_VI

    move $a2, $t7

check_after_Part_VI:

    lb $t0, 4($a0)
    sub $t0, $t0, $s2

    blt $t0, 3, set_v0_Part_VI

    addi $a2, $a2, 3

    beq $s3, 'X', check_X_capture_Part_VI
    beq $s3, 'O', check_O_capture_Part_VI

check_X_capture_Part_VI:

    jal get_slot
    bne $v0, 'X', reset_column_Part_VI
    
    addi $a2, $a2, -1
    jal get_slot
    bne $v0, 'O', reset_column_Part_VI

    addi $a2, $a2, -1
    jal get_slot
    bne $v0, 'O', reset_column_Part_VI

    addi $a2, $a2, -1
    jal get_slot
    bne $v0, 'X', reset_column_Part_VI

    addi $a2, $a2, 2
    li $a3, '.'
    jal set_slot

    addi $a2, $a2, -1
    li $a3, '.'
    jal set_slot

    addi $s4, $s4, 2
    addi $a2, $a2, 2

    j reset_column_Part_VI

check_O_capture_Part_VI:

    jal get_slot

    bne $v0, 'O', reset_column_Part_VI
    addi $a2, $a2, -1
    jal get_slot

    bne $v0, 'X', reset_column_Part_VI
    addi $a2, $a2, -1
    jal get_slot

    bne $v0, 'X', reset_column_Part_VI
    addi $a2, $a2, -1
    jal get_slot

    bne $v0, 'O', reset_column_Part_VI
    
    addi $a2, $a2, 2
    li $a3, '.'
    jal set_slot

    addi $a2, $a2, -1
    li $t0, '.'
    
    jal set_slot

    addi $s4, $s4, 2
    addi $a2, $a2, 2
    
    j reset_column_Part_VI

no_capture_Part_VI:

    li $v0, 0
    j Part_VI_Done

maybe_invalid_input_Part_VI:

    beq $s3, 'O', check_for_horizontal_capture

invalid_input_Part_VI:

    li $v0, -1
    j Part_VI_Done

set_v0_Part_VI:

    move $v0, $s4
    j Part_VI_Done

Part_VI_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function    
    lw $s4, 20($sp) # Loaded s4 from the caller function

    addi $sp, $sp, 24 # Deallocated the stack space
    jr $ra

#################################### PART VII #####################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #		$a3 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
    #		$s3 - character                                                     #
	#	    $s4 - $v0's value   												#
	#																			#
	#	Returns:																#
	#	   $v0 = the number of pieces captured                                  #
	#	       -1: row or col (or both) are invalid                             #
	#			   player is neither ‘X’ nor ‘O’					    		#
	#			   the slot at the given row and column is not equal to player  #
	#																    		#
####################################################################################
check_vertical_capture:

    addi $sp, $sp, -24 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function
    sw $s4, 20($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number
    move $s3, $a3 # $s3 = character
    li $s4, 0
    li $t8, 0
    move $t7, $s1 # $t7 = row number

    jal get_slot

    beq $v0, $s3, check_for_vertical_capture

    beq $v0, -1, invalid_input_Part_VII
    bne $v0, $s3, invalid_input_Part_VII
    bne $s3, 'X', maybe_invalid_input_Part_VII

    j no_capture_Part_VII

check_for_vertical_capture:

    lb $t0, 4($a0)
    sub $t0, $t0, $s1
    bge $t0, 3, check_below_Part_VII

    bge $s1, 3, check_above_Part_VII

    j no_capture_Part_VII

check_below_Part_VII:

    beq $s3, 'X', check_X_capture_Part_VII
    beq $s3, 'O', check_O_capture_Part_VII

    j invalid_input_Part_VII

reset_row_Part_VII:

    addi $t8, $t8, 1
    move $t7, $a1
    beq $t8, 2, set_v0_Part_VII

check_above_Part_VII:

    beq $t8, 2, set_v0_Part_VII
    addi $a1, $a1, -3
    
    beq $s3, 'X', check_X_capture_Part_VII
    beq $s3, 'O', check_O_capture_Part_VII

check_X_capture_Part_VII:

    jal get_slot

    bne $v0, 'X', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'O', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'O', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'X', reset_row_Part_VII

    addi $a1, $a1, -2
    li $a3, '.'
    jal set_slot

    addi $a1, $a1, 1
    li $a3, '.'
    jal set_slot

    addi $s4, $s4, 2
    addi $a1, $a1, -2

    j reset_row_Part_VII

check_O_capture_Part_VII:

    jal get_slot

    bne $v0, 'O', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'X', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'X', reset_row_Part_VII
    addi $a1, $a1, 1
    jal get_slot

    bne $v0, 'O', reset_row_Part_VII
    
    addi $a1, $a1, -2
    li $a3, '.'
    jal set_slot

    addi $a1, $a1, 1
    li $a3, '.'
    jal set_slot

    addi $s4, $s4, 2
    addi $a1, $a1, -2

    j reset_row_Part_VII

no_capture_Part_VII:

    li $v0, 0
    j Part_VII_Done

maybe_invalid_input_Part_VII:

    beq $s3, 'O', check_for_vertical_capture

invalid_input_Part_VII:

    li $v0, -1
    j Part_VII_Done

set_v0_Part_VII:

    move $v0, $s4
    j Part_VII_Done

Part_VII_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function    
    lw $s4, 20($sp) # Loaded s4 from the caller function

    addi $sp, $sp, 24 # Deallocated the stack space
    jr $ra

################################## PART VIII #####################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - row number                                                    #
    #		$a2 - column number                                                 #
    #		$a3 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - row number                                                    #
    #		$s2 - column number                                                 #
    #		$s3 - character                                                     #
	#	    $s4 - $v0's value   												#
    #		$s5 - row number                                                    #
    #		$s6 - column number                                                 #
	#																			#
	#	Returns:																#
	#	   $v0 = the number of pieces captured                                  #
	#	       -1: row or col (or both) are invalid                             #
	#			   player is neither ‘X’ nor ‘O’					    		#
	#			   the slot at the given row and column is not equal to player  #
	#																    		#
####################################################################################
check_diagonal_capture:

    addi $sp, $sp, -32 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function
    sw $s4, 20($sp) # Stored s4 from the caller function
    sw $s5, 24($sp) # Stored s5 from the caller function
    sw $s6, 28($sp) # Stored s6 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = row number
    move $s2, $a2 # $s2 = column number
    move $s3, $a3 # $s3 = character
    li $s4, 0
    move $s5, $s1 # $s5 = row number
    move $s6, $s2 # $s6 = column number
    
    li $t6, 0 # y
    li $t5, 0 # x
    li $t8, -1

    jal get_slot

    beq $v0, $s3, reset_row_and_column_Part_VIII

    beq $v0, -1, invalid_input_Part_VIII
    bne $v0, $s3, invalid_input_Part_VIII
    bne $s3, 'X', maybe_invalid_input_Part_VIII

    j no_capture_Part_VIII

reset_row_and_column_Part_VIII:

    addi $t8, $t8, 1

    move $a1, $s5
    move $a2, $s6

    li $t5, 0 # x
    li $t6, 0 # y

    beq $t8, 0, check_NE_Part_VIII
    beq $t8, 1, check_NW_Part_VIII
    beq $t8, 2, check_SW_Part_VIII
    beq $t8, 3, check_SE_Part_VIII
    beq $t8, 4, set_v0_Part_VIII

    j set_v0_Part_VIII

check_NE_Part_VIII:

    li $t5, -1   # x
    li $t6, 1    # y

    lb $t0, 4($a0)
    sub $t0, $t0, $s2 # $s2 - column

    blt $t0, 3, reset_row_and_column_Part_VIII
    blt $s1, 3, reset_row_and_column_Part_VIII

    beq $s3, 'X', check_X_capture_Part_VIII
    beq $s3, 'O', check_O_capture_Part_VIII

    j invalid_input_Part_VIII

check_NW_Part_VIII:

    li $t5, -1   # x
    li $t6, -1   # y

    blt $s2, 3, reset_row_and_column_Part_VIII
    blt $s1, 3, reset_row_and_column_Part_VIII

    beq $s3, 'X', check_X_capture_Part_VIII
    beq $s3, 'O', check_O_capture_Part_VIII

    j invalid_input_Part_VIII

check_SW_Part_VIII:

    li $t5, 1   # x
    li $t6, -1   # y

    blt $s2, 3, reset_row_and_column_Part_VIII

    lb $t0, 0($a0)
    sub $t0, $t0, $s1
    blt $t0, 3, reset_row_and_column_Part_VIII

    beq $s3, 'X', check_X_capture_Part_VIII
    beq $s3, 'O', check_O_capture_Part_VIII

    j invalid_input_Part_VIII

check_SE_Part_VIII:

    li $t5, 1   # x
    li $t6, 1   # y

    lb $t0, 4($a0)
    sub $t0, $t0, $s2

    blt $t0, 3, reset_row_and_column_Part_VIII

    lb $t0, 0($a0)
    sub $t0, $t0, $s1
    blt $t0, 3, reset_row_and_column_Part_VIII

    beq $s3, 'X', check_X_capture_Part_VIII
    beq $s3, 'O', check_O_capture_Part_VIII

    j invalid_input_Part_VIII

check_X_capture_Part_VIII:

    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3

    jal get_slot
    bne $v0, 'X', reset_row_and_column_Part_VIII
    
    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'O', reset_row_and_column_Part_VIII

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'O', reset_row_and_column_Part_VIII

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'X', reset_row_and_column_Part_VIII

    sll $t5, $t5, 1
    sll $t6, $t6, 1

    li $t0, -1

    mul $t5, $t5, $t0
    mul $t6, $t6, $t0

    add $a1, $a1, $t5
    add $a2, $a2, $t6

    srl $t5, $t5, 1
    srl $t6, $t6, 1

    li $t0, -1

    mul $t5, $t5, $t0
    mul $t6, $t6, $t0
    
    li $a3, '.'
    jal set_slot

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    li $a3, '.'
    jal set_slot

    addi $s4, $s4, 2
    j reset_row_and_column_Part_VIII

check_O_capture_Part_VIII:

    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3

    jal get_slot

    bne $v0, 'O', reset_row_and_column_Part_VIII
    
    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'X', reset_row_and_column_Part_VIII

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'X', reset_row_and_column_Part_VIII

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    jal get_slot

    bne $v0, 'O', reset_row_and_column_Part_VIII

    sll $t5, $t5, 1
    sll $t6, $t6, 1

    li $t0, -1

    mul $t5, $t5, $t0
    mul $t6, $t6, $t0

    add $a1, $a1, $t5
    add $a2, $a2, $t6

    srl $t5, $t5, 1
    srl $t6, $t6, 1

    li $t0, -1

    mul $t5, $t5, $t0
    mul $t6, $t6, $t0
    
    li $a3, '.'
    jal set_slot

    add $a1, $a1, $t5
    add $a2, $a2, $t6
    li $a3, '.'
    jal set_slot

    addi $s4, $s4, 2

    j reset_row_and_column_Part_VIII

no_capture_Part_VIII:

    li $v0, 0
    j Part_VIII_Done

maybe_invalid_input_Part_VIII:

    beq $s3, 'O', reset_row_and_column_Part_VIII

invalid_input_Part_VIII:

    li $v0, -1
    j Part_VIII_Done

set_v0_Part_VIII:

    move $v0, $s4
    j Part_VIII_Done

Part_VIII_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function    
    lw $s4, 20($sp) # Loaded s4 from the caller function
    lw $s5, 24($sp) # Loaded s5 from the caller function
    lw $s6, 28($sp) # Loaded s6 from the caller function

    addi $sp, $sp, 32 # Deallocated the stack space
    jr $ra

#################################### PART IX ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - character                                                     #
	#                                                                           #
	#	    $t0 - file descriptor												#
	#	    $t1 - current character / indicator to read num_rows                #
    #               and num_columns                                             #
	#	    $t2 - 4 * (Capacity + 2) 			                                #
	#																			#
	#	Returns:																#
	#	   $v0 = Number of X's                                                  #
	#	   $v1 = Number of O's                                                  #
	#																    		#
####################################################################################
check_horizontal_winner:

    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s3, $a1 # $s3 = character

    li $s1, 0 # row number
    li $s2, -1 # column number

    move $a1, $s1 # row number
    move $a2, $s2 # column number
    move $a3, $s3 # character

    j check_for_horizontal_winner_Part_IX

check_for_horizontal_winner_Part_IX:

    lb $t6, 0($a0) # $t6 = number of rows
    lb $t7, 4($a0) # #t7 = number of columns

    ble $t6, 4, invalid_input_Part_IX
    
    addi $t7, $t7, -4 # #t7 = number of columns

check_column_Part_IX:

	bgt $a1, $t6, invalid_input_Part_IX # number of rows = rows_counter go to next_row

    li $a2, -1 # reset column position to 0

    check_row_Part_IX:
        
        addi $a2, $a2, 1
        move $s2, $a2
        bge $a2, $t7, next_row_Part_IX # number of columns = columns_counter go to next row
    	jal get_slot
        bne $v0, $s3, check_row_Part_IX

        addi $a2, $a2, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_IX

        addi $a2, $a2, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_IX

        addi $a2, $a2, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_IX

        addi $a2, $a2, 1
        jal get_slot
        beq $v0, $s3, found_winner_Part_IX

        j check_row_Part_IX

next_row_Part_IX:

    addi $a1, $a1, 1
    move $s1, $a1

    j check_column_Part_IX

found_winner_Part_IX:

    move $v0, $s1
    move $v1, $s2

    j Part_IX_Done

invalid_input_Part_IX:

    li $v0, -1
    li $v1, -1

    j Part_IX_Done

Part_IX_Done:

    lw $ra, 0($sp) 	# Loaded the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s2 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra

#################################### PART X #######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - character                                                     #
	#                                                                           #
	#	    $t0 - file descriptor												#
	#	    $t1 - current character / indicator to read num_rows                #
    #               and num_columns                                             #
	#	    $t2 - 4 * (Capacity + 2) 			                                #
	#																			#
	#	Returns:																#
	#	   $v0 = Number of X's                                                  #
	#	   $v1 = Number of O's                                                  #
	#																    		#
####################################################################################
check_vertical_winner:

    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s3, $a1 # $s3 = character

    li $s1, 0 # row number
    li $s2, 0 # column number

    move $a1, $s1 # row number
    move $a2, $s2 # column number
    move $a3, $s3 # character

    j check_for_vertical_winner_Part_X

check_for_vertical_winner_Part_X:

    lb $t6, 0($a0) # $t6 = number of rows
    lb $t7, 4($a0) # $t7 = number of columns

    ble $t6, 4, invalid_input_Part_X
    
    addi $t6, $t6, -4 # $t7 = number of columns

check_column_Part_X:

	bgt $a1, $t6, invalid_input_Part_X # number of rows = rows_counter then quit
    move $a1, $s1
    li $a2, -1 # reset column position to 0

    check_row_Part_X:
        
        addi $a2, $a2, 1
        move $a1, $s1
        bge $a2, $t7, next_row_Part_X # number of columns = columns_counter go to next row
    	jal get_slot
        bne $v0, $s3, check_row_Part_X

        addi $a1, $a1, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_X

        addi $a1, $a1, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_X

        addi $a1, $a1, 1
        jal get_slot
        bne $v0, $s3, check_row_Part_X

        addi $a1, $a1, 1
        jal get_slot
        beq $v0, $s3, found_winner_Part_X

        j check_row_Part_X

next_row_Part_X:

    addi $a1, $a1, 1
    move $s1, $a1

    j check_column_Part_X

found_winner_Part_X:

    move $v0, $s1
    move $v1, $a2

    j Part_X_Done

invalid_input_Part_X:

    li $v0, -1
    li $v1, -1

    j Part_X_Done

Part_X_Done:

    lw $ra, 0($sp) 	# Loaded the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s2 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra

#################################### PART XI ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - character                                                     #
	#                                                                           #
	#	    $t0 - file descriptor												#
	#	    $t1 - current character / indicator to read num_rows                #
    #               and num_columns                                             #
	#	    $t2 - 4 * (Capacity + 2) 			                                #
	#																			#
	#	Returns:																#
	#	   $v0 = Number of X's                                                  #
	#	   $v1 = Number of O's                                                  #
	#																    		#
####################################################################################
check_sw_ne_diagonal_winner:
    
    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s3, $a1 # $s3 = character

    li $s1, 3 # row number
    li $s2, 0 # column number

    move $a1, $s1 # row number
    move $a2, $s2 # column number
    move $a3, $s3 # character

    j check_for_sw_ne_diagonal_winner_Part_XI

check_for_sw_ne_diagonal_winner_Part_XI:

    lb $t0, 0($a0) # $t0 = number of rows to check till
    lb $t1, 4($a0) # $t1 = number of columns to check till

    blt $t0, 5, invalid_input_Part_XI
    blt $t1, 5, invalid_input_Part_XI

    addi $t1, $t1, -4 # $t1 = number of columns

check_column_diagonally_Part_XI:

    bgt $a2, $t0, invalid_input_Part_XI
    move $a1, $s1
    li $a2, 0 # reset column position to 0

    # Check the number of rows from row 4 to the number_rows and check the number of columns from num_columns to num_columns - 4
    check_row_diagonally_Part_XI:

        addi $s1, $s1, 1
        move $a1, $s1
        move $a2, $s2
        bgt $a1, $t2, next_column_Part_XI
        bge $a2, $t1, next_row_Part_XI
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XI

        addi $a2, $a2, 1
        addi $a1, $a1, -1 
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XI

        addi $a2, $a2, 1
        addi $a1, $a1, -1
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XI

        addi $a2, $a2, 1
        addi $a1, $a1, -1
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XI

        addi $a2, $a2, 1
        addi $a1, $a1, -1
        jal get_slot
        beq $v0, $s3, found_winner_Part_XI

next_column_Part_XI:

    li $s1, 3
    addi $a2, $a2, 1
    move $s2, $a2

    j check_column_diagonally_Part_XI

next_row_Part_XI:

    li $s1, 3
    addi $a2, $a2, 1
    move $s2, $a2

    j check_column_diagonally_Part_XI

found_winner_Part_XI:

    move $v0, $s1
    move $v1, $s2

    j Part_XI_Done

invalid_input_Part_XI:

    li $v0, -1
    li $v1, -1

    j Part_XI_Done

Part_XI_Done:

    lw $ra, 0($sp) 	# Loaded the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s2 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra

################################### PART XII ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - character                                                     #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - character                                                     #
	#                                                                           #
	#	    $t0 - file descriptor												#
	#	    $t1 - current character / indicator to read num_rows                #
    #               and num_columns                                             #
	#	    $t2 - 4 * (Capacity + 2) 			                                #
	#																			#
	#	Returns:																#
	#	   $v0 = Number of X's                                                  #
	#	   $v1 = Number of O's                                                  #
	#																    		#
####################################################################################
check_nw_se_diagonal_winner:
    
    addi $sp, $sp, -20 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function

    move $s0, $a0 # $s0 = board
    move $s3, $a1 # $s3 = character

    li $s1, -1 # row number
    li $s2, 0 # column number

    move $a1, $s1 # row number
    move $a2, $s2 # column number
    move $a3, $s3 # character

    j check_for_nw_se_diagonal_winner_Part_XII

check_for_nw_se_diagonal_winner_Part_XII:

    lb $t0, 0($a0) # $t0 = number of rows to check till
    lb $t1, 4($a0) # $t1 = number of columns to check till

    blt $t0, 5, invalid_input_Part_XII
    blt $t1, 5, invalid_input_Part_XII

    addi $t1, $t1, -4 # $t1 = number of columns
    addi $t0, $t0, -4 # $t0 = number of rows

check_column_diagonally_Part_XII:

    bgt $a2, $t0, invalid_input_Part_XII
    move $a1, $s1
    li $a2, 0 # reset column position to 0

    # Check the number of rows from row 4 to the number_rows and check the number of columns from num_columns to num_columns - 4
    check_row_diagonally_Part_XII:

        addi $s1, $s1, 1
        move $a1, $s1
        move $a2, $s2
        bge $a1, $t0, next_column_Part_XII
        bge $a2, $t1, next_row_Part_XII
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XII

        addi $a2, $a2, 1
        addi $a1, $a1, 1 
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XII

        addi $a2, $a2, 1
        addi $a1, $a1, 1
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XII

        addi $a2, $a2, 1
        addi $a1, $a1, 1
        jal get_slot
        bne $v0, $s3, check_row_diagonally_Part_XII

        addi $a2, $a2, 1
        addi $a1, $a1, 1
        jal get_slot
        beq $v0, $s3, found_winner_Part_XII

next_column_Part_XII:

    li $s1, -1
    addi $a2, $a2, 1
    move $s2, $a2

    j check_column_diagonally_Part_XII

next_row_Part_XII:

    li $s1, 3
    addi $a2, $a2, 1
    move $s2, $a2

    j check_column_diagonally_Part_XII

found_winner_Part_XII:

    move $v0, $s1
    move $v1, $s2

    j Part_XII_Done

invalid_input_Part_XII:

    li $v0, -1
    li $v1, -1

    j Part_XII_Done

Part_XII_Done:

    lw $ra, 0($sp) 	# Loaded the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s2 from the caller function

    addi $sp, $sp, 20 # Deallocated the stack space
    jr $ra


################################## PART XIII ######################################
	#																			#
	#	Parameters:																#
	#		$a0 - board                                                         #
    #		$a1 - filename                                                      #
    #		$a2 - turns                                                         #
    #		$a3 - num_turns_to_play                                             #
    #                                                                           #
	#		$s0 - board                                                         #
    #		$s1 - filename                                                      #
    #		$s2 - turns                                                         #
    #		$s3 - num_turns_to_play                                             #
	#																			#
	#	Returns:																#
	#	   $v0 = the character found in board.slots[row][col]                   #
    #			 -1	if either row or col (or both) are invalid			   		#
	#																    		#
####################################################################################
simulate_game:

    addi $sp, $sp, -36 # Allocated space on the stack
	sw $ra, 0($sp) # Stored the return address on the stack
	sw $s0, 4($sp) # Stored s0 from the caller function
    sw $s1, 8($sp) # Stored s1 from the caller function
    sw $s2, 12($sp) # Stored s2 from the caller function
    sw $s3, 16($sp) # Stored s3 from the caller function
    sw $s4, 20($sp) # Stored s4 from the caller function
    sw $s5, 24($sp) # Stored s5 from the caller function
    sw $s6, 28($sp) # Stored s6 from the caller function
    sw $s7, 32($sp) # Stored s7 from the caller function

    move $s0, $a0 # $s0 = board
    move $s1, $a1 # $s1 = filename
    move $s2, $a2 # $s2 = turns
    move $s3, $a3 # $s3 = num_turns_to_play
    li $s4, 0 # $s4 = valid_num_turns
    li $s5, 0 # $s5 = turns_length
    li $s6, 0 # $s6 = turn_number
    li $s7, 0 # $s7 = character extracted

    jal load_board

    beq $v0, -1, file_not_found_Part_XIII

    li $s7, 0 # $s7 = game_over

    move $a0, $s2
    jal strlen

    move $a0, $s0

    li $t7, 5
    div $v0, $t7
    mflo $s5
    
while_loop_Part_XIII:

    li $t7, 10 # $t7 = 10

    beq $s7, 1, winner_found_Part_XIII
    bge $s4, $s3, winner_not_found_Part_XIII
    bge $s6, $s5, winner_not_found_Part_XIII

    lb $s3, 0($s2) # $s3 = character
    addi $s2, $s2, 1

    lb $t5, 0($s2) # get the row number.
    addi $s2, $s2, 1
    addi $t5, $t5, -48
    mul $t5, $t5, $t7 # multiply $t5 by 10
    move $a1, $t5 # move the new number read

    lb $t5, 0($s2) # get the row number
    addi $s2, $s2, 1
    addi $t5, $t5, -48
    add $a1, $a1, $t5 # $a1 = new row number

    lb $t6, 0($s2) # get the column number.
    addi $s2, $s2, 1
    addi $t6, $t6, -48
    mul $t6, $t6, $t7 # multiply $t6 by 10
    move $a2, $t6 # move the new number read

    lb $t6, 0($s2) # get the column number
    addi $t6, $t6, -48
    addi $s2, $s2, 1
    add $a2, $a2, $t6 # $a2 = new column number

    addi $s6, $s6, 1 # turn_number++

    move $a3, $s3

    lb $t8, 0($s0)
    lb $t9, 4($s0)

    beq $s3, 'O', placing_the_piece_Part_XIII
    beq $s3, 'X', placing_the_piece_Part_XIII

    j while_loop_Part_XIII

placing_the_piece_Part_XIII:

    bge $a1, $t8, while_loop_Part_XIII
    bge $a2, $t9, while_loop_Part_XIII

    jal place_piece

    beq $v0, -1, while_loop_Part_XIII

    addi $s4, $s4, 1 # valid_num_turns++

piece_placed_Part_XIII:

    jal check_horizontal_capture
    jal check_vertical_capture
    jal check_diagonal_capture

    jal check_horizontal_winner

    bne $v0, -1, winner_found_Part_XIII

    jal check_vertical_winner

    bne $v0, -1, winner_found_Part_XIII

    jal check_sw_ne_diagonal_winner

    bne $v0, -1, winner_found_Part_XIII

    jal check_nw_se_diagonal_winner

    bne $v0, -1, winner_found_Part_XIII

    jal game_status 

    beq $s7, 1, winner_found_Part_XIII

    lb $t8, 0($s0)
    lb $t9, 4($s0)

    mul $t8, $t8, $t9
    add $t9, $v0, $v1
    beq $t8, $t9, winner_not_found_Part_XIII

    j while_loop_Part_XIII

piece_placed_found_winner_Part_XIII:

    move $v0, $s4
    move $v1, $s3

    li $s7, 1

    jr $ra

record_winner_Part_XIII:

    li $s7, 1

    move $v0, $s4
    move $v1, $s3

    j Part_XIII_Done

winner_not_found_Part_XIII:

    move $v0, $s4
    li $v1, -1

    j Part_XIII_Done

winner_found_Part_XIII:

    li $s7, 1

    move $v0, $s4
    move $v1, $a3

    j Part_XIII_Done

file_not_found_Part_XIII:

    li $v0, 0
    li $v1, -1

    j Part_XIII_Done

Part_XIII_Done:

    lw $ra, 0($sp) 	# Stored the return address on the stack
	lw $s0, 4($sp) 	# Loaded s0 from the caller function
	lw $s1, 8($sp) 	# Loaded s1 from the caller function
    lw $s2, 12($sp) # Loaded s2 from the caller function
    lw $s3, 16($sp) # Loaded s3 from the caller function
    lw $s4, 20($sp) # Loaded s4 from the caller function
    lw $s5, 24($sp) # Loaded s5 from the caller function
    lw $s6, 28($sp) # Loaded s6 from the caller function
    lw $s7, 32($sp) # Loaded s7 from the caller function

    addi $sp, $sp, 36 # Deallocated the stack space
    jr $ra

strlen:

	li $t2, 0 # Counter = 0

strlen_loop:

	beq $t0, $0, Done # If the character in the string is equal to null terminating string, end the loop
	addi $t2, $t2, 1 # Counter++

	addi $a0, $a0, 1 # Next character in the string
	lb $t0, 0($a0) # Holds the individual character from $a0
	j strlen_loop

Done:
    move $v0, $t2
    jr $ra