# Author: Aster Bodden Pineda 
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
	COMMA: .asciiz ", "
	COLON: .asciiz ": "
	SRC: .asciiz "Source registers: "
	DEST: .asciiz "\n\tDestination register: "
	DEPEN: .asciiz "\n\tDependences: " 
	Istr: .asciiz "I"
	LINE:.asciiz "-------------------------------------------\n"
	NONE: .asciiz "none" 
	
	
# End of Data Items

.text
main:

	###### stack allocation/ store reg ################
	
	addi $sp, $sp, -20
	sw $s0, 0($sp) #save $s0 value 
	sw $s1, 4($sp) # save s1 address 
	sw $ra, 8($sp) #save return address 
	
	
	la $a0, INIT_INPUT
	li $v0, 4
	syscall # Print out message asking for N (number of instructions to process)
	
	li $v0, 5
	syscall # read in Int 
	addi $t1, $v0, 0 
	move $s1, $t1 # save instruction count in s1 
	
	# Allocate enough data in the heap to store all int instructions
	li $t2, 0x4
	mul $a0,$t1,$t2 #  multiply the number of instructions times int data type 
	li $v0, 9 
	syscall # allocated address is in $v0 
	move $s0, $v0 # move allocated address to $s0 
	
	la $a0, INSTR_SEQUENCE
	li $v0, 4
	syscall 
	
	# store instruction count in stack  
	sw $t1, 12($sp) 
	
	li $t0, 0 # loop counter	
	Loop: # Read in N strings
		la $a0, INPUT
		li $a1, 9
		li $v0, 8
		syscall # read in one string and store in INPUT
		
		sw $t0, 16($sp) # store current counter 
		# Convert String to integer value 
		la $a0, INPUT
		jal ascii2hex 
		
		# restore counter and size 
		lw $t1, 12($sp) 
		lw $t0, 16($sp) 
				
		# store instruction address in heap
		li $t2, 4  
		mul $t2, $t2, $t0 # 4i 
		add $t3, $s0, $t2 # base address + 4i 
		sw $v0, 0($t3) # store integer address at index i 
		
		la $a0, NEWLINE
		li $v0, 4
		syscall 
												
		addi $t0, $t0, 1
		blt $t0, $t1, Loop
	
	# Instrunctios are integers and the base of the array is $s0 and its size is in $s1 
	li $t0, 0 # loop counter	
	test1: 
	
		# print I 
		la $a0, Istr
		li $v0, 4
		syscall 
		
		# print instruction number 
		move $a0, $t0 
		li $v0, 1
		syscall	
		
		# print colon
		la $a0, COLON
		li $v0, 4
		syscall 	
		
		# source String 
		la $a0, SRC
		li $v0, 4
		syscall 
				
		# get instruction from heap 
		li $t2, 4  
		mul $t2, $t2, $t0 # 4i 
		add $t3, $s0, $t2 # base address + 4i 
		lw $a0, 0($t3) # get integer address at index i 
		sw $t0, 12($sp) # store count 	
		jal get_src_reg
				
		# print the source 
		move $a0, $v0 
		li $v0, 1
		syscall
		
		beq $v1, $zero, destination 	# there is no second source register 
		
		# print second source 
		la $a0, COMMA 
		li $v0, 4
		syscall 
		
		move $a0, $v1 
		li $v0, 1
		syscall
		
		# print destination registers 
		destination: 
		# destination String 
		la $a0, DEST
		li $v0, 4
		syscall	
		
		lw $a0, 0($t3) # get integer address at index i 
		jal get_dest_reg
		li $t2, 32
		bne $v0, $t2, pdest
		# print that there is no destination 
		la $a0, NONE 
		li $v0, 4
		syscall	
		j dependancy 
		
		pdest:
		# print the destination 
		move $a0, $v0 
		li $v0, 1
		syscall
		
		dependancy: 
		# destination String 
		la $a0, DEPEN
		li $v0, 4
		syscall	
		
		#print that there is no dependancy 
		
		la $a0, NONE 
		li $v0, 4
		syscall	
		
		la $a0, NEWLINE
		li $v0, 4
		syscall 
		
		# print delimeter line 
		la $a0, LINE 
		li $v0, 4
		syscall 
		
		lw $t0, 12($sp) #restore count 
		addi $t0, $t0, 1
		blt $t0, $s1, test1
	  
