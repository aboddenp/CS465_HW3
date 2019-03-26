# Author: Hamza Mughal
# CS465 S2019
# HW3 

################################
# DESCRIPTION OF ALGORITHM 

# PUT YOUR DESCRIPTION HERE

# END DESCRIPTION OF ALGORITHM
################################

.data # Start of Data Items
	INIT_INPUT: .asciiz "How many instructions to process? "
	INSTR_SEQUENCE: .asciiz "Please input instruction sequence:\n"
	NEWLINE: .asciiz "\n"
	INPUT: .space 9
	
	
# End of Data Items

.text
main:
	la $a0, INIT_INPUT
	li $v0, 4
	syscall # Print out message asking for N (number of instructions to process)
	
	li $v0, 5
	syscall # read in Int 
	addi $t1, $v0, 0 
	
	
	la $a0, INSTR_SEQUENCE
	li $v0, 4
	syscall 
	
	li $t0, 0 # loop counter	
	Loop: # Read in N strings
		la $a0, INPUT
		li $a1, 9
		li $v0, 8
		syscall # read in one string and store in INPUT
		
		la $a0, NEWLINE
		li $v0, 4
		syscall 
												
		addi $t0, $t0, 1
		blt $t0, $t1, Loop
		



exit:
	li $v0, 10
	syscall