exit:
	#restore stack and regs to original values
	lw $s0, 0($sp) 
	lw $s1, 4($sp)
	lw $ra, 8($sp) # restore return address 
	addi $sp, $sp, 20
	
	li $v0, 10
	syscall



########################################## SECTION FOR HELPER METHODS ###################################################
# convert the hexadecimal string in $a0 into integer value returned in vo
ascii2hex:
	addi $t1 , $zero, 8 # stop index 
	addi $t2 , $zero, 0 # index 
	add $t5, $zero, $zero  # saves int instruction
	#convert ascii hex to int values 
	loop: 
		# next character 
		 lb $t3, 0($a0) 
		 
		 #convert to int value 0 - 10 
		 addi $t3, $t3, -0x30
		 addi $t4, $zero, 17
		 blt $t3, $t4, mask # if less than 17 it is not a letter 
		 # convert to int value A - F 
		 addi $t3, $t3, -0x7
		 
		 mask: 
		 or $t5, $t5, $t3
		 
		 addi $t2, $t2, 1 #increment counter 
		 beq $t1, $t2, d1 # check if the loop continues 
		 
		 # prepare for net 4 bits 
		 sll $t5, $t5, 4
		 
		addi $a0, $a0, 1 # move address to next byte 
		j loop # check if the loop continues 
	d1: # loop end 
		move $v0, $t5
		jr $ra

# required subroutines 
#Parameter:instruction is a 32-bit unsigned number representing a machine instruction word.
# Return: an integer with the following possible values of 1-R type, 2-I type, 3-J type, 0-not supported
get_type:

	# push stacks values to restore  before the call ends
	addi $sp, $sp, -16
	sw $s0, 4($sp) 
	sw $s1, 8($sp) 
	sw $ra, 12($sp)

	# R types will have the opcode set to 0 and func can be 32 34 42 
	# I type ocodes are 8 35 and 43 
	# J type will have opcode 2
	
	#obtain Op code and function code 
	sw $a0, 0($sp) #save instruction parameter 
	jal getOpcode
	add $s0, $v0, $zero # save returned OP code 
	lw $a0, 0($sp) #restore instruction 
	jal getFunc 
	add $s1, $v0, $zero # save returned Function code 
	
	add $v0, $zero, $zero # return register if invalid set to 0
	
	#check the OP code
	addi $t0, $zero, 2 
	beq $s0, $zero, R
	beq $s0, $t0, J
	I:
 		addi $t0, $zero, 4  #beq
 		addi $t1, $zero, 35 #lw
 		addi $t2, $zero, 43 #sw
 		addi $t3, $zero, 8 # addi
 		# check that Opcode is valid 
 		beq $s0,$t0, goodI  
 		beq $s0,$t1, goodI 
 		beq $s0,$t2, goodI
 		beq $t3,$t3, goodI
 		j exit_func #not a supported type
 		goodI: 
 			addi $v0, $zero, 1
 			j exit_func
 	R:  
 		addi $t0, $zero, 32 # add
 		addi $t1, $zero, 34 # sub
 		addi $t2, $zero, 42 # slt , 
 		# check that Func is valid 
 		beq $s1,$t0, goodR  
 		beq $s1,$t1, goodR 
 		beq $s1,$t2, goodR
 		j exit #not a supported type
 		goodR: 
 			addi $v0, $zero, 2
 			j exit_func
	J: 	# set return value to 3
		addi $v0, $zero, 3
	
	exit_func: 
		# restore Saved registers and retrun address to original value 
		lw $s0 , 4($sp) 
		lw $s1, 8($sp) 
		lw $ra, 12($sp)
		#restore stack to original value 
		addi $sp, $sp, 16
		jr $ra 
#Parameter: instruction is a 32-bit unsigned number representing a machine instruction word.
# return: 
	#an integer representing the register number which will be updated by executing of this instruction.
	# A valid return should be within the range of [0,31]'
	# Return 32 if no register gets updated by the instruction
	# Retrun 0 for invalid instruction or invalid destination register
	#Note: some instruction might update $rt instead of $rd
get_dest_reg: 
	#make room in stack for ra and other saved variables
	addi $sp, $sp, -8
	sw $ra, 4($sp) # store return address 
	sw $a0, 0($sp) # store paramter 
	# get instruction type 
	jal get_type 
	add $t0, $v0, $zero #save return type 
	beq $t0, $zero, end #if it is an invalid instruction return 0
	
	addi $t1, $zero , 1 
	addi $t3, $zero , 3
	
	beq $t1, $t0, It
	beq $t3, $t0, noUpdate
	# R type 
	Rt:
		lw $a0, 0($sp) # restore instruction
		addi $a1, $zero, 2 # 2ndparam is what register to get (2 = rd)
		jal getRreg # get rd 
		j end 
	
	# I type 
	It:
		lw $a0, 0($sp) #restore instruction before call 
		jal getOpcode #get opcode 
		addi $t0 , $zero, 0x04
		addi $t1 , $zero, 0x2b
		beq $v0, $t0, noUpdate # this instruction does not update any registers 
		beq $v0, $t1, noUpdate # this instruction does not update any registers 
		
		lw $a0, 0($sp) #restore instruction before call 
		addi $a1, $zero, 1 # 2ndparam is what register to get (1 = rt)
		jal getRreg #get rt
		j end 
	
	# J type or any instruction that does not modify a register  
	noUpdate: 
		addi $v0 , $zero, 32
	
	end: 
		#restore return address 
		lw $ra, 4($sp) 
		addi $sp , $sp, 8 # restore stack to original size 
		jr $ra
		
# This function gets the source_register from instruction in $a0 if the instruction has more than two source $v1 
# will have the value of the second source register otherwise its value is 0 
get_src_reg: 
	#store items in the stack 
	addi $sp, $sp, -12 
	sw $s0, 0($sp) 
	sw $ra, 4($sp) 
	sw $s1, 8($sp) 
	
	# save instruction in param 1 
	move $s0, $a0 
	
	# All I and R Mips instructions use RS as one source register 
	li $a1, 0 
	jal getRreg # gets rs and stores it in $v0 
	move $s1, $v0 # save return value 
	
	# get opcode 
	move $a0, $s0 
	jal getOpcode 
	li $t0, 0x23 #load word
	li $t1, 0x08 # addi
	li $v1, 0 # 0 when no second source is used 
	beq $v0, $t0, complete
	beq $v0,$t1, complete
	# two source registers needed for this instruction 
	move $a0, $s0 # move instruction to pass to parameter 
	li $a1, 1
	jal getRreg # returns rt 
	# move second source to second return register 
	move $v1, $v0
	
	#restore register values and exit 
	complete: 
		move $v0, $s1 # store source 1 in return value 
	
	lw $s0, 0($sp) 
	lw $ra, 4($sp) 
	lw $s1, 8($sp) 
	addi $sp, $sp, 12
	jr $ra 
	

# Helper subroutines 
getOpcode: 
	srl $v0, $a0, 26
	jr $ra
getFunc: 
	andi $v0, $a0, 0x3F
	jr $ra
# gets the register in instruction $a0 at position $a1
# 0 = rs 
# 1 = rt
# 2 = rd 
getRreg: 
	addi $t0, $zero, 1
	beq $a1, $zero, rs 
	beq $a1, $t0, rt 
	rd: 
		srl $v0, $a0, 11 #shift to rd position 
		j return 		
	rs:
		srl $v0, $a0, 21 #shift to rs position
		j return 
	rt: 
		srl $v0, $a0, 16 #shift to rt position
	
	return: 
		#save only the six bits needed for registers
		andi $v0, $v0, 0x1F
		jr $ra 